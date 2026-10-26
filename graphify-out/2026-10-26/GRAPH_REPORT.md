# Graph Report - FlutterGran  (2026-10-26)

## Corpus Check
- 236 files · ~209,269 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 27 file(s) not represented in the graph (top: .xml 9, (none) 4, .css 2)

## Summary
- 4085 nodes · 5856 edges · 173 communities (156 shown, 17 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 24 edges (avg confidence: 0.87)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `750e5e84`
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
- package:flutter_test/flutter_test.dart
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
- main_menu_screen_test.dart
- setup_screens_test.dart
- stats_screen.dart
- game_controller.dart
- Win32Window
- StatelessWidget
- make_icon.py
- roster_screen.dart
- persistence_test.dart
- StatelessWidget
- FakeBoardSource
- app_localizations.dart
- Connectivity
- atc_game_screen.dart
- sound_player_test.dart
- bulling_leg_state.dart
- app_localizations_de.dart
- game_over_card.dart
- Bulling Game Mode Implementation Plan
- rule_explorer.dart
- frame_assembler.dart
- dart_keypad.dart
- MaterialPageRoute
- Transitions Polish
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
- game_mode.dart
- training_setup_screen.dart
- responsive_layout_test.dart
- l10n/app_localizations.dart
- fluttergran
- The GranBoard 132
- atc_leg_state.dart
- Chalk
- Table
- dart
- rule_board.dart
- mode_layout_test.dart
- worker.md
- resumable_leg_provider_test.dart
- FlutterWindow
- MainActivity
- .Create
- package:fluttergran/domain/segment.dart
- end_screen_test.dart
- bulling_reducer.dart
- widget_test.dart
- string
- currentGameIdProvider
- dart
- free_practice_state.dart
- dart
- utils.cpp
- Around the Clock — design
- package:flutter/material.dart
- Transitions.dev
- ../l10n_extensions.dart
- Map
- checkout_table.dart
- board_lifecycle.dart
- aim_strip.dart
- segment.dart
- bool get
- Releasing
- .MessageHandler
- ../../domain/x01/thrown_dart.dart
- Card hover tilt
- release-please-config.json
- List
- Point
- check_version.sh
- release_notes.sh
- transitions-dev/SKILL.md
- CustomPainter
- dart:async
- Avatar group hover
- Error state shake
- Plus to menu morph
- Accordion expand
- Success check
- Input clear with dissolve
- match_controller.dart
- Card resize
- Number pop-in
- Notification badge
- Text states swap
- Menu dropdown
- sound_player.dart
- Modal open / close
- Panel reveal
- Page side-by-side
- Icon swap
- Skeleton loader and reveal
- Shimmer text
- Tabs sliding
- Tooltip open/close
- Texts reveal
- Toast open / close
- Like button
- Learn more hover
- Checkbox check
- Spinning counter
- Toggle
- Thinking states
- Reasoning stream
- Matrix dot loader
- led_scheduler_test.dart
- Banner stacking
- Text morph
- Text swap soft
- Donut chart
- [1.1.0](https://github.com/Filan-glitch/FlutterGran/compare/9be2ca2...v1.1.0) (2026-10-26)
- FlutterGranApp
- Size
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
3. `dart` - 34 edges
4. `FakeBoardSource` - 26 edges
5. `AppDatabase` - 26 edges
6. `currentGameIdProvider` - 25 edges
7. `gameRepositoryProvider` - 22 edges
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

## Communities (173 total, 17 thin omitted)

### Community 0 - "database.dart"
Cohesion: 0.03
Nodes (61): _, actualTableName, _alias, allSchemaEntities, allTables, atcGamesRefs, bullingGamesRefs, copyWithCompanion (+53 more)

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
Nodes (41): aliasedName, attachedDatabase, copyWith, custom, hashCode, _legsToPlayMeta, matchesRefs, _matchIdMeta (+33 more)

### Community 6 - "leg_state.dart"
Cohesion: 0.07
Nodes (26): averageFor, busted, config, currentPlayerId, currentPlayerIndex, currentRemaining, currentTurnDarts, darts (+18 more)

### Community 7 - "providers.dart"
Cohesion: 0.04
Nodes (58): _perform, ring, allAtcLegsProvider, allBullingLegsProvider, allLegsProvider, allMatchesProvider, boardReaderProvider, checkoutTableProvider (+50 more)

### Community 8 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.06
Nodes (27): highlight, main, pumpKeypad, pumpWidget, FixedRandom, main, nextBool, nextDouble (+19 more)

### Community 9 - "responsive_layout_test.dart"
Cohesion: 0.05
Nodes (35): SoundPlayer, AudioPlayersSoundPlayer, _MutePlayer, _MutePlayer, _FakePlayer, _MutePlayer, _MutePlayer, at (+27 more)

### Community 10 - "board_widget.dart"
Cohesion: 0.06
Nodes (33): _black, BoardGeometry, boardWedgeOrder, BoardWidget, build, _cream, dimColour, dimUnheated (+25 more)

### Community 11 - "game_repository.dart"
Cohesion: 0.05
Nodes (41): addPlayer, allPlayers, appendDart, _aroundTheClock, _bulling, db, deleteEmptyGames, deleteGame (+33 more)

### Community 12 - "game_screen.dart"
Cohesion: 0.12
Nodes (11): _figures, _legWon, match, matchFiguresKey, names, _seats, _standing, _freePracticeFigures (+3 more)

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
Nodes (30): a, b, black, byNumber, c, code, colourOf, effect (+22 more)

### Community 19 - "board_source.dart"
Cohesion: 0.06
Nodes (27): BleBoardSource, assembler, boardName, BoardSource, codec, connect, connectionState, currentState (+19 more)

### Community 20 - "led_cue.dart"
Cohesion: 0.07
Nodes (35): BoardConnected, DartLanded, DartMissed, GameOn, hashCode, kind, LedCue, LedCueKind (+27 more)

### Community 21 - "main_menu_screen_test.dart"
Cohesion: 0.03
Nodes (53): RulesBody, contentSizeAt, main, board, container, database, frames, main (+45 more)

### Community 22 - "setup_screens_test.dart"
Cohesion: 0.11
Nodes (16): BoolSetting, _LightsOff, _LightsOff, board, build, container, database, dispose (+8 more)

### Community 23 - "stats_screen.dart"
Cohesion: 0.10
Nodes (18): child, createState, _decimal, detail, _Empty, _FadeIn, _Headline, label (+10 more)

### Community 24 - "game_controller.dart"
Cohesion: 0.08
Nodes (20): acknowledgedTurns, addDart, awaitingTurnConfirm, confirmTurn, endTurn, GameSession, handleBoardEvent, leave (+12 more)

### Community 25 - "Win32Window"
Cohesion: 0.17
Nodes (5): RegisterPlugins(), Win32Window, child_content_, quit_on_close_, window_handle_

### Community 26 - "StatelessWidget"
Cohesion: 0.11
Nodes (15): build, buttonKey, ChoiceRow, label, _Numeral, NumeralChoiceRow, onPressed, onSelected (+7 more)

### Community 27 - "make_icon.py"
Cohesion: 0.06
Nodes (31): Generated assets, `tool/make_cues.py` — the four cues, `tool/make_icon.py` — the launcher icon, `tool/make_speech.py` — the commentary, bust(), checkout(), dart(), envelope() (+23 more)

### Community 28 - "roster_screen.dart"
Cohesion: 0.06
Nodes (29): _commit, _controller, createState, didUpdateWidget, dispose, _editing, _focusNode, initState (+21 more)

### Community 29 - "persistence_test.dart"
Cohesion: 0.05
Nodes (41): GameRepository, database, main, repository, s, seedAtcGame, database, main (+33 more)

### Community 30 - "StatelessWidget"
Cohesion: 0.05
Nodes (42): AnimatedFigure, CenteredContent, EntrancePop, _aroundTheClock, _AtcRoute, body, build, _bulling (+34 more)

### Community 31 - "FakeBoardSource"
Cohesion: 0.04
Nodes (48): FakeBoardSource, board, clock, container, controller, main, s, session (+40 more)

### Community 32 - "app_localizations.dart"
Cohesion: 0.01
Nodes (267): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+259 more)

### Community 33 - "Connectivity"
Cohesion: 0.12
Nodes (17): A forgiving characteristic lookup, Android, Connecting from the app, Connection lifecycle, Connectivity, GATT, Licensing note, Permissions (+9 more)

### Community 34 - "atc_game_screen.dart"
Cohesion: 0.13
Nodes (6): _clearedThisTurn, _figures, _gain, _movedOn, _figures, _gain

### Community 35 - "sound_player_test.dart"
Cohesion: 0.05
Nodes (37): binding, create, dispose, emitError, emitGlobalError, emitGlobalLog, emitLog, _events (+29 more)

### Community 36 - "bulling_leg_state.dart"
Cohesion: 0.09
Nodes (20): BullingTurn, config, currentPlayerId, currentPlayerIndex, currentTurnDarts, darts, dartsLeftThisTurn, dartsThrownBy (+12 more)

### Community 37 - "app_localizations_de.dart"
Cohesion: 0.01
Nodes (259): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+251 more)

