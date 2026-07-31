import 'game_config.dart';
import 'thrown_dart.dart';

/// Darts in a turn.
const int dartsPerTurn = 3;

/// A completed turn.
///
/// A turn ends after three darts, on a bust, or on a checkout - so [darts] may
/// hold fewer than three.
class Turn {
  const Turn({
    required this.playerId,
    required this.darts,
    required this.scoreBefore,
    required this.scoreAfter,
    required this.busted,
  });

  final int playerId;
  final List<ThrownDart> darts;

  /// Score the player was on when the turn started.
  final int scoreBefore;

  /// Score the player was left on. Equal to [scoreBefore] when [busted].
  final int scoreAfter;

  final bool busted;

  /// Points credited for the turn. Zero on a bust.
  int get scored => scoreBefore - scoreAfter;

  @override
  String toString() =>
      'Turn(p$playerId, ${darts.join(' ')}, '
      '$scoreBefore->$scoreAfter${busted ? ' BUST' : ''})';
}

/// Everything derivable about a leg, produced entirely by folding the dart log.
///
/// This type is never mutated and never constructed by hand outside the
/// reducer: undoing a dart means dropping it from the log and folding again.
class LegState {
  const LegState({
    required this.config,
    required this.darts,
    required this.remaining,
    required this.currentPlayerIndex,
    required this.currentTurnDarts,
    required this.turns,
    required this.winnerId,
  });

  final GameConfig config;

  /// The full ordered log this state was folded from.
  final List<ThrownDart> darts;

  /// Points left, per player id.
  final Map<int, int> remaining;

  /// Seat whose turn it is. Meaningless once the leg is finished.
  final int currentPlayerIndex;

  /// Darts thrown so far in the turn in progress.
  final List<ThrownDart> currentTurnDarts;

  /// Turns already completed, in order.
  final List<Turn> turns;

  /// Winner, or null while the leg is still running.
  final int? winnerId;

  int get currentPlayerId => config.playerIds[currentPlayerIndex];

  /// Points the player to throw still needs.
  int get currentRemaining => remaining[currentPlayerId]!;

  int get dartsThrownThisTurn => currentTurnDarts.length;

  int get dartsLeftThisTurn => dartsPerTurn - currentTurnDarts.length;

  bool get isFinished => winnerId != null;

  /// The most recently completed turn, or null before the first one ends.
  Turn? get lastTurn => turns.isEmpty ? null : turns.last;

  /// Total darts a player has thrown in this leg, including the turn in
  /// progress. This is the denominator of their three-dart average.
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

  /// Points a player has actually scored in this leg, busts excluded.
  int scoredBy(int playerId) => config.startScore - remaining[playerId]!;

  /// Three-dart average, or null before the player has thrown anything.
  double? averageFor(int playerId) {
    final thrown = dartsThrownBy(playerId);
    if (thrown == 0) return null;
    return scoredBy(playerId) / thrown * dartsPerTurn;
  }
}
