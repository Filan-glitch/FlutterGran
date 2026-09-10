import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/atc_game_screen.dart';
import 'package:fluttergran/app/screens/bulling_game_screen.dart';
import 'package:fluttergran/app/screens/bulling_setup_screen.dart'
    show bullseyeValueLabel;
import 'package:fluttergran/app/screens/main_menu_screen.dart';
import 'package:fluttergran/app/screens/roster_screen.dart';
import 'package:fluttergran/app/screens/select_game_mode_screen.dart';
import 'package:fluttergran/app/screens/settings_screen.dart';
import 'package:fluttergran/app/screens/stats_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/atc/atc_config.dart';
import 'package:fluttergran/domain/atc/atc_variant.dart';
import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/game_mode.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

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
    database = AppDatabase(NativeDatabase.memory());
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

  /// Pumps frames without settling: the resumable-leg stream and the
  /// database writes both land a frame or two after the query starts.
  Future<void> frames(WidgetTester tester) async {
    // Long enough to cover a route transition (~300ms) with margin, so the
    // outgoing route is fully gone rather than one frame short of it.
    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: buildTheme(), home: const MainMenuScreen()),
      ),
    );
    await frames(tester);
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
    await frames(tester);

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
        dart: ThrownDart(Segment(1, Ring.doubleRing)),
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
        dart: ThrownDart(Segment(1, Ring.outerSingle)),
      );

      await pump(tester);
      await tester.tap(find.byKey(const Key('menu-resume-banner')));
      await frames(tester);

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

        expect(find.byKey(const Key('menu-resume-banner')), findsOneWidget);
        expect(
          find.text(
            '${_modeName(GameMode.bulling)} · '
            '${bullseyeValueLabel(BullseyeValue.two)} · 21',
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
      await frames(tester);

      expect(container.read(currentGameIdProvider), gameId);
      expect(find.byType(BullingGameScreen), findsOneWidget);
    });
  });

  testWidgets('PLAY navigates to the mode picker', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('menu-play-button')));
    await frames(tester);

    expect(find.byType(SelectGameModeScreen), findsOneWidget);
  });

  testWidgets('STATISTICS navigates to the stats screen', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('menu-statistics-row')));
    await frames(tester);

    expect(find.byType(StatsScreen), findsOneWidget);
  });

  testWidgets('ROSTER navigates to the roster screen', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('menu-roster-row')));
    await frames(tester);

    expect(find.byType(RosterScreen), findsOneWidget);
  });

  testWidgets('SETTINGS navigates to the settings screen', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('menu-settings-row')));
    await frames(tester);

    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
