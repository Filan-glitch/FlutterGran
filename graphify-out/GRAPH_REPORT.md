# Graph Report - FlutterGran-integrate  (2026-10-26)

## Corpus Check
- 223 files · ~197,183 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 26 file(s) not represented in the graph (top: .xml 10, (none) 5, .properties 2)

## Summary
- 4365 nodes · 6438 edges · 153 communities (136 shown, 17 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 24 edges (avg confidence: 0.87)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `3ae40dca`
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
- atc_widget_test.dart
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
- setup_screens_test.dart
- stats_screen.dart
- main_menu_screen_test.dart
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
- playersProvider
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
- List
- fake_update.dart
- responsive_layout_test.dart
- update_controller.dart
- fluttergran
- The GranBoard 132
- atc_leg_state.dart
- Chalk
- Table
- higher_lower_controller_test.dart
- rule_board.dart
- mode_layout_test.dart
- worker.md
- resumable_leg_provider_test.dart
- FlutterWindow
- MainActivity.kt
- .Create
- package:fluttergran/domain/segment.dart
- MaterialPageRoute
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
- package:flutter/material.dart
- github_releases.dart
- end_screen_test.dart
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
- x01_setup_screen.dart
- Point
- check_version.sh
- release_notes.sh
- ../l10n_extensions.dart
- higher_lower_stats.dart
- ConsumerWidget
- bulling_stats.dart
- game_config.dart
- higher_lower_sound.dart
- Set
- ModeStats
- apk_download.dart
- match_controller.dart
- update_platform.dart
- rules_screen_test.dart
- update_controller_test.dart
- ../theme.dart
- checkout_card.dart
- sound_player.dart
- release_version.dart
- _Dart
- update_card.dart
- reconnect_delay_test.dart
- Size
- CustomPainter
- led_scheduler_test.dart
- [1.1.0](https://github.com/Filan-glitch/FlutterGran/compare/9be2ca2...v1.1.0) (2026-10-26)
- build
- int?
- State
- ../theme.dart
- game_controller.dart
- atc_controller.dart
- bulling_controller.dart
- bool get
- led_scheduler.dart
- Feature ideas (not yet built)
- game_layout.dart
- main_menu_screen.dart
- AppLocalizations
- Rules section
- lights_providers.dart
- BoardConnectionController
- _FakeAudioPlatform
- _FakeGlobalAudioPlatform
- _FakeAudioCache

## God Nodes (most connected - your core abstractions)
1. `_` - 48 edges
2. `dart` - 42 edges
3. `dart` - 37 edges
4. `currentGameIdProvider` - 32 edges
5. `FakeBoardSource` - 28 edges
6. `AppDatabase` - 28 edges
7. `gameRepositoryProvider` - 24 edges
8. `Win32Window` - 21 edges
9. `Bulling Game Mode Implementation Plan` - 21 edges
10. `MainMenuScreen` - 17 edges

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

## Communities (153 total, 17 thin omitted)

### Community 0 - "database.g.dart"
Cohesion: 0.03
Nodes (60): _, actualTableName, _alias, allSchemaEntities, allTables, atcGamesRefs, bullingGamesRefs, copyWithCompanion (+52 more)

### Community 1 - "theme.dart"
Cohesion: 0.03
Nodes (72): 1, base, bluetoothAmber, bluetoothBlue, body, brand, build, buildTheme (+64 more)

### Community 2 - "checkout_search.dart"
Cohesion: 0.06
Nodes (29): _byValue, CheckoutRoute, _compare, cost, darts, findCheckouts, finish, _finishCost (+21 more)

### Community 3 - "ble_board_source.dart"
Cohesion: 0.03
Nodes (56): _adapter, _adapterOff, _adapterSubscription, _attempt, _attemptConnect, _boardName, _busy, _cancelReconnect (+48 more)

### Community 4 - "_"
Cohesion: 0.05
Nodes (39): _, after, afterBustCue, afterCheckoutCue, afterOneEightyCue, asset, before, bustCue (+31 more)

### Community 5 - "database.dart"
Cohesion: 0.04
Nodes (42): aliasedName, attachedDatabase, copyWith, _createdAtMeta, custom, hashCode, _matchIdMeta, _nameMeta (+34 more)

### Community 6 - "leg_state.dart"
Cohesion: 0.07
Nodes (26): averageFor, busted, config, currentPlayerId, currentPlayerIndex, currentRemaining, currentTurnDarts, darts (+18 more)

### Community 7 - "providers.dart"
Cohesion: 0.03
Nodes (59): trainingLightsProvider, allAtcLegsProvider, allBullingLegsProvider, allHigherLowerLegsProvider, allLegsProvider, allMatchesProvider, AtcConfigController, boardReaderProvider (+51 more)

### Community 8 - "atc_widget_test.dart"
Cohesion: 0.12
Nodes (15): closeApp, database, keypadKey, launch, main, _modeName, openAtcSetup, popRoute (+7 more)

### Community 9 - "responsive_layout_test.dart"
Cohesion: 0.08
Nodes (23): SoundPlayer, AudioPlayersSoundPlayer, _MutePlayer, _MutePlayer, _FakePlayer, _MutePlayer, _MutePlayer, at (+15 more)

### Community 10 - "board_widget.dart"
Cohesion: 0.06
Nodes (33): _black, BoardGeometry, boardWedgeOrder, BoardWidget, build, _cream, dimColour, dimUnheated (+25 more)

### Community 11 - "game_repository.dart"
Cohesion: 0.04
Nodes (45): addPlayer, allPlayers, appendDart, _aroundTheClock, _bulling, db, deleteEmptyGames, deleteGame (+37 more)

### Community 12 - "game_screen.dart"
Cohesion: 0.05
Nodes (27): after, before, _darts, sounds, soundsForTraining, l10n, L10nContext, nameFor (+19 more)

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
Nodes (34): a, b, black, byNumber, c, code, colourOf, effect (+26 more)

### Community 19 - "board_source.dart"
Cohesion: 0.06
Nodes (27): BleBoardSource, assembler, boardName, BoardSource, codec, connect, connectionState, currentState (+19 more)

### Community 20 - "led_cue.dart"
Cohesion: 0.15
Nodes (19): BoardConnected, DartLanded, DartMissed, GameOn, hashCode, kind, LedCue, LedCueKind (+11 more)

### Community 21 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.05
Nodes (31): build, _ChalkMark, createState, initState, paint, _proceed, shouldRepaint, choose (+23 more)

### Community 22 - "setup_screens_test.dart"
Cohesion: 0.04
Nodes (49): GameRepository, database, main, repository, s, seedAtcGame, database, main (+41 more)

### Community 23 - "stats_screen.dart"
Cohesion: 0.10
Nodes (18): child, createState, _decimal, detail, _Empty, _FadeIn, _Headline, label (+10 more)

### Community 24 - "main_menu_screen_test.dart"
Cohesion: 0.04
Nodes (38): main, pumpBoardIn, pumpWidget, tapped, contentSizeAt, main, board, container (+30 more)

### Community 25 - "Win32Window"
Cohesion: 0.23
Nodes (4): Win32Window, child_content_, quit_on_close_, window_handle_

### Community 26 - "higher_lower_leg_state.dart"
Cohesion: 0.06
Nodes (29): activePlayerIds, between, config, currentPlayerId, currentPlayerIndex, currentTurnDarts, darts, dartsLeftThisTurn (+21 more)

### Community 27 - "make_icon.py"
Cohesion: 0.06
Nodes (31): Generated assets, `tool/make_cues.py` — the four cues, `tool/make_icon.py` — the launcher icon, `tool/make_speech.py` — the commentary, bust(), checkout(), dart(), envelope() (+23 more)

### Community 28 - "roster_screen.dart"
Cohesion: 0.10
Nodes (19): _commit, _controller, createState, didUpdateWidget, dispose, _editing, _focusNode, initState (+11 more)

### Community 29 - "persistence_test.dart"
Cohesion: 0.14
Nodes (12): board, container, controller, d, database, gameId, main, repository (+4 more)

### Community 30 - "StatelessWidget"
Cohesion: 0.06
Nodes (32): AnimatedFigure, CenteredContent, EntrancePop, _aroundTheClock, _AtcRoute, body, build, _bulling (+24 more)

### Community 31 - "FakeBoardSource"
Cohesion: 0.04
Nodes (44): FakeBoardSource, board, clock, container, controller, main, s, session (+36 more)

### Community 32 - "app_localizations.dart"
Cohesion: 0.01
Nodes (322): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+314 more)

### Community 33 - "Connectivity"
Cohesion: 0.12
Nodes (17): A forgiving characteristic lookup, Android, Connecting from the app, Connection lifecycle, Connectivity, GATT, Licensing note, Permissions (+9 more)

### Community 34 - "../theme.dart"
Cohesion: 0.07
Nodes (22): _bestDart, BoundsCard, boundsCardKey, _BoundTile, build, dartsLeft, figure, hero (+14 more)

### Community 35 - "sound_player_test.dart"
Cohesion: 0.05
Nodes (37): binding, create, dispose, emitError, emitGlobalError, emitGlobalLog, emitLog, _events (+29 more)

### Community 36 - "bulling_leg_state.dart"
Cohesion: 0.08
Nodes (22): BullingConfigController, BullingConfig, BullingTurn, config, currentPlayerId, currentPlayerIndex, currentTurnDarts, darts (+14 more)

### Community 37 - "app_localizations_de.dart"
Cohesion: 0.01
Nodes (314): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+306 more)

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
Cohesion: 0.06
Nodes (30): build, createState, _enter, highlight, highlighted, _isHighlighted, _Key, _KeyState (+22 more)

