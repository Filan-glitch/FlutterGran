# Graph Report - FlutterGran  (2026-10-26)

## Corpus Check
- 174 files · ~165,389 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 20 file(s) not represented in the graph (top: .xml 9, (none) 3, .properties 2)

## Summary
- 3338 nodes · 5003 edges · 121 communities (111 shown, 10 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 9 edges (avg confidence: 0.91)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `a671b595`
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
- package:flutter_riverpod/flutter_riverpod.dart
- end_screen_test.dart
- stats_screen.dart
- game_controller.dart
- player_picker.dart
- StatelessWidget
- make_icon.py
- roster_screen.dart
- main_menu_screen_test.dart
- SettingsScreen
- FakeBoardSource
- app_localizations.dart
- Connectivity
- ConsumerWidget
- sound_player_test.dart
- bulling_leg_state.dart
- app_localizations_de.dart
- game_over_card.dart
- Bulling Game Mode Implementation Plan
- atc_stop.dart
- frame_assembler.dart
- dart_keypad.dart
- MaterialPageRoute
- MaterialPageRoute
- DataClass
- Development
- main.dart
- Data model
- settings_screen.dart
- app_localizations_en.dart
- scoreboard.dart
- DateTime
- Architecture
- The board protocol
- return
- select_game_mode_screen.dart
- training_setup_screen.dart
- ../providers.dart
- l10n/app_localizations.dart
- fluttergran
- The GranBoard 132
- atc_leg_state.dart
- Chalk
- Table
- dart
- ../../domain/x01/thrown_dart.dart
- mode_layout_test.dart
- worker.md
- _Body
- MainActivity
- package:fluttergran/domain/segment.dart
- aim_card.dart
- mode_sounds_test.dart
- currentGameIdProvider
- dart
- free_practice_state.dart
- dart
- Around the Clock — design
- checkout_card.dart
- package:flutter/material.dart
- Map
- x01_setup_screen.dart
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
- setup_screens_test.dart
- known_board_store.dart
- segment.dart
- led_scheduler.dart
- Feature ideas (not yet built)
- bulling_reducer.dart
- game_layout.dart
- main_menu_screen.dart
- AppLocalizations
- board_lifecycle.dart
- Rules screens: overview vs detail
- bool get
- Map
- lights_providers.dart
- BoardConnectionController
- int get
- reconnect_delay_test.dart
- TrainingGameScreen
- _FakeAudioPlatform
- _FakeGlobalAudioPlatform
- _FakeAudioCache
- Notifier

## God Nodes (most connected - your core abstractions)
1. `_` - 48 edges
2. `dart` - 44 edges
3. `dart` - 36 edges
4. `FakeBoardSource` - 26 edges
5. `AppDatabase` - 26 edges
6. `currentGameIdProvider` - 25 edges
7. `gameRepositoryProvider` - 22 edges
8. `Bulling Game Mode Implementation Plan` - 21 edges
9. `dart` - 15 edges
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

## Communities (121 total, 10 thin omitted)

### Community 0 - "database.dart"
Cohesion: 0.03
Nodes (59): _, aliasedName, allSchemaEntities, allTables, atcGamesRefs, copyWith, copyWithCompanion, _createdAtMeta (+51 more)

### Community 1 - "theme.dart"
Cohesion: 0.03
Nodes (68): 1, base, bluetoothAmber, bluetoothBlue, body, brand, build, buildTheme (+60 more)

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
Cohesion: 0.04
Nodes (42): actualTableName, _alias, attachedDatabase, bullingGamesRefs, _finishedAtMeta, _legsToPlayMeta, _nameMeta, _seatMeta (+34 more)

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
Cohesion: 0.04
Nodes (53): SoundPlayer, AudioPlayersSoundPlayer, _MutePlayer, _MutePlayer, _FakePlayer, board, build, container (+45 more)

### Community 10 - "board_widget.dart"
Cohesion: 0.05
Nodes (37): _TallyPainter, _black, BoardGeometry, _BoardPainter, boardWedgeOrder, build, _cream, doubleInner (+29 more)

### Community 11 - "game_repository.dart"
Cohesion: 0.05
Nodes (41): addPlayer, allPlayers, appendDart, _aroundTheClock, _bulling, db, deleteEmptyGames, deleteGame (+33 more)

### Community 12 - "game_screen.dart"
Cohesion: 0.08
Nodes (17): _clearedThisTurn, _figures, _gain, _movedOn, _figures, _gain, _figures, _legWon (+9 more)

### Community 13 - "mode_stats.dart"
Cohesion: 0.07
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
Nodes (35): a, b, black, byNumber, c, code, colourOf, effect (+27 more)

### Community 19 - "board_source.dart"
Cohesion: 0.06
Nodes (27): BleBoardSource, assembler, boardName, BoardSource, codec, connect, connectionState, currentState (+19 more)

### Community 20 - "board_reader_test.dart"
Cohesion: 0.15
Nodes (15): BoardReader, BoardEvent, BoardMiss, body, ButtonPress, DartHit, segment, toString (+7 more)

### Community 21 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.03
Nodes (55): RulesDetailScreen, build, createState, initState, paint, _proceed, shouldRepaint, main (+47 more)

### Community 22 - "end_screen_test.dart"
Cohesion: 0.07
Nodes (23): board, checkout, container, d, database, dispose, frames, inFigures (+15 more)

### Community 23 - "stats_screen.dart"
Cohesion: 0.10
Nodes (18): child, createState, _decimal, detail, _Empty, _FadeIn, _Headline, label (+10 more)

### Community 24 - "game_controller.dart"
Cohesion: 0.11
Nodes (16): acknowledgedTurns, addDart, awaitingTurnConfirm, confirmTurn, endTurn, GameSession, handleBoardEvent, leave (+8 more)

### Community 25 - "player_picker.dart"
Cohesion: 0.12
Nodes (13): _addPlayer, createState, dispose, enabled, _full, _newPlayer, onChanged, onTap (+5 more)

### Community 26 - "StatelessWidget"
Cohesion: 0.08
Nodes (25): _ChalkMark, AnimatedFigure, CenteredContent, EntrancePop, BoardWidget, _Figure, _HeroSeatCard, ProgressRail (+17 more)

### Community 27 - "make_icon.py"
Cohesion: 0.06
Nodes (31): Generated assets, `tool/make_cues.py` — the four cues, `tool/make_icon.py` — the launcher icon, `tool/make_speech.py` — the commentary, bust(), checkout(), dart(), envelope() (+23 more)

### Community 28 - "roster_screen.dart"
Cohesion: 0.10
Nodes (19): _addPlayer, _commit, _controller, createState, didUpdateWidget, dispose, _editing, _focusNode (+11 more)

### Community 29 - "main_menu_screen_test.dart"
Cohesion: 0.05
Nodes (41): GameRepository, database, main, repository, s, seedAtcGame, database, main (+33 more)

### Community 30 - "SettingsScreen"
Cohesion: 0.19
Nodes (15): boardLifecycleProvider, ledSchedulerProvider, _perform, ledCelebrationsProvider, ledDartFlashesProvider, ledEnabledProvider, localeProvider, _play (+7 more)

### Community 31 - "FakeBoardSource"
Cohesion: 0.05
Nodes (33): FakeBoardSource, board, clock, container, controller, main, s, session (+25 more)

### Community 32 - "app_localizations.dart"
Cohesion: 0.01
Nodes (209): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+201 more)

