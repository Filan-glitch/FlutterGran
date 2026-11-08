# Graph Report - FlutterGran-training-drills  (2026-11-08)

## Corpus Check
- 264 files · ~201,961 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 26 file(s) not represented in the graph (top: .xml 10, (none) 5, .properties 2)

## Summary
- 4919 nodes · 7210 edges · 180 communities (146 shown, 34 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 24 edges (avg confidence: 0.87)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `bdb2c6fa`
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
- package:flutter/material.dart
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
- responsive_layout_test.dart
- stats_screen.dart
- training_setup_screen_test.dart
- Win32Window
- higher_lower_leg_state.dart
- make_icon.py
- roster_screen.dart
- dependencies
- StatelessWidget
- package:flutter_riverpod/flutter_riverpod.dart
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
- splash_screen.dart
- training_setup_screen.dart
- Player
- Development
- main.dart
- Data model
- ../../theme.dart
- app_localizations_en.dart
- Recipes
- DateTime
- Architecture
- The board protocol
- return
- select_game_mode_screen.dart
- apk_download_test.dart
- checkout_challenge.dart
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
- training_controller.dart
- persistence_test.dart
- fake_update.dart
- currentGameIdProvider
- dart
- int?
- dart
- utils.cpp
- devices.dart
- higher_lower_controller.dart
- pump.dart
- package:flutter/material.dart
- github_releases.dart
- deploy
- generated_plugin_registrant.cc
- board_lifecycle.dart
- aim_strip.dart
- bool get
- rules_topic.dart
- Releasing
- .MessageHandler
- scoreboard.dart
- higher_lower_reducer.dart
- release-please-config.json
- x01_setup_screen.dart
- Point
- check_version.sh
- release_notes.sh
- int get
- dart_keypad.dart
- ConsumerWidget
- weak_spot.dart
- int get
- dartdoc
- Map
- bobs_27.dart
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
- dart
- aim_records.dart
- ladder_121.dart
- check.sh
- async.dart
- led_scheduler_test.dart
- [1.1.0](https://github.com/Filan-glitch/FlutterGran/compare/9be2ca2...v1.1.0) (2026-10-26)
- build
- aim_target.dart
- training_game_screen.dart
- _
- match_controller.dart
- higherLowerGameProvider
- higher_lower_config.dart
- Start here
- KnownBoardController
- CustomPainter
- ../segment.dart
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
2. `dart` - 45 edges
3. `dart` - 44 edges
4. `currentGameIdProvider` - 32 edges
5. `AppDatabase` - 29 edges
6. `FakeBoardSource` - 28 edges
7. `_` - 25 edges
8. `gameRepositoryProvider` - 24 edges
9. `Win32Window` - 21 edges
10. `Bulling Game Mode Implementation Plan` - 21 edges

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

## Communities (180 total, 34 thin omitted)

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
Cohesion: 0.03
Nodes (62): _perform, allAtcLegsProvider, allBullingLegsProvider, allHigherLowerLegsProvider, allLegsProvider, allMatchesProvider, AtcConfigController, boardReaderProvider (+54 more)

### Community 8 - "package:flutter/material.dart"
Cohesion: 0.04
Nodes (43): angle, at, hit, main, radius, main, pumpApp, pumpBoardIn (+35 more)

### Community 9 - "sound.dart"
Cohesion: 0.20
Nodes (10): SoundPlayer, AudioPlayersSoundPlayer, cues, dispose, MuteSoundPlayer, playCue, playSpeech, RecordingSoundPlayer (+2 more)

### Community 10 - "board_widget.dart"
Cohesion: 0.06
Nodes (33): _black, BoardGeometry, boardWedgeOrder, BoardWidget, build, _cream, dimColour, dimUnheated (+25 more)

### Community 11 - "game_repository.dart"
Cohesion: 0.04
Nodes (44): addPlayer, allPlayers, appendDart, _aroundTheClock, _bulling, db, deleteGame, findResumableGameId (+36 more)

### Community 12 - "game_screen.dart"
Cohesion: 0.08
Nodes (16): _clearedThisTurn, _figures, _gain, _movedOn, _figures, _gain, _figures, _legWon (+8 more)

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
Nodes (35): a, b, black, byNumber, c, code, colourOf, effect (+27 more)

### Community 19 - "board_source.dart"
Cohesion: 0.06
Nodes (26): BleBoardSource, assembler, boardName, BoardSource, codec, connect, connectionState, currentState (+18 more)

### Community 20 - "led_cue.dart"
Cohesion: 0.08
Nodes (34): BoardConnected, DartLanded, DartMissed, GameOn, hashCode, kind, LedCue, LedCueKind (+26 more)

### Community 22 - "responsive_layout_test.dart"
Cohesion: 0.04
Nodes (34): FakeBoardSource, board, checkout, container, database, inFigures, main, open (+26 more)

### Community 23 - "stats_screen.dart"
Cohesion: 0.10
Nodes (18): child, createState, _decimal, detail, _Empty, _FadeIn, _Headline, label (+10 more)

### Community 24 - "training_setup_screen_test.dart"
Cohesion: 0.05
Nodes (33): RulesDetailScreen, close, container, database, open, repository, waitOutUndo, choose (+25 more)

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
Cohesion: 0.09
Nodes (21): _addPlayer, _commit, _controller, createState, didUpdateWidget, dispose, _editing, _focusNode (+13 more)

### Community 29 - "dependencies"
Cohesion: 0.05
Nodes (39): dependencies, audioplayers, crypto, drift, drift_flutter, flutter, flutter_blue_plus, flutter_localizations (+31 more)

### Community 30 - "StatelessWidget"
Cohesion: 0.06
Nodes (34): AnimatedFigure, CenteredContent, EntrancePop, _aroundTheClock, _AtcRoute, body, build, _bulling (+26 more)

### Community 31 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.05
Nodes (39): board, clock, container, controller, main, session, board, clock (+31 more)

### Community 32 - "app_localizations.dart"
Cohesion: 0.01
Nodes (382): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+374 more)

### Community 33 - "Connectivity"
Cohesion: 0.12
Nodes (17): A forgiving characteristic lookup, Android, Connecting from the app, Connection lifecycle, Connectivity, GATT, Licensing note, Permissions (+9 more)

### Community 34 - "../theme.dart"
Cohesion: 0.07
Nodes (24): _bestDart, BoundsCard, boundsCardKey, _BoundTile, build, dartsLeft, figure, hero (+16 more)

### Community 35 - "sound_player_test.dart"
Cohesion: 0.05
Nodes (37): binding, create, dispose, emitError, emitGlobalError, emitGlobalLog, emitLog, _events (+29 more)

### Community 36 - "bulling_leg_state.dart"
Cohesion: 0.09
Nodes (20): BullingTurn, config, currentPlayerId, currentPlayerIndex, currentTurnDarts, darts, dartsLeftThisTurn, dartsThrownBy (+12 more)

### Community 37 - "app_localizations_de.dart"
Cohesion: 0.01
Nodes (374): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+366 more)

