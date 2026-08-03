# Development

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift codegen
flutter run
```

Requires the Dart SDK matching `environment: sdk: ^3.12.2` in `pubspec.yaml`.
No board is needed — the app starts on the simulated source.

## Commands

```bash
flutter analyze                                            # must be clean
flutter test                                               # everything, 292 tests
dart test test/domain test/data                            # engine, checkout, protocol
dart run build_runner build --delete-conflicting-outputs   # after any table change
dart format lib test                                       # note the caveat below
```

`test/domain` and `test/data` run under plain `dart test` because neither layer
imports Flutter, which makes the engine fast to iterate on. `test/app` needs
`flutter test`.

> **`dart format` caveat.** The tree is not uniformly formatted, so
> `dart format lib test` will rewrite files you did not touch. Format only the
> files you changed, or check `git diff --stat` before committing.

## Running on a device

```bash
flutter devices
flutter run -d <device-id>            # debug
flutter run -d <device-id> --release  # release; first Gradle build takes minutes
```

To drive it without touching the phone:

```bash
adb exec-out screencap -p > shot.png
adb shell input tap <x> <y>
adb shell settings put system accelerometer_rotation 0
adb shell settings put system user_rotation 1   # 1 = landscape, 0 = portrait
```

Remember to put `accelerometer_rotation` back to `1` afterwards.

## Test layout

| Directory | Runner | Covers |
|---|---|---|
| `test/domain/` | `dart test` | x01 fold, checkout search, match fold, statistics, **and the purity rule** |
| `test/data/` | `dart test` | frame assembly, segment codec, the GranBoard table |
| `test/app/` | `flutter test` | persistence, migrations, controllers, audio mapping, keypad, board widget, end screen, responsive layout |
| `test/widget_test.dart` | `flutter test` | the app end to end: roster → leg → leave → resume |

`test/domain/domain_purity_test.dart` fails if anything under `lib/domain/`
imports `package:flutter`. If it goes red, move the offending code out of
`domain/` — do not relax the test.

## Generated assets

Three committed Python scripts. Each is the source of truth for what it emits;
the emitted files are build output that happens to be committed.

### `tool/make_icon.py` — the launcher icon

```bash
python3 tool/make_icon.py       # needs Pillow
```

Parses `Palette.ground` and `Palette.chalk` out of `lib/app/theme.dart` and
draws a chalk tally, then writes five Android densities (legacy and adaptive),
the adaptive-icon XML, `@color/ic_launcher_background`, and the full iOS
`AppIcon.appiconset`. Change the green, re-run, and everything follows — the
icon cannot drift from the theme.

Deterministic: fixed seed, explicit UTF-8, explicit `\n` newlines. Re-running
without changing the theme produces byte-identical files, which is worth
checking with `git status` after a run.

### `tool/make_speech.py` — the commentary

```bash
sudo apt install ffmpeg pipx
pipx install piper-tts
python3 tool/make_speech.py
```

Renders 186 lines — every three-dart total 0–180, plus `bust`, `no score`,
`game shot`, `game on` and `one hundred and eighty` — with Piper
(`en_GB-northern_english_male-medium`, the accent darts is commentated in) and
encodes them to Ogg.

The vocabulary of a darts commentator is closed, so there is nothing left for a
text-to-speech engine on the phone to do: no first-call latency, no per-device
variation, no extra dependency. **The 63 MB voice model is build-time only** —
downloaded on first run to `~/.local/share/piper-voices`, gitignored, never
shipped. Licence and attribution: `assets/sounds/SPEECH-VOICE-LICENCE.txt`.

### `tool/make_cues.py` — the four cues

```bash
python3 tool/make_cues.py       # stdlib only
```

Synthesises `dart`, `bust`, `checkout` and `one_eighty` from sine partials with
Python's `wave` module. A bust and a checkout are the two that must never be
confused, so they sit three octaves apart with opposite contours.

> If a cue's length changes here, update `SoundTiming` in
> `lib/app/audio/sound_controller.dart` to match. The generator is the
> authority; the two files cannot see each other.

## Dependency constraints, learned the hard way

- **`flutter_blue_plus` is not open source.** Free for personal use only; any
  for-profit use requires a purchased commercial licence. If this ships
  commercially, swap it for `flutter_blue_ultra` or `universal_ble` (both
  BSD-3).
- **No Riverpod codegen.** `riverpod_generator` requires `analyzer ^13` while
  `drift_dev` pins an older analyzer — they cannot coexist. Providers are
  written by hand.
- **No `riverpod_lint` / `custom_lint`.** `riverpod_lint` caps
  `riverpod_annotation <4.0.0` and so is incompatible with Riverpod 3. Provider
  mistakes are not caught by tooling; keep providers few and small.
- **Do not write to the board.** The MVP is read-only; all audio is app-side.

## Conventions

- **Nothing counts incrementally.** State is folded from the dart log. A patch
  that introduces a running total, a cached derived value, or a counter updated
  as darts land is going the wrong way — that is what makes undo work.
- **Comments say why, not what.** The existing comments explain decisions and
  the things that bit somebody; match that density rather than narrating the
  code.
- **Every PR leaves `flutter analyze` clean and the full suite green.**
- **A schema change ships with its migration and a migration test** that has
  rows in the table before the upgrade.

## Working with the board

See [BOARD_PROTOCOL.md](BOARD_PROTOCOL.md) for the frame format and
[BOARD_PROTOCOL.md#hardware-day](BOARD_PROTOCOL.md#hardware-day) for the list of
questions only a connected 132 can answer.
