/// The in-app update flow: [UpdateController] checks GitHub for a newer release
/// and, asked to, installs its APK on Android or runs its installer on
/// Windows.
///
/// {@category App}
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../data/update/apk_download.dart';
import '../../data/update/github_releases.dart';
import '../../data/update/release_version.dart';
import '../providers.dart';
import 'update_platform.dart';

/// Where the update check stands.
sealed class UpdateState {
  const UpdateState();

  /// The newer release on offer, if there is one.
  AppRelease? get release => null;
}

/// Not checked yet, or a platform that has nothing to update with.
class UpdateIdle extends UpdateState {
  const UpdateIdle();
}

/// Asking GitHub for the latest release.
class UpdateChecking extends UpdateState {
  const UpdateChecking();
}

/// The running version is the newest release.
class UpdateUpToDate extends UpdateState {
  const UpdateUpToDate(this.current);

  final ReleaseVersion current;
}

/// A newer release exists and nothing has been done about it yet.
class UpdateAvailable extends UpdateState {
  const UpdateAvailable(this.release);

  @override
  final AppRelease release;
}

/// Downloading the APK or the Windows installer for [release].
class UpdateDownloading extends UpdateState {
  const UpdateDownloading(this.release, [this.progress]);

  @override
  final AppRelease release;

  /// 0..1, or null while the size is unknown.
  final double? progress;
}

/// The APK is down and verified. Either the installer has it, or it is
/// waiting on the player letting Chalk install apps; asking again installs
/// the same file rather than downloading it twice.
class UpdateDownloaded extends UpdateState {
  const UpdateDownloaded(
    this.release,
    this.apkPath, {
    this.needsPermission = false,
  });

  @override
  final AppRelease release;
  final String apkPath;

  /// Whether the install is waiting on that permission - see
  /// [UpdateController.resumeInstall].
  final bool needsPermission;
}

/// Which step of an update went wrong.
enum UpdateFailure {
  /// GitHub could not be asked, or answered with nothing usable.
  check,

  /// The APK or installer did not download, or did not match its checksum.
  download,

  /// Nothing could take the update: no installer, no browser.
  install,
}

/// The check, download or install failed.
class UpdateFailed extends UpdateState {
  const UpdateFailed(this.failure, [this.release]);

  final UpdateFailure failure;

  /// The release that failed to download or install, so it can be retried.
  /// Null when the check itself failed.
  @override
  final AppRelease? release;
}

/// The two platforms that ship releases: Android installs the APK, Windows
/// runs the installer (or, for a release that has none, opens its page).
bool get platformCanUpdate =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.windows;

/// Checks GitHub for a newer release and, asked to, takes it.
class UpdateController extends Notifier<UpdateState> {
  @override
  UpdateState build() => const UpdateIdle();

  UpdatePlatform get _platform => ref.read(updatePlatformProvider);

  /// Asks GitHub for the latest release. Does nothing while a check or a
  /// download is already under way.
  Future<void> check() async {
    if (!platformCanUpdate) return;
    if (state is UpdateChecking || state is UpdateDownloading) return;
    state = const UpdateChecking();
    try {
      final current = ReleaseVersion.tryParse(await _platform.currentVersion());
      final latest = await ref.read(githubReleasesProvider).latest();
      if (current == null || !(latest.version > current)) {
        state = UpdateUpToDate(current ?? latest.version);
      } else {
        state = UpdateAvailable(latest);
      }
    } on Exception catch (error) {
      debugPrint('update check failed: $error');
      state = const UpdateFailed(UpdateFailure.check);
    }
  }

  /// Takes the release on offer: installs its APK on Android, runs its
  /// installer on Windows.
  Future<void> apply() async {
    final current = state;
    final release = current.release;
    if (release == null || current is UpdateDownloading) return;

    if (defaultTargetPlatform == TargetPlatform.windows) {
      await _applyOnWindows(release);
      return;
    }

    if (current is UpdateDownloaded) {
      await _install(release, current.apkPath);
      return;
    }

    final String apkPath;
    try {
      final name = release.apkNameFor(await _platform.supportedAbis());
      if (name == null) throw const UpdateCheckException('release has no APK');
      apkPath = await _download(release, name);
    } on Exception catch (error) {
      debugPrint('update download failed: $error');
      state = UpdateFailed(UpdateFailure.download, release);
      return;
    }
    await _install(release, apkPath);
  }

  /// Installs the waiting APK if Chalk has since been allowed to - for coming
  /// back from the settings page [InstallResult.needsPermission] opened.
  /// Without the permission it does nothing, rather than opening that page
  /// again in a loop every time the app resumes.
  Future<void> resumeInstall() async {
    final current = state;
    if (current is! UpdateDownloaded || !current.needsPermission) return;
    if (!await _platform.canInstall()) return;
    await _install(current.release, current.apkPath);
  }

