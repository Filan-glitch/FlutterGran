import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/stats/player_stats.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

void main() {
  late AppDatabase database;
  late GameRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = GameRepository(database);
  });

  tearDown(() => database.close());

  ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));
  ThrownDart d(int n) => ThrownDart(Segment(n, Ring.doubleRing));

  /// Writes a finished leg straight through the repository.
  Future<int> recordLeg(
    List<int> playerIds,
    List<ThrownDart> darts, {
    int startScore = 501,
    int? winner,
  }) async {
    final config = GameConfig(startScore: startScore, playerIds: playerIds);
    final gameId = await repository.startGame(config);

    for (var i = 0; i < darts.length; i++) {
      await repository.appendDart(
        gameId: gameId,
        ordinal: i,
        // Turns rotate every three darts.
        playerId: playerIds[(i ~/ 3) % playerIds.length],
        dart: darts[i],
      );
    }
    if (winner != null) await repository.finishGame(gameId, winner);
    return gameId;
  }

  test('a stored leg produces the statistics it earned', () async {
    final finn = await repository.addPlayer('Finn');
    final sam = await repository.addPlayer('Sam');

    await recordLeg(
      [finn.id, sam.id],
      [t(20), t(20), t(20), t(1), t(1), t(1)],
    );

    final legs = await repository.watchAllLegs().first;
    final stats = computePlayerStats(finn.id, legs);

    expect(stats.legsPlayed, 1);
    expect(stats.dartsThrown, 3);
    expect(stats.average, 180.0);
    expect(stats.turnsOf180, 1);
  });

  test('a checkout shows up as a win and a best leg', () async {
    final finn = await repository.addPlayer('Finn');
    final sam = await repository.addPlayer('Sam');

    await recordLeg(
      [finn.id, sam.id],
      [d(20)],
      startScore: 40,
      winner: finn.id,
    );

    final legs = await repository.watchAllLegs().first;
    final stats = computePlayerStats(finn.id, legs);

    expect(stats.legsWon, 1);
    expect(stats.bestCheckout, 40);
    expect(stats.fewestDartsToWin, 1);
    expect(stats.checkoutRate, 1.0);
  });

  test('the heatmap counts where darts landed, per player', () async {
    final finn = await repository.addPlayer('Finn');
    final sam = await repository.addPlayer('Sam');

    await recordLeg(
      [finn.id, sam.id],
      [t(20), t(20), d(5), t(1), t(1), t(1)],
    );

    final finnCounts = await repository.segmentCounts(finn.id);
    expect(finnCounts[const Segment(20, Ring.triple)], 2);
    expect(finnCounts[const Segment(5, Ring.doubleRing)], 1);
    expect(finnCounts[const Segment(1, Ring.triple)], isNull);

    final samCounts = await repository.segmentCounts(sam.id);
    expect(samCounts[const Segment(1, Ring.triple)], 3);
    expect(samCounts[const Segment(20, Ring.triple)], isNull);
  });

  test('misses are not plotted on the heatmap', () async {
    final finn = await repository.addPlayer('Finn');
    await recordLeg([finn.id], [t(20), const ThrownDart.miss()]);

    final counts = await repository.segmentCounts(finn.id);
    expect(counts.values.fold(0, (a, b) => a + b), 1);
  });

  test('statistics accumulate across games', () async {
    final finn = await repository.addPlayer('Finn');

    await recordLeg([finn.id], [t(20), t(20), t(20)]);
    await recordLeg([finn.id], [t(20), t(20), t(20)]);

    final legs = await repository.watchAllLegs().first;
    final stats = computePlayerStats(finn.id, legs);

    expect(stats.legsPlayed, 2);
    expect(stats.dartsThrown, 6);
    expect(stats.turnsOf180, 2);
  });

  test('a player with no games reads as empty, not as an error', () async {
    final newcomer = await repository.addPlayer('Newcomer');

    final legs = await repository.watchAllLegs().first;
    final stats = computePlayerStats(newcomer.id, legs);

    expect(stats.legsPlayed, 0);
    expect(stats.average, isNull);
    expect(await repository.segmentCounts(newcomer.id), isEmpty);
  });
}