### Community 33 - "Connectivity"
Cohesion: 0.12
Nodes (16): A forgiving characteristic lookup, Android, Connecting from the app, Connection lifecycle, Connectivity, GATT, Licensing note, Permissions (+8 more)

### Community 34 - "ConsumerWidget"
Cohesion: 0.22
Nodes (12): ring, x01LightsProvider, checkoutTableProvider, decidedMatchLegsProvider, gameProvider, matchProvider, matchStateProvider, soundControllerProvider (+4 more)

### Community 35 - "sound_player_test.dart"
Cohesion: 0.05
Nodes (37): binding, create, dispose, emitError, emitGlobalError, emitGlobalLog, emitLog, _events (+29 more)

### Community 36 - "bulling_leg_state.dart"
Cohesion: 0.09
Nodes (21): BullingLegState, BullingTurn, config, currentPlayerId, currentPlayerIndex, currentTurnDarts, darts, dartsLeftThisTurn (+13 more)

### Community 37 - "app_localizations_de.dart"
Cohesion: 0.01
Nodes (201): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+193 more)

### Community 38 - "game_over_card.dart"
Cohesion: 0.07
Nodes (26): KnownBoardController, build, column, columns, error, eyebrow, FigureColumn, FigureRow (+18 more)

### Community 39 - "Bulling Game Mode Implementation Plan"
Cohesion: 0.09
Nodes (21): Bulling Game Mode Implementation Plan, Design, precisely, Domain (`lib/domain/bulling/`), Global Constraints, Out of scope for this pass, Persistence, Self-review notes, Stats (`lib/domain/stats/bulling_stats.dart`, `part of 'mode_stats.dart'`) (+13 more)