### Community 43 - "playersProvider"
Cohesion: 0.25
Nodes (9): playersProvider, playerStatsProvider, segmentCountsProvider, build, _Body, build, StatsScreen, _StatsScreenState (+1 more)

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
Cohesion: 0.12
Nodes (12): boardLifecycleProvider, ledSchedulerProvider, localeProvider, updateLifecycleProvider, build, child, createState, FlutterGranApp (+4 more)

### Community 48 - "Data model"
Cohesion: 0.18
Nodes (11): `DartEvents` — every dart, Data model, `Games` — one leg, `GameSeats` — who sat where, `Matches` — a run of legs, Migrations, `Players`, Reading it back (+3 more)

### Community 49 - "board_reader_test.dart"
Cohesion: 0.14
Nodes (16): BoardReader, BoardEvent, BoardMiss, body, ButtonPress, DartHit, segment, toString (+8 more)

### Community 50 - "app_localizations_en.dart"
Cohesion: 0.01
Nodes (314): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+306 more)

### Community 51 - "scoreboard.dart"
Cohesion: 0.06
Nodes (30): accent, alignment, build, caption, colour, count, expand, _Figure (+22 more)

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

### Community 56 - "List"
Cohesion: 0.08
Nodes (17): _ComingSoonTile, createState, mode, modes, _pressed, SelectGameModeScreen, _setPressed, _setupScreenFor (+9 more)

