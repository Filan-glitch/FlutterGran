# Graph Report - higher-lower  (2026-10-26)

## Corpus Check
- 211 files · ~190,766 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 25 file(s) not represented in the graph (top: .xml 9, (none) 5, .properties 2)

## Summary
- 4093 nodes · 6034 edges · 144 communities (128 shown, 16 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 24 edges (avg confidence: 0.87)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `b11a6e82`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- database.g.dart
- theme.dart
- checkout_search.dart
- ble_board_source.dart
- _
- database.dart
- leg_state.dart
- providers.dart
- training_game_screen_test.dart
- responsive_layout_test.dart
- board_widget.dart
- game_repository.dart
- game_screen.dart
- mode_stats.dart
- player_stats.dart
- match_state.dart
- migration_test.dart
- fake_board_source.dart
- led_command.dart
- board_source.dart
- led_cue.dart
- package:flutter_riverpod/flutter_riverpod.dart
- package:flutter_test/flutter_test.dart
- stats_screen.dart
- game_controller.dart
- Win32Window
- higher_lower_leg_state.dart
- make_icon.py
- roster_screen.dart
- persistence_test.dart
- StatelessWidget
- FakeBoardSource
- app_localizations.dart
- Connectivity
- ../theme.dart
- sound_player_test.dart
- bulling_leg_state.dart
- app_localizations_de.dart
- game_over_card.dart
- Bulling Game Mode Implementation Plan
- rule_explorer.dart
- frame_assembler.dart
- dart_keypad.dart
- MaterialPageRoute
- x01_stats.dart
- Player
- Development
- main.dart
- Data model
- board_reader_test.dart
- app_localizations_en.dart
- scoreboard.dart
- DateTime
- Architecture
- The board protocol
- return
- string
- training_setup_screen.dart
- responsive_layout_test.dart
- l10n/app_localizations.dart
- fluttergran
- The GranBoard 132
- atc_leg_state.dart
- Chalk
- Table
- ../../domain/x01/thrown_dart.dart
- rule_board.dart
- mode_layout_test.dart
- worker.md
- resumable_leg_provider_test.dart
- FlutterWindow
- MainActivity
- .Create
- package:fluttergran/domain/segment.dart
- x01_setup_screen.dart
- int?
- widget_test.dart
- string
- currentGameIdProvider
- dart
- free_practice_state.dart
- dart
- utils.cpp
- Around the Clock — design
- higher_lower_controller.dart
- player_picker.dart
- ../l10n_extensions.dart
- Map
- checkout_table.dart
- generated_plugin_registrant.cc
- board_lifecycle.dart
- aim_strip.dart
- bool get
- aim_card.dart
- Releasing
- .MessageHandler
- atc_stop.dart
- higher_lower_reducer.dart
- release-please-config.json
- List
- Point
- check_version.sh
- release_notes.sh
- atc_reducer.dart
- higher_lower_stats.dart
- dart:async
- bulling_stats.dart
- game_config.dart
- higher_lower_sound.dart
- Set
- ModeStats
- match_controller.dart
- sound_player.dart
- led_scheduler_test.dart
- [1.1.0](https://github.com/Filan-glitch/FlutterGran/compare/9be2ca2...v1.1.0) (2026-10-26)
- ConsumerWidget
- int?
- State
- ../theme.dart
- training_controller.dart
- atc_controller.dart
- bulling_controller.dart
- x01_rules.dart
- led_scheduler.dart
- Feature ideas (not yet built)
- game_layout.dart
- main_menu_screen.dart
- AppLocalizations
- Rules section
- lights_providers.dart
- BoardConnectionController
- int get
- TrainingGameScreen
- _FakeAudioPlatform
- _FakeGlobalAudioPlatform
- _FakeAudioCache
- Notifier

## God Nodes (most connected - your core abstractions)
1. `_` - 48 edges
2. `dart` - 42 edges
3. `dart` - 37 edges
4. `currentGameIdProvider` - 32 edges
5. `FakeBoardSource` - 27 edges
6. `AppDatabase` - 27 edges
7. `gameRepositoryProvider` - 24 edges
8. `Win32Window` - 21 edges
9. `Bulling Game Mode Implementation Plan` - 21 edges
10. `_Dart` - 16 edges

## Surprising Connections (you probably didn't know these)
- ``tool/make_speech.py` — the commentary` --references--> `bust()`  [INFERRED]
  docs/DEVELOPMENT.md → tool/make_cues.py
- ``tool/make_cues.py` — the four cues` --references--> `dart()`  [INFERRED]
  docs/DEVELOPMENT.md → tool/make_cues.py
- ``tool/make_cues.py` — the four cues` --references--> `bust()`  [INFERRED]
  docs/DEVELOPMENT.md → tool/make_cues.py
- ``tool/make_cues.py` — the four cues` --references--> `checkout()`  [INFERRED]
  docs/DEVELOPMENT.md → tool/make_cues.py
- ``tool/make_cues.py` — the four cues` --references--> `one_eighty()`  [INFERRED]
  docs/DEVELOPMENT.md → tool/make_cues.py

## Import Cycles
- None detected.

## Communities (144 total, 16 thin omitted)

### Community 0 - "database.g.dart"
Cohesion: 0.03
Nodes (60): _, aliasedName, allTables, atcGamesRefs, copyWith, copyWithCompanion, _createdAtMeta, custom (+52 more)

### Community 1 - "theme.dart"
Cohesion: 0.03
Nodes (72): 1, base, bluetoothAmber, bluetoothBlue, body, brand, build, buildTheme (+64 more)

### Community 2 - "checkout_search.dart"
Cohesion: 0.08
Nodes (22): _byValue, CheckoutRoute, _compare, cost, darts, findCheckouts, finish, _finishCost (+14 more)

### Community 3 - "ble_board_source.dart"
Cohesion: 0.03
Nodes (56): _adapter, _adapterOff, _adapterSubscription, _attempt, _attemptConnect, _boardName, _busy, _cancelReconnect (+48 more)

### Community 4 - "_"
Cohesion: 0.05
Nodes (39): _, after, afterBustCue, afterCheckoutCue, afterOneEightyCue, asset, before, bustCue (+31 more)

### Community 5 - "database.dart"
Cohesion: 0.03
Nodes (42): actualTableName, _alias, allSchemaEntities, attachedDatabase, bullingGamesRefs, _legsToPlayMeta, matchesRefs, _seatMeta (+34 more)

### Community 6 - "leg_state.dart"
Cohesion: 0.07
Nodes (26): averageFor, busted, config, currentPlayerId, currentPlayerIndex, currentRemaining, currentTurnDarts, darts (+18 more)

### Community 7 - "providers.dart"
Cohesion: 0.03
Nodes (50): _perform, allAtcLegsProvider, allBullingLegsProvider, allHigherLowerLegsProvider, allLegsProvider, allMatchesProvider, boardReaderProvider, computePlayerStats (+42 more)

### Community 8 - "training_game_screen_test.dart"
Cohesion: 0.06
Nodes (27): board, container, controller, dispose, main, playCue, player, playSpeech (+19 more)

### Community 9 - "responsive_layout_test.dart"
Cohesion: 0.05
Nodes (37): SoundPlayer, AudioPlayersSoundPlayer, board, checkout, container, d, database, dispose (+29 more)

### Community 10 - "board_widget.dart"
Cohesion: 0.04
Nodes (42): _TallyPainter, _black, BoardGeometry, _BoardPainter, boardWedgeOrder, BoardWidget, build, _cream (+34 more)

### Community 11 - "game_repository.dart"
Cohesion: 0.04
Nodes (45): addPlayer, allPlayers, appendDart, _aroundTheClock, _bulling, db, deleteEmptyGames, deleteGame (+37 more)

### Community 12 - "game_screen.dart"
Cohesion: 0.07
Nodes (19): _clearedThisTurn, _figures, _gain, _movedOn, _figures, _gain, _figures, _legWon (+11 more)

### Community 13 - "mode_stats.dart"
Cohesion: 0.20
Nodes (9): AtcStats, qualifyingDarts, dartsThrown, empty, fewestDartsToWin, hitRate, legsPlayed, legsWon (+1 more)

### Community 14 - "player_stats.dart"
Cohesion: 0.04
Nodes (41): atcLegs, bestCheckout, bestTurn, bullingLegs, checkoutsByRule, computeAtcStats, computeBullingStats, computeHigherLowerStats (+33 more)

### Community 15 - "match_state.dart"
Cohesion: 0.07
Nodes (25): config, counted, foldMatch, formatLabel, inRule, isFinished, isHeadToHead, isMultiLeg (+17 more)

### Community 16 - "migration_test.dart"
Cohesion: 0.06
Nodes (31): AppDatabase, d, directory, file, _gamesAtV2, _gamesAtV4, _gamesAtV5, _gamesSinceV6 (+23 more)

### Community 17 - "fake_board_source.dart"
Cohesion: 0.05
Nodes (41): _adapterOn, _attempt, boardName, connect, connectCalls, connectionState, _current, currentState (+33 more)

### Community 18 - "led_command.dart"
Cohesion: 0.06
Nodes (30): a, b, black, byNumber, c, code, colourOf, effect (+22 more)

### Community 19 - "board_source.dart"
Cohesion: 0.06
Nodes (27): BleBoardSource, assembler, boardName, BoardSource, codec, connect, connectionState, currentState (+19 more)

### Community 20 - "led_cue.dart"
Cohesion: 0.15
Nodes (19): BoardConnected, DartLanded, DartMissed, GameOn, hashCode, kind, LedCue, LedCueKind (+11 more)

### Community 21 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.05
Nodes (34): RulesDetailScreen, build, _ChalkMark, createState, initState, paint, shouldRepaint, RulesBody (+26 more)

### Community 22 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.04
Nodes (45): angle, at, hit, main, radius, contentSizeAt, main, highlight (+37 more)

### Community 23 - "stats_screen.dart"
Cohesion: 0.06
Nodes (24): child, createState, _decimal, detail, _Empty, _FadeIn, _Headline, label (+16 more)

### Community 24 - "game_controller.dart"
Cohesion: 0.11
Nodes (16): acknowledgedTurns, addDart, awaitingTurnConfirm, confirmTurn, endTurn, GameSession, handleBoardEvent, leave (+8 more)

### Community 25 - "Win32Window"
Cohesion: 0.16
Nodes (7): Size, height, width, Win32Window, child_content_, quit_on_close_, window_handle_

### Community 26 - "higher_lower_leg_state.dart"
Cohesion: 0.06
Nodes (29): activePlayerIds, between, config, currentPlayerId, currentPlayerIndex, currentTurnDarts, darts, dartsLeftThisTurn (+21 more)

### Community 27 - "make_icon.py"
Cohesion: 0.06
Nodes (31): Generated assets, `tool/make_cues.py` — the four cues, `tool/make_icon.py` — the launcher icon, `tool/make_speech.py` — the commentary, bust(), checkout(), dart(), envelope() (+23 more)

### Community 28 - "roster_screen.dart"
Cohesion: 0.09
Nodes (21): _addPlayer, _commit, _controller, createState, didUpdateWidget, dispose, _editing, _focusNode (+13 more)

### Community 29 - "persistence_test.dart"
Cohesion: 0.05
Nodes (43): GameRepository, database, main, repository, s, seedAtcGame, database, main (+35 more)

### Community 30 - "StatelessWidget"
Cohesion: 0.04
Nodes (48): AnimatedFigure, CenteredContent, EntrancePop, _aroundTheClock, _AtcRoute, body, build, _bulling (+40 more)

### Community 31 - "FakeBoardSource"
Cohesion: 0.04
Nodes (45): FakeBoardSource, board, clock, container, controller, main, s, session (+37 more)

### Community 32 - "app_localizations.dart"
Cohesion: 0.01
Nodes (301): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+293 more)

### Community 33 - "Connectivity"
Cohesion: 0.12
Nodes (17): A forgiving characteristic lookup, Android, Connecting from the app, Connection lifecycle, Connectivity, GATT, Licensing note, Permissions (+9 more)

### Community 34 - "../theme.dart"
Cohesion: 0.07
Nodes (25): _bestDart, BoundsCard, boundsCardKey, _BoundTile, build, dartsLeft, figure, hero (+17 more)

### Community 35 - "sound_player_test.dart"
Cohesion: 0.05
Nodes (37): binding, create, dispose, emitError, emitGlobalError, emitGlobalLog, emitLog, _events (+29 more)

### Community 36 - "bulling_leg_state.dart"
Cohesion: 0.09
Nodes (20): BullingTurn, config, currentPlayerId, currentPlayerIndex, currentTurnDarts, darts, dartsLeftThisTurn, dartsThrownBy (+12 more)

### Community 37 - "app_localizations_de.dart"
Cohesion: 0.01
Nodes (293): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+285 more)

