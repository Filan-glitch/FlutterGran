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

class UpdateChecking extends UpdateState {
  const UpdateChecking();
}

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
  final bool needsPermission;
}

enum UpdateFailure {
  /// GitHub could not be asked, or answered with nothing usable.
  check,

  /// The APK did not download, or did not match its checksum.
  download,

  /// Nothing could take the update: no installer, no browser.
  install,
}

class UpdateFailed extends UpdateState {
  const UpdateFailed(this.failure, [this.release]);

  final UpdateFailure failure;

  /// The release that failed to download or install, so it can be retried.
  /// Null when the check itself failed.
  @override
  final AppRelease? release;
}

/// The two platforms that ship releases: Android installs the APK itself,
/// Windows has no installer and is sent to the release page.
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

  /// Takes the release on offer: installs it on Android, opens its page on
  /// Windows.
  Future<void> apply() async {
    final current = state;
    final release = current.release;
    if (release == null || current is UpdateDownloading) return;

    if (defaultTargetPlatform == TargetPlatform.windows) {
      final opened = await _platform.openPage(release.pageUrl);
      if (!opened) state = UpdateFailed(UpdateFailure.install, release);
      return;
    }

    if (current is UpdateDownloaded) {
      await _install(release, current.apkPath);
      return;
    }

    final String apkPath;
    try {
      apkPath = await _download(release);
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

  Future<String> _download(AppRelease release) async {
    state = UpdateDownloading(release);
    final releases = ref.read(githubReleasesProvider);
    final name = release.apkNameFor(await _platform.supportedAbis());
    final url = name == null ? null : release.assets[name];
    if (name == null || url == null) {
      throw const UpdateCheckException('release has no APK');
    }
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

final updatePlatformProvider = Provider<UpdatePlatform>(
  (ref) => DeviceUpdatePlatform(),
);

/// One client for the check and the download, closed with the app.
final updateHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final githubReleasesProvider = Provider<GitHubReleases>(
  (ref) => GitHubReleases(ref.watch(updateHttpClientProvider)),
);

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

class UpdateCardDismissed extends Notifier<bool> {
  @override
  bool build() => false;

  void dismiss() => state = true;
}

/// Checks once at launch, if [updateAutoCheckProvider] is on, and picks a
/// waiting install back up when the player returns from granting Chalk
/// permission to install it. The app root keeps this alive by watching it,
/// the same way it keeps `boardLifecycleProvider`.
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