### Community 57 - "fake_update.dart"
Cohesion: 0.06
Nodes (28): ChecksumMismatch, UpdateCheckException, allowed, apkBytes, apkName, base, browserOpens, canInstall (+20 more)

### Community 58 - "responsive_layout_test.dart"
Cohesion: 0.06
Nodes (30): BoolSetting, highlight, main, pumpKeypad, pumpWidget, _LightsOff, board, build (+22 more)

### Community 59 - "update_controller.dart"
Cohesion: 0.08
Nodes (25): apkPath, apply, build, check, client, current, dismiss, disposed (+17 more)

### Community 60 - "fluttergran"
Cohesion: 0.17
Nodes (11): Board protocol, in one paragraph, Commands, Dependency constraints (learned the hard way), fluttergran, graphify, Hardware day (done), Layering rule, Releases (+3 more)

### Community 61 - "The GranBoard 132"
Cohesion: 0.25
Nodes (8): Hardware day (2026-09-04) — done, Non-dart frames, See also, The GranBoard 132, The matrix, The segment table, What is confirmed, and what is not, What kind of device it is

### Community 62 - "atc_leg_state.dart"
Cohesion: 0.06
Nodes (29): CurrentGameId, AtcTurn, config, currentPlayerId, currentPlayerIndex, currentStopFor, currentTurnDarts, darts (+21 more)