### Community 38 - "game_over_card.dart"
Cohesion: 0.05
Nodes (32): build, column, columns, error, eyebrow, FigureColumn, FigureRow, _Figures (+24 more)

### Community 39 - "with"
Cohesion: 0.06
Nodes (30): needs, uses, with, runs-on, steps, timeout-minutes, concurrency, cancel-in-progress (+22 more)

### Community 40 - "rule_explorer.dart"
Cohesion: 0.08
Nodes (20): _board, build, createState, explanation, id, initial, label, legend (+12 more)

### Community 41 - "frame_assembler.dart"
Cohesion: 0.15
Nodes (10): _buffer, dedupeWindow, feed, FrameAssembler, _greeting, _isRepeat, _lastAt, _lastBody (+2 more)

### Community 42 - "setup_controls.dart"
Cohesion: 0.12
Nodes (15): build, buttonKey, ChoiceRow, label, _Numeral, NumeralChoiceRow, onPressed, onSelected (+7 more)

### Community 43 - "splash_screen.dart"
Cohesion: 0.08
Nodes (29): playersProvider, playerStatsProvider, resumableLegProvider, segmentCountsProvider, AtcSetupScreen, BullingSetupScreen, HigherLowerSetupScreen, _HigherLowerSetupScreenState (+21 more)

### Community 44 - "training_setup_screen.dart"
Cohesion: 0.07
Nodes (25): aimRecordsProvider, _band, build, createState, _drill, _DrillChoice, _focus, label (+17 more)

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

### Community 49 - "../../theme.dart"
Cohesion: 0.05
Nodes (32): detail, enabled, label, _LanguageChoice, onChanged, _SettingSwitch, value, AddPlayerField (+24 more)