### Community 38 - "game_over_card.dart"
Cohesion: 0.07
Nodes (25): build, column, columns, error, eyebrow, FigureColumn, FigureRow, _Figures (+17 more)

### Community 39 - "Bulling Game Mode Implementation Plan"
Cohesion: 0.09
Nodes (21): Bulling Game Mode Implementation Plan, Design, precisely, Domain (`lib/domain/bulling/`), Global Constraints, Out of scope for this pass, Persistence, Self-review notes, Stats (`lib/domain/stats/bulling_stats.dart`, `part of 'mode_stats.dart'`) (+13 more)

### Community 40 - "rule_explorer.dart"
Cohesion: 0.11
Nodes (17): _board, build, createState, explanation, id, initial, label, legend (+9 more)

### Community 41 - "frame_assembler.dart"
Cohesion: 0.15
Nodes (10): _buffer, dedupeWindow, feed, FrameAssembler, _greeting, _isRepeat, _lastAt, _lastBody (+2 more)

### Community 42 - "dart_keypad.dart"
Cohesion: 0.07
Nodes (26): Aim, AimCard, aimCardKey, aimsFor, bed, build, dartsLeft, hero (+18 more)

### Community 43 - "MaterialPageRoute"
Cohesion: 0.07
Nodes (32): playersProvider, playerStatsProvider, resumableLegProvider, segmentCountsProvider, x01DefaultsProvider, AtcSetupScreen, BullingSetupScreen, build (+24 more)

