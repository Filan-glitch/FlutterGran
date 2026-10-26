# Graph Report - FlutterGran  (2026-10-26)

## Corpus Check
- 189 files · ~173,558 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 25 file(s) not represented in the graph (top: .xml 9, (none) 4, .properties 2)

## Summary
- 3471 nodes · 5159 edges · 137 communities (120 shown, 17 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 24 edges (avg confidence: 0.87)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `2ddcb726`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- database.dart
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
- board_reader_test.dart
- package:flutter/material.dart
- setup_screens_test.dart
- stats_screen.dart
- game_controller.dart
- Win32Window
- StatelessWidget
- make_icon.py
- roster_screen.dart
- persistence_test.dart
- SettingsScreen
- FakeBoardSource
- app_localizations.dart
- Connectivity
- checkout_card.dart
- sound_player_test.dart
- bulling_leg_state.dart
- app_localizations_de.dart
- game_over_card.dart
- Bulling Game Mode Implementation Plan
- atc_stop.dart
- frame_assembler.dart
- dart_keypad.dart
- ConsumerState
- x01_setup_screen.dart
- DataClass
- Development
- main.dart
- Data model
- ../providers.dart
- app_localizations_en.dart
- scoreboard.dart
- DateTime
- Architecture
- The board protocol
- return
- select_game_mode_screen.dart
- training_setup_screen.dart
- responsive_layout_test.dart
- l10n/app_localizations.dart
- fluttergran
- The GranBoard 132
- atc_leg_state.dart
- Chalk
- Table
- dart
- reconnect_delay_test.dart
- mode_layout_test.dart
- worker.md
- resumable_leg_provider_test.dart
- FlutterWindow
- MainActivity
- .Create
- package:fluttergran/domain/segment.dart
- settings_screen.dart
- bulling_reducer.dart
- aim_card.dart
- string
- currentGameIdProvider
- dart
- free_practice_state.dart
- dart
- utils.cpp
- Around the Clock — design
- player_picker.dart
- x01_rules.dart
- package:flutter/material.dart
- Map
- checkout_table.dart
- generated_plugin_registrant.cc
- board_lifecycle.dart
- aim_strip.dart
- segment.dart
- board_geometry_test.dart
- Releasing
- .MessageHandler
- ../../domain/x01/thrown_dart.dart
- Map
- release-please-config.json
- x01_setup_screen.dart
- Point
- check_version.sh
- release_notes.sh
- ConsumerStatefulWidget
- CustomPainter
- led_cue.dart
- match_controller.dart
- sound_player.dart
- led_scheduler_test.dart
- int?
- State
- ../theme.dart
- training_controller.dart
- atc_controller.dart
- bulling_controller.dart
- game_config.dart
- led_scheduler.dart
- Feature ideas (not yet built)
- game_layout.dart
- main_menu_screen.dart
- AppLocalizations
- Rules screens: overview vs detail
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
3. `dart` - 34 edges
4. `FakeBoardSource` - 26 edges
5. `AppDatabase` - 26 edges
6. `currentGameIdProvider` - 25 edges
7. `gameRepositoryProvider` - 22 edges
8. `Win32Window` - 21 edges
9. `Bulling Game Mode Implementation Plan` - 21 edges
10. `GameRepository` - 14 edges

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

## Communities (137 total, 17 thin omitted)

### Community 0 - "database.dart"
Cohesion: 0.03
Nodes (60): _, aliasedName, allTables, atcGamesRefs, copyWith, copyWithCompanion, _createdAtMeta, custom (+52 more)

### Community 1 - "theme.dart"
Cohesion: 0.03
Nodes (71): 1, base, bluetoothAmber, bluetoothBlue, body, brand, build, buildTheme (+63 more)

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
Cohesion: 0.04
Nodes (45): allAtcLegsProvider, allBullingLegsProvider, allLegsProvider, allMatchesProvider, boardReaderProvider, computePlayerStats, controller, current (+37 more)

### Community 8 - "atc_widget_test.dart"
Cohesion: 0.07
Nodes (27): closeApp, database, keypadKey, launch, main, _modeName, openAtcSetup, popRoute (+19 more)

### Community 9 - "responsive_layout_test.dart"
Cohesion: 0.05
Nodes (37): SoundPlayer, AudioPlayersSoundPlayer, board, checkout, container, d, database, dispose (+29 more)

### Community 10 - "board_widget.dart"
Cohesion: 0.06
Nodes (30): _black, BoardGeometry, boardWedgeOrder, build, _cream, doubleInner, doubleOuter, _green (+22 more)

### Community 11 - "game_repository.dart"
Cohesion: 0.05
Nodes (41): addPlayer, allPlayers, appendDart, _aroundTheClock, _bulling, db, deleteEmptyGames, deleteGame (+33 more)

### Community 12 - "game_screen.dart"
Cohesion: 0.08
Nodes (17): _clearedThisTurn, _figures, _gain, _movedOn, _figures, _gain, _figures, _legWon (+9 more)

### Community 13 - "mode_stats.dart"
Cohesion: 0.06
Nodes (44): AtcStats, average, bestCheckout, bestTurn, BullingStats, checkoutRateFor, firstNineAverage, firstNineDarts (+36 more)

### Community 14 - "player_stats.dart"
Cohesion: 0.05
Nodes (34): atcLegs, bestCheckout, bestTurn, bullingLegs, checkoutsByRule, computeAtcStats, computeBullingStats, computePlayerStats (+26 more)

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
Nodes (31): a, b, black, byNumber, c, code, colourOf, effect (+23 more)

### Community 19 - "board_source.dart"
Cohesion: 0.06
Nodes (27): BleBoardSource, assembler, boardName, BoardSource, codec, connect, connectionState, currentState (+19 more)

### Community 20 - "board_reader_test.dart"
Cohesion: 0.15
Nodes (15): BoardReader, BoardEvent, BoardMiss, body, ButtonPress, DartHit, segment, toString (+7 more)

### Community 21 - "package:flutter/material.dart"
Cohesion: 0.03
Nodes (74): icon, overview, RulesTopic, RulesTopicPresentation, title, build, _RuleParagraph, RulesDetailScreen (+66 more)

### Community 22 - "setup_screens_test.dart"
Cohesion: 0.09
Nodes (17): board, container, database, main, pumpScreen, board, build, container (+9 more)

### Community 23 - "stats_screen.dart"
Cohesion: 0.10
Nodes (19): child, createState, _decimal, detail, _Empty, _Headline, label, milestone (+11 more)

### Community 24 - "game_controller.dart"
Cohesion: 0.11
Nodes (16): acknowledgedTurns, addDart, awaitingTurnConfirm, confirmTurn, endTurn, GameSession, handleBoardEvent, leave (+8 more)

### Community 25 - "Win32Window"
Cohesion: 0.16
Nodes (7): Size, height, width, Win32Window, child_content_, quit_on_close_, window_handle_

### Community 26 - "StatelessWidget"
Cohesion: 0.08
Nodes (25): _FadeIn, AnimatedFigure, CenteredContent, EntrancePop, BoardWidget, _Figure, _HeroSeatCard, ProgressRail (+17 more)

### Community 27 - "make_icon.py"
Cohesion: 0.06
Nodes (31): Generated assets, `tool/make_cues.py` — the four cues, `tool/make_icon.py` — the launcher icon, `tool/make_speech.py` — the commentary, bust(), checkout(), dart(), envelope() (+23 more)

### Community 28 - "roster_screen.dart"
Cohesion: 0.09
Nodes (21): _addPlayer, _commit, _controller, createState, didUpdateWidget, dispose, _editing, _focusNode (+13 more)

### Community 29 - "persistence_test.dart"
Cohesion: 0.05
Nodes (36): GameRepository, database, main, repository, s, seedAtcGame, database, main (+28 more)

### Community 30 - "SettingsScreen"
Cohesion: 0.26
Nodes (11): _perform, ledCelebrationsProvider, ledDartFlashesProvider, ledEnabledProvider, localeProvider, _play, _silenceWhenSwitchedOff, soundEnabledProvider (+3 more)

### Community 31 - "FakeBoardSource"
Cohesion: 0.04
Nodes (44): FakeBoardSource, board, clock, container, controller, main, s, session (+36 more)

### Community 32 - "app_localizations.dart"
Cohesion: 0.01
Nodes (209): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+201 more)

