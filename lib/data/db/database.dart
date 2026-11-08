/// The drift schema - players, matches, legs, seats, the dart log and each
/// mode's own config - and [AppDatabase] with its migrations.
///
/// {@category Data}
library;

import 'dart:io' show Platform;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

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
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
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
  BoolColumn get doubleOut => boolean().withDefault(const Constant(true))();

  /// What it takes to open a leg. Stored by name, like [DartEvents.ring].
  TextColumn get inRule =>
      textEnum<X01InRule>().withDefault(const Constant('straight'))();

  /// What it takes to finish a leg.
  TextColumn get outRule =>
      textEnum<X01OutRule>().withDefault(const Constant('double'))();

  /// Best of this many legs. 1 is a single leg.
  IntColumn get legsToPlay => integer()();

  /// Stored by name, like [DartEvents.ring] - see the note there. Defaults to
  /// x01, which also backfilled every row written before the column existed.
  TextColumn get gameMode =>
      textEnum<GameMode>().withDefault(const Constant('x01'))();

  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  IntColumn get winnerPlayerId =>
      integer().nullable().references(Players, #id)();
}

/// One leg. A leg may belong to a match, or stand on its own.
///
/// [matchId] and [legNumber] are null for a leg with no match around it, and
/// nothing that reads legs - statistics, the resume offer, the fold - may
/// depend on a match being there.
class Games extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Null for a leg played under a mode with no start score - every mode but
  /// x01, which always writes a real value here.
  IntColumn get startScore => integer().nullable()();

  /// Null for every mode but x01. Kept only as a frozen legacy mirror of
  /// [outRule] - see [Matches.doubleOut].
  BoolColumn get doubleOut =>
      boolean().nullable().withDefault(const Constant(true))();

  /// What it takes to open a leg. Null for a mode with no in-rule.
  TextColumn get inRule => textEnum<X01InRule>().nullable().withDefault(
    const Constant('straight'),
  )();

  /// What it takes to finish a leg. Null for a mode with no out-rule.
  TextColumn get outRule =>
      textEnum<X01OutRule>().nullable().withDefault(const Constant('double'))();

  IntColumn get matchId => integer().nullable().references(Matches, #id)();

  /// Position in the match, from zero. Null for a leg outside a match.
  ///
  /// This is also what pins who threw first: the starting seat is rebuilt from
  /// the leg number when the leg is replayed, so the alternation rule and this
  /// column have to stay in step.
  IntColumn get legNumber => integer().nullable()();

  /// Stored by name, like [DartEvents.ring]. See [Matches.gameMode].
  TextColumn get gameMode =>
      textEnum<GameMode>().withDefault(const Constant('x01'))();

  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
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

  DateTimeColumn get thrownAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {gameId, ordinal},
  ];
}

/// Around the Clock's own per-leg config: which variant it was played under.
///
/// A sibling to [Games] rather than columns on it: x01's start score and
/// rules mean nothing here, and this mode's `variant` means nothing there.
/// [BullingGames] is the same arrangement for Bulling.
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
/// A sibling to [Games] for the same reason as [AtcGames].
class BullingGames extends Table {
  IntColumn get gameId =>
      integer().references(Games, #id, onDelete: KeyAction.cascade)();
  TextColumn get bullseyeValue => textEnum<BullseyeValue>()();
  IntColumn get target => integer()();

  @override
  Set<Column<Object>> get primaryKey => {gameId};
}

@DriftDatabase(
  tables: [
    Players,
    Matches,
    Games,
    GameSeats,
    DartEvents,
    AtcGames,
    BullingGames,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'fluttergran',
              native: Platform.isWindows ? _windowsStorage : null,
            ),
      );

  /// drift's default home for the file is the documents directory, which on
  /// Android is private to the app and on Windows is the user's own Documents
  /// folder - visible, often synced to OneDrive, and no place for a database
  /// that is open while the app runs. %APPDATA% is where a Windows app keeps
  /// its state. Android stays where it always was: moving it would orphan
  /// every dart already thrown.
  static const _windowsStorage = DriftNativeOptions(
    databaseDirectory: getApplicationSupportDirectory,
  );

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.createTable(matches);
        // Added rather than backfilled: an existing leg belongs to no match,
        // and inventing one for it would invent a result nobody played for.
        await m.addColumn(games, games.matchId);
        await m.addColumn(games, games.legNumber);
      }
      if (from < 4 && from >= 2) {
        // Segment calibration was removed; only v2 and v3 had its table.
        await m.deleteTable('segment_calibrations');
      }
      if (from < 5) {
        // Backfilled to 'x01' by the column default, which is correct: x01
        // was the only mode at schema 5.
        await m.addColumn(games, games.gameMode);
        if (from >= 3) {
          // Below v3, `matches` was just created from the current
          // definition and already has the column.
          await m.addColumn(matches, matches.gameMode);
        }
      }
      if (from < 6) {
        // Widens startScore/doubleOut to nullable for non-x01 modes. SQLite
        // cannot loosen NOT NULL in place, so TableMigration rebuilds
        // `games` from its current definition and copies every row across.
        //
        // TableMigration copies every column the current table has, so any
        // column added after schema 6 must be listed in `newColumns`, or
        // this step fails copying a column the old table lacks. The rebuilt
        // table gives those columns their defaults; the schema-8 step below
        // corrects inRule/outRule.
        await m.alterTable(
          TableMigration(games, newColumns: [games.inRule, games.outRule]),
        );
        await m.createTable(atcGames);
      }
      if (from < 7) {
        await m.createTable(bullingGames);
      }
      if (from < 8) {
        // Splits the old double-out flag into inRule/outRule. Every older
        // row was straight-in, so the column defaults ('straight',
        // 'double') are right except for straight-out rows
        // (`double_out = 0`) and non-x01 legs (`double_out` null, so no
        // rules at all), both corrected below.
        //
        // Tables created or rebuilt from the current definition by an
        // earlier step (`matches` below v3, `games` below v6) already have
        // the columns, and adding them again would fail.
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
