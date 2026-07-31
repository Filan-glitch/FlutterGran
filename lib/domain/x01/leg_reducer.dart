import 'game_config.dart';
import 'leg_state.dart';
import 'thrown_dart.dart';

/// Replays a dart log under [config] and returns the resulting leg state.
///
/// This is the whole x01 engine. It is a pure function of the log, which is what
/// makes undo trivial - drop the last dart and fold again - and what lets the
/// same code reconstruct any historical leg from the database.
LegState foldLeg(GameConfig config, List<ThrownDart> darts) {
  final remaining = <int, int>{
    for (final id in config.playerIds) id: config.startScore,
  };
  final turns = <Turn>[];

  var playerIndex = 0;
  var turnDarts = <ThrownDart>[];
  var turnStart = config.startScore;
  int? winnerId;

  for (final dart in darts) {
    // Darts logged after the leg is won cannot change anything.
    if (winnerId != null) break;

    final playerId = config.playerIds[playerIndex];
    turnDarts.add(dart);

    final candidate = remaining[playerId]! - dart.value;

    // A turn busts by overshooting, by landing exactly on zero without the
    // required double, or by leaving 1 - which no double can finish.
    var busted = false;
    var won = false;
    if (candidate < 0) {
      busted = true;
    } else if (candidate == 0) {
      if (config.doubleOut && !dart.isDouble) {
        busted = true;
      } else {
        won = true;
      }
    } else if (candidate == 1 && config.doubleOut) {
      busted = true;
    }

    remaining[playerId] = busted ? turnStart : candidate;

    if (busted || won || turnDarts.length == dartsPerTurn) {
      turns.add(
        Turn(
          playerId: playerId,
          darts: List<ThrownDart>.unmodifiable(turnDarts),
          scoreBefore: turnStart,
          scoreAfter: remaining[playerId]!,
          busted: busted,
        ),
      );
      turnDarts = [];

      if (won) {
        winnerId = playerId;
      } else {
        playerIndex = (playerIndex + 1) % config.playerIds.length;
        turnStart = remaining[config.playerIds[playerIndex]]!;
      }
    }
  }

  return LegState(
    config: config,
    darts: List<ThrownDart>.unmodifiable(darts),
    remaining: Map<int, int>.unmodifiable(remaining),
    currentPlayerIndex: playerIndex,
    currentTurnDarts: List<ThrownDart>.unmodifiable(turnDarts),
    turns: List<Turn>.unmodifiable(turns),
    winnerId: winnerId,
  );
}

/// The state of a leg before anyone has thrown.
LegState initialLegState(GameConfig config) => foldLeg(config, const []);
