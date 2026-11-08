# Development

Running the app on real devices, the test layout, the layout breakpoints and
the asset generators. Setup, the golden rules and the recipes are in
[CONTRIBUTING.md](../CONTRIBUTING.md), which is the place to start.

## Commands

```bash
tool/check.sh                                              # what CI runs; --quick skips codegen, l10n, dartdoc
flutter analyze                                            # must be clean
flutter test                                               # everything
dart test test/domain test/data                            # engine, checkout, protocol
dart format lib test                                       # the whole tree is formatted; CI checks it
flutter gen-l10n                                           # after editing an .arb file
dart run build_runner build --delete-conflicting-outputs   # after any table change
dart pub global run dartdoc                                # API docs to doc/api/ (dartdoc 9.0.11)
```

`test/domain` and `test/data` run under plain `dart test` because neither layer
imports Flutter, which makes the engine fast to iterate on. `test/app` needs
`flutter test`. No board is needed for any of it: with nothing connected, the
keypad scores, and tests drive `FakeBoardSource`.

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

## Running on Windows

```bash
flutter run -d windows
flutter build windows                  # build\windows\x64\runner\Release\
```

Needs Visual Studio 2022 with the **Desktop development with C++** workload
(`flutter doctor` says what is missing), and only builds on Windows: there is
no cross-compiling the runner from Linux or macOS. CI's `build / windows` job
compiles it on every PR (`build.yml`, called from `ci.yml`), which is the
check for a change made elsewhere.

What differs from Android:

- **Layout.** The window opens maximised, cannot be dragged below 960x600
  logical, and gets the desktop tiers in `lib/app/theme.dart`
  (`isDesktop`, `desktopHeroLayout`, `typeScaleFor`) — see
  [Layout breakpoints](#layout-breakpoints) and
  [ARCHITECTURE.md](ARCHITECTURE.md#layout).
- **Data.** The database lives in `%APPDATA%\de.bot.filan\Chalk\`
  (`getApplicationSupportDirectory`, named from `CompanyName`/`ProductName` in
  `windows/runner/Runner.rc`), not Documents. Renaming either string moves it.
- **Audio.** The commentary is Ogg Vorbis. Windows decodes it through Media
  Foundation with the *Web Media Extensions* codec, which ships with Windows
  10 and 11 but not with the N editions; there the cues and commentary are
  silent until it is installed from the Microsoft Store. `PlayerMode.lowLatency`
  is a no-op on Windows.
- **Bluetooth.** See [CONNECTIVITY.md](CONNECTIVITY.md#windows).
- **Installer.** Releases ship `chalk-X.Y.Z-windows-x64-setup.exe`, an
  [Inno Setup](https://jrsoftware.org/isinfo.php) wizard from
  `windows/installer/chalk.iss`: per-user into `%LOCALAPPDATA%\Programs\Chalk`
  with no admin rights (the wizard offers all users too), a Start-menu entry,
  an uninstaller that leaves the database alone. To build it locally, install
  Inno Setup 6, build release, copy the three VC++ DLLs in as `build.yml`'s
  Package step does, then from the repo root:

  ```bat
  "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" /DAppVersion=1.4.0 /DSourceDir=%CD%\build\windows\x64\runner\Release windows\installer\chalk.iss
  ```

  It lands in `build\installer\`. The app updates itself by downloading the
  next one and running it silently: see
  [RELEASING.md](RELEASING.md#in-app-updates).

## Test layout

| Directory | Runner | Covers |
|---|---|---|
| `test/domain/` | `dart test` | x01 fold, match fold, checkout search and table, x01 rules, segments, game modes, player statistics, **and the purity rule** |
| `test/domain/atc/`, `bulling/`, `higher_lower/`, `training/` | `dart test` | each mode's config, fold and statistics |
| `test/data/` | `dart test` | frame assembly, board reader, segment codec, the GranBoard table, LED command encoding |
| `test/data/update/` | `dart test` | release lookup (APK and Windows installer names), version comparison, verified download |
| `test/app/` | `flutter test` | controllers, persistence, migrations, sound and LED mappings, LED scheduler, keypad, board widget, every screen, responsive and per-mode layout, update flow |
| `test/support/` | - | shared helpers: `darts.dart`, `async.dart`, `database.dart`, `sound.dart`, `lights.dart`, `devices.dart`, `pump.dart`, `board_clock.dart`, `fake_update.dart` |
| `test/widget_test.dart` | `flutter test` | x01 end to end: roster → leg → leave → resume |
| `test/atc_widget_test.dart` | `flutter test` | Around the Clock end to end |

How to write one (which folder, Windows variants, `FakeBoardSource`) is in
[CONTRIBUTING.md](../CONTRIBUTING.md#add-a-test).

`test/domain/domain_purity_test.dart` fails if anything under `lib/domain/`
imports `package:flutter`. If it goes red, move the offending code out of
`domain/` — do not relax the test.

## Layout breakpoints

All in `lib/app/theme.dart`, and what
[ARCHITECTURE.md](ARCHITECTURE.md#layout) builds on. These are the reasons
behind each number, so a change can be checked against the device it was
measured on.

| Constant | Value | Why |
|---|---|---|
| `wideLayout` | 600 | Where a phone on its side lands and a tablet always is. Below it a column is the only arrangement that fits a keypad; above it a column would leave the score marooned at the top of a wide screen |
| `heroLayout` | 780 (shortest side) | A Samsung Galaxy Tab S6 Lite, the tablet the layout is built for, measures 800dp at its shipped display size (`adb shell wm size` / `adb shell wm density`: 1200x2000 physical at 240dpi). The threshold has to clear that with room to spare, or that tablet gets the phone treatment |
| `desktopHeroLayout` | 900x580 | A 1080p laptop at Windows' default 150% is 1280x720 logical, about 640 high after the title bar and taskbar: short of `heroLayout`, but plenty for the hero cards side by side. Set just under the runner's 960x600 client-area floor (`windows/runner/flutter_window.cpp`), so the smallest window the runner allows always qualifies. Change one, check the other |
| `formContentWidth` | 640 | A setup column a hand can take in at a glance; the rest of a tablet's width becomes margin. On desktop the cap grows with `typeScaleFor`, so 1.75-sized labels do not wrap into a phone-width strip |

**Why a desktop is sized by its window.** A desktop window has width to spare
and never enough height: a laptop is landscape, the title bar and taskbar take
their share, and the window can be any size its owner drags it to. So
`isDesktop` devices qualify for the hero layout by window size (`isHeroSize`),
and call sites ask `isHeroDevice(context)` rather than comparing
`shortestSide` themselves.

**`typeScaleFor` tiers.** The sizes in `Type` are for a phone at arm's length.
A tablet is further away, on a table or a stand, so the same 62px score reads
as ordinary across a room. Keyed to the shortest side, which says how big the
device is rather than which way up it is held.

| | 1.0 | 1.25 | 1.5 | 1.75 |
|---|---|---|---|---|
| Mobile | below 700 | from 700 | from 780 (`heroLayout`) | - |
| Desktop | below 580 | from 580 (`desktopHeroLayout.height`) | from 780 | from 1000 |

The desktop's extra bottom tier gives a laptop's ~640-high window bigger type
along with the hero layout; the extra top tier is for a full-height window on a
monitor at 100% scaling, where a logical pixel is physically the smallest on
any screen the app runs on.

## Generated assets

Three committed Python scripts. Each is the source of truth for what it emits;
the emitted files are build output that happens to be committed.

### `tool/make_icon.py` — the launcher icon

```bash
python3 tool/make_icon.py       # needs Pillow
```

Parses `Palette.ground` and `Palette.chalk` out of `lib/app/theme.dart` and
draws a chalk tally, then writes five Android densities (legacy and adaptive),
the adaptive-icon XML, `@color/ic_launcher_background`, and the Windows
`app_icon.ico` (16 to 256px, each drawn down from the master). Change the green, re-run, and everything follows — the
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

## Dependency constraints and conventions

The dependency constraints (`flutter_blue_plus` licence, no Riverpod codegen
or lints, audioplayers position polling, LED-only writes) and the code
conventions are in [CONTRIBUTING.md](../CONTRIBUTING.md#golden-rules), which
is their one home.

## Working with the board

See [BOARD_PROTOCOL.md](BOARD_PROTOCOL.md) for the frame format and
[BOARD_PROTOCOL.md#hardware-day](BOARD_PROTOCOL.md#hardware-day) for what a
connected 132 confirmed.