### Community 33 - "Connectivity"
Cohesion: 0.12
Nodes (17): A forgiving characteristic lookup, Android, Connecting from the app, Connection lifecycle, Connectivity, GATT, Licensing note, Permissions (+9 more)

### Community 34 - "checkout_card.dart"
Cohesion: 0.14
Nodes (10): _alternates, build, CheckoutCard, checkoutCardKey, checkoutNextDartKey, dartsLeft, hero, padding (+2 more)

### Community 35 - "sound_player_test.dart"
Cohesion: 0.05
Nodes (37): binding, create, dispose, emitError, emitGlobalError, emitGlobalLog, emitLog, _events (+29 more)

### Community 36 - "bulling_leg_state.dart"
Cohesion: 0.09
Nodes (20): BullingTurn, config, currentPlayerId, currentPlayerIndex, currentTurnDarts, darts, dartsLeftThisTurn, dartsThrownBy (+12 more)

### Community 37 - "app_localizations_de.dart"
Cohesion: 0.01
Nodes (201): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+193 more)

### Community 38 - "game_over_card.dart"
Cohesion: 0.07
Nodes (25): build, column, columns, error, eyebrow, FigureColumn, FigureRow, _Figures (+17 more)

### Community 39 - "Bulling Game Mode Implementation Plan"
Cohesion: 0.09
Nodes (21): Bulling Game Mode Implementation Plan, Design, precisely, Domain (`lib/domain/bulling/`), Global Constraints, Out of scope for this pass, Persistence, Self-review notes, Stats (`lib/domain/stats/bulling_stats.dart`, `part of 'mode_stats.dart'`) (+13 more)

