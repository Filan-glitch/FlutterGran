import 'package:fluttergran/data/update/release_version.dart';
import 'package:test/test.dart';

void main() {
  test('reads a plain version, a tag and a pubspec version alike', () {
    expect(ReleaseVersion.tryParse('1.2.3'), const ReleaseVersion(1, 2, 3));
    expect(ReleaseVersion.tryParse('v1.2.3'), const ReleaseVersion(1, 2, 3));
    expect(ReleaseVersion.tryParse('1.2.3+4'), const ReleaseVersion(1, 2, 3));
  });

  test('is null for anything that is not a version', () {
    for (final text in ['', 'latest', '1.2', 'v1.2.x', '1.2.3.4']) {
      expect(ReleaseVersion.tryParse(text), isNull, reason: text);
    }
  });

  test('compares numerically, field by field', () {
    final v = ReleaseVersion.tryParse;
    expect(v('1.10.0')! > v('1.9.9')!, isTrue);
    expect(v('2.0.0')! > v('1.99.99')!, isTrue);
    expect(v('1.1.1')! > v('1.1.0')!, isTrue);
    expect(v('1.1.0')! > v('1.1.0')!, isFalse);
    expect(v('1.0.9')! > v('1.1.0')!, isFalse);
  });

  test('ignores the build number', () {
    expect(
      ReleaseVersion.tryParse('1.1.0+7'),
      ReleaseVersion.tryParse('v1.1.0'),
    );
  });
}
