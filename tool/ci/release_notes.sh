#!/usr/bin/env bash
# Writes a release's final notes to stdout: the changelog release-please wrote
# (read from stdin), then what to download, how to check it, and what built it.
#
# Every input is an environment variable, so the workflow passes data, never
# splices it into this script:
#   VERSION          1.2.3
#   SIGNED           true when the APKs carry the release key
#   FLUTTER_VERSION  the Flutter that built them
#   REPO             owner/name
#   SHA              the commit the release is tagged at
#   RUN_URL          the workflow run that built it
set -euo pipefail

: "${VERSION:?}" "${SIGNED:?}" "${FLUTTER_VERSION:?}" "${REPO:?}" "${SHA:?}" "${RUN_URL:?}"
name="chalk-$VERSION"

cat  # the changelog, unchanged

if [ "$SIGNED" != true ]; then
  cat <<NOTE

> [!WARNING]
> These APKs are signed with a throwaway debug key, not the project's release
> key. They install on a clean device, but cannot update an earlier install of
> Chalk; uninstall that first, which deletes its match history.
NOTE
fi

cat <<NOTES

## Downloads

| Platform | File |
| --- | --- |
| Android, most phones and tablets (64-bit ARM) | \`$name-android-arm64-v8a.apk\` |
| Android, older 32-bit devices | \`$name-android-armeabi-v7a.apk\` |
| Android, x86_64 (emulators, some Chromebooks) | \`$name-android-x86_64.apk\` |
| Android, if unsure which of the above | \`$name-android.apk\` (universal, larger) |
| Windows 10 / 11, 64-bit | \`$name-windows-x64.zip\`: unzip anywhere and run \`fluttergran.exe\` |

The Android APKs are sideloaded: allow installs from your browser or file
manager when Android asks. Windows SmartScreen may warn about an unrecognised
app on first launch: **More info → Run anyway**.

## Verifying

\`\`\`sh
sha256sum --check --ignore-missing SHA256SUMS.txt
gh attestation verify $name-android.apk --repo $REPO
\`\`\`

Every file has a [build provenance attestation](https://github.com/$REPO/attestations)
tying it to the commit and workflow run below.

## Build

| | |
| --- | --- |
| Commit | [\`${SHA:0:7}\`](https://github.com/$REPO/commit/$SHA) |
| Flutter | $FLUTTER_VERSION |
| Android signing | $([ "$SIGNED" = true ] && echo 'release key' || echo 'debug key (see above)') |
| Workflow run | [$RUN_URL]($RUN_URL) |
NOTES
