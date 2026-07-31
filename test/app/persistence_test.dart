// Only OrderingTerm is needed here; drift also exports matcher-like names.
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/game_controller.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:fluttergran/domain/x01/leg_reducer.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

/// Lets the fire-and-forget database writes land before assertions run.
Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

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

  ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));
  ThrownDart d(int n) => ThrownDart(Segment(n, Ring.doubleRing));

  Future<GameConfig> seedGame({
    int startScore = 501,
    int players = 2,
  }) async {
    final roster = [
      for (var i = 0; i < players; i++)
        await repository.addPlayer('Player ${i + 1}'),
    ];
    final config = GameConfig(
      startScore: startScore,
      playerIds: [for (final player in roster) player.id],
    );

    final gameId = await repository.startGame(config);
    container.read(gameConfigProvider.notifier).update(config);
    container.read(currentGameIdProvider.notifier).set(gameId);
    container.listen(gameProvider, (_, _) {});
    return config;
  }

  int gameId() => container.read(currentGameIdProvider)!;
  GameController controller() => container.read(gameProvider.notifier);
  GameSession session() => container.read(gameProvider);

  group('the roster', () {
    test('a player survives being written and read back', () async {
      await repository.addPlayer('Finn');
      final players = await repository.allPlayers();

      expect(players.single.name, 'Finn');
      expect(players.single.id, isPositive);
    });

    test('players come back in name order', () async {
      await repository.addPlayer('Zoe');
      await repository.addPlayer('Alex');

      expect(
        (await repository.allPlayers()).map((p) => p.name),
        ['Alex', 'Zoe'],
      );
    });

    test('deleting a player removes them', () async {
      final player = await repository.addPlayer('Temp');
      await repository.removePlayer(player.id);

      expect(await repository.allPlayers(), isEmpty);
    });
  });

  group('the dart log', () {
    test('darts are written in throwing order', () async {
      await seedGame();

      controller()
        ..addDart(t(20))
        ..addDart(t(19))
        ..addDart(const ThrownDart.miss());
      await settle();

      final log = await repository.loadLog(gameId());
      expect(log.map((dart) => dart.label), ['T20', 'T19', 'MISS']);
    });

    test('a miss is stored without a segment and scores zero', () async {
      await seedGame();

      controller().addDart(const ThrownDart.miss());
      await settle();

      final rows = await database.select(database.dartEvents).get();
      expect(rows.single.number, isNull);
      expect(rows.single.ring, isNull);
      expect(rows.single.value, 0);
    });

    test('each dart is attributed to whoever actually threw it', () async {
      final config = await seedGame();

      controller()
        ..addDart(t(20))
        ..addDart(t(20))
        ..addDart(t(20))
        ..confirmTurn()
        ..addDart(t(1));
      await settle();

      final rows = await (database.select(database.dartEvents)
            ..orderBy([(row) => OrderingTerm(expression: row.ordinal)]))
          .get();

      expect(
        rows.map((row) => row.playerId),
        [
          config.playerIds[0],
          config.playerIds[0],
          config.playerIds[0],
          config.playerIds[1],
        ],
      );
    });

    test('undo removes the row rather than recording a correction', () async {
      await seedGame();

      controller()
        ..addDart(t(20))
        ..addDart(t(19));
      await settle();
      expect(await repository.loadLog(gameId()), hasLength(2));

      controller().undo();
      await settle();

      final log = await repository.loadLog(gameId());
      expect(log.map((dart) => dart.label), ['T20']);
    });
  });

  group('replaying a stored game', () {
    test('the reloaded log folds to the same state it was played to', () async {
      final config = await seedGame();

      controller()
        ..addDart(t(20))
        ..addDart(t(20))
        ..addDart(t(5))
        ..confirmTurn()
        ..addDart(t(20))
        ..addDart(const ThrownDart.miss())
        ..addDart(d(10));
      await settle();

      final storedConfig = await repository.loadConfig(gameId());
      final storedLog = await repository.loadLog(gameId());
      final replayed = foldLeg(storedConfig!, storedLog);

      expect(replayed.remaining, session().leg.remaining);
      expect(replayed.currentPlayerId, session().leg.currentPlayerId);
      expect(replayed.turns.length, session().leg.turns.length);
      expect(storedConfig.playerIds, config.playerIds);
      expect(storedConfig.startScore, 501);
    });

    test('seating order round-trips', () async {
      final config = await seedGame(players: 4);
      final stored = await repository.loadConfig(gameId());

      expect(stored!.playerIds, config.playerIds);
    });
  });

  group('finishing', () {
    test('a checkout records the winner', () async {
      final config = await seedGame(startScore: 40);

      controller().addDart(d(20));
      await settle();

      final game = await (database.select(database.games)
            ..where((g) => g.id.equals(gameId())))
          .getSingle();

      expect(game.winnerPlayerId, config.playerIds[0]);
      expect(game.finishedAt, isNotNull);
    });

    test('undoing a checkout reopens the game', () async {
      await seedGame(startScore: 40);

      controller().addDart(d(20));
      await settle();

      controller().undo();
      await settle();

      final game = await (database.select(database.games)
            ..where((g) => g.id.equals(gameId())))
          .getSingle();

      expect(game.winnerPlayerId, isNull);
      expect(game.finishedAt, isNull);
    });
  });

  test('nothing is written when no game is being persisted', () async {
    container.listen(gameProvider, (_, _) {});
    controller().addDart(t(20));
    await settle();

    expect(await database.select(database.dartEvents).get(), isEmpty);
  });
}