### Community 50 - "app_localizations_en.dart"
Cohesion: 0.01
Nodes (374): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+366 more)

### Community 51 - "Recipes"
Cohesion: 0.09
Nodes (22): Add a database column or table, Add a game mode, Add a localized string, Add a provider, Add a sound, Add a test, Add a training drill, Add an LED cue (+14 more)

### Community 52 - "DateTime"
Cohesion: 0.12
Nodes (10): advance, bytes, call, FakeClock, main, now, advance, now (+2 more)

### Community 53 - "Architecture"
Cohesion: 0.12
Nodes (16): Architecture, Audio, Checkouts, Everything is a fold, Game modes, Layout, Lights, Matches (+8 more)

### Community 54 - "The board protocol"
Cohesion: 0.15
Nodes (13): Connection lifecycle, Decoding, Effect frames: 16 bytes, Frame assembly, Hardware day, In one paragraph, LED control, Playing without a board (+5 more)

### Community 55 - "return"
Cohesion: 0.11
Nodes (12): after, before, sounds, soundsForAtc, after, before, sounds, soundsForBulling (+4 more)

### Community 56 - "select_game_mode_screen.dart"
Cohesion: 0.09
Nodes (15): _ComingSoonTile, createState, mode, modes, _pressed, SelectGameModeScreen, _setPressed, _setupScreenFor (+7 more)

### Community 57 - "apk_download_test.dart"
Cohesion: 0.12
Nodes (10): ChecksumMismatch, UpdateCheckException, bytes, directory, main, serving, target, url (+2 more)

### Community 58 - "checkout_challenge.dart"
Cohesion: 0.05
Nodes (40): attempts, band, checkoutLevelBand, checkoutLevelCount, checkoutLevelWidth, checkoutMissesToDrop, checkoutPool, checkouts (+32 more)

### Community 59 - "update_controller.dart"
Cohesion: 0.07
Nodes (32): apkPath, apply, build, check, client, current, dismiss, disposed (+24 more)

### Community 60 - "fluttergran"
Cohesion: 0.15
Nodes (12): Board protocol, in one paragraph, Commands, Dependency constraints (learned the hard way), fluttergran, graphify, Hardware day (done), Layering rule, Parallel work: one worktree per worker (+4 more)

### Community 61 - "The GranBoard 132"
Cohesion: 0.29
Nodes (7): Non-dart frames, See also, The GranBoard 132, The matrix, The segment table, What is confirmed, and what is not, What kind of device it is

### Community 62 - "atc_leg_state.dart"
Cohesion: 0.09
Nodes (21): AtcLegState, AtcTurn, config, currentPlayerId, currentPlayerIndex, currentStopFor, currentTurnDarts, darts (+13 more)

### Community 63 - "Chalk"
Cohesion: 0.22
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
Cohesion: 0.04
Nodes (36): board, container, database, main, _modeName, pump, repository, _atc (+28 more)

### Community 69 - "worker.md"
Cohesion: 0.50
Nodes (3): Contract, Project, Reporting back

### Community 70 - "package:fluttergran/domain/segment.dart"
Cohesion: 0.04
Nodes (39): ThrownDart, coords, main, parts, config, dbull, main, sbull (+31 more)

### Community 71 - "FlutterWindow"
Cohesion: 0.12
Nodes (4): FlutterWindow, flutter_controller_, FlutterWindow::FlutterWindow(), project_

### Community 73 - ".Create"
Cohesion: 0.18
Nodes (5): Scale(), Win32Window::Win32Window(), WindowClassRegistrar, class_registered_, instance_

### Community 74 - "led_reactions_test.dart"
Cohesion: 0.06
Nodes (24): at, bull, config, main, throwing, board, clock, container (+16 more)

### Community 78 - "MaterialPageRoute"
Cohesion: 0.15
Nodes (15): trainingLightsProvider, soundPlayerProvider, trainingProvider, trainingSoundControllerProvider, x01DefaultsProvider, build, build, TrainingGameScreen (+7 more)

### Community 79 - "training_controller.dart"
Cohesion: 0.06
Nodes (38): addDart, Bobs27Plan, Bobs27Session, _challenge, CheckoutChallengePlan, CheckoutChallengeSession, CheckoutPracticePlan, CheckoutPracticeSession (+30 more)

### Community 81 - "persistence_test.dart"
Cohesion: 0.06
Nodes (32): GameRepository, database, main, repository, seedAtcGame, database, main, repository (+24 more)

