import 'package:drift/drift.dart';

import '../../domain/segment.dart';
import '../../domain/x01/game_config.dart';
import '../../domain/x01/thrown_dart.dart';
import 'database.dart';

/// Reads and writes games, players, and the dart log.
///
/// Nothing here scores anything. The log is stored exactly as thrown and
/// replayed through [foldLeg] when a game is loaded, so there is one
/// implementation of the rules rather than one in Dart and another in SQL.
class GameRepository {
  GameRepository(this.db);

  final AppDatabase db;

  // Players

  Stream<List<Player>> watchPlayers() =>
      (db.select(db.players)..orderBy([(p) => OrderingTerm(expression: p.name)]))
          .watch();

  Future<List<Player>> allPlayers() =>
      (db.select(db.players)
            ..orderBy([(p) => OrderingTerm(expression: p.name)]))
          .get();

  Future<Player> addPlayer(String name) => db
      .into(db.players)
      .insertReturning(PlayersCompanion.insert(name: name.trim()));

  Future<void> removePlayer(int playerId) =>
      (db.delete(db.players)..where((p) => p.id.equals(playerId))).go();

  // Games

  /// Creates a game and seats its players in throwing order.
  Future<int> startGame(GameConfig config) async {
    return db.transaction(() async {
      final gameId = await db
          .into(db.games)
          .insert(
            GamesCompanion.insert(
              startScore: config.startScore,
              doubleOut: Value(config.doubleOut),
            ),
          );

      for (var seat = 0; seat < config.playerIds.length; seat++) {
        await db
            .into(db.gameSeats)
            .insert(
              GameSeatsCompanion.insert(
                gameId: gameId,
                playerId: config.playerIds[seat],
                seat: seat,
              ),
            );
      }
      return gameId;
    });
  }

  Future<void> finishGame(int gameId, int winnerPlayerId) =>
      (db.update(db.games)..where((g) => g.id.equals(gameId))).write(
        GamesCompanion(
          winnerPlayerId: Value(winnerPlayerId),
          finishedAt: Value(DateTime.now()),
        ),
      );

  /// Clears a result, for when a finished leg is undone back into play.
  Future<void> reopenGame(int gameId) =>
      (db.update(db.games)..where((g) => g.id.equals(gameId))).write(
        const GamesCompanion(
          winnerPlayerId: Value(null),
          finishedAt: Value(null),
        ),
      );

  Future<void> deleteGame(int gameId) =>
      (db.delete(db.games)..where((g) => g.id.equals(gameId))).go();

  /// Games that were abandoned before anyone won.
  Future<void> deleteEmptyGames() async {
    final counts = db.dartEvents.gameId.count();
    final played = await (db.selectOnly(db.dartEvents)
          ..addColumns([db.dartEvents.gameId, counts])
          ..groupBy([db.dartEvents.gameId]))
        .get();
    final withDarts = played
        .map((row) => row.read(db.dartEvents.gameId))
        .whereType<int>()
        .toSet();

    await (db.delete(db.games)
          ..where((g) => g.id.isNotIn(withDarts) & g.finishedAt.isNull()))
        .go();
  }

  // Darts

  Future<void> appendDart({
    required int gameId,
    required int ordinal,
    required int playerId,
    required ThrownDart dart,
  }) => db
      .into(db.dartEvents)
      .insert(
        DartEventsCompanion.insert(
          gameId: gameId,
          ordinal: ordinal,
          playerId: playerId,
          number: Value(dart.segment?.number),
          ring: Value(dart.segment?.ring),
          value: dart.value,
        ),
      );

  /// Drops every dart at or after [ordinal]. Undo rewinds the log rather than
  /// recording a correction, so history stays a plain list of what was thrown.
  Future<void> truncateLog(int gameId, int ordinal) =>
      (db.delete(db.dartEvents)
            ..where((d) => d.gameId.equals(gameId) & d.ordinal.isBiggerOrEqualValue(ordinal)))
          .go();

  Future<List<ThrownDart>> loadLog(int gameId) async {
    final rows =
        await (db.select(db.dartEvents)
              ..where((d) => d.gameId.equals(gameId))
              ..orderBy([(d) => OrderingTerm(expression: d.ordinal)]))
            .get();

    return [
      for (final row in rows)
        if (row.number == null || row.ring == null)
          const ThrownDart.miss()
        else
          ThrownDart(Segment(row.number!, row.ring!)),
    ];
  }

  /// Rebuilds the configuration a game was played under.
  Future<GameConfig?> loadConfig(int gameId) async {
    final game = await (db.select(db.games)
          ..where((g) => g.id.equals(gameId)))
        .getSingleOrNull();
    if (game == null) return null;

    final seats =
        await (db.select(db.gameSeats)
              ..where((s) => s.gameId.equals(gameId))
              ..orderBy([(s) => OrderingTerm(expression: s.seat)]))
            .get();

    return GameConfig(
      startScore: game.startScore,
      playerIds: [for (final seat in seats) seat.playerId],
      doubleOut: game.doubleOut,
    );
  }
}
