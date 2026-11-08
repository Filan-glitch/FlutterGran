/// Aggregates a player's replayed legs into their all-time record, one
/// [ModeStats] per [GameMode], for the statistics screen.
///
/// {@category Domain}
library;

import '../atc/atc_leg_state.dart';
import '../atc/atc_stop.dart';
import '../bulling/bulling_leg_state.dart';
import '../bulling/bulling_reducer.dart';
import '../checkout/checkout_search.dart';
import '../checkout/checkout_table.dart';
import '../game_mode.dart';
import '../higher_lower/higher_lower_leg_state.dart';
import '../segment.dart';
import '../x01/leg_state.dart';
import '../x01/match_state.dart';
import '../x01/x01_rules.dart';
import 'mode_stats.dart';

export 'dated.dart';
export 'mode_stats.dart';

/// One memoised checkout table per out-rule, for "could this visit finish?".
final Map<X01OutRule, CheckoutTable> _checkoutTables = {
  for (final rule in X01OutRule.values)
    rule: CheckoutTable(limit: 1, outRule: rule),
};

/// Whether [score] can be finished within one visit of three darts under
/// [outRule] - the definition behind "visits at a finish".
bool isFinishableInOneVisit(int score, X01OutRule outRule) =>
    _checkoutTables[outRule]!.bestFor(score, dartsPerTurn) != null;

/// Whether [score] can be finished with a single dart, under [outRule].
///
/// This is the definition behind "darts at a finish": a dart only counts as
/// an attempt if the player was actually on a finish when they threw it.
bool isOneDartFinishFor(int score, X01OutRule outRule) => Segment.all.any(
  (segment) => segment.value == score && outRule.checksOut(segment),
);

