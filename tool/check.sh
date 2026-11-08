#!/usr/bin/env bash
# Runs what CI's `check` job runs, in the same order. Use before pushing:
#
#   tool/check.sh          # everything
#   tool/check.sh --quick  # skip codegen, l10n and dartdoc
#
# Codegen and l10n steps regenerate files and fail if that changed anything
# tracked, so commit the regenerated output when they do.
set -euo pipefail
cd "$(dirname "$0")/.."

# Pinned: the SDK's bundled `dart doc` (dartdoc 9.0.6) crashes on drift's
# inherited `@docImport` comments. Keep in sync with .github/workflows/ci.yml.
DARTDOC_VERSION=9.0.11

quick=false
[[ "${1:-}" == "--quick" ]] && quick=true

step() { printf '\n\033[1m== %s\033[0m\n' "$*"; }

if ! $quick; then
  step 'drift codegen is up to date'
  dart run build_runner build --delete-conflicting-outputs
  git diff --exit-code -- '*.g.dart'

  step 'l10n output is up to date'
  flutter gen-l10n
  git diff --exit-code -- lib/l10n
fi

step 'format'
dart format --output=none --set-exit-if-changed lib test

step 'analyze'
flutter analyze

step 'domain and data tests (plain dart test, no Flutter)'
dart test test/domain test/data

step 'all tests'
flutter test

if ! $quick; then
  # A full build, not --no-generate-docs: only a full build checks library
  # docs. Output goes to a temp dir so doc/api/ is left alone.
  step 'dartdoc builds without warnings'
  dart pub global activate dartdoc "$DARTDOC_VERSION" > /dev/null
  out="$(mktemp -d)"
  trap 'rm -rf "$out"' EXIT
  dart pub global run dartdoc --output "$out"
fi

step 'all checks passed'