### Community 82 - "fake_update.dart"
Cohesion: 0.11
Nodes (18): allowed, apkBytes, apkName, base, browserOpens, canInstall, checksAtLaunch, currentVersion (+10 more)

### Community 83 - "currentGameIdProvider"
Cohesion: 0.15
Nodes (34): AtcController, build, _persist, build, BullingController, _persist, build, GameController (+26 more)

### Community 84 - "dart"
Cohesion: 0.06
Nodes (33): dart, big, _brandGreen, bust, command, connected, _flashFor, _forestGreen (+25 more)

### Community 85 - "int?"
Cohesion: 0.05
Nodes (30): CurrentGameId, foldAroundTheClock, initialAtcLegState, playerIndex, stopIndex, turnDarts, turns, turnStart (+22 more)

### Community 86 - "dart"
Cohesion: 0.07
Nodes (30): dart, after, _aimCue, aimRing, all, atcRing, _attemptCues, before (+22 more)

### Community 87 - "utils.cpp"
Cohesion: 0.18
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
Cohesion: 0.06
Nodes (31): RulesTopic, RulesTopicPresentation, build, rulesContentWidth, topic, build, _cards, createState (+23 more)

### Community 93 - "github_releases.dart"
Cohesion: 0.07
Nodes (24): apkNameFor, AppRelease, assets, checksums, checksumsUrl, _client, GitHubReleases, json (+16 more)

### Community 94 - "deploy"
Cohesion: 0.06
Nodes (35): runs-on, steps, timeout-minutes, concurrency, cancel-in-progress, group, environment, needs (+27 more)

### Community 96 - "board_lifecycle.dart"
Cohesion: 0.12
Nodes (14): BoardToast, boardToastFor, context, disposed, l10n, lifecycle, messenger, null (+6 more)

### Community 97 - "aim_strip.dart"
Cohesion: 0.07
Nodes (23): AimStrip, alternatives, build, caption, chips, dartsLeft, footnote, hero (+15 more)

### Community 98 - "bool get"
Cohesion: 0.07
Nodes (22): AtcStop, _bull, clears, label, number, _numbered, ring, toString (+14 more)

### Community 99 - "rules_topic.dart"
Cohesion: 0.07
Nodes (21): displayName, facts, icon, objective, of, overview, _registryName, RulesFact (+13 more)

### Community 101 - "Releasing"
Cohesion: 0.15
Nodes (12): Android signing key (strongly recommended), Changing the toolchain, CI on the release PR (optional), In-app updates, One-time setup, Pinned actions, Releasing, Starting point (+4 more)

### Community 103 - "scoreboard.dart"
Cohesion: 0.06
Nodes (30): accent, alignment, build, caption, colour, count, expand, _Figure (+22 more)

### Community 104 - "higher_lower_reducer.dart"
Cohesion: 0.14
Nodes (10): eliminated, foldHigherLower, higher, initialHigherLowerLegState, lower, playerIndex, total, turnDarts (+2 more)

### Community 105 - "release-please-config.json"
Cohesion: 0.50
Nodes (3): bootstrap-sha, packages, $schema

### Community 106 - "x01_setup_screen.dart"
Cohesion: 0.06
Nodes (25): build, createState, _seats, _variant, build, _bullseyeValue, createState, _seats (+17 more)

### Community 107 - "Point"
Cohesion: 0.50
Nodes (3): Point, x, y

### Community 110 - "int get"
Cohesion: 0.22
Nodes (7): hashCode, label, miss, operator, segment, toString, value

### Community 111 - "dart_keypad.dart"
Cohesion: 0.12
Nodes (16): build, createState, _enter, highlight, highlighted, _isHighlighted, _Key, _KeyState (+8 more)

### Community 112 - "ConsumerWidget"
Cohesion: 0.13
Nodes (24): atcLightsProvider, bullingLightsProvider, x01LightsProvider, atcSoundControllerProvider, bullingSoundControllerProvider, decidedMatchLegsProvider, gameProvider, matchProvider (+16 more)

### Community 113 - "weak_spot.dart"
Cohesion: 0.06
Nodes (30): combined, config, currentTarget, currentVisitDarts, darts, dartsLeftThisVisit, doubles, drawWeakSpotTarget (+22 more)

### Community 114 - "int get"
Cohesion: 0.15
Nodes (7): bullseyeValue, offeredTargets, playerIds, target, BullseyeValue, points, three