### Community 38 - "game_over_card.dart"
Cohesion: 0.07
Nodes (25): build, column, columns, error, eyebrow, FigureColumn, FigureRow, _Figures (+17 more)

### Community 39 - "Bulling Game Mode Implementation Plan"
Cohesion: 0.09
Nodes (21): Bulling Game Mode Implementation Plan, Design, precisely, Domain (`lib/domain/bulling/`), Global Constraints, Out of scope for this pass, Persistence, Self-review notes, Stats (`lib/domain/stats/bulling_stats.dart`, `part of 'mode_stats.dart'`) (+13 more)

### Community 40 - "rule_explorer.dart"
Cohesion: 0.10
Nodes (17): _board, build, createState, explanation, id, initial, label, legend (+9 more)

### Community 41 - "frame_assembler.dart"
Cohesion: 0.15
Nodes (10): _buffer, dedupeWindow, feed, FrameAssembler, _greeting, _isRepeat, _lastAt, _lastBody (+2 more)

### Community 42 - "dart_keypad.dart"
Cohesion: 0.12
Nodes (15): build, createState, _enter, highlight, highlighted, _isHighlighted, _Key, _KeyState (+7 more)

### Community 43 - "MaterialPageRoute"
Cohesion: 0.11
Nodes (21): playersProvider, playerStatsProvider, resumableLegProvider, segmentCountsProvider, AtcSetupScreen, BullingSetupScreen, _BullingSetupScreenState, HigherLowerSetupScreen (+13 more)