### Community 40 - "atc_stop.dart"
Cohesion: 0.17
Nodes (10): AtcStop, _bull, clears, label, number, _numbered, ring, toString (+2 more)

### Community 41 - "frame_assembler.dart"
Cohesion: 0.15
Nodes (10): _buffer, dedupeWindow, feed, FrameAssembler, _greeting, _isRepeat, _lastAt, _lastBody (+2 more)

### Community 42 - "dart_keypad.dart"
Cohesion: 0.12
Nodes (15): build, createState, _enter, highlight, highlighted, _isHighlighted, _Key, _KeyState (+7 more)

### Community 43 - "ConsumerState"
Cohesion: 0.24
Nodes (9): playersProvider, playerStatsProvider, segmentCountsProvider, build, _RosterScreenState, _Body, build, build (+1 more)

### Community 44 - "x01_setup_screen.dart"
Cohesion: 0.12
Nodes (18): x01DefaultsProvider, build, createState, _headToHead, initState, _inRule, l10n, _legsToPlay (+10 more)

### Community 45 - "DataClass"
Cohesion: 0.21
Nodes (14): AtcGame, AtcGamesCompanion, BullingGame, BullingGamesCompanion, DartEvent, DartEventsCompanion, Game, GamesCompanion (+6 more)

### Community 46 - "Development"
Cohesion: 0.22
Nodes (9): Commands, Conventions, Dependency constraints, learned the hard way, Development, Running on a device, Running on Windows, Setup, Test layout (+1 more)

### Community 47 - "main.dart"
Cohesion: 0.12
Nodes (10): boardLifecycleProvider, ledSchedulerProvider, build, child, createState, FlutterGranApp, _lockedToLandscape, main (+2 more)

### Community 48 - "Data model"
Cohesion: 0.18
Nodes (11): `DartEvents` — every dart, Data model, `Games` — one leg, `GameSeats` — who sat where, `Matches` — a run of legs, Migrations, `Players`, Reading it back (+3 more)

### Community 49 - "../providers.dart"
Cohesion: 0.18
Nodes (10): resumableLegProvider, build, _ChalkMark, createState, initState, paint, _proceed, shouldRepaint (+2 more)

### Community 50 - "app_localizations_en.dart"
Cohesion: 0.01
Nodes (201): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+193 more)

