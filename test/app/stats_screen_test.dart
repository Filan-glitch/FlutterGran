import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/stats_screen.dart';
import 'package:fluttergran/app/widgets/stats/stats_charts.dart';
import 'package:fluttergran/app/widgets/stats/stats_grid.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

import '../support/darts.dart';
import '../support/database.dart';
import '../support/devices.dart';
import '../support/pump.dart';

void main() {
  late AppDatabase database;
  late GameRepository repository;
  late ProviderContainer container;

  setUp(() {
    database = memoryDatabase();
    repository = GameRepository(database);
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  /// A two-player x01 leg, darts alternating every three, won by [winner].
  Future<int> recordLeg(
    List<int> playerIds,
    List<ThrownDart> darts, {
    int startScore = 501,
    int? winner,
  }) async {
    final gameId = await repository.startGame(
      GameConfig(startScore: startScore, playerIds: playerIds),
    );
    for (var i = 0; i < darts.length; i++) {
      await repository.appendDart(
        gameId: gameId,
        ordinal: i,
        playerId: playerIds[(i ~/ 3) % playerIds.length],
        dart: darts[i],
      );
    }
    if (winner != null) await repository.finishGame(gameId, winner);
    return gameId;
  }

  Future<void> backdate(int gameId, Duration by) =>
      (database.update(database.games)..where((g) => g.id.equals(gameId)))
          .write(GamesCompanion(startedAt: Value(DateTime.now().subtract(by))));

  Future<void> open(
    WidgetTester tester, {
    Size size = phonePortrait,
    Locale? locale,
  }) async {
    setViewSize(tester, size);
    await pumpApp(
      tester,
      const StatsScreen(),
      container: container,
      locale: locale,
      typeScaled: true,
    );
    await pumpFrames(tester);
  }

  testWidgets('no players says so', (tester) async {
    await open(tester);
    expect(find.text('No players yet'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('a player with no legs says so', (tester) async {
    await repository.addPlayer('Finn');
    await open(tester);
    expect(find.text('No legs yet'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('one tab per mode played, and only those', (tester) async {
    final finn = await repository.addPlayer('Finn');
    final sam = await repository.addPlayer('Sam');
    await recordLeg([finn.id, sam.id], [t(20), t(20), t(20)]);
    final bulling = await repository.startBullingGame(
      BullingConfig(
        playerIds: [finn.id],
        bullseyeValue: BullseyeValue.two,
        target: 21,
      ),
    );
    await repository.appendDart(
      gameId: bulling,
      ordinal: 0,
      playerId: finn.id,
      dart: const ThrownDart(Segment.innerBull),
    );

    await open(tester);

    expect(find.widgetWithText(Tab, 'X01'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'BULLING'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'AROUND THE CLOCK'), findsNothing);
    expect(find.text('180.00'), findsWidgets, reason: 'the average leads');
    await closeApp(tester);
  });

  testWidgets('the range cuts what every figure counts', (tester) async {
    final finn = await repository.addPlayer('Finn');
    final sam = await repository.addPlayer('Sam');
    final old = await recordLeg([finn.id, sam.id], [s(1), s(1), s(1)]);
    await backdate(old, const Duration(days: 60));
    await recordLeg([finn.id, sam.id], [t(20), t(20), t(20)]);

    await open(tester);
    expect(find.text('6 darts over 2 legs'), findsOneWidget);

    await tester.tap(find.text('30 days'));
    await pumpFrames(tester);
    expect(find.text('3 darts over 1 leg'), findsOneWidget);
    expect(find.text('180.00'), findsWidgets);

    await closeApp(tester);
  });

  testWidgets('an empty range keeps its tab and explains itself', (
    tester,
  ) async {
    final finn = await repository.addPlayer('Finn');
    final old = await recordLeg([finn.id], [t(20), t(20), t(20)]);
    await backdate(old, const Duration(days: 60));

    await open(tester);
    await tester.tap(find.text('7 days'));
    await pumpFrames(tester);

    expect(find.widgetWithText(Tab, 'X01'), findsOneWidget);
    expect(find.text('Nothing in this range'), findsOneWidget);
    await closeApp(tester);
  });

  group('lays out without overflow', () {
    Future<void> seedFullRecord() async {
      final finn = await repository.addPlayer('Finn');
      final sam = await repository.addPlayer('Sam');
      for (var day = 0; day < 4; day++) {
        final game = await recordLeg(
          [finn.id, sam.id],
          [
            t(20), t(20), t(20), // Finn 501 -> 321
            s(1), s(1), s(1), //    Sam
            t(20), t(20), t(20), // Finn 321 -> 141
            s(1), s(1), s(1), //    Sam
            t(20), t(19), d(12), // Finn checks out 141
          ],
          winner: finn.id,
        );
        await backdate(game, Duration(days: day));
      }
    }

    for (final (name, size) in [
      ('phone', phonePortrait),
      ('phone on its side', phoneLandscape),
      ('tablet', tablet),
    ]) {
      testWidgets(name, (tester) async {
        await seedFullRecord();
        await open(tester, size: size);
        expect(tester.takeException(), isNull);
        expect(find.byType(TrendChart), findsOneWidget);
        await closeApp(tester);
      });
    }

    for (final size in [phonePortrait, tablet]) {
      testWidgets('in German at $size', (tester) async {
        await seedFullRecord();
        await open(tester, size: size, locale: const Locale('de'));
        expect(tester.takeException(), isNull);
        await closeApp(tester);
      });
    }

    for (final (name, size) in [
      ('laptop window', laptop),
      ('smallest window', smallestWindow),
      ('monitor', monitor),
    ]) {
      testWidgets(name, (tester) async {
        await seedFullRecord();
        await open(tester, size: size);
        expect(tester.takeException(), isNull);
        await closeApp(tester);
      }, variant: windows);
    }
  });

  test('card columns grow with the width', () {
    expect(statsColumnsFor(411), 1);
    expect(statsColumnsFor(statsTwoColumns), 2);
    expect(statsColumnsFor(1099), 2);
    expect(statsColumnsFor(statsThreeColumns), 3);
  });

  test('the rolling line smooths over its window', () {
    expect(rollingMean([], 5), isEmpty);
    expect(rollingMean([10, 20, 30], 2), [10, 15, 25]);
  });

  testWidgets('charts draw with no, one and many points', (tester) async {
    for (final points in [
      <TrendPoint>[],
      [(day: DateTime(2026, 11, 1), value: 50.0)],
      [
        for (var i = 0; i < 30; i++)
          (day: DateTime(2026, 10, 1 + i), value: 40.0 + i % 7),
      ],
    ]) {
      await pumpApp(
        tester,
        Scaffold(
          body: Column(
            children: [
              TrendChart(
                points: points,
                reference: 45,
                format: (v) => v.toStringAsFixed(0),
              ),
              const BarChart(
                bars: [
                  (label: '0+', count: 0, highlight: false),
                  (label: '180', count: 3, highlight: true),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
  });
}