### Community 44 - "x01_stats.dart"
Cohesion: 0.09
Nodes (21): average, bestCheckout, bestTurn, checkoutRateFor, firstNineAverage, firstNineDarts, firstNinePoints, matchesPlayed (+13 more)

### Community 45 - "Player"
Cohesion: 0.21
Nodes (14): AtcGame, AtcGamesCompanion, BullingGame, BullingGamesCompanion, DartEvent, DartEventsCompanion, Game, GamesCompanion (+6 more)

### Community 46 - "Development"
Cohesion: 0.22
Nodes (9): Commands, Conventions, Dependency constraints, learned the hard way, Development, Running on a device, Running on Windows, Setup, Test layout (+1 more)

### Community 47 - "main.dart"
Cohesion: 0.14
Nodes (6): child, createState, _lockedToLandscape, main, _Scaled, _ScaledState

### Community 48 - "Data model"
Cohesion: 0.18
Nodes (11): `DartEvents` — every dart, Data model, `Games` — one leg, `GameSeats` — who sat where, `Matches` — a run of legs, Migrations, `Players`, Reading it back (+3 more)

### Community 49 - "board_reader_test.dart"
Cohesion: 0.15
Nodes (15): BoardReader, BoardEvent, BoardMiss, body, ButtonPress, DartHit, segment, toString (+7 more)