### Community 51 - "scoreboard.dart"
Cohesion: 0.07
Nodes (25): accent, alignment, build, caption, colour, count, expand, _height (+17 more)

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

### Community 56 - "select_game_mode_screen.dart"
Cohesion: 0.08
Nodes (21): color, _ComingSoonGlyph, _ComingSoonTile, createState, _Dot, mode, _ModeGlyph, modes (+13 more)

### Community 57 - "training_setup_screen.dart"
Cohesion: 0.12
Nodes (12): build, createState, _drill, _DrillChoice, label, onTap, selected, _startScore (+4 more)

### Community 58 - "responsive_layout_test.dart"
Cohesion: 0.07
Nodes (26): BoolSetting, _LightsOff, board, build, container, database, dispose, frames (+18 more)

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

### Community 66 - "dart"
Cohesion: 0.25
Nodes (7): dart, build, darts, DartSlot, struck, total, TurnLedger

### Community 67 - "reconnect_delay_test.dart"
Cohesion: 0.22
Nodes (7): FixedRandom, main, nextBool, nextDouble, nextInt, _scanCooldownTests, value

### Community 68 - "mode_layout_test.dart"
Cohesion: 0.07
Nodes (24): _atc, board, build, _bulling, container, database, desktopWindows, dispose (+16 more)

### Community 69 - "worker.md"
Cohesion: 0.50
Nodes (3): Contract, Project, Reporting back

### Community 70 - "resumable_leg_provider_test.dart"
Cohesion: 0.06
Nodes (28): _click, cues, dispose, _gameOn, _gameShot, main, miss, playCue (+20 more)

### Community 71 - "FlutterWindow"
Cohesion: 0.12
Nodes (4): FlutterWindow, flutter_controller_, FlutterWindow::FlutterWindow(), project_

### Community 73 - ".Create"
Cohesion: 0.18
Nodes (5): Scale(), Win32Window::Win32Window(), WindowClassRegistrar, class_registered_, instance_

### Community 74 - "package:fluttergran/domain/segment.dart"
Cohesion: 0.03
Nodes (56): ThrownDart, X01RuleDartChecks, at, bull, config, d, main, miss (+48 more)

### Community 78 - "settings_screen.dart"
Cohesion: 0.20
Nodes (7): detail, enabled, label, _LanguageChoice, onChanged, _SoundToggle, value

### Community 79 - "bulling_reducer.dart"
Cohesion: 0.08
Nodes (18): CurrentGameId, foldAroundTheClock, initialAtcLegState, playerIndex, stopIndex, turnDarts, turns, turnStart (+10 more)

### Community 81 - "aim_card.dart"
Cohesion: 0.12
Nodes (12): Aim, AimCard, aimCardKey, aimsFor, bed, build, dartsLeft, hero (+4 more)

### Community 82 - "string"
Cohesion: 0.31
Nodes (7): KnownBoardController, deviceId, KnownBoardStore, MemoryKnownBoardStore, NoKnownBoardStore, read, write

### Community 83 - "currentGameIdProvider"
Cohesion: 0.13
Nodes (35): _persist, _persist, _persist, atcLightsProvider, bullingLightsProvider, x01LightsProvider, atcConfigProvider, atcGameProvider (+27 more)

### Community 84 - "dart"
Cohesion: 0.06
Nodes (33): dart, big, _brandGreen, bust, command, connected, _flashFor, _forestGreen (+25 more)

### Community 85 - "free_practice_state.dart"
Cohesion: 0.15
Nodes (12): currentTurnDarts, darts, dartsThrown, foldFreePractice, FreePracticeState, FreePracticeTurn, initialFreePracticeState, oneEightyCount (+4 more)

### Community 86 - "dart"
Cohesion: 0.08
Nodes (24): dart, after, all, atcRing, before, bullingRing, checkoutRing, colours (+16 more)

### Community 87 - "utils.cpp"
Cohesion: 0.17
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 88 - "Around the Clock — design"
Cohesion: 0.20
Nodes (9): Around the Clock — design, Domain (`lib/domain/atc/`), Out of scope for this pass, Persistence, Rules, precisely, Stats (`lib/domain/stats/atc_stats.dart`, `part of 'mode_stats.dart'`), Summary, Testing (+1 more)

