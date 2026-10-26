# Releasing

Releases are cut by [release-please](https://github.com/googleapis/release-please)
from [Conventional Commits](https://www.conventionalcommits.org/), and built,
attached and published by `.github/workflows/release.yml`. Nobody tags,
bumps a version or writes a changelog by hand.

## The flow

1. **Commits land on `main`** (through PRs; `ci.yml` tests them and builds a
   debug APK and a debug Windows app on every PR).
2. **release-please keeps a release PR open**, titled `chore: release x.y.z`.
   On every push to `main` it recomputes the next version from the commit
   types since the last release, updates `CHANGELOG.md`, and bumps `version:`
   in `pubspec.yaml`. The build number after the `+` goes up by one each
   release, which is what keeps Android's `versionCode` rising.
3. **Merging the release PR is the release.** The run on that merge:
   1. tags `vX.Y.Z` and opens a **draft** GitHub release with the changelog;
   2. builds, from the tagged commit, in `build.yml`:
      - `chalk-X.Y.Z-android-arm64-v8a.apk`, `-armeabi-v7a.apk`, `-x86_64.apk`
        (one per ABI) and `chalk-X.Y.Z-android.apk` (universal);
      - `chalk-X.Y.Z-windows-x64.zip` (the whole app folder, with the Visual
        C++ runtime DLLs beside `fluttergran.exe`);
   3. writes `SHA256SUMS.txt`, adds a build provenance attestation for every
      file, and uploads them all;
   4. appends download, verification and build details to the notes
      (`tool/ci/release_notes.sh`) and publishes the release as latest.

   The release stays a draft until its files are attached, so a failed build
   never leaves a public release with nothing to download. Re-run the failed
   jobs from the Actions tab and it carries on from the same tag.

## What decides the version

| Commit | Example | Bumps |
| --- | --- | --- |
| `fix:` | `fix: say "1 dart", not "1 darts"` | patch: 1.1.0 → 1.1.1 |
| `feat:` | `feat: add Windows as a desktop platform` | minor: 1.1.0 → 1.2.0 |
| `!` or a `BREAKING CHANGE:` footer | `feat!: drop the v4 schema migration` | major: 1.1.0 → 2.0.0 |
| `chore:`, `ci:`, `test:`, `refactor:`, `build:`, `style:` | | nothing on their own, and hidden from the changelog |

`feat`, `fix`, `perf`, `revert`, `docs` and `deps` get changelog sections;
the rest are hidden (`release-please-config.json`). With squash merges, the
**PR title** is the commit that counts, so it needs the prefix.

To force a version, put `Release-As: 2.0.0` in a commit body.

## One-time setup

### Android signing key (strongly recommended)

Without it, release APKs are signed with the runner's throwaway debug key: a
different key every release, so no release can install over the previous one
without uninstalling it first, and uninstalling deletes the match history. The
workflow still publishes, with a warning in the notes.

Create a key once, and keep the `.jks` and its passwords somewhere safe. Lose
them and no future release can update an existing install:

```bash
keytool -genkeypair -v -keystore chalk-release.jks -alias chalk \
  -keyalg RSA -keysize 4096 -validity 10000
base64 -w0 chalk-release.jks > chalk-release.jks.b64
```

Add four repository secrets (Settings → Secrets and variables → Actions):

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | the contents of `chalk-release.jks.b64` |
| `ANDROID_KEYSTORE_PASSWORD` | the store password |
| `ANDROID_KEY_ALIAS` | `chalk` |
| `ANDROID_KEY_PASSWORD` | the key password |

Locally, a release build signs with the same key if `android/key.properties`
exists (it is gitignored):

```properties
storeFile=/absolute/path/to/chalk-release.jks
storePassword=…
keyAlias=chalk
keyPassword=…
```

### Workflow permissions

Settings → Actions → General → Workflow permissions: **Allow GitHub Actions
to create and approve pull requests**, or release-please cannot open its PR.

### CI on the release PR (optional)

A PR opened with the default `GITHUB_TOKEN` does not trigger other workflows,
so `ci.yml` does not run on the release PR. If branch protection requires its
checks, add a fine-grained personal access token as `RELEASE_PLEASE_TOKEN`
(this repository only; Contents, Pull requests and Issues: read and write).
`release.yml` uses it when it exists.

## Verifying a download

```bash
sha256sum --check --ignore-missing SHA256SUMS.txt
gh attestation verify chalk-X.Y.Z-android.apk --repo Filan-glitch/FlutterGran
```

## Changing the toolchain

`build.yml` and `ci.yml` pin `FLUTTER_VERSION` / `flutter-version`, so a
release can be rebuilt from its tag. Move both together, with `.metadata`,
when the project upgrades Flutter.

## Starting point

`.release-please-manifest.json` began at `1.0.0`, the version the project
had before releases were automated, and `bootstrap-sha` in
`release-please-config.json` limits the first changelog to commits after the
last pre-automation commit on `main`. Neither matters once the first release
exists: from then on release-please starts from the latest tag.
