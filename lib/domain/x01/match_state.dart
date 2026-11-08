/// Best-of matches: [MatchConfig], and [foldMatch], which derives the score and
/// the winner from the legs already won, plus who throws first in each leg.
///
/// {@category Domain}
library;

import 'game_config.dart';
import 'leg_reducer.dart';
import 'x01_rules.dart';

/// Best-of formats offered in the UI. The engine accepts any positive count.
const List<int> offeredLegsToPlay = [1, 3, 5, 7];

/// Legs needed to take a best of [legsToPlay]: more than half of them.
///
/// Free-standing because the setup screen has to name the format before there
/// is a [MatchConfig] to ask.
int legsToWinFor(int legsToPlay) => (legsToPlay ~/ 2) + 1;

/// Which seat throws first in leg [legNumber] (from zero) of a match between
/// [playerCount] players: the leg number modulo the field.
///
/// A stored leg's starting seat is rebuilt from its leg number alone, so
/// changing this rule replays history differently and would need a migration
/// writing the seat out explicitly.
int startingSeatForLeg(int legNumber, int playerCount) =>
    legNumber % playerCount;

/// The format a match is played to: a run of legs under one set of rules, won
/// by the first player to [legsToWin].
///
/// Head to head, that is the same as best of [legsToPlay]. With three or more
/// players it is not - three players taking one leg each in a best of three
/// leaves nobody on two - so the match runs on until somebody reaches the
/// target, and [formatLabel] says "first to" instead.
class MatchConfig {
  MatchConfig({
    required this.startScore,
    required this.playerIds,
    this.inRule = X01InRule.straight,
    this.outRule = X01OutRule.double,
    this.legsToPlay = 1,
  }) : assert(legsToPlay > 0, 'a match is at least one leg'),
       assert(playerIds.isNotEmpty, 'a match needs players');

  /// Points each player starts every leg on.
  final int startScore;

  /// Seats in throwing order. Fixed for the whole match; only who leads off
  /// each leg moves.
  final List<int> playerIds;

  /// What it takes to open a leg. Straight-in needs nothing.
  final X01InRule inRule;

  /// What it takes to finish a leg.
  final X01OutRule outRule;

  /// Best of this many legs.
  final int legsToPlay;

  /// Legs it takes to win: more than half of [legsToPlay].
  int get legsToWin => legsToWinFor(legsToPlay);

  /// Whether this format is more than a single leg.
  bool get isMultiLeg => legsToPlay > 1;

  /// Whether "best of" means what it says: two players, one of whom must take
  /// more than half.
  bool get isHeadToHead => playerIds.length == 2;

  /// How the format reads on screen.
  ///
  /// `BEST OF 5` head to head, because that is what darts calls it, and
  /// `FIRST TO 3` otherwise, because that is what is actually being played.
  String get formatLabel =>
      isHeadToHead ? 'BEST OF $legsToPlay' : 'FIRST TO $legsToWin';

  /// Seat that throws first in leg [legNumber]. See [startingSeatForLeg].
  int startingSeatFor(int legNumber) =>
      startingSeatForLeg(legNumber, playerIds.length);

  /// The rules for one leg of the match, with the throw rotated into place.
  GameConfig legConfig(int legNumber) => GameConfig(
    startScore: startScore,
    playerIds: playerIds,
    inRule: inRule,
    outRule: outRule,
    startingSeat: startingSeatFor(legNumber),
  );
}

/// Where a match stands, derived entirely from the legs already won.
///
/// The same idea as [foldLeg] one level up: nothing here is mutated or
/// counted incrementally, so undoing a checkout that had won a leg only means
/// folding a shorter list.
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

    // A winner who is not in the match cannot have won a leg of it. Nothing in
    // the app can produce one, but the winners come off stored rows, and a row
    // that disagrees with its own match is not allowed to decide it.
    if (!legsWon.containsKey(playerId)) continue;

    counted.add(playerId);
    legsWon[playerId] = legsWon[playerId]! + 1;
    if (legsWon[playerId]! >= config.legsToWin) winnerId = playerId;
  }

  return MatchState(
    config: config,
    legWinners: List<int>.unmodifiable(counted),
    legsWon: Map<int, int>.unmodifiable(legsWon),
    winnerId: winnerId,
  );
}
