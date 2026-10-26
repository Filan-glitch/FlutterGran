#!/usr/bin/env bash
# Fails unless pubspec.yaml's version name is exactly $1.
#
# release-please bumps pubspec.yaml in the same release PR that produces the
# tag, so the two can only disagree if someone edits one by hand. Building
# anyway would publish an APK and an .exe stamped with a different version
# from the release they hang off, which is worse than no release.
set -euo pipefail

expected="${1:?usage: check_version.sh <version>}"
pubspec="$(dirname "$0")/../../pubspec.yaml"

# version: 1.2.3+45  ->  1.2.3
actual="$(sed -n 's/^version:[[:space:]]*\([^+[:space:]]*\).*/\1/p' "$pubspec")"

if [ "$actual" != "$expected" ]; then
  echo "::error file=pubspec.yaml::pubspec.yaml says version $actual, the release is $expected"
  exit 1
fi
echo "pubspec.yaml version $actual matches the release"
