# Graph Report - bulling-game-mode  (2026-09-10)

## Corpus Check
- 125 files · ~131,037 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1885 nodes · 2858 edges · 109 communities (103 shown, 6 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 4 edges (avg confidence: 0.5)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `591936f2`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- database.dart
- theme.dart
- checkout_search.dart
- ble_board_source.dart
- _
- player_stats_test.dart
- leg_state.dart
- providers.dart
- package:flutter_test/flutter_test.dart
- package:flutter_riverpod/flutter_riverpod.dart
- board_widget.dart
- game_repository.dart
- dart
- mode_stats.dart
- player_stats.dart
- match_state.dart
- migration_test.dart
- fake_board_source.dart
- game_controller.dart
- board_source.dart
- board_reader_test.dart
- sound_controller_test.dart
- boardConnectionProvider
- match_controller.dart
- make_icon.py
- AppDelegate
- stats_screen.dart
- make_cues.py
- roster_screen.dart
- resumable_leg_provider_test.dart
- x01_setup_screen.dart
- responsive_layout_test.dart
- playersProvider
- Connectivity
- splash_screen_test.dart
- main_menu_screen.dart
- bulling_leg_state.dart
- end_screen_test.dart
- dart
- Bulling Game Mode Implementation Plan
- segment.dart
- frame_assembler.dart
- dart_keypad.dart
- persistence_test.dart
- thrown_dart.dart
- DataClass
- Development
- main.dart
- Data model
- ../providers.dart
- Map
- bulling_setup_screen.dart
- frame_assembler_test.dart
- Architecture
- The board protocol
- select_game_mode_screen.dart
- game_mode.dart
- game_config.dart
- package:fluttergran/domain/segment.dart
- main
- fluttergran
- The GranBoard 132
- atc_leg_state.dart
- Chalk
- Table
- segment_codec.dart
- keypadOverrideProvider
- atc_stats_test.dart
- worker.md
- _Body
- SettingsScreen
- MainActivity
- LaunchImage.imageset/README.md
- atc_controller_test.dart
- bool?
- Random
- dart
- atc_controller.dart
- currentGameIdProvider
- atc_setup_screen.dart
- atc_stop.dart
- reconnect_delay_test.dart
- bulling_controller.dart
- Around the Clock — design
- bulling_reducer_test.dart
- Connection lifecycle
- CustomPainter
- List
- widget_test.dart
- atc_reducer.dart
- bulling_reducer.dart
- bulling_stats_test.dart
- bulling_controller_test.dart
- select_game_mode_screen_test.dart
- atc_reducer_test.dart
- package:fluttergran/domain/x01/thrown_dart.dart
- roster_screen_test.dart
- AppDatabase
- board_geometry_test.dart
- board_widget_test.dart
- int get
- ModeStats
- int?
- BoardSource

## God Nodes (most connected - your core abstractions)
1. `dart` - 69 edges
2. `_` - 48 edges
3. `dart` - 45 edges
4. `dart` - 44 edges
5. `gameRepositoryProvider` - 25 edges
6. `currentGameIdProvider` - 25 edges
7. `AppDatabase` - 22 edges
8. `Bulling Game Mode Implementation Plan` - 21 edges
9. `FakeBoardSource` - 20 edges
10. `keypadOverrideProvider` - 13 edges

## Surprising Connections (you probably didn't know these)
- `_MutePlayer` --implements--> `SoundPlayer`  [EXTRACTED]
  test/app/end_screen_test.dart → lib/app/audio/sound_controller.dart
- `_MutePlayer` --implements--> `SoundPlayer`  [EXTRACTED]
  test/app/responsive_layout_test.dart → lib/app/audio/sound_controller.dart
- `_FakePlayer` --implements--> `SoundPlayer`  [EXTRACTED]
  test/app/sound_controller_test.dart → lib/app/audio/sound_controller.dart
- `_SchemaV2` --inherits--> `AppDatabase`  [EXTRACTED]
  test/app/migration_test.dart → lib/data/db/database.dart
- `_SchemaV4` --inherits--> `AppDatabase`  [EXTRACTED]
  test/app/migration_test.dart → lib/data/db/database.dart

## Import Cycles
- None detected.

## Communities (109 total, 6 thin omitted)

### Community 0 - "database.dart"
Cohesion: 0.02
Nodes (111): BoolColumn get, ColumnFilters, ColumnOrderings, ColumnWithTypeConverterFilters, DateTimeColumn get, GeneratedColumn, GeneratedColumnWithTypeConverter, GeneratedDatabase (+103 more)

### Community 1 - "theme.dart"
Cohesion: 0.04
Nodes (48): ColorScheme, 1, base, body, brand, build, buildTheme, chalk (+40 more)

### Community 2 - "checkout_search.dart"
Cohesion: 0.10
Nodes (19): _byValue, CheckoutRoute, _compare, cost, darts, findCheckouts, finish, _finishCost (+11 more)

### Community 3 - "ble_board_source.dart"
Cohesion: 0.05
Nodes (41): BluetoothDevice?, BluetoothDevice? get, _attempt, _attemptConnect, connect, connectionState, _current, currentState (+33 more)

### Community 4 - "_"
Cohesion: 0.05
Nodes (42): ../game_controller.dart, _, after, afterBustCue, afterCheckoutCue, afterOneEightyCue, asset, before (+34 more)

### Community 5 - "player_stats_test.dart"
Cohesion: 0.14
Nodes (12): package:fluttergran/domain/x01/leg_reducer.dart, package:fluttergran/domain/x01/leg_state.dart, package:fluttergran/domain/x01/match_state.dart, config, main, d, leg, main (+4 more)

### Community 6 - "leg_state.dart"
Cohesion: 0.05
Nodes (36): game_config.dart, leg_state.dart, foldLeg, initialLegState, playerIndex, remaining, turnDarts, turns (+28 more)

### Community 7 - "providers.dart"
Cohesion: 0.05
Nodes (41): audio/sound_controller.dart, audio/sound_player.dart, ../data/board/ble_board_source.dart, ../data/board/segment_codec.dart, ../domain/checkout/checkout_table.dart, allAtcLegsProvider, allBullingLegsProvider, allLegsProvider (+33 more)

### Community 8 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.09
Nodes (21): package:flutter_test/flutter_test.dart, package:fluttergran/app/widgets/dart_keypad.dart, highlight, main, pumpKeypad, pumpWidget, closeApp, database (+13 more)

### Community 9 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.08
Nodes (24): dart:async, ../../data/board/board_source.dart, _attempted, createState, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:fluttergran/app/screens/atc_game_screen.dart, package:fluttergran/app/screens/settings_screen.dart (+16 more)

### Community 10 - "board_widget.dart"
Cohesion: 0.06
Nodes (33): Color, _black, BoardGeometry, boardWedgeOrder, build, _cream, doubleInner, doubleOuter (+25 more)

### Community 11 - "game_repository.dart"
Cohesion: 0.05
Nodes (43): database.dart, addPlayer, allPlayers, appendDart, _aroundTheClock, _bulling, db, deleteEmptyGames (+35 more)

### Community 12 - "dart"
Cohesion: 0.05
Nodes (47): ../../domain/checkout/checkout_search.dart, ../../domain/stats/player_stats.dart, double?, dart, average, _CheckoutPanel, _CheckoutStrip, child (+39 more)

### Community 13 - "mode_stats.dart"
Cohesion: 0.04
Nodes (46): double? get, average, bestCheckout, bestTurn, checkoutRate, dartsAtDouble, doublesHit, firstNineAverage (+38 more)

### Community 14 - "player_stats.dart"
Cohesion: 0.05
Nodes (40): ../atc/atc_leg_state.dart, ../atc/atc_stop.dart, ../bulling/bulling_leg_state.dart, ../bulling/bulling_reducer.dart, ../game_mode.dart, Iterable, atcLegs, bestCheckout (+32 more)

### Community 15 - "match_state.dart"
Cohesion: 0.07
Nodes (26): GameConfig? get, config, counted, doubleOut, foldMatch, formatLabel, isFinished, isHeadToHead (+18 more)

### Community 16 - "migration_test.dart"
Cohesion: 0.08
Nodes (23): Directory, File, MigrationStrategy get, d, directory, file, _gamesAtV2, _gamesAtV4 (+15 more)

### Community 17 - "fake_board_source.dart"
Cohesion: 0.08
Nodes (24): board_source.dart, connect, connectionState, _current, currentState, disconnect, dispose, emitBatch (+16 more)

### Community 18 - "game_controller.dart"
Cohesion: 0.11
Nodes (18): ../../domain/x01/leg_reducer.dart, ../../domain/x01/leg_state.dart, acknowledgedTurns, addDart, awaitingTurnConfirm, confirmTurn, GameSession, handleBoardEvent (+10 more)

### Community 19 - "board_source.dart"
Cohesion: 0.08
Nodes (23): BoardConnectionState get, disconnected,
  scanning,
  connecting,, frame_assembler.dart, assembler, BoardConnectionState, codec, connect, connected (+15 more)

### Community 20 - "board_reader_test.dart"
Cohesion: 0.14
Nodes (19): BoardReader, BoardEvent, BoardMiss, body, ButtonPress, DartHit, segment, toString (+11 more)

### Community 21 - "sound_controller_test.dart"
Cohesion: 0.05
Nodes (37): AudioPlayer, SoundPlayer, AudioPlayersSoundPlayer, _cues, dispose, _disposed, _fire, _live (+29 more)

### Community 22 - "boardConnectionProvider"
Cohesion: 0.18
Nodes (19): ConsumerWidget, boardConnectionProvider, boardSourceProvider, bullingGameProvider, decidedMatchLegsProvider, matchProvider, matchStateProvider, playerNamesProvider (+11 more)

### Community 23 - "match_controller.dart"
Cohesion: 0.15
Nodes (15): ../../domain/x01/game_config.dart, ../../domain/x01/match_state.dart, build, config, decidedLegs, leave, MatchController, matchId (+7 more)

### Community 24 - "make_icon.py"
Cohesion: 0.19
Nodes (20): Image, _chalk_polygon(), corner_mask(), _down(), draw_mark(), foreground(), _hex(), main() (+12 more)

### Community 25 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate, Bool (+6 more)

### Community 26 - "stats_screen.dart"
Cohesion: 0.10
Nodes (20): ../../domain/atc/atc_stop.dart, ../../domain/stats/mode_stats.dart, createState, _decimal, detail, _Empty, _Eyebrow, _Headline (+12 more)

### Community 27 - "make_cues.py"
Cohesion: 0.25
Nodes (19): Samples, bust(), checkout(), dart(), envelope(), main(), mix(), normalise() (+11 more)

### Community 28 - "roster_screen.dart"
Cohesion: 0.11
Nodes (18): FocusNode, _commit, _controller, createState, didUpdateWidget, dispose, _editing, _focusNode (+10 more)

### Community 29 - "resumable_leg_provider_test.dart"
Cohesion: 0.09
Nodes (26): GameRepository, package:drift/native.dart, package:fluttergran/data/db/database.dart, package:fluttergran/data/db/game_repository.dart, database, main, repository, s (+18 more)

### Community 30 - "x01_setup_screen.dart"
Cohesion: 0.11
Nodes (17): createState, dispose, _Eyebrow, _headToHead, _legsToPlay, _newPlayer, onTap, score (+9 more)

### Community 31 - "responsive_layout_test.dart"
Cohesion: 0.11
Nodes (17): board, container, database, dispose, frames, main, openAt, phoneLandscape (+9 more)

### Community 32 - "playersProvider"
Cohesion: 0.15
Nodes (20): ConsumerState, ConsumerStatefulWidget, playersProvider, AtcSetupScreen, _AtcSetupScreenState, build, build, BullingSetupScreen (+12 more)

### Community 33 - "Connectivity"
Cohesion: 0.15
Nodes (13): Android, Connecting from the app, Connectivity, GATT, iOS, Licensing note, Permissions, Playing without a board (+5 more)

### Community 34 - "splash_screen_test.dart"
Cohesion: 0.13
Nodes (14): Batch, Duplicate, GreetingGluedTo, FakeBoardSource, Miss, package:fluttergran/app/screens/main_menu_screen.dart, package:fluttergran/app/screens/splash_screen.dart, Raw (+6 more)

### Community 35 - "main_menu_screen.dart"
Cohesion: 0.12
Nodes (16): atc_game_screen.dart, bulling_game_screen.dart, game_screen.dart, IconData, icon, label, _MenuRow, names (+8 more)

### Community 36 - "bulling_leg_state.dart"
Cohesion: 0.09
Nodes (22): BullingTurn? get, BullingLegState, BullingTurn, config, currentPlayerId, currentPlayerIndex, currentTurnDarts, darts (+14 more)

### Community 37 - "end_screen_test.dart"
Cohesion: 0.12
Nodes (15): package:fluttergran/app/screens/game_screen.dart, board, checkout, container, d, database, dispose, frames (+7 more)

### Community 38 - "dart"
Cohesion: 0.10
Nodes (22): ../bulling_controller.dart, dart, _BoardScoringAlone, _confirmLeave, _DartSlot, leg, _LegWon, live (+14 more)

### Community 39 - "Bulling Game Mode Implementation Plan"
Cohesion: 0.09
Nodes (21): Bulling Game Mode Implementation Plan, Design, precisely, Domain (`lib/domain/bulling/`), Global Constraints, Out of scope for this pass, Persistence, Self-review notes, Stats (`lib/domain/stats/bulling_stats.dart`, `part of 'mode_stats.dart'`) (+13 more)

### Community 40 - "segment.dart"
Cohesion: 0.15
Nodes (12): all, hashCode, innerBull, isDouble, label, multiplier, number, operator (+4 more)

### Community 41 - "frame_assembler.dart"
Cohesion: 0.14
Nodes (13): Duration, _buffer, dedupeWindow, feed, FrameAssembler, _greeting, _isRepeat, _lastAt (+5 more)

### Community 42 - "dart_keypad.dart"
Cohesion: 0.14
Nodes (13): build, createState, _enter, highlight, highlighted, _isHighlighted, _Key, label (+5 more)

### Community 43 - "persistence_test.dart"
Cohesion: 0.14
Nodes (13): package:drift/drift.dart, board, container, controller, d, database, gameId, main (+5 more)

### Community 44 - "thrown_dart.dart"
Cohesion: 0.17
Nodes (11): bool get, Segment, hashCode, isDouble, label, miss, operator, segment (+3 more)

### Community 45 - "DataClass"
Cohesion: 0.21
Nodes (17): DataClass, AtcGame, AtcGamesCompanion, BullingGame, BullingGamesCompanion, DartEvent, DartEventsCompanion, Game (+9 more)

### Community 46 - "Development"
Cohesion: 0.17
Nodes (12): Commands, Conventions, Dependency constraints, learned the hard way, Development, Generated assets, Running on a device, Setup, Test layout (+4 more)

### Community 47 - "main.dart"
Cohesion: 0.12
Nodes (18): app/screens/splash_screen.dart, app/theme.dart, _PlayerTile, _PlayerTileState, DartKeypad, _DartKeypadState, build, child (+10 more)

### Community 48 - "Data model"
Cohesion: 0.18
Nodes (11): `DartEvents` — every dart, Data model, `Games` — one leg, `GameSeats` — who sat where, `Matches` — a run of legs, Migrations, `Players`, Reading it back (+3 more)

### Community 49 - "../providers.dart"
Cohesion: 0.11
Nodes (18): detail, enabled, _Eyebrow, label, onChanged, _SoundToggle, text, value (+10 more)

### Community 50 - "Map"
Cohesion: 0.11
Nodes (17): checkout_search.dart, ../../domain/segment.dart, buttonCode, granboardSegmentMap, innerBullCode, missCode, outerBullCode, _ringOrder (+9 more)

### Community 51 - "bulling_setup_screen.dart"
Cohesion: 0.11
Nodes (18): ../../domain/bulling/bulling_config.dart, ../../domain/bulling/bulling_variant.dart, _bullseyeValue, bullseyeValueLabel, createState, dispose, _Eyebrow, label (+10 more)

### Community 52 - "frame_assembler_test.dart"
Cohesion: 0.22
Nodes (8): DateTime, package:fluttergran/data/board/frame_assembler.dart, advance, bytes, call, FakeClock, main, now

### Community 53 - "Architecture"
Cohesion: 0.14
Nodes (14): Architecture, Audio, Checkouts, Everything is a fold, Game modes, Layout, Matches, Screens (+6 more)

### Community 54 - "The board protocol"
Cohesion: 0.22
Nodes (9): Connection lifecycle, Decoding, Frame assembly, Hardware day (2026-09-04) — resolved, In one paragraph, Playing without a board, The board protocol, The pipeline (+1 more)

### Community 55 - "select_game_mode_screen.dart"
Cohesion: 0.15
Nodes (12): atc_setup_screen.dart, bulling_setup_screen.dart, ../../domain/game_mode.dart, build, _ComingSoonTile, _icons, mode, modes (+4 more)

### Community 56 - "game_mode.dart"
Cohesion: 0.25
Nodes (7): displayName, GameMode, GameModeDescriptor, gameModeRegistry, id, isAvailable, tagline

### Community 57 - "game_config.dart"
Cohesion: 0.25
Nodes (7): doubleOut, maxPlayers, offeredStartScores, playerIds, startingSeat, startScore, static const int

### Community 58 - "package:fluttergran/domain/segment.dart"
Cohesion: 0.11
Nodes (16): dart:io, package:fluttergran/data/board/granboard_segment_map.dart, package:fluttergran/domain/checkout/checkout_search.dart, package:fluttergran/domain/checkout/checkout_table.dart, package:fluttergran/domain/segment.dart, package:test/test.dart, Set, coords (+8 more)

### Community 59 - "main"
Cohesion: 0.42
Nodes (8): encode(), ensure_voice(), main(), Path, Downloads the voice if it is not already there, and returns the model path., A number as a commentator says it: "one hundred and eighty", not "one eight…, spell(), synthesise()

### Community 60 - "fluttergran"
Cohesion: 0.25
Nodes (7): Board protocol, in one paragraph, Commands, Dependency constraints (learned the hard way), fluttergran, graphify, Hardware day (done), Layering rule

### Community 61 - "The GranBoard 132"
Cohesion: 0.25
Nodes (8): Hardware day (2026-09-04) — done, Non-dart frames, See also, The GranBoard 132, The matrix, The segment table, What is confirmed, and what is not, What kind of device it is

### Community 62 - "atc_leg_state.dart"
Cohesion: 0.09
Nodes (22): AtcTurn? get, AtcLegState, AtcTurn, config, currentPlayerId, currentPlayerIndex, currentStopFor, currentTurnDarts (+14 more)

### Community 63 - "Chalk"
Cohesion: 0.25
Nodes (8): Chalk, Documentation, Generated assets, How it is put together, Licence notes, Quick start, Testing, What it does

### Community 64 - "Table"
Cohesion: 0.22
Nodes (9): @DataClassName, AtcGames, BullingGames, DartEvents, Games, GameSeats, Matches, Players (+1 more)

### Community 66 - "segment_codec.dart"
Cohesion: 0.29
Nodes (6): ../../domain/board_event.dart, granboard_segment_map.dart, _base, decode, knows, SegmentCodec

### Community 67 - "keypadOverrideProvider"
Cohesion: 0.15
Nodes (22): AtcController, build, build, BullingController, build, GameController, AtcConfigController, atcConfigProvider (+14 more)

### Community 68 - "atc_stats_test.dart"
Cohesion: 0.13
Nodes (14): package:fluttergran/domain/atc/atc_config.dart, package:fluttergran/domain/atc/atc_leg_state.dart, package:fluttergran/domain/atc/atc_stop.dart, package:fluttergran/domain/atc/atc_variant.dart, package:fluttergran/domain/x01/game_config.dart, main, d, dbull (+6 more)

### Community 69 - "worker.md"
Cohesion: 0.50
Nodes (3): Contract, Project, Reporting back

### Community 70 - "_Body"
Cohesion: 0.67
Nodes (4): playerStatsProvider, segmentCountsProvider, _Body, build

### Community 71 - "SettingsScreen"
Cohesion: 0.67
Nodes (4): soundEnabledProvider, speechEnabledProvider, build, SettingsScreen

### Community 74 - "atc_controller_test.dart"
Cohesion: 0.10
Nodes (20): package:fluttergran/app/atc_controller.dart, package:fluttergran/app/game_controller.dart, package:fluttergran/app/providers.dart, ProviderContainer, board, container, controller, main (+12 more)

### Community 81 - "dart"
Cohesion: 0.10
Nodes (22): ../atc_controller.dart, dart, _BoardScoringAlone, _confirmLeave, _DartSlot, leg, _LegWon, live (+14 more)

### Community 82 - "atc_controller.dart"
Cohesion: 0.11
Nodes (17): ../../domain/atc/atc_leg_state.dart, ../../domain/atc/atc_reducer.dart, ../../domain/x01/thrown_dart.dart, acknowledgedTurns, addDart, AtcSession, awaitingTurnConfirm, confirmTurn (+9 more)

### Community 83 - "currentGameIdProvider"
Cohesion: 0.13
Nodes (22): _persist, _persist, _persist, legSettled, resumeFrom, start, atcGameProvider, currentGameIdProvider (+14 more)

### Community 84 - "atc_setup_screen.dart"
Cohesion: 0.12
Nodes (16): ../../data/db/database.dart, ../../domain/atc/atc_config.dart, ../../domain/atc/atc_variant.dart, atcVariantLabel, createState, dispose, _Eyebrow, label (+8 more)

### Community 85 - "atc_stop.dart"
Cohesion: 0.15
Nodes (12): AtcStop, _bull, clears, label, number, _numbered, ring, toString (+4 more)

### Community 86 - "reconnect_delay_test.dart"
Cohesion: 0.22
Nodes (8): package:fluttergran/data/board/ble_board_source.dart, FixedRandom, main, nextBool, nextDouble, nextInt, _scanCooldownTests, value

### Community 87 - "bulling_controller.dart"
Cohesion: 0.11
Nodes (17): ../data/db/game_repository.dart, ../../domain/bulling/bulling_leg_state.dart, ../../domain/bulling/bulling_reducer.dart, acknowledgedTurns, addDart, awaitingTurnConfirm, BullingSession, confirmTurn (+9 more)

### Community 88 - "Around the Clock — design"
Cohesion: 0.20
Nodes (9): Around the Clock — design, Domain (`lib/domain/atc/`), Out of scope for this pass, Persistence, Rules, precisely, Stats (`lib/domain/stats/atc_stats.dart`, `part of 'mode_stats.dart'`), Summary, Testing (+1 more)

### Community 89 - "bulling_reducer_test.dart"
Cohesion: 0.15
Nodes (12): AssertionError, package:fluttergran/domain/bulling/bulling_config.dart, package:fluttergran/domain/bulling/bulling_reducer.dart, package:fluttergran/domain/bulling/bulling_variant.dart, main, config, dbull, main (+4 more)

### Community 90 - "Connection lifecycle"
Cohesion: 0.50
Nodes (4): A forgiving characteristic lookup, Connection lifecycle, Reconnecting without scanning, Services are rediscovered every time

### Community 91 - "CustomPainter"
Cohesion: 0.67
Nodes (3): CustomPainter, _TallyPainter, _BoardPainter

### Community 92 - "List"
Cohesion: 0.13
Nodes (13): atc_variant.dart, bulling_variant.dart, playerIds, variant, AtcVariant, bullseyeValue, offeredTargets, playerIds (+5 more)

### Community 93 - "widget_test.dart"
Cohesion: 0.14
Nodes (13): package:fluttergran/main.dart, closeApp, database, launch, main, openX01Setup, popRoute, pump (+5 more)

### Community 94 - "atc_reducer.dart"
Cohesion: 0.15
Nodes (12): atc_config.dart, atc_leg_state.dart, atc_stop.dart, foldAroundTheClock, initialAtcLegState, playerIndex, stopIndex, turnDarts (+4 more)

### Community 95 - "bulling_reducer.dart"
Cohesion: 0.15
Nodes (12): bulling_config.dart, bulling_leg_state.dart, foldBulling, initialBullingLegState, playerIndex, pointsFor, score, turnDarts (+4 more)

### Community 96 - "bulling_stats_test.dart"
Cohesion: 0.17
Nodes (10): package:fluttergran/domain/bulling/bulling_leg_state.dart, package:fluttergran/domain/game_mode.dart, package:fluttergran/domain/stats/player_stats.dart, dbull, leg, main, miss, sbull (+2 more)

### Community 97 - "bulling_controller_test.dart"
Cohesion: 0.18
Nodes (10): ThrownDart, package:fluttergran/app/bulling_controller.dart, board, container, controller, dbull, main, sbull (+2 more)

### Community 98 - "select_game_mode_screen_test.dart"
Cohesion: 0.18
Nodes (10): package:fluttergran/app/screens/atc_setup_screen.dart, package:fluttergran/app/screens/bulling_setup_screen.dart, package:fluttergran/app/screens/select_game_mode_screen.dart, package:fluttergran/app/screens/x01_setup_screen.dart, board, container, database, main (+2 more)

### Community 99 - "atc_reducer_test.dart"
Cohesion: 0.20
Nodes (9): package:fluttergran/domain/atc/atc_reducer.dart, config, d, dbull, main, miss, s, sbull (+1 more)

### Community 100 - "package:fluttergran/domain/x01/thrown_dart.dart"
Cohesion: 0.20
Nodes (9): package:fluttergran/domain/x01/thrown_dart.dart, config, d, dbull, main, miss, s, sbull (+1 more)

### Community 101 - "roster_screen_test.dart"
Cohesion: 0.22
Nodes (8): package:fluttergran/app/screens/roster_screen.dart, close, container, database, frames, main, open, repository

### Community 102 - "AppDatabase"
Cohesion: 0.29
Nodes (7): _, @DriftDatabase, AppDatabase, _SchemaV2, _SchemaV4, _SchemaV5, _SchemaV6

### Community 103 - "board_geometry_test.dart"
Cohesion: 0.29
Nodes (6): dart:math, angle, at, hit, main, radius

### Community 104 - "board_widget_test.dart"
Cohesion: 0.29
Nodes (6): package:fluttergran/app/widgets/board_widget.dart, return, main, pumpBoardIn, pumpWidget, tapped

### Community 105 - "int get"
Cohesion: 0.40
Nodes (4): int get, points, three, two,

### Community 106 - "ModeStats"
Cohesion: 0.50
Nodes (4): AtcStats, BullingStats, X01Stats, ModeStats

## Knowledge Gaps
- **1223 isolated node(s):** `XCTest`, `leg`, `acknowledgedTurns`, `awaitingTurnConfirm`, `pendingTurn` (+1218 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `dart` connect `dart` to `bulling_controller_test.dart`, `_`, `leg_state.dart`, `package:flutter_riverpod/flutter_riverpod.dart`, `ModeStats`, `int?`, `dart_keypad.dart`, `match_state.dart`, `main.dart`, `../providers.dart`, `game_controller.dart`, `atc_controller.dart`, `Map`, `dart`, `boardConnectionProvider`, `match_controller.dart`, `List`?**
  _High betweenness centrality (0.076) - this node is a cross-community bridge._
- **Why does `AppDatabase` connect `AppDatabase` to `database.dart`, `select_game_mode_screen_test.dart`, `splash_screen_test.dart`, `end_screen_test.dart`, `roster_screen_test.dart`, `providers.dart`, `package:flutter_test/flutter_test.dart`, `package:flutter_riverpod/flutter_riverpod.dart`, `game_repository.dart`, `persistence_test.dart`, `widget_test.dart`, `resumable_leg_provider_test.dart`, `responsive_layout_test.dart`?**
  _High betweenness centrality (0.053) - this node is a cross-community bridge._
- **Why does `_` connect `_` to `board_widget_test.dart`, `frame_assembler.dart`, `int get`, `sound_controller_test.dart`, `List`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._
- **What connects `XCTest`, `leg`, `acknowledgedTurns` to the rest of the system?**
  _1223 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.017857142857142856 - nodes in this community are weakly interconnected._
- **Should `theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.04081632653061224 - nodes in this community are weakly interconnected._
- **Should `checkout_search.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._