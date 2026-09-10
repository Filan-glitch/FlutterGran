# Graph Report - FlutterGran  (2026-09-08)

## Corpus Check
- 110 files · ~110,957 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1664 nodes · 2467 edges · 93 communities (88 shown, 5 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 4 edges (avg confidence: 0.5)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `bd81f859`
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
- atc_widget_test.dart
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
- board_event.dart
- sound_player.dart
- MainMenuScreen
- match_controller.dart
- make_icon.py
- AppDelegate
- stats_screen.dart
- make_cues.py
- roster_screen.dart
- package:flutter_test/flutter_test.dart
- x01_setup_screen.dart
- responsive_layout_test.dart
- playersProvider
- Connectivity
- FakeBoardSource
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
- DataClass
- Development
- main.dart
- Data model
- package:flutter/material.dart
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
- atc_leg_state.dart
- Chalk
- Table
- segment_codec.dart
- GameController
- package:fluttergran/domain/segment.dart
- worker.md
- _Body
- SettingsScreen
- MainActivity
- LaunchImage.imageset/README.md
- resumable_leg_provider_test.dart
- bool?
- Random
- dart
- atc_controller.dart
- gameRepositoryProvider
- atc_setup_screen.dart
- atc_stop.dart
- reconnect_delay_test.dart
- package:flutter_riverpod/flutter_riverpod.dart
- Around the Clock — design
- settings_screen_test.dart
- Connection lifecycle
- CustomPainter
- AtcVariant

## God Nodes (most connected - your core abstractions)
1. `dart` - 69 edges
2. `_` - 48 edges
3. `dart` - 45 edges
4. `gameRepositoryProvider` - 21 edges
5. `AppDatabase` - 20 edges
6. `FakeBoardSource` - 19 edges
7. `currentGameIdProvider` - 18 edges
8. `Connectivity` - 12 edges
9. `MainMenuScreen` - 11 edges
10. `GameScreen` - 10 edges

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

## Communities (93 total, 5 thin omitted)

### Community 0 - "database.dart"
Cohesion: 0.02
Nodes (105): BoolColumn get, ColumnFilters, ColumnOrderings, ColumnWithTypeConverterFilters, DateTimeColumn get, GeneratedColumn, GeneratedColumnWithTypeConverter, GeneratedDatabase (+97 more)

### Community 1 - "theme.dart"
Cohesion: 0.04
Nodes (48): ColorScheme, 1, base, body, brand, build, buildTheme, chalk (+40 more)

### Community 2 - "checkout_search.dart"
Cohesion: 0.07
Nodes (25): _byValue, CheckoutRoute, _compare, cost, darts, findCheckouts, finish, _finishCost (+17 more)

### Community 3 - "ble_board_source.dart"
Cohesion: 0.05
Nodes (41): BluetoothDevice?, BluetoothDevice? get, _attempt, _attemptConnect, connect, connectionState, _current, currentState (+33 more)

### Community 4 - "_"
Cohesion: 0.05
Nodes (42): ../game_controller.dart, _, after, afterBustCue, afterCheckoutCue, afterOneEightyCue, asset, before (+34 more)

### Community 5 - "player_stats_test.dart"
Cohesion: 0.10
Nodes (19): package:fluttergran/domain/stats/player_stats.dart, package:fluttergran/domain/x01/leg_reducer.dart, package:fluttergran/domain/x01/leg_state.dart, package:fluttergran/domain/x01/thrown_dart.dart, config, d, dbull, main (+11 more)

### Community 6 - "leg_state.dart"
Cohesion: 0.05
Nodes (36): game_config.dart, leg_state.dart, foldLeg, initialLegState, playerIndex, remaining, turnDarts, turns (+28 more)

### Community 7 - "providers.dart"
Cohesion: 0.05
Nodes (39): audio/sound_controller.dart, audio/sound_player.dart, ../data/board/ble_board_source.dart, ../data/board/segment_codec.dart, ../domain/checkout/checkout_table.dart, allAtcLegsProvider, allLegsProvider, allMatchesProvider (+31 more)

### Community 8 - "atc_widget_test.dart"
Cohesion: 0.05
Nodes (34): package:flutter/services.dart, package:fluttergran/app/widgets/dart_keypad.dart, package:fluttergran/main.dart, highlight, main, pumpKeypad, pumpWidget, closeApp (+26 more)

### Community 9 - "main_menu_screen_test.dart"
Cohesion: 0.08
Nodes (27): package:drift/native.dart, package:fluttergran/app/screens/atc_game_screen.dart, package:fluttergran/app/screens/atc_setup_screen.dart, package:fluttergran/app/screens/main_menu_screen.dart, package:fluttergran/app/screens/select_game_mode_screen.dart, package:fluttergran/app/screens/splash_screen.dart, package:fluttergran/app/screens/stats_screen.dart, package:fluttergran/app/screens/x01_setup_screen.dart (+19 more)

### Community 10 - "board_widget.dart"
Cohesion: 0.06
Nodes (33): Color, _black, BoardGeometry, boardWedgeOrder, build, _cream, doubleInner, doubleOuter (+25 more)

### Community 11 - "game_repository.dart"
Cohesion: 0.05
Nodes (38): database.dart, addPlayer, allPlayers, appendDart, _aroundTheClock, db, deleteEmptyGames, deleteGame (+30 more)

### Community 12 - "dart"
Cohesion: 0.06
Nodes (32): ../../domain/checkout/checkout_search.dart, ../../domain/stats/player_stats.dart, double?, dart, average, child, _confirmLeave, _decimal (+24 more)

### Community 13 - "mode_stats.dart"
Cohesion: 0.06
Nodes (37): double? get, AtcStats, average, bestCheckout, bestTurn, checkoutRate, dartsAtDouble, doublesHit (+29 more)

### Community 14 - "player_stats.dart"
Cohesion: 0.06
Nodes (33): ../atc/atc_leg_state.dart, ../atc/atc_stop.dart, ../game_mode.dart, Iterable, atcLegs, bestCheckout, bestTurn, computeAtcStats (+25 more)

### Community 15 - "match_state.dart"
Cohesion: 0.07
Nodes (26): GameConfig? get, config, counted, doubleOut, foldMatch, formatLabel, isFinished, isHeadToHead (+18 more)

### Community 16 - "migration_test.dart"
Cohesion: 0.07
Nodes (28): _, @DriftDatabase, Directory, File, AppDatabase, MigrationStrategy get, d, directory (+20 more)

### Community 17 - "fake_board_source.dart"
Cohesion: 0.08
Nodes (24): board_source.dart, BoardConnectionState, connect, connectionState, _current, currentState, disconnect, dispose (+16 more)

### Community 18 - "game_controller.dart"
Cohesion: 0.11
Nodes (18): ../../domain/x01/leg_reducer.dart, ../../domain/x01/leg_state.dart, acknowledgedTurns, addDart, awaitingTurnConfirm, confirmTurn, GameSession, handleBoardEvent (+10 more)

### Community 19 - "board_source.dart"
Cohesion: 0.08
Nodes (25): BoardConnectionState get, disconnected,
  scanning,
  connecting,, frame_assembler.dart, BleBoardSource, assembler, BoardSource, codec, connect (+17 more)

### Community 20 - "board_event.dart"
Cohesion: 0.22
Nodes (12): BoardEvent, BoardMiss, body, ButtonPress, DartHit, segment, toString, UnknownFrame (+4 more)

### Community 21 - "sound_player.dart"
Cohesion: 0.09
Nodes (22): AudioPlayer, SoundPlayer, AudioPlayersSoundPlayer, _cues, dispose, _disposed, _fire, _live (+14 more)

### Community 22 - "MainMenuScreen"
Cohesion: 0.25
Nodes (16): ConsumerWidget, boardConnectionProvider, decidedMatchLegsProvider, gameProvider, matchProvider, matchStateProvider, playerNamesProvider, resumableLegProvider (+8 more)

### Community 23 - "match_controller.dart"
Cohesion: 0.13
Nodes (15): ../../domain/x01/game_config.dart, ../../domain/x01/match_state.dart, int?, build, config, decidedLegs, leave, MatchController (+7 more)

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

### Community 29 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.07
Nodes (28): GameRepository, package:flutter_test/flutter_test.dart, package:fluttergran/app/screens/roster_screen.dart, package:fluttergran/data/db/database.dart, package:fluttergran/data/db/game_repository.dart, database, main, repository (+20 more)

### Community 30 - "x01_setup_screen.dart"
Cohesion: 0.12
Nodes (16): ../../data/db/database.dart, createState, dispose, _Eyebrow, _headToHead, _legsToPlay, _newPlayer, onTap (+8 more)

### Community 31 - "responsive_layout_test.dart"
Cohesion: 0.11
Nodes (17): board, container, database, dispose, frames, main, openAt, phoneLandscape (+9 more)

### Community 32 - "playersProvider"
Cohesion: 0.19
Nodes (14): ConsumerState, ConsumerStatefulWidget, playersProvider, AtcSetupScreen, build, build, RosterScreen, _RosterScreenState (+6 more)

### Community 33 - "Connectivity"
Cohesion: 0.15
Nodes (13): Android, Connecting from the app, Connectivity, GATT, iOS, Licensing note, Permissions, Playing without a board (+5 more)

### Community 34 - "FakeBoardSource"
Cohesion: 0.08
Nodes (25): Batch, Duplicate, GreetingGluedTo, BoardReader, FakeBoardSource, Miss, package:fluttergran/app/game_controller.dart, package:fluttergran/data/board/board_source.dart (+17 more)

### Community 35 - "main_menu_screen.dart"
Cohesion: 0.12
Nodes (15): atc_game_screen.dart, game_screen.dart, IconData, icon, label, _MenuRow, names, onResume (+7 more)

### Community 36 - "sound_controller_test.dart"
Cohesion: 0.12
Nodes (15): package:fluttergran/app/audio/sound_controller.dart, at, config, cues, d, dispose, main, miss (+7 more)

### Community 37 - "end_screen_test.dart"
Cohesion: 0.10
Nodes (18): package:fluttergran/app/screens/game_screen.dart, package:fluttergran/domain/x01/match_state.dart, board, checkout, container, d, database, dispose (+10 more)

### Community 38 - "splash_screen.dart"
Cohesion: 0.18
Nodes (11): build, _ChalkMark, createState, initState, paint, _proceed, shouldRepaint, SplashScreen (+3 more)

### Community 39 - "StatelessWidget"
Cohesion: 0.13
Nodes (15): _CheckoutPanel, _CheckoutStrip, _DartSlot, _Figure, _FitOrScroll, _HeroPlayerCard, _LegWon, _MatchFigures (+7 more)

### Community 40 - "segment.dart"
Cohesion: 0.15
Nodes (12): all, hashCode, innerBull, isDouble, label, multiplier, number, operator (+4 more)

### Community 41 - "frame_assembler.dart"
Cohesion: 0.14
Nodes (13): Duration, _buffer, dedupeWindow, feed, FrameAssembler, _greeting, _isRepeat, _lastAt (+5 more)

### Community 42 - "dart_keypad.dart"
Cohesion: 0.13
Nodes (15): build, createState, DartKeypad, _DartKeypadState, _enter, highlight, highlighted, _isHighlighted (+7 more)

### Community 43 - "persistence_test.dart"
Cohesion: 0.14
Nodes (13): package:drift/drift.dart, board, container, controller, d, database, gameId, main (+5 more)

### Community 44 - "thrown_dart.dart"
Cohesion: 0.17
Nodes (11): bool get, int get, hashCode, isDouble, label, miss, operator, segment (+3 more)

### Community 45 - "DataClass"
Cohesion: 0.23
Nodes (15): DataClass, AtcGame, AtcGamesCompanion, DartEvent, DartEventsCompanion, Game, GamesCompanion, GameSeat (+7 more)

### Community 46 - "Development"
Cohesion: 0.17
Nodes (12): Commands, Conventions, Dependency constraints, learned the hard way, Development, Generated assets, Running on a device, Setup, Test layout (+4 more)

### Community 47 - "main.dart"
Cohesion: 0.14
Nodes (15): app/screens/splash_screen.dart, app/theme.dart, _PlayerTile, _PlayerTileState, build, child, createState, FlutterGranApp (+7 more)

### Community 48 - "Data model"
Cohesion: 0.18
Nodes (11): `DartEvents` — every dart, Data model, `Games` — one leg, `GameSeats` — who sat where, `Matches` — a run of legs, Migrations, `Players`, Reading it back (+3 more)

### Community 49 - "package:flutter/material.dart"
Cohesion: 0.14
Nodes (12): detail, enabled, _Eyebrow, label, onChanged, _SoundToggle, text, value (+4 more)

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
Cohesion: 0.14
Nodes (14): Architecture, Audio, Checkouts, Everything is a fold, Game modes, Layout, Matches, Screens (+6 more)

### Community 54 - "The board protocol"
Cohesion: 0.22
Nodes (9): Connection lifecycle, Decoding, Frame assembly, Hardware day (2026-09-04) — resolved, In one paragraph, Playing without a board, The board protocol, The pipeline (+1 more)

### Community 55 - "select_game_mode_screen.dart"
Cohesion: 0.17
Nodes (11): atc_setup_screen.dart, ../../domain/game_mode.dart, build, _ComingSoonTile, _icons, mode, modes, _ModeTile (+3 more)

### Community 56 - "List"
Cohesion: 0.14
Nodes (12): atc_variant.dart, playerIds, variant, displayName, GameMode, GameModeDescriptor, gameModeRegistry, id (+4 more)

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

### Community 62 - "atc_leg_state.dart"
Cohesion: 0.06
Nodes (35): atc_config.dart, atc_leg_state.dart, atc_stop.dart, AtcTurn? get, AtcLegState, AtcTurn, config, currentPlayerId (+27 more)

### Community 63 - "Chalk"
Cohesion: 0.25
Nodes (8): Chalk, Documentation, Generated assets, How it is put together, Licence notes, Quick start, Testing, What it does

### Community 64 - "Table"
Cohesion: 0.25
Nodes (8): @DataClassName, AtcGames, DartEvents, Games, GameSeats, Matches, Players, Table

### Community 66 - "segment_codec.dart"
Cohesion: 0.29
Nodes (6): ../../domain/board_event.dart, granboard_segment_map.dart, _base, decode, knows, SegmentCodec

### Community 67 - "GameController"
Cohesion: 0.20
Nodes (14): AtcController, build, build, GameController, AtcConfigController, boardEventsProvider, BoolSetting, GameConfigController (+6 more)

### Community 68 - "package:fluttergran/domain/segment.dart"
Cohesion: 0.07
Nodes (31): dart:io, ThrownDart, package:fluttergran/data/board/granboard_segment_map.dart, package:fluttergran/domain/atc/atc_leg_state.dart, package:fluttergran/domain/atc/atc_reducer.dart, package:fluttergran/domain/atc/atc_stop.dart, package:fluttergran/domain/atc/atc_variant.dart, package:fluttergran/domain/game_mode.dart (+23 more)

### Community 69 - "worker.md"
Cohesion: 0.50
Nodes (3): Contract, Project, Reporting back

### Community 70 - "_Body"
Cohesion: 0.67
Nodes (4): playerStatsProvider, segmentCountsProvider, _Body, build

### Community 71 - "SettingsScreen"
Cohesion: 0.67
Nodes (4): soundEnabledProvider, speechEnabledProvider, build, SettingsScreen

### Community 74 - "resumable_leg_provider_test.dart"
Cohesion: 0.09
Nodes (21): AssertionError, package:fluttergran/app/atc_controller.dart, package:fluttergran/app/providers.dart, package:fluttergran/domain/atc/atc_config.dart, package:fluttergran/domain/x01/game_config.dart, ProviderContainer, board, container (+13 more)

### Community 81 - "dart"
Cohesion: 0.10
Nodes (22): ../atc_controller.dart, dart, _BoardScoringAlone, _confirmLeave, _DartSlot, leg, _LegWon, live (+14 more)

### Community 82 - "atc_controller.dart"
Cohesion: 0.11
Nodes (18): ../data/db/game_repository.dart, ../../domain/atc/atc_leg_state.dart, ../../domain/atc/atc_reducer.dart, ../../domain/x01/thrown_dart.dart, acknowledgedTurns, addDart, AtcSession, awaitingTurnConfirm (+10 more)

### Community 83 - "gameRepositoryProvider"
Cohesion: 0.17
Nodes (19): _persist, _persist, legSettled, _openLeg, resumeFrom, start, atcConfigProvider, atcGameProvider (+11 more)

### Community 84 - "atc_setup_screen.dart"
Cohesion: 0.11
Nodes (17): ../../domain/atc/atc_config.dart, ../../domain/atc/atc_variant.dart, atcVariantLabel, createState, dispose, _Eyebrow, label, _newPlayer (+9 more)

### Community 85 - "atc_stop.dart"
Cohesion: 0.17
Nodes (11): AtcStop, _bull, clears, label, number, _numbered, ring, toString (+3 more)

### Community 86 - "reconnect_delay_test.dart"
Cohesion: 0.20
Nodes (9): dart:math, package:fluttergran/data/board/ble_board_source.dart, FixedRandom, main, nextBool, nextDouble, nextInt, _scanCooldownTests (+1 more)

### Community 87 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.24
Nodes (9): ../../data/board/board_source.dart, boardSourceProvider, _attempted, _BoardConnectionButtonState, build, createState, _toggle, package:flutter_riverpod/flutter_riverpod.dart (+1 more)

### Community 88 - "Around the Clock — design"
Cohesion: 0.20
Nodes (9): Around the Clock — design, Domain (`lib/domain/atc/`), Out of scope for this pass, Persistence, Rules, precisely, Stats (`lib/domain/stats/atc_stats.dart`, `part of 'mode_stats.dart'`), Summary, Testing (+1 more)

### Community 89 - "settings_screen_test.dart"
Cohesion: 0.25
Nodes (7): dart:async, package:fluttergran/app/screens/settings_screen.dart, Switch, container, main, pump, switches

### Community 90 - "Connection lifecycle"
Cohesion: 0.50
Nodes (4): A forgiving characteristic lookup, Connection lifecycle, Reconnecting without scanning, Services are rediscovered every time

### Community 91 - "CustomPainter"
Cohesion: 0.67
Nodes (3): CustomPainter, _TallyPainter, _BoardPainter

## Knowledge Gaps
- **1073 isolated node(s):** `XCTest`, `leg`, `acknowledgedTurns`, `awaitingTurnConfirm`, `pendingTurn` (+1068 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `dart` connect `dart` to `_`, `package:fluttergran/domain/segment.dart`, `leg_state.dart`, `StatelessWidget`, `splash_screen.dart`, `dart_keypad.dart`, `mode_stats.dart`, `match_state.dart`, `main.dart`, `package:flutter/material.dart`, `game_controller.dart`, `atc_controller.dart`, `Map`, `dart`, `MainMenuScreen`, `match_controller.dart`, `List`, `package:flutter_riverpod/flutter_riverpod.dart`?**
  _High betweenness centrality (0.094) - this node is a cross-community bridge._
- **Why does `AppDatabase` connect `migration_test.dart` to `database.dart`, `end_screen_test.dart`, `providers.dart`, `atc_widget_test.dart`, `main_menu_screen_test.dart`, `resumable_leg_provider_test.dart`, `game_repository.dart`, `persistence_test.dart`, `package:flutter_test/flutter_test.dart`, `responsive_layout_test.dart`?**
  _High betweenness centrality (0.062) - this node is a cross-community bridge._
- **Why does `_` connect `_` to `checkout_search.dart`, `frame_assembler.dart`, `thrown_dart.dart`, `sound_player.dart`, `game_config.dart`?**
  _High betweenness centrality (0.049) - this node is a cross-community bridge._
- **What connects `XCTest`, `leg`, `acknowledgedTurns` to the rest of the system?**
  _1073 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.018867924528301886 - nodes in this community are weakly interconnected._
- **Should `theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.04081632653061224 - nodes in this community are weakly interconnected._
- **Should `checkout_search.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.07407407407407407 - nodes in this community are weakly interconnected._