/// A player's whole record, one entry per [GameMode].
///
/// Each parameter holds legs (or matches) the caller already knows belong to
/// that mode: the leg states carry no mode field, so grouping by mode happens
/// where the rows are loaded from their `gameMode` column. This only composes
/// the per-mode calculators.
Map<GameMode, ModeStats> computePlayerStats(
  int playerId, {
  Iterable<LegState> x01Legs = const [],
  Iterable<MatchState> x01Matches = const [],
  Iterable<AtcLegState> atcLegs = const [],
  Iterable<BullingLegState> bullingLegs = const [],
  Iterable<HigherLowerLegState> higherLowerLegs = const [],
}) {
  return {
    GameMode.x01: computeX01Stats(playerId, x01Legs, matches: x01Matches),
    GameMode.aroundTheClock: computeAtcStats(playerId, atcLegs),
    GameMode.bulling: computeBullingStats(playerId, bullingLegs),
    GameMode.higherLower: computeHigherLowerStats(playerId, higherLowerLegs),
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
  final dartsAtFinishByRule = <X01OutRule, int>{};
  final finishesHitByRule = <X01OutRule, int>{};
  int? bestCheckout;
  int? fewestDartsToWin;
  var firstNinePoints = 0;
  var firstNineDarts = 0;
  var legsFinished = 0;
  var scoringPoints = 0;
  var scoringDarts = 0;
  var scoringTrebles = 0;
  var scoringVisitSquares = 0;
  final scoringVisitBands = List.filled(X01Stats.visitScoreBands.length, 0);
  final visitsAtFinishByRule = <X01OutRule, int>{};
  final visitsWonByRule = <X01OutRule, int>{};
  var tonPlusCheckouts = 0;
  final dartsToWinByStart = <int, List<int>>{};
  final legsFinishedByStart = <int, int>{};
  var legsOnThrow = 0;
  var legsWonOnThrow = 0;
  var legsAgainstThrow = 0;
  var legsWonAgainstThrow = 0;

  for (final leg in legs) {
    if (!leg.config.playerIds.contains(playerId)) continue;
    legsPlayed++;

    final start = leg.config.startScore;
    if (leg.isFinished) {
      legsFinished++;
      legsFinishedByStart[start] = (legsFinishedByStart[start] ?? 0) + 1;

      // Who threw first only means something against an opponent.
      if (leg.config.playerIds.length > 1) {
        final won = leg.winnerId == playerId;
        final seat = leg.config.playerIds.indexOf(playerId);
        if (seat == leg.config.startingSeat) {
          legsOnThrow++;
          if (won) legsWonOnThrow++;
        } else {
          legsAgainstThrow++;
          if (won) legsWonAgainstThrow++;
        }
      }
    }

    final outRule = leg.config.outRule;
    // Whether this player has opened yet, tracked across the leg the same
    // way the reducer does - only this player's own darts can change it, so
    // walking just their turns in order is enough to keep it in step.
    var playerOpened = leg.config.inRule == X01InRule.straight;

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

      // A scoring visit is one that could not have finished the leg, so no
      // dart in it was thrown at a finish - only complete visits count, a
      // leg abandoned mid-visit is not a three-dart score.
      if (turn.scoreBefore > maxCheckoutFor(outRule) &&
          turn.darts.length == dartsPerTurn) {
        scoringPoints += turn.scored;
        scoringDarts += turn.darts.length;
        scoringTrebles += turn.darts
            .where((dart) => dart.segment?.ring == Ring.triple)
            .length;
        scoringVisitBands[X01Stats.bandFor(turn.scored)]++;
        scoringVisitSquares += turn.scored * turn.scored;
      }

      // A visit at a finish: opened (or straight in), and on a score three
      // darts can check out. Won when it left the player on nothing.
      if (playerOpened && isFinishableInOneVisit(turn.scoreBefore, outRule)) {
        visitsAtFinishByRule[outRule] =
            (visitsAtFinishByRule[outRule] ?? 0) + 1;
        if (!turn.busted && turn.scoreAfter == 0) {
          visitsWonByRule[outRule] = (visitsWonByRule[outRule] ?? 0) + 1;
        }
      }

      // Walk the turn dart by dart, re-deriving each dart's effective value
      // the same way the reducer does - a dart before opening scores
      // nothing, so it must not be mistaken for a scoring attempt either. A
      // dart counts as a finish attempt only if the score standing before it
      // could actually be finished in one, under this leg's out-rule.
      var standing = turn.scoreBefore;
      for (final dart in turn.darts) {
        final effectiveValue = playerOpened
            ? dart.value
            : (dart.opensUnder(leg.config.inRule) ? dart.value : 0);
        playerOpened |= effectiveValue > 0;

        if (isOneDartFinishFor(standing, outRule)) {
          dartsAtFinishByRule[outRule] =
              (dartsAtFinishByRule[outRule] ?? 0) + 1;
        }
        if (dart.checksOutUnder(outRule) && standing - effectiveValue == 0) {
          finishesHitByRule[outRule] = (finishesHitByRule[outRule] ?? 0) + 1;
        }
        standing -= effectiveValue;
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
      if (winningTurn.scoreBefore >= 100) tonPlusCheckouts++;

      final darts = leg.dartsThrownBy(playerId);
      if (fewestDartsToWin == null || darts < fewestDartsToWin) {
        fewestDartsToWin = darts;
      }
      (dartsToWinByStart[start] ??= []).add(darts);
    }
  }

  for (final match in matches) {
    if (!match.config.playerIds.contains(playerId)) continue;
    matchesPlayed++;
    if (match.winnerId == playerId) matchesWon++;
  }

  final checkoutsByRule = <X01OutRule, ({int dartsAtFinish, int finishesHit})>{
    for (final rule in dartsAtFinishByRule.keys)
      rule: (
        dartsAtFinish: dartsAtFinishByRule[rule]!,
        finishesHit: finishesHitByRule[rule] ?? 0,
      ),
  };

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
    checkoutsByRule: checkoutsByRule,
    bestCheckout: bestCheckout,
    fewestDartsToWin: fewestDartsToWin,
    firstNinePoints: firstNinePoints,
    firstNineDarts: firstNineDarts,
    legsFinished: legsFinished,
    scoringPoints: scoringPoints,
    scoringDarts: scoringDarts,
    scoringTrebles: scoringTrebles,
    scoringVisitBands: List.unmodifiable(scoringVisitBands),
    scoringVisitSquares: scoringVisitSquares,
    checkoutVisitsByRule: {
      for (final rule in visitsAtFinishByRule.keys)
        rule: (
          visits: visitsAtFinishByRule[rule]!,
          won: visitsWonByRule[rule] ?? 0,
        ),
    },
    tonPlusCheckouts: tonPlusCheckouts,
    dartsToWinByStart: {
      for (final entry in dartsToWinByStart.entries)
        entry.key: List.unmodifiable(entry.value),
    },
    legsFinishedByStart: Map.unmodifiable(legsFinishedByStart),
    legsOnThrow: legsOnThrow,
    legsWonOnThrow: legsWonOnThrow,
    legsAgainstThrow: legsAgainstThrow,
    legsWonAgainstThrow: legsWonAgainstThrow,
  );
}

