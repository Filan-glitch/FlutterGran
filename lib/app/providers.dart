import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/board/ble_board_source.dart';
import '../data/board/board_source.dart';
import '../data/board/fake_board_source.dart';
import '../data/board/segment_codec.dart';
import '../data/db/database.dart';
import '../data/db/game_repository.dart';
import '../domain/board_event.dart';
import '../domain/checkout/checkout_table.dart';
import '../domain/segment.dart';
import '../domain/stats/player_stats.dart';
import '../domain/x01/game_config.dart';
import '../domain/x01/leg_reducer.dart';
import '../domain/x01/leg_state.dart';
import '../domain/x01/match_state.dart';
import 'audio/sound_controller.dart';
import 'audio/sound_player.dart';
import 'game_controller.dart';
import 'match_controller.dart';

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

/// A single long-lived codec.
///
/// Kept out of [boardReaderProvider] so calibration corrections can be applied
/// to it in place. Rebuilding it would tear down the board connection every
/// time a segment was corrected - exactly while someone is standing at the
/// board throwing darts at it.
final segmentCodecProvider = Provider<SegmentCodec>((ref) => SegmentCodec());

final boardReaderProvider = Provider<BoardReader>((ref) {
  final reader = BoardReader(
    source: ref.watch(boardSourceProvider),
    codec: ref.watch(segmentCodecProvider),
  );
  ref.onDispose(reader.dispose);
  return reader;
});

/// Codes verified against this particular board.
final calibrationsProvider = StreamProvider<List<SegmentCalibration>>(
  (ref) => ref.watch(gameRepositoryProvider).watchCalibrations(),
);

/// Segments whose code has been confirmed, for the coverage checklist.
final calibrationCoverageProvider = Provider<Set<Segment>>((ref) {
  final rows = ref.watch(calibrationsProvider).value ?? const [];
  return {for (final row in rows) Segment(row.number, row.ring)};
});

/// Keeps the decoder in step with what calibration has learned.
///
/// Corrections are pushed into the live codec rather than rebuilt around it, so
/// the next dart decodes correctly without reconnecting.
final calibrationSyncProvider = Provider<void>((ref) {
  final codec = ref.watch(segmentCodecProvider);
  final rows = ref.watch(calibrationsProvider).value ?? const [];

  codec.clearAllOverrides();
  for (final row in rows.where((row) => row.corrected)) {
    codec.setOverride(row.body, Segment(row.number, row.ring));
  }
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

/// Whether the keypad is being shown by hand over a connected board.
///
/// Separate from [BoardMode]/[boardSourceProvider]: those decide which board
/// the app is reading from, a setup-time choice buried in diagnostics. This is
/// a mid-game visibility switch a player reaches for from the corner of the
/// game screen - "let me key one in" - and it means nothing until there is a
/// real board connected for the keypad to be hidden behind in the first place.
class KeypadOverrideController extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;

  void set(bool value) => state = value;
}

final keypadOverrideProvider =
    NotifierProvider<KeypadOverrideController, bool>(
      KeypadOverrideController.new,
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
    startingSeat: state.startingSeat,
  );

  /// Reseats the leg, which resets the lead: a different field is a different
  /// leg, and there is no seat to carry over.
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

final matchProvider = NotifierProvider<MatchController, MatchSession?>(
  MatchController.new,
);

/// Where the match stands, the leg on screen included.
///
/// Null when a leg is being played outside a match at all. Folding the current
/// leg's winner in here rather than storing it is what keeps the tally honest
/// through an undo.
final matchStateProvider = Provider<MatchState?>((ref) {
  final session = ref.watch(matchProvider);
  if (session == null) return null;

  final current = ref.watch(gameProvider).leg.winnerId;
  return foldMatch(session.config, [...session.decidedLegs, ?current]);
});

/// The legs of the match on screen that are already in the books.
///
/// Keyed on the session rather than the game on purpose: the legs behind the
/// current one cannot change while it is being thrown, so this reads the
/// database once per leg rather than once per dart. The leg on screen is left
/// out because it is in [gameProvider], live and un-stored - whoever wants the
/// whole match adds it on the end.
final decidedMatchLegsProvider = FutureProvider<List<LegState>>((ref) async {
  final session = ref.watch(matchProvider);
  if (session == null) return const [];

  return ref
      .watch(gameRepositoryProvider)
      .loadMatchLegs(
        session.matchId,
        beforeLegNumber: session.decidedLegs.length,
      );
});

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

/// Every stored match, folded from its legs.
final allMatchesProvider = StreamProvider<List<MatchState>>(
  (ref) => ref.watch(gameRepositoryProvider).watchAllMatches(),
);

/// A player's all-time record.
final playerStatsProvider = Provider.family<PlayerStats, int>((ref, playerId) {
  final legs = ref.watch(allLegsProvider).value;
  if (legs == null) return PlayerStats.empty;
  return computePlayerStats(
    playerId,
    legs,
    matches: ref.watch(allMatchesProvider).value ?? const [],
  );
});

/// Where a player's darts have landed, for the accuracy heatmap.
final segmentCountsProvider = FutureProvider.family<Map<Segment, int>, int>(
  (ref, playerId) {
    // Depend on the legs stream so the map refreshes as games are played.
    ref.watch(allLegsProvider);
    return ref.watch(gameRepositoryProvider).segmentCounts(playerId);
  },
);

/// A leg that was left unfinished, ready to be picked back up.
class ResumableLeg {
  const ResumableLeg({required this.gameId, required this.leg});

  final int gameId;

  /// Replayed from the stored dart log, so the banner can show real scores.
  final LegState leg;
}

/// The leg the setup screen offers to resume, or null when there is none.
///
/// Watches the games table rather than loading once: finishing or abandoning a
/// leg has to make the offer appear or disappear without a manual refresh.
final resumableLegProvider = StreamProvider<ResumableLeg?>((ref) async* {
  final repository = ref.watch(gameRepositoryProvider);

  await for (final gameId in repository.watchResumableGameId()) {
    if (gameId == null) {
      yield null;
      continue;
    }

    final config = await repository.loadConfig(gameId);
    if (config == null) {
      yield null;
      continue;
    }

    yield ResumableLeg(
      gameId: gameId,
      leg: foldLeg(config, await repository.loadLog(gameId)),
    );
  }
});

/// The game rows are being written to, or null when nothing is persisted.
class CurrentGameId extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? gameId) => state = gameId;
}