### Community 50 - "app_localizations_en.dart"
Cohesion: 0.01
Nodes (293): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+285 more)

### Community 51 - "scoreboard.dart"
Cohesion: 0.06
Nodes (29): accent, alignment, build, caption, colour, count, expand, _height (+21 more)

### Community 52 - "DateTime"
Cohesion: 0.22
Nodes (6): advance, bytes, call, FakeClock, main, now

### Community 53 - "Architecture"
Cohesion: 0.13
Nodes (15): Architecture, Audio, Checkouts, Everything is a fold, Game modes, Layout, Lights, Matches (+7 more)

### Community 54 - "The board protocol"
Cohesion: 0.15
Nodes (13): Connection lifecycle, Decoding, Effect frames: 16 bytes, Frame assembly, Hardware day (2026-09-04) — resolved, In one paragraph, LED control, Playing without a board (+5 more)

### Community 55 - "return"
Cohesion: 0.15
Nodes (8): after, before, sounds, soundsForAtc, after, before, sounds, soundsForBulling

### Community 56 - "string"
Cohesion: 0.11
Nodes (15): KnownBoardController, build, CalloutTone, footer, points, RuleCallout, title, tone (+7 more)

### Community 57 - "training_setup_screen.dart"
Cohesion: 0.07
Nodes (22): displayName, facts, icon, objective, of, overview, _registryName, RulesFact (+14 more)

