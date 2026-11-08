# fluttergran

Flutter companion app for a **GranBoard 132** Bluetooth electronic dartboard,
for **Android and Windows**.
x01 (301/501/701, single/double/master in and out) for up to 4 players, best of 1/3/5/7
legs, live checkout suggestions, spoken commentary and sound cues, reactions on
the board's LED ring, and per-player statistics across every dart ever thrown.
Also Around the Clock, Bulling, Higher/Lower (elimination: beat the higher or
lower value each turn) and solo training: free practice, checkout practice,
Checkout Challenge, 121 Ladder, Bob's 27 and the Weak-spot Trainer (never
saved; see `docs/ARCHITECTURE.md`, "Training drills").

MVP finished 2026-09-07 — real hardware connects and scores correctly, and the
five post-MVP features (multi-leg matches, sound, app icon, end screen,
responsive/tablet layout) have all shipped. Now polishing. Architecture and
protocol reference: `docs/`.

**The full developer handbook is [CONTRIBUTING.md](CONTRIBUTING.md)**: setup,
golden rules, project map, recipes (add a mode, provider, string, sound, LED
cue, DB column, test), code and comment style, workflow. This file is the
condensed version of its hard rules.

## Commands

```
tool/check.sh                         # everything CI runs; --quick skips codegen/l10n/dartdoc
flutter analyze
flutter test                          # everything
dart test test/domain test/data       # engine, checkout and protocol, no Flutter
dart format lib test                  # the tree is fully formatted; CI checks it
flutter gen-l10n                      # after editing lib/l10n/*.arb; commit the output
dart run build_runner build --delete-conflicting-outputs   # drift codegen
```

`test/domain` and `test/data` run under plain `dart test` because neither layer
imports Flutter. `test/app` needs `flutter test`. Shared test helpers (in-memory
database, sound and lights fakes, pump helpers, `BoardClock`) live in
`test/support/`; use them rather than writing new copies.

## Parallel work: one worktree per worker

Several agent sessions often work on this repo at once. They must never share
a checkout: a `git checkout` in one session moves HEAD under every other
session in the same directory, so commits land on the wrong branch (once,
a whole feature landed on local `main`) and one session's `dart format` or
codegen output turns up in another's diff. So every feature gets its own
branch **and its own worktree**, made before the first edit:

```
git worktree add ../FlutterGran-<topic> -b feat/<topic> origin/main
```

or a subagent started with `isolation: "worktree"`. Work, test and commit
only inside it; leave the main checkout on `main` and never switch it. Remove
the worktree (`git worktree remove`) once its PR is merged. Branches that
touch the same files - the `.arb` files and `graphify-out/` almost always
conflict - are merged one at a time: merge `main` into the next branch,
union the `.arb` keys, rerun `flutter gen-l10n` and `graphify update .`,
and let CI pass before merging it.

## Windows

Added 2026-10-26 (Flutter 3.47). Only builds on Windows; CI's `build / windows`
job is the compile check from Linux. The desktop layout is the tablet's hero
treatment re-keyed for a wide, short window: `isDesktop`, `desktopHeroLayout`,
`isHeroSize` and the desktop tiers of `typeScaleFor` in `lib/app/theme.dart`.
Call sites ask `isHeroDevice(context)` (also in `theme.dart`), never
`shortestSide >= heroLayout` directly, or a laptop window falls back to the
phone layout. The runner (`windows/runner/flutter_window.cpp`) opens
maximised and floors the client area at 960x600, kept just above
`desktopHeroLayout` (900x580) — change one, check the other. Tests run Windows behaviour with
`variant: TargetPlatformVariant.only(TargetPlatform.windows)`. The database
sits in `%APPDATA%\<CompanyName>\<ProductName>` from `Runner.rc`, so renaming
either string orphans it. Ogg audio needs the Web Media Extensions codec
(absent on Windows N editions). Details: `docs/DEVELOPMENT.md`, "Running on
Windows".

## Releases

Automated: `docs/RELEASING.md`. release-please reads **Conventional Commit**
prefixes on `main` (`feat:` minor, `fix:` patch, `!` major; `chore:`/`ci:`/
`test:` change nothing), so commit messages and squash-merge PR titles must use
them. Never hand-edit `version:` in `pubspec.yaml`, `CHANGELOG.md` or
`.release-please-manifest.json`, and never tag by hand: the release PR does all
three, and `tool/ci/check_version.sh` fails a release whose pubspec disagrees
with its tag. `build.yml` is the one build definition, called by `ci.yml`
(debug) and `release.yml` (release); the Flutter version is pinned in both
`build.yml` and `ci.yml`. Pin every action to a full commit SHA with a
`# vX.Y.Z` comment, never a tag; the signing key lives only in the
`sign-android` job, which must stay free of third-party actions.

## Self-update

