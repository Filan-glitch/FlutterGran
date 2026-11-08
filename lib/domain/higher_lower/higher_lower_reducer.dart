import '../x01/leg_reducer.dart' show foldLeg;
import '../x01/leg_state.dart' show dartsPerTurn;
import '../x01/thrown_dart.dart';
import 'higher_lower_config.dart';
import 'higher_lower_leg_state.dart';
import 'higher_lower_scoring.dart';

/// The Higher/Lower engine: replays a dart log under [config], the same way
/// [foldLeg] does for x01.
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
    final points = higherLowerPointsFor(dart.segment);
    if (points != null) total += points;

    final HigherLowerOutcome outcome;
    if (points == null) {
      outcome = HigherLowerOutcome.missed;
    } else if (turnDarts.length < dartsPerTurn) {
      // The turn is not over yet: only a miss or the third dart decides it.
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

    // Next seat round the table, skipping anyone already out. At least two
    // players are still in here, so this always stops.
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
