import '../x01/leg_state.dart' show dartsPerTurn;
import '../x01/thrown_dart.dart';
import 'atc_config.dart';
import 'atc_leg_state.dart';
import 'atc_stop.dart';

/// Replays a dart log under [config] and returns the resulting leg state.
///
/// This is the whole Around the Clock engine, structured like x01's
/// `foldLeg`: a pure function of the log, so undo is dropping the last dart
/// and folding again, and the same code reconstructs any historical leg from
/// the database.
AtcLegState foldAroundTheClock(AtcConfig config, List<ThrownDart> darts) {
  final stopIndex = <int, int>{for (final id in config.playerIds) id: 0};
  final turns = <AtcTurn>[];

  var playerIndex = 0;
  var turnDarts = <ThrownDart>[];
  var turnStart = 0;
  int? winnerId;

  for (final dart in darts) {
    // Darts logged after the leg is won cannot change anything.
    if (winnerId != null) break;

    final playerId = config.playerIds[playerIndex];
    turnDarts.add(dart);

    var index = stopIndex[playerId]!;
    final segment = dart.segment;
    if (segment != null &&
        index < AtcStop.track.length &&
        AtcStop.track[index].clears(segment, config.variant)) {
      index++;
    }
    stopIndex[playerId] = index;

    final won = index == AtcStop.track.length;

    if (won || turnDarts.length == dartsPerTurn) {
      turns.add(
        AtcTurn(
          playerId: playerId,
          darts: List<ThrownDart>.unmodifiable(turnDarts),
          stopBefore: turnStart,
          stopAfter: index,
        ),
      );
      turnDarts = [];

      if (won) {
        winnerId = playerId;
      } else {
        playerIndex = (playerIndex + 1) % config.playerIds.length;
        turnStart = stopIndex[config.playerIds[playerIndex]]!;
      }
    }
  }

  return AtcLegState(
    config: config,
    darts: List<ThrownDart>.unmodifiable(darts),
    stopIndex: Map<int, int>.unmodifiable(stopIndex),
    currentPlayerIndex: playerIndex,
    currentTurnDarts: List<ThrownDart>.unmodifiable(turnDarts),
    turns: List<AtcTurn>.unmodifiable(turns),
    winnerId: winnerId,
  );
}

/// The state of a leg before anyone has thrown.
AtcLegState initialAtcLegState(AtcConfig config) =>
    foldAroundTheClock(config, const []);
