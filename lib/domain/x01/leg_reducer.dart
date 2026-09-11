import 'game_config.dart';
import 'leg_state.dart';
import 'thrown_dart.dart';
import 'x01_rules.dart';

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
  final opened = <int>{};

  var playerIndex = config.startingSeat;
  var turnDarts = <ThrownDart>[];
  var turnStart = config.startScore;
  int? winnerId;

  for (final dart in darts) {
    // Darts logged after the leg is won cannot change anything.
    if (winnerId != null) break;

    final playerId = config.playerIds[playerIndex];
    turnDarts.add(dart);

    // Before opening under double/master-in, a dart that doesn't qualify
    // scores nothing; one that does both opens the leg and scores, the same
    // way a real double-in dart gets a player "in" even if it's their only
    // dart to land. Once open, every dart scores normally.
    final alreadyOpen =
        config.inRule == X01InRule.straight || opened.contains(playerId);
    if (!alreadyOpen && dart.opensUnder(config.inRule)) {
      opened.add(playerId);
    }
    final effectiveValue = (alreadyOpen || opened.contains(playerId))
        ? dart.value
        : 0;

    final candidate = remaining[playerId]! - effectiveValue;

    // A turn busts by overshooting, by landing exactly on zero without the
    // required finish, or by leaving 1 - which nothing but straight-out can
    // finish.
    var busted = false;
    var won = false;
    if (candidate < 0) {
      busted = true;
    } else if (candidate == 0) {
      if (!dart.checksOutUnder(config.outRule)) {
        busted = true;
      } else {
        won = true;
      }
    } else if (candidate == 1 && config.outRule != X01OutRule.straight) {
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
    openedPlayerIds: Set<int>.unmodifiable(opened),
  );
}

/// The state of a leg before anyone has thrown.
LegState initialLegState(GameConfig config) => foldLeg(config, const []);