### Community 44 - "Transitions Polish"
Cohesion: 0.12
Nodes (17): Blur, Commands, Core doctrine: match on usage, never on the nearest number, Distances, Durations, Easings, Future expansion, Hover in vs hover out (+9 more)

### Community 45 - "DataClass"
Cohesion: 0.21
Nodes (14): AtcGame, AtcGamesCompanion, BullingGame, BullingGamesCompanion, DartEvent, DartEventsCompanion, Game, GamesCompanion (+6 more)

### Community 46 - "Development"
Cohesion: 0.22
Nodes (9): Commands, Conventions, Dependency constraints, learned the hard way, Development, Running on a device, Running on Windows, Setup, Test layout (+1 more)

### Community 47 - "main.dart"
Cohesion: 0.15
Nodes (6): child, createState, _lockedToLandscape, main, _Scaled, _ScaledState

### Community 48 - "Data model"
Cohesion: 0.18
Nodes (11): `DartEvents` — every dart, Data model, `Games` — one leg, `GameSeats` — who sat where, `Matches` — a run of legs, Migrations, `Players`, Reading it back (+3 more)

### Community 49 - "../providers.dart"
Cohesion: 0.10
Nodes (14): detail, enabled, label, _LanguageChoice, onChanged, _SoundToggle, value, build (+6 more)

### Community 50 - "app_localizations_en.dart"
Cohesion: 0.01
Nodes (259): addPlayerFieldLabel, aimLabel, aroundTheClockLabel, atcSetupTitle, atcVariantAnyPart, atcVariantDoublesOnly, atcVariantMasters, autoConnectDetail (+251 more)

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

