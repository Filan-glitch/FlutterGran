import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_reducer.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/game_mode.dart';
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

  final ThrownDart sbull = ThrownDart(Segment.outerBull);

  Future<BullingConfig> seedBullingGame({
    int players = 2,
    BullseyeValue bullseyeValue = BullseyeValue.two,
    int target = 21,
  }) async {
    final roster = [
      for (var i = 0; i < players; i++)
        await repository.addPlayer('Player ${i + 1}'),
    ];
    return BullingConfig(
      playerIds: [for (final player in roster) player.id],
      bullseyeValue: bullseyeValue,
      target: target,
    );
  }

  group('starting a game', () {
    test('writes a games row under bulling and seats the players', () async {
      final config = await seedBullingGame(players: 3);
      final gameId = await repository.startBullingGame(config);

      final game = await repository.loadGame(gameId);
      expect(game!.gameMode, GameMode.bulling);
      expect(game.startScore, isNull);
      expect(game.doubleOut, isNull);

      final loaded = await repository.loadBullingConfig(gameId);
      expect(loaded!.playerIds, config.playerIds);
      expect(loaded.bullseyeValue, config.bullseyeValue);
      expect(loaded.target, config.target);
    });

    test('the bullseye value and target round-trip through BullingGames', () async {
      final config = await seedBullingGame(
        bullseyeValue: BullseyeValue.three,
        target: 31,
      );
      final gameId = await repository.startBullingGame(config);

      final loaded = await repository.loadBullingConfig(gameId);
      expect(loaded!.bullseyeValue, BullseyeValue.three);
      expect(loaded.target, 31);
    });
  });

  group('replaying a stored game', () {
    test('the reloaded log folds to the same state it was played to', () async {
      final config = await seedBullingGame();
      final gameId = await repository.startBullingGame(config);

      await repository.appendDart(
        gameId: gameId,
        ordinal: 0,
        playerId: config.playerIds[0],
        dart: sbull,
      );

      final storedConfig = await repository.loadBullingConfig(gameId);
      final storedLog = await repository.loadLog(gameId);
      final leg = foldBulling(storedConfig!, storedLog);

      expect(leg.scoreFor(config.playerIds[0]), 1);
    });

    test('a game with no seats has no Bulling config to replay', () async {
      final gameId = await repository.startBullingGame(
        BullingConfig(
          playerIds: const [1],
          bullseyeValue: BullseyeValue.two,
          target: 21,
        ),
      );
      await database.delete(database.bullingGames).go();

      expect(await repository.loadBullingConfig(gameId), isNull);
    });
  });

  group('this mode alongside the others', () {
    test('watchAllBullingLegs only ever returns Bulling rows', () async {
      final config = await seedBullingGame();
      await repository.startBullingGame(config);

      final legs = await repository.watchAllBullingLegs().first;
      expect(legs, hasLength(1));
    });

    test('appears in the resumable-leg query the same as any other mode', () async {
      final config = await seedBullingGame();
      final gameId = await repository.startBullingGame(config);
      await repository.appendDart(
        gameId: gameId,
        ordinal: 0,
        playerId: config.playerIds[0],
        dart: sbull,
      );

      expect(await repository.findResumableGameId(), gameId);
    });

    test('finishGame/reopenGame work unchanged for a Bulling row', () async {
      final config = await seedBullingGame();
      final gameId = await repository.startBullingGame(config);

      await repository.finishGame(gameId, config.playerIds[0]);
      expect(
        (await repository.loadGame(gameId))!.winnerPlayerId,
        config.playerIds[0],
      );

      await repository.reopenGame(gameId);
      expect((await repository.loadGame(gameId))!.winnerPlayerId, isNull);
    });
  });
}