  /// Downloads and runs the installer, which quits Chalk and starts the new
  /// version. A release from before there was an installer is only on its
  /// page, so that is opened instead.
  Future<void> _applyOnWindows(AppRelease release) async {
    final name = release.windowsInstallerName;
    if (name == null) {
      final opened = await _platform.openPage(release.pageUrl);
      if (!opened) state = UpdateFailed(UpdateFailure.install, release);
      return;
    }

    final String path;
    try {
      path = await _download(release, name);
    } on Exception catch (error) {
      debugPrint('update download failed: $error');
      state = UpdateFailed(UpdateFailure.download, release);
      return;
    }
    try {
      await _platform.runInstaller(path);
    } on ProcessException catch (error) {
      debugPrint('update install failed: $error');
      state = UpdateFailed(UpdateFailure.install, release);
    }
  }

  /// Downloads the release's file [name] and checks it against the release's
  /// `SHA256SUMS.txt`, returning where it landed.
  Future<String> _download(AppRelease release, String name) async {
    state = UpdateDownloading(release);
    final releases = ref.read(githubReleasesProvider);
    final url = release.assets[name];
    if (url == null) throw UpdateCheckException('release has no $name');
    final expected = (await releases.checksums(release))[name];
    if (expected == null) {
      throw UpdateCheckException('SHA256SUMS.txt does not list $name');
    }

    // One update at a time is ever worth keeping: clear out whatever an
    // earlier one left behind, finished or not.
    final directory = await _platform.downloadDirectory();
    if (await directory.exists()) await directory.delete(recursive: true);
    await directory.create(recursive: true);

    final file = await downloadVerified(
      ref.read(updateHttpClientProvider),
      url,
      File('${directory.path}/$name'),
      expected,
      onProgress: (progress) {
        if (ref.mounted) state = UpdateDownloading(release, progress);
      },
    );
    return file.path;
  }

  Future<void> _install(AppRelease release, String apkPath) async {
    try {
      final result = await _platform.installApk(apkPath);
      state = UpdateDownloaded(
        release,
        apkPath,
        needsPermission: result == InstallResult.needsPermission,
      );
    } on PlatformException catch (error) {
      debugPrint('update install failed: $error');
      state = UpdateFailed(UpdateFailure.install, release);
    }
  }
}

/// The device side of updating; overridden in tests.
final updatePlatformProvider = Provider<UpdatePlatform>(
  (ref) => DeviceUpdatePlatform(),
);

/// One client for the check and the download, closed with the app.
final updateHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// GitHub's release API for this app's repository.
final githubReleasesProvider = Provider<GitHubReleases>(
  (ref) => GitHubReleases(ref.watch(updateHttpClientProvider)),
);

/// Where the update check stands - see [UpdateController].
final updateProvider = NotifierProvider<UpdateController, UpdateState>(
  UpdateController.new,
);

/// The running version, for the settings screen to show. Null where the
/// platform cannot say - the test binding, chiefly.
final appVersionProvider = FutureProvider<String?>((ref) async {
  try {
    return await ref.watch(updatePlatformProvider).currentVersion();
  } on Exception {
    return null;
  }
});

/// Whether the main menu's update card was closed. For this run only: the
/// next launch checks again and offers it again, which is the point of
/// checking at launch.
final updateCardDismissedProvider = NotifierProvider<UpdateCardDismissed, bool>(
  UpdateCardDismissed.new,
);

/// Backs [updateCardDismissedProvider].
class UpdateCardDismissed extends Notifier<bool> {
  @override
  bool build() => false;

  void dismiss() => state = true;
}

/// Checks once at launch, if [updateAutoCheckProvider] is on, and picks a
/// waiting install back up when the player returns from granting Chalk
/// permission to install it. Listen-only, watched by `main.dart` - see
/// [soundControllerProvider].
final updateLifecycleProvider = Provider<void>((ref) {
  var disposed = false;
  ref.onDispose(() => disposed = true);

  Future<void> start() async {
    if (!ref.read(updatePlatformProvider).checksAtLaunch) return;
    final autoCheck = ref.read(updateAutoCheckProvider.notifier);
    await autoCheck.ready;
    if (disposed || !ref.read(updateAutoCheckProvider)) return;
    await ref.read(updateProvider.notifier).check();
  }

  unawaited(start());

  final lifecycle = AppLifecycleListener(
    onResume: () =>
        unawaited(ref.read(updateProvider.notifier).resumeInstall()),
  );
  ref.onDispose(lifecycle.dispose);
});
