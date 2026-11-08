# Graph Report - FlutterGran-stats-redesign  (2026-11-09)

## Corpus Check
- 276 files · ~213,644 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 28 file(s) not represented in the graph (top: .xml 11, (none) 5, .properties 2)

## Summary
- 5308 nodes · 7771 edges · 191 communities (161 shown, 30 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 24 edges (avg confidence: 0.87)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `b2ae8832`
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
- atc_widget_test.dart
- win32_window.cpp
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
- aim_card.dart
- splash_screen.dart
- training_setup_screen.dart
- Player
- Development
- build
- Data model
- List
- app_localizations_en.dart
- Recipes
- atc_reducer.dart
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
- atc_stop.dart
- training_controller.dart
- end_screen_test.dart
- fake_update.dart
- currentGameIdProvider
- dart
- free_practice_state.dart
- dart
- utils.cpp
- devices.dart
- dart_keypad.dart
- pump.dart
- bulling_reducer.dart
- package:flutter/material.dart
- github_releases.dart
- deploy
- generated_plugin_registrant.cc
- board_lifecycle.dart
- aim_strip.dart
- bool get
- rules_topic.dart
- Releasing
- Map
- scoreboard.dart
- higher_lower_reducer.dart
- release-please-config.json
- main_menu_screen.dart
- Point
- check_version.sh
- release_notes.sh
- stats_charts.dart
- bulling_config.dart
- board_reader_test.dart
- weak_spot.dart
- stat_card.dart
- dartdoc
- x01_stats_tab.dart
- bobs_27.dart
- apk_download.dart
- analyzer
- update_platform.dart
- rule_callout.dart
- update_controller_test.dart
- higher_lower_config.dart
- game_config.dart
- sound_player.dart
- release_version.dart
- checkout_table.dart
- Around the Clock — design
- reconnect_delay_test.dart
- board_geometry_test.dart
- Set
- int get
- aim_records.dart
- ladder_121.dart
- check.sh
- async.dart
- led_scheduler_test.dart
- [1.1.0](https://github.com/Filan-glitch/FlutterGran/compare/9be2ca2...v1.1.0) (2026-10-26)
- ConsumerWidget
- aim_target.dart
- training_game_screen.dart
- _
- ../segment.dart
- player_picker.dart
- chalk_mark.dart
- Start here
- KnownBoardController
- x01_setup_screen.dart
- stats_format.dart
- bounds_card.dart
- higher_lower_stats.dart
- bulling_stats.dart
- String get
- int?
- mode
- build.yml
- with
- atc_stats.dart
- secrets
- steps
- State
- android-signed
- sign-android
- windows
- android
- env
- ModeStats
- game_controller.dart
- atc_controller.dart
- x01_rules.dart
- led_scheduler.dart
- Feature ideas (not yet built)
- game_layout.dart
- AppLocalizations
- Rules section
- _FakeAudioPlatform
- _FakeGlobalAudioPlatform

## God Nodes (most connected - your core abstractions)
1. `_` - 48 edges
2. `dart` - 45 edges
3. `dart` - 44 edges
4. `currentGameIdProvider` - 32 edges
5. `AppDatabase` - 30 edges
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

## Communities (191 total, 30 thin omitted)

### Community 0 - "database.g.dart"
Cohesion: 0.03
Nodes (60): _, actualTableName, _alias, allSchemaEntities, allTables, atcGamesRefs, attachedDatabase, bullingGamesRefs (+52 more)

### Community 1 - "theme.dart"
Cohesion: 0.02
Nodes (76): 1, AnimatedFigure, base, bluetoothAmber, bluetoothBlue, body, brand, build (+68 more)

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
Nodes (64): _perform, allAtcLegsProvider, allBullingLegsProvider, allHigherLowerLegsProvider, allLegsProvider, allMatchesProvider, AtcConfigController, boardReaderProvider (+56 more)

### Community 8 - "package:flutter/material.dart"
Cohesion: 0.03
Nodes (50): main, pumpApp, pumpBoardIn, tapped, main, choose, container, litIn (+42 more)

### Community 9 - "sound.dart"
Cohesion: 0.18
Nodes (10): SoundPlayer, AudioPlayersSoundPlayer, cues, dispose, MuteSoundPlayer, playCue, playSpeech, RecordingSoundPlayer (+2 more)

### Community 10 - "board_widget.dart"
Cohesion: 0.06
Nodes (33): _black, BoardGeometry, boardWedgeOrder, BoardWidget, build, _cream, dimColour, dimUnheated (+25 more)

### Community 11 - "game_repository.dart"
Cohesion: 0.04
Nodes (44): addPlayer, allPlayers, appendDart, _aroundTheClock, _bulling, db, deleteGame, findResumableGameId (+36 more)

### Community 12 - "game_screen.dart"
Cohesion: 0.06
Nodes (26): l10n, L10nContext, nameFor, _clearedThisTurn, _figures, _gain, _movedOn, _figures (+18 more)

### Community 13 - "mode_stats.dart"
Cohesion: 0.07
Nodes (47): average, averageDartsPerLegWon, bandFor, bestCheckout, bestTurn, checkoutRateFor, checkoutVisitRateFor, dartsToWinByStart (+39 more)

### Community 14 - "player_stats.dart"
Cohesion: 0.03
Nodes (56): atcLegs, bestCheckout, bestTurn, bullingLegs, checkoutsByRule, _checkoutTables, computeAtcStats, computeBullingStats (+48 more)

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
Cohesion: 0.05
Nodes (28): BoardConnectionController, BleBoardSource, assembler, BoardConnectionState, boardName, BoardSource, codec, connect (+20 more)

### Community 20 - "led_cue.dart"
Cohesion: 0.15
Nodes (19): BoardConnected, DartLanded, DartMissed, GameOn, hashCode, kind, LedCue, LedCueKind (+11 more)

### Community 22 - "responsive_layout_test.dart"
Cohesion: 0.07
Nodes (19): FakeBoardSource, board, container, database, main, openAt, repository, where (+11 more)

### Community 23 - "stats_screen.dart"
Cohesion: 0.12
Nodes (13): playedModesProvider, playersProvider, build, build, createState, _modeLabel, onChanged, _playerId (+5 more)

### Community 24 - "atc_widget_test.dart"
Cohesion: 0.12
Nodes (13): highlight, main, pumpApp, pumpKeypad, database, keypadKey, main, _modeName (+5 more)

### Community 25 - "win32_window.cpp"
Cohesion: 0.16
Nodes (5): EnableFullDpiSupportIfAvailable(), Win32Window, child_content_, quit_on_close_, window_handle_

### Community 26 - "higher_lower_leg_state.dart"
Cohesion: 0.06
Nodes (29): activePlayerIds, between, config, currentPlayerId, currentPlayerIndex, currentTurnDarts, darts, dartsLeftThisTurn (+21 more)

### Community 27 - "make_icon.py"
Cohesion: 0.06
Nodes (31): Generated assets, `tool/make_cues.py` — the four cues, `tool/make_icon.py` — the launcher icon, `tool/make_speech.py` — the commentary, bust(), checkout(), dart(), envelope() (+23 more)

### Community 28 - "roster_screen.dart"
Cohesion: 0.08
Nodes (23): _addPlayer, _commit, _controller, createState, didUpdateWidget, dispose, _editing, _focusNode (+15 more)

### Community 29 - "dependencies"
Cohesion: 0.05
Nodes (39): dependencies, audioplayers, crypto, drift, drift_flutter, flutter, flutter_blue_plus, flutter_localizations (+31 more)

### Community 30 - "StatelessWidget"
Cohesion: 0.05
Nodes (46): _aroundTheClock, _AtcRoute, body, build, _bulling, bullseye, child, createState (+38 more)

### Community 31 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.04
Nodes (48): BoardReader, board, clock, container, controller, main, session, board (+40 more)

### Community 32 - "app_localizations.dart"
Cohesion: 0.00
Nodes (413): addPlayerFieldLabel, againstThrowLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters (+405 more)

### Community 33 - "Connectivity"
Cohesion: 0.12
Nodes (17): A forgiving characteristic lookup, Android, Connecting from the app, Connection lifecycle, Connectivity, GATT, Licensing note, Permissions (+9 more)

### Community 34 - "../theme.dart"
Cohesion: 0.09
Nodes (19): ringColours, _Dart, build, caption, darts, ExampleDart, ExampleOutcome, note (+11 more)

### Community 35 - "sound_player_test.dart"
Cohesion: 0.05
Nodes (38): binding, create, dispose, emitError, emitGlobalError, emitGlobalLog, emitLog, _events (+30 more)

### Community 36 - "bulling_leg_state.dart"
Cohesion: 0.09
Nodes (21): BullingLegState, BullingTurn, config, currentPlayerId, currentPlayerIndex, currentTurnDarts, darts, dartsLeftThisTurn (+13 more)

### Community 37 - "app_localizations_de.dart"
Cohesion: 0.00
Nodes (405): addPlayerFieldLabel, againstThrowLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters (+397 more)

### Community 38 - "game_over_card.dart"
Cohesion: 0.06
Nodes (25): build, column, columns, error, eyebrow, FigureColumn, FigureRow, _Figures (+17 more)

### Community 39 - "with"
Cohesion: 0.06
Nodes (30): needs, uses, with, runs-on, steps, timeout-minutes, concurrency, cancel-in-progress (+22 more)

### Community 40 - "rule_explorer.dart"
Cohesion: 0.11
Nodes (17): _board, build, createState, explanation, id, initial, label, legend (+9 more)

### Community 41 - "frame_assembler.dart"
Cohesion: 0.15
Nodes (10): _buffer, dedupeWindow, feed, FrameAssembler, _greeting, _isRepeat, _lastAt, _lastBody (+2 more)

### Community 42 - "aim_card.dart"
Cohesion: 0.07
Nodes (20): Aim, AimCard, aimCardKey, aimsFor, bed, build, dartsLeft, hero (+12 more)

### Community 43 - "splash_screen.dart"
Cohesion: 0.14
Nodes (8): createState, dispose, _draw, drawDuration, initState, minimumHold, _proceed, _wordmark

### Community 44 - "training_setup_screen.dart"
Cohesion: 0.05
Nodes (34): atcVariantLabel, bullseyeValueLabel, gameModeName, hitRateText, l10n, missDirectionLabel, rateText, weakSpotFocusLabel (+26 more)

### Community 45 - "Player"
Cohesion: 0.21
Nodes (14): AtcGame, AtcGamesCompanion, BullingGame, BullingGamesCompanion, DartEvent, DartEventsCompanion, Game, GamesCompanion (+6 more)

### Community 46 - "Development"
Cohesion: 0.25
Nodes (8): Commands, Dependency constraints and conventions, Development, Layout breakpoints, Running on a device, Running on Windows, Test layout, Working with the board

### Community 47 - "build"
Cohesion: 0.22
Nodes (14): boardLifecycleProvider, ledSchedulerProvider, localeProvider, _play, _silenceWhenSwitchedOff, soundEnabledProvider, speechEnabledProvider, build (+6 more)

### Community 48 - "Data model"
Cohesion: 0.13
Nodes (15): `AtcGames` — an Around the Clock leg's settings, `BullingGames` — a Bulling leg's settings, `DartEvents` — every dart, Data model, `Games` — one leg, `GameSeats` — who sat where, `Matches` — a run of x01 legs, Migration tests (+7 more)

### Community 49 - "List"
Cohesion: 0.07
Nodes (17): build, busted, caption, celebrate, child, darts, figure, finishing (+9 more)

### Community 50 - "app_localizations_en.dart"
Cohesion: 0.00
Nodes (405): addPlayerFieldLabel, againstThrowLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters (+397 more)

### Community 51 - "Recipes"
Cohesion: 0.09
Nodes (22): Add a database column or table, Add a game mode, Add a localized string, Add a provider, Add a sound, Add a test, Add a training drill, Add an LED cue (+14 more)

### Community 52 - "atc_reducer.dart"
Cohesion: 0.15
Nodes (8): foldAroundTheClock, initialAtcLegState, playerIndex, stopIndex, turnDarts, turns, turnStart, winnerId

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
Cohesion: 0.05
Nodes (30): _ComingSoonTile, createState, mode, modes, _pressed, SelectGameModeScreen, _setPressed, _setupScreenFor (+22 more)

### Community 57 - "apk_download_test.dart"
Cohesion: 0.11
Nodes (10): ChecksumMismatch, UpdateCheckException, bytes, directory, main, serving, target, url (+2 more)

### Community 58 - "checkout_challenge.dart"
Cohesion: 0.05
Nodes (40): attempts, band, checkoutLevelBand, checkoutLevelCount, checkoutLevelWidth, checkoutMissesToDrop, checkoutPool, checkouts (+32 more)

### Community 59 - "update_controller.dart"
Cohesion: 0.07
Nodes (35): updateAutoCheckProvider, apkPath, apply, _applyOnWindows, build, check, client, current (+27 more)

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
Cohesion: 0.14
Nodes (12): build, _controller, createState, _curve, didUpdateWidget, _dim, dispose, _from (+4 more)

### Community 68 - "mode_layout_test.dart"
Cohesion: 0.06
Nodes (22): board, container, database, main, _modeName, pump, repository, _atc (+14 more)

### Community 69 - "worker.md"
Cohesion: 0.50
Nodes (3): Contract, Project, Reporting back

### Community 70 - "package:fluttergran/domain/segment.dart"
Cohesion: 0.03
Nodes (66): AtcVariant, ThrownDart, X01RuleDartChecks, at, bull, config, main, throwing (+58 more)

### Community 71 - "FlutterWindow"
Cohesion: 0.12
Nodes (4): FlutterWindow, flutter_controller_, FlutterWindow::FlutterWindow(), project_

### Community 73 - ".Create"
Cohesion: 0.14
Nodes (8): Scale(), Size, height, width, Win32Window::Win32Window(), WindowClassRegistrar, class_registered_, instance_

### Community 74 - "led_reactions_test.dart"
Cohesion: 0.05
Nodes (28): board, clock, container, controller, main, session, board, container (+20 more)

### Community 78 - "atc_stop.dart"
Cohesion: 0.15
Nodes (10): AtcStop, _bull, clears, label, number, _numbered, ring, toString (+2 more)

### Community 79 - "training_controller.dart"
Cohesion: 0.07
Nodes (32): addDart, Bobs27Plan, Bobs27Session, _challenge, CheckoutChallengePlan, CheckoutChallengeSession, config, darts (+24 more)

### Community 81 - "end_screen_test.dart"
Cohesion: 0.04
Nodes (45): GameRepository, database, main, repository, seedAtcGame, database, main, repository (+37 more)

### Community 82 - "fake_update.dart"
Cohesion: 0.07
Nodes (26): allowed, apkBytes, apkName, base, browserOpens, canInstall, checksAtLaunch, currentVersion (+18 more)

### Community 83 - "currentGameIdProvider"
Cohesion: 0.08
Nodes (66): AtcController, build, _persist, build, BullingController, _persist, build, GameController (+58 more)

### Community 84 - "dart"
Cohesion: 0.06
Nodes (33): dart, big, _brandGreen, bust, command, connected, _flashFor, _forestGreen (+25 more)

### Community 85 - "free_practice_state.dart"
Cohesion: 0.14
Nodes (12): currentTurnDarts, darts, dartsThrown, foldFreePractice, FreePracticeState, FreePracticeTurn, initialFreePracticeState, oneEightyCount (+4 more)

### Community 86 - "dart"
Cohesion: 0.07
Nodes (30): dart, after, _aimCue, aimRing, all, atcRing, _attemptCues, before (+22 more)

### Community 87 - "utils.cpp"
Cohesion: 0.13
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 88 - "devices.dart"
Cohesion: 0.20
Nodes (9): laptop, monitor, phoneLandscape, phonePortrait, setViewSize, smallestWindow, tablet, tabS6Lite (+1 more)

### Community 89 - "dart_keypad.dart"
Cohesion: 0.12
Nodes (18): build, createState, DartKeypad, _DartKeypadState, _enter, highlight, highlighted, _isHighlighted (+10 more)

### Community 90 - "pump.dart"
Cohesion: 0.07
Nodes (22): board, checkout, container, database, inFigures, main, open, repository (+14 more)

### Community 91 - "bulling_reducer.dart"
Cohesion: 0.15
Nodes (9): bullingPointsFor, foldBulling, initialBullingLegState, playerIndex, score, turnDarts, turns, turnStart (+1 more)

### Community 92 - "package:flutter/material.dart"
Cohesion: 0.05
Nodes (36): RulesTopic, RulesTopicPresentation, build, rulesContentWidth, RulesDetailScreen, topic, build, _cards (+28 more)

### Community 93 - "github_releases.dart"
Cohesion: 0.07
Nodes (24): apkNameFor, AppRelease, assets, checksums, checksumsUrl, _client, GitHubReleases, json (+16 more)

### Community 94 - "deploy"
Cohesion: 0.06
Nodes (35): runs-on, steps, timeout-minutes, concurrency, cancel-in-progress, group, environment, needs (+27 more)

### Community 96 - "board_lifecycle.dart"
Cohesion: 0.09
Nodes (20): BoardToast, boardToastFor, context, disposed, l10n, lifecycle, messenger, null (+12 more)

### Community 97 - "aim_strip.dart"
Cohesion: 0.12
Nodes (14): AimStrip, alternatives, build, caption, chips, dartsLeft, footnote, hero (+6 more)

### Community 98 - "bool get"
Cohesion: 0.13
Nodes (12): all, boardOrder, hashCode, innerBull, isDouble, label, multiplier, number (+4 more)

### Community 99 - "rules_topic.dart"
Cohesion: 0.13
Nodes (10): displayName, facts, icon, objective, of, overview, _registryName, RulesFact (+2 more)

### Community 101 - "Releasing"
Cohesion: 0.17
Nodes (12): Android signing key (strongly recommended), Changing the toolchain, CI on the release PR (optional), In-app updates, One-time setup, Pinned actions, Releasing, Starting point (+4 more)

### Community 102 - "Map"
Cohesion: 0.20
Nodes (8): buttonCode, granboardSegmentMap, innerBullCode, missCode, outerBullCode, _ringOrder, unusedMatrixSlots, wedgeCodes

### Community 103 - "scoreboard.dart"
Cohesion: 0.06
Nodes (30): accent, alignment, build, caption, colour, count, expand, _Figure (+22 more)

### Community 104 - "higher_lower_reducer.dart"
Cohesion: 0.12
Nodes (11): CurrentGameId, eliminated, foldHigherLower, higher, initialHigherLowerLegState, lower, playerIndex, total (+3 more)

### Community 105 - "release-please-config.json"
Cohesion: 0.50
Nodes (3): bootstrap-sha, packages, $schema

### Community 106 - "main_menu_screen.dart"
Cohesion: 0.03
Nodes (40): LocaleSetting, AtcSetupScreen, build, createState, _seats, _variant, build, BullingSetupScreen (+32 more)

### Community 107 - "Point"
Cohesion: 0.50
Nodes (3): Point, x, y

### Community 110 - "stats_charts.dart"
Cohesion: 0.07
Nodes (25): _BoardPainter, TallyPainter, Bar, BarChart, bars, build, colour, firstLabel (+17 more)

### Community 111 - "bulling_config.dart"
Cohesion: 0.25
Nodes (5): bullseyeValue, offeredTargets, playerIds, target, BullseyeValue

### Community 112 - "board_reader_test.dart"
Cohesion: 0.24
Nodes (10): BoardEvent, BoardMiss, body, ButtonPress, DartHit, segment, toString, UnknownFrame (+2 more)

### Community 113 - "weak_spot.dart"
Cohesion: 0.06
Nodes (30): combined, config, currentTarget, currentVisitDarts, darts, dartsLeftThisVisit, doubles, drawWeakSpotTarget (+22 more)

### Community 114 - "stat_card.dart"
Cohesion: 0.11
Nodes (16): accent, build, caption, child, children, detail, FadeIn, label (+8 more)

### Community 115 - "dartdoc"
Cohesion: 0.14
Nodes (13): markdown, App, Data, Domain, Game modes, dartdoc, categories, categoryOrder (+5 more)

### Community 116 - "x01_stats_tab.dart"
Cohesion: 0.05
Nodes (31): _percentAxis, playerId, since, _dartsBars, _DoublesCard, _FinishingCard, _LegsCard, minDoubleSample (+23 more)

### Community 117 - "bobs_27.dart"
Cohesion: 0.07
Nodes (24): Bobs27Config, bobs27MaxScore, bobs27StartScore, Bobs27State, bobs27Targets, Bobs27Visit, config, currentTarget (+16 more)

### Community 118 - "apk_download.dart"
Cohesion: 0.10
Nodes (17): actual, add, close, _deleteIfThere, digest, _DigestSink, downloadVerified, expected (+9 more)

### Community 119 - "analyzer"
Cohesion: 0.17
Nodes (11): analyzer, errors, exclude, language, invalid_annotation_target, include, strict-casts, strict-inference (+3 more)

### Community 120 - "update_platform.dart"
Cohesion: 0.12
Nodes (12): canInstall, _channel, checksAtLaunch, currentVersion, DeviceUpdatePlatform, downloadDirectory, installApk, InstallResult (+4 more)

### Community 121 - "rule_callout.dart"
Cohesion: 0.25
Nodes (7): build, CalloutTone, footer, points, RuleCallout, title, tone

### Community 122 - "update_controller_test.dart"
Cohesion: 0.15
Nodes (8): containerWith, directory, installApk, main, platform, _ThrowingInstall, main, FakeUpdatePlatform

### Community 123 - "higher_lower_config.dart"
Cohesion: 0.29
Nodes (4): minPlayers, playerIds, startHigher, startLower

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

### Community 130 - "board_geometry_test.dart"
Cohesion: 0.29
Nodes (5): angle, at, hit, main, radius

### Community 131 - "Set"
Cohesion: 0.33
Nodes (3): bogeyNumbers, main, route

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
Cohesion: 0.12
Nodes (16): [1.1.0](https://github.com/Filan-glitch/FlutterGran/compare/9be2ca2...v1.1.0) (2026-10-26), [1.2.0](https://github.com/Filan-glitch/FlutterGran/compare/v1.1.0...v1.2.0) (2026-10-26), [1.2.1](https://github.com/Filan-glitch/FlutterGran/compare/v1.2.0...v1.2.1) (2026-11-08), [1.3.0](https://github.com/Filan-glitch/FlutterGran/compare/v1.2.1...v1.3.0) (2026-11-08), [1.3.1](https://github.com/Filan-glitch/FlutterGran/compare/v1.3.0...v1.3.1) (2026-11-08), [1.4.0](https://github.com/Filan-glitch/FlutterGran/compare/v1.3.1...v1.4.0) (2026-11-08), Bug Fixes, Bug Fixes (+8 more)

### Community 150 - "ConsumerWidget"
Cohesion: 0.17
Nodes (14): doublesRecordProvider, playerStatsProvider, playerTrendProvider, _UpdateStatus, AtcStatsTab, build, BullingStatsTab, HigherLowerStatsTab (+6 more)

### Community 153 - "aim_target.dart"
Cohesion: 0.10
Nodes (18): AimKind, AimTarget, bull, bullseye, double, hashCode, isBull, isHitBy (+10 more)

### Community 154 - "training_game_screen.dart"
Cohesion: 0.05
Nodes (35): dart, _attemptSounds, bust, checkout, index, _legSounds, soundsForTraining, connection (+27 more)

### Community 155 - "_"
Cohesion: 0.12
Nodes (16): _, attempts, CheckoutAttempt, dartsUsed, fold, isOver, leg, remaining (+8 more)

### Community 157 - "player_picker.dart"
Cohesion: 0.07
Nodes (22): AddPlayerField, build, controller, onAdd, _addPlayer, createState, dispose, enabled (+14 more)

### Community 158 - "chalk_mark.dart"
Cohesion: 0.14
Nodes (12): build, ChalkMark, chalkMarkHeroTag, ChalkWordmark, fontSize, paint, progress, shouldRepaint (+4 more)

### Community 159 - "Start here"
Cohesion: 0.33
Nodes (6): API docs, Check before pushing, Run, Setup, Start here, Where the docs live

### Community 160 - "KnownBoardController"
Cohesion: 0.40
Nodes (5): KnownBoardController, KnownBoardStore, NoKnownBoardStore, read, write

### Community 161 - "x01_setup_screen.dart"
Cohesion: 0.06
Nodes (33): build, config, decidedLegs, leave, legSettled, matchId, MatchSession, _recordedWinner (+25 more)

### Community 162 - "stats_format.dart"
Cohesion: 0.12
Nodes (16): build, busiest, cards, decimal, detail, headline, minRateSample, noFigure (+8 more)

### Community 163 - "bounds_card.dart"
Cohesion: 0.13
Nodes (13): _bestDart, BoundsCard, boundsCardKey, _BoundTile, build, dartsLeft, figure, hero (+5 more)

### Community 165 - "higher_lower_stats.dart"
Cohesion: 0.15
Nodes (12): higherCalls, longestRun, lowerCalls, survivalRate, turnsPlayed, turnsSurvived, dartsThrown, empty (+4 more)

### Community 166 - "bulling_stats.dart"
Cohesion: 0.15
Nodes (12): innerBullHits, outerBullHits, dartsThrown, empty, fewestDartsToWin, hitRate, legsFinished, legsPlayed (+4 more)

### Community 168 - "String get"
Cohesion: 0.22
Nodes (7): hashCode, label, miss, operator, segment, toString, value

### Community 169 - "int?"
Cohesion: 0.17
Nodes (9): foldLeg, initialLegState, opened, playerIndex, remaining, turnDarts, turns, turnStart (+1 more)

### Community 170 - "mode"
Cohesion: 0.18
Nodes (11): mode, version, description, required, type, on, workflow_call, default (+3 more)

### Community 171 - "build.yml"
Cohesion: 0.20
Nodes (9): env, FLUTTER_VERSION, MODE, NAME, VERSION, jobs, name, permissions (+1 more)

### Community 172 - "with"
Cohesion: 0.20
Nodes (10): with, cache, channel, distribution, flutter-version, if-no-files-found, java-version, name (+2 more)

### Community 173 - "atc_stats.dart"
Cohesion: 0.20
Nodes (9): qualifyingDarts, dartsThrown, empty, fewestDartsToWin, hitRate, legsFinished, legsPlayed, legsWon (+1 more)

### Community 174 - "secrets"
Cohesion: 0.22
Nodes (9): required, required, required, required, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD, ANDROID_KEYSTORE_BASE64, ANDROID_KEYSTORE_PASSWORD (+1 more)

### Community 175 - "steps"
Cohesion: 0.39
Nodes (9): steps, steps, id, if, name, run, shell, uses (+1 more)

### Community 176 - "State"
Cohesion: 0.15
Nodes (16): RulesScreen, _RulesScreenState, _ModeTile, _ModeTileState, Pulse, _PulseState, StaggeredEntry, _StaggeredEntryState (+8 more)

### Community 178 - "android-signed"
Cohesion: 0.29
Nodes (7): description, value, description, value, android-signed, flutter-version, outputs

### Community 179 - "sign-android"
Cohesion: 0.29
Nodes (7): sign-android, signed, if, needs, outputs, runs-on, timeout-minutes

### Community 181 - "windows"
Cohesion: 0.33
Nodes (6): run, windows, shell, defaults, runs-on, timeout-minutes

### Community 182 - "android"
Cohesion: 0.40
Nodes (5): outputs, runs-on, timeout-minutes, android, flutter

### Community 183 - "env"
Cohesion: 0.40
Nodes (5): KEY_ALIAS, KEY_PASS, KEYSTORE_BASE64, KS_PASS, env

### Community 184 - "ModeStats"
Cohesion: 0.40
Nodes (5): AtcStats, BullingStats, HigherLowerStats, X01Stats, ModeStats

### Community 191 - "game_controller.dart"
Cohesion: 0.11
Nodes (16): acknowledgedTurns, addDart, awaitingTurnConfirm, confirmTurn, endTurn, GameSession, handleBoardEvent, leave (+8 more)

### Community 200 - "atc_controller.dart"
Cohesion: 0.03
Nodes (51): acknowledgedTurns, addDart, AtcSession, awaitingTurnConfirm, confirmTurn, endTurn, handleBoardEvent, leave (+43 more)

### Community 207 - "x01_rules.dart"
Cohesion: 0.18
Nodes (11): abbreviation, checksOut, checksOutUnder, label, opens, opensUnder, _qualifies, X01InRule (+3 more)

### Community 216 - "led_scheduler.dart"
Cohesion: 0.08
Nodes (22): _ambient, _deliver, dispose, _disposed, _enabled, enterGame, _gateClosed, _gateTimer (+14 more)

### Community 217 - "Feature ideas (not yet built)"
Cohesion: 0.29
Nodes (6): Candidate game modes, Feature ideas (not yet built), How a mode fits the existing architecture, Process note, Quality-of-life, Stats / data features

### Community 219 - "game_layout.dart"
Cohesion: 0.10
Nodes (18): aim, build, child, confirm, _confirmLeave, _desktopScoreShareWidth, GameLayout, gameOver (+10 more)

### Community 230 - "AppLocalizations"
Cohesion: 0.33
Nodes (5): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsDe, AppLocalizationsEn, of

### Community 233 - "Rules section"
Cohesion: 0.33
Nodes (5): Building blocks - `lib/app/widgets/rules/`, Rules section, Screens, Tests, The rule this section must not break

## Knowledge Gaps
- **3359 isolated node(s):** `StatsKey`, `PlayerTrend`, `source`, `_key`, `_loaded` (+3354 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 3962 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **30 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `_` connect `_` to `int get`, `atc_controller.dart`, `frame_assembler.dart`, `sound.dart`, `bulling_config.dart`, `dart`, `return`?**
  _High betweenness centrality (0.016) - this node is a cross-community bridge._
- **What connects `StatsKey`, `PlayerTrend`, `source` to the rest of the system?**
  _3359 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.g.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03278688524590164 - nodes in this community are weakly interconnected._
- **Why does `dart` connect `dart` to `../theme.dart`, `select_game_mode_screen.dart`, `frame_assembler.dart`, `led_command.dart`, `led_scheduler.dart`, `training_game_screen.dart`, `higher_lower_config.dart`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **Should `theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.024096385542168676 - nodes in this community are weakly interconnected._
- **Why does `AppDatabase` connect `migration_test.dart` to `mode_layout_test.dart`, `database.dart`, `package:fluttergran/domain/segment.dart`, `providers.dart`, `package:flutter/material.dart`, `led_reactions_test.dart`, `game_repository.dart`, `end_screen_test.dart`, `responsive_layout_test.dart`, `atc_widget_test.dart`, `pump.dart`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **Should `checkout_search.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06896551724137931 - nodes in this community are weakly interconnected._