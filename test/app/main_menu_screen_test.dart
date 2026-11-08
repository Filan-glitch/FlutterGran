import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/labels.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/atc_game_screen.dart';
import 'package:fluttergran/app/screens/bulling_game_screen.dart';
import 'package:fluttergran/app/screens/higher_lower_game_screen.dart';
import 'package:fluttergran/app/screens/main_menu_screen.dart';
import 'package:fluttergran/app/screens/roster_screen.dart';
import 'package:fluttergran/app/screens/rules_screen.dart';
import 'package:fluttergran/app/screens/select_game_mode_screen.dart';
import 'package:fluttergran/app/screens/settings_screen.dart';
import 'package:fluttergran/app/screens/stats_screen.dart';
import 'package:fluttergran/app/screens/training_setup_screen.dart';
import 'package:fluttergran/app/widgets/board_connection_button.dart';
import 'package:fluttergran/app/widgets/chalk_mark.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/atc/atc_config.dart';
import 'package:fluttergran/domain/atc/atc_variant.dart';
import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/game_mode.dart';
import 'package:fluttergran/domain/higher_lower/higher_lower_config.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

import '../support/database.dart';
import '../support/devices.dart';
import '../support/pump.dart';

/// The mode name the resume banner prefixes its format eyebrow with -
/// read from the registry rather than hardcoded, same reasoning as the
/// banner itself.
String _modeName(GameMode mode) => gameModeRegistry
    .firstWhere((descriptor) => descriptor.id == mode)
    .displayName;

