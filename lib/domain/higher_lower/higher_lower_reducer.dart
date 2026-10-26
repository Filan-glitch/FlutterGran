import '../segment.dart';
import '../x01/leg_state.dart' show dartsPerTurn;
import '../x01/thrown_dart.dart';
import 'higher_lower_config.dart';
import 'higher_lower_leg_state.dart';

/// Points a dart is worth in Higher/Lower, or null for a miss.
///
/// Every segment scores its usual value except treble 1, which counts as 0 -
/// the one way to bring a turn in under 3. A miss is null rather than 0
/// because it is not a low score: it ends the turn and puts the player out.
///
/// Exported for `computeHigherLowerStats` and the game screen's ledger, which
/// total darts the same way the engine does.
int? pointsFor(Segment? segment) {
  if (segment == null) return null;
  if (segment.number == 1 && segment.ring == Ring.triple) return 0;
  return segment.value;
}

/// Replays a dart log under [config] and returns the resulting leg state.
///
/// This is the whole Higher/Lower engine, structured like Bulling's
/// `foldBulling`: a pure function of the log, so undo is dropping the last
/// dart and folding again.
HigherLowerLegState foldHigherLower(
  HigherLowerConfig config,
  List<ThrownDart> darts,
) {
  final eliminated = <int>[];
  final turns = <HigherLowerTurn>[];

  var higher = HigherLowerConfig.startHigher;
  var lower = HigherLowerConfig.startLower;
  var playerIndex = 0;
  var turnDarts = <ThrownDart>[];
  var total = 0;
  int? winnerId;

  for (final dart in darts) {
    // Darts logged after the leg is won cannot change anything.
    if (winnerId != null) break;

    turnDarts.add(dart);
    final points = pointsFor(dart.segment);
    if (points != null) total += points;

    final HigherLowerOutcome outcome;
    if (points == null) {
      outcome = HigherLowerOutcome.missed;
    } else if (turnDarts.length < dartsPerTurn) {
      continue;
    } else if (total > higher) {
      outcome = HigherLowerOutcome.higher;
    } else if (total < lower) {
      outcome = HigherLowerOutcome.lower;
    } else {
      outcome = HigherLowerOutcome.between;
    }

    final playerId = config.playerIds[playerIndex];
    turns.add(
      HigherLowerTurn(
        playerId: playerId,
        darts: List<ThrownDart>.unmodifiable(turnDarts),
        higherBefore: higher,
        lowerBefore: lower,
        total: total,
        outcome: outcome,
      ),
    );

    switch (outcome) {
      case HigherLowerOutcome.higher:
        higher = total;
      case HigherLowerOutcome.lower:
        lower = total;
      case HigherLowerOutcome.missed || HigherLowerOutcome.between:
        eliminated.add(playerId);
    }

    turnDarts = [];
    total = 0;

    final standing = [
      for (final id in config.playerIds)
        if (!eliminated.contains(id)) id,
    ];
    if (standing.length == 1) {
      winnerId = standing.single;
      continue;
    }

    do {
      playerIndex = (playerIndex + 1) % config.playerIds.length;
    } while (eliminated.contains(config.playerIds[playerIndex]));
  }

  return HigherLowerLegState(
    config: config,
    darts: List<ThrownDart>.unmodifiable(darts),
    higher: higher,
    lower: lower,
    eliminated: List<int>.unmodifiable(eliminated),
    currentPlayerIndex: playerIndex,
    currentTurnDarts: List<ThrownDart>.unmodifiable(turnDarts),
    turns: List<HigherLowerTurn>.unmodifiable(turns),
    winnerId: winnerId,
  );
}

/// The state of a leg before anyone has thrown.
HigherLowerLegState initialHigherLowerLegState(HigherLowerConfig config) =>
    foldHigherLower(config, const []);
