import '../x01/leg_state.dart' show dartsPerTurn;
import '../x01/thrown_dart.dart';
import 'atc_config.dart';
import 'atc_stop.dart';

/// A completed turn in an Around the Clock leg.
///
/// A turn ends after three darts or on the winning dart - so [darts] may
/// hold fewer than three. Unlike x01's `Turn`, nothing here busts: a dart
/// either clears the current stop or does nothing.
class AtcTurn {
  const AtcTurn({
    required this.playerId,
    required this.darts,
    required this.stopBefore,
    required this.stopAfter,
  });

  final int playerId;
  final List<ThrownDart> darts;

  /// Track index (0-21) the player was on when the turn started.
  final int stopBefore;

  /// Track index the turn left them on. Equal to [stopBefore] when nothing
  /// in the turn cleared anything.
  final int stopAfter;

  /// How many stops this turn cleared.
  int get stopsCleared => stopAfter - stopBefore;

  @override
  String toString() => 'AtcTurn(p$playerId, ${darts.join(' ')}, '
      '$stopBefore->$stopAfter)';
}

/// Everything derivable about an Around the Clock leg, produced entirely by
/// folding the dart log - the same idea as x01's `LegState`.
///
/// Never mutated and never constructed by hand outside the reducer: undoing
/// a dart means dropping it from the log and folding again.
class AtcLegState {
  const AtcLegState({
    required this.config,
    required this.darts,
    required this.stopIndex,
    required this.currentPlayerIndex,
    required this.currentTurnDarts,
    required this.turns,
    required this.winnerId,
  });

  final AtcConfig config;

  /// The full ordered log this state was folded from.
  final List<ThrownDart> darts;

  /// Track index (0-21) each player has reached, per player id.
  final Map<int, int> stopIndex;

  /// Seat whose turn it is. Meaningless once the leg is finished.
  final int currentPlayerIndex;

  /// Darts thrown so far in the turn in progress.
  final List<ThrownDart> currentTurnDarts;

  /// Turns already completed, in order.
  final List<AtcTurn> turns;

  /// Winner, or null while the leg is still running.
  final int? winnerId;

  int get currentPlayerId => config.playerIds[currentPlayerIndex];

  /// The stop a player still needs to clear.
  ///
  /// Clamped to the last stop for a player who has already finished, so a
  /// winner reads as "on the bullseye" rather than indexing past the track.
  AtcStop currentStopFor(int playerId) =>
      AtcStop.track[stopIndex[playerId]!.clamp(0, AtcStop.track.length - 1)];

  int get dartsThrownThisTurn => currentTurnDarts.length;

  int get dartsLeftThisTurn => dartsPerTurn - currentTurnDarts.length;

  bool get isFinished => winnerId != null;

  /// The most recently completed turn, or null before the first one ends.
  AtcTurn? get lastTurn => turns.isEmpty ? null : turns.last;

  /// Total darts a player has thrown in this leg, including the turn in
  /// progress.
  int dartsThrownBy(int playerId) {
    var total = 0;
    for (final turn in turns) {
      if (turn.playerId == playerId) total += turn.darts.length;
    }
    if (!isFinished && currentPlayerId == playerId) {
      total += currentTurnDarts.length;
    }
    return total;
  }
}
