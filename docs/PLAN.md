# FlutterGran — GranBoard 132 Companion App (MVP)

## Context

`FlutterGran` is currently a stock `flutter create` template (`lib/main.dart` is the unmodified counter demo, zero third-party runtime dependencies, no git repo). The goal is a companion app for a **Bluetooth GranBoard 132** electronic dartboard: classic x01 for up to 4 players, live game state, checkout suggestions, and statistics both within a game and across every dart ever thrown.

Two research findings shape the entire plan:

1. **No public source verifies the 132.** Six independent open-source implementations of the GranBoard protocol exist and agree perfectly with each other — but every one that names a model names the **GRANBOARD 3s**. The 132 is a physically different board (13.2" vs 15.5", much narrower doubles/triples, touch sensor instead of physical buttons). Its segment matrix, LED geometry, and whether its touch sensor emits `BTN@` at all are **unconfirmed**. The 3s table is therefore *provisional data*, not truth, and the app needs a calibration path from day one.

2. **The hardware is weeks away.** Nearly all development happens with no board attached, so the fake board is not test scaffolding — it is the only board. It must be high enough fidelity that the work done in the meantime is genuinely verified.

Correcting the brief: `sobassy/gran-app` is not a good reference. Its BLE layer is a copy of [`CJPrez/DaDartboard`](https://github.com/CJPrez/DaDartboard), it does a single exact-match dictionary lookup per BLE notification with no frame buffering, no `@`-splitting, no handshake stripping and no dedupe, it has no `OUT@` handling, and its unknown-segment log prints `undefined` instead of the payload. Use [`burgerearmuffs/granbridge`](https://github.com/burgerearmuffs/granbridge) as the reference instead — live-hardware validated, with unit tests and captured fixtures.

---

## Protocol reference

**Transport:** BLE / GATT.

| Role | UUID |
|---|---|
| Service | `442f1570-8a00-9a28-cbe1-e1d4212d53eb` |
| Notify (board → app) | `442f1571-8a00-9a28-cbe1-e1d4212d53eb` |
| Write (app → board) | `442f1572-8a00-9a28-cbe1-e1d4212d53eb` (write-without-response; unused in MVP) |

The board advertises its 128-bit service UUID, so scan by service and use `neverForLocation` — **no location permission prompt on Android 12+**. Fall back to name prefix `GRAN`. No handshake write is required; notifications start immediately.

**Wire format:** ASCII `"<column>.<row>@"` — a *physical sensor-matrix coordinate*, not a score. Column 0–11, row 0–6.

**Required pipeline** (each stage exists because real hardware demonstrably breaks the naive version):

```
bytes → append to buffer
      → strip GB\d;\d{3} greeting prefix   (e.g. "GB8;102", no @ terminator, can be glued to first hit)
      → split on '@', keep incomplete tail in buffer
      → drop empty segments
      → 50 ms dedupe                       (board re-emits identical frames)
      → table lookup
      → Segment | Button | Out | Unknown(raw body)
```

Unknown frames must log **the raw body**, never the failed lookup result. That log line is the primary diagnostic on hardware day.

**Segment table** (3s-derived, provisional for the 132). `SI` = inner single, `T` = triple, `SO` = outer single, `D` = double. All entries confirmed identically across 6 codebases.

| N | SI | T | SO | D | | N | SI | T | SO | D |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 2.3 | 2.4 | 2.5 | 2.6 | | 11 | 7.3 | 7.4 | 7.5 | 7.6 |
| 2 | 9.1 | 9.0 | 9.2 | 8.2 | | 12 | 5.0 | 5.3 | 5.5 | 5.6 |
| 3 | 7.1 | 7.0 | 7.2 | 8.4 | | 13 | 0.0 | 0.2 | 0.4 | 4.5 |
| 4 | 0.1 | 0.3 | 0.5 | 0.6 | | 14 | 10.3 | 10.4 | 10.5 | 10.6 |
| 5 | 5.1 | 5.2 | 5.4 | 4.6 | | 15 | 3.0 | 3.1 | 3.2 | 4.2 |
| 6 | 1.0 | 1.1 | 1.3 | 4.4 | | 16 | 11.0 | 11.3 | 11.5 | 11.6 |
| 7 | 11.1 | 11.2 | 11.4 | 8.6 | | 17 | 10.1 | 10.0 | 10.2 | 8.3 |
| 8 | 6.2 | 6.4 | 6.5 | 6.6 | | 18 | 1.2 | 1.4 | 1.5 | 1.6 |
| 9 | 9.3 | 9.4 | 9.5 | 9.6 | | 19 | 6.1 | 6.0 | 6.3 | 8.5 |
| 10 | 2.0 | 2.1 | 2.2 | 4.3 | | 20 | 3.3 | 3.4 | 3.5 | 3.6 |

Specials: `8.0` = single bull (25) · `4.0` = double bull (50) · `BTN` = button/touch · `OUT` = miss.

Sanity check that validates the table: the grid is 12 columns × 7 rows = 84 slots. Ten columns each serve two numbers (8 segments into 7 rows), so exactly one double overflows per column. Columns 4 and 8 are the overflow columns, each holding one bull plus five displaced doubles. `4.1` and `8.1` are unused — **a valid hit can never produce them**, which makes them a useful assertion.

---

## Decisions

| Area | Decision |
|---|---|
| Platform | Android is the build/test target; iOS kept build-ready (config only, unverifiable without a Mac) |
| Distribution | Personal sideload — no store listing, privacy policy, accounts, or analytics |
| BLE package | `flutter_blue_plus` ^2.3.11 |
| Rules | Start 301/501/701, straight-in, **double-out**, single leg, up to 4 players, fixed order |
| Bust | Turn score voided, score reverts to start-of-turn, turn ends |
| Turn advance | Auto on 3rd dart / bust / checkout → turn-summary screen → dismissed by tap **or** `BTN@` |
| Corrections | Unlimited single-dart undo via event log + pure re-fold; manual pad for re-entry |
| Out-calc | Precomputed darts-aware search, best route + 2 alternates, refreshed after every dart |
| Players | Persistent roster; every dart attributed to a player id |
| Stats | Scoring core, checkout stats, first-9 average, per-segment heatmap |
| Persistence | `drift` over SQLite |
| State | `riverpod`; **game engine is pure Dart with zero Flutter imports** |
| Fake board | Emits raw byte frames through the real parser; frame recorder for replay |
| Calibration | Live diagnostic screen, tap-to-correct, 82-cell coverage checklist, override file |
| Board writes | **None.** Read-only. All audio is app-side |

### Why `flutter_blue_plus` needs a note

It is **no longer open source**: *"Use of the Software by any for-profit organization requires a commercial license under Section 3, regardless of how the Software was obtained."* Free for personal use, which this is. **If this app ever becomes commercial or ships under a company, this dependency must be swapped** — `flutter_blue_ultra` (BSD-3 fork of the 1.x API) or `universal_ble` (BSD-3) are the escape hatches. Record this in `CLAUDE.md`.

---

## Architecture

`lib/main.dart` currently holds `MyApp` / `MyHomePage` / `_MyHomePageState` (counter demo) and `test/widget_test.dart` tests it. Both are replaced.

```
lib/
  domain/                        ← pure Dart, no flutter imports, runs under `dart test`
    segment.dart                 Segment(number, Ring{innerSingle,triple,outerSingle,double,bull,dBull}), value getter
    board_event.dart             sealed: DartHit | ButtonPress | Miss | UnknownFrame(raw)
    x01/
      game_config.dart           startScore, playerIds, doubleOut
      leg_state.dart             immutable derived state: scores, turn, dartsThrown, finished
      leg_reducer.dart           fold(List<BoardEvent>, GameConfig) -> LegState   ← the core
    checkout/
      checkout_search.dart       BFS over (remaining, dartsLeft) with preference cost
      checkout_table.dart        materialized best+alternates lookup
  data/
    board/
      frame_assembler.dart       buffer, greeting strip, @-split, dedupe
      segment_codec.dart         frame body -> BoardEvent, base table + override layer
      board_source.dart          abstract Stream<List<int>> rawFrames + connection state
      ble_board_source.dart      flutter_blue_plus impl: scan by service, notify, backoff reconnect
      fake_board_source.dart     scripted raw frames incl. split/glued/duplicate cases
      frame_recorder.dart        appends every raw chunk to a file
    db/
      database.dart              drift: Players, Games, Legs, DartEvents
      stats_dao.dart             aggregate queries
  app/
    providers.dart               riverpod; boardSourceProvider overridden by the fake
    screens/                     game, turn_summary, roster, game_setup, stats, diagnostics
    widgets/board_widget.dart    82 tappable regions — serves entry pad, heatmap, calibration
assets/
  segment_map.json               base table (3s-derived)
```

**The board widget is one component doing three jobs** — manual entry pad, heatmap render, and calibration target picker. It was already on the critical path; the heatmap is close to free once it exists.

**Checkout preference cost function:** fewest darts first, then prefer finishing on D20/D16, then prefer leaving an even number, then prefer higher-percentage triples. Correctness is pinned by asserting the canonical pro checkout table for every 3-dart finish 2–170, and asserting *no* route exists for the bogey numbers 169, 168, 166, 165, 163, 162, 159.

**Checkout-percentage rule** (the one subtle stat): a dart counts as "at a double" only when the score standing immediately before it is finishable by a single double — even and ≤ 40, or exactly 50.

---

## Milestones

| # | Deliverable |
|---|---|
| **M0** | `git init` + baseline commit (project is currently untracked — do this before anything). Add deps, folder skeleton, tighten `analysis_options.yaml` |
| **M1** | `domain/` x01 engine + reducer, full unit tests under `dart test`. No Flutter |
| **M2** | Checkout search + golden test against the canonical 2–170 table |
| **M3** | Frame layer: assembler, codec, fake source, recorder. Tests use granbridge's exact fixtures |
| **M4** | Playable vertical slice: game screen + manual pad + fake board + undo + turn summary |
| **M5** | `drift` schema, roster screen, game setup, persistence of dart events |
| **M6** | Stats screens: scoring core, checkout stats, first-9, heatmap |
| **M7** | Real BLE: scan/connect/notify, reconnect with exponential backoff + jitter, permissions |
| **M8** | **Hardware day**: diagnostics screen, verify/correct the 132 table, record fixtures |

### Platform config (M7)

`android/app/src/main/AndroidManifest.xml` currently declares **zero** permissions. Add:

```xml
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"
                 android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

`ios/Runner/Info.plist` has no usage-description keys. Add `NSBluetoothAlwaysUsageDescription`. Deployment target is already 13.0. There is no `Podfile` yet — CocoaPods initializes on the first plugin dependency.

Existing config worth knowing: `minSdk` 24, `compileSdk`/`targetSdk` 36, Kotlin 2.3.20, AGP 9.0.1, Gradle 9.1.0, `applicationId` `de.bot.filan.fluttergran`. **Release currently signs with the debug key** — acceptable for sideload, but it means no upgrade path to a store listing without a keystore change.

### BLE stability rules (from live-hardware sources, not blogs)

- **No idle/silence watchdog.** The board is silent between throws; a silence timeout falsely fires. Detect drops via the disconnect callback only.
- Dedupe window 50 ms.
- Reconnect backoff `min(30s, 0.5 × 2^attempt) + jitter`; **reset the frame assembler on every reconnect**.
- Re-discover services after each reconnect.
- Connection drops are the documented #1 field complaint about this hardware. Robust reconnect is a core feature, not polish.

---

## Verification

**Continuous** — from project root:
```
flutter analyze
flutter test
dart test test/domain            # engine + checkout, no Flutter binding needed
```

**Per milestone:**

- **M1** — reducer tests: bust reverts correctly, double-out rejects a non-double finish, score of 1 busts, undo across a turn boundary restores the previous player's turn, 4-player rotation.
- **M2** — golden test asserting every canonical 3-dart checkout 2–170; assert no route for the 7 bogey numbers; assert 2-dart and 1-dart states resolve sensibly (e.g. 40 with 1 dart → D20; 41 with 1 dart → no route).
- **M3** — feed the three known-pathological inputs and assert exact output: `b"2.5@8.0@OUT@"` → 3 events; `b"2."` then `b"5@"` → 1 event; `b"GB8;1027.0@"` → 1 event (greeting stripped). Assert `4.1@` and `8.1@` decode as `UnknownFrame`, not a valid segment.
- **M4** — run on an Android device (`flutter run`), play a full 501 leg end-to-end driven by the fake board, exercising undo mid-turn, a bust, and a checkout.
- **M6** — play three legs, then confirm all-time stats match hand-computed values from the event log.
- **M7** — on device: airplane-mode toggle mid-game must reconnect and resume without corrupting the leg.
- **M8 (hardware day)** — connect, open diagnostics, throw at every one of the 82 segments and confirm the coverage checklist fills with zero corrections (or record the corrections). Verify the touch sensor emits `BTN@`. Verify whether `OUT@` ever fires. Save a recorded frame file as a permanent replay fixture.

---

## Open questions to resolve on hardware day

1. Does the 132's segment matrix match the 3s table? (calibration screen answers this)
2. Does the touch sensor emit `BTN@`? If not, turn-summary dismissal is tap-only — already the designed fallback, so nothing breaks.
3. Does `OUT@` ever fire? granbridge reports the 3s effectively never sends it despite the vendor spec listing an out sensor; a writable "out sensitivity" setting (0–15) exists and may ship at zero.
4. What is the full advertised device name? Only the prefix `GRAN` is confirmed.
5. What do the `GB<n>;<ddd>` greeting fields mean? Model + firmware is inference only.

Deferred beyond MVP, in rough priority order: legs and sets, double-in / straight-out variants, LED integration (lighting the checkout double on the board is the strongest feature this hardware allows), setup-shot advice above 170, editing arbitrary past darts, and configurable double preference.
