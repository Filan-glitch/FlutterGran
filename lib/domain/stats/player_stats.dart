import '../game_mode.dart';
import '../x01/leg_state.dart';
import '../x01/match_state.dart';
import 'mode_stats.dart';

export 'mode_stats.dart';

/// Whether a score can be finished with a single dart at a double.
///
/// This is the definition behind "darts at double": a dart only counts as an
/// attempt if the player was actually on a finish when they threw it.
bool isOneDartFinish(int score) =>
    score == 50 || (score.isEven && score >= 2 && score <= 40);

/// A player's whole record, one entry per mode they have ever played.
///
/// [x01Legs]/[x01Matches] are legs and matches the caller already knows are
/// x01 - `LegState` itself carries no mode field, because it is the x01
/// engine's own state and nothing else uses it. Grouping by mode happens one
/// level up, where the rows are loaded from a `gameMode` column; this
/// function only composes the per-mode calculators. A second mode adds a
/// second parameter pair and a second entry here, not a rewrite of this one.
Map<GameMode, ModeStats> computePlayerStats(
  int playerId, {
  Iterable<LegState> x01Legs = const [],
  Iterable<MatchState> x01Matches = const [],
}) {
  return {
    GameMode.x01: computeX01Stats(playerId, x01Legs, matches: x01Matches),
  };
}

/// Aggregates a player's x01 record across any number of replayed legs.
///
/// Takes folded [LegState]s rather than raw rows, so every number here agrees
/// with what was shown during play by construction.
///
/// [matches] is separate because a match is not derivable from a pile of legs:
/// legs carry no record of which match they belonged to. Callers that only care
/// about the throwing figures can leave it off.
X01Stats computeX01Stats(
  int playerId,
  Iterable<LegState> legs, {
  Iterable<MatchState> matches = const [],
}) {
  var legsPlayed = 0;
  var legsWon = 0;
  var matchesPlayed = 0;
  var matchesWon = 0;
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

  for (final match in matches) {
    if (!match.config.playerIds.contains(playerId)) continue;
    matchesPlayed++;
    if (match.winnerId == playerId) matchesWon++;
  }

  return X01Stats(
    legsPlayed: legsPlayed,
    legsWon: legsWon,
    matchesPlayed: matchesPlayed,
    matchesWon: matchesWon,
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