### Community 63 - "Chalk"
Cohesion: 0.25
Nodes (8): Chalk, Documentation, Generated assets, How it is put together, Licence notes, Quick start, Testing, What it does

### Community 64 - "Table"
Cohesion: 0.22
Nodes (7): AtcGames, BullingGames, DartEvents, Games, GameSeats, Matches, Players

### Community 66 - "higher_lower_controller_test.dart"
Cohesion: 0.07
Nodes (25): ThrownDart, X01RuleDartChecks, board, clock, container, controller, main, miss (+17 more)

### Community 67 - "rule_board.dart"
Cohesion: 0.12
Nodes (12): build, _controller, createState, _curve, didUpdateWidget, _dim, dispose, _from (+4 more)

### Community 68 - "mode_layout_test.dart"
Cohesion: 0.07
Nodes (25): _atc, board, build, _bulling, container, database, desktopWindows, dispose (+17 more)

### Community 69 - "worker.md"
Cohesion: 0.50
Nodes (3): Contract, Project, Reporting back

### Community 70 - "resumable_leg_provider_test.dart"
Cohesion: 0.05
Nodes (31): _click, cues, dispose, _gameOn, _gameShot, main, miss, playCue (+23 more)

### Community 71 - "FlutterWindow"
Cohesion: 0.12
Nodes (4): FlutterWindow, flutter_controller_, FlutterWindow::FlutterWindow(), project_

### Community 73 - ".Create"
Cohesion: 0.18
Nodes (5): Scale(), Win32Window::Win32Window(), WindowClassRegistrar, class_registered_, instance_

### Community 74 - "package:fluttergran/domain/segment.dart"
Cohesion: 0.04
Nodes (46): at, bull, config, d, main, miss, s, t (+38 more)

### Community 78 - "MaterialPageRoute"
Cohesion: 0.17
Nodes (11): x01DefaultsProvider, build, _start, initState, _start, X01SetupScreen, _X01SetupScreenState, build (+3 more)

### Community 79 - "int?"
Cohesion: 0.17
Nodes (9): foldBulling, initialBullingLegState, playerIndex, pointsFor, score, turnDarts, turns, turnStart (+1 more)

### Community 81 - "widget_test.dart"
Cohesion: 0.13
Nodes (12): closeApp, database, launch, main, openX01Setup, popRoute, pump, pumpFrames (+4 more)

### Community 82 - "string"
Cohesion: 0.32
Nodes (7): KnownBoardController, deviceId, KnownBoardStore, MemoryKnownBoardStore, NoKnownBoardStore, read, write

### Community 83 - "currentGameIdProvider"
Cohesion: 0.07
Nodes (59): AtcController, build, _persist, build, BullingController, _persist, build, GameController (+51 more)

### Community 84 - "dart"
Cohesion: 0.06
Nodes (34): dart, big, _brandGreen, bust, command, connected, _flashFor, _forestGreen (+26 more)

### Community 85 - "free_practice_state.dart"
Cohesion: 0.11
Nodes (14): points, three, currentTurnDarts, darts, dartsThrown, foldFreePractice, FreePracticeState, FreePracticeTurn (+6 more)

### Community 86 - "dart"
Cohesion: 0.07
Nodes (26): dart, after, all, atcRing, before, bullingRing, checkoutRing, colours (+18 more)

### Community 87 - "utils.cpp"
Cohesion: 0.18
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 88 - "Around the Clock — design"
Cohesion: 0.20
Nodes (9): Around the Clock — design, Domain (`lib/domain/atc/`), Out of scope for this pass, Persistence, Rules, precisely, Stats (`lib/domain/stats/atc_stats.dart`, `part of 'mode_stats.dart'`), Summary, Testing (+1 more)

