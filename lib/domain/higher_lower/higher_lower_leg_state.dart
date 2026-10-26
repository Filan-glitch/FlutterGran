import '../x01/leg_state.dart' show dartsPerTurn;
import '../x01/thrown_dart.dart';
import 'higher_lower_config.dart';
import 'higher_lower_reducer.dart' show pointsFor;

/// How a Higher/Lower turn ended.
enum HigherLowerOutcome {
  /// The total went over the higher value and replaced it.
  higher,

  /// The total went under the lower value and replaced it.
  lower,

  /// A dart missed the board. The turn ends on that dart.
  missed,

  /// Three darts landed but the total was neither over the higher value nor
  /// under the lower one - equalling either counts as neither.
  between;

  /// Whether the player stays in the leg after a turn ending like this.
  bool get survived => this == higher || this == lower;
}

/// A completed turn in a Higher/Lower leg.
///
/// Three darts, or fewer when one missed - a miss ends the turn on the spot.
class HigherLowerTurn {
  const HigherLowerTurn({
    required this.playerId,
    required this.darts,
    required this.higherBefore,
    required this.lowerBefore,
    required this.total,
    required this.outcome,
  });

  final int playerId;
  final List<ThrownDart> darts;

  /// The values the turn had to beat.
  final int higherBefore;
  final int lowerBefore;

  /// What the darts that landed scored, treble 1 counting as 0.
  final int total;

  final HigherLowerOutcome outcome;

  bool get survived => outcome.survived;

  @override
  String toString() =>
      'HigherLowerTurn(p$playerId, ${darts.join(' ')}, $total '
      'vs $lowerBefore/$higherBefore, ${outcome.name})';
}

/// Everything derivable about a Higher/Lower leg, produced entirely by
/// folding the dart log - the same idea as Bulling's `BullingLegState`.
///
/// Never mutated and never constructed by hand outside the reducer: undoing
/// a dart means dropping it from the log and folding again.
class HigherLowerLegState {
  const HigherLowerLegState({
    required this.config,
    required this.darts,
    required this.higher,
    required this.lower,
    required this.eliminated,
    required this.currentPlayerIndex,
    required this.currentTurnDarts,
    required this.turns,
    required this.winnerId,
  });

  final HigherLowerConfig config;

  /// The full ordered log this state was folded from.
  final List<ThrownDart> darts;

  /// The value the next turn has to go over.
  final int higher;

  /// The value the next turn has to go under.
  final int lower;

  /// Players who are out, in the order they went out.
  final List<int> eliminated;

  /// Seat whose turn it is. Meaningless once the leg is finished.
  final int currentPlayerIndex;

  /// Darts thrown so far in the turn in progress.
  final List<ThrownDart> currentTurnDarts;

  /// Turns already completed, in order.
  final List<HigherLowerTurn> turns;

  /// The last player standing, or null while the leg is still running.
  final int? winnerId;

  int get currentPlayerId => config.playerIds[currentPlayerIndex];

  bool isOut(int playerId) => eliminated.contains(playerId);

  /// Players still in, in seat order.
  List<int> get activePlayerIds => [
    for (final id in config.playerIds)
      if (!isOut(id)) id,
  ];

  int get dartsThrownThisTurn => currentTurnDarts.length;

  int get dartsLeftThisTurn => dartsPerTurn - currentTurnDarts.length;

  /// What the turn in progress has scored so far.
  int get runningTotal => currentTurnDarts.fold(
    0,
    (sum, dart) => sum + (pointsFor(dart.segment) ?? 0),
  );

  bool get isFinished => winnerId != null;

  /// The most recently completed turn, or null before the first one ends.
  HigherLowerTurn? get lastTurn => turns.isEmpty ? null : turns.last;

  /// Turns a player has come through still in.
  int turnsSurvivedBy(int playerId) =>
      turns.where((turn) => turn.playerId == playerId && turn.survived).length;

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
