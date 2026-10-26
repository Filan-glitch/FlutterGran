import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/game_mode.dart';
import 'package:fluttergran/domain/higher_lower/higher_lower_config.dart';
import 'package:fluttergran/domain/higher_lower/higher_lower_reducer.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

void main() {
  late AppDatabase database;
  late GameRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = GameRepository(database);
  });

  tearDown(() => database.close());

  const ThrownDart s20 = ThrownDart(Segment(20, Ring.outerSingle));

  Future<HigherLowerConfig> seedHigherLowerGame({int players = 2}) async {
    final roster = [
      for (var i = 0; i < players; i++)
        await repository.addPlayer('Player ${i + 1}'),
    ];
    return HigherLowerConfig(
      playerIds: [for (final player in roster) player.id],
    );
  }

  Future<void> throwDarts(
    int gameId,
    int playerId,
    List<ThrownDart> darts,
  ) async {
    final start = (await repository.loadLog(gameId)).length;
    for (var i = 0; i < darts.length; i++) {
      await repository.appendDart(
        gameId: gameId,
        ordinal: start + i,
        playerId: playerId,
        dart: darts[i],
      );
    }
  }

  group('starting a game', () {
    test(
      'writes a games row under higherLower and seats the players',
      () async {
        final config = await seedHigherLowerGame(players: 3);
        final gameId = await repository.startHigherLowerGame(config);

        final game = await repository.loadGame(gameId);
        expect(game!.gameMode, GameMode.higherLower);
        expect(game.startScore, isNull);
        expect(game.doubleOut, isNull);
        expect(game.inRule, isNull);
        expect(game.outRule, isNull);

        final loaded = await repository.loadHigherLowerConfig(gameId);
        expect(loaded!.playerIds, config.playerIds);
      },
    );
  });

  group('replaying a stored game', () {
    test('the reloaded log folds to the same state it was played to', () async {
      final config = await seedHigherLowerGame();
      final gameId = await repository.startHigherLowerGame(config);
      await throwDarts(gameId, config.playerIds[0], const [s20, s20, s20]);

      final storedConfig = await repository.loadHigherLowerConfig(gameId);
      final leg = foldHigherLower(
        storedConfig!,
        await repository.loadLog(gameId),
      );

      expect(leg.higher, 60);
      expect(leg.currentPlayerId, config.playerIds[1]);
    });

    test('a game with fewer than two seats has no config to replay', () async {
      final config = await seedHigherLowerGame();
      final gameId = await repository.startHigherLowerGame(config);
      await (database.delete(
        database.gameSeats,
      )..where((s) => s.playerId.equals(config.playerIds[1]))).go();

      expect(await repository.loadHigherLowerConfig(gameId), isNull);
    });
  });

  group('this mode alongside the others', () {
    test(
      'watchAllHigherLowerLegs only ever returns Higher/Lower rows',
      () async {
        final config = await seedHigherLowerGame();
        await repository.startHigherLowerGame(config);

        expect(await repository.watchAllHigherLowerLegs().first, hasLength(1));
        expect(await repository.watchAllBullingLegs().first, isEmpty);
        expect(await repository.watchAllLegs().first, isEmpty);
      },
    );

    test(
      'appears in the resumable-leg query the same as any other mode',
      () async {
        final config = await seedHigherLowerGame();
        final gameId = await repository.startHigherLowerGame(config);
        await throwDarts(gameId, config.playerIds[0], const [s20]);

        expect(await repository.findResumableGameId(), gameId);
      },
    );

    test(
      'finishGame/reopenGame work unchanged for a Higher/Lower row',
      () async {
        final config = await seedHigherLowerGame();
        final gameId = await repository.startHigherLowerGame(config);

        await repository.finishGame(gameId, config.playerIds[0]);
        expect(
          (await repository.loadGame(gameId))!.winnerPlayerId,
          config.playerIds[0],
        );

        await repository.reopenGame(gameId);
        expect((await repository.loadGame(gameId))!.winnerPlayerId, isNull);
      },
    );
  });
}
