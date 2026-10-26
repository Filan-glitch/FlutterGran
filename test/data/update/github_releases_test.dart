import 'dart:convert';

import 'package:fluttergran/data/update/github_releases.dart';
import 'package:fluttergran/data/update/release_version.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

/// The shape `releases/latest` returned for v1.1.0, trimmed to what is read.
String releaseJson({
  String tag = 'v1.1.0',
  List<String> files = const [
    'chalk-1.1.0-android-arm64-v8a.apk',
    'chalk-1.1.0-android-armeabi-v7a.apk',
    'chalk-1.1.0-android-x86_64.apk',
    'chalk-1.1.0-android.apk',
    'chalk-1.1.0-windows-x64.zip',
    'SHA256SUMS.txt',
  ],
}) => jsonEncode({
  'tag_name': tag,
  'html_url': 'https://github.com/Filan-glitch/FlutterGran/releases/tag/$tag',
  'draft': false,
  'prerelease': false,
  'body': '## Features\n\n* something',
  'assets': [
    for (final name in files)
      {
        'name': name,
        'browser_download_url':
            'https://github.com/Filan-glitch/FlutterGran/releases/download/$tag/$name',
      },
  ],
});

void main() {
  group('latest', () {
    test('asks the repository for its latest release', () async {
      late http.Request seen;
      final releases = GitHubReleases(
        MockClient((request) async {
          seen = request;
          return http.Response(releaseJson(), 200);
        }),
      );

      final release = await releases.latest();

      expect(
        seen.url.toString(),
        'https://api.github.com/repos/Filan-glitch/FlutterGran/releases/latest',
      );
      expect(release.version, const ReleaseVersion(1, 1, 0));
      expect(
        release.pageUrl.toString(),
        'https://github.com/Filan-glitch/FlutterGran/releases/tag/v1.1.0',
      );
      expect(release.notes, contains('Features'));
      expect(release.assets, hasLength(6));
    });

    for (final status in [403, 404, 500]) {
      test('throws on a $status', () async {
        final releases = GitHubReleases(
          MockClient((_) async => http.Response('{}', status)),
        );
        await expectLater(
          releases.latest(),
          throwsA(isA<UpdateCheckException>()),
        );
      });
    }

    test('throws when the network does', () async {
      final releases = GitHubReleases(
        MockClient((_) async => throw http.ClientException('offline')),
      );
      await expectLater(
        releases.latest(),
        throwsA(isA<UpdateCheckException>()),
      );
    });

    test('throws on a tag that is not a version', () {
      expect(
        () => parseRelease(releaseJson(tag: 'nightly')),
        throwsA(isA<UpdateCheckException>()),
      );
    });

    test('throws on a body that is not JSON', () {
      expect(
        () => parseRelease('<html>'),
        throwsA(isA<UpdateCheckException>()),
      );
    });
  });

  group('apkNameFor', () {
    final release = parseRelease(releaseJson());

    test('picks the first supported ABI the release was split for', () {
      expect(
        release.apkNameFor(['arm64-v8a', 'armeabi-v7a', 'armeabi']),
        'chalk-1.1.0-android-arm64-v8a.apk',
      );
      expect(
        release.apkNameFor(['riscv64', 'x86_64']),
        'chalk-1.1.0-android-x86_64.apk',
      );
    });

    test('falls back to the universal APK', () {
      expect(release.apkNameFor(['riscv64']), 'chalk-1.1.0-android.apk');
      expect(release.apkNameFor([]), 'chalk-1.1.0-android.apk');
    });

    test('is null for a release with no APK at all', () {
      final windowsOnly = parseRelease(
        releaseJson(files: ['chalk-1.1.0-windows-x64.zip']),
      );
      expect(windowsOnly.apkNameFor(['arm64-v8a']), isNull);
    });
  });

  group('checksums', () {
    test('parses sha256sum output, text and binary mode', () {
      final a = 'A' * 64;
      final b = 'b' * 64;
      expect(
        parseChecksums('$a  chalk-1.1.0-android.apk\n$b *SHA256SUMS.txt\n\n'),
        {'chalk-1.1.0-android.apk': 'a' * 64, 'SHA256SUMS.txt': b},
      );
    });

    test('are fetched from the release', () async {
      final sum = 'c' * 64;
      final releases = GitHubReleases(
        MockClient((request) async {
          if (request.url.path.endsWith('SHA256SUMS.txt')) {
            return http.Response('$sum  chalk-1.1.0-android.apk\n', 200);
          }
          return http.Response('', 404);
        }),
      );
      final sums = await releases.checksums(parseRelease(releaseJson()));
      expect(sums, {'chalk-1.1.0-android.apk': sum});
    });

    test('throw when the release has none', () async {
      final releases = GitHubReleases(
        MockClient((_) async => http.Response('', 200)),
      );
      await expectLater(
        releases.checksums(parseRelease(releaseJson(files: []))),
        throwsA(isA<UpdateCheckException>()),
      );
    });
  });
}
