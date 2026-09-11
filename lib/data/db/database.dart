import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/atc/atc_variant.dart';
import '../../domain/bulling/bulling_variant.dart';
import '../../domain/game_mode.dart';
import '../../domain/segment.dart';
import '../../domain/x01/x01_rules.dart';

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

  /// Kept only as a frozen legacy mirror of [outRule] (`true` for
  /// `X01OutRule.double`), written on every insert so it never drifts out of
  /// step. Nothing but the schema-8 migration reads it back.
  BoolColumn get doubleOut =>
      boolean().withDefault(const Constant(true))();

  /// What it takes to open a leg. Stored by name, like [DartEvents.ring].
  TextColumn get inRule =>
      textEnum<X01InRule>().withDefault(const Constant('straight'))();

  /// What it takes to finish a leg.
  TextColumn get outRule =>
      textEnum<X01OutRule>().withDefault(const Constant('double'))();

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
  /// Kept only as a frozen legacy mirror of [outRule] - see the note on
  /// [Matches.doubleOut].
  BoolColumn get doubleOut =>
      boolean().nullable().withDefault(const Constant(true))();

  /// What it takes to open a leg. Null for a mode with no in-rule.
  TextColumn get inRule => textEnum<X01InRule>()
      .nullable()
      .withDefault(const Constant('straight'))();

  /// What it takes to finish a leg. Null for a mode with no out-rule.
  TextColumn get outRule => textEnum<X01OutRule>()
      .nullable()
      .withDefault(const Constant('double'))();

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

/// Bulling's own per-leg config: the bullseye value and the target score it
/// was played to.
///
/// A sibling to [Games], the same way [AtcGames] stands beside it for
/// Around the Clock's own rules — x01's `startScore`/`doubleOut` mean
/// nothing here, and this mode's `bullseyeValue`/`target` mean nothing
/// there.
class BullingGames extends Table {
  IntColumn get gameId =>
      integer().references(Games, #id, onDelete: KeyAction.cascade)();
  TextColumn get bullseyeValue => textEnum<BullseyeValue>()();
  IntColumn get target => integer()();

  @override
  Set<Column<Object>> get primaryKey => {gameId};
}

@DriftDatabase(
  tables: [Players, Matches, Games, GameSeats, DartEvents, AtcGames, BullingGames],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'fluttergran'));

  @override
  int get schemaVersion => 8;

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
        //
        // `inRule`/`outRule` are declared as [newColumns]: this step
        // predates them, so the on-disk table being copied from does not
        // have them yet either, and copying a column that is not there
        // would fail. Declaring them here just gives the rebuilt table their
        // column defaults instead - the schema-8 step below still runs its
        // own backfill on top for the cases the flat default gets wrong.
        await m.alterTable(
          TableMigration(games, newColumns: [games.inRule, games.outRule]),
        );
        await m.createTable(atcGames);
      }
      if (from < 7) {
        await m.createTable(bullingGames);
      }
      if (from < 8) {
        // Every match/leg recorded before this column existed was played
        // double-out - straight-in didn't exist as a concept, and neither
        // did master. The flat column defaults ('straight', 'double')
        // backfill every row correctly for the common case, the same way
        // `gameMode`'s default did at schema 5. That default is wrong for
        // two cases the flat backfill can't see: a row that was actually
        // straight-out (`double_out = 0`), and a non-x01 leg (`double_out`
        // null, meaning the in/out columns mean nothing there either) - both
        // corrected explicitly below.
        // A database migrating from below v3 gets `matches` created fresh at
        // the `from < 3` step above, from the current table definition -
        // which already includes these columns - so adding them again here
        // would be a duplicate column, the same guard `gameMode` needed
        // above. Likewise one migrating from below v6 already got `games`
        // rebuilt wholesale by that step's `TableMigration`, current
        // definition and all.
        if (from >= 3) {
          await m.addColumn(matches, matches.inRule);
          await m.addColumn(matches, matches.outRule);
        }
        if (from >= 6) {
          await m.addColumn(games, games.inRule);
          await m.addColumn(games, games.outRule);
        }

        await m.database.customStatement(
          "UPDATE matches SET out_rule = 'straight' WHERE double_out = 0",
        );
        await m.database.customStatement(
          "UPDATE games SET out_rule = 'straight' WHERE double_out = 0",
        );
        await m.database.customStatement(
          'UPDATE games SET in_rule = NULL, out_rule = NULL '
          'WHERE double_out IS NULL',
        );
      }
    },
  );
}