### Community 89 - "player_picker.dart"
Cohesion: 0.12
Nodes (13): _addPlayer, createState, dispose, enabled, _full, _newPlayer, onChanged, onTap (+5 more)

### Community 90 - "x01_rules.dart"
Cohesion: 0.20
Nodes (10): abbreviation, checksOut, checksOutUnder, label, opens, opensUnder, X01InRule, X01InRuleChecks (+2 more)

### Community 92 - "package:flutter/material.dart"
Cohesion: 0.12
Nodes (12): build, RulesScreen, _RulesTopicRow, topic, build, _start, build, RulesButton (+4 more)

### Community 93 - "Map"
Cohesion: 0.14
Nodes (10): buttonCode, granboardSegmentMap, innerBullCode, missCode, outerBullCode, _ringOrder, unusedMatrixSlots, wedgeCodes (+2 more)

### Community 94 - "checkout_table.dart"
Cohesion: 0.20
Nodes (7): bestFor, _cache, CheckoutTable, isCheckoutRange, limit, outRule, routesFor

### Community 96 - "board_lifecycle.dart"
Cohesion: 0.08
Nodes (22): BoardToast, boardToastFor, context, disposed, l10n, lifecycle, messenger, null (+14 more)

### Community 97 - "aim_strip.dart"
Cohesion: 0.11
Nodes (15): AimStrip, alternatives, build, caption, chips, dartsLeft, footnote, hero (+7 more)

### Community 98 - "segment.dart"
Cohesion: 0.09
Nodes (20): all, hashCode, innerBull, isDouble, label, multiplier, number, operator (+12 more)

### Community 99 - "board_geometry_test.dart"
Cohesion: 0.25
Nodes (5): angle, at, hit, main, radius

### Community 101 - "Releasing"
Cohesion: 0.17
Nodes (11): Android signing key (strongly recommended), Changing the toolchain, CI on the release PR (optional), One-time setup, Pinned actions, Releasing, Starting point, The flow (+3 more)

### Community 103 - "../../domain/x01/thrown_dart.dart"
Cohesion: 0.25
Nodes (5): after, before, _darts, sounds, soundsForTraining

### Community 104 - "Map"
Cohesion: 0.25
Nodes (4): _base, decode, knows, SegmentCodec

### Community 105 - "release-please-config.json"
Cohesion: 0.50
Nodes (3): bootstrap-sha, packages, $schema

### Community 106 - "x01_setup_screen.dart"
Cohesion: 0.09
Nodes (13): atcVariantLabel, build, createState, l10n, _seats, _variant, build, _bullseyeValue (+5 more)

### Community 107 - "Point"
Cohesion: 0.50
Nodes (3): Point, x, y

### Community 110 - "ConsumerStatefulWidget"
Cohesion: 0.40
Nodes (4): AtcSetupScreen, BullingSetupScreen, RosterScreen, PlayerPicker

### Community 114 - "led_cue.dart"
Cohesion: 0.15
Nodes (19): BoardConnected, DartLanded, DartMissed, GameOn, hashCode, kind, LedCue, LedCueKind (+11 more)

### Community 119 - "match_controller.dart"
Cohesion: 0.12
Nodes (18): ring, build, config, decidedLegs, leave, legSettled, MatchController, matchId (+10 more)

### Community 125 - "sound_player.dart"
Cohesion: 0.12
Nodes (13): _cues, dispose, _disposed, _fire, _live, _pending, playCue, playSpeech (+5 more)

### Community 144 - "led_scheduler_test.dart"
Cohesion: 0.12
Nodes (14): EffectFrame, HitFlash, LedCommand, RingPaint, big, connected, gap, hit (+6 more)

### Community 169 - "int?"
Cohesion: 0.15
Nodes (9): foldLeg, initialLegState, opened, playerIndex, remaining, turnDarts, turns, turnStart (+1 more)

