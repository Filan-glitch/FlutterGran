# Graph Report - FlutterGran  (2026-09-07)

## Corpus Check
- 92 files · ~99,413 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1427 nodes · 2029 edges · 81 communities (76 shown, 5 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 4 edges (avg confidence: 0.5)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `8d95853c`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- database.dart
- theme.dart
- checkout_search.dart
- ble_board_source.dart
- _
- package:fluttergran/domain/segment.dart
- leg_state.dart
- providers.dart
- package:flutter/material.dart
- main_menu_screen_test.dart
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
- sound_player.dart
- currentGameIdProvider
- match_controller.dart
- make_icon.py
- AppDelegate
- stats_screen.dart
- make_cues.py
- roster_screen.dart
- roster_screen_test.dart
- x01_setup_screen.dart
- responsive_layout_test.dart
- playersProvider
- Connectivity
- package:flutter_riverpod/flutter_riverpod.dart
- main_menu_screen.dart
- sound_controller_test.dart
- end_screen_test.dart
- splash_screen.dart
- StatelessWidget
- segment.dart
- frame_assembler.dart
- dart_keypad.dart
- persistence_test.dart
- thrown_dart.dart
- Player
- Development
- main.dart
- Data model
- settings_screen.dart
- granboard_segment_map.dart
- Map
- frame_assembler_test.dart
- Architecture
- The board protocol
- select_game_mode_screen.dart
- List
- game_config.dart
- checkout_search_test.dart
- main
- fluttergran
- The GranBoard 132
- _PlayerTile
- Chalk
- Table
- segment_codec.dart
- int?
- The domain in detail
- worker.md
- _Body
- SettingsScreen
- MainActivity
- LaunchImage.imageset/README.md
- BoardSource
- bool?
- Random

## God Nodes (most connected - your core abstractions)
1. `dart` - 69 edges
2. `_` - 48 edges
3. `FakeBoardSource` - 17 edges
4. `AppDatabase` - 16 edges
5. `gameRepositoryProvider` - 14 edges
6. `Connectivity` - 12 edges
7. `currentGameIdProvider` - 11 edges
8. `GameScreen` - 10 edges
9. `build` - 10 edges
10. `GameController` - 9 edges

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

## Communities (81 total, 5 thin omitted)

### Community 0 - "database.dart"
Cohesion: 0.02
Nodes (102): BoolColumn get, ColumnFilters, ColumnOrderings, ColumnWithTypeConverterFilters, DateTimeColumn get, GeneratedColumn, GeneratedColumnWithTypeConverter, GeneratedDatabase (+94 more)

### Community 1 - "theme.dart"
Cohesion: 0.04
Nodes (48): ColorScheme, 1, base, body, brand, build, buildTheme, chalk (+40 more)

### Community 2 - "checkout_search.dart"
Cohesion: 0.05
Nodes (39): dart:math, _byValue, CheckoutRoute, _compare, cost, darts, findCheckouts, finish (+31 more)

### Community 3 - "ble_board_source.dart"
Cohesion: 0.05
Nodes (41): BluetoothDevice?, BluetoothDevice? get, _attempt, _attemptConnect, connect, connectionState, _current, currentState (+33 more)

### Community 4 - "_"
Cohesion: 0.05
Nodes (42): ../game_controller.dart, _, after, afterBustCue, afterCheckoutCue, afterOneEightyCue, asset, before (+34 more)

### Community 5 - "package:fluttergran/domain/segment.dart"
Cohesion: 0.06
Nodes (32): dart:io, package:fluttergran/data/board/granboard_segment_map.dart, package:fluttergran/domain/game_mode.dart, package:fluttergran/domain/segment.dart, package:fluttergran/domain/x01/game_config.dart, package:fluttergran/domain/x01/leg_reducer.dart, package:fluttergran/domain/x01/leg_state.dart, package:fluttergran/domain/x01/match_state.dart (+24 more)

### Community 6 - "leg_state.dart"
Cohesion: 0.05
Nodes (36): game_config.dart, leg_state.dart, foldLeg, initialLegState, playerIndex, remaining, turnDarts, turns (+28 more)

### Community 7 - "providers.dart"
Cohesion: 0.06
Nodes (35): audio/sound_controller.dart, audio/sound_player.dart, ../data/board/ble_board_source.dart, ../data/board/segment_codec.dart, ../domain/checkout/checkout_table.dart, allLegsProvider, allMatchesProvider, boardReaderProvider (+27 more)

### Community 8 - "package:flutter/material.dart"
Cohesion: 0.07
Nodes (32): dart:async, package:flutter/material.dart, package:flutter_test/flutter_test.dart, package:fluttergran/app/providers.dart, package:fluttergran/app/screens/settings_screen.dart, package:fluttergran/app/theme.dart, package:fluttergran/app/widgets/dart_keypad.dart, package:fluttergran/main.dart (+24 more)

### Community 9 - "main_menu_screen_test.dart"
Cohesion: 0.07
Nodes (32): Batch, Duplicate, GreetingGluedTo, FakeBoardSource, Miss, package:drift/native.dart, package:fluttergran/app/screens/main_menu_screen.dart, package:fluttergran/app/screens/select_game_mode_screen.dart (+24 more)

### Community 10 - "board_widget.dart"
Cohesion: 0.06
Nodes (33): Color, _black, BoardGeometry, boardWedgeOrder, build, _cream, doubleInner, doubleOuter (+25 more)

### Community 11 - "game_repository.dart"
Cohesion: 0.06
Nodes (32): database.dart, addPlayer, allPlayers, appendDart, db, deleteEmptyGames, deleteGame, findResumableGameId (+24 more)

### Community 12 - "dart"
Cohesion: 0.06
Nodes (33): ../../domain/checkout/checkout_search.dart, ../../domain/stats/player_stats.dart, double?, dart, average, child, _confirmLeave, _decimal (+25 more)

### Community 13 - "mode_stats.dart"
Cohesion: 0.07
Nodes (28): double? get, average, bestCheckout, bestTurn, checkoutRate, dartsAtDouble, dartsThrown, doublesHit (+20 more)

### Community 14 - "player_stats.dart"
Cohesion: 0.07
Nodes (27): ../game_mode.dart, Iterable, bestCheckout, bestTurn, computePlayerStats, computeX01Stats, dartsAtDouble, dartsThrown (+19 more)

### Community 15 - "match_state.dart"
Cohesion: 0.07
Nodes (26): GameConfig? get, config, counted, doubleOut, foldMatch, formatLabel, isFinished, isHeadToHead (+18 more)

### Community 16 - "migration_test.dart"
Cohesion: 0.08
Nodes (25): _, @DriftDatabase, Directory, File, AppDatabase, MigrationStrategy get, d, directory (+17 more)

### Community 17 - "fake_board_source.dart"
Cohesion: 0.08
Nodes (24): board_source.dart, connect, connectionState, _current, currentState, disconnect, dispose, emitBatch (+16 more)

### Community 18 - "game_controller.dart"
Cohesion: 0.09
Nodes (24): ../data/db/game_repository.dart, ../../domain/x01/leg_reducer.dart, ../../domain/x01/leg_state.dart, ../../domain/x01/thrown_dart.dart, acknowledgedTurns, addDart, awaitingTurnConfirm, build (+16 more)

### Community 19 - "board_source.dart"
Cohesion: 0.08
Nodes (23): BoardConnectionState get, disconnected,
  scanning,
  connecting,, frame_assembler.dart, assembler, BoardConnectionState, codec, connect, connected (+15 more)

### Community 20 - "board_reader_test.dart"
Cohesion: 0.12
Nodes (21): BoardReader, BoardEvent, BoardMiss, body, ButtonPress, DartHit, segment, toString (+13 more)

### Community 21 - "sound_player.dart"
Cohesion: 0.09
Nodes (22): AudioPlayer, SoundPlayer, AudioPlayersSoundPlayer, _cues, dispose, _disposed, _fire, _live (+14 more)

### Community 22 - "currentGameIdProvider"
Cohesion: 0.20
Nodes (21): ConsumerWidget, MatchController, _openLeg, currentGameIdProvider, decidedMatchLegsProvider, gameConfigProvider, gameProvider, matchProvider (+13 more)

### Community 23 - "match_controller.dart"
Cohesion: 0.10
Nodes (20): ../../domain/x01/game_config.dart, ../../domain/x01/match_state.dart, _persist, build, config, decidedLegs, leave, legSettled (+12 more)

### Community 24 - "make_icon.py"
Cohesion: 0.19
Nodes (20): Image, _chalk_polygon(), corner_mask(), _down(), draw_mark(), foreground(), _hex(), main() (+12 more)

### Community 25 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate, Bool (+6 more)

### Community 26 - "stats_screen.dart"
Cohesion: 0.10
Nodes (19): ../../domain/stats/mode_stats.dart, createState, _decimal, detail, _Empty, _Eyebrow, _Headline, label (+11 more)

### Community 27 - "make_cues.py"
Cohesion: 0.25
Nodes (19): Samples, bust(), checkout(), dart(), envelope(), main(), mix(), normalise() (+11 more)

### Community 28 - "roster_screen.dart"
Cohesion: 0.11
Nodes (18): FocusNode, _commit, _controller, createState, didUpdateWidget, dispose, _editing, _focusNode (+10 more)

### Community 29 - "roster_screen_test.dart"
Cohesion: 0.11
Nodes (17): GameRepository, package:fluttergran/app/screens/roster_screen.dart, package:fluttergran/data/db/game_repository.dart, package:fluttergran/domain/stats/player_stats.dart, close, container, database, frames (+9 more)

### Community 30 - "x01_setup_screen.dart"
Cohesion: 0.11
Nodes (17): ../../data/db/database.dart, createState, dispose, _Eyebrow, _headToHead, _legsToPlay, _newPlayer, onTap (+9 more)

### Community 31 - "responsive_layout_test.dart"
Cohesion: 0.11
Nodes (17): board, container, database, dispose, frames, main, openAt, phoneLandscape (+9 more)

### Community 32 - "playersProvider"
Cohesion: 0.17
Nodes (17): ConsumerState, ConsumerStatefulWidget, boardConnectionProvider, boardSourceProvider, playersProvider, build, RosterScreen, _RosterScreenState (+9 more)

### Community 33 - "Connectivity"
Cohesion: 0.12
Nodes (17): A forgiving characteristic lookup, Android, Connecting from the app, Connection lifecycle, Connectivity, GATT, iOS, Licensing note (+9 more)

### Community 34 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.12
Nodes (14): ../../data/board/board_source.dart, _attempted, createState, package:flutter_riverpod/flutter_riverpod.dart, package:fluttergran/app/game_controller.dart, ProviderContainer, board, container (+6 more)

### Community 35 - "main_menu_screen.dart"
Cohesion: 0.12
Nodes (15): game_screen.dart, IconData, ResumableLeg, icon, label, _MenuRow, names, onResume (+7 more)

### Community 36 - "sound_controller_test.dart"
Cohesion: 0.12
Nodes (15): package:fluttergran/app/audio/sound_controller.dart, at, config, cues, d, dispose, main, miss (+7 more)

### Community 37 - "end_screen_test.dart"
Cohesion: 0.12
Nodes (15): package:fluttergran/app/screens/game_screen.dart, board, checkout, container, d, database, dispose, frames (+7 more)

### Community 38 - "splash_screen.dart"
Cohesion: 0.14
Nodes (14): CustomPainter, build, _ChalkMark, createState, initState, paint, _proceed, shouldRepaint (+6 more)

### Community 39 - "StatelessWidget"
Cohesion: 0.13
Nodes (15): _CheckoutPanel, _CheckoutStrip, _DartSlot, _Figure, _FitOrScroll, _HeroPlayerCard, _LegWon, _MatchFigures (+7 more)

### Community 40 - "segment.dart"
Cohesion: 0.13
Nodes (14): all, hashCode, innerBull, isDouble, label, multiplier, number, operator (+6 more)

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
Cohesion: 0.15
Nodes (12): bool get, int get, hashCode, isDouble, label, miss, operator, segment (+4 more)

### Community 45 - "Player"
Cohesion: 0.26
Nodes (13): DataClass, DartEvent, DartEventsCompanion, Game, GamesCompanion, GameSeat, GameSeatsCompanion, Match (+5 more)

### Community 46 - "Development"
Cohesion: 0.17
Nodes (12): Commands, Conventions, Dependency constraints, learned the hard way, Development, Generated assets, Running on a device, Setup, Test layout (+4 more)

### Community 47 - "main.dart"
Cohesion: 0.18
Nodes (10): app/screens/splash_screen.dart, app/theme.dart, build, child, createState, FlutterGranApp, _lockedToLandscape, main (+2 more)

### Community 48 - "Data model"
Cohesion: 0.18
Nodes (11): `DartEvents` — every dart, Data model, `Games` — one leg, `GameSeats` — who sat where, `Matches` — a run of legs, Migrations, `Players`, Reading it back (+3 more)

### Community 49 - "settings_screen.dart"
Cohesion: 0.18
Nodes (10): detail, enabled, _Eyebrow, label, onChanged, _SoundToggle, text, value (+2 more)

### Community 50 - "granboard_segment_map.dart"
Cohesion: 0.20
Nodes (9): ../../domain/segment.dart, buttonCode, granboardSegmentMap, innerBullCode, missCode, outerBullCode, _ringOrder, unusedMatrixSlots (+1 more)

### Community 51 - "Map"
Cohesion: 0.22
Nodes (8): checkout_search.dart, bestFor, _cache, CheckoutTable, isCheckoutRange, limit, routesFor, Map

### Community 52 - "frame_assembler_test.dart"
Cohesion: 0.22
Nodes (8): DateTime, package:fluttergran/data/board/frame_assembler.dart, advance, bytes, call, FakeClock, main, now

### Community 53 - "Architecture"
Cohesion: 0.22
Nodes (9): Architecture, Audio, Everything is a fold, Layout, Screens, The app layer, The keypad and a connected board, Three layers, one rule (+1 more)

### Community 54 - "The board protocol"
Cohesion: 0.22
Nodes (9): Connection lifecycle, Decoding, Frame assembly, Hardware day (2026-09-04) — resolved, In one paragraph, Playing without a board, The board protocol, The pipeline (+1 more)

### Community 55 - "select_game_mode_screen.dart"
Cohesion: 0.22
Nodes (8): ../../domain/game_mode.dart, _ComingSoonTile, _icons, mode, modes, _ModeTile, SelectGameModeScreen, x01_setup_screen.dart

### Community 56 - "List"
Cohesion: 0.22
Nodes (8): displayName, GameMode, GameModeDescriptor, gameModeRegistry, id, isAvailable, tagline, List

### Community 57 - "game_config.dart"
Cohesion: 0.22
Nodes (8): doubleOut, maxPlayers, offeredStartScores, playerIds, startingSeat, startScore, static const int, static const List

### Community 58 - "checkout_search_test.dart"
Cohesion: 0.22
Nodes (7): package:fluttergran/domain/checkout/checkout_search.dart, package:fluttergran/domain/checkout/checkout_table.dart, Set, bogeyNumbers, main, route, main

### Community 59 - "main"
Cohesion: 0.42
Nodes (8): encode(), ensure_voice(), main(), Path, Downloads the voice if it is not already there, and returns the model path., A number as a commentator says it: "one hundred and eighty", not "one eight…, spell(), synthesise()

### Community 60 - "fluttergran"
Cohesion: 0.25
Nodes (7): Board protocol, in one paragraph, Commands, Dependency constraints (learned the hard way), fluttergran, graphify, Hardware day (done), Layering rule

### Community 61 - "The GranBoard 132"
Cohesion: 0.25
Nodes (8): Hardware day (2026-09-04) — done, Non-dart frames, See also, The GranBoard 132, The matrix, The segment table, What is confirmed, and what is not, What kind of device it is

### Community 62 - "_PlayerTile"
Cohesion: 0.32
Nodes (8): _PlayerTile, _PlayerTileState, DartKeypad, _DartKeypadState, _Scaled, _ScaledState, State, StatefulWidget

### Community 63 - "Chalk"
Cohesion: 0.25
Nodes (8): Chalk, Documentation, Generated assets, How it is put together, Licence notes, Quick start, Testing, What it does

### Community 64 - "Table"
Cohesion: 0.29
Nodes (7): @DataClassName, DartEvents, Games, GameSeats, Matches, Players, Table

### Community 66 - "segment_codec.dart"
Cohesion: 0.29
Nodes (6): ../../domain/board_event.dart, granboard_segment_map.dart, _base, decode, knows, SegmentCodec

### Community 67 - "int?"
Cohesion: 0.29
Nodes (7): int?, BoolSetting, CurrentGameId, GameConfigController, KeypadOverrideController, GameConfig, Notifier

### Community 68 - "The domain in detail"
Cohesion: 0.40
Nodes (5): Checkouts, Game modes, Matches, The domain in detail, x01

### Community 69 - "worker.md"
Cohesion: 0.50
Nodes (3): Contract, Project, Reporting back

### Community 70 - "_Body"
Cohesion: 0.67
Nodes (4): playerStatsProvider, segmentCountsProvider, _Body, build

### Community 71 - "SettingsScreen"
Cohesion: 0.67
Nodes (4): soundEnabledProvider, speechEnabledProvider, build, SettingsScreen

## Knowledge Gaps
- **917 isolated node(s):** `XCTest`, `SoundChannel`, `SoundAssets`, `SoundTiming`, `Sound` (+912 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `dart` connect `dart` to `package:flutter_riverpod/flutter_riverpod.dart`, `int?`, `_`, `leg_state.dart`, `StatelessWidget`, `package:flutter/material.dart`, `splash_screen.dart`, `dart_keypad.dart`, `thrown_dart.dart`, `mode_stats.dart`, `match_state.dart`, `main.dart`, `settings_screen.dart`, `game_controller.dart`, `Map`, `currentGameIdProvider`, `match_controller.dart`, `List`?**
  _High betweenness centrality (0.075) - this node is a cross-community bridge._
- **Why does `_` connect `_` to `checkout_search.dart`, `frame_assembler.dart`, `thrown_dart.dart`, `sound_player.dart`, `game_config.dart`?**
  _High betweenness centrality (0.048) - this node is a cross-community bridge._
- **Why does `AppDatabase` connect `migration_test.dart` to `database.dart`, `end_screen_test.dart`, `providers.dart`, `package:flutter/material.dart`, `main_menu_screen_test.dart`, `game_repository.dart`, `persistence_test.dart`, `roster_screen_test.dart`, `responsive_layout_test.dart`?**
  _High betweenness centrality (0.048) - this node is a cross-community bridge._
- **What connects `XCTest`, `SoundChannel`, `SoundAssets` to the rest of the system?**
  _917 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.019417475728155338 - nodes in this community are weakly interconnected._
- **Should `theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.04081632653061224 - nodes in this community are weakly interconnected._
- **Should `checkout_search.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.046511627906976744 - nodes in this community are weakly interconnected._