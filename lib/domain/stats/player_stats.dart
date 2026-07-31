import '../x01/leg_state.dart';

/// Whether a score can be finished with a single dart at a double.
///
/// This is the definition behind "darts at double": a dart only counts as an
/// attempt if the player was actually on a finish when they threw it.
bool isOneDartFinish(int score) =>
    score == 50 || (score.isEven && score >= 2 && score <= 40);

/// Everything the stats screens show for one player.
class PlayerStats {
  const PlayerStats({
    required this.legsPlayed,
    required this.legsWon,
    required this.dartsThrown,
    required this.pointsScored,
    required this.bestTurn,
    required this.turnsOf180,
    required this.turnsOf140Plus,
    required this.turnsOf100Plus,
    required this.turnsOf60Plus,
    required this.dartsAtDouble,
    required this.doublesHit,
    required this.bestCheckout,
    required this.fewestDartsToWin,
    required this.firstNinePoints,
    required this.firstNineDarts,
  });

  static const PlayerStats empty = PlayerStats(
    legsPlayed: 0,
    legsWon: 0,
    dartsThrown: 0,
    pointsScored: 0,
    bestTurn: 0,
    turnsOf180: 0,
    turnsOf140Plus: 0,
    turnsOf100Plus: 0,
    turnsOf60Plus: 0,
    dartsAtDouble: 0,
    doublesHit: 0,
    bestCheckout: null,
    fewestDartsToWin: null,
    firstNinePoints: 0,
    firstNineDarts: 0,
  );

  final int legsPlayed;
  final int legsWon;
  final int dartsThrown;

  /// Points that survived - a busted turn contributes nothing.
  final int pointsScored;

  final int bestTurn;
  final int turnsOf180;
  final int turnsOf140Plus;
  final int turnsOf100Plus;
  final int turnsOf60Plus;

  /// Darts thrown while on a finish.
  final int dartsAtDouble;

  /// Of those, the ones that won the leg.
  final int doublesHit;

  /// Highest score ever checked out from.
  final int? bestCheckout;

  /// Fewest darts taken to win a leg.
  final int? fewestDartsToWin;

  final int firstNinePoints;
  final int firstNineDarts;

  /// Three-dart average, or null before anything has been thrown.
  double? get average =>
      dartsThrown == 0 ? null : pointsScored / dartsThrown * dartsPerTurn;

  /// Average over the opening three turns of each leg, which separates scoring
  /// power from finishing ability.
  double? get firstNineAverage => firstNineDarts == 0
      ? null
      : firstNinePoints / firstNineDarts * dartsPerTurn;

  /// Share of darts at a double that actually won the leg, 0 to 1.
  double? get checkoutRate =>
      dartsAtDouble == 0 ? null : doublesHit / dartsAtDouble;

  double? get winRate => legsPlayed == 0 ? null : legsWon / legsPlayed;
}

/// Aggregates a player's record across any number of replayed legs.
///
/// Takes folded [LegState]s rather than raw rows, so every number here agrees
/// with what was shown during play by construction.
PlayerStats computePlayerStats(int playerId, Iterable<LegState> legs) {
  var legsPlayed = 0;
  var legsWon = 0;
  var dartsThrown = 0;
  var pointsScored = 0;
  var bestTurn = 0;
  var turnsOf180 = 0;
  var turnsOf140Plus = 0;
  var turnsOf100Plus = 0;
  var turnsOf60Plus = 0;
  var dartsAtDouble = 0;
  var doublesHit = 0;
  int? bestCheckout;
  int? fewestDartsToWin;
  var firstNinePoints = 0;
  var firstNineDarts = 0;

  for (final leg in legs) {
    if (!leg.config.playerIds.contains(playerId)) continue;
    legsPlayed++;

    var turnIndex = 0;
    for (final turn in leg.turns) {
      if (turn.playerId != playerId) continue;

      dartsThrown += turn.darts.length;
      pointsScored += turn.scored;
      if (turn.scored > bestTurn) bestTurn = turn.scored;

      if (turn.scored == 180) turnsOf180++;
      if (turn.scored >= 140) turnsOf140Plus++;
      if (turn.scored >= 100) turnsOf100Plus++;
      if (turn.scored >= 60) turnsOf60Plus++;

      if (turnIndex < 3) {
        firstNinePoints += turn.scored;
        firstNineDarts += turn.darts.length;
      }

      if (leg.config.doubleOut) {
        // Walk the turn dart by dart. A dart counts as an attempt only if the
        // score standing before it could be finished by one double.
        var standing = turn.scoreBefore;
        for (final dart in turn.darts) {
          if (isOneDartFinish(standing)) dartsAtDouble++;
          if (dart.isDouble && standing - dart.value == 0) doublesHit++;
          standing -= dart.value;
        }
      }

      turnIndex++;
    }

    if (leg.winnerId == playerId) {
      legsWon++;

      final winningTurn = leg.turns.lastWhere(
        (turn) => turn.playerId == playerId,
      );
      if (bestCheckout == null || winningTurn.scoreBefore > bestCheckout) {
        bestCheckout = winningTurn.scoreBefore;
      }

      final darts = leg.dartsThrownBy(playerId);
      if (fewestDartsToWin == null || darts < fewestDartsToWin) {
        fewestDartsToWin = darts;
      }
    }
  }

  return PlayerStats(
    legsPlayed: legsPlayed,
    legsWon: legsWon,
    dartsThrown: dartsThrown,
    pointsScored: pointsScored,
    bestTurn: bestTurn,
    turnsOf180: turnsOf180,
    turnsOf140Plus: turnsOf140Plus,
    turnsOf100Plus: turnsOf100Plus,
    turnsOf60Plus: turnsOf60Plus,
    dartsAtDouble: dartsAtDouble,
    doublesHit: doublesHit,
    bestCheckout: bestCheckout,
    fewestDartsToWin: fewestDartsToWin,
    firstNinePoints: firstNinePoints,
    firstNineDarts: firstNineDarts,
  );
}
