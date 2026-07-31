import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/board/ble_board_source.dart';
import '../data/board/board_source.dart';
import '../data/board/fake_board_source.dart';
import '../data/db/database.dart';
import '../data/db/game_repository.dart';
import '../domain/board_event.dart';
import '../domain/checkout/checkout_table.dart';
import '../domain/segment.dart';
import '../domain/stats/player_stats.dart';
import '../domain/x01/game_config.dart';
import '../domain/x01/leg_state.dart';
import 'game_controller.dart';

/// Which board the app is reading.
enum BoardMode {
  /// Scripted bytes, for playing and testing without hardware.
  fake,

  /// A real GranBoard over Bluetooth.
  bluetooth;

  String get label => this == BoardMode.fake ? 'Simulated' : 'Bluetooth';
}

class BoardModeController extends Notifier<BoardMode> {
  @override
  BoardMode build() => BoardMode.fake;

  void set(BoardMode mode) => state = mode;
}

final boardModeProvider = NotifierProvider<BoardModeController, BoardMode>(
  BoardModeController.new,
);

/// The board the app is reading.
///
/// Switching this one provider is the whole mechanism for swapping the fake for
/// real Bluetooth, which is why nothing above it ever learns which it is
/// talking to. Tests override it directly.
final boardSourceProvider = Provider<BoardSource>((ref) {
  final source = switch (ref.watch(boardModeProvider)) {
    BoardMode.fake => FakeBoardSource(),
    BoardMode.bluetooth => BleBoardSource(),
  };
  ref.onDispose(source.dispose);
  return source;
});

final boardReaderProvider = Provider<BoardReader>((ref) {
  final reader = BoardReader(source: ref.watch(boardSourceProvider));
  ref.onDispose(reader.dispose);
  return reader;
});

final boardEventsProvider = StreamProvider<BoardEvent>(
  (ref) => ref.watch(boardReaderProvider).events,
);

final boardConnectionProvider = StreamProvider<BoardConnectionState>(
  (ref) => ref.watch(boardReaderProvider).connectionState,
);

/// Frames the board sent that the segment table does not recognise.
///
/// Kept for the diagnostics screen: on an unverified board these are the only
/// evidence of what the hardware actually does.
final unknownFramesProvider = StreamProvider<List<String>>((ref) async* {
  final seen = <String>[];
  await for (final event in ref.watch(boardReaderProvider).events) {
    if (event is UnknownFrame) {
      seen.add(event.body);
      yield List<String>.unmodifiable(seen);
    }
  }
});

final checkoutTableProvider = Provider<CheckoutTable>(
  (ref) => CheckoutTable(),
);

class GameConfigController extends Notifier<GameConfig> {
  @override
  GameConfig build() =>
      GameConfig(startScore: 501, playerIds: const [1, 2]);

  void update(GameConfig config) => state = config;

  void setStartScore(int startScore) => state = GameConfig(
    startScore: startScore,
    playerIds: state.playerIds,
    doubleOut: state.doubleOut,
  );

  void setPlayerCount(int count) => state = GameConfig(
    startScore: state.startScore,
    playerIds: [for (var i = 1; i <= count; i++) i],
    doubleOut: state.doubleOut,
  );
}

final gameConfigProvider = NotifierProvider<GameConfigController, GameConfig>(
  GameConfigController.new,
);

final gameProvider = NotifierProvider<GameController, GameSession>(
  GameController.new,
);

/// Overridden in tests with an in-memory database.
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepository(ref.watch(databaseProvider)),
);

final playersProvider = StreamProvider<List<Player>>(
  (ref) => ref.watch(gameRepositoryProvider).watchPlayers(),
);

/// Player id to name, for labelling the scoreboard.
final playerNamesProvider = Provider<Map<int, String>>((ref) {
  final players = ref.watch(playersProvider).value ?? const <Player>[];
  return {for (final player in players) player.id: player.name};
});

/// Every stored leg, replayed. Refreshes itself when a game changes.
final allLegsProvider = StreamProvider<List<LegState>>(
  (ref) => ref.watch(gameRepositoryProvider).watchAllLegs(),
);

/// A player's all-time record.
final playerStatsProvider = Provider.family<PlayerStats, int>((ref, playerId) {
  final legs = ref.watch(allLegsProvider).value;
  if (legs == null) return PlayerStats.empty;
  return computePlayerStats(playerId, legs);
});

/// Where a player's darts have landed, for the accuracy heatmap.
final segmentCountsProvider = FutureProvider.family<Map<Segment, int>, int>(
  (ref, playerId) {
    // Depend on the legs stream so the map refreshes as games are played.
    ref.watch(allLegsProvider);
    return ref.watch(gameRepositoryProvider).segmentCounts(playerId);
  },
);

/// The game rows are being written to, or null when nothing is persisted.
class CurrentGameId extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? gameId) => state = gameId;
}

final currentGameIdProvider = NotifierProvider<CurrentGameId, int?>(
  CurrentGameId.new,
);
