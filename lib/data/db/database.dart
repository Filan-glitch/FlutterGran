import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

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

/// One leg. The MVP plays a single leg per game.
class Games extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get startScore => integer()();
  BoolColumn get doubleOut =>
      boolean().withDefault(const Constant(true))();
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

@DriftDatabase(tables: [Players, Games, GameSeats, DartEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'fluttergran'));

  @override
  int get schemaVersion => 1;
}
