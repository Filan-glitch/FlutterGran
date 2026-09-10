import '../atc/atc_leg_state.dart';
import '../atc/atc_stop.dart';
import '../bulling/bulling_leg_state.dart';
import '../bulling/bulling_reducer.dart';
import '../game_mode.dart';
import '../segment.dart';
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
/// [x01Legs]/[x01Matches]/[atcLegs] are legs and matches the caller already
/// knows belong to that mode - `LegState`/`AtcLegState` carry no mode field
/// of their own, because each is one engine's own state. Grouping by mode
/// happens one level up, where the rows are loaded from a `gameMode` column;
/// this function only composes the per-mode calculators. A third mode adds a
/// third parameter (pair) and a third entry here, not a rewrite of this one.
Map<GameMode, ModeStats> computePlayerStats(
  int playerId, {
  Iterable<LegState> x01Legs = const [],
  Iterable<MatchState> x01Matches = const [],
  Iterable<AtcLegState> atcLegs = const [],
  Iterable<BullingLegState> bullingLegs = const [],
}) {
  return {
    GameMode.x01: computeX01Stats(playerId, x01Legs, matches: x01Matches),
    GameMode.aroundTheClock: computeAtcStats(playerId, atcLegs),
    GameMode.bulling: computeBullingStats(playerId, bullingLegs),
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

/// Aggregates a player's Around the Clock record across any number of
/// replayed legs.
///
/// Takes folded [AtcLegState]s rather than raw rows, for the same reason
/// [computeX01Stats] does: every number here agrees with what was shown
/// during play by construction.
AtcStats computeAtcStats(int playerId, Iterable<AtcLegState> legs) {
  var legsPlayed = 0;
  var legsWon = 0;
  var dartsThrown = 0;
  var qualifyingDarts = 0;
  int? fewestDartsToWin;
  final perStop = <AtcStop, ({int attempts, int hits})>{};

  for (final leg in legs) {
    if (!leg.config.playerIds.contains(playerId)) continue;
    legsPlayed++;

    for (final turn in leg.turns) {
      if (turn.playerId != playerId) continue;

      // Walk the turn dart by dart, re-deriving which stop was standing
      // before each one - the same idiom `computeX01Stats` uses to re-derive
      // "on a finish" for `dartsAtDouble`.
      var standing = turn.stopBefore;
      for (final dart in turn.darts) {
        dartsThrown++;
        if (standing >= AtcStop.track.length) continue;

        final target = AtcStop.track[standing];
        final segment = dart.segment;
        final cleared =
            segment != null && target.clears(segment, leg.config.variant);

        final current = perStop[target] ?? (attempts: 0, hits: 0);
        perStop[target] = (
          attempts: current.attempts + 1,
          hits: current.hits + (cleared ? 1 : 0),
        );

        if (cleared) {
          qualifyingDarts++;
          standing++;
        }
      }
    }

    if (leg.winnerId == playerId) {
      legsWon++;
      final darts = leg.dartsThrownBy(playerId);
      if (fewestDartsToWin == null || darts < fewestDartsToWin) {
        fewestDartsToWin = darts;
      }
    }
  }

  return AtcStats(
    legsPlayed: legsPlayed,
    legsWon: legsWon,
    dartsThrown: dartsThrown,
    qualifyingDarts: qualifyingDarts,
    fewestDartsToWin: fewestDartsToWin,
    perStop: Map.unmodifiable(perStop),
  );
}

/// Aggregates a player's Bulling record across any number of replayed
/// legs.
///
/// Takes folded [BullingLegState]s rather than raw rows, for the same
/// reason [computeX01Stats] and [computeAtcStats] do: every number here
/// agrees with what was shown during play by construction.
BullingStats computeBullingStats(int playerId, Iterable<BullingLegState> legs) {
  var legsPlayed = 0;
  var legsWon = 0;
  var dartsThrown = 0;
  var scoringDarts = 0;
  var pointsScored = 0;
  var outerBullHits = 0;
  var innerBullHits = 0;
  int? fewestDartsToWin;

  for (final leg in legs) {
    if (!leg.config.playerIds.contains(playerId)) continue;
    legsPlayed++;

    for (final turn in leg.turns) {
      if (turn.playerId != playerId) continue;

      for (final dart in turn.darts) {
        dartsThrown++;
        final points = pointsFor(dart.segment, leg.config.bullseyeValue);
        pointsScored += points;
        if (dart.segment?.ring == Ring.outerBull) outerBullHits++;
        if (dart.segment?.ring == Ring.innerBull) innerBullHits++;
        if (points > 0) scoringDarts++;
      }
    }

    if (leg.winnerId == playerId) {
      legsWon++;
      final darts = leg.dartsThrownBy(playerId);
      if (fewestDartsToWin == null || darts < fewestDartsToWin) {
        fewestDartsToWin = darts;
      }
    }
  }

  return BullingStats(
    legsPlayed: legsPlayed,
    legsWon: legsWon,
    dartsThrown: dartsThrown,
    scoringDarts: scoringDarts,
    pointsScored: pointsScored,
    outerBullHits: outerBullHits,
    innerBullHits: innerBullHits,
    fewestDartsToWin: fewestDartsToWin,
  );
}