### Community 56 - "game_mode.dart"
Cohesion: 0.25
Nodes (7): displayName, GameMode, GameModeDescriptor, gameModeRegistry, id, isAvailable, tagline

### Community 57 - "training_setup_screen.dart"
Cohesion: 0.07
Nodes (20): displayName, facts, icon, objective, of, overview, _registryName, RulesFact (+12 more)

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

### Community 66 - "dart"
Cohesion: 0.25
Nodes (7): dart, build, darts, DartSlot, struck, total, TurnLedger

### Community 67 - "rule_board.dart"
Cohesion: 0.12
Nodes (12): build, _controller, createState, _curve, didUpdateWidget, _dim, dispose, _from (+4 more)

### Community 68 - "mode_layout_test.dart"
Cohesion: 0.07
Nodes (24): _atc, board, build, _bulling, container, database, desktopWindows, dispose (+16 more)

### Community 69 - "worker.md"
Cohesion: 0.50
Nodes (3): Contract, Project, Reporting back

### Community 70 - "resumable_leg_provider_test.dart"
Cohesion: 0.03
Nodes (53): at, bull, config, d, main, miss, s, t (+45 more)

### Community 71 - "FlutterWindow"
Cohesion: 0.12
Nodes (4): FlutterWindow, flutter_controller_, FlutterWindow::FlutterWindow(), project_

### Community 73 - ".Create"
Cohesion: 0.19
Nodes (5): Scale(), Win32Window::Win32Window(), WindowClassRegistrar, class_registered_, instance_

### Community 74 - "package:fluttergran/domain/segment.dart"
Cohesion: 0.05
Nodes (33): ThrownDart, X01RuleDartChecks, coords, main, parts, bogeyNumbers, main, route (+25 more)

### Community 78 - "end_screen_test.dart"
Cohesion: 0.12
Nodes (14): board, checkout, container, d, database, dispose, frames, inFigures (+6 more)

### Community 79 - "bulling_reducer.dart"
Cohesion: 0.08
Nodes (18): CurrentGameId, foldAroundTheClock, initialAtcLegState, playerIndex, stopIndex, turnDarts, turns, turnStart (+10 more)

### Community 81 - "widget_test.dart"
Cohesion: 0.13
Nodes (12): closeApp, database, launch, main, openX01Setup, popRoute, pump, pumpFrames (+4 more)

### Community 82 - "string"
Cohesion: 0.24
Nodes (7): KnownBoardController, deviceId, KnownBoardStore, MemoryKnownBoardStore, NoKnownBoardStore, read, write

### Community 83 - "currentGameIdProvider"
Cohesion: 0.11
Nodes (42): _persist, _persist, _persist, atcLightsProvider, bullingLightsProvider, x01LightsProvider, MatchController, _openLeg (+34 more)

### Community 84 - "dart"
Cohesion: 0.06
Nodes (34): dart, big, _brandGreen, bust, command, connected, _flashFor, _forestGreen (+26 more)

### Community 85 - "free_practice_state.dart"
Cohesion: 0.15
Nodes (12): currentTurnDarts, darts, dartsThrown, foldFreePractice, FreePracticeState, FreePracticeTurn, initialFreePracticeState, oneEightyCount (+4 more)

### Community 86 - "dart"
Cohesion: 0.08
Nodes (24): dart, after, all, atcRing, before, bullingRing, checkoutRing, colours (+16 more)

### Community 87 - "utils.cpp"
Cohesion: 0.19
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 88 - "Around the Clock — design"
Cohesion: 0.20
Nodes (9): Around the Clock — design, Domain (`lib/domain/atc/`), Out of scope for this pass, Persistence, Rules, precisely, Stats (`lib/domain/stats/atc_stats.dart`, `part of 'mode_stats.dart'`), Summary, Testing (+1 more)

### Community 89 - "package:flutter/material.dart"
Cohesion: 0.14
Nodes (11): build, CalloutTone, footer, points, RuleCallout, title, tone, main (+3 more)