final currentGameIdProvider = NotifierProvider<CurrentGameId, int?>(
  CurrentGameId.new,
);

/// One remembered on/off switch.
///
/// Kept in shared_preferences rather than in the drift database, and the reason
/// is not that a table would be hard. The database is the history of every dart
/// ever thrown - relational, migrated, replayed through the scoring engine - and
/// a pair of booleans is none of those things. Giving them a table costs a
/// schema version, and `feat/multi-leg` has already claimed version 3 for
/// `Matches`. That branch and this one were meant to run in parallel; two
/// branches minting the same schema version is a merge nobody enjoys, over two
/// bits of state that have no business being in a games database anyway.
class BoolSetting extends Notifier<bool> {
  BoolSetting(this._key);

  final String _key;

  @override
  bool build() {
    // Both settings default on, and correct themselves a frame later if the
    // stored value disagrees. Holding the first frame on a disk read to avoid
    // one frame of the default is the wrong way round: the default is right for
    // everyone who has never touched the switch.
    unawaited(_load());
    return true;
  }

  Future<void> _load() async {
    final stored = (await _preferences())?.getBool(_key);
    if (stored != null) state = stored;
  }

  Future<void> set(bool value) async {
    state = value;
    await (await _preferences())?.setBool(_key, value);
  }

  /// Null when there is no platform behind the channel.
  ///
  /// That is the test binding, where no preference has ever been written and
  /// the defaults are exactly what the tests want. It is the only case this
  /// swallows - a genuine read failure on a device would still surface.
  Future<SharedPreferences?> _preferences() async {
    try {
      return await SharedPreferences.getInstance();
    } on MissingPluginException {
      return null;
    }
  }
}

/// The master switch: off means silence, cues and commentary alike.
final soundEnabledProvider = NotifierProvider<BoolSetting, bool>(
  () => BoolSetting('sound.enabled'),
);

/// The spoken commentary alone.
///
/// Separate from [soundEnabledProvider] because the two wear out at different
/// rates. Being told your own score out loud every turn gets old long before a
/// 45ms click does, and someone who turns the talking off should not lose the
/// dart cue with it.
final speechEnabledProvider = NotifierProvider<BoolSetting, bool>(
  () => BoolSetting('speech.enabled'),
);

/// Overridden in tests with a fake that records rather than plays.
final soundPlayerProvider = Provider<SoundPlayer>((ref) {
  final player = AudioPlayersSoundPlayer();
  ref.onDispose(player.dispose);
  return player;
});

/// Watches the game and plays what it hears.
///
/// A listener rather than something the screens or the controller call. Audio
/// is a consequence of the leg, not a step in it, so nothing on the scoring
/// path - and nothing at all in `lib/domain` - has to know it exists. The game
/// screen keeps this alive simply by watching it.
final soundControllerProvider = Provider<SoundController>((ref) {
  final controller = SoundController(ref.watch(soundPlayerProvider));

  ref.listen(gameProvider, (previous, next) {
    controller.observe(
      previous,
      next,
      soundEnabled: ref.read(soundEnabledProvider),
      speechEnabled: ref.read(speechEnabledProvider),
    );
  });

  // Silence what is already queued the moment a switch goes off, rather than
  // letting the line that was waiting behind a cue arrive after it.
  ref.listen(soundEnabledProvider, (_, enabled) {
    if (!enabled) controller.player.silence();
  });
  ref.listen(speechEnabledProvider, (_, enabled) {
    if (!enabled) controller.player.silence();
  });

  return controller;
});
