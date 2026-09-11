import '../x01/leg_state.dart' show dartsPerTurn;
import '../x01/thrown_dart.dart';

/// One completed group of [dartsPerTurn] darts.
///
/// Unlike a x01 `Turn`, nothing here busts or scores toward anything - it
/// exists purely so the screen can show three darts at a time the way every
/// other mode does.
class FreePracticeTurn {
  const FreePracticeTurn(this.darts);

  final List<ThrownDart> darts;

  /// Points these darts would score, had anyone been counting.
  int get scored => darts.fold(0, (sum, dart) => sum + dart.value);
}

/// A free-practice session: every dart thrown, and what it adds up to.
///
/// There is no target and no win condition, so unlike x01's `LegState` this
/// never stops accepting darts - it just keeps folding the log into running
/// numbers.
class FreePracticeState {
  const FreePracticeState({
    required this.darts,
    required this.turns,
    required this.currentTurnDarts,
  });

  /// The full ordered log this state was folded from.
  final List<ThrownDart> darts;

  /// Turns already completed, in order.
  final List<FreePracticeTurn> turns;

  /// Darts thrown so far in the turn in progress.
  final List<ThrownDart> currentTurnDarts;

  int get dartsThrown => darts.length;

  int get totalScored => darts.fold(0, (sum, dart) => sum + dart.value);

  int get oneEightyCount => turns.where((turn) => turn.scored == 180).length;

  /// The highest turn thrown so far, or null before one has completed.
  int? get bestTurn {
    if (turns.isEmpty) return null;
    return turns.map((turn) => turn.scored).reduce((a, b) => a > b ? a : b);
  }

  /// Three-dart average across the whole session, or null before anything
  /// has been thrown.
  double? get average {
    if (dartsThrown == 0) return null;
    return totalScored / dartsThrown * dartsPerTurn;
  }
}

/// Folds a free-practice dart log into its running state.
///
/// Modeled on `foldLeg` (`../x01/leg_reducer.dart`): a pure function of the
/// log, so undo is dropping the last dart and folding again. Simpler than
/// `foldLeg` because there is nothing to fold toward - every group of three
/// darts closes a turn, full stop.
FreePracticeState foldFreePractice(List<ThrownDart> darts) {
  final turns = <FreePracticeTurn>[];
  var turnDarts = <ThrownDart>[];

  for (final dart in darts) {
    turnDarts.add(dart);
    if (turnDarts.length == dartsPerTurn) {
      turns.add(FreePracticeTurn(List<ThrownDart>.unmodifiable(turnDarts)));
      turnDarts = [];
    }
  }

  return FreePracticeState(
    darts: List<ThrownDart>.unmodifiable(darts),
    turns: List<FreePracticeTurn>.unmodifiable(turns),
    currentTurnDarts: List<ThrownDart>.unmodifiable(turnDarts),
  );
}

/// The state of a free-practice session before anything has been thrown.
FreePracticeState initialFreePracticeState() => foldFreePractice(const []);