void main() {
  late AppDatabase database;
  late GameRepository repository;
  late FakeBoardSource board;
  late ProviderContainer container;

  setUp(() {
    database = memoryDatabase();
    repository = GameRepository(database);
    board = FakeBoardSource();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        boardSourceProvider.overrideWithValue(board),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await board.dispose();
    await database.close();
  });

  Future<void> pump(WidgetTester tester) async {
    await pumpApp(tester, const MainMenuScreen(), container: container);
    await pumpFrames(tester);
  }

  testWidgets('shows no resume card when nothing is in progress', (
    tester,
  ) async {
    await pump(tester);

    expect(find.byKey(const Key('menu-resume-banner')), findsNothing);
  });

  testWidgets('shows the resume card for a leg with darts thrown', (
    tester,
  ) async {
    final finn = await repository.addPlayer('Finn');
    final gameId = await repository.startGame(
      GameConfig(startScore: 501, playerIds: [finn.id]),
    );
    await repository.appendDart(
      gameId: gameId,
      ordinal: 0,
      playerId: finn.id,
      dart: const ThrownDart.miss(),
    );

    await pump(tester);

    expect(find.byKey(const Key('menu-resume-banner')), findsOneWidget);
    expect(find.text('FINN'), findsOneWidget);
  });

  testWidgets('hides the resume card once that leg is the one already open', (
    tester,
  ) async {
    final finn = await repository.addPlayer('Finn');
    final gameId = await repository.startGame(
      GameConfig(startScore: 501, playerIds: [finn.id]),
    );
    await repository.appendDart(
      gameId: gameId,
      ordinal: 0,
      playerId: finn.id,
      dart: const ThrownDart.miss(),
    );
    container.read(currentGameIdProvider.notifier).set(gameId);

    await pump(tester);

    expect(find.byKey(const Key('menu-resume-banner')), findsNothing);
  });

  testWidgets('tapping resume loads the leg and opens the game screen', (
    tester,
  ) async {
    final finn = await repository.addPlayer('Finn');
    final gameId = await repository.startGame(
      GameConfig(startScore: 501, playerIds: [finn.id]),
    );
    await repository.appendDart(
      gameId: gameId,
      ordinal: 0,
      playerId: finn.id,
      dart: const ThrownDart.miss(),
    );

    await pump(tester);
    await tester.tap(find.byKey(const Key('menu-resume-banner')));
    await pumpFrames(tester);

    expect(container.read(currentGameIdProvider), gameId);
    expect(find.byType(MainMenuScreen), findsNothing);
  });

  group('an Around the Clock leg', () {
    testWidgets('shows the resume card with the variant and current stop', (
      tester,
    ) async {
      final finn = await repository.addPlayer('Finn');
      final gameId = await repository.startAtcGame(
        AtcConfig(playerIds: [finn.id], variant: AtcVariant.masters),
      );
      await repository.appendDart(
        gameId: gameId,
        ordinal: 0,
        playerId: finn.id,
        dart: const ThrownDart(Segment(1, Ring.doubleRing)),
      );

      await pump(tester);

      expect(find.byKey(const Key('menu-resume-banner')), findsOneWidget);
      expect(
        find.text('${_modeName(GameMode.aroundTheClock)} · MASTERS'),
        findsOneWidget,
      );
      expect(find.text('FINN'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('resume loads it into AtcGameScreen', (tester) async {
      final finn = await repository.addPlayer('Finn');
      final gameId = await repository.startAtcGame(
        AtcConfig(playerIds: [finn.id], variant: AtcVariant.anyPart),
      );
      await repository.appendDart(
        gameId: gameId,
        ordinal: 0,
        playerId: finn.id,
        dart: const ThrownDart(Segment(1, Ring.outerSingle)),
      );

      await pump(tester);
      await tester.tap(find.byKey(const Key('menu-resume-banner')));
      await pumpFrames(tester);

      expect(container.read(currentGameIdProvider), gameId);
      expect(find.byType(AtcGameScreen), findsOneWidget);
    });
  });

  group('a Bulling leg', () {
    testWidgets(
      'shows the resume card with the bullseye value, target and score',
      (tester) async {
        final finn = await repository.addPlayer('Finn');
        final gameId = await repository.startBullingGame(
          BullingConfig(
            playerIds: [finn.id],
            bullseyeValue: BullseyeValue.two,
            target: 21,
          ),
        );
        await repository.appendDart(
          gameId: gameId,
          ordinal: 0,
          playerId: finn.id,
          dart: const ThrownDart(Segment.outerBull),
        );

        await pump(tester);

        final context = tester.element(find.byType(MainMenuScreen));
        expect(find.byKey(const Key('menu-resume-banner')), findsOneWidget);
        expect(
          find.text(
            '${_modeName(GameMode.bulling)} · '
            '${bullseyeValueLabel(context, BullseyeValue.two)} · 21',
          ),
          findsOneWidget,
        );
        expect(find.text('FINN'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
      },
    );

    testWidgets('resume loads it into BullingGameScreen', (tester) async {
      final finn = await repository.addPlayer('Finn');
      final gameId = await repository.startBullingGame(
        BullingConfig(
          playerIds: [finn.id],
          bullseyeValue: BullseyeValue.three,
          target: 21,
        ),
      );
      await repository.appendDart(
        gameId: gameId,
        ordinal: 0,
        playerId: finn.id,
        dart: const ThrownDart(Segment.outerBull),
      );

      await pump(tester);
      await tester.tap(find.byKey(const Key('menu-resume-banner')));
      await pumpFrames(tester);

      expect(container.read(currentGameIdProvider), gameId);
      expect(find.byType(BullingGameScreen), findsOneWidget);
    });
  });

  group('a Higher/Lower leg', () {
    Future<int> seed() async {
      final finn = await repository.addPlayer('Finn');
      final ada = await repository.addPlayer('Ada');
      final gameId = await repository.startHigherLowerGame(
        HigherLowerConfig(playerIds: [finn.id, ada.id]),
      );
      // Finn goes higher with 60 + 60 + 1, and Ada is one dart into their
      // turn - still open, so still resumable.
      for (final (ordinal, playerId, dart) in [
        (0, finn.id, const ThrownDart(Segment(20, Ring.triple))),
        (1, finn.id, const ThrownDart(Segment(20, Ring.triple))),
        (2, finn.id, const ThrownDart(Segment(1, Ring.outerSingle))),
        (3, ada.id, const ThrownDart(Segment(5, Ring.outerSingle))),
      ]) {
        await repository.appendDart(
          gameId: gameId,
          ordinal: ordinal,
          playerId: playerId,
          dart: dart,
        );
      }
      return gameId;
    }

    testWidgets('shows the resume card with both values', (tester) async {
      await seed();
      await pump(tester);

      expect(find.byKey(const Key('menu-resume-banner')), findsOneWidget);
      expect(
        find.text('${_modeName(GameMode.higherLower)} · 121 · 26'),
        findsOneWidget,
      );
      expect(find.text('FINN'), findsOneWidget);
      expect(find.text('ADA'), findsOneWidget);
    });

    testWidgets('resume loads it into HigherLowerGameScreen', (tester) async {
      final gameId = await seed();

      await pump(tester);
      await tester.tap(find.byKey(const Key('menu-resume-banner')));
      await pumpFrames(tester);

      expect(container.read(currentGameIdProvider), gameId);
      expect(find.byType(HigherLowerGameScreen), findsOneWidget);
      expect(container.read(higherLowerGameProvider).leg.higher, 121);
    });
  });

  testWidgets('PLAY navigates to the mode picker', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('menu-play-button')));
    await pumpFrames(tester);

    expect(find.byType(SelectGameModeScreen), findsOneWidget);
  });

  testWidgets('TRAINING navigates to the training setup screen', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('menu-training-row')));
    await pumpFrames(tester);

    expect(find.byType(TrainingSetupScreen), findsOneWidget);
  });

  testWidgets('RULES navigates to the rules screen', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('menu-rules-row')));
    await pumpFrames(tester);

    expect(find.byType(RulesScreen), findsOneWidget);
  });

  testWidgets('STATISTICS navigates to the stats screen', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('menu-statistics-row')));
    await pumpFrames(tester);

    expect(find.byType(StatsScreen), findsOneWidget);
  });

  testWidgets('ROSTER navigates to the roster screen', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('menu-roster-row')));
    await pumpFrames(tester);

    expect(find.byType(RosterScreen), findsOneWidget);
  });

  testWidgets('SETTINGS navigates to the settings screen', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('menu-settings-row')));
    await pumpFrames(tester);

    expect(find.byType(SettingsScreen), findsOneWidget);
  });
  testWidgets('carries the brand mark and the board light', (tester) async {
    await pump(tester);

    expect(find.byType(ChalkMark), findsOneWidget);
    expect(find.byType(ChalkWordmark), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byKey(const Key('menu-board-button')),
      ),
      findsOneWidget,
    );
    expect(find.byType(BoardConnectionButton), findsOneWidget);
  });

  group('layout', () {
    Offset playAt(WidgetTester tester) =>
        tester.getCenter(find.byKey(const Key('menu-play-button')));
    Offset rowAt(WidgetTester tester) =>
        tester.getCenter(find.byKey(const Key('menu-training-row')));

    testWidgets('stacks everything in one column on a phone', (tester) async {
      setViewSize(tester, phonePortrait);
      await pump(tester);

      expect(playAt(tester).dx, moreOrLessEquals(rowAt(tester).dx));
      expect(playAt(tester).dy, lessThan(rowAt(tester).dy));
    });

    testWidgets('puts PLAY beside the other actions on the tablet', (
      tester,
    ) async {
      setViewSize(tester, tabS6Lite);
      await pump(tester);

      expect(playAt(tester).dx, lessThan(rowAt(tester).dx));
      expect(tester.takeException(), isNull);
    });

    testWidgets('puts PLAY beside the other actions in a laptop window', (
      tester,
    ) async {
      setViewSize(tester, laptop);
      await pump(tester);

      expect(playAt(tester).dx, lessThan(rowAt(tester).dx));
      expect(tester.takeException(), isNull);
    }, variant: windows);

    testWidgets('keeps the resume card with PLAY in the smallest window', (
      tester,
    ) async {
      final finn = await repository.addPlayer('Finn');
      final gameId = await repository.startGame(
        GameConfig(startScore: 501, playerIds: [finn.id]),
      );
      await repository.appendDart(
        gameId: gameId,
        ordinal: 0,
        playerId: finn.id,
        dart: const ThrownDart.miss(),
      );

      setViewSize(tester, smallestWindow);
      await pump(tester);

      final resume = tester.getCenter(
        find.byKey(const Key('menu-resume-banner')),
      );
      expect(resume.dx, moreOrLessEquals(playAt(tester).dx));
      expect(resume.dx, lessThan(rowAt(tester).dx));
      expect(tester.takeException(), isNull);
    }, variant: windows);
  });
}