### Community 90 - "Transitions.dev"
Cohesion: 0.15
Nodes (13): Commands, Common mistakes to avoid, Decision rules, Motion tokens, Output format, Quick reference, Reference files, transitions apply — install the best-fit transition (+5 more)

### Community 92 - "../l10n_extensions.dart"
Cohesion: 0.05
Nodes (32): RulesTopic, RulesTopicPresentation, build, rulesContentWidth, RulesDetailScreen, topic, build, _cards (+24 more)

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

### Community 98 - "segment.dart"
Cohesion: 0.08
Nodes (21): AtcStop, _bull, clears, label, number, _numbered, ring, toString (+13 more)

### Community 99 - "bool get"
Cohesion: 0.18
Nodes (8): hashCode, isDouble, label, miss, operator, segment, toString, value

### Community 101 - "Releasing"
Cohesion: 0.17
Nodes (11): Android signing key (strongly recommended), Changing the toolchain, CI on the release PR (optional), One-time setup, Pinned actions, Releasing, Starting point, The flow (+3 more)

### Community 103 - "../../domain/x01/thrown_dart.dart"
Cohesion: 0.25
Nodes (5): after, before, _darts, sounds, soundsForTraining

### Community 104 - "Card hover tilt"
Cohesion: 0.20
Nodes (9): Card hover tilt, CSS, HTML usage, JavaScript orchestration, Peak tilt angle, Touch / mobile, Tunable variables, When to use (+1 more)

### Community 105 - "release-please-config.json"
Cohesion: 0.50
Nodes (3): bootstrap-sha, packages, $schema

### Community 106 - "List"
Cohesion: 0.05
Nodes (29): atcVariantLabel, build, createState, l10n, _seats, _variant, build, _bullseyeValue (+21 more)

### Community 107 - "Point"
Cohesion: 0.50
Nodes (3): Point, x, y

### Community 110 - "transitions-dev/SKILL.md"
Cohesion: 0.20
Nodes (6): CSS, HTML usage, JavaScript orchestration, Streaming text, Tunable variables, When to use

### Community 112 - "dart:async"
Cohesion: 0.27
Nodes (7): boardConnectionProvider, boardSourceProvider, build, BoardConnectionButton, build, _onTap, GameAppBar

### Community 113 - "Avatar group hover"
Cohesion: 0.22
Nodes (8): Avatar group hover, CSS, HTML usage, JavaScript orchestration, React form, Tunable variables, When to use, Why the timing-function is set inline before the variable writes

### Community 114 - "Error state shake"
Cohesion: 0.22
Nodes (8): CSS, Error state shake, HTML usage, JavaScript orchestration, Recomputing the keyframe stops, Tunable variables, When to use, Why three classes (`.is-error` on wrap + input, `.is-shaking` on input)

### Community 115 - "Plus to menu morph"
Cohesion: 0.22
Nodes (8): CSS, HTML usage, JavaScript orchestration, Open and close use different eases, Pin the plus button to a corner, Plus to menu morph, Tunable variables, When to use

### Community 116 - "Accordion expand"
Cohesion: 0.22
Nodes (8): Accordion expand, CSS, HTML usage, JavaScript orchestration, Tunable variables, Two-element panel + padding placement, When to use, Why the chevron flips instead of morphing its path

### Community 117 - "Success check"
Cohesion: 0.25
Nodes (7): Calibrating `stroke-dasharray` for your path, CSS, HTML usage, JavaScript orchestration, Success check, Tunable variables, When to use

### Community 118 - "Input clear with dissolve"
Cohesion: 0.25
Nodes (7): CSS, Dark mode, HTML usage, Input clear with dissolve, JavaScript orchestration, Tunable variables, When to use

### Community 119 - "match_controller.dart"
Cohesion: 0.14
Nodes (12): build, config, decidedLegs, leave, legSettled, matchId, MatchSession, _recordedWinner (+4 more)

### Community 120 - "Card resize"
Cohesion: 0.29
Nodes (6): Card resize, CSS, HTML usage, JavaScript orchestration, Tunable variables, When to use

