import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/atc/atc_variant.dart';
import '../../domain/game_mode.dart';
import '../../domain/segment.dart';

part 'database.g.dart';

/// People who throw. A player persists across games so their history means
/// something.
class Players extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// A run of legs played to a best-of, won by whoever takes more than half.
///
/// The rules are repeated here rather than read off the first leg because they
/// are the format that was agreed before anyone threw: the match owns them, and
/// every leg it spawns inherits them.
// Named explicitly: drift would otherwise singularise `Matches` to `Matche`.
@DataClassName('Match')
class Matches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get startScore => integer()();
  BoolColumn get doubleOut =>
      boolean().withDefault(const Constant(true))();

  /// Best of this many legs. 1 is a single leg, which is what every game
  /// recorded before matches existed is.
  IntColumn get legsToPlay => integer()();

  /// Stored by name, like [DartEvents.ring] - see the note there. Every match
  /// recorded before this column existed was x01, which is also the default
  /// for a fresh insert until a second mode has a setup screen to choose from.
  TextColumn get gameMode =>
      textEnum<GameMode>().withDefault(const Constant('x01'))();

  DateTimeColumn get startedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  IntColumn get winnerPlayerId =>
      integer().nullable().references(Players, #id)();
}

/// One leg. A leg may belong to a match, or stand on its own.
///
/// [matchId] and [legNumber] are nullable because they have to be: every leg
/// stored before matches existed is a real leg with no match around it, and
/// nothing that reads legs - statistics, the resume offer, the fold - may start
/// depending on a match being there.
class Games extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Null for a leg played under a mode with no such thing - Around the
  /// Clock, today. x01 always writes a real value here.
  IntColumn get startScore => integer().nullable()();

  /// Null for the same reason as [startScore]: a mode with no double-out
  /// rule leaves this empty rather than writing a value that means nothing.
  BoolColumn get doubleOut =>
      boolean().nullable().withDefault(const Constant(true))();

  IntColumn get matchId =>
      integer().nullable().references(Matches, #id)();

  /// Position in the match, from zero. Null for a leg outside a match.
  ///
  /// This is also what pins who threw first: the starting seat is rebuilt from
  /// the leg number when the leg is replayed, so the alternation rule and this
  /// column have to stay in step.
  IntColumn get legNumber => integer().nullable()();

  /// Stored by name, like [DartEvents.ring]. See the note on
  /// [Matches.gameMode] - every leg recorded before this column existed was
  /// x01, which is also the default for a fresh insert today.
  TextColumn get gameMode =>
      textEnum<GameMode>().withDefault(const Constant('x01'))();

  DateTimeColumn get startedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  IntColumn get winnerPlayerId =>
      integer().nullable().references(Players, #id)();
}

/// Who sat where, in throwing order.
class GameSeats extends Table {
  IntColumn get gameId =>
      integer().references(Games, #id, onDelete: KeyAction.cascade)();
  IntColumn get playerId => integer().references(Players, #id)();
  IntColumn get seat => integer()();

  @override
  Set<Column<Object>> get primaryKey => {gameId, seat};
}

/// Every dart ever thrown.
///
/// Stored raw, in throwing order, with no scoring applied. Rules live in one
/// place - the fold - so a game is replayed through the same engine that scored
/// it live rather than having the rules restated in SQL. [value] is
/// denormalised only so that rule-free aggregates, like the accuracy heatmap,
/// stay a single query.
class DartEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameId =>
      integer().references(Games, #id, onDelete: KeyAction.cascade)();

  /// Position in the game's dart log, from zero.
  IntColumn get ordinal => integer()();

  IntColumn get playerId => integer().references(Players, #id)();

  /// Wedge number, 25 for a bull, or null for a miss.
  IntColumn get number => integer().nullable()();

  /// Stored by name, not index, so the enum can be reordered without
  /// reinterpreting existing history.
  TextColumn get ring => textEnum<Ring>().nullable()();

  IntColumn get value => integer()();

  DateTimeColumn get thrownAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {gameId, ordinal},
  ];
}

/// Around the Clock's own per-leg config: which variant it was played under.
///
/// A sibling to [Games] rather than columns on it, the same way [Matches]
/// stands beside [Games] for x01's own rules - x01's `startScore`/
/// `doubleOut` mean nothing here, and this mode's `variant` means nothing
/// there.
class AtcGames extends Table {
  IntColumn get gameId =>
      integer().references(Games, #id, onDelete: KeyAction.cascade)();
  TextColumn get variant => textEnum<AtcVariant>()();

  @override
  Set<Column<Object>> get primaryKey => {gameId};
}

@DriftDatabase(
  tables: [Players, Matches, Games, GameSeats, DartEvents, AtcGames],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'fluttergran'));

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.createTable(matches);
        // Added rather than backfilled: a leg thrown before matches existed
        // belongs to no match, and inventing one for it would invent a result
        // nobody played for.
        await m.addColumn(games, games.matchId);
        await m.addColumn(games, games.legNumber);
      }
      if (from < 4 && from >= 2) {
        // Calibration was a hardware-bring-up feature: verify the shipped
        // GranBoard 3s table against a real 132 and record any corrections.
        // Hardware day (2026-09-04) found zero - the table is correct as
        // shipped - so the table, its overrides, and the whole screen around
        // them are gone. A database that never reached schema 2 never had
        // this table to drop.
        await m.deleteTable('segment_calibrations');
      }
      if (from < 5) {
        // Backfilled to 'x01' by the column default, which is correct: every
        // leg and match ever recorded was x01, since it is the only mode
        // that has ever had an engine.
        await m.addColumn(games, games.gameMode);
        if (from >= 3) {
          // A database already at v3 or v4 has a `matches` table missing
          // this column. One migrating from below v3 gets `matches`
          // created fresh, just above, from the current table definition -
          // which already includes it - so adding it again here would be a
          // duplicate column.
          await m.addColumn(matches, matches.gameMode);
        }
      }
      if (from < 6) {
        // Widens startScore/doubleOut to nullable - Around the Clock has
        // neither - via a full recreate-and-copy: SQLite cannot loosen a
        // NOT NULL constraint in place. drift's TableMigration builds the
        // new table from `games`' current (now-nullable) definition, so
        // every pre-existing row is copied across unchanged; only rows
        // written from here on can actually hold nulls in these columns.
        await m.alterTable(TableMigration(games));
        await m.createTable(atcGames);
      }
    },
  );
}
