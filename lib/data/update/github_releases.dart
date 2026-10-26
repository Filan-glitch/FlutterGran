import 'dart:convert';

import 'package:http/http.dart' as http;

import 'release_version.dart';

/// The public repository every release is published to.
const releaseRepository = 'Filan-glitch/FlutterGran';

/// The update check failed: no network, GitHub refused (its unauthenticated
/// limit is 60 requests an hour per address), or answered with something
/// that is not a release.
class UpdateCheckException implements Exception {
  const UpdateCheckException(this.message);

  final String message;

  @override
  String toString() => 'UpdateCheckException: $message';
}

/// One published release, as far as updating to it goes.
///
/// The file names are a contract with `.github/workflows/build.yml`, whose
/// `NAME` is `chalk-<version>`: rename the files there and every install in
/// the wild stops finding its update. See docs/RELEASING.md, "In-app updates".
class AppRelease {
  const AppRelease({
    required this.version,
    required this.pageUrl,
    required this.notes,
    required this.assets,
  });

  final ReleaseVersion version;

  /// The release's page on GitHub: changelog and every download.
  final Uri pageUrl;

  /// The release notes, as markdown.
  final String notes;

  /// Every attached file, by name.
  final Map<String, Uri> assets;

  String get _name => 'chalk-$version';

  /// The file name of the APK for a device supporting [abis], most preferred
  /// first - the order Android's `Build.SUPPORTED_ABIS` lists them in. The
  /// per-ABI APK is a third the size of the universal one, which is only the
  /// fallback for an ABI the release was not split for.
  String? apkNameFor(List<String> abis) {
    for (final abi in abis) {
      final split = '$_name-android-$abi.apk';
      if (assets.containsKey(split)) return split;
    }
    final universal = '$_name-android.apk';
    return assets.containsKey(universal) ? universal : null;
  }

  Uri? get checksumsUrl => assets['SHA256SUMS.txt'];
}

/// Reads the latest release from GitHub's REST API.
class GitHubReleases {
  GitHubReleases(this._client, {this.repository = releaseRepository});

  final http.Client _client;
  final String repository;

  /// The newest published release. GitHub's `releases/latest` already leaves
  /// out drafts and prereleases, which is exactly the set nobody should be
  /// offered: a release stays a draft until its files are attached.
  Future<AppRelease> latest() async {
    final http.Response response;
    try {
      response = await _client.get(
        Uri.https('api.github.com', '/repos/$repository/releases/latest'),
        headers: const {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'Chalk',
        },
      );
    } on Exception catch (error) {
      throw UpdateCheckException('request failed: $error');
    }
    if (response.statusCode != 200) {
      throw UpdateCheckException('GitHub answered ${response.statusCode}');
    }
    return parseRelease(response.body);
  }

  /// The release's `SHA256SUMS.txt`, by file name.
  Future<Map<String, String>> checksums(AppRelease release) async {
    final url = release.checksumsUrl;
    if (url == null) {
      throw const UpdateCheckException('release has no SHA256SUMS.txt');
    }
    final http.Response response;
    try {
      response = await _client.get(url, headers: const {'User-Agent': 'Chalk'});
    } on Exception catch (error) {
      throw UpdateCheckException('request failed: $error');
    }
    if (response.statusCode != 200) {
      throw UpdateCheckException(
        'SHA256SUMS.txt answered ${response.statusCode}',
      );
    }
    return parseChecksums(response.body);
  }
}

/// A release from the body of GitHub's release endpoint.
AppRelease parseRelease(String body) {
  final Object? json;
  try {
    json = jsonDecode(body);
  } on FormatException {
    throw const UpdateCheckException('release is not JSON');
  }
  if (json is! Map<String, Object?>) {
    throw const UpdateCheckException('release is not an object');
  }
  final tag = json['tag_name'];
  final page = json['html_url'];
  final version = tag is String ? ReleaseVersion.tryParse(tag) : null;
  final pageUrl = page is String ? Uri.tryParse(page) : null;
  if (version == null || pageUrl == null) {
    throw UpdateCheckException('release has an unreadable tag: $tag');
  }

  final assets = <String, Uri>{};
  final list = json['assets'];
  if (list is List<Object?>) {
    for (final asset in list) {
      if (asset is! Map<String, Object?>) continue;
      final name = asset['name'];
      final url = asset['browser_download_url'];
      if (name is String && url is String) {
        final uri = Uri.tryParse(url);
        if (uri != null) assets[name] = uri;
      }
    }
  }

  final notes = json['body'];
  return AppRelease(
    version: version,
    pageUrl: pageUrl,
    notes: notes is String ? notes : '',
    assets: assets,
  );
}

/// `sha256sum` output - `<hex>  <name>` per line, `*` before the name in
/// binary mode - as a map from file name to lowercase hex digest.
Map<String, String> parseChecksums(String body) {
  final sums = <String, String>{};
  final line = RegExp(r'^([0-9a-fA-F]{64})\s+\*?(.+)$');
  for (final text in const LineSplitter().convert(body)) {
    final match = line.firstMatch(text.trim());
    if (match != null) sums[match[2]!.trim()] = match[1]!.toLowerCase();
  }
  return sums;
}