### Community 40 - "atc_stop.dart"
Cohesion: 0.14
Nodes (10): AtcStop, _bull, clears, label, number, _numbered, ring, toString (+2 more)

### Community 41 - "frame_assembler.dart"
Cohesion: 0.15
Nodes (10): _buffer, dedupeWindow, feed, FrameAssembler, _greeting, _isRepeat, _lastAt, _lastBody (+2 more)

### Community 42 - "dart_keypad.dart"
Cohesion: 0.06
Nodes (30): AimStrip, alternatives, build, caption, chips, dartsLeft, footnote, hero (+22 more)

### Community 43 - "MaterialPageRoute"
Cohesion: 0.13
Nodes (19): playersProvider, resumableLegProvider, AtcSetupScreen, BullingSetupScreen, build, build, RosterScreen, _RosterScreenState (+11 more)

### Community 44 - "MaterialPageRoute"
Cohesion: 0.20
Nodes (9): x01DefaultsProvider, build, build, _start, initState, _start, main, pushAt (+1 more)

### Community 45 - "DataClass"
Cohesion: 0.21
Nodes (14): AtcGame, AtcGamesCompanion, BullingGame, BullingGamesCompanion, DartEvent, DartEventsCompanion, Game, GamesCompanion (+6 more)

### Community 46 - "Development"
Cohesion: 0.25
Nodes (8): Commands, Conventions, Dependency constraints, learned the hard way, Development, Running on a device, Setup, Test layout, Working with the board

### Community 47 - "main.dart"
Cohesion: 0.14
Nodes (6): child, createState, _lockedToLandscape, main, _Scaled, _ScaledState

### Community 48 - "Data model"
Cohesion: 0.18
Nodes (11): `DartEvents` — every dart, Data model, `Games` — one leg, `GameSeats` — who sat where, `Matches` — a run of legs, Migrations, `Players`, Reading it back (+3 more)

### Community 49 - "settings_screen.dart"
Cohesion: 0.20
Nodes (7): detail, enabled, label, _LanguageChoice, onChanged, _SoundToggle, value

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
Cohesion: 0.13
Nodes (10): build, createState, _drill, _DrillChoice, label, onTap, selected, _startScore (+2 more)

### Community 58 - "../providers.dart"
Cohesion: 0.31
Nodes (7): boardConnectionProvider, boardSourceProvider, build, BoardConnectionButton, build, _onTap, build

### Community 59 - "l10n/app_localizations.dart"
Cohesion: 0.25
Nodes (3): l10n, L10nContext, nameFor

### Community 60 - "fluttergran"
Cohesion: 0.22
Nodes (8): Board protocol, in one paragraph, Commands, Dependency constraints (learned the hard way), fluttergran, graphify, Hardware day (done), Layering rule, X01 rules and schema

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

### Community 67 - "../../domain/x01/thrown_dart.dart"
Cohesion: 0.25
Nodes (5): after, before, _darts, sounds, soundsForTraining

### Community 68 - "mode_layout_test.dart"
Cohesion: 0.06
Nodes (27): highlight, main, pumpKeypad, pumpWidget, _atc, board, build, _bulling (+19 more)

### Community 69 - "worker.md"
Cohesion: 0.50
Nodes (3): Contract, Project, Reporting back

### Community 70 - "_Body"
Cohesion: 0.67
Nodes (4): playerStatsProvider, segmentCountsProvider, _Body, build

### Community 74 - "package:fluttergran/domain/segment.dart"
Cohesion: 0.03
Nodes (48): at, bull, config, d, main, miss, s, t (+40 more)

### Community 81 - "aim_card.dart"
Cohesion: 0.14
Nodes (11): Aim, AimCard, aimCardKey, aimsFor, bed, build, dartsLeft, hero (+3 more)

### Community 82 - "mode_sounds_test.dart"
Cohesion: 0.05
Nodes (36): ThrownDart, X01RuleDartChecks, board, clock, container, controller, dbull, main (+28 more)

### Community 83 - "currentGameIdProvider"
Cohesion: 0.18
Nodes (24): atcLightsProvider, bullingLightsProvider, _openLeg, atcConfigProvider, atcGameProvider, atcSoundControllerProvider, bullingConfigProvider, bullingGameProvider (+16 more)

### Community 84 - "dart"
Cohesion: 0.06
Nodes (33): dart, big, _brandGreen, bust, command, connected, _flashFor, _forestGreen (+25 more)

