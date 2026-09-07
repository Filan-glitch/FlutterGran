import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/board/ble_board_source.dart';
import '../data/board/board_source.dart';
import '../data/board/segment_codec.dart';
import '../data/db/database.dart';
import '../data/db/game_repository.dart';
import '../domain/atc/atc_config.dart';
import '../domain/atc/atc_leg_state.dart';
import '../domain/atc/atc_reducer.dart';
import '../domain/atc/atc_variant.dart';
import '../domain/board_event.dart';
import '../domain/checkout/checkout_table.dart';
import '../domain/game_mode.dart';
import '../domain/segment.dart';
import '../domain/stats/player_stats.dart';
import '../domain/x01/game_config.dart';
import '../domain/x01/leg_reducer.dart';
import '../domain/x01/leg_state.dart';
import '../domain/x01/match_state.dart';
import 'atc_controller.dart';
import 'audio/sound_controller.dart';
import 'audio/sound_player.dart';
import 'game_controller.dart';
import 'match_controller.dart';

/// The board the app is reading.
///
/// Always a real GranBoard over Bluetooth - there is no in-app switch for it
/// any more. Hardware day (2026-09-04) confirmed the real connection works
/// end to end, so scripted bytes are a test-only concern from here on; tests
/// override this provider directly with a `FakeBoardSource`.
final boardSourceProvider = Provider<BoardSource>((ref) {
  final source = BleBoardSource();
  ref.onDispose(source.dispose);
  return source;
});

final segmentCodecProvider = Provider<SegmentCodec>((ref) => SegmentCodec());

final boardReaderProvider = Provider<BoardReader>((ref) {
  final reader = BoardReader(
    source: ref.watch(boardSourceProvider),
    codec: ref.watch(segmentCodecProvider),
  );
  ref.onDispose(reader.dispose);
  return reader;
});

final boardEventsProvider = StreamProvider<BoardEvent>(
  (ref) => ref.watch(boardReaderProvider).events,
);

final boardConnectionProvider = StreamProvider<BoardConnectionState>(
  (ref) => ref.watch(boardReaderProvider).connectionState,
);

final checkoutTableProvider = Provider<CheckoutTable>(
  (ref) => CheckoutTable(),
);

/// Whether the keypad is being shown by hand over a connected board.
///
/// Separate from [boardSourceProvider]: that decides which board the app is
/// reading from. This is a mid-game visibility switch a player reaches for
/// from the corner of the game screen - "let me key one in" - and it means
/// nothing until there is a real board connected for the keypad to be hidden
/// behind in the first place.
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

class AtcConfigController extends Notifier<AtcConfig> {
  @override
  AtcConfig build() =>
      AtcConfig(playerIds: const [1, 2], variant: AtcVariant.anyPart);

  void update(AtcConfig config) => state = config;
}

final atcConfigProvider = NotifierProvider<AtcConfigController, AtcConfig>(
  AtcConfigController.new,
);

final atcGameProvider = NotifierProvider<AtcController, AtcSession>(
  AtcController.new,
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

/// Every stored Around the Clock leg, replayed.
final allAtcLegsProvider = StreamProvider<List<AtcLegState>>(
  (ref) => ref.watch(gameRepositoryProvider).watchAllAtcLegs(),
);

/// A player's all-time record, one entry per mode they have played.
///
/// See [computePlayerStats] for why the grouping happens here rather than
/// inside the domain function.
final playerStatsProvider =
    Provider.family<Map<GameMode, ModeStats>, int>((ref, playerId) {
      return computePlayerStats(
        playerId,
        x01Legs: ref.watch(allLegsProvider).value ?? const [],
        x01Matches: ref.watch(allMatchesProvider).value ?? const [],
        atcLegs: ref.watch(allAtcLegsProvider).value ?? const [],
      );
    });

/// Where a player's darts have landed, for the accuracy heatmap.
///
/// Every dart ever thrown counts here regardless of mode - the underlying
/// query has no `gameMode` filter of its own - so this depends on both leg
/// streams purely to know when to refresh, not to change what it reads.
final segmentCountsProvider = FutureProvider.family<Map<Segment, int>, int>(
  (ref, playerId) {
    ref.watch(allLegsProvider);
    ref.watch(allAtcLegsProvider);
    return ref.watch(gameRepositoryProvider).segmentCounts(playerId);
  },
);

/// A leg that was left unfinished, ready to be picked back up.
///
/// Sealed, the same pattern [ModeStats] uses: every call site that reads
/// [leg] has to switch on the concrete type, which is what makes a third
/// mode's leg impossible to fall through unhandled the way an x01-only
/// resume path once would have.
sealed class ResumableLeg {
  const ResumableLeg({required this.gameId});

  final int gameId;
}

class ResumableX01Leg extends ResumableLeg {
  const ResumableX01Leg({required super.gameId, required this.leg});

  /// Replayed from the stored dart log, so the banner can show real scores.
  final LegState leg;
}

class ResumableAtcLeg extends ResumableLeg {
  const ResumableAtcLeg({required super.gameId, required this.leg});

  final AtcLegState leg;
}

/// The leg the main menu offers to resume, or null when there is none.
///
/// Watches the games table rather than loading once: finishing or abandoning a
/// leg has to make the offer appear or disappear without a manual refresh.
/// [GameRepository.watchResumableGameId] itself has no `gameMode` filter, so
/// the row's own mode decides which config/fold this reads it back through.
final resumableLegProvider = StreamProvider<ResumableLeg?>((ref) async* {
  final repository = ref.watch(gameRepositoryProvider);

  await for (final gameId in repository.watchResumableGameId()) {
    if (gameId == null) {
      yield null;
      continue;
    }

    final game = await repository.loadGame(gameId);
    if (game == null) {
      yield null;
      continue;
    }

    switch (game.gameMode) {
      case GameMode.x01:
        final config = await repository.loadConfig(gameId);
        if (config == null) {
          yield null;
          continue;
        }
        yield ResumableX01Leg(
          gameId: gameId,
          leg: foldLeg(config, await repository.loadLog(gameId)),
        );
      case GameMode.aroundTheClock:
        final config = await repository.loadAtcConfig(gameId);
        if (config == null) {
          yield null;
          continue;
        }
        yield ResumableAtcLeg(
          gameId: gameId,
          leg: foldAroundTheClock(config, await repository.loadLog(gameId)),
        );
    }
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