### Community 89 - "higher_lower_controller.dart"
Cohesion: 0.11
Nodes (16): acknowledgedTurns, addDart, awaitingTurnConfirm, confirmTurn, endTurn, handleBoardEvent, HigherLowerSession, leave (+8 more)

### Community 90 - "player_picker.dart"
Cohesion: 0.12
Nodes (12): createState, dispose, enabled, _full, _newPlayer, onChanged, onTap, player (+4 more)

### Community 92 - "package:flutter/material.dart"
Cohesion: 0.05
Nodes (33): displayName, facts, icon, objective, of, overview, _registryName, RulesFact (+25 more)

### Community 93 - "github_releases.dart"
Cohesion: 0.07
Nodes (24): apkNameFor, AppRelease, assets, checksums, checksumsUrl, _client, GitHubReleases, json (+16 more)

### Community 94 - "end_screen_test.dart"
Cohesion: 0.07
Nodes (23): board, checkout, container, d, database, dispose, frames, inFigures (+15 more)

### Community 96 - "board_lifecycle.dart"
Cohesion: 0.11
Nodes (14): BoardToast, boardToastFor, context, disposed, l10n, lifecycle, messenger, null (+6 more)

### Community 97 - "aim_strip.dart"
Cohesion: 0.12
Nodes (14): AimStrip, alternatives, build, caption, chips, dartsLeft, footnote, hero (+6 more)

### Community 98 - "bool get"
Cohesion: 0.15
Nodes (11): all, hashCode, innerBull, isDouble, label, multiplier, number, operator (+3 more)

### Community 99 - "aim_card.dart"
Cohesion: 0.13
Nodes (12): Aim, AimCard, aimCardKey, aimsFor, bed, build, dartsLeft, hero (+4 more)

### Community 101 - "Releasing"
Cohesion: 0.15
Nodes (12): Android signing key (strongly recommended), Changing the toolchain, CI on the release PR (optional), In-app updates, One-time setup, Pinned actions, Releasing, Starting point (+4 more)

### Community 103 - "atc_stop.dart"
Cohesion: 0.15
Nodes (10): AtcStop, _bull, clears, label, number, _numbered, ring, toString (+2 more)

### Community 104 - "higher_lower_reducer.dart"
Cohesion: 0.14
Nodes (11): eliminated, foldHigherLower, higher, initialHigherLowerLegState, lower, playerIndex, pointsFor, total (+3 more)

### Community 105 - "release-please-config.json"
Cohesion: 0.50
Nodes (3): bootstrap-sha, packages, $schema

### Community 106 - "x01_setup_screen.dart"
Cohesion: 0.04
Nodes (40): atcVariantLabel, build, createState, l10n, _seats, _variant, build, createState (+32 more)

### Community 107 - "Point"
Cohesion: 0.50
Nodes (3): Point, x, y

### Community 110 - "../l10n_extensions.dart"
Cohesion: 0.09
Nodes (16): build, rulesContentWidth, RulesDetailScreen, topic, build, _cards, createState, flight (+8 more)

### Community 111 - "higher_lower_stats.dart"
Cohesion: 0.17
Nodes (11): higherCalls, longestRun, lowerCalls, survivalRate, turnsPlayed, turnsSurvived, dartsThrown, empty (+3 more)

### Community 112 - "ConsumerWidget"
Cohesion: 0.16
Nodes (20): bullingLightsProvider, higherLowerLightsProvider, ring, x01LightsProvider, bullingSoundControllerProvider, checkoutTableProvider, decidedMatchLegsProvider, gameProvider (+12 more)

### Community 113 - "bulling_stats.dart"
Cohesion: 0.17
Nodes (11): innerBullHits, outerBullHits, scoringDarts, dartsThrown, empty, fewestDartsToWin, hitRate, legsPlayed (+3 more)

### Community 114 - "game_config.dart"
Cohesion: 0.08
Nodes (18): GameConfigController, bullseyeValue, offeredTargets, playerIds, target, BullseyeValue, minPlayers, playerIds (+10 more)