/// Aggregates a player's Around the Clock record across any number of
/// replayed legs.
///
/// Takes folded [AtcLegState]s; see [computeX01Stats].
AtcStats computeAtcStats(int playerId, Iterable<AtcLegState> legs) {
  var legsPlayed = 0;
  var legsWon = 0;
  var legsFinished = 0;
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
      // before each one, as computeX01Stats does for "on a finish".
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

    if (leg.isFinished) legsFinished++;
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
    legsFinished: legsFinished,
    dartsThrown: dartsThrown,
    qualifyingDarts: qualifyingDarts,
    fewestDartsToWin: fewestDartsToWin,
    perStop: Map.unmodifiable(perStop),
  );
}

/// Aggregates a player's Bulling record across any number of replayed
/// legs.
///
/// Takes folded [BullingLegState]s; see [computeX01Stats].
BullingStats computeBullingStats(int playerId, Iterable<BullingLegState> legs) {
  var legsPlayed = 0;
  var legsWon = 0;
  var legsFinished = 0;
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
        final points = bullingPointsFor(dart.segment, leg.config.bullseyeValue);
        pointsScored += points;
        if (dart.segment?.ring == Ring.outerBull) outerBullHits++;
        if (dart.segment?.ring == Ring.innerBull) innerBullHits++;
        if (points > 0) scoringDarts++;
      }
    }

    if (leg.isFinished) legsFinished++;
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
    legsFinished: legsFinished,
    dartsThrown: dartsThrown,
    scoringDarts: scoringDarts,
    pointsScored: pointsScored,
    outerBullHits: outerBullHits,
    innerBullHits: innerBullHits,
    fewestDartsToWin: fewestDartsToWin,
  );
}

/// Aggregates a player's Higher/Lower record across any number of replayed
/// legs.
///
/// Takes folded [HigherLowerLegState]s; see [computeX01Stats].
HigherLowerStats computeHigherLowerStats(
  int playerId,
  Iterable<HigherLowerLegState> legs,
) {
  var legsPlayed = 0;
  var legsWon = 0;
  var legsFinished = 0;
  var turnsPlayed = 0;
  var turnsSurvived = 0;
  var higherCalls = 0;
  var lowerCalls = 0;
  var dartsThrown = 0;
  var longestRun = 0;

  for (final leg in legs) {
    if (!leg.config.playerIds.contains(playerId)) continue;
    legsPlayed++;
    if (leg.isFinished) legsFinished++;
    if (leg.winnerId == playerId) legsWon++;

    for (final turn in leg.turns) {
      if (turn.playerId != playerId) continue;
      turnsPlayed++;
      dartsThrown += turn.darts.length;
      switch (turn.outcome) {
        case HigherLowerOutcome.higher:
          higherCalls++;
        case HigherLowerOutcome.lower:
          lowerCalls++;
        case HigherLowerOutcome.missed || HigherLowerOutcome.between:
          break;
      }
    }

    final survived = leg.turnsSurvivedBy(playerId);
    turnsSurvived += survived;
    if (survived > longestRun) longestRun = survived;
  }

  return HigherLowerStats(
    legsPlayed: legsPlayed,
    legsWon: legsWon,
    legsFinished: legsFinished,
    turnsPlayed: turnsPlayed,
    turnsSurvived: turnsSurvived,
    higherCalls: higherCalls,
    lowerCalls: lowerCalls,
    dartsThrown: dartsThrown,
    longestRun: longestRun,
  );
}