### Community 115 - "dartdoc"
Cohesion: 0.14
Nodes (13): markdown, App, Data, Domain, Game modes, dartdoc, categories, categoryOrder (+5 more)

### Community 116 - "Map"
Cohesion: 0.13
Nodes (11): buttonCode, granboardSegmentMap, innerBullCode, missCode, outerBullCode, _ringOrder, unusedMatrixSlots, wedgeCodes (+3 more)

### Community 117 - "bobs_27.dart"
Cohesion: 0.08
Nodes (24): Bobs27Config, bobs27MaxScore, bobs27StartScore, Bobs27State, bobs27Targets, Bobs27Visit, config, currentTarget (+16 more)

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
Cohesion: 0.21
Nodes (8): boardConnectionProvider, boardSourceProvider, build, BoardConnectionButton, build, _onTap, build, GameAppBar

### Community 122 - "update_controller_test.dart"
Cohesion: 0.15
Nodes (8): containerWith, directory, installApk, main, platform, _ThrowingInstall, main, FakeUpdatePlatform

### Community 123 - "labels.dart"
Cohesion: 0.14
Nodes (10): atcVariantLabel, bullseyeValueLabel, gameModeName, hitRateText, l10n, missDirectionLabel, rateText, weakSpotFocusLabel (+2 more)

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
Cohesion: 0.22
Nodes (7): dart, build, darts, DartSlot, struck, total, TurnLedger

### Community 132 - "dart"
Cohesion: 0.22
Nodes (7): dart, _attemptSounds, bust, checkout, index, _legSounds, soundsForTraining

### Community 133 - "aim_records.dart"
Cohesion: 0.08
Nodes (17): add, AimRecord, atcLegs, _atcTarget, attempts, bullingLegs, hashCode, hits (+9 more)

### Community 134 - "ladder_121.dart"
Cohesion: 0.08
Nodes (20): attempts, completed, config, current, darts, foldLadder121, isFinished, Ladder121Config (+12 more)

### Community 144 - "led_scheduler_test.dart"
Cohesion: 0.13
Nodes (11): LedScheduler, big, connected, gap, hit, idle, main, scheduler (+3 more)

