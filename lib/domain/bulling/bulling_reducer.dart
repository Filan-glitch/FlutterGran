import '../segment.dart';
import '../x01/leg_state.dart' show dartsPerTurn;
import '../x01/thrown_dart.dart';
import 'bulling_config.dart';
import 'bulling_leg_state.dart';
import 'bulling_variant.dart';

/// Points a dart is worth in Bulling: 1 for the outer bull, [bullseyeValue]'s
/// points for the inner bull, 0 for anything else including a miss.
///
/// Exported for `computeBullingStats`, which re-derives the same figure per
/// dart to classify it rather than trusting a running total — the same
/// idiom `computeAtcStats` uses with `AtcStop.clears`.
int pointsFor(Segment? segment, BullseyeValue bullseyeValue) {
  if (segment == null) return 0;
  return switch (segment.ring) {
    Ring.outerBull => 1,
    Ring.innerBull => bullseyeValue.points,
    _ => 0,
  };
}

/// Replays a dart log under [config] and returns the resulting leg state.
///
/// This is the whole Bulling engine, structured like x01's `foldLeg` and
/// Around the Clock's `foldAroundTheClock`: a pure function of the log, so
/// undo is dropping the last dart and folding again.
BullingLegState foldBulling(BullingConfig config, List<ThrownDart> darts) {
  final score = <int, int>{for (final id in config.playerIds) id: 0};
  final turns = <BullingTurn>[];

  var playerIndex = 0;
  var turnDarts = <ThrownDart>[];
  var turnStart = 0;
  int? winnerId;

  for (final dart in darts) {
    // Darts logged after the leg is won cannot change anything.
    if (winnerId != null) break;

    final playerId = config.playerIds[playerIndex];
    turnDarts.add(dart);

    final total =
        score[playerId]! + pointsFor(dart.segment, config.bullseyeValue);
    score[playerId] = total;

    final won = total >= config.target;

    if (won || turnDarts.length == dartsPerTurn) {
      turns.add(
        BullingTurn(
          playerId: playerId,
          darts: List<ThrownDart>.unmodifiable(turnDarts),
          scoreBefore: turnStart,
          scoreAfter: total,
        ),
      );
      turnDarts = [];

      if (won) {
        winnerId = playerId;
      } else {
        playerIndex = (playerIndex + 1) % config.playerIds.length;
        turnStart = score[config.playerIds[playerIndex]]!;
      }
    }
  }

  return BullingLegState(
    config: config,
    darts: List<ThrownDart>.unmodifiable(darts),
    score: Map<int, int>.unmodifiable(score),
    currentPlayerIndex: playerIndex,
    currentTurnDarts: List<ThrownDart>.unmodifiable(turnDarts),
    turns: List<BullingTurn>.unmodifiable(turns),
    winnerId: winnerId,
  );
}

/// The state of a leg before anyone has thrown.
BullingLegState initialBullingLegState(BullingConfig config) =>
    foldBulling(config, const []);
