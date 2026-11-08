# Contributing to Chalk

The developer handbook: how to set up, the rules that are not negotiable, where
things live, and step-by-step recipes for the changes people actually make. Read
this first; the documents in `docs/` go deeper on one subject each.

## Start here

### Setup

Needs Flutter 3.47 (CI pins the exact version in `.github/workflows/build.yml`
and `ci.yml`) and the Dart SDK in `pubspec.yaml` (`^3.13.7`).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift codegen
```

The generated drift code (`*.g.dart`) and localizations
(`lib/l10n/app_localizations*.dart`) are committed. CI fails if either is stale.

### Run

```bash
flutter run                    # Android device or emulator
flutter run -d windows         # Windows; only builds on Windows
```

No board is needed: with nothing connected the keypad scores every dart. To
use a GranBoard 132, tap the board icon (`BoardConnectionButton`) in the app
bar. Windows needs Visual Studio 2022 with the C++ desktop workload; details in
[DEVELOPMENT.md](docs/DEVELOPMENT.md#running-on-windows).

### Check before pushing

```bash
tool/check.sh            # everything CI's check job runs, in the same order
tool/check.sh --quick    # skips codegen, l10n and dartdoc
```

`tool/check.sh` runs: drift codegen and `flutter gen-l10n` (failing if either
changed a tracked file), `dart format --set-exit-if-changed lib test`,
`flutter analyze`, `dart test test/domain test/data`, `flutter test`, and a
dartdoc build. The individual commands:

```bash
flutter analyze                          # must be clean
flutter test                             # everything
dart test test/domain test/data          # engine, checkout, protocol; no Flutter
dart format lib test                     # the whole tree is formatted
flutter gen-l10n                         # after editing an .arb file
dart run build_runner build --delete-conflicting-outputs   # after a table change
```

### API docs

```bash
dart pub global activate dartdoc 9.0.11
dart pub global run dartdoc              # writes doc/api/index.html (gitignored)
```

Pinned to 9.0.11 because the SDK's bundled `dart doc` (dartdoc 9.0.6) crashes
on drift's inherited `@docImport` comments. Libraries are grouped by
`{@category}` (Domain, Data, App, Game modes), and this handbook and the
`docs/` files are included as dartdoc topics.

### Where the docs live

| Document | What is in it |
| --- | --- |
| [README.md](README.md) | What the app does, screenshots, the short tour |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Layers, the folds, the provider graph, screens, audio, lights, layout |
| [docs/DATA_MODEL.md](docs/DATA_MODEL.md) | Every table, migrations v1 to v8, `GameRepository` |
| [docs/BOARD_PROTOCOL.md](docs/BOARD_PROTOCOL.md) | Frame format, decoding, hardware day, LED control |
| [docs/HARDWARE.md](docs/HARDWARE.md) | The GranBoard 132, its sensor matrix and the segment table |
| [docs/CONNECTIVITY.md](docs/CONNECTIVITY.md) | BLE scanning, reconnect backoff, permissions, `FakeBoardSource` |
| [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) | Devices, Windows, test layout, layout breakpoints, asset generators |
| [docs/RELEASING.md](docs/RELEASING.md) | release-please, signing, the in-app update contract |
| [docs/RULES_SCREENS.md](docs/RULES_SCREENS.md) | The rules section's screens and building blocks |
| [docs/FEATURE_IDEAS.md](docs/FEATURE_IDEAS.md) | Backlog of modes and features not yet built |
| [docs/history/](docs/history/README.md) | Old planning documents; not maintained |
| [CLAUDE.md](CLAUDE.md) | The same hard rules, condensed for coding agents |

## Golden rules

Each of these has bitten someone. The detail is linked; the rule is here.

**`lib/domain/` is pure Dart.** No `package:flutter`, `dart:ui` or
`package:drift`. `test/domain/domain_purity_test.dart` enforces it; if it fails,
move the code out of `domain/`, never relax the test.

**State is a fold over the darts thrown.** No running totals, cached derived
values or counters anywhere: a leg is replayed from its dart log by a pure
`fold*` function, and undo is folding a shorter list. A patch that adds an
incremental count is going the wrong way.
See [ARCHITECTURE.md](docs/ARCHITECTURE.md#everything-is-a-fold).

**Board events are a plain stream, never provider state.**
`boardEventsProvider` is a `Provider<Stream<BoardEvent>>` and controllers
`listen` to it. Riverpod 3 skips a state equal to the last one, and every miss
or button press is the same const object, so a `StreamProvider` swallowed every
second miss in a row.

**Providers are hand-written.** No `riverpod_generator`: it needs
`analyzer ^13` while `drift_dev` pins an older one, and the two cannot coexist.
No `riverpod_lint`/`custom_lint` either: `riverpod_lint` caps
`riverpod_annotation <4.0.0`, incompatible with Riverpod 3. Nothing catches
provider mistakes, so keep providers few and small.

**Only LED frames are written to the board, only through
`BoardSource.sendLed(LedCommand)`.** `LedCommand` allow-lists the ops confirmed
on the 132. Never add a raw-bytes write, and never send the 12-byte settings
frames (`…34 35`, `…36 37`, `…3A 3B`): they change how the board scores.
See [BOARD_PROTOCOL.md](docs/BOARD_PROTOCOL.md#led-control).

**Every `AudioPlayer` sets `positionUpdater = null`** unless it really reads
position. audioplayers starts a per-frame position-polling loop on every
`play()` that only completion stops, and the low-latency (SoundPool) player
never reports completion on Android; long x01 sessions took seconds to show a
dart. See `AudioPlayersSoundPlayer` in `lib/app/audio/sound_player.dart`.

**Ask `isHeroDevice(context)`, never `shortestSide >= heroLayout`.** Both live
in `lib/app/theme.dart`. A direct comparison sends a laptop window to the phone
layout, because desktops qualify by window size (`isHeroSize`,
`desktopHeroLayout`). See [DEVELOPMENT.md](docs/DEVELOPMENT.md#layout-breakpoints).

**The Windows runner floor (960x600) stays just above `desktopHeroLayout`
(900x580).** The floor is in `windows/runner/flutter_window.cpp`; change one,
check the other, or the smallest allowed window loses the hero layout.

**drift's `TableMigration` copies every column the current table class has.**
When a later schema version adds a column to a table that an earlier step
rebuilds with `TableMigration`, declare it on that earlier step with
`newColumns: [table.newColumn]`, or a multi-version upgrade crashes copying a
column that does not exist yet. See [DATA_MODEL.md](docs/DATA_MODEL.md#the-tablemigration-gotcha).

**A schema change bumps `schemaVersion` and ships a migration test.** The test
lays down the old shape with raw SQL and puts rows in it before upgrading.
See [Add a database column or table](#add-a-database-column-or-table).

**Never hand-edit `version:` in `pubspec.yaml`, `CHANGELOG.md` or
`.release-please-manifest.json`, and never tag by hand.** The release PR does
all three. See [RELEASING.md](docs/RELEASING.md).

**Release asset names are a contract with installed apps.** The in-app updater
looks for `chalk-<version>-android-<abi>.apk`, `SHA256SUMS.txt` and `vX.Y.Z`
tags. Read [RELEASING.md](docs/RELEASING.md#in-app-updates) before touching
`NAME` in `build.yml`.

**`flutter_blue_plus` is not open source.** Free for personal use only; any
for-profit use needs a purchased commercial licence. Shipping commercially means
swapping it for `flutter_blue_ultra` or `universal_ble` (both BSD-3);
`BoardSource` is the seam that keeps that swap small.

## Project map

```
lib/
├── domain/            pure Dart: rules, folds, checkout search, statistics
│   ├── x01/           GameConfig, X01InRule/X01OutRule, foldLeg, MatchConfig/foldMatch
│   ├── atc/           Around the Clock: config, variant, stop, leg state, reducer
│   ├── bulling/       Bulling: config, bullseye value, leg state, reducer
│   ├── higher_lower/  Higher/Lower: config, leg state, reducer
│   ├── training/      training drills and free practice
│   ├── checkout/      findCheckouts, CheckoutTable
│   ├── stats/         sealed ModeStats, one part file per mode, computePlayerStats
│   ├── game_mode.dart GameMode enum + gameModeRegistry
│   ├── segment.dart   Segment, Ring
│   └── board_event.dart  DartHit | BoardMiss | ButtonPress | UnknownFrame
├── data/
│   ├── board/         BoardSource, BleBoardSource, FakeBoardSource, FrameAssembler,
│   │                  SegmentCodec, the segment table, LedCommand
│   ├── db/            AppDatabase (drift tables, migrations), GameRepository
│   └── update/        GitHub releases, version comparison, verified APK download
├── app/
│   ├── providers.dart       every provider except lights and update
│   ├── *_controller.dart    one Notifier per mode, plus MatchController
│   ├── screens/             one file per screen
│   ├── widgets/             shared widgets; widgets/rules/ for the rules section
│   ├── audio/               soundsFor* mappings and the SoundPlayer
│   ├── lights/              ledCuesFor*, rings, LedScheduler, lights providers
│   ├── update/              UpdateController and the platform seam
│   ├── theme.dart           Palette, Type, breakpoints, isHeroDevice, buildTheme
│   ├── labels.dart          localized labels for domain enums
│   ├── l10n_extensions.dart context.l10n, nameFor
│   ├── rules_topic.dart     RulesTopic: a rules page per mode, plus training
│   └── board_lifecycle.dart auto-connect and app-lifetime board handling
├── l10n/              app_en.arb (template), app_de.arb, generated localizations
└── main.dart