### Community 58 - "responsive_layout_test.dart"
Cohesion: 0.09
Nodes (22): board, build, container, database, dispose, frames, laptop, main (+14 more)

### Community 59 - "l10n/app_localizations.dart"
Cohesion: 0.25
Nodes (3): l10n, L10nContext, nameFor

### Community 60 - "fluttergran"
Cohesion: 0.18
Nodes (10): Board protocol, in one paragraph, Commands, Dependency constraints (learned the hard way), fluttergran, graphify, Hardware day (done), Layering rule, Releases (+2 more)

### Community 61 - "The GranBoard 132"
Cohesion: 0.25
Nodes (8): Hardware day (2026-09-04) — done, Non-dart frames, See also, The GranBoard 132, The matrix, The segment table, What is confirmed, and what is not, What kind of device it is

### Community 62 - "atc_leg_state.dart"
Cohesion: 0.09
Nodes (20): AtcTurn, config, currentPlayerId, currentPlayerIndex, currentStopFor, currentTurnDarts, darts, dartsLeftThisTurn (+12 more)

### Community 63 - "Chalk"
Cohesion: 0.25
Nodes (8): Chalk, Documentation, Generated assets, How it is put together, Licence notes, Quick start, Testing, What it does

### Community 64 - "Table"
Cohesion: 0.22
Nodes (7): AtcGames, BullingGames, DartEvents, Games, GameSeats, Matches, Players

### Community 66 - "../../domain/x01/thrown_dart.dart"
Cohesion: 0.12
Nodes (12): after, before, _darts, sounds, soundsForTraining, dart, build, darts (+4 more)

### Community 67 - "rule_board.dart"
Cohesion: 0.12
Nodes (12): build, _controller, createState, _curve, didUpdateWidget, _dim, dispose, _from (+4 more)

### Community 68 - "mode_layout_test.dart"
Cohesion: 0.05
Nodes (33): board, container, database, frames, main, _modeName, pump, repository (+25 more)

### Community 69 - "worker.md"
Cohesion: 0.50
Nodes (3): Contract, Project, Reporting back

### Community 70 - "resumable_leg_provider_test.dart"
Cohesion: 0.05
Nodes (35): _click, cues, dispose, _gameOn, _gameShot, main, miss, playCue (+27 more)

### Community 71 - "FlutterWindow"
Cohesion: 0.12
Nodes (4): FlutterWindow, flutter_controller_, FlutterWindow::FlutterWindow(), project_

### Community 73 - ".Create"
Cohesion: 0.18
Nodes (5): Scale(), Win32Window::Win32Window(), WindowClassRegistrar, class_registered_, instance_

### Community 74 - "package:fluttergran/domain/segment.dart"
Cohesion: 0.03
Nodes (75): ThrownDart, X01RuleDartChecks, board, clock, container, controller, dbull, main (+67 more)

### Community 78 - "x01_setup_screen.dart"
Cohesion: 0.12
Nodes (18): x01DefaultsProvider, build, createState, _headToHead, initState, _inRule, l10n, _legsToPlay (+10 more)

### Community 79 - "int?"
Cohesion: 0.14
Nodes (10): CurrentGameId, foldBulling, initialBullingLegState, playerIndex, pointsFor, score, turnDarts, turns (+2 more)

### Community 81 - "widget_test.dart"
Cohesion: 0.14
Nodes (12): closeApp, database, launch, main, openX01Setup, popRoute, pump, pumpFrames (+4 more)