### Community 121 - "Number pop-in"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Number pop-in, Tunable variables, When to use

### Community 122 - "Notification badge"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Notification badge, Tunable variables, When to use

### Community 123 - "Text states swap"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Text states swap, Tunable variables, When to use

### Community 124 - "Menu dropdown"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Menu dropdown, Tunable variables, When to use

### Community 125 - "sound_player.dart"
Cohesion: 0.12
Nodes (13): _cues, dispose, _disposed, _fire, _live, _pending, playCue, playSpeech (+5 more)

### Community 126 - "Modal open / close"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Modal open / close, Tunable variables, When to use

### Community 127 - "Panel reveal"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Panel reveal, Tunable variables, When to use

### Community 128 - "Page side-by-side"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Page side-by-side, Tunable variables, When to use

### Community 129 - "Icon swap"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, Icon swap, JavaScript orchestration, Tunable variables, When to use

### Community 130 - "Skeleton loader and reveal"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Skeleton loader and reveal, Tunable variables, When to use

### Community 131 - "Shimmer text"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Shimmer text, Tunable variables, When to use

### Community 132 - "Tabs sliding"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Tabs sliding, Tunable variables, When to use

### Community 133 - "Tooltip open/close"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Tooltip open/close, Tunable variables, When to use

### Community 134 - "Texts reveal"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Texts reveal, Tunable variables, When to use

### Community 135 - "Toast open / close"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Toast open / close, Tunable variables, When to use

### Community 136 - "Like button"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Like button, Tunable variables, When to use

### Community 137 - "Learn more hover"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Learn more hover, Tunable variables, When to use

### Community 138 - "Checkbox check"
Cohesion: 0.29
Nodes (6): Checkbox check, CSS, HTML usage, JavaScript orchestration, Tunable variables, When to use

### Community 139 - "Spinning counter"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Spinning counter, Tunable variables, When to use

### Community 140 - "Toggle"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Toggle, Tunable variables, When to use

### Community 141 - "Thinking states"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Thinking states, Tunable variables, When to use

### Community 142 - "Reasoning stream"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Reasoning stream, Tunable variables, When to use

### Community 143 - "Matrix dot loader"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Matrix dot loader, Tunable variables, When to use

### Community 144 - "led_scheduler_test.dart"
Cohesion: 0.12
Nodes (14): EffectFrame, HitFlash, LedCommand, RingPaint, big, connected, gap, hit (+6 more)

### Community 145 - "Banner stacking"
Cohesion: 0.29
Nodes (6): Banner stacking, CSS, HTML usage, JavaScript orchestration, Tunable variables, When to use

### Community 146 - "Text morph"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Text morph, Tunable variables, When to use

### Community 147 - "Text swap soft"
Cohesion: 0.29
Nodes (6): CSS, HTML usage, JavaScript orchestration, Text swap soft, Tunable variables, When to use

### Community 148 - "Donut chart"
Cohesion: 0.29
Nodes (6): CSS, Donut chart, HTML usage, JavaScript orchestration, Tunable variables, When to use

