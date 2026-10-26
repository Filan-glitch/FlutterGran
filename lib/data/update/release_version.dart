/// A release's `major.minor.patch`, the only part of a version two builds
/// are compared on.
///
/// The `+build` suffix pubspec.yaml carries is Android's versionCode, not
/// part of the release: release-please bumps it with every version, so two
/// builds of the same tag never differ in it and nothing here reads it.
class ReleaseVersion implements Comparable<ReleaseVersion> {
  const ReleaseVersion(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  static final _pattern = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)(?:[+-].*)?$');

  /// Reads `1.2.3`, a tag's `v1.2.3`, or pubspec's `1.2.3+4`. Null for
  /// anything else, which the update check treats as "nothing newer" rather
  /// than guessing.
  static ReleaseVersion? tryParse(String text) {
    final match = _pattern.firstMatch(text.trim());
    if (match == null) return null;
    return ReleaseVersion(
      int.parse(match[1]!),
      int.parse(match[2]!),
      int.parse(match[3]!),
    );
  }

  @override
  int compareTo(ReleaseVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  bool operator >(ReleaseVersion other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) =>
      other is ReleaseVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}
