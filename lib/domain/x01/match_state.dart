import 'game_config.dart';

/// Best-of formats offered in the UI. The engine accepts any positive count.
const List<int> offeredLegsToPlay = [1, 3, 5, 7];

/// Which seat throws first in leg [legNumber] of a match between
/// [playerCount] players.
///
/// Legs are numbered from zero, like the dart log's ordinal, so the rule is
/// just the leg number modulo the field. It lives on its own rather than only
/// inside [MatchConfig] because a stored leg's starting seat is rebuilt from
/// its leg number alone: change this and history replays differently, so it
/// would need a migration writing the seat out explicitly.
int startingSeatForLeg(int legNumber, int playerCount) =>
    legNumber % playerCount;

/// The format a match is played to.
///
/// A match is a run of legs under one set of rules, won by whoever takes more
/// than half of them. Best of one is a legitimate match, and is what every leg
/// played before matches existed amounts to.
class MatchConfig {
  MatchConfig({
    required this.startScore,
    required this.playerIds,
    this.doubleOut = true,
    this.legsToPlay = 1,
  }) : assert(legsToPlay > 0, 'a match is at least one leg'),
       assert(playerIds.isNotEmpty, 'a match needs players');

  /// Points each player starts every leg on.
  final int startScore;

  /// Seats in throwing order. Fixed for the whole match; only who leads off
  /// each leg moves.
  final List<int> playerIds;

  final bool doubleOut;

  /// Best of this many legs.
  final int legsToPlay;

  /// Legs it takes to win: more than half of [legsToPlay].
  int get legsToWin => (legsToPlay ~/ 2) + 1;

  /// Whether this format is more than the single leg the app has always played.
  bool get isMultiLeg => legsToPlay > 1;

  int startingSeatFor(int legNumber) =>
      startingSeatForLeg(legNumber, playerIds.length);

  /// The rules for one leg of the match, with the throw rotated into place.
  GameConfig legConfig(int legNumber) => GameConfig(
    startScore: startScore,
    playerIds: playerIds,
    doubleOut: doubleOut,
    startingSeat: startingSeatFor(legNumber),
  );
}

/// Where a match stands, derived entirely from the legs already won.
///
/// The same idea as [GameConfig]'s leg fold one level up: nothing here is
/// mutated or counted incrementally, so undoing a checkout that had won a leg
/// only means folding a shorter list.
class MatchState {
  const MatchState({
    required this.config,
    required this.legWinners,
    required this.legsWon,
    required this.winnerId,
  });

  final MatchConfig config;

  /// Winner of each leg that counted, in order.
  final List<int> legWinners;

  /// Legs won, per player id. Every seat is present, on zero if need be.
  final Map<int, int> legsWon;

  /// Winner of the match, or null while it is still running.
  final int? winnerId;

  bool get isFinished => winnerId != null;

  int get legsPlayed => legWinners.length;

  /// Number of the leg to throw next, from zero.
  int get nextLegNumber => legsPlayed;

  int get nextStartingSeat => config.startingSeatFor(nextLegNumber);

  /// Rules for the next leg, or null once the match is decided.
  GameConfig? get nextLegConfig =>
      isFinished ? null : config.legConfig(nextLegNumber);

  /// Legs the leader still needs. Zero once the match is won.
  int get legsToWinFrom {
    final best = legsWon.values.fold<int>(0, (a, b) => a > b ? a : b);
    return config.legsToWin - best;
  }
}

/// Folds the winners of completed legs into the state of the match.
///
/// [legWinners] is the winning player id of each finished leg, oldest first;
/// legs still in progress are simply absent.
MatchState foldMatch(MatchConfig config, Iterable<int> legWinners) {
  final legsWon = <int, int>{for (final id in config.playerIds) id: 0};
  final counted = <int>[];
  int? winnerId;

  for (final playerId in legWinners) {
    // Legs logged after the match is decided cannot change it, the same way
    // darts logged after a checkout cannot change a leg.
    if (winnerId != null) break;

    counted.add(playerId);
    legsWon[playerId] = (legsWon[playerId] ?? 0) + 1;
    if (legsWon[playerId]! >= config.legsToWin) winnerId = playerId;
  }

  return MatchState(
    config: config,
    legWinners: List<int>.unmodifiable(counted),
    legsWon: Map<int, int>.unmodifiable(legsWon),
    winnerId: winnerId,
  );
}