### Community 149 - "[1.1.0](https://github.com/Filan-glitch/FlutterGran/compare/9be2ca2...v1.1.0) (2026-10-26)"
Cohesion: 0.22
Nodes (8): [1.1.0](https://github.com/Filan-glitch/FlutterGran/compare/9be2ca2...v1.1.0) (2026-10-26), [1.2.0](https://github.com/Filan-glitch/FlutterGran/compare/v1.1.0...v1.2.0) (2026-10-26), [1.2.1](https://github.com/Filan-glitch/FlutterGran/compare/v1.2.0...v1.2.1) (2026-11-08), Changelog, Documentation, Documentation, Features, Features

### Community 150 - "build"
Cohesion: 0.21
Nodes (15): boardLifecycleProvider, ledSchedulerProvider, localeProvider, _play, _silenceWhenSwitchedOff, soundEnabledProvider, speechEnabledProvider, updateAutoCheckProvider (+7 more)

### Community 153 - "aim_target.dart"
Cohesion: 0.10
Nodes (18): AimKind, AimTarget, bull, bullseye, double, hashCode, isBull, isHitBy (+10 more)

### Community 154 - "training_game_screen.dart"
Cohesion: 0.11
Nodes (14): _again, _aimStrip, _attemptLayout, _bedsOf, _betweenAttempts, _bobsLedger, _done, _freePracticeFigures (+6 more)

### Community 155 - "_"
Cohesion: 0.12
Nodes (16): _, attempts, CheckoutAttempt, dartsUsed, fold, isOver, leg, remaining (+8 more)

### Community 156 - "match_controller.dart"
Cohesion: 0.13
Nodes (13): build, config, decidedLegs, leave, legSettled, matchId, MatchSession, _recordedWinner (+5 more)

### Community 157 - "higherLowerGameProvider"
Cohesion: 0.38
Nodes (7): higherLowerLightsProvider, higherLowerGameProvider, higherLowerSoundControllerProvider, build, HigherLowerGameScreen, _playAgain, _start

### Community 158 - "higher_lower_config.dart"
Cohesion: 0.29
Nodes (4): minPlayers, playerIds, startHigher, startLower

### Community 159 - "Start here"
Cohesion: 0.33
Nodes (6): API docs, Check before pushing, Run, Setup, Start here, Where the docs live

### Community 160 - "KnownBoardController"
Cohesion: 0.40
Nodes (5): KnownBoardController, KnownBoardStore, NoKnownBoardStore, read, write

### Community 169 - "int?"
Cohesion: 0.17
Nodes (9): foldLeg, initialLegState, opened, playerIndex, remaining, turnDarts, turns, turnStart (+1 more)

### Community 176 - "State"
Cohesion: 0.14
Nodes (18): RulesScreen, _RulesScreenState, _ModeTile, _ModeTileState, Pulse, _PulseState, StaggeredEntry, _StaggeredEntryState (+10 more)

### Community 187 - "../theme.dart"
Cohesion: 0.14
Nodes (13): build, busted, caption, celebrate, child, darts, figure, finishing (+5 more)

### Community 191 - "game_controller.dart"
Cohesion: 0.11
Nodes (16): acknowledgedTurns, addDart, awaitingTurnConfirm, confirmTurn, endTurn, GameSession, handleBoardEvent, leave (+8 more)

### Community 200 - "atc_controller.dart"
Cohesion: 0.05
Nodes (33): acknowledgedTurns, addDart, AtcSession, awaitingTurnConfirm, confirmTurn, endTurn, handleBoardEvent, leave (+25 more)

### Community 207 - "x01_rules.dart"
Cohesion: 0.16
Nodes (12): abbreviation, checksOut, checksOutUnder, label, opens, opensUnder, _qualifies, X01InRule (+4 more)

### Community 216 - "led_scheduler.dart"
Cohesion: 0.08
Nodes (22): _ambient, _deliver, dispose, _disposed, _enabled, enterGame, _gateClosed, _gateTimer (+14 more)

### Community 217 - "Feature ideas (not yet built)"
Cohesion: 0.29
Nodes (6): Candidate game modes, Feature ideas (not yet built), How a mode fits the existing architecture, Process note, Quality-of-life, Stats / data features

### Community 219 - "game_layout.dart"
Cohesion: 0.10
Nodes (17): aim, child, confirm, _confirmLeave, _desktopScoreShareWidth, GameLayout, gameOver, keypad (+9 more)

### Community 227 - "main_menu_screen.dart"
Cohesion: 0.10
Nodes (11): child, _FullHeightScrollView, icon, label, _MenuRow, names, onResume, onTap (+3 more)

### Community 230 - "AppLocalizations"
Cohesion: 0.33
Nodes (5): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsDe, AppLocalizationsEn, of

### Community 233 - "Rules section"
Cohesion: 0.33
Nodes (5): Building blocks - `lib/app/widgets/rules/`, Rules section, Screens, Tests, The rule this section must not break

### Community 238 - "lights_providers.dart"
Cohesion: 0.10
Nodes (12): connection, _drive, _gateRing, paint, ring, scheduler, source, checkoutTableProvider (+4 more)

## Knowledge Gaps
- **3149 isolated node(s):** `checkout`, `bust`, `index`, `soundsForTraining`, `_attemptSounds` (+3144 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 3697 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **34 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppDatabase` connect `migration_test.dart` to `mode_layout_test.dart`, `database.dart`, `providers.dart`, `package:flutter/material.dart`, `game_repository.dart`, `persistence_test.dart`, `responsive_layout_test.dart`, `training_setup_screen_test.dart`?**
  _High betweenness centrality (0.024) - this node is a cross-community bridge._
- **What connects `checkout`, `bust`, `index` to the rest of the system?**
  _3149 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.g.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03278688524590164 - nodes in this community are weakly interconnected._
- **Why does `dart` connect `dart` to `../theme.dart`, `frame_assembler.dart`, `x01_setup_screen.dart`, `lights_providers.dart`, `led_command.dart`, `led_scheduler.dart`, `higher_lower_config.dart`?**
  _High betweenness centrality (0.016) - this node is a cross-community bridge._
- **Should `theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.025 - nodes in this community are weakly interconnected._
- **Why does `FakeBoardSource` connect `responsive_layout_test.dart` to `mode_layout_test.dart`, `package:flutter/material.dart`, `led_reactions_test.dart`, `persistence_test.dart`, `fake_board_source.dart`, `board_source.dart`, `led_cue.dart`, `training_setup_screen_test.dart`, `package:flutter_riverpod/flutter_riverpod.dart`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Should `checkout_search.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06896551724137931 - nodes in this community are weakly interconnected._