### Community 82 - "string"
Cohesion: 0.38
Nodes (6): deviceId, KnownBoardStore, MemoryKnownBoardStore, NoKnownBoardStore, read, write

### Community 83 - "currentGameIdProvider"
Cohesion: 0.10
Nodes (41): _persist, _persist, _persist, _persist, atcLightsProvider, bullingLightsProvider, higherLowerLightsProvider, atcConfigProvider (+33 more)

### Community 84 - "dart"
Cohesion: 0.06
Nodes (34): dart, big, _brandGreen, bust, command, connected, _flashFor, _forestGreen (+26 more)

### Community 85 - "free_practice_state.dart"
Cohesion: 0.14
Nodes (12): currentTurnDarts, darts, dartsThrown, foldFreePractice, FreePracticeState, FreePracticeTurn, initialFreePracticeState, oneEightyCount (+4 more)

### Community 86 - "dart"
Cohesion: 0.07
Nodes (26): dart, after, all, atcRing, before, bullingRing, checkoutRing, colours (+18 more)

### Community 87 - "utils.cpp"
Cohesion: 0.17
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 88 - "Around the Clock — design"
Cohesion: 0.20
Nodes (9): Around the Clock — design, Domain (`lib/domain/atc/`), Out of scope for this pass, Persistence, Rules, precisely, Stats (`lib/domain/stats/atc_stats.dart`, `part of 'mode_stats.dart'`), Summary, Testing (+1 more)

### Community 89 - "higher_lower_controller.dart"
Cohesion: 0.11
Nodes (16): acknowledgedTurns, addDart, awaitingTurnConfirm, confirmTurn, endTurn, handleBoardEvent, HigherLowerSession, leave (+8 more)

### Community 90 - "player_picker.dart"
Cohesion: 0.12
Nodes (13): _addPlayer, createState, dispose, enabled, _full, _newPlayer, onChanged, onTap (+5 more)

### Community 92 - "../l10n_extensions.dart"
Cohesion: 0.05
Nodes (35): RulesTopic, RulesTopicPresentation, build, rulesContentWidth, topic, build, _cards, createState (+27 more)

### Community 93 - "Map"
Cohesion: 0.20
Nodes (8): buttonCode, granboardSegmentMap, innerBullCode, missCode, outerBullCode, _ringOrder, unusedMatrixSlots, wedgeCodes

### Community 94 - "checkout_table.dart"
Cohesion: 0.20
Nodes (7): bestFor, _cache, CheckoutTable, isCheckoutRange, limit, outRule, routesFor

### Community 96 - "board_lifecycle.dart"
Cohesion: 0.11
Nodes (14): BoardToast, boardToastFor, context, disposed, l10n, lifecycle, messenger, null (+6 more)

### Community 97 - "aim_strip.dart"
Cohesion: 0.07
Nodes (24): AimStrip, alternatives, build, caption, chips, dartsLeft, footnote, hero (+16 more)

### Community 98 - "bool get"
Cohesion: 0.09
Nodes (20): all, hashCode, innerBull, isDouble, label, multiplier, number, operator (+12 more)

### Community 99 - "aim_card.dart"
Cohesion: 0.13
Nodes (12): Aim, AimCard, aimCardKey, aimsFor, bed, build, dartsLeft, hero (+4 more)

### Community 101 - "Releasing"
Cohesion: 0.17
Nodes (11): Android signing key (strongly recommended), Changing the toolchain, CI on the release PR (optional), One-time setup, Pinned actions, Releasing, Starting point, The flow (+3 more)

### Community 103 - "atc_stop.dart"
Cohesion: 0.14
Nodes (10): AtcStop, _bull, clears, label, number, _numbered, ring, toString (+2 more)

### Community 104 - "higher_lower_reducer.dart"
Cohesion: 0.14
Nodes (11): eliminated, foldHigherLower, higher, initialHigherLowerLegState, lower, playerIndex, pointsFor, total (+3 more)

### Community 105 - "release-please-config.json"
Cohesion: 0.50
Nodes (3): bootstrap-sha, packages, $schema

