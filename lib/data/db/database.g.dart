// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PlayersTable extends Players with TableInfo<$PlayersTable, Player> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(
    Insertable<Player> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Player map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Player(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }
}

class Player extends DataClass implements Insertable<Player> {
  final int id;
  final String name;
  final DateTime createdAt;
  const Player({required this.id, required this.name, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Player.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Player(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Player copyWith({int? id, String? name, DateTime? createdAt}) => Player(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  Player copyWithCompanion(PlayersCompanion data) {
    return Player(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Player(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Player &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class PlayersCompanion extends UpdateCompanion<Player> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const PlayersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PlayersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Player> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PlayersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return PlayersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GamesTable extends Games with TableInfo<$GamesTable, Game> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startScoreMeta = const VerificationMeta(
    'startScore',
  );
  @override
  late final GeneratedColumn<int> startScore = GeneratedColumn<int>(
    'start_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doubleOutMeta = const VerificationMeta(
    'doubleOut',
  );
  @override
  late final GeneratedColumn<bool> doubleOut = GeneratedColumn<bool>(
    'double_out',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("double_out" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _winnerPlayerIdMeta = const VerificationMeta(
    'winnerPlayerId',
  );
  @override
  late final GeneratedColumn<int> winnerPlayerId = GeneratedColumn<int>(
    'winner_player_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startScore,
    doubleOut,
    startedAt,
    finishedAt,
    winnerPlayerId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(
    Insertable<Game> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_score')) {
      context.handle(
        _startScoreMeta,
        startScore.isAcceptableOrUnknown(data['start_score']!, _startScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_startScoreMeta);
    }
    if (data.containsKey('double_out')) {
      context.handle(
        _doubleOutMeta,
        doubleOut.isAcceptableOrUnknown(data['double_out']!, _doubleOutMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('winner_player_id')) {
      context.handle(
        _winnerPlayerIdMeta,
        winnerPlayerId.isAcceptableOrUnknown(
          data['winner_player_id']!,
          _winnerPlayerIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Game map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Game(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_score'],
      )!,
      doubleOut: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}double_out'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      winnerPlayerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}winner_player_id'],
      ),
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }
}

class Game extends DataClass implements Insertable<Game> {
  final int id;
  final int startScore;
  final bool doubleOut;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int? winnerPlayerId;
  const Game({
    required this.id,
    required this.startScore,
    required this.doubleOut,
    required this.startedAt,
    this.finishedAt,
    this.winnerPlayerId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_score'] = Variable<int>(startScore);
    map['double_out'] = Variable<bool>(doubleOut);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || winnerPlayerId != null) {
      map['winner_player_id'] = Variable<int>(winnerPlayerId);
    }
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      startScore: Value(startScore),
      doubleOut: Value(doubleOut),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      winnerPlayerId: winnerPlayerId == null && nullToAbsent
          ? const Value.absent()
          : Value(winnerPlayerId),
    );
  }

  factory Game.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Game(
      id: serializer.fromJson<int>(json['id']),
      startScore: serializer.fromJson<int>(json['startScore']),
      doubleOut: serializer.fromJson<bool>(json['doubleOut']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      winnerPlayerId: serializer.fromJson<int?>(json['winnerPlayerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startScore': serializer.toJson<int>(startScore),
      'doubleOut': serializer.toJson<bool>(doubleOut),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'winnerPlayerId': serializer.toJson<int?>(winnerPlayerId),
    };
  }

  Game copyWith({
    int? id,
    int? startScore,
    bool? doubleOut,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    Value<int?> winnerPlayerId = const Value.absent(),
  }) => Game(
    id: id ?? this.id,
    startScore: startScore ?? this.startScore,
    doubleOut: doubleOut ?? this.doubleOut,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    winnerPlayerId: winnerPlayerId.present
        ? winnerPlayerId.value
        : this.winnerPlayerId,
  );
  Game copyWithCompanion(GamesCompanion data) {
    return Game(
      id: data.id.present ? data.id.value : this.id,
      startScore: data.startScore.present
          ? data.startScore.value
          : this.startScore,
      doubleOut: data.doubleOut.present ? data.doubleOut.value : this.doubleOut,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      winnerPlayerId: data.winnerPlayerId.present
          ? data.winnerPlayerId.value
          : this.winnerPlayerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Game(')
          ..write('id: $id, ')
          ..write('startScore: $startScore, ')
          ..write('doubleOut: $doubleOut, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('winnerPlayerId: $winnerPlayerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startScore,
    doubleOut,
    startedAt,
    finishedAt,
    winnerPlayerId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Game &&
          other.id == this.id &&
          other.startScore == this.startScore &&
          other.doubleOut == this.doubleOut &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.winnerPlayerId == this.winnerPlayerId);
}

class GamesCompanion extends UpdateCompanion<Game> {
  final Value<int> id;
  final Value<int> startScore;
  final Value<bool> doubleOut;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<int?> winnerPlayerId;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.startScore = const Value.absent(),
    this.doubleOut = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.winnerPlayerId = const Value.absent(),
  });
  GamesCompanion.insert({
    this.id = const Value.absent(),
    required int startScore,
    this.doubleOut = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.winnerPlayerId = const Value.absent(),
  }) : startScore = Value(startScore);
  static Insertable<Game> custom({
    Expression<int>? id,
    Expression<int>? startScore,
    Expression<bool>? doubleOut,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? winnerPlayerId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startScore != null) 'start_score': startScore,
      if (doubleOut != null) 'double_out': doubleOut,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (winnerPlayerId != null) 'winner_player_id': winnerPlayerId,
    });
  }

  GamesCompanion copyWith({
    Value<int>? id,
    Value<int>? startScore,
    Value<bool>? doubleOut,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<int?>? winnerPlayerId,
  }) {
    return GamesCompanion(
      id: id ?? this.id,
      startScore: startScore ?? this.startScore,
      doubleOut: doubleOut ?? this.doubleOut,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      winnerPlayerId: winnerPlayerId ?? this.winnerPlayerId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startScore.present) {
      map['start_score'] = Variable<int>(startScore.value);
    }
    if (doubleOut.present) {
      map['double_out'] = Variable<bool>(doubleOut.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (winnerPlayerId.present) {
      map['winner_player_id'] = Variable<int>(winnerPlayerId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('startScore: $startScore, ')
          ..write('doubleOut: $doubleOut, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('winnerPlayerId: $winnerPlayerId')
          ..write(')'))
        .toString();
  }
}

class $GameSeatsTable extends GameSeats
    with TableInfo<$GameSeatsTable, GameSeat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameSeatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _seatMeta = const VerificationMeta('seat');
  @override
  late final GeneratedColumn<int> seat = GeneratedColumn<int>(
    'seat',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, playerId, seat];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_seats';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameSeat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('seat')) {
      context.handle(
        _seatMeta,
        seat.isAcceptableOrUnknown(data['seat']!, _seatMeta),
      );
    } else if (isInserting) {
      context.missing(_seatMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, seat};
  @override
  GameSeat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameSeat(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_id'],
      )!,
      seat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seat'],
      )!,
    );
  }

  @override
  $GameSeatsTable createAlias(String alias) {
    return $GameSeatsTable(attachedDatabase, alias);
  }
}

class GameSeat extends DataClass implements Insertable<GameSeat> {
  final int gameId;
  final int playerId;
  final int seat;
  const GameSeat({
    required this.gameId,
    required this.playerId,
    required this.seat,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<int>(gameId);
    map['player_id'] = Variable<int>(playerId);
    map['seat'] = Variable<int>(seat);
    return map;
  }

  GameSeatsCompanion toCompanion(bool nullToAbsent) {
    return GameSeatsCompanion(
      gameId: Value(gameId),
      playerId: Value(playerId),
      seat: Value(seat),
    );
  }

  factory GameSeat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameSeat(
      gameId: serializer.fromJson<int>(json['gameId']),
      playerId: serializer.fromJson<int>(json['playerId']),
      seat: serializer.fromJson<int>(json['seat']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<int>(gameId),
      'playerId': serializer.toJson<int>(playerId),
      'seat': serializer.toJson<int>(seat),
    };
  }

  GameSeat copyWith({int? gameId, int? playerId, int? seat}) => GameSeat(
    gameId: gameId ?? this.gameId,
    playerId: playerId ?? this.playerId,
    seat: seat ?? this.seat,
  );
  GameSeat copyWithCompanion(GameSeatsCompanion data) {
    return GameSeat(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      seat: data.seat.present ? data.seat.value : this.seat,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameSeat(')
          ..write('gameId: $gameId, ')
          ..write('playerId: $playerId, ')
          ..write('seat: $seat')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, playerId, seat);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameSeat &&
          other.gameId == this.gameId &&
          other.playerId == this.playerId &&
          other.seat == this.seat);
}

class GameSeatsCompanion extends UpdateCompanion<GameSeat> {
  final Value<int> gameId;
  final Value<int> playerId;
  final Value<int> seat;
  final Value<int> rowid;
  const GameSeatsCompanion({
    this.gameId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.seat = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameSeatsCompanion.insert({
    required int gameId,
    required int playerId,
    required int seat,
    this.rowid = const Value.absent(),
  }) : gameId = Value(gameId),
       playerId = Value(playerId),
       seat = Value(seat);
  static Insertable<GameSeat> custom({
    Expression<int>? gameId,
    Expression<int>? playerId,
    Expression<int>? seat,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (playerId != null) 'player_id': playerId,
      if (seat != null) 'seat': seat,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameSeatsCompanion copyWith({
    Value<int>? gameId,
    Value<int>? playerId,
    Value<int>? seat,
    Value<int>? rowid,
  }) {
    return GameSeatsCompanion(
      gameId: gameId ?? this.gameId,
      playerId: playerId ?? this.playerId,
      seat: seat ?? this.seat,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (seat.present) {
      map['seat'] = Variable<int>(seat.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameSeatsCompanion(')
          ..write('gameId: $gameId, ')
          ..write('playerId: $playerId, ')
          ..write('seat: $seat, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DartEventsTable extends DartEvents
    with TableInfo<$DartEventsTable, DartEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DartEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Ring?, String> ring =
      GeneratedColumn<String>(
        'ring',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Ring?>($DartEventsTable.$converterringn);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thrownAtMeta = const VerificationMeta(
    'thrownAt',
  );
  @override
  late final GeneratedColumn<DateTime> thrownAt = GeneratedColumn<DateTime>(
    'thrown_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    ordinal,
    playerId,
    number,
    ring,
    value,
    thrownAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dart_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<DartEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('thrown_at')) {
      context.handle(
        _thrownAtMeta,
        thrownAt.isAcceptableOrUnknown(data['thrown_at']!, _thrownAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {gameId, ordinal},
  ];
  @override
  DartEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DartEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      ),
      ring: $DartEventsTable.$converterringn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}ring'],
        ),
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
      thrownAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}thrown_at'],
      )!,
    );
  }

  @override
  $DartEventsTable createAlias(String alias) {
    return $DartEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Ring, String, String> $converterring =
      const EnumNameConverter<Ring>(Ring.values);
  static JsonTypeConverter2<Ring?, String?, String?> $converterringn =
      JsonTypeConverter2.asNullable($converterring);
}

class DartEvent extends DataClass implements Insertable<DartEvent> {
  final int id;
  final int gameId;

  /// Position in the game's dart log, from zero.
  final int ordinal;
  final int playerId;

  /// Wedge number, 25 for a bull, or null for a miss.
  final int? number;

  /// Stored by name, not index, so the enum can be reordered without
  /// reinterpreting existing history.
  final Ring? ring;
  final int value;
  final DateTime thrownAt;
  const DartEvent({
    required this.id,
    required this.gameId,
    required this.ordinal,
    required this.playerId,
    this.number,
    this.ring,
    required this.value,
    required this.thrownAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_id'] = Variable<int>(gameId);
    map['ordinal'] = Variable<int>(ordinal);
    map['player_id'] = Variable<int>(playerId);
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<int>(number);
    }
    if (!nullToAbsent || ring != null) {
      map['ring'] = Variable<String>(
        $DartEventsTable.$converterringn.toSql(ring),
      );
    }
    map['value'] = Variable<int>(value);
    map['thrown_at'] = Variable<DateTime>(thrownAt);
    return map;
  }

  DartEventsCompanion toCompanion(bool nullToAbsent) {
    return DartEventsCompanion(
      id: Value(id),
      gameId: Value(gameId),
      ordinal: Value(ordinal),
      playerId: Value(playerId),
      number: number == null && nullToAbsent
          ? const Value.absent()
          : Value(number),
      ring: ring == null && nullToAbsent ? const Value.absent() : Value(ring),
      value: Value(value),
      thrownAt: Value(thrownAt),
    );
  }

  factory DartEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DartEvent(
      id: serializer.fromJson<int>(json['id']),
      gameId: serializer.fromJson<int>(json['gameId']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
      playerId: serializer.fromJson<int>(json['playerId']),
      number: serializer.fromJson<int?>(json['number']),
      ring: $DartEventsTable.$converterringn.fromJson(
        serializer.fromJson<String?>(json['ring']),
      ),
      value: serializer.fromJson<int>(json['value']),
      thrownAt: serializer.fromJson<DateTime>(json['thrownAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameId': serializer.toJson<int>(gameId),
      'ordinal': serializer.toJson<int>(ordinal),
      'playerId': serializer.toJson<int>(playerId),
      'number': serializer.toJson<int?>(number),
      'ring': serializer.toJson<String?>(
        $DartEventsTable.$converterringn.toJson(ring),
      ),
      'value': serializer.toJson<int>(value),
      'thrownAt': serializer.toJson<DateTime>(thrownAt),
    };
  }

  DartEvent copyWith({
    int? id,
    int? gameId,
    int? ordinal,
    int? playerId,
    Value<int?> number = const Value.absent(),
    Value<Ring?> ring = const Value.absent(),
    int? value,
    DateTime? thrownAt,
  }) => DartEvent(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    ordinal: ordinal ?? this.ordinal,
    playerId: playerId ?? this.playerId,
    number: number.present ? number.value : this.number,
    ring: ring.present ? ring.value : this.ring,
    value: value ?? this.value,
    thrownAt: thrownAt ?? this.thrownAt,
  );
  DartEvent copyWithCompanion(DartEventsCompanion data) {
    return DartEvent(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      number: data.number.present ? data.number.value : this.number,
      ring: data.ring.present ? data.ring.value : this.ring,
      value: data.value.present ? data.value.value : this.value,
      thrownAt: data.thrownAt.present ? data.thrownAt.value : this.thrownAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DartEvent(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('ordinal: $ordinal, ')
          ..write('playerId: $playerId, ')
          ..write('number: $number, ')
          ..write('ring: $ring, ')
          ..write('value: $value, ')
          ..write('thrownAt: $thrownAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, gameId, ordinal, playerId, number, ring, value, thrownAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DartEvent &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.ordinal == this.ordinal &&
          other.playerId == this.playerId &&
          other.number == this.number &&
          other.ring == this.ring &&
          other.value == this.value &&
          other.thrownAt == this.thrownAt);
}

class DartEventsCompanion extends UpdateCompanion<DartEvent> {
  final Value<int> id;
  final Value<int> gameId;
  final Value<int> ordinal;
  final Value<int> playerId;
  final Value<int?> number;
  final Value<Ring?> ring;
  final Value<int> value;
  final Value<DateTime> thrownAt;
  const DartEventsCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.playerId = const Value.absent(),
    this.number = const Value.absent(),
    this.ring = const Value.absent(),
    this.value = const Value.absent(),
    this.thrownAt = const Value.absent(),
  });
  DartEventsCompanion.insert({
    this.id = const Value.absent(),
    required int gameId,
    required int ordinal,
    required int playerId,
    this.number = const Value.absent(),
    this.ring = const Value.absent(),
    required int value,
    this.thrownAt = const Value.absent(),
  }) : gameId = Value(gameId),
       ordinal = Value(ordinal),
       playerId = Value(playerId),
       value = Value(value);
  static Insertable<DartEvent> custom({
    Expression<int>? id,
    Expression<int>? gameId,
    Expression<int>? ordinal,
    Expression<int>? playerId,
    Expression<int>? number,
    Expression<String>? ring,
    Expression<int>? value,
    Expression<DateTime>? thrownAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (ordinal != null) 'ordinal': ordinal,
      if (playerId != null) 'player_id': playerId,
      if (number != null) 'number': number,
      if (ring != null) 'ring': ring,
      if (value != null) 'value': value,
      if (thrownAt != null) 'thrown_at': thrownAt,
    });
  }

  DartEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? gameId,
    Value<int>? ordinal,
    Value<int>? playerId,
    Value<int?>? number,
    Value<Ring?>? ring,
    Value<int>? value,
    Value<DateTime>? thrownAt,
  }) {
    return DartEventsCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      ordinal: ordinal ?? this.ordinal,
      playerId: playerId ?? this.playerId,
      number: number ?? this.number,
      ring: ring ?? this.ring,
      value: value ?? this.value,
      thrownAt: thrownAt ?? this.thrownAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (ring.present) {
      map['ring'] = Variable<String>(
        $DartEventsTable.$converterringn.toSql(ring.value),
      );
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (thrownAt.present) {
      map['thrown_at'] = Variable<DateTime>(thrownAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DartEventsCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('ordinal: $ordinal, ')
          ..write('playerId: $playerId, ')
          ..write('number: $number, ')
          ..write('ring: $ring, ')
          ..write('value: $value, ')
          ..write('thrownAt: $thrownAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $GamesTable games = $GamesTable(this);
  late final $GameSeatsTable gameSeats = $GameSeatsTable(this);
  late final $DartEventsTable dartEvents = $DartEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    players,
    games,
    gameSeats,
    dartEvents,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('game_seats', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('dart_events', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PlayersTableCreateCompanionBuilder =
    PlayersCompanion Function({
      Value<int> id,
      required String name,
      Value<DateTime> createdAt,
    });
typedef $$PlayersTableUpdateCompanionBuilder =
    PlayersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
    });

final class $$PlayersTableReferences
    extends BaseReferences<_$AppDatabase, $PlayersTable, Player> {
  $$PlayersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GamesTable, List<Game>> _gamesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.games,
    aliasName: 'players__id__games__winner_player_id',
  );

  $$GamesTableProcessedTableManager get gamesRefs {
    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.winnerPlayerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gamesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GameSeatsTable, List<GameSeat>>
  _gameSeatsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gameSeats,
    aliasName: 'players__id__game_seats__player_id',
  );

  $$GameSeatsTableProcessedTableManager get gameSeatsRefs {
    final manager = $$GameSeatsTableTableManager(
      $_db,
      $_db.gameSeats,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameSeatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DartEventsTable, List<DartEvent>>
  _dartEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dartEvents,
    aliasName: 'players__id__dart_events__player_id',
  );

  $$DartEventsTableProcessedTableManager get dartEventsRefs {
    final manager = $$DartEventsTableTableManager(
      $_db,
      $_db.dartEvents,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dartEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gamesRefs(
    Expression<bool> Function($$GamesTableFilterComposer f) f,
  ) {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.winnerPlayerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gameSeatsRefs(
    Expression<bool> Function($$GameSeatsTableFilterComposer f) f,
  ) {
    final $$GameSeatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameSeats,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSeatsTableFilterComposer(
            $db: $db,
            $table: $db.gameSeats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dartEventsRefs(
    Expression<bool> Function($$DartEventsTableFilterComposer f) f,
  ) {
    final $$DartEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dartEvents,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DartEventsTableFilterComposer(
            $db: $db,
            $table: $db.dartEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> gamesRefs<T extends Object>(
    Expression<T> Function($$GamesTableAnnotationComposer a) f,
  ) {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.winnerPlayerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gameSeatsRefs<T extends Object>(
    Expression<T> Function($$GameSeatsTableAnnotationComposer a) f,
  ) {
    final $$GameSeatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameSeats,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSeatsTableAnnotationComposer(
            $db: $db,
            $table: $db.gameSeats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dartEventsRefs<T extends Object>(
    Expression<T> Function($$DartEventsTableAnnotationComposer a) f,
  ) {
    final $$DartEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dartEvents,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DartEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.dartEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayersTable,
          Player,
          $$PlayersTableFilterComposer,
          $$PlayersTableOrderingComposer,
          $$PlayersTableAnnotationComposer,
          $$PlayersTableCreateCompanionBuilder,
          $$PlayersTableUpdateCompanionBuilder,
          (Player, $$PlayersTableReferences),
          Player,
          PrefetchHooks Function({
            bool gamesRefs,
            bool gameSeatsRefs,
            bool dartEventsRefs,
          })
        > {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PlayersCompanion(id: id, name: name, createdAt: createdAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
              }) => PlayersCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlayersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gamesRefs = false,
                gameSeatsRefs = false,
                dartEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (gamesRefs) db.games,
                    if (gameSeatsRefs) db.gameSeats,
                    if (dartEventsRefs) db.dartEvents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gamesRefs)
                        await $_getPrefetchedData<Player, $PlayersTable, Game>(
                          currentTable: table,
                          referencedTable: $$PlayersTableReferences
                              ._gamesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayersTableReferences(db, table, p0).gamesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.winnerPlayerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (gameSeatsRefs)
                        await $_getPrefetchedData<
                          Player,
                          $PlayersTable,
                          GameSeat
                        >(
                          currentTable: table,
                          referencedTable: $$PlayersTableReferences
                              ._gameSeatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayersTableReferences(
                                db,
                                table,
                                p0,
                              ).gameSeatsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dartEventsRefs)
                        await $_getPrefetchedData<
                          Player,
                          $PlayersTable,
                          DartEvent
                        >(
                          currentTable: table,
                          referencedTable: $$PlayersTableReferences
                              ._dartEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayersTableReferences(
                                db,
                                table,
                                p0,
                              ).dartEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayersTable,
      Player,
      $$PlayersTableFilterComposer,
      $$PlayersTableOrderingComposer,
      $$PlayersTableAnnotationComposer,
      $$PlayersTableCreateCompanionBuilder,
      $$PlayersTableUpdateCompanionBuilder,
      (Player, $$PlayersTableReferences),
      Player,
      PrefetchHooks Function({
        bool gamesRefs,
        bool gameSeatsRefs,
        bool dartEventsRefs,
      })
    >;
typedef $$GamesTableCreateCompanionBuilder =
    GamesCompanion Function({
      Value<int> id,
      required int startScore,
      Value<bool> doubleOut,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
      Value<int?> winnerPlayerId,
    });
typedef $$GamesTableUpdateCompanionBuilder =
    GamesCompanion Function({
      Value<int> id,
      Value<int> startScore,
      Value<bool> doubleOut,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
      Value<int?> winnerPlayerId,
    });

final class $$GamesTableReferences
    extends BaseReferences<_$AppDatabase, $GamesTable, Game> {
  $$GamesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlayersTable _winnerPlayerIdTable(_$AppDatabase db) =>
      db.players.createAlias('games__winner_player_id__players__id');

  $$PlayersTableProcessedTableManager? get winnerPlayerId {
    final $_column = $_itemColumn<int>('winner_player_id');
    if ($_column == null) return null;
    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_winnerPlayerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GameSeatsTable, List<GameSeat>>
  _gameSeatsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gameSeats,
    aliasName: 'games__id__game_seats__game_id',
  );

  $$GameSeatsTableProcessedTableManager get gameSeatsRefs {
    final manager = $$GameSeatsTableTableManager(
      $_db,
      $_db.gameSeats,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameSeatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DartEventsTable, List<DartEvent>>
  _dartEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dartEvents,
    aliasName: 'games__id__dart_events__game_id',
  );

  $$DartEventsTableProcessedTableManager get dartEventsRefs {
    final manager = $$DartEventsTableTableManager(
      $_db,
      $_db.dartEvents,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dartEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startScore => $composableBuilder(
    column: $table.startScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get doubleOut => $composableBuilder(
    column: $table.doubleOut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PlayersTableFilterComposer get winnerPlayerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerPlayerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> gameSeatsRefs(
    Expression<bool> Function($$GameSeatsTableFilterComposer f) f,
  ) {
    final $$GameSeatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameSeats,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSeatsTableFilterComposer(
            $db: $db,
            $table: $db.gameSeats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dartEventsRefs(
    Expression<bool> Function($$DartEventsTableFilterComposer f) f,
  ) {
    final $$DartEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dartEvents,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DartEventsTableFilterComposer(
            $db: $db,
            $table: $db.dartEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableOrderingComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startScore => $composableBuilder(
    column: $table.startScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get doubleOut => $composableBuilder(
    column: $table.doubleOut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlayersTableOrderingComposer get winnerPlayerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerPlayerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startScore => $composableBuilder(
    column: $table.startScore,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get doubleOut =>
      $composableBuilder(column: $table.doubleOut, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  $$PlayersTableAnnotationComposer get winnerPlayerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerPlayerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> gameSeatsRefs<T extends Object>(
    Expression<T> Function($$GameSeatsTableAnnotationComposer a) f,
  ) {
    final $$GameSeatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameSeats,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSeatsTableAnnotationComposer(
            $db: $db,
            $table: $db.gameSeats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dartEventsRefs<T extends Object>(
    Expression<T> Function($$DartEventsTableAnnotationComposer a) f,
  ) {
    final $$DartEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dartEvents,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DartEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.dartEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamesTable,
          Game,
          $$GamesTableFilterComposer,
          $$GamesTableOrderingComposer,
          $$GamesTableAnnotationComposer,
          $$GamesTableCreateCompanionBuilder,
          $$GamesTableUpdateCompanionBuilder,
          (Game, $$GamesTableReferences),
          Game,
          PrefetchHooks Function({
            bool winnerPlayerId,
            bool gameSeatsRefs,
            bool dartEventsRefs,
          })
        > {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> startScore = const Value.absent(),
                Value<bool> doubleOut = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int?> winnerPlayerId = const Value.absent(),
              }) => GamesCompanion(
                id: id,
                startScore: startScore,
                doubleOut: doubleOut,
                startedAt: startedAt,
                finishedAt: finishedAt,
                winnerPlayerId: winnerPlayerId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int startScore,
                Value<bool> doubleOut = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int?> winnerPlayerId = const Value.absent(),
              }) => GamesCompanion.insert(
                id: id,
                startScore: startScore,
                doubleOut: doubleOut,
                startedAt: startedAt,
                finishedAt: finishedAt,
                winnerPlayerId: winnerPlayerId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GamesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                winnerPlayerId = false,
                gameSeatsRefs = false,
                dartEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (gameSeatsRefs) db.gameSeats,
                    if (dartEventsRefs) db.dartEvents,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (winnerPlayerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.winnerPlayerId,
                                    referencedTable: $$GamesTableReferences
                                        ._winnerPlayerIdTable(db),
                                    referencedColumn: $$GamesTableReferences
                                        ._winnerPlayerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gameSeatsRefs)
                        await $_getPrefetchedData<Game, $GamesTable, GameSeat>(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._gameSeatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).gameSeatsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dartEventsRefs)
                        await $_getPrefetchedData<Game, $GamesTable, DartEvent>(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._dartEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).dartEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamesTable,
      Game,
      $$GamesTableFilterComposer,
      $$GamesTableOrderingComposer,
      $$GamesTableAnnotationComposer,
      $$GamesTableCreateCompanionBuilder,
      $$GamesTableUpdateCompanionBuilder,
      (Game, $$GamesTableReferences),
      Game,
      PrefetchHooks Function({
        bool winnerPlayerId,
        bool gameSeatsRefs,
        bool dartEventsRefs,
      })
    >;
typedef $$GameSeatsTableCreateCompanionBuilder =
    GameSeatsCompanion Function({
      required int gameId,
      required int playerId,
      required int seat,
      Value<int> rowid,
    });
typedef $$GameSeatsTableUpdateCompanionBuilder =
    GameSeatsCompanion Function({
      Value<int> gameId,
      Value<int> playerId,
      Value<int> seat,
      Value<int> rowid,
    });

final class $$GameSeatsTableReferences
    extends BaseReferences<_$AppDatabase, $GameSeatsTable, GameSeat> {
  $$GameSeatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('game_seats__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _playerIdTable(_$AppDatabase db) =>
      db.players.createAlias('game_seats__player_id__players__id');

  $$PlayersTableProcessedTableManager get playerId {
    final $_column = $_itemColumn<int>('player_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GameSeatsTableFilterComposer
    extends Composer<_$AppDatabase, $GameSeatsTable> {
  $$GameSeatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seat => $composableBuilder(
    column: $table.seat,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get playerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameSeatsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameSeatsTable> {
  $$GameSeatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seat => $composableBuilder(
    column: $table.seat,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get playerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameSeatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameSeatsTable> {
  $$GameSeatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seat =>
      $composableBuilder(column: $table.seat, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get playerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameSeatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameSeatsTable,
          GameSeat,
          $$GameSeatsTableFilterComposer,
          $$GameSeatsTableOrderingComposer,
          $$GameSeatsTableAnnotationComposer,
          $$GameSeatsTableCreateCompanionBuilder,
          $$GameSeatsTableUpdateCompanionBuilder,
          (GameSeat, $$GameSeatsTableReferences),
          GameSeat,
          PrefetchHooks Function({bool gameId, bool playerId})
        > {
  $$GameSeatsTableTableManager(_$AppDatabase db, $GameSeatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameSeatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameSeatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameSeatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> gameId = const Value.absent(),
                Value<int> playerId = const Value.absent(),
                Value<int> seat = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameSeatsCompanion(
                gameId: gameId,
                playerId: playerId,
                seat: seat,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int gameId,
                required int playerId,
                required int seat,
                Value<int> rowid = const Value.absent(),
              }) => GameSeatsCompanion.insert(
                gameId: gameId,
                playerId: playerId,
                seat: seat,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GameSeatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false, playerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameId,
                                referencedTable: $$GameSeatsTableReferences
                                    ._gameIdTable(db),
                                referencedColumn: $$GameSeatsTableReferences
                                    ._gameIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (playerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playerId,
                                referencedTable: $$GameSeatsTableReferences
                                    ._playerIdTable(db),
                                referencedColumn: $$GameSeatsTableReferences
                                    ._playerIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GameSeatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameSeatsTable,
      GameSeat,
      $$GameSeatsTableFilterComposer,
      $$GameSeatsTableOrderingComposer,
      $$GameSeatsTableAnnotationComposer,
      $$GameSeatsTableCreateCompanionBuilder,
      $$GameSeatsTableUpdateCompanionBuilder,
      (GameSeat, $$GameSeatsTableReferences),
      GameSeat,
      PrefetchHooks Function({bool gameId, bool playerId})
    >;
typedef $$DartEventsTableCreateCompanionBuilder =
    DartEventsCompanion Function({
      Value<int> id,
      required int gameId,
      required int ordinal,
      required int playerId,
      Value<int?> number,
      Value<Ring?> ring,
      required int value,
      Value<DateTime> thrownAt,
    });
typedef $$DartEventsTableUpdateCompanionBuilder =
    DartEventsCompanion Function({
      Value<int> id,
      Value<int> gameId,
      Value<int> ordinal,
      Value<int> playerId,
      Value<int?> number,
      Value<Ring?> ring,
      Value<int> value,
      Value<DateTime> thrownAt,
    });

final class $$DartEventsTableReferences
    extends BaseReferences<_$AppDatabase, $DartEventsTable, DartEvent> {
  $$DartEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('dart_events__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _playerIdTable(_$AppDatabase db) =>
      db.players.createAlias('dart_events__player_id__players__id');

  $$PlayersTableProcessedTableManager get playerId {
    final $_column = $_itemColumn<int>('player_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DartEventsTableFilterComposer
    extends Composer<_$AppDatabase, $DartEventsTable> {
  $$DartEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Ring?, Ring, String> get ring =>
      $composableBuilder(
        column: $table.ring,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get thrownAt => $composableBuilder(
    column: $table.thrownAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get playerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DartEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $DartEventsTable> {
  $$DartEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ring => $composableBuilder(
    column: $table.ring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get thrownAt => $composableBuilder(
    column: $table.thrownAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get playerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DartEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DartEventsTable> {
  $$DartEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Ring?, String> get ring =>
      $composableBuilder(column: $table.ring, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get thrownAt =>
      $composableBuilder(column: $table.thrownAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get playerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DartEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DartEventsTable,
          DartEvent,
          $$DartEventsTableFilterComposer,
          $$DartEventsTableOrderingComposer,
          $$DartEventsTableAnnotationComposer,
          $$DartEventsTableCreateCompanionBuilder,
          $$DartEventsTableUpdateCompanionBuilder,
          (DartEvent, $$DartEventsTableReferences),
          DartEvent,
          PrefetchHooks Function({bool gameId, bool playerId})
        > {
  $$DartEventsTableTableManager(_$AppDatabase db, $DartEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DartEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DartEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DartEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gameId = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<int> playerId = const Value.absent(),
                Value<int?> number = const Value.absent(),
                Value<Ring?> ring = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<DateTime> thrownAt = const Value.absent(),
              }) => DartEventsCompanion(
                id: id,
                gameId: gameId,
                ordinal: ordinal,
                playerId: playerId,
                number: number,
                ring: ring,
                value: value,
                thrownAt: thrownAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameId,
                required int ordinal,
                required int playerId,
                Value<int?> number = const Value.absent(),
                Value<Ring?> ring = const Value.absent(),
                required int value,
                Value<DateTime> thrownAt = const Value.absent(),
              }) => DartEventsCompanion.insert(
                id: id,
                gameId: gameId,
                ordinal: ordinal,
                playerId: playerId,
                number: number,
                ring: ring,
                value: value,
                thrownAt: thrownAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DartEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false, playerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameId,
                                referencedTable: $$DartEventsTableReferences
                                    ._gameIdTable(db),
                                referencedColumn: $$DartEventsTableReferences
                                    ._gameIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (playerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playerId,
                                referencedTable: $$DartEventsTableReferences
                                    ._playerIdTable(db),
                                referencedColumn: $$DartEventsTableReferences
                                    ._playerIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DartEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DartEventsTable,
      DartEvent,
      $$DartEventsTableFilterComposer,
      $$DartEventsTableOrderingComposer,
      $$DartEventsTableAnnotationComposer,
      $$DartEventsTableCreateCompanionBuilder,
      $$DartEventsTableUpdateCompanionBuilder,
      (DartEvent, $$DartEventsTableReferences),
      DartEvent,
      PrefetchHooks Function({bool gameId, bool playerId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$GamesTableTableManager get games =>
      $$GamesTableTableManager(_db, _db.games);
  $$GameSeatsTableTableManager get gameSeats =>
      $$GameSeatsTableTableManager(_db, _db.gameSeats);
  $$DartEventsTableTableManager get dartEvents =>
      $$DartEventsTableTableManager(_db, _db.dartEvents);
}
