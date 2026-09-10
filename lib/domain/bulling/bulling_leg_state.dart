import '../x01/leg_state.dart' show dartsPerTurn;
import '../x01/thrown_dart.dart';
import 'bulling_config.dart';

/// A completed turn in a Bulling leg.
///
/// A turn ends after three darts or on the winning dart — so [darts] may
/// hold fewer than three. Unlike x01's `Turn`, nothing here busts: every
/// dart either scores its points or scores zero.
class BullingTurn {
  const BullingTurn({
    required this.playerId,
    required this.darts,
    required this.scoreBefore,
    required this.scoreAfter,
  });

  final int playerId;
  final List<ThrownDart> darts;

  /// Points the player had when the turn started.
  final int scoreBefore;

  /// Points the turn left them on. Never less than [scoreBefore] — nothing
  /// in this mode can take points away.
  final int scoreAfter;

  /// Points earned this turn.
  int get scored => scoreAfter - scoreBefore;

  @override
  String toString() =>
      'BullingTurn(p$playerId, ${darts.join(' ')}, '
      '$scoreBefore->$scoreAfter)';
}

/// Everything derivable about a Bulling leg, produced entirely by folding
/// the dart log — the same idea as x01's `LegState` and Around the Clock's
/// `AtcLegState`.
///
/// Never mutated and never constructed by hand outside the reducer: undoing
/// a dart means dropping it from the log and folding again.
class BullingLegState {
  const BullingLegState({
    required this.config,
    required this.darts,
    required this.score,
    required this.currentPlayerIndex,
    required this.currentTurnDarts,
    required this.turns,
    required this.winnerId,
  });

  final BullingConfig config;

  /// The full ordered log this state was folded from.
  final List<ThrownDart> darts;

  /// Points scored so far, per player id.
  final Map<int, int> score;

  /// Seat whose turn it is. Meaningless once the leg is finished.
  final int currentPlayerIndex;

  /// Darts thrown so far in the turn in progress.
  final List<ThrownDart> currentTurnDarts;

  /// Turns already completed, in order.
  final List<BullingTurn> turns;

  /// Winner, or null while the leg is still running.
  final int? winnerId;

  int get currentPlayerId => config.playerIds[currentPlayerIndex];

  /// Points a player has scored so far.
  int scoreFor(int playerId) => score[playerId]!;

  int get dartsThrownThisTurn => currentTurnDarts.length;

  int get dartsLeftThisTurn => dartsPerTurn - currentTurnDarts.length;

  bool get isFinished => winnerId != null;

  /// The most recently completed turn, or null before the first one ends.
  BullingTurn? get lastTurn => turns.isEmpty ? null : turns.last;

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
