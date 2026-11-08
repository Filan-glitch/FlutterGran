import '../segment.dart';
import '../x01/leg_reducer.dart' show foldLeg;
import '../x01/leg_state.dart' show dartsPerTurn;
import '../x01/thrown_dart.dart';
import 'bulling_config.dart';
import 'bulling_leg_state.dart';
import 'bulling_variant.dart';

/// Points a dart is worth in Bulling: 1 for the outer bull, [bullseyeValue]'s
/// points for the inner bull, 0 for anything else including a miss.
///
/// Public so the stats and the game screen total darts the same way the
/// engine does.
int bullingPointsFor(Segment? segment, BullseyeValue bullseyeValue) {
  if (segment == null) return 0;
  return switch (segment.ring) {
    Ring.outerBull => 1,
    Ring.innerBull => bullseyeValue.points,
    _ => 0,
  };
}

/// The Bulling engine: replays a dart log under [config], the same way
/// [foldLeg] does for x01.
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
        score[playerId]! + bullingPointsFor(dart.segment, config.bullseyeValue);
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