### Community 106 - "List"
Cohesion: 0.05
Nodes (24): atcVariantLabel, build, createState, l10n, _seats, _variant, build, _bullseyeValue (+16 more)

### Community 107 - "Point"
Cohesion: 0.50
Nodes (3): Point, x, y

### Community 110 - "atc_reducer.dart"
Cohesion: 0.15
Nodes (8): foldAroundTheClock, initialAtcLegState, playerIndex, stopIndex, turnDarts, turns, turnStart, winnerId

### Community 111 - "higher_lower_stats.dart"
Cohesion: 0.17
Nodes (11): higherCalls, longestRun, lowerCalls, survivalRate, turnsPlayed, turnsSurvived, dartsThrown, empty (+3 more)

### Community 112 - "dart:async"
Cohesion: 0.31
Nodes (7): boardConnectionProvider, boardSourceProvider, build, BoardConnectionButton, build, _onTap, build

### Community 113 - "bulling_stats.dart"
Cohesion: 0.17
Nodes (11): innerBullHits, outerBullHits, scoringDarts, dartsThrown, empty, fewestDartsToWin, hitRate, legsPlayed (+3 more)

### Community 114 - "game_config.dart"
Cohesion: 0.18
Nodes (9): GameConfigController, GameConfig, inRule, maxPlayers, offeredStartScores, outRule, playerIds, startingSeat (+1 more)

### Community 115 - "higher_lower_sound.dart"
Cohesion: 0.33
Nodes (4): after, before, sounds, soundsForHigherLower

### Community 116 - "Set"
Cohesion: 0.33
Nodes (3): bogeyNumbers, main, route

### Community 117 - "ModeStats"
Cohesion: 0.50
Nodes (4): BullingStats, HigherLowerStats, X01Stats, ModeStats

### Community 119 - "match_controller.dart"
Cohesion: 0.10
Nodes (26): ring, x01LightsProvider, build, config, decidedLegs, leave, legSettled, MatchController (+18 more)

### Community 125 - "sound_player.dart"
Cohesion: 0.12
Nodes (13): _cues, dispose, _disposed, _fire, _live, _pending, playCue, playSpeech (+5 more)

### Community 144 - "led_scheduler_test.dart"
Cohesion: 0.12
Nodes (14): EffectFrame, HitFlash, LedCommand, RingPaint, big, connected, gap, hit (+6 more)

