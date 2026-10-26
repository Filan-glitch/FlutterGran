import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// What handing an APK to Android came to.
enum InstallResult {
  /// The system installer is showing it.
  started,

  /// The player has not let Chalk install apps yet. Android's settings page
  /// for that is open instead; the install has to be asked for again.
  needsPermission,
}

/// Everything the update check needs from the device, behind one seam so the
/// tests can run it without a platform.
abstract interface class UpdatePlatform {
  /// Whether to check by itself at launch. Off in debug builds: they carry the
  /// debug key, which no release can install over, and a developer running
  /// one does not want GitHub asked on every hot restart.
  bool get checksAtLaunch;

  /// The running version, e.g. `1.1.0`.
  Future<String> currentVersion();

  /// The device's ABIs, most preferred first. Android only.
  Future<List<String>> supportedAbis();

  /// Where downloaded APKs go. Must sit under `cache/updates/`, the one
  /// directory `res/xml/update_paths.xml` lets the installer read.
  Future<Directory> downloadDirectory();

  /// Whether Chalk may install apps right now. Android only.
  Future<bool> canInstall();

  /// Hands the APK at [path] to the system installer. Android only.
  Future<InstallResult> installApk(String path);

  /// Opens [url] in the browser. False when nothing could.
  Future<bool> openPage(Uri url);
}

/// The real device: package_info_plus, url_launcher, and the `update`
/// channel `MainActivity.kt` answers on Android.
class DeviceUpdatePlatform implements UpdatePlatform {
  static const _channel = MethodChannel('de.bot.filan.fluttergran/update');

  @override
  bool get checksAtLaunch => !kDebugMode;

  @override
  Future<String> currentVersion() async =>
      (await PackageInfo.fromPlatform()).version;

  @override
  Future<List<String>> supportedAbis() async =>
      (await _channel.invokeListMethod<String>('supportedAbis')) ?? const [];

  @override
  Future<Directory> downloadDirectory() async {
    final cache = await getApplicationCacheDirectory();
    return Directory('${cache.path}/updates');
  }

  @override
  Future<bool> canInstall() async =>
      (await _channel.invokeMethod<bool>('canInstall')) ?? false;

  @override
  Future<InstallResult> installApk(String path) async {
    final result = await _channel.invokeMethod<String>('installApk', {
      'path': path,
    });
    return result == 'needsPermission'
        ? InstallResult.needsPermission
        : InstallResult.started;
  }

  @override
  Future<bool> openPage(Uri url) =>
      launchUrl(url, mode: LaunchMode.externalApplication);
}
