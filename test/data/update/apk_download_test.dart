import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fluttergran/data/update/apk_download.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late File target;
  final bytes = utf8.encode('not really an apk, but bytes all the same');
  final url = Uri.parse('https://example.com/chalk.apk');

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('apk_download_test');
    target = File('${directory.path}/chalk.apk');
  });

  tearDown(() => directory.delete(recursive: true));

  MockClient serving(List<int> body, {int status = 200}) => MockClient(
    (_) async => http.Response.bytes(
      body,
      status,
      headers: {'content-length': '${body.length}'},
    ),
  );

  test('keeps a file whose hash matches', () async {
    final progress = <double>[];
    final file = await downloadVerified(
      serving(bytes),
      url,
      target,
      sha256.convert(bytes).toString().toUpperCase(),
      onProgress: progress.add,
    );

    expect(file.path, target.path);
    expect(await target.readAsBytes(), bytes);
    expect(await File('${target.path}.partial').exists(), isFalse);
    expect(progress.last, 1.0);
  });

  test('deletes a file whose hash does not match', () async {
    await expectLater(
      downloadVerified(serving(bytes), url, target, '0' * 64),
      throwsA(isA<ChecksumMismatch>()),
    );
    expect(await target.exists(), isFalse);
    expect(await File('${target.path}.partial').exists(), isFalse);
  });

  test('throws on a failed response and writes nothing', () async {
    await expectLater(
      downloadVerified(serving(bytes, status: 404), url, target, '0' * 64),
      throwsA(isA<http.ClientException>()),
    );
    expect(await target.exists(), isFalse);
  });
}
