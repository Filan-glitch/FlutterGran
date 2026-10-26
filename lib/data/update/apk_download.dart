import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// The download finished but is not the file the release lists.
///
/// Android would refuse an APK signed with any key but the installed one, so
/// a tampered download could never replace the app. Checking first still
/// means a truncated or swapped file never reaches the installer at all, and
/// the player gets "download failed" rather than the system's "App not
/// installed".
class ChecksumMismatch implements Exception {
  const ChecksumMismatch(this.expected, this.actual);

  final String expected;
  final String actual;

  @override
  String toString() => 'ChecksumMismatch: expected $expected, got $actual';
}

/// Downloads [url] to [target], hashing as it writes, and keeps the file only
/// if its SHA-256 is [expectedSha256].
///
/// Written to `<target>.partial` and renamed at the end, so [target] only
/// ever exists complete and verified. [onProgress] gets 0..1 while the server
/// says how long the file is, and is not called when it does not.
Future<File> downloadVerified(
  http.Client client,
  Uri url,
  File target,
  String expectedSha256, {
  void Function(double progress)? onProgress,
}) async {
  final partial = File('${target.path}.partial');
  final response = await client.send(
    http.Request('GET', url)..headers['User-Agent'] = 'Chalk',
  );
  if (response.statusCode != 200) {
    await response.stream.drain<void>();
    throw http.ClientException('download answered ${response.statusCode}', url);
  }

  final digest = _DigestSink();
  final hasher = sha256.startChunkedConversion(digest);
  final sink = partial.openWrite();
  final total = response.contentLength;
  var received = 0;
  try {
    await for (final chunk in response.stream) {
      sink.add(chunk);
      hasher.add(chunk);
      received += chunk.length;
      if (total != null && total > 0) onProgress?.call(received / total);
    }
  } catch (_) {
    await sink.close();
    await _deleteIfThere(partial);
    rethrow;
  }
  await sink.close();
  hasher.close();

  final actual = digest.value.toString();
  if (actual != expectedSha256.toLowerCase()) {
    await _deleteIfThere(partial);
    throw ChecksumMismatch(expectedSha256, actual);
  }
  return partial.rename(target.path);
}

Future<void> _deleteIfThere(File file) async {
  if (await file.exists()) await file.delete();
}

/// Catches the one [Digest] a chunked hash emits when it is closed.
class _DigestSink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}
