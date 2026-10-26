import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fluttergran/app/update/update_platform.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A device with no platform channels behind it.
class FakeUpdatePlatform implements UpdatePlatform {
  FakeUpdatePlatform(this.directory);

  final Directory directory;
  String version = '1.0.0';
  bool allowed = true;
  bool browserOpens = true;
  final installed = <String>[];
  final opened = <Uri>[];

  @override
  bool checksAtLaunch = true;

  @override
  Future<String> currentVersion() async => version;

  @override
  Future<List<String>> supportedAbis() async => ['arm64-v8a', 'armeabi-v7a'];

  @override
  Future<Directory> downloadDirectory() async =>
      Directory('${directory.path}/updates');

  @override
  Future<bool> canInstall() async => allowed;

  @override
  Future<InstallResult> installApk(String path) async {
    if (!allowed) return InstallResult.needsPermission;
    installed.add(path);
    return InstallResult.started;
  }

  @override
  Future<bool> openPage(Uri url) async {
    opened.add(url);
    return browserOpens;
  }
}

final apkBytes = utf8.encode('the new apk');
const apkName = 'chalk-1.1.0-android-arm64-v8a.apk';
const base = 'https://github.com/Filan-glitch/FlutterGran/releases';

/// GitHub as the v1.1.0 release left it, with [checksum] for the APK.
MockClient github({String? checksum, int status = 200}) {
  final sum = checksum ?? sha256.convert(apkBytes).toString();
  return MockClient((request) async {
    final path = request.url.path;
    if (path.endsWith('/releases/latest')) {
      return http.Response(
        jsonEncode({
          'tag_name': 'v1.1.0',
          'html_url': '$base/tag/v1.1.0',
          'body': '',
          'assets': [
            for (final name in [apkName, 'SHA256SUMS.txt'])
              {
                'name': name,
                'browser_download_url': '$base/download/v1.1.0/$name',
              },
          ],
        }),
        status,
      );
    }
    if (path.endsWith('SHA256SUMS.txt')) {
      return http.Response('$sum  $apkName\n', 200);
    }
    if (path.endsWith(apkName)) return http.Response.bytes(apkBytes, 200);
    return http.Response('', 404);
  });
}
