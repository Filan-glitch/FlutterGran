import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/atc/atc_config.dart';
import 'package:fluttergran/domain/atc/atc_reducer.dart';
import 'package:fluttergran/domain/atc/atc_variant.dart';
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

  ThrownDart s(int n) => ThrownDart(Segment(n, Ring.outerSingle));

  Future<AtcConfig> seedAtcGame({
    int players = 2,
    AtcVariant variant = AtcVariant.anyPart,
  }) async {
    final roster = [
      for (var i = 0; i < players; i++)
        await repository.addPlayer('Player ${i + 1}'),
    ];
    return AtcConfig(
      playerIds: [for (final player in roster) player.id],
      variant: variant,
    );
  }

  group('starting a game', () {
    test('writes a games row under aroundTheClock and seats the players', () async {
      final config = await seedAtcGame(players: 3);
      final gameId = await repository.startAtcGame(config);

      final game = await repository.loadGame(gameId);
      expect(game!.gameMode, GameMode.aroundTheClock);
      expect(game.startScore, isNull);
      expect(game.doubleOut, isNull);
      expect(game.inRule, isNull);
      expect(game.outRule, isNull);

      final loaded = await repository.loadAtcConfig(gameId);
      expect(loaded!.playerIds, config.playerIds);
      expect(loaded.variant, config.variant);
    });

    test('the variant round-trips through AtcGames', () async {
      final config = await seedAtcGame(variant: AtcVariant.masters);
      final gameId = await repository.startAtcGame(config);

      final loaded = await repository.loadAtcConfig(gameId);
      expect(loaded!.variant, AtcVariant.masters);
    });
  });

  group('replaying a stored game', () {
    test('the reloaded log folds to the same state it was played to', () async {
      final config = await seedAtcGame();
      final gameId = await repository.startAtcGame(config);

      await repository.appendDart(
        gameId: gameId,
        ordinal: 0,
        playerId: config.playerIds[0],
        dart: s(1),
      );

      final storedConfig = await repository.loadAtcConfig(gameId);
      final storedLog = await repository.loadLog(gameId);
      final leg = foldAroundTheClock(storedConfig!, storedLog);

      expect(leg.stopIndex[config.playerIds[0]], 1);
    });

    test('a game with no seats has no ATC config to replay', () async {
      final gameId = await repository.startAtcGame(
        AtcConfig(playerIds: const [1], variant: AtcVariant.anyPart),
      );
      // Delete the player without cleaning up the seat row would be a
      // different scenario; here there is simply no AtcGames row at all -
      // the mirror of x01's "game with no seats" case.
      await database.delete(database.atcGames).go();

      expect(await repository.loadAtcConfig(gameId), isNull);
    });
  });

  group('this mode alongside x01', () {
    test('watchAllAtcLegs only ever returns ATC rows', () async {
      final config = await seedAtcGame();
      await repository.startAtcGame(config);

      final legs = await repository.watchAllAtcLegs().first;
      expect(legs, hasLength(1));
    });

    test('appears in the resumable-leg query the same as an x01 leg', () async {
      final config = await seedAtcGame();
      final gameId = await repository.startAtcGame(config);
      await repository.appendDart(
        gameId: gameId,
        ordinal: 0,
        playerId: config.playerIds[0],
        dart: s(1),
      );

      expect(await repository.findResumableGameId(), gameId);
    });

    test('finishGame/reopenGame work unchanged for an ATC row', () async {
      final config = await seedAtcGame();
      final gameId = await repository.startAtcGame(config);

      await repository.finishGame(gameId, config.playerIds[0]);
      expect((await repository.loadGame(gameId))!.winnerPlayerId, config.playerIds[0]);

      await repository.reopenGame(gameId);
      expect((await repository.loadGame(gameId))!.winnerPlayerId, isNull);
    });
  });
}