### Community 85 - "free_practice_state.dart"
Cohesion: 0.15
Nodes (12): currentTurnDarts, darts, dartsThrown, foldFreePractice, FreePracticeState, FreePracticeTurn, initialFreePracticeState, oneEightyCount (+4 more)

### Community 86 - "dart"
Cohesion: 0.08
Nodes (24): dart, after, all, atcRing, before, bullingRing, checkoutRing, colours (+16 more)

### Community 88 - "Around the Clock — design"
Cohesion: 0.20
Nodes (9): Around the Clock — design, Domain (`lib/domain/atc/`), Out of scope for this pass, Persistence, Rules, precisely, Stats (`lib/domain/stats/atc_stats.dart`, `part of 'mode_stats.dart'`), Summary, Testing (+1 more)

### Community 89 - "checkout_card.dart"
Cohesion: 0.14
Nodes (10): _alternates, build, CheckoutCard, checkoutCardKey, checkoutNextDartKey, dartsLeft, hero, padding (+2 more)

### Community 92 - "package:flutter/material.dart"
Cohesion: 0.11
Nodes (15): icon, overview, RulesTopic, RulesTopicPresentation, title, build, _RuleParagraph, text (+7 more)

### Community 94 - "Map"
Cohesion: 0.10
Nodes (15): buttonCode, granboardSegmentMap, innerBullCode, missCode, outerBullCode, _ringOrder, unusedMatrixSlots, wedgeCodes (+7 more)

### Community 106 - "x01_setup_screen.dart"
Cohesion: 0.05
Nodes (29): atcVariantLabel, build, createState, l10n, _seats, _variant, build, _bullseyeValue (+21 more)

### Community 114 - "led_cue.dart"
Cohesion: 0.15
Nodes (19): BoardConnected, DartLanded, DartMissed, GameOn, hashCode, kind, LedCue, LedCueKind (+11 more)

### Community 119 - "match_controller.dart"
Cohesion: 0.12
Nodes (18): _persist, _persist, _persist, build, config, decidedLegs, leave, legSettled (+10 more)

### Community 125 - "sound_player.dart"
Cohesion: 0.12
Nodes (13): _cues, dispose, _disposed, _fire, _live, _pending, playCue, playSpeech (+5 more)

### Community 144 - "led_scheduler_test.dart"
Cohesion: 0.11
Nodes (13): LedScheduler, big, connected, gap, hit, idle, main, scheduler (+5 more)

### Community 169 - "int?"
Cohesion: 0.17
Nodes (9): foldLeg, initialLegState, opened, playerIndex, remaining, turnDarts, turns, turnStart (+1 more)

### Community 176 - "State"
Cohesion: 0.21
Nodes (10): _PlayerTile, _PlayerTileState, _ModeTile, _ModeTileState, Pulse, _PulseState, StaggeredEntry, _StaggeredEntryState (+2 more)

### Community 187 - "../theme.dart"
Cohesion: 0.10
Nodes (18): build, label, onTap, SelectableTile, selected, build, busted, caption (+10 more)

### Community 191 - "training_controller.dart"
Cohesion: 0.12
Nodes (17): addDart, CheckoutPracticeSession, checkoutsCompleted, FreePracticeSession, _handleBoardEvent, leave, leg, _live (+9 more)

### Community 200 - "atc_controller.dart"
Cohesion: 0.11
Nodes (16): acknowledgedTurns, addDart, AtcSession, awaitingTurnConfirm, confirmTurn, endTurn, handleBoardEvent, leave (+8 more)

### Community 206 - "bulling_controller.dart"
Cohesion: 0.11
Nodes (15): acknowledgedTurns, addDart, awaitingTurnConfirm, BullingSession, confirmTurn, endTurn, handleBoardEvent, leave (+7 more)

### Community 207 - "game_config.dart"
Cohesion: 0.09
Nodes (19): GameConfigController, GameConfig, inRule, maxPlayers, offeredStartScores, outRule, playerIds, startingSeat (+11 more)

### Community 210 - "setup_screens_test.dart"
Cohesion: 0.14
Nodes (12): board, build, container, database, dispose, frames, main, playCue (+4 more)

### Community 211 - "known_board_store.dart"
Cohesion: 0.38
Nodes (6): deviceId, KnownBoardStore, MemoryKnownBoardStore, NoKnownBoardStore, read, write

### Community 212 - "segment.dart"
Cohesion: 0.14
Nodes (12): all, hashCode, innerBull, isDouble, label, multiplier, number, operator (+4 more)

