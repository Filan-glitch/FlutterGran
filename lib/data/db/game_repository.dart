import 'package:drift/drift.dart';

import '../../domain/segment.dart';
import '../../domain/x01/game_config.dart';
import '../../domain/x01/leg_reducer.dart';
import '../../domain/x01/leg_state.dart';
import '../../domain/x01/match_state.dart';
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

  /// Creates a leg and seats its players in throwing order.
  ///
  /// [matchId] and [legNumber] are left off for a leg played on its own, which
  /// is every leg the app recorded before matches existed.
  Future<int> startGame(
    GameConfig config, {
    int? matchId,
    int? legNumber,
  }) async {
    return db.transaction(() async {
      final gameId = await db
          .into(db.games)
          .insert(
            GamesCompanion.insert(
              startScore: config.startScore,
              doubleOut: Value(config.doubleOut),
              matchId: Value(matchId),
              legNumber: Value(legNumber),
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

  // Matches

  /// Opens a match and throws its first leg.
  ///
  /// The two go together on purpose: a match with no leg under it has no
  /// seating, and so nothing could be read back off it.
  Future<({int matchId, int gameId})> startMatch(MatchConfig config) async {
    return db.transaction(() async {
      final matchId = await db
          .into(db.matches)
          .insert(
            MatchesCompanion.insert(
              startScore: config.startScore,
              doubleOut: Value(config.doubleOut),
              legsToPlay: config.legsToPlay,
            ),
          );
      final gameId = await startNextLeg(matchId: matchId, config: config, legNumber: 0);
      return (matchId: matchId, gameId: gameId);
    });
  }

  /// Throws leg [legNumber] of a match, with the lead rotated into place.
  Future<int> startNextLeg({
    required int matchId,
    required MatchConfig config,
    required int legNumber,
  }) => startGame(
    config.legConfig(legNumber),
    matchId: matchId,
    legNumber: legNumber,
  );

  Future<void> finishMatch(int matchId, int winnerPlayerId) =>
      (db.update(db.matches)..where((m) => m.id.equals(matchId))).write(
        MatchesCompanion(
          winnerPlayerId: Value(winnerPlayerId),
          finishedAt: Value(DateTime.now()),
        ),
      );

  /// Clears a result, for when the checkout that won the match is undone.
  Future<void> reopenMatch(int matchId) =>
      (db.update(db.matches)..where((m) => m.id.equals(matchId))).write(
        const MatchesCompanion(
          winnerPlayerId: Value(null),
          finishedAt: Value(null),
        ),
      );

  /// Rebuilds the format a match is being played to.
  ///
  /// Seating comes from the first leg rather than the match: everyone plays
  /// every leg in the same order, so storing it twice would only give it a
  /// chance to disagree with itself.
  Future<MatchConfig?> loadMatchConfig(int matchId) async {
    final match = await (db.select(db.matches)
          ..where((m) => m.id.equals(matchId)))
        .getSingleOrNull();
    if (match == null) return null;

    final first =
        await (db.select(db.games)
              ..where((g) => g.matchId.equals(matchId))
              ..orderBy([(g) => OrderingTerm(expression: g.legNumber)])
              ..limit(1))
            .getSingleOrNull();
    if (first == null) return null;

    final seats = await _seatsOf(first.id);
    if (seats.isEmpty) return null;

    return MatchConfig(
      startScore: match.startScore,
      playerIds: seats,
      doubleOut: match.doubleOut,
      legsToPlay: match.legsToPlay,
    );
  }

  /// A match's legs, replayed, in the order they were thrown.
  ///
  /// [beforeLegNumber] takes only the legs already decided by the time a given
  /// leg started, which is what resuming mid-match needs.
  Future<List<LegState>> loadMatchLegs(
    int matchId, {
    int? beforeLegNumber,
  }) async {
    final query = db.select(db.games)
      ..where((g) => g.matchId.equals(matchId))
      ..orderBy([(g) => OrderingTerm(expression: g.legNumber)]);
    if (beforeLegNumber != null) {
      query.where((g) => g.legNumber.isSmallerThanValue(beforeLegNumber));
    }

    final legs = <LegState>[];
    for (final game in await query.get()) {
      final config = await loadConfig(game.id);
      if (config == null || config.playerIds.isEmpty) continue;
      legs.add(foldLeg(config, await loadLog(game.id)));
    }
    return legs;
  }

  /// Every match, folded from its legs.
  ///
  /// Joined to games rather than read from the matches table alone so that a
  /// leg being won re-emits the tally: a stream over `select(matches)` is only
  /// invalidated by writes to matches, and a match in progress never touches
  /// its own row.
  Stream<List<MatchState>> watchAllMatches() =>
      (db.select(db.matches).join([
            innerJoin(
              db.games,
              db.games.matchId.equalsExp(db.matches.id),
              useColumns: false,
            ),
          ])
            ..groupBy([db.matches.id]))
          .watch()
          .asyncMap((rows) async {
            final states = <MatchState>[];
            for (final row in rows) {
              final id = row.readTable(db.matches).id;
              final config = await loadMatchConfig(id);
              if (config == null) continue;
              states.add(foldMatch(config, await legWinners(id)));
            }
            return states;
          });

  /// Winners of a match's decided legs, oldest first.
  Future<List<int>> legWinners(int matchId, {int? beforeLegNumber}) async {
    final legs = await loadMatchLegs(
      matchId,
      beforeLegNumber: beforeLegNumber,
    );
    return [for (final leg in legs) ?leg.winnerId];
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

  /// The most recent leg that was started, thrown at, and never finished.
  ///
  /// Darts already having been thrown is what separates a leg worth offering to
  /// resume from one abandoned at the setup screen.
  JoinedSelectStatement<HasResultSet, dynamic> _resumableQuery() {
    return db.select(db.games).join([
      innerJoin(
        db.dartEvents,
        db.dartEvents.gameId.equalsExp(db.games.id),
        useColumns: false,
      ),
    ])
      ..where(db.games.finishedAt.isNull())
      ..groupBy([db.games.id])
      // Id breaks the tie: startedAt has second resolution, so two legs begun
      // in the same second would otherwise come back in an arbitrary order.
      ..orderBy([
        OrderingTerm.desc(db.games.startedAt),
        OrderingTerm.desc(db.games.id),
      ])
      ..limit(1);
  }

  /// The leg to offer, or null when there is nothing to pick up.
  Future<int?> findResumableGameId() async =>
      (await _resumableQuery().getSingleOrNull())?.readTable(db.games).id;

  /// The same answer, kept current.
  ///
  /// Watching the join rather than the games table is what makes this react to
  /// a dart being thrown: a stream built from `select(games)` alone is only
  /// invalidated by writes to games, so it would never notice the first dart
  /// turning a leg into one worth resuming.
  Stream<int?> watchResumableGameId() => _resumableQuery()
      .watch()
      .map((rows) => rows.singleOrNull?.readTable(db.games).id);

  /// Every stored game, replayed into leg state.
  ///
  /// Emits again whenever a game changes, so statistics refresh themselves
  /// after a leg finishes.
  Stream<List<LegState>> watchAllLegs() =>
      db.select(db.games).watch().asyncMap((games) async {
        final legs = <LegState>[];
        for (final game in games) {
          final config = await loadConfig(game.id);
          if (config == null || config.playerIds.isEmpty) continue;
          legs.add(foldLeg(config, await loadLog(game.id)));
        }
        return legs;
      });

  /// How many darts a player has landed in each segment.
  ///
  /// The one statistic that is genuinely a SQL aggregate: where a dart landed
  /// does not depend on any rule, so it needs no replay.
  Future<Map<Segment, int>> segmentCounts(int playerId) async {
    final hits = db.dartEvents.id.count();
    final rows =
        await (db.selectOnly(db.dartEvents)
              ..addColumns([db.dartEvents.number, db.dartEvents.ring, hits])
              ..where(
                db.dartEvents.playerId.equals(playerId) &
                    db.dartEvents.number.isNotNull() &
                    db.dartEvents.ring.isNotNull(),
              )
              ..groupBy([db.dartEvents.number, db.dartEvents.ring]))
            .get();

    return {
      for (final row in rows)
        if (row.read(db.dartEvents.number) case final number?)
          if (row.readWithConverter(db.dartEvents.ring) case final ring?)
            Segment(number, ring): row.read(hits) ?? 0,
    };
  }

  // Calibration

  /// Every frame code that has been verified against real hardware.
  Stream<List<SegmentCalibration>> watchCalibrations() =>
      db.select(db.segmentCalibrations).watch();

  Future<List<SegmentCalibration>> allCalibrations() =>
      db.select(db.segmentCalibrations).get();

  /// Records what [body] really means on this board.
  ///
  /// [corrected] marks a code whose meaning differs from the shipped table,
  /// which is what turns this row into a decoding override.
  Future<void> recordCalibration({
    required String body,
    required Segment segment,
    required bool corrected,
  }) => db
      .into(db.segmentCalibrations)
      .insertOnConflictUpdate(
        SegmentCalibrationsCompanion.insert(
          body: body,
          number: segment.number,
          ring: segment.ring,
          corrected: Value(corrected),
        ),
      );

  Future<void> clearCalibration(String body) =>
      (db.delete(db.segmentCalibrations)..where((c) => c.body.equals(body)))
          .go();

  Future<void> clearAllCalibrations() =>
      db.delete(db.segmentCalibrations).go();

  /// Rebuilds the configuration a game was played under.
  Future<GameConfig?> loadConfig(int gameId) async {
    final game = await loadGame(gameId);
    if (game == null) return null;

    final seats = await _seatsOf(gameId);

    return GameConfig(
      startScore: game.startScore,
      playerIds: seats,
      doubleOut: game.doubleOut,
      // Who threw first is not stored: it follows from the leg's position in
      // its match, and a leg outside a match always opens on the first seat.
      startingSeat: game.legNumber == null || seats.isEmpty
          ? 0
          : startingSeatForLeg(game.legNumber!, seats.length),
    );
  }

  Future<Game?> loadGame(int gameId) =>
      (db.select(db.games)..where((g) => g.id.equals(gameId)))
          .getSingleOrNull();

  /// Player ids of a game, in throwing order.
  Future<List<int>> _seatsOf(int gameId) async {
    final rows =
        await (db.select(db.gameSeats)
              ..where((s) => s.gameId.equals(gameId))
              ..orderBy([(s) => OrderingTerm(expression: s.seat)]))
            .get();
    return [for (final row in rows) row.playerId];
  }
}