### Community 149 - "[1.1.0](https://github.com/Filan-glitch/FlutterGran/compare/9be2ca2...v1.1.0) (2026-10-26)"
Cohesion: 0.50
Nodes (3): [1.1.0](https://github.com/Filan-glitch/FlutterGran/compare/9be2ca2...v1.1.0) (2026-10-26), Changelog, Features

### Community 150 - "FlutterGranApp"
Cohesion: 0.67
Nodes (4): boardLifecycleProvider, ledSchedulerProvider, build, FlutterGranApp

### Community 151 - "Size"
Cohesion: 0.50
Nodes (3): Size, height, width

### Community 169 - "int?"
Cohesion: 0.17
Nodes (9): foldLeg, initialLegState, opened, playerIndex, remaining, turnDarts, turns, turnStart (+1 more)

### Community 176 - "State"
Cohesion: 0.14
Nodes (18): _PlayerTile, _PlayerTileState, RulesScreen, _RulesScreenState, _ModeTile, _ModeTileState, Pulse, _PulseState (+10 more)

### Community 187 - "../theme.dart"
Cohesion: 0.08
Nodes (19): ringColours, build, label, onTap, SelectableTile, selected, build, busted (+11 more)

### Community 191 - "training_controller.dart"
Cohesion: 0.12
Nodes (17): addDart, CheckoutPracticeSession, checkoutsCompleted, FreePracticeSession, _handleBoardEvent, leave, leg, _live (+9 more)

### Community 200 - "atc_controller.dart"
Cohesion: 0.08
Nodes (21): acknowledgedTurns, addDart, AtcSession, awaitingTurnConfirm, confirmTurn, endTurn, handleBoardEvent, leave (+13 more)

### Community 206 - "bulling_controller.dart"
Cohesion: 0.11
Nodes (16): acknowledgedTurns, addDart, awaitingTurnConfirm, BullingSession, confirmTurn, endTurn, handleBoardEvent, leave (+8 more)

### Community 207 - "game_config.dart"
Cohesion: 0.09
Nodes (19): GameConfigController, GameConfig, inRule, maxPlayers, offeredStartScores, outRule, playerIds, startingSeat (+11 more)

### Community 216 - "led_scheduler.dart"
Cohesion: 0.08
Nodes (22): _ambient, _deliver, dispose, _disposed, _enabled, enterGame, _gateClosed, _gateTimer (+14 more)

### Community 217 - "Feature ideas (not yet built)"
Cohesion: 0.29
Nodes (6): Candidate game modes, Feature ideas (not yet built), How a mode fits the existing architecture, Process note, Quality-of-life, Stats / data features

### Community 219 - "game_layout.dart"
Cohesion: 0.09
Nodes (19): aim, build, child, confirm, _confirmLeave, _desktopScoreShareWidth, GameLayout, gameOver (+11 more)

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
Cohesion: 0.12
Nodes (9): BullingConfigController, BullingConfig, bullseyeValue, offeredTargets, playerIds, target, BullseyeValue, points (+1 more)

### Community 272 - "TrainingGameScreen"
Cohesion: 0.53
Nodes (6): trainingLightsProvider, soundPlayerProvider, trainingProvider, trainingSoundControllerProvider, build, TrainingGameScreen

### Community 278 - "Notifier"
Cohesion: 0.21
Nodes (14): AtcController, build, build, BullingController, build, GameController, AtcConfigController, boardEventsProvider (+6 more)

## Knowledge Gaps
- **2461 isolated node(s):** `leg`, `acknowledgedTurns`, `awaitingTurnConfirm`, `pendingTurn`, `_live` (+2456 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 3078 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **17 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppDatabase` connect `migration_test.dart` to `mode_layout_test.dart`, `database.dart`, `providers.dart`, `package:flutter_test/flutter_test.dart`, `game_repository.dart`, `end_screen_test.dart`, `widget_test.dart`, `main_menu_screen_test.dart`, `setup_screens_test.dart`, `responsive_layout_test.dart`, `persistence_test.dart`, `FakeBoardSource`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **What connects `leg`, `acknowledgedTurns`, `awaitingTurnConfirm` to the rest of the system?**
  _2461 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `database.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03225806451612903 - nodes in this community are weakly interconnected._
- **Why does `FakeBoardSource` connect `FakeBoardSource` to `mode_layout_test.dart`, `responsive_layout_test.dart`, `end_screen_test.dart`, `fake_board_source.dart`, `board_source.dart`, `led_cue.dart`, `main_menu_screen_test.dart`, `setup_screens_test.dart`, `responsive_layout_test.dart`, `persistence_test.dart`?**
  _High betweenness centrality (0.017) - this node is a cross-community bridge._
- **Should `theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.02531645569620253 - nodes in this community are weakly interconnected._
- **Why does `dart` connect `dart` to `frame_assembler.dart`, `dart_keypad.dart`, `List`, `lights_providers.dart`, `game_config.dart`, `led_scheduler_test.dart`, `led_scheduler.dart`?**
  _High betweenness centrality (0.017) - this node is a cross-community bridge._
- **Should `checkout_search.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08333333333333333 - nodes in this community are weakly interconnected._