### Community 115 - "higher_lower_sound.dart"
Cohesion: 0.33
Nodes (4): after, before, sounds, soundsForHigherLower

### Community 116 - "Set"
Cohesion: 0.33
Nodes (3): bogeyNumbers, main, route

### Community 117 - "ModeStats"
Cohesion: 0.50
Nodes (4): BullingStats, HigherLowerStats, X01Stats, ModeStats

### Community 118 - "apk_download.dart"
Cohesion: 0.10
Nodes (17): actual, add, close, _deleteIfThere, digest, _DigestSink, downloadVerified, expected (+9 more)

### Community 119 - "match_controller.dart"
Cohesion: 0.14
Nodes (13): build, config, decidedLegs, leave, legSettled, matchId, MatchSession, _recordedWinner (+5 more)

### Community 120 - "update_platform.dart"
Cohesion: 0.11
Nodes (12): canInstall, _channel, checksAtLaunch, currentVersion, DeviceUpdatePlatform, downloadDirectory, installApk, InstallResult (+4 more)

### Community 121 - "rules_screen_test.dart"
Cohesion: 0.11
Nodes (15): RulesBody, container, expectEveryMode, laptop, main, monitor, phoneLandscape, phonePortrait (+7 more)

### Community 122 - "update_controller_test.dart"
Cohesion: 0.17
Nodes (15): UpdateAvailable, UpdateChecking, UpdateDownloaded, UpdateDownloading, UpdateFailed, UpdateIdle, UpdateState, UpdateUpToDate (+7 more)

### Community 123 - "../theme.dart"
Cohesion: 0.13
Nodes (12): build, CalloutTone, footer, points, RuleCallout, title, tone, build (+4 more)

### Community 124 - "checkout_card.dart"
Cohesion: 0.14
Nodes (10): _alternates, build, CheckoutCard, checkoutCardKey, checkoutNextDartKey, dartsLeft, hero, padding (+2 more)

### Community 125 - "sound_player.dart"
Cohesion: 0.12
Nodes (13): _cues, dispose, _disposed, _fire, _live, _pending, playCue, playSpeech (+5 more)

### Community 126 - "release_version.dart"
Cohesion: 0.15
Nodes (10): compareTo, hashCode, major, minor, operator, patch, _pattern, ReleaseVersion (+2 more)

### Community 127 - "_Dart"
Cohesion: 0.18
Nodes (11): _Dart, build, caption, darts, ExampleDart, ExampleOutcome, note, outcome (+3 more)

### Community 128 - "update_card.dart"
Cohesion: 0.25
Nodes (6): _UpdateStatus, updateProvider, build, compact, onDismiss, UpdateCard

### Community 129 - "reconnect_delay_test.dart"
Cohesion: 0.22
Nodes (7): FixedRandom, main, nextBool, nextDouble, nextInt, _scanCooldownTests, value

### Community 130 - "Size"
Cohesion: 0.50
Nodes (3): Size, height, width

### Community 144 - "led_scheduler_test.dart"
Cohesion: 0.14
Nodes (10): big, connected, gap, hit, idle, main, scheduler, sent (+2 more)