test/
├── domain/            dart test: x01, checkout, match, stats at the top level;
│                      atc/, bulling/, higher_lower/, training/ per mode;
│                      domain_purity_test.dart
├── data/              dart test: frame assembly, codec, segment table, LED
│                      command; update/ for the updater's data layer
├── app/               flutter test: controllers, persistence, migrations,
│                      screens, audio and LED mappings, layout
├── support/           shared test helpers
├── widget_test.dart   x01 end to end
└── atc_widget_test.dart  Around the Clock end to end

tool/
├── check.sh           runs what CI runs
├── ci/                check_version.sh, release_notes.sh (used by CI)
├── make_icon.py       launcher icon and Windows .ico from the theme palette
├── make_speech.py     the 186 spoken lines, via Piper
└── make_cues.py       the four cues, from sine partials

assets/
├── sounds/cues/       dart, bust, checkout, one_eighty (.wav)
├── sounds/speech/     0.ogg to 180.ogg plus the named lines
└── fonts/             Ubuntu Sans and Ubuntu Sans Mono
```

### Naming conventions

| Thing | Pattern | Examples |
| --- | --- | --- |
| Domain files per mode | `lib/domain/<mode>/<mode>_config.dart`, `_leg_state.dart`, `_reducer.dart` | `bulling_config.dart`, `higher_lower_reducer.dart` |
| The fold | `fold<Mode>(config, darts)`; x01 is `foldLeg` | `foldAroundTheClock`, `foldBulling`, `foldHigherLower` |
| Stats | `lib/domain/stats/<mode>_stats.dart`, class `<Mode>Stats`, `compute<Mode>Stats` | `AtcStats`, `computeBullingStats` |
| Controllers | `lib/app/<mode>_controller.dart`, `<Mode>Controller` over a `<Mode>Session` | `AtcController`/`AtcSession`; x01 is `GameController`/`GameSession` |
| Providers | `<name>Provider`, a top-level `final` | `bullingGameProvider`, `allAtcLegsProvider` |
| Screens | `<mode>_setup_screen.dart`, `<mode>_game_screen.dart` | `atc_setup_screen.dart`; x01's game screen is `game_screen.dart` |
| Sound mapping | `soundsFor<Mode>(previous, next)` in `lib/app/audio/<mode>_sound.dart`; x01 is `soundsFor` | `soundsForHigherLower` |
| LED mapping | `ledCuesFor<Mode>(previous, next)` and `<mode>Ring(session)` in `led_reactions.dart` | `ledCuesForAtc`, `bullingRing` |
| Lights provider | `<mode>LightsProvider` in `lights_providers.dart` | `trainingLightsProvider` |
| Repository | `start<Mode>Game`, `load<Mode>Config`, `watchAll<Mode>Legs` | `startBullingGame` |
| Tests | mirror the file under test, `_test.dart` | `test/domain/atc/atc_reducer_test.dart` |

Around the Clock is abbreviated `atc` in file and symbol names.

## Recipes

### Add a game mode

Follow how Higher/Lower (no config table) or Bulling (with one) was added.
Adding the `GameMode` value first makes the compiler point at most of the
exhaustive switches below.

1. **Mode.** Add a value to `GameMode` and an entry to `gameModeRegistry` in
   `lib/domain/game_mode.dart`.
2. **Domain.** `lib/domain/<mode>/`: `<mode>_config.dart` (asserting its
   invariants), `<mode>_leg_state.dart`, `<mode>_reducer.dart` with a pure
   `fold<Mode>(config, darts)`. No Flutter, no drift.
3. **Stats.** `lib/domain/stats/<mode>_stats.dart` as a `part of
   'mode_stats.dart'` subtype of `ModeStats` (add the `part` line), a
   `compute<Mode>Stats` in `player_stats.dart`, and a parameter and map entry
   in `computePlayerStats`.
4. **Database**, only if a leg has settings beyond its seats: a sibling table
   `<Mode>Games` keyed by `gameId` in `lib/data/db/database.dart`, added to
   `@DriftDatabase(tables:)`, with a schema bump, migration step and migration
   test. See [Add a database column or table](#add-a-database-column-or-table).
5. **Repository.** In `GameRepository`: `start<Mode>Game` (writing
   `startScore`, `doubleOut`, `inRule`, `outRule` explicitly null, since their
   column defaults would otherwise fill them), `load<Mode>Config` and
   `watchAll<Mode>Legs` filtered on `gameMode`.
6. **Controller.** `lib/app/<mode>_controller.dart`: a `<Mode>Session` and a
   `<Mode>Controller extends Notifier`. It listens to `boardEventsProvider`'s
   stream, drops `DartHit`/`BoardMiss` while `keypadOverrideProvider` is on, and
   persists through `appendDart`, `truncateLog`, `finishGame` and `reopenGame`.
7. **Providers** in `lib/app/providers.dart`: `<mode>GameProvider` (and a
   `<mode>ConfigProvider` if setup has choices), `all<Mode>LegsProvider`, fed
   into `playerStatsProvider` and watched by `segmentCountsProvider`.
8. **Setup screen.** `lib/app/screens/<mode>_setup_screen.dart`, using
   `PlayerPicker` and `setup_controls.dart`; it calls `start<Mode>Game` and sets
   `currentGameIdProvider`. Map the mode to it in `_setupScreenFor`
   (`select_game_mode_screen.dart`).
9. **Game screen.** `lib/app/screens/<mode>_game_screen.dart`, laid out by
   `GameLayout` with `GameAppBar` and `LeaveGuard`. Fill its slots (`scoreboard`,
   `aim`, `ledger`, `turnResult`, `outcome`, `gameOver`, `keypad`); a mode that
   needs a new kind of card adds a widget for a slot, as `BoundsCard` did. Add
   its column to the slot table in [ARCHITECTURE.md](docs/ARCHITECTURE.md#layout).
10. **Sound.** `soundsFor<Mode>(previous, next)` in
    `lib/app/audio/<mode>_sound.dart`, with the one-dart guard, and a
    `<mode>SoundControllerProvider` the game screen watches.
11. **Lights.** `ledCuesFor<Mode>` and `<mode>Ring` in
    `lib/app/lights/led_reactions.dart`, and a `<mode>LightsProvider` in
    `lights_providers.dart` the game screen watches.
12. **Rules.** A `RulesTopic` value (`lib/app/rules_topic.dart`), its section in
    `widgets/rules/rules_body.dart`, and its glyph in `widgets/mode_glyph.dart`.
    See [RULES_SCREENS.md](docs/RULES_SCREENS.md).
13. **Strings.** Every label in both `.arb` files; see
    [Add a localized string](#add-a-localized-string).
14. **Resume.** A `Resumable<Mode>Leg` subclass of the sealed `ResumableLeg` and
    its case in `resumableLegProvider` (`providers.dart`), then its case and
    subtitle in `main_menu_screen.dart`.
15. **Statistics screen.** A section in `stats_screen.dart` for the new
    `<Mode>Stats`.
16. **Tests.** `test/domain/<mode>/` for config, reducer and stats;
    `test/app/<mode>_controller_test.dart` and `<mode>_persistence_test.dart`;
    and the mode's cases in `mode_layout_test`, `mode_sounds_test`,
    `led_reactions_test`, `resumable_leg_provider_test`, `main_menu_screen_test`,
    `select_game_mode_screen_test`, `setup_screens_test`, the two rules tests
    and `test/domain/game_mode_test.dart`.

### Add a provider

1. Write it by hand in `lib/app/providers.dart` (lights providers live in
   `lights/lights_providers.dart`, update providers in
   `update/update_controller.dart`), as a top-level `final <name>Provider`.
2. Pick the smallest kind: `Provider` for a dependency, `NotifierProvider`
   with a `Notifier` class for state that changes, `StreamProvider` for a
   database `watch*` stream. Never wrap board events in one (see the golden
   rules).
3. A remembered on/off switch is a `NotifierProvider<BoolSetting, bool>` with a
   `shared_preferences` key; settings do not go in the database.
4. A provider that only has to be alive (a listener that plays sound or drives
   lights) is a `Provider<void>` the screen `ref.watch`es; app-lifetime ones are
   watched from `main.dart`.
5. Give anything with a platform behind it (database, sound player, update
   platform) a seam tests can `overrideWithValue`.

### Add a localized string

1. Add the key to `lib/l10n/app_en.arb` (the template, with an `@key`
   description and placeholders) and the same key to `lib/l10n/app_de.arb`.
2. Run `flutter gen-l10n` and commit the regenerated
   `lib/l10n/app_localizations*.dart`; CI fails if they are stale.
3. Read it as `context.l10n.<key>` (`lib/app/l10n_extensions.dart`). A label for
   a domain enum goes in `lib/app/labels.dart` beside `x01InRuleLabel` and
   `atcVariantLabel`, so `lib/domain/` stays free of localization.
4. When two branches both touch the `.arb` files, see
   [Merging branches](#merging-branches).

### Add a sound

1. A cue: add a function to `tool/make_cues.py` and its entry in `main()`, run
   `python3 tool/make_cues.py`. A spoken line: add it to `PHRASES` in
   `tool/make_speech.py`, run it (needs Piper and ffmpeg; see
   [DEVELOPMENT.md](docs/DEVELOPMENT.md#generated-assets)).
2. Commit the generated file under `assets/sounds/cues/` or
   `assets/sounds/speech/` (both folders are already listed in `pubspec.yaml`).
3. Add its path to `SoundAssets` in `lib/app/audio/sound_controller.dart`, and
   add a new cue to `SoundAssets.cues` so it is warmed at startup.
4. If a cue's length changed, update `SoundTiming` to match; the generator is
   the authority.
5. Return it from the relevant `soundsFor*` mapping and pin it in
   `test/app/sound_controller_test.dart` or `mode_sounds_test.dart`.

### Add an LED cue

1. Add a `final class` to the sealed `LedCue` in `lib/app/lights/led_cue.dart`
   (what happened).
2. Give it a `LedShow` in `showFor` in `led_theme.dart` (how it looks: colours,
   ops, speed, hold, priority). Use only ops `LedCommand` already allows; a new
   op must first be confirmed on a 132.
3. Emit it from the relevant `ledCuesFor*` function in `led_reactions.dart`,
   behind the one-dart guard and the Settings switch it belongs to.
4. Pin it in `test/app/led_reactions_test.dart`; scheduling behaviour is in
   `led_scheduler_test.dart`.

### Add a database column or table

1. Change the table class in `lib/data/db/database.dart`. An enum column is
   `textEnum<T>()` (stored by name, so the enum can be reordered).
2. Bump `schemaVersion` and add an `if (from < N)` step to `onUpgrade`:
   `m.addColumn`/`m.createTable`, plus any backfill as `customStatement`.
   Guard `addColumn` on tables an earlier step creates or rebuilds from the
   current class, or it adds a duplicate column (see the `from >= 3` and
   `from >= 6` guards in the v8 step).
3. If the column lands on a table an earlier step rebuilds with
   `TableMigration`, add it to that step's `newColumns`.
4. In `test/app/migration_test.dart`, freeze the previous schema: raw SQL for
   the tables as they were (`_gamesSinceV6`, ...) and an `AppDatabase` subclass
   pinned to the old version (`_SchemaV7`). Seed rows, open at the current
   version, and assert the data survived and still folds.
5. Run `dart run build_runner build --delete-conflicting-outputs` and commit
   `database.g.dart`.
6. Update [DATA_MODEL.md](docs/DATA_MODEL.md) and the schema version in
   `CLAUDE.md`.

### Add a test

| Testing | Folder | Runner |
| --- | --- | --- |
| a rule, fold, checkout or stat | `test/domain/` (a mode's own folder if it has one) | `dart test` |
| the board protocol, LED encoding, updater data layer | `test/data/` | `dart test` |
| controllers, persistence, screens, audio, lights | `test/app/` | `flutter test` |
| the app end to end | `test/widget_test.dart`, `test/atc_widget_test.dart` | `flutter test` |

- `test/domain` and `test/data` must not import Flutter, so they run under plain
  `dart test`.
- Shared helpers live in `test/support/`. Use them rather than writing
  another copy:

  | File | Gives you |
  | --- | --- |
  | `darts.dart` | `s(20)`, `d(20)`, `t(20)`, `miss` |
  | `async.dart` | `settle()`, a zero-delay wait for un-awaited work |
  | `database.dart` | `memoryDatabase()`, an empty in-memory `AppDatabase` |
  | `sound.dart` | `MuteSoundPlayer`, `RecordingSoundPlayer` |
  | `lights.dart` | `lightsOff()`, an override that keeps the LED ring dark |
  | `devices.dart` | `phonePortrait`, `tablet`, `tabS6Lite`, `laptop` and the other sizes, `windows`, `setViewSize` |
  | `pump.dart` | `pumpApp` (a localized `MaterialApp`, optionally themed, type-scaled and on a container), `pumpFrames`, `launchApp`, `popRoute`, `closeApp` |
  | `board_clock.dart` | `BoardClock` |
  | `fake_update.dart` | `FakeUpdatePlatform`, a `github` mock client |

  `darts.dart` and `async.dart` are pure Dart, so `test/domain` and
  `test/data` may import them; the rest need `flutter test`.
- Anything that opens an `AppDatabase` stays in `test/app/`, even with no
  widget in it: `database.dart` imports `drift_flutter`, which plain
  `dart test` cannot load.
- Drive the board with `FakeBoardSource`
  (`lib/data/board/fake_board_source.dart`), overriding `boardSourceProvider`;
  it reproduces split, glued and duplicated frames and the greeting.
  `BoardClock` steps the dedupe clock past 50 ms so two identical misses are
  two darts.
- Windows behaviour runs under
  `variant: TargetPlatformVariant.only(TargetPlatform.windows)`.
- A layout test that matters on more than one device runs at phone, tablet and
  desktop sizes, in English and German.

## Code style

### Formatting and lints

- `dart format` decides formatting: 80 columns, the whole tree is formatted,
  CI checks it.
- `analysis_options.yaml` is `flutter_lints` plus strict casts, inference and
  raw types, and rules including `comment_references`,
  `prefer_const_constructors`, `prefer_const_declarations`,
  `use_super_parameters`, `unnecessary_lambdas`, `avoid_void_async`,
  `unawaited_futures`, `avoid_dynamic_calls`, `prefer_final_locals` and
  `directives_ordering`. `flutter analyze` must be clean.

### Comments and docs

- **`///` on declarations, `//` inside bodies.**
- **The first sentence is a one-line summary** of what the thing is or does.
  Then only what the name and type do not already say.