At launch the app asks GitHub's `releases/latest` for a newer version; Android
downloads the per-ABI APK, verifies it against `SHA256SUMS.txt` and opens the
system installer (`update` MethodChannel in `MainActivity.kt`, FileProvider on
`cache/updates/`), Windows opens the release page. Asset names, the checksum
file and `vX.Y.Z` tags are a contract with installed apps: see
`docs/RELEASING.md`, "In-app updates", before touching `NAME` in `build.yml`.

## Layering rule

`lib/domain/` is **pure Dart and must not import `package:flutter`**. It holds the
x01 fold and the checkout search — the parts worth testing hardest. A test asserts
this mechanically; if it fails, the fix is to move the Flutter-dependent code out of
`domain/`, not to relax the test.

Everything else: `lib/data/` (board protocol, drift database), `lib/app/` (Riverpod
providers, screens, widgets).

## X01 rules and schema

In-rule and out-rule are independent `X01InRule`/`X01OutRule` enums (straight/double/
master) on `GameConfig`/`MatchConfig` — there is no `doubleOut` bool any more. A
same-named DB column survives only as a frozen, always-derived legacy mirror; nothing
else reads it. Current drift schema version: **8**.

**drift `TableMigration` gotcha:** it copies every column the *current* table class has,
assuming the on-disk table already has them all. When a later schema version adds a
column to that table, any earlier `TableMigration(table)` step must be updated to
declare the new column via `newColumns: [table.newColumn]` — otherwise a multi-version
upgrade (e.g. v2 straight to v8) crashes trying to copy a column that doesn't exist yet
at that point in the chain. `test/app/migration_test.dart` freezes historical
`games`/`matches` shapes with raw SQL for exactly this reason, once the current table
classes outgrow them.

## Board protocol, in one paragraph

The board sends ASCII frames terminated by `@`, e.g. `3.4@`. The payload is a
**physical sensor-matrix coordinate (column.row), not a score** — `3.4@` is triple 20.
Frames arrive split across notifications, glued together, duplicated within 50 ms, and
preceded on connect by a `GB<n>;<ddd>` greeting with no terminator. The parser must
buffer, strip the greeting, split on `@`, and dedupe before lookup. Unknown frames must
log the **raw body**, never the failed lookup result.

The segment table shipped is derived from the **GRANBOARD 3s** and was verified
against a real 132 (below). It is settled, not provisional.

## Hardware day (done)

Verified end to end against a real 132 on 2026-09-04: the 3s table matched with
zero corrections, `BTN@` and `OUT@` both fire, and the advertised name is
`GRANBOARD`. The calibration screen built for it is gone; the board UI is one
`BoardConnectionButton`. Details: `docs/BOARD_PROTOCOL.md`, "Hardware day".

## Dependency constraints (learned the hard way)

Canonical, with the reasons: `CONTRIBUTING.md`, "Golden rules".

- **`flutter_blue_plus` is not open source.** Free for personal use only; any for-profit
  use requires a purchased commercial license. If this app ever ships commercially,
  swap it for `flutter_blue_ultra` or `universal_ble` (both BSD-3).
- **No Riverpod codegen.** `riverpod_generator` requires `analyzer ^13` while `drift_dev`
  pins an older analyzer — they cannot coexist. Providers are written by hand.
  `riverpod_lint`/`custom_lint` are also unavailable: `riverpod_lint` caps
  `riverpod_annotation <4.0.0` and so is incompatible with Riverpod 3.
- **audioplayers position polling leaks.** Every `play()` starts another per-frame
  `getCurrentPosition` loop, and only completion stops them — which the low-latency
  (SoundPool) player never reports on Android. That made long x01 sessions take
  seconds to show a dart. `AudioPlayersSoundPlayer` sets `positionUpdater = null` on
  both players; any new `AudioPlayer` must do the same unless it really reads position.
- **Board events are a plain stream, never provider state.** Riverpod 3 skips a state
  equal to the last one, and every miss/press is the same const object — a
  `StreamProvider` swallowed every second miss in a row. Controllers subscribe to
  `boardEventsProvider`'s stream directly.
- Write only LED frames to the board, and only through `BoardSource.sendLed(LedCommand)`.
  `LedCommand` allow-lists the ops confirmed on the 132. Never add a raw-bytes
  write, and never send the 12-byte settings frames (`…34 35`, `…36 37`, `…3A 3B`):
  they change how the board scores. LED protocol: `docs/BOARD_PROTOCOL.md`, "LED control".

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:
- Before grepping or exploring for a symbol, file, or relationship, run `graphify query "<question>"` first when graphify-out/graph.json exists — cheaper and more scoped than raw search. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost). Commit the graphify-out diff as its own separate commit (e.g. `chore: update graphify knowledge graph`) — never squashed into the code change.