### Community 176 - "State"
Cohesion: 0.24
Nodes (8): _ModeTile, _ModeTileState, Pulse, _PulseState, StaggeredEntry, _StaggeredEntryState, DartKeypad, _DartKeypadState

### Community 187 - "../theme.dart"
Cohesion: 0.09
Nodes (18): build, label, onTap, SelectableTile, selected, build, busted, caption (+10 more)

### Community 191 - "training_controller.dart"
Cohesion: 0.12
Nodes (17): addDart, CheckoutPracticeSession, checkoutsCompleted, FreePracticeSession, _handleBoardEvent, leave, leg, _live (+9 more)

### Community 200 - "atc_controller.dart"
Cohesion: 0.11
Nodes (16): acknowledgedTurns, addDart, AtcSession, awaitingTurnConfirm, confirmTurn, endTurn, handleBoardEvent, leave (+8 more)

### Community 206 - "bulling_controller.dart"
Cohesion: 0.11
Nodes (16): acknowledgedTurns, addDart, awaitingTurnConfirm, BullingSession, confirmTurn, endTurn, handleBoardEvent, leave (+8 more)

### Community 207 - "game_config.dart"
Cohesion: 0.17
Nodes (9): GameConfigController, GameConfig, inRule, maxPlayers, offeredStartScores, outRule, playerIds, startingSeat (+1 more)

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
Cohesion: 0.11
Nodes (9): icon, label, _MenuRow, _modeName, names, onResume, onTap, resumable (+1 more)

### Community 230 - "AppLocalizations"
Cohesion: 0.33
Nodes (5): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsDe, AppLocalizationsEn, of

### Community 233 - "Rules screens: overview vs detail"
Cohesion: 0.33
Nodes (5): Known gap — not done, Rules screens: overview vs detail, Still to do before this is “finished”, Verified, What changed

### Community 238 - "lights_providers.dart"
Cohesion: 0.15
Nodes (7): LedScheduler, connection, _drive, _gateRing, paint, scheduler, source

### Community 254 - "int get"
Cohesion: 0.14
Nodes (7): bullseyeValue, offeredTargets, playerIds, target, BullseyeValue, points, three

### Community 272 - "TrainingGameScreen"
Cohesion: 0.53
Nodes (6): trainingLightsProvider, soundPlayerProvider, trainingProvider, trainingSoundControllerProvider, build, TrainingGameScreen

### Community 278 - "Notifier"
Cohesion: 0.17
Nodes (17): AtcController, build, build, BullingController, build, GameController, AtcConfigController, boardEventsProvider (+9 more)

## Knowledge Gaps
- **2183 isolated node(s):** `leg`, `acknowledgedTurns`, `awaitingTurnConfirm`, `pendingTurn`, `_live` (+2178 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 2583 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **17 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppDatabase` connect `migration_test.dart` to `mode_layout_test.dart`, `database.dart`, `providers.dart`, `atc_widget_test.dart`, `responsive_layout_test.dart`, `game_repository.dart`, `package:flutter/material.dart`, `setup_screens_test.dart`, `responsive_layout_test.dart`, `persistence_test.dart`?**
  _High betweenness centrality (0.036) - this node is a cross-community bridge._
- **What connects `leg`, `acknowledgedTurns`, `awaitingTurnConfirm` to the rest of the system?**
  _2183 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03278688524590164 - nodes in this community are weakly interconnected._
- **Why does `dart` connect `dart` to `aim_strip.dart`, `frame_assembler.dart`, `lights_providers.dart`, `game_config.dart`, `led_scheduler_test.dart`, `led_command.dart`, `led_scheduler.dart`, `Map`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **Should `theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.025 - nodes in this community are weakly interconnected._
- **Why does `FakeBoardSource` connect `FakeBoardSource` to `mode_layout_test.dart`, `responsive_layout_test.dart`, `fake_board_source.dart`, `board_source.dart`, `board_reader_test.dart`, `package:flutter/material.dart`, `setup_screens_test.dart`, `responsive_layout_test.dart`, `persistence_test.dart`?**
  _High betweenness centrality (0.019) - this node is a cross-community bridge._
- **Should `checkout_search.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08333333333333333 - nodes in this community are weakly interconnected._