- **Document why, not what.** Decisions, constraints and the thing that broke
  last time, stated as a rule ("X must Y, otherwise Z"), not narrated code.
- **Document only non-obvious public API.** A self-explanatory field or getter
  needs nothing.
- **Link with `[Symbol]`.** `comment_references` checks every bracketed name
  resolves; use backticks for parameters and things not in scope.
- **No history in code.** No dates, "used to", "previously", branch names or
  past bugs told as a story. git and `docs/history/` hold the story; the
  comment keeps the fact and the reason.
- **One canonical explanation.** Explain a thing once, where it lives, and link
  to it from elsewhere rather than repeating it.
- **Short comments, only at genuinely complex code**: algorithms, magic
  numbers, byte layouts, tricky control flow.
- **Spaced hyphen (` - `), not an em-dash**, in comments. Strings shown to users
  are not comments.
- **Every library file starts with a library doc comment and a `{@category}`**
  (Domain, Data, App or Game modes), so dartdoc can group it.
- **No TODOs and no commented-out code.** Open an issue or add it to
  [FEATURE_IDEAS.md](docs/FEATURE_IDEAS.md).

## Workflow

### One worktree per worker

Several people or agent sessions often work on the repo at once. They must
never share a checkout: a `git checkout` in one moves HEAD under every other
session in the same directory, so commits land on the wrong branch, and one
session's `dart format` or codegen output turns up in another's diff. Every
feature gets its own branch **and its own worktree**, made before the first
edit:

