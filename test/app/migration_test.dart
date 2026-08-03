import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/leg_reducer.dart';
import 'package:fluttergran/domain/x01/match_state.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

/// The games table exactly as schema 2 wrote it: no match, no leg number.
///
/// Spelled out rather than built from the current table definition, because the
/// point of the exercise is to start from a shape the code no longer knows how
/// to produce.
const String _gamesAtV2 = '''
CREATE TABLE IF NOT EXISTS games (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  start_score INTEGER NOT NULL,
  double_out INTEGER NOT NULL DEFAULT 1 CHECK ("double_out" IN (0, 1)),
  started_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  finished_at INTEGER NULL,
  winner_player_id INTEGER NULL REFERENCES players (id)
)''';

/// An [AppDatabase] frozen at schema 2, used to lay a database down the way an
/// older build of the app would have left it on someone's phone.
class _SchemaV2 extends AppDatabase {
  _SchemaV2(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createTable(players);
      await m.database.customStatement(_gamesAtV2);
      await m.createTable(gameSeats);
      await m.createTable(dartEvents);
      await m.createTable(segmentCalibrations);
    },
  );
}

void main() {
  // Every test here opens the same file twice on purpose - once as the old
  // schema, once as the current one - never at the same time.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory directory;
  late File file;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('chalk-migration');
    file = File('${directory.path}/chalk.sqlite');
  });

  tearDown(() => directory.deleteSync(recursive: true));

  ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));
  ThrownDart d(int n) => ThrownDart(Segment(n, Ring.doubleRing));

  /// Writes one leg the way schema 2 stored legs, and returns its id.
  Future<int> seedV2({
    required List<ThrownDart> darts,
    int startScore = 501,
    int? winningSeat,
  }) async {
    final db = _SchemaV2(NativeDatabase(file));

    final finn = await db
        .into(db.players)
        .insertReturning(PlayersCompanion.insert(name: 'Finn'));
    final sam = await db
        .into(db.players)
        .insertReturning(PlayersCompanion.insert(name: 'Sam'));
    final seats = [finn.id, sam.id];

    await db.customStatement(
      'INSERT INTO games (start_score, double_out, finished_at, '
      'winner_player_id) VALUES (?, 1, ?, ?)',
      [
        startScore,
        // Seconds since the epoch, which is how drift stores a DateTime.
        if (winningSeat == null)
          null
        else
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
        if (winningSeat == null) null else seats[winningSeat],
      ],
    );
    final gameId = (await db
            .customSelect('SELECT MAX(id) AS id FROM games')
            .getSingle())
        .read<int>('id');

    for (var seat = 0; seat < seats.length; seat++) {
      await db
          .into(db.gameSeats)
          .insert(
            GameSeatsCompanion.insert(
              gameId: gameId,
              playerId: seats[seat],
              seat: seat,
            ),
          );
    }

    for (var i = 0; i < darts.length; i++) {
      await db
          .into(db.dartEvents)
          .insert(
            DartEventsCompanion.insert(
              gameId: gameId,
              ordinal: i,
              // Turns rotate every three darts, as they did then.
              playerId: seats[(i ~/ 3) % seats.length],
              number: Value(darts[i].segment?.number),
              ring: Value(darts[i].segment?.ring),
              value: darts[i].value,
            ),
          );
    }

    await db.close();
    return gameId;
  }

  /// Opens the same file with the current schema, running the migration.
  AppDatabase migrated() => AppDatabase(NativeDatabase(file));

  test('a version 2 database opens at version 3', () async {
    await seedV2(darts: [t(20)]);

    final db = migrated();
    // Touching a table is what actually forces the migration to run.
    await db.select(db.matches).get();

    final version = await db
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), 3);

    await db.close();
  });

  test('an old leg still folds to exactly what was thrown', () async {
    final gameId = await seedV2(
      darts: [t(20), t(20), t(20), t(1), t(1), t(1), t(19)],
    );

    final db = migrated();
    final repository = GameRepository(db);

    final config = await repository.loadConfig(gameId);
    expect(config, isNotNull);
    expect(config!.startScore, 501);
    expect(config.playerIds, hasLength(2));
    expect(
      config.startingSeat,
      0,
      reason: 'a leg with no match still opens on the first seat',
    );

    final leg = foldLeg(config, await repository.loadLog(gameId));
    expect(leg.remaining[config.playerIds[0]], 501 - 180 - 57);
    expect(leg.remaining[config.playerIds[1]], 501 - 9);
    expect(leg.turns, hasLength(2));
    expect(leg.dartsThrownBy(config.playerIds[0]), 4);

    await db.close();
  });

  test('an old leg belongs to no match, and is not made to', () async {
    final gameId = await seedV2(darts: [t(20)]);

    final db = migrated();
    final game = await GameRepository(db).loadGame(gameId);

    expect(game!.matchId, isNull);
    expect(game.legNumber, isNull);
    expect(await db.select(db.matches).get(), isEmpty);

    await db.close();
  });

  test('an old unfinished leg is still offered back', () async {
    final gameId = await seedV2(darts: [t(20), t(20)]);

    final db = migrated();
    expect(await GameRepository(db).findResumableGameId(), gameId);

    await db.close();
  });

  test('an old finished leg is still finished', () async {
    final gameId = await seedV2(
      darts: [d(20)],
      startScore: 40,
      winningSeat: 0,
    );

    final db = migrated();
    final repository = GameRepository(db);

    final game = await repository.loadGame(gameId);
    expect(game!.winnerPlayerId, isNotNull);

    final config = await repository.loadConfig(gameId);
    final leg = foldLeg(config!, await repository.loadLog(gameId));
    expect(leg.isFinished, isTrue);
    expect(leg.winnerId, config.playerIds[0]);

    expect(await repository.findResumableGameId(), isNull);

    await db.close();
  });

  test('a match can be played on top of migrated history', () async {
    final old = await seedV2(darts: [t(20), t(20), t(20)]);

    final db = migrated();
    final repository = GameRepository(db);

    final players = await repository.allPlayers();
    final config = MatchConfig(
      startScore: 501,
      playerIds: [for (final player in players) player.id],
      legsToPlay: 3,
    );
    final started = await repository.startMatch(config);

    // The new leg is bound to its match; the old one is untouched by it.
    final first = await repository.loadGame(started.gameId);
    expect(first!.matchId, started.matchId);
    expect(first.legNumber, 0);
    expect((await repository.loadGame(old))!.matchId, isNull);

    // And every stored leg is still readable, old and new alike.
    final legs = await repository.watchAllLegs().first;
    expect(legs, hasLength(2));

    await db.close();
  });
}
