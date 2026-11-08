# Graph Report - FlutterGran-dx  (2026-11-08)

## Corpus Check
- 248 files · ~187,293 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 26 file(s) not represented in the graph (top: .xml 10, (none) 5, .properties 2)

## Summary
- 4419 nodes · 6551 edges · 170 communities (138 shown, 32 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 24 edges (avg confidence: 0.87)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `80cecd1e`
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
- package:flutter_test/flutter_test.dart
- sound.dart
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
- stats_screen.dart
- update_card_test.dart
- Win32Window
- higher_lower_leg_state.dart
- make_icon.py
- roster_screen.dart
- dependencies
- StatelessWidget
- FakeBoardSource
- app_localizations.dart
- Connectivity
- ../theme.dart
- sound_player_test.dart
- bulling_leg_state.dart
- app_localizations_de.dart
- game_over_card.dart
- with
- rule_explorer.dart
- frame_assembler.dart
- setup_controls.dart
- playersProvider
- training_setup_screen.dart
- Player
- Development
- main.dart
- Data model
- board_reader_test.dart
- app_localizations_en.dart
- Recipes
- DateTime
- Architecture
- The board protocol
- return
- String?
- apk_download_test.dart
- Notifier
- update_controller.dart
- fluttergran
- The GranBoard 132
- atc_leg_state.dart
- Chalk
- Table
- README.md
- Bulling Game Mode Implementation Plan
- rule_board.dart
- mode_layout_test.dart
- worker.md
- package:fluttergran/domain/segment.dart
- FlutterWindow
- MainActivity.kt
- .Create
- led_reactions_test.dart
- MaterialPageRoute
- int?
- resumable_leg_provider_test.dart
- fake_update.dart
- currentGameIdProvider
- dart
- free_practice_state.dart
- dart
- utils.cpp
- devices.dart
- higher_lower_controller.dart
- pump.dart
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
- int get
- dart_keypad.dart
- ConsumerWidget
- splash_screen_test.dart
- List
- dartdoc
- Map
- atc_reducer.dart
- apk_download.dart
- analyzer
- update_platform.dart
- board_connection_button.dart
- update_controller_test.dart
- labels.dart
- game_config.dart
- sound_player.dart
- release_version.dart
- checkout_table.dart
- Around the Clock — design
- reconnect_delay_test.dart
- Size
- dart
- ../../domain/x01/thrown_dart.dart
- FlutterGranApp
- TrainingGameScreen
- check.sh
- async.dart
- led_scheduler_test.dart
- [1.1.0](https://github.com/Filan-glitch/FlutterGran/compare/9be2ca2...v1.1.0) (2026-10-26)
- build
- int?
- State
- ../theme.dart
- game_controller.dart
- atc_controller.dart
- x01_rules.dart
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
2. `dart` - 44 edges
3. `dart` - 39 edges
4. `currentGameIdProvider` - 32 edges
5. `FakeBoardSource` - 28 edges
6. `AppDatabase` - 28 edges
7. `gameRepositoryProvider` - 24 edges
8. `Bulling Game Mode Implementation Plan` - 21 edges
9. `Win32Window` - 21 edges
10. `MainMenuScreen` - 17 edges

## Surprising Connections (you probably didn't know these)
- ``tool/make_speech.py` — the commentary` --references--> `bust()`  [INFERRED]
  docs/DEVELOPMENT.md → tool/make_cues.py
- ``tool/make_cues.py` — the four cues` --references--> `bust()`  [INFERRED]
  docs/DEVELOPMENT.md → tool/make_cues.py
- ``tool/make_cues.py` — the four cues` --references--> `checkout()`  [INFERRED]
  docs/DEVELOPMENT.md → tool/make_cues.py
- ``tool/make_cues.py` — the four cues` --references--> `dart()`  [INFERRED]
  docs/DEVELOPMENT.md → tool/make_cues.py
- ``tool/make_cues.py` — the four cues` --references--> `one_eighty()`  [INFERRED]
  docs/DEVELOPMENT.md → tool/make_cues.py

## Import Cycles
- None detected.

## Communities (170 total, 32 thin omitted)

### Community 0 - "database.g.dart"
Cohesion: 0.03
Nodes (60): _, actualTableName, _alias, allSchemaEntities, allTables, atcGamesRefs, attachedDatabase, bullingGamesRefs (+52 more)

### Community 1 - "theme.dart"
Cohesion: 0.03
Nodes (73): 1, base, bluetoothAmber, bluetoothBlue, body, brand, build, buildTheme (+65 more)

### Community 2 - "checkout_search.dart"
Cohesion: 0.07
Nodes (27): _byValue, CheckoutRoute, _compare, cost, darts, findCheckouts, finish, _finishCost (+19 more)

### Community 3 - "ble_board_source.dart"
Cohesion: 0.03
Nodes (56): _adapter, _adapterOff, _adapterSubscription, _attempt, _attemptConnect, _boardName, _busy, _cancelReconnect (+48 more)

### Community 4 - "_"
Cohesion: 0.05
Nodes (39): _, after, afterBustCue, afterCheckoutCue, afterOneEightyCue, asset, before, bustCue (+31 more)

### Community 5 - "database.dart"
Cohesion: 0.04
Nodes (42): aliasedName, copyWith, custom, _gameIdMeta, _matchIdMeta, _playerIdMeta, _startedAtMeta, _thrownAtMeta (+34 more)

### Community 6 - "leg_state.dart"
Cohesion: 0.07
Nodes (26): averageFor, busted, config, currentPlayerId, currentPlayerIndex, currentRemaining, currentTurnDarts, darts (+18 more)

### Community 7 - "providers.dart"
Cohesion: 0.04
Nodes (47): allAtcLegsProvider, allBullingLegsProvider, allHigherLowerLegsProvider, allLegsProvider, allMatchesProvider, boardReaderProvider, computePlayerStats, controller (+39 more)

### Community 8 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.09
Nodes (17): main, pumpApp, pumpBoardIn, tapped, highlight, main, pumpApp, pumpKeypad (+9 more)

### Community 9 - "sound.dart"
Cohesion: 0.18
Nodes (10): SoundPlayer, AudioPlayersSoundPlayer, cues, dispose, MuteSoundPlayer, playCue, playSpeech, RecordingSoundPlayer (+2 more)

### Community 10 - "board_widget.dart"
Cohesion: 0.05
Nodes (35): _TallyPainter, _black, BoardGeometry, _BoardPainter, boardWedgeOrder, BoardWidget, build, _cream (+27 more)

### Community 11 - "game_repository.dart"
Cohesion: 0.04
Nodes (44): addPlayer, allPlayers, appendDart, _aroundTheClock, _bulling, db, deleteGame, findResumableGameId (+36 more)

### Community 12 - "game_screen.dart"
Cohesion: 0.08
Nodes (19): _clearedThisTurn, _figures, _gain, _movedOn, _figures, _gain, _figures, _legWon (+11 more)

### Community 13 - "mode_stats.dart"
Cohesion: 0.06
Nodes (56): average, bestCheckout, bestTurn, BullingStats, checkoutRateFor, firstNineAverage, firstNineDarts, firstNinePoints (+48 more)

### Community 14 - "player_stats.dart"
Cohesion: 0.04
Nodes (40): atcLegs, bestCheckout, bestTurn, bullingLegs, checkoutsByRule, computeAtcStats, computeBullingStats, computeHigherLowerStats (+32 more)

### Community 15 - "match_state.dart"
Cohesion: 0.07
Nodes (25): config, counted, foldMatch, formatLabel, inRule, isFinished, isHeadToHead, isMultiLeg (+17 more)

### Community 16 - "migration_test.dart"
Cohesion: 0.07
Nodes (28): AppDatabase, directory, file, _gamesAtV2, _gamesAtV4, _gamesAtV5, _gamesSinceV6, id (+20 more)

### Community 17 - "fake_board_source.dart"
Cohesion: 0.05
Nodes (35): _adapterOn, _attempt, boardName, connect, connectionState, _current, currentState, disconnect (+27 more)

### Community 18 - "led_command.dart"
Cohesion: 0.06
Nodes (31): a, b, black, byNumber, c, code, colourOf, effect (+23 more)

### Community 19 - "board_source.dart"
Cohesion: 0.06
Nodes (26): BleBoardSource, assembler, boardName, BoardSource, codec, connect, connectionState, currentState (+18 more)

### Community 20 - "led_cue.dart"
Cohesion: 0.15
Nodes (19): BoardConnected, DartLanded, DartMissed, GameOn, hashCode, kind, LedCue, LedCueKind (+11 more)

### Community 22 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.03
Nodes (61): RulesDetailScreen, RulesBody, compact, onDismiss, contentSizeAt, main, board, container (+53 more)

### Community 23 - "stats_screen.dart"
Cohesion: 0.09
Nodes (20): child, createState, _decimal, detail, _Empty, _FadeIn, _Headline, label (+12 more)

### Community 24 - "update_card_test.dart"
Cohesion: 0.12
Nodes (12): container, main, pump, switches, board, check, container, database (+4 more)

### Community 25 - "Win32Window"
Cohesion: 0.21
Nodes (4): Win32Window, child_content_, quit_on_close_, window_handle_

### Community 26 - "higher_lower_leg_state.dart"
Cohesion: 0.06
Nodes (29): activePlayerIds, between, config, currentPlayerId, currentPlayerIndex, currentTurnDarts, darts, dartsLeftThisTurn (+21 more)

### Community 27 - "make_icon.py"
Cohesion: 0.06
Nodes (31): Generated assets, `tool/make_cues.py` — the four cues, `tool/make_icon.py` — the launcher icon, `tool/make_speech.py` — the commentary, bust(), checkout(), dart(), envelope() (+23 more)

### Community 28 - "roster_screen.dart"
Cohesion: 0.05
Nodes (32): _addPlayer, _commit, _controller, createState, didUpdateWidget, dispose, _editing, _focusNode (+24 more)

### Community 29 - "dependencies"
Cohesion: 0.05
Nodes (39): dependencies, audioplayers, crypto, drift, drift_flutter, flutter, flutter_blue_plus, flutter_localizations (+31 more)

### Community 30 - "StatelessWidget"
Cohesion: 0.03
Nodes (61): AnimatedFigure, CenteredContent, EntrancePop, _aroundTheClock, _AtcRoute, body, build, _bulling (+53 more)

### Community 31 - "FakeBoardSource"
Cohesion: 0.05
Nodes (31): BoardReader, FakeBoardSource, board, clock, container, controller, main, session (+23 more)

### Community 32 - "app_localizations.dart"
Cohesion: 0.01
Nodes (322): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+314 more)

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
Nodes (21): BullingLegState, BullingTurn, config, currentPlayerId, currentPlayerIndex, currentTurnDarts, darts, dartsLeftThisTurn (+13 more)

### Community 37 - "app_localizations_de.dart"
Cohesion: 0.01
Nodes (314): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+306 more)