```bash
git worktree add ../FlutterGran-<topic> -b feat/<topic> origin/main
```

Work, test and commit only inside it; leave the main checkout on `main`. Remove
the worktree (`git worktree remove`) once its PR is merged.

### Commits

[Conventional Commits](https://www.conventionalcommits.org/), because
release-please reads them on `main`:

| Prefix | Effect |
| --- | --- |
| `fix:` | patch release |
| `feat:` | minor release |
| `!` or a `BREAKING CHANGE:` footer | major release |
| `docs:`, `perf:`, `revert:`, `deps:` | listed in the changelog |
| `chore:`, `ci:`, `test:`, `refactor:`, `style:`, `build:` | no release, hidden from the changelog |

With squash merges the **PR title** is the commit that counts, so it needs the
prefix too. Details: [RELEASING.md](docs/RELEASING.md#what-decides-the-version).

### graphify

The knowledge graph in `graphify-out/` is kept current with `graphify update .`
after code changes (AST only, no API cost). Commit its diff as its own commit,
`chore: update graphify knowledge graph`, never squashed into the code change.

### Merging branches

Branches that touch the same files are merged one at a time. The `.arb` files
and `graphify-out/` almost always conflict. For the next branch in line: merge
`main` into it, take the union of the `.arb` keys, rerun `flutter gen-l10n` and
`graphify update .`, and let CI pass before merging.

### PR checklist

- [ ] `tool/check.sh` passes.
- [ ] PR title has a Conventional Commit prefix.
- [ ] New behaviour has tests; a schema change has a migration test.
- [ ] New strings are in both `app_en.arb` and `app_de.arb`, and the generated
      localizations are committed.
- [ ] A changed layout was checked at phone, tablet and desktop sizes.
- [ ] Docs that describe the change are updated, and nothing hardcodes test
      counts or other numbers that rot.
- [ ] `graphify update .` committed separately.