### Community 216 - "led_scheduler.dart"
Cohesion: 0.08
Nodes (22): _ambient, _deliver, dispose, _disposed, _enabled, enterGame, _gateClosed, _gateTimer (+14 more)

### Community 217 - "Feature ideas (not yet built)"
Cohesion: 0.29
Nodes (6): Candidate game modes, Feature ideas (not yet built), How a mode fits the existing architecture, Process note, Quality-of-life, Stats / data features

### Community 218 - "bulling_reducer.dart"
Cohesion: 0.08
Nodes (18): CurrentGameId, foldAroundTheClock, initialAtcLegState, playerIndex, stopIndex, turnDarts, turns, turnStart (+10 more)

### Community 219 - "game_layout.dart"
Cohesion: 0.10
Nodes (17): aim, child, confirm, _confirmLeave, GameLayout, gameOver, isHeroDevice, keypad (+9 more)

### Community 227 - "main_menu_screen.dart"
Cohesion: 0.11
Nodes (9): icon, label, _MenuRow, _modeName, names, onResume, onTap, resumable (+1 more)

### Community 230 - "AppLocalizations"
Cohesion: 0.33
Nodes (5): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsDe, AppLocalizationsEn, of

### Community 232 - "board_lifecycle.dart"
Cohesion: 0.11
Nodes (14): BoardToast, boardToastFor, context, disposed, l10n, lifecycle, messenger, null (+6 more)

### Community 233 - "Rules screens: overview vs detail"
Cohesion: 0.33
Nodes (5): Known gap — not done, Rules screens: overview vs detail, Still to do before this is “finished”, Verified, What changed

### Community 235 - "bool get"
Cohesion: 0.20
Nodes (8): hashCode, isDouble, label, miss, operator, segment, toString, value

### Community 237 - "Map"
Cohesion: 0.29
Nodes (4): _base, decode, knows, SegmentCodec

### Community 238 - "lights_providers.dart"
Cohesion: 0.17
Nodes (6): connection, _drive, _gateRing, paint, scheduler, source

### Community 254 - "int get"
Cohesion: 0.12
Nodes (9): BullingConfigController, BullingConfig, bullseyeValue, offeredTargets, playerIds, target, BullseyeValue, points (+1 more)

### Community 266 - "reconnect_delay_test.dart"
Cohesion: 0.22
Nodes (7): FixedRandom, main, nextBool, nextDouble, nextInt, _scanCooldownTests, value

### Community 272 - "TrainingGameScreen"
Cohesion: 0.53
Nodes (6): trainingLightsProvider, soundPlayerProvider, trainingProvider, trainingSoundControllerProvider, build, TrainingGameScreen

### Community 278 - "Notifier"
Cohesion: 0.15
Nodes (18): AtcController, build, build, BullingController, build, GameController, AtcConfigController, boardEventsProvider (+10 more)

## Knowledge Gaps
- **2162 isolated node(s):** `leg`, `acknowledgedTurns`, `awaitingTurnConfirm`, `pendingTurn`, `_live` (+2157 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 2470 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **10 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppDatabase` connect `migration_test.dart` to `mode_layout_test.dart`, `database.dart`, `providers.dart`, `atc_widget_test.dart`, `responsive_layout_test.dart`, `game_repository.dart`, `setup_screens_test.dart`, `package:flutter_riverpod/flutter_riverpod.dart`, `end_screen_test.dart`, `main_menu_screen_test.dart`?**
  _High betweenness centrality (0.037) - this node is a cross-community bridge._
- **What connects `leg`, `acknowledgedTurns`, `awaitingTurnConfirm` to the rest of the system?**
  _2162 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03333333333333333 - nodes in this community are weakly interconnected._
- **Why does `dart` connect `dart` to `frame_assembler.dart`, `dart_keypad.dart`, `x01_setup_screen.dart`, `lights_providers.dart`, `game_config.dart`, `led_command.dart`, `led_scheduler.dart`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **Should `theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.02631578947368421 - nodes in this community are weakly interconnected._
- **Why does `FakeBoardSource` connect `FakeBoardSource` to `mode_layout_test.dart`, `responsive_layout_test.dart`, `fake_board_source.dart`, `mode_sounds_test.dart`, `board_source.dart`, `setup_screens_test.dart`, `package:flutter_riverpod/flutter_riverpod.dart`, `end_screen_test.dart`, `board_reader_test.dart`, `main_menu_screen_test.dart`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **Should `checkout_search.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08333333333333333 - nodes in this community are weakly interconnected._