### Community 149 - "[1.1.0](https://github.com/Filan-glitch/FlutterGran/compare/9be2ca2...v1.1.0) (2026-10-26)"
Cohesion: 0.50
Nodes (3): [1.1.0](https://github.com/Filan-glitch/FlutterGran/compare/9be2ca2...v1.1.0) (2026-10-26), Changelog, Features

### Community 150 - "build"
Cohesion: 0.24
Nodes (12): _perform, ledCelebrationsProvider, ledDartFlashesProvider, ledEnabledProvider, _play, _silenceWhenSwitchedOff, soundEnabledProvider, speechEnabledProvider (+4 more)

### Community 169 - "int?"
Cohesion: 0.15
Nodes (9): foldLeg, initialLegState, opened, playerIndex, remaining, turnDarts, turns, turnStart (+1 more)

### Community 176 - "State"
Cohesion: 0.15
Nodes (16): RulesScreen, _RulesScreenState, _ModeTile, _ModeTileState, Pulse, _PulseState, StaggeredEntry, _StaggeredEntryState (+8 more)

### Community 187 - "../theme.dart"
Cohesion: 0.12
Nodes (13): build, busted, caption, celebrate, child, darts, figure, finishing (+5 more)

### Community 191 - "game_controller.dart"
Cohesion: 0.04
Nodes (44): acknowledgedTurns, addDart, awaitingTurnConfirm, confirmTurn, endTurn, GameSession, handleBoardEvent, leave (+36 more)

### Community 200 - "atc_controller.dart"
Cohesion: 0.08
Nodes (21): acknowledgedTurns, addDart, AtcSession, awaitingTurnConfirm, confirmTurn, endTurn, handleBoardEvent, leave (+13 more)

### Community 206 - "bulling_controller.dart"
Cohesion: 0.11
Nodes (16): acknowledgedTurns, addDart, awaitingTurnConfirm, BullingSession, confirmTurn, endTurn, handleBoardEvent, leave (+8 more)

### Community 207 - "bool get"
Cohesion: 0.10
Nodes (18): hashCode, isDouble, label, miss, operator, segment, toString, value (+10 more)

### Community 216 - "led_scheduler.dart"
Cohesion: 0.08
Nodes (22): _ambient, _deliver, dispose, _disposed, _enabled, enterGame, _gateClosed, _gateTimer (+14 more)

### Community 217 - "Feature ideas (not yet built)"
Cohesion: 0.29
Nodes (6): Candidate game modes, Feature ideas (not yet built), How a mode fits the existing architecture, Process note, Quality-of-life, Stats / data features

### Community 219 - "game_layout.dart"
Cohesion: 0.07
Nodes (26): boardConnectionProvider, boardSourceProvider, build, BoardConnectionButton, build, _onTap, aim, build (+18 more)

### Community 227 - "main_menu_screen.dart"
Cohesion: 0.10
Nodes (12): child, _FitOrScroll, icon, label, _MenuRow, _modeName, names, onResume (+4 more)

### Community 230 - "AppLocalizations"
Cohesion: 0.33
Nodes (5): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsDe, AppLocalizationsEn, of

### Community 233 - "Rules section"
Cohesion: 0.33
Nodes (5): Building blocks - `lib/app/widgets/rules/`, Rules section, Screens, Tests, The rule this section must not break

### Community 238 - "lights_providers.dart"
Cohesion: 0.15
Nodes (7): LedScheduler, connection, _drive, _gateRing, paint, scheduler, source

## Knowledge Gaps
- **2869 isolated node(s):** `leg`, `acknowledgedTurns`, `awaitingTurnConfirm`, `pendingTurn`, `_live` (+2864 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 3320 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **17 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `dart` connect `dart` to `game_screen.dart`, `lights_providers.dart`, `higher_lower_sound.dart`, `return`, `checkout_card.dart`, `game_controller.dart`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **What connects `leg`, `acknowledgedTurns`, `awaitingTurnConfirm` to the rest of the system?**
  _2869 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.g.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03278688524590164 - nodes in this community are weakly interconnected._
- **Why does `AppDatabase` connect `migration_test.dart` to `mode_layout_test.dart`, `database.dart`, `providers.dart`, `atc_widget_test.dart`, `package:fluttergran/domain/segment.dart`, `game_repository.dart`, `widget_test.dart`, `setup_screens_test.dart`, `main_menu_screen_test.dart`, `responsive_layout_test.dart`, `persistence_test.dart`, `end_screen_test.dart`?**
  _High betweenness centrality (0.021) - this node is a cross-community bridge._
- **Should `theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.02564102564102564 - nodes in this community are weakly interconnected._
- **Why does `Win32Window` connect `Win32Window` to `Size`, `.MessageHandler`, `FlutterWindow`, `.Create`, `Point`, `flutter_window.h`?**
  _High betweenness centrality (0.020) - this node is a cross-community bridge._
- **Should `checkout_search.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._