### Community 149 - "[1.1.0](https://github.com/Filan-glitch/FlutterGran/compare/9be2ca2...v1.1.0) (2026-10-26)"
Cohesion: 0.50
Nodes (3): [1.1.0](https://github.com/Filan-glitch/FlutterGran/compare/9be2ca2...v1.1.0) (2026-10-26), Changelog, Features

### Community 150 - "ConsumerWidget"
Cohesion: 0.20
Nodes (13): boardLifecycleProvider, ledSchedulerProvider, ledEnabledProvider, localeProvider, _play, _silenceWhenSwitchedOff, soundEnabledProvider, speechEnabledProvider (+5 more)

### Community 169 - "int?"
Cohesion: 0.17
Nodes (9): foldLeg, initialLegState, opened, playerIndex, remaining, turnDarts, turns, turnStart (+1 more)

### Community 176 - "State"
Cohesion: 0.15
Nodes (16): RulesScreen, _RulesScreenState, _ModeTile, _ModeTileState, Pulse, _PulseState, StaggeredEntry, _StaggeredEntryState (+8 more)

### Community 187 - "../theme.dart"
Cohesion: 0.09
Nodes (18): build, label, onTap, SelectableTile, selected, build, busted, caption (+10 more)

### Community 191 - "training_controller.dart"
Cohesion: 0.12
Nodes (17): addDart, CheckoutPracticeSession, checkoutsCompleted, FreePracticeSession, _handleBoardEvent, leave, leg, _live (+9 more)

### Community 200 - "atc_controller.dart"
Cohesion: 0.08
Nodes (20): acknowledgedTurns, addDart, AtcSession, awaitingTurnConfirm, confirmTurn, endTurn, handleBoardEvent, leave (+12 more)

### Community 206 - "bulling_controller.dart"
Cohesion: 0.11
Nodes (16): acknowledgedTurns, addDart, awaitingTurnConfirm, BullingSession, confirmTurn, endTurn, handleBoardEvent, leave (+8 more)

### Community 207 - "x01_rules.dart"
Cohesion: 0.20
Nodes (10): abbreviation, checksOut, checksOutUnder, label, opens, opensUnder, X01InRule, X01InRuleChecks (+2 more)

### Community 216 - "led_scheduler.dart"
Cohesion: 0.08
Nodes (22): _ambient, _deliver, dispose, _disposed, _enabled, enterGame, _gateClosed, _gateTimer (+14 more)

### Community 217 - "Feature ideas (not yet built)"
Cohesion: 0.29
Nodes (6): Candidate game modes, Feature ideas (not yet built), How a mode fits the existing architecture, Process note, Quality-of-life, Stats / data features

### Community 219 - "game_layout.dart"
Cohesion: 0.10
Nodes (18): aim, child, confirm, _confirmLeave, _desktopScoreShareWidth, GameLayout, gameOver, isHeroDevice (+10 more)

### Community 227 - "main_menu_screen.dart"
Cohesion: 0.07
Nodes (17): icon, label, _MenuRow, _modeName, names, onResume, onTap, resumable (+9 more)

### Community 230 - "AppLocalizations"
Cohesion: 0.33
Nodes (5): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsDe, AppLocalizationsEn, of

### Community 233 - "Rules section"
Cohesion: 0.33
Nodes (5): Building blocks - `lib/app/widgets/rules/`, Rules section, Screens, Tests, The rule this section must not break

### Community 238 - "lights_providers.dart"
Cohesion: 0.15
Nodes (7): LedScheduler, connection, _drive, _gateRing, paint, scheduler, source

### Community 254 - "int get"
Cohesion: 0.13
Nodes (9): BullingConfigController, BullingConfig, bullseyeValue, offeredTargets, playerIds, target, BullseyeValue, points (+1 more)

### Community 272 - "TrainingGameScreen"
Cohesion: 0.53
Nodes (6): trainingLightsProvider, soundPlayerProvider, trainingProvider, trainingSoundControllerProvider, build, TrainingGameScreen

### Community 278 - "Notifier"
Cohesion: 0.12
Nodes (24): AtcController, build, build, BullingController, build, GameController, build, HigherLowerController (+16 more)

## Knowledge Gaps
- **2689 isolated node(s):** `leg`, `acknowledgedTurns`, `awaitingTurnConfirm`, `pendingTurn`, `_live` (+2684 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 3116 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppDatabase` connect `migration_test.dart` to `mode_layout_test.dart`, `database.dart`, `resumable_leg_provider_test.dart`, `providers.dart`, `training_game_screen_test.dart`, `responsive_layout_test.dart`, `game_repository.dart`, `widget_test.dart`, `package:flutter_test/flutter_test.dart`, `responsive_layout_test.dart`, `persistence_test.dart`?**
  _High betweenness centrality (0.030) - this node is a cross-community bridge._
- **What connects `leg`, `acknowledgedTurns`, `awaitingTurnConfirm` to the rest of the system?**
  _2689 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.g.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03278688524590164 - nodes in this community are weakly interconnected._
- **Why does `dart` connect `dart` to `../theme.dart`, `frame_assembler.dart`, `lights_providers.dart`, `led_scheduler_test.dart`, `stats_screen.dart`, `led_scheduler.dart`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **Should `theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.02531645569620253 - nodes in this community are weakly interconnected._
- **Why does `FakeBoardSource` connect `FakeBoardSource` to `mode_layout_test.dart`, `resumable_leg_provider_test.dart`, `training_game_screen_test.dart`, `responsive_layout_test.dart`, `package:fluttergran/domain/segment.dart`, `fake_board_source.dart`, `board_reader_test.dart`, `board_source.dart`, `package:flutter_riverpod/flutter_riverpod.dart`, `package:flutter_test/flutter_test.dart`, `responsive_layout_test.dart`, `persistence_test.dart`?**
  _High betweenness centrality (0.026) - this node is a cross-community bridge._
- **Should `checkout_search.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08333333333333333 - nodes in this community are weakly interconnected._