### Community 38 - "game_over_card.dart"
Cohesion: 0.07
Nodes (25): build, column, columns, error, eyebrow, FigureColumn, FigureRow, _Figures (+17 more)

### Community 39 - "with"
Cohesion: 0.06
Nodes (30): needs, uses, with, runs-on, steps, timeout-minutes, concurrency, cancel-in-progress (+22 more)

### Community 40 - "rule_explorer.dart"
Cohesion: 0.10
Nodes (17): _board, build, createState, explanation, id, initial, label, legend (+9 more)

### Community 41 - "frame_assembler.dart"
Cohesion: 0.15
Nodes (10): _buffer, dedupeWindow, feed, FrameAssembler, _greeting, _isRepeat, _lastAt, _lastBody (+2 more)

### Community 42 - "setup_controls.dart"
Cohesion: 0.11
Nodes (15): build, buttonKey, ChoiceRow, label, _Numeral, NumeralChoiceRow, onPressed, onSelected (+7 more)

### Community 43 - "playersProvider"
Cohesion: 0.33
Nodes (7): playersProvider, playerStatsProvider, segmentCountsProvider, build, _Body, build, build

### Community 44 - "training_setup_screen.dart"
Cohesion: 0.07
Nodes (22): displayName, facts, icon, objective, of, overview, _registryName, RulesFact (+14 more)

### Community 45 - "Player"
Cohesion: 0.21
Nodes (14): AtcGame, AtcGamesCompanion, BullingGame, BullingGamesCompanion, DartEvent, DartEventsCompanion, Game, GamesCompanion (+6 more)

### Community 46 - "Development"
Cohesion: 0.25
Nodes (8): Commands, Dependency constraints and conventions, Development, Layout breakpoints, Running on a device, Running on Windows, Test layout, Working with the board

### Community 47 - "main.dart"
Cohesion: 0.15
Nodes (4): child, createState, _lockedToLandscape, main

### Community 48 - "Data model"
Cohesion: 0.13
Nodes (15): `AtcGames` — an Around the Clock leg's settings, `BullingGames` — a Bulling leg's settings, `DartEvents` — every dart, Data model, `Games` — one leg, `GameSeats` — who sat where, `Matches` — a run of x01 legs, Migration tests (+7 more)

### Community 49 - "board_reader_test.dart"
Cohesion: 0.24
Nodes (10): BoardEvent, BoardMiss, body, ButtonPress, DartHit, segment, toString, UnknownFrame (+2 more)

### Community 50 - "app_localizations_en.dart"
Cohesion: 0.01
Nodes (314): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+306 more)

### Community 51 - "Recipes"
Cohesion: 0.07
Nodes (27): Add a database column or table, Add a game mode, Add a localized string, Add a provider, Add a sound, Add a test, Add an LED cue, API docs (+19 more)

### Community 52 - "DateTime"
Cohesion: 0.22
Nodes (6): advance, bytes, call, FakeClock, main, now

### Community 53 - "Architecture"
Cohesion: 0.13
Nodes (15): Architecture, Audio, Checkouts, Everything is a fold, Game modes, Layout, Lights, Matches (+7 more)

### Community 54 - "The board protocol"
Cohesion: 0.15
Nodes (13): Connection lifecycle, Decoding, Effect frames: 16 bytes, Frame assembly, Hardware day, In one paragraph, LED control, Playing without a board (+5 more)

### Community 55 - "return"
Cohesion: 0.11
Nodes (12): after, before, sounds, soundsForAtc, after, before, sounds, soundsForBulling (+4 more)

### Community 56 - "String?"
Cohesion: 0.14
Nodes (12): KnownBoardController, KnownBoardStore, NoKnownBoardStore, read, write, displayName, GameMode, GameModeDescriptor (+4 more)

### Community 57 - "apk_download_test.dart"
Cohesion: 0.11
Nodes (10): ChecksumMismatch, UpdateCheckException, bytes, directory, main, serving, target, url (+2 more)

### Community 58 - "Notifier"
Cohesion: 0.12
Nodes (24): AtcController, build, build, BullingController, build, GameController, build, HigherLowerController (+16 more)

### Community 59 - "update_controller.dart"
Cohesion: 0.07
Nodes (34): updateAutoCheckProvider, apkPath, apply, build, check, client, current, dismiss (+26 more)

### Community 60 - "fluttergran"
Cohesion: 0.15
Nodes (12): Board protocol, in one paragraph, Commands, Dependency constraints (learned the hard way), fluttergran, graphify, Hardware day (done), Layering rule, Parallel work: one worktree per worker (+4 more)

### Community 61 - "The GranBoard 132"
Cohesion: 0.29
Nodes (7): Non-dart frames, See also, The GranBoard 132, The matrix, The segment table, What is confirmed, and what is not, What kind of device it is

### Community 62 - "atc_leg_state.dart"
Cohesion: 0.09
Nodes (20): AtcTurn, config, currentPlayerId, currentPlayerIndex, currentStopFor, currentTurnDarts, darts, dartsLeftThisTurn (+12 more)

### Community 63 - "Chalk"
Cohesion: 0.25
Nodes (8): Chalk, Documentation, Generated assets, How it is put together, Licence notes, Quick start, Testing, What it does

### Community 64 - "Table"
Cohesion: 0.22
Nodes (7): AtcGames, BullingGames, DartEvents, Games, GameSeats, Matches, Players

### Community 66 - "Bulling Game Mode Implementation Plan"
Cohesion: 0.09
Nodes (21): Bulling Game Mode Implementation Plan, Design, precisely, Domain (`lib/domain/bulling/`), Global Constraints, Out of scope for this pass, Persistence, Self-review notes, Stats (`lib/domain/stats/bulling_stats.dart`, `part of 'mode_stats.dart'`) (+13 more)

### Community 67 - "rule_board.dart"
Cohesion: 0.12
Nodes (12): build, _controller, createState, _curve, didUpdateWidget, _dim, dispose, _from (+4 more)

### Community 68 - "mode_layout_test.dart"
Cohesion: 0.06
Nodes (22): board, container, database, main, _modeName, pump, repository, _atc (+14 more)

### Community 69 - "worker.md"
Cohesion: 0.50
Nodes (3): Contract, Project, Reporting back

### Community 70 - "package:fluttergran/domain/segment.dart"
Cohesion: 0.03
Nodes (59): AtcVariant, ThrownDart, X01RuleDartChecks, board, clock, container, controller, dbull (+51 more)

### Community 71 - "FlutterWindow"
Cohesion: 0.12
Nodes (4): FlutterWindow, flutter_controller_, FlutterWindow::FlutterWindow(), project_

### Community 73 - ".Create"
Cohesion: 0.19
Nodes (5): Scale(), Win32Window::Win32Window(), WindowClassRegistrar, class_registered_, instance_

### Community 74 - "led_reactions_test.dart"
Cohesion: 0.06
Nodes (25): at, bull, config, main, throwing, board, container, controller (+17 more)

### Community 78 - "MaterialPageRoute"
Cohesion: 0.16
Nodes (13): bullingLightsProvider, bullingGameProvider, bullingSoundControllerProvider, build, BullingGameScreen, _playAgain, _start, build (+5 more)

### Community 79 - "int?"
Cohesion: 0.15
Nodes (9): bullingPointsFor, foldBulling, initialBullingLegState, playerIndex, score, turnDarts, turns, turnStart (+1 more)

### Community 81 - "resumable_leg_provider_test.dart"
Cohesion: 0.05
Nodes (34): GameRepository, database, main, repository, seedAtcGame, database, main, repository (+26 more)

### Community 82 - "fake_update.dart"
Cohesion: 0.11
Nodes (18): allowed, apkBytes, apkName, base, browserOpens, canInstall, checksAtLaunch, currentVersion (+10 more)

### Community 83 - "currentGameIdProvider"
Cohesion: 0.08
Nodes (39): _persist, _persist, _persist, _persist, higherLowerLightsProvider, build, config, decidedLegs (+31 more)

### Community 84 - "dart"
Cohesion: 0.06
Nodes (33): dart, big, _brandGreen, bust, command, connected, _flashFor, _forestGreen (+25 more)

### Community 85 - "free_practice_state.dart"
Cohesion: 0.14
Nodes (12): currentTurnDarts, darts, dartsThrown, foldFreePractice, FreePracticeState, FreePracticeTurn, initialFreePracticeState, oneEightyCount (+4 more)

### Community 86 - "dart"
Cohesion: 0.08
Nodes (26): dart, after, all, atcRing, before, bullingRing, checkoutRing, colours (+18 more)

### Community 87 - "utils.cpp"
Cohesion: 0.17
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 88 - "devices.dart"
Cohesion: 0.11
Nodes (12): l10n, L10nContext, nameFor, laptop, monitor, phoneLandscape, phonePortrait, setViewSize (+4 more)

### Community 89 - "higher_lower_controller.dart"
Cohesion: 0.11
Nodes (16): acknowledgedTurns, addDart, awaitingTurnConfirm, confirmTurn, endTurn, handleBoardEvent, HigherLowerSession, leave (+8 more)

### Community 90 - "pump.dart"
Cohesion: 0.11
Nodes (14): app, closeApp, launchApp, media, popRoute, pump, pumpApp, pumpFrames (+6 more)

### Community 92 - "package:flutter/material.dart"
Cohesion: 0.04
Nodes (43): RulesTopic, RulesTopicPresentation, build, rulesContentWidth, topic, build, _cards, createState (+35 more)

### Community 93 - "github_releases.dart"
Cohesion: 0.07
Nodes (24): apkNameFor, AppRelease, assets, checksums, checksumsUrl, _client, GitHubReleases, json (+16 more)

### Community 94 - "end_screen_test.dart"
Cohesion: 0.14
Nodes (10): board, checkout, container, database, inFigures, main, open, repository (+2 more)

### Community 96 - "board_lifecycle.dart"
Cohesion: 0.12
Nodes (14): BoardToast, boardToastFor, context, disposed, l10n, lifecycle, messenger, null (+6 more)

### Community 97 - "aim_strip.dart"
Cohesion: 0.12
Nodes (14): AimStrip, alternatives, build, caption, chips, dartsLeft, footnote, hero (+6 more)

### Community 98 - "bool get"
Cohesion: 0.14
Nodes (11): all, hashCode, innerBull, isDouble, label, multiplier, number, operator (+3 more)

### Community 99 - "aim_card.dart"
Cohesion: 0.14
Nodes (11): Aim, AimCard, aimCardKey, aimsFor, bed, build, dartsLeft, hero (+3 more)

### Community 101 - "Releasing"
Cohesion: 0.17
Nodes (12): Android signing key (strongly recommended), Changing the toolchain, CI on the release PR (optional), In-app updates, One-time setup, Pinned actions, Releasing, Starting point (+4 more)

### Community 103 - "atc_stop.dart"
Cohesion: 0.13
Nodes (11): CurrentGameId, AtcStop, _bull, clears, label, number, _numbered, ring (+3 more)

### Community 104 - "higher_lower_reducer.dart"
Cohesion: 0.14
Nodes (10): eliminated, foldHigherLower, higher, initialHigherLowerLegState, lower, playerIndex, total, turnDarts (+2 more)

### Community 105 - "release-please-config.json"
Cohesion: 0.50
Nodes (3): bootstrap-sha, packages, $schema

### Community 106 - "x01_setup_screen.dart"
Cohesion: 0.04
Nodes (42): resumableLegProvider, x01DefaultsProvider, AtcSetupScreen, build, createState, _seats, _variant, build (+34 more)

### Community 107 - "Point"
Cohesion: 0.50
Nodes (3): Point, x, y

### Community 110 - "int get"
Cohesion: 0.12
Nodes (10): points, three, higherLowerPointsFor, hashCode, label, miss, operator, segment (+2 more)

### Community 111 - "dart_keypad.dart"
Cohesion: 0.12
Nodes (16): build, createState, _enter, highlight, highlighted, _isHighlighted, _Key, _KeyState (+8 more)

### Community 112 - "ConsumerWidget"
Cohesion: 0.15
Nodes (23): atcLightsProvider, ring, x01LightsProvider, atcSoundControllerProvider, checkoutTableProvider, decidedMatchLegsProvider, gameProvider, matchProvider (+15 more)

### Community 113 - "splash_screen_test.dart"
Cohesion: 0.14
Nodes (7): board, container, database, main, pump, main, main

### Community 114 - "List"
Cohesion: 0.05
Nodes (27): _alternates, build, CheckoutCard, checkoutNextDartKey, dartsLeft, hero, padding, remaining (+19 more)

### Community 115 - "dartdoc"
Cohesion: 0.13
Nodes (14): markdown, App, Data, Domain, Game modes, dartdoc, categories, categoryOrder (+6 more)

### Community 116 - "Map"
Cohesion: 0.12
Nodes (11): buttonCode, granboardSegmentMap, innerBullCode, missCode, outerBullCode, _ringOrder, unusedMatrixSlots, wedgeCodes (+3 more)

### Community 117 - "atc_reducer.dart"
Cohesion: 0.15
Nodes (8): foldAroundTheClock, initialAtcLegState, playerIndex, stopIndex, turnDarts, turns, turnStart, winnerId

### Community 118 - "apk_download.dart"
Cohesion: 0.10
Nodes (17): actual, add, close, _deleteIfThere, digest, _DigestSink, downloadVerified, expected (+9 more)

### Community 119 - "analyzer"
Cohesion: 0.17
Nodes (11): analyzer, errors, exclude, language, invalid_annotation_target, include, strict-casts, strict-inference (+3 more)

### Community 120 - "update_platform.dart"
Cohesion: 0.11
Nodes (12): canInstall, _channel, checksAtLaunch, currentVersion, DeviceUpdatePlatform, downloadDirectory, installApk, InstallResult (+4 more)

### Community 121 - "board_connection_button.dart"
Cohesion: 0.24
Nodes (8): boardConnectionProvider, boardSourceProvider, build, BoardConnectionButton, build, _onTap, build, GameAppBar

### Community 122 - "update_controller_test.dart"
Cohesion: 0.15
Nodes (8): containerWith, directory, installApk, main, platform, _ThrowingInstall, main, FakeUpdatePlatform

### Community 123 - "labels.dart"
Cohesion: 0.18
Nodes (7): atcVariantLabel, bullseyeValueLabel, gameModeName, hitRateText, l10n, x01InRuleLabel, x01OutRuleLabel

### Community 124 - "game_config.dart"
Cohesion: 0.18
Nodes (9): GameConfigController, GameConfig, inRule, maxPlayers, offeredStartScores, outRule, playerIds, startingSeat (+1 more)

### Community 125 - "sound_player.dart"
Cohesion: 0.12
Nodes (13): _cues, dispose, _disposed, _fire, _live, _pending, playCue, playSpeech (+5 more)

### Community 126 - "release_version.dart"
Cohesion: 0.15
Nodes (10): compareTo, hashCode, major, minor, operator, patch, _pattern, ReleaseVersion (+2 more)

### Community 127 - "checkout_table.dart"
Cohesion: 0.20
Nodes (7): bestFor, _cache, CheckoutTable, isCheckoutRange, limit, outRule, routesFor

### Community 128 - "Around the Clock — design"
Cohesion: 0.20
Nodes (9): Around the Clock — design, Domain (`lib/domain/atc/`), Out of scope for this pass, Persistence, Rules, precisely, Stats (`lib/domain/stats/atc_stats.dart`, `part of 'mode_stats.dart'`), Summary, Testing (+1 more)

### Community 129 - "reconnect_delay_test.dart"
Cohesion: 0.20
Nodes (7): FixedRandom, main, nextBool, nextDouble, nextInt, _scanCooldownTests, value

### Community 130 - "Size"
Cohesion: 0.50
Nodes (3): Size, height, width

### Community 131 - "dart"
Cohesion: 0.25
Nodes (7): dart, build, darts, DartSlot, struck, total, TurnLedger

### Community 132 - "../../domain/x01/thrown_dart.dart"
Cohesion: 0.25
Nodes (5): after, before, _darts, sounds, soundsForTraining

### Community 133 - "FlutterGranApp"
Cohesion: 0.53
Nodes (6): boardLifecycleProvider, ledSchedulerProvider, localeProvider, updateLifecycleProvider, build, FlutterGranApp

### Community 134 - "TrainingGameScreen"
Cohesion: 0.53
Nodes (6): trainingLightsProvider, soundPlayerProvider, trainingProvider, trainingSoundControllerProvider, build, TrainingGameScreen

### Community 144 - "led_scheduler_test.dart"
Cohesion: 0.12
Nodes (14): EffectFrame, HitFlash, LedCommand, RingPaint, big, connected, gap, hit (+6 more)

### Community 149 - "[1.1.0](https://github.com/Filan-glitch/FlutterGran/compare/9be2ca2...v1.1.0) (2026-10-26)"
Cohesion: 0.29
Nodes (6): [1.1.0](https://github.com/Filan-glitch/FlutterGran/compare/9be2ca2...v1.1.0) (2026-10-26), [1.2.0](https://github.com/Filan-glitch/FlutterGran/compare/v1.1.0...v1.2.0) (2026-10-26), Changelog, Documentation, Features, Features

### Community 150 - "build"
Cohesion: 0.26
Nodes (11): _perform, ledCelebrationsProvider, ledDartFlashesProvider, ledEnabledProvider, _play, _silenceWhenSwitchedOff, soundEnabledProvider, speechEnabledProvider (+3 more)

### Community 169 - "int?"
Cohesion: 0.17
Nodes (9): foldLeg, initialLegState, opened, playerIndex, remaining, turnDarts, turns, turnStart (+1 more)

### Community 176 - "State"
Cohesion: 0.13
Nodes (20): _PlayerTile, _PlayerTileState, RulesScreen, _RulesScreenState, _ModeTile, _ModeTileState, Pulse, _PulseState (+12 more)

### Community 187 - "../theme.dart"
Cohesion: 0.10
Nodes (18): build, label, onTap, SelectableTile, selected, build, busted, caption (+10 more)

### Community 191 - "game_controller.dart"
Cohesion: 0.05
Nodes (35): acknowledgedTurns, addDart, awaitingTurnConfirm, confirmTurn, endTurn, GameSession, handleBoardEvent, leave (+27 more)

### Community 200 - "atc_controller.dart"
Cohesion: 0.05
Nodes (36): acknowledgedTurns, addDart, AtcSession, awaitingTurnConfirm, confirmTurn, endTurn, handleBoardEvent, leave (+28 more)

### Community 207 - "x01_rules.dart"
Cohesion: 0.18
Nodes (11): abbreviation, checksOut, checksOutUnder, label, opens, opensUnder, _qualifies, X01InRule (+3 more)

### Community 216 - "led_scheduler.dart"
Cohesion: 0.08
Nodes (22): _ambient, _deliver, dispose, _disposed, _enabled, enterGame, _gateClosed, _gateTimer (+14 more)

### Community 217 - "Feature ideas (not yet built)"
Cohesion: 0.33
Nodes (6): Candidate game modes, Feature ideas (not yet built), How a mode fits the existing architecture, Process note, Quality-of-life, Stats / data features

### Community 219 - "game_layout.dart"
Cohesion: 0.10
Nodes (17): aim, child, confirm, _confirmLeave, _desktopScoreShareWidth, GameLayout, gameOver, keypad (+9 more)

### Community 227 - "main_menu_screen.dart"
Cohesion: 0.07
Nodes (18): child, _FullHeightScrollView, icon, label, _MenuRow, names, onResume, onTap (+10 more)

### Community 230 - "AppLocalizations"
Cohesion: 0.33
Nodes (5): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsDe, AppLocalizationsEn, of

### Community 233 - "Rules section"
Cohesion: 0.40
Nodes (5): Building blocks - `lib/app/widgets/rules/`, Rules section, Screens, Tests, The rule this section must not break

### Community 238 - "lights_providers.dart"
Cohesion: 0.15
Nodes (7): LedScheduler, connection, _drive, _gateRing, paint, scheduler, source

## Knowledge Gaps
- **2758 isolated node(s):** `leg`, `acknowledgedTurns`, `awaitingTurnConfirm`, `pendingTurn`, `_live` (+2753 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 3276 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **32 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppDatabase` connect `migration_test.dart` to `mode_layout_test.dart`, `database.dart`, `package:fluttergran/domain/segment.dart`, `providers.dart`, `package:flutter_test/flutter_test.dart`, `led_reactions_test.dart`, `game_repository.dart`, `resumable_leg_provider_test.dart`, `splash_screen_test.dart`, `package:flutter_riverpod/flutter_riverpod.dart`, `update_card_test.dart`, `end_screen_test.dart`?**
  _High betweenness centrality (0.026) - this node is a cross-community bridge._
- **What connects `leg`, `acknowledgedTurns`, `awaitingTurnConfirm` to the rest of the system?**
  _2758 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.g.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03278688524590164 - nodes in this community are weakly interconnected._
- **Why does `dart` connect `dart` to `../theme.dart`, `frame_assembler.dart`, `lights_providers.dart`, `led_scheduler_test.dart`, `led_command.dart`, `List`, `led_scheduler.dart`?**
  _High betweenness centrality (0.026) - this node is a cross-community bridge._
- **Should `theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.025 - nodes in this community are weakly interconnected._
- **Why does `FakeBoardSource` connect `FakeBoardSource` to `mode_layout_test.dart`, `package:fluttergran/domain/segment.dart`, `led_reactions_test.dart`, `fake_board_source.dart`, `resumable_leg_provider_test.dart`, `board_source.dart`, `splash_screen_test.dart`, `package:flutter_riverpod/flutter_riverpod.dart`, `update_card_test.dart`, `end_screen_test.dart`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **Should `checkout_search.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06896551724137931 - nodes in this community are weakly interconnected._