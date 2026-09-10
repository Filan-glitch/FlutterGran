import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/board_event.dart';
import '../domain/training/free_practice_state.dart';
import '../domain/training/training_drill.dart';
import '../domain/x01/game_config.dart';
import '../domain/x01/leg_reducer.dart';
import '../domain/x01/leg_state.dart';
import '../domain/x01/thrown_dart.dart';
import 'providers.dart';

/// The seat id a solo checkout-practice leg plays under.
///
/// Never written anywhere - no repository call ever reads a training session
/// back - so it only has to be a value [GameConfig] accepts, not a real
/// player.
const int soloTrainingSeat = 0;

/// A training session in progress: which drill, and where it stands.
///
/// Sealed the same way `ResumableLeg` and `ModeStats` are, so a screen
/// reading this has to handle both drills explicitly rather than assuming
/// free practice.
sealed class TrainingSession {
  const TrainingSession();
}

class FreePracticeSession extends TrainingSession {
  const FreePracticeSession(this.practice);

  final FreePracticeState practice;
}

/// A checkout-practice attempt, plus how many the session has finished so
/// far.
///
/// [leg] is a genuine [LegState] - checkout practice is just a solo x01 leg
/// nobody saves - so bust handling, the win check and turn structure all
/// come from [foldLeg] for free.
class CheckoutPracticeSession extends TrainingSession {
  const CheckoutPracticeSession({
    required this.leg,
    required this.checkoutsCompleted,
  });

  final LegState leg;

  /// How many attempts have finished this session, across every "throw
  /// again". Kept here rather than in [leg] because restarting an attempt
  /// re-folds [leg] from an empty log, and this count must survive that.
  final int checkoutsCompleted;

  int get startScore => leg.config.startScore;
}

/// Owns a training session's dart log and turns board events into feedback.
///
/// The one thing this type guarantees by never doing it: nothing here reads
/// [gameRepositoryProvider] or writes [currentGameIdProvider]. There is
/// consequently no code path from a training dart to a database row - the
/// same guarantee [GameController] gives a real leg through its own persist
/// step, just held here by omission rather than by a gate.
class TrainingController extends Notifier<TrainingSession> {
  /// Whether a training screen is open in front of someone. Mirrors
  /// `GameController._live`: board input is ignored while this is false, so a
  /// dart thrown after the player has walked away cannot score into a session
  /// nobody is looking at.
  bool _live = false;

  @override
  TrainingSession build() {
    ref.listen(boardEventsProvider, (previous, next) {
      final event = next.value;
      if (event != null) _handleBoardEvent(event);
    });

    return FreePracticeSession(initialFreePracticeState());
  }

  void _handleBoardEvent(BoardEvent event) {
    if (!_live) return;

    switch (event) {
      case DartHit(:final segment):
        addDart(ThrownDart(segment));
      case BoardMiss():
        addDart(const ThrownDart.miss());
      case ButtonPress():
      case UnknownFrame():
        // Training has no turn-confirm step and nothing diagnostic to show -
        // there is no leg-ending consequence a training dart could reach.
        break;
    }
  }

  /// Records a dart. Public and ungated, exactly like `GameController.addDart`
  /// - only the board path above is gated on [_live], so this stays usable
  /// for manual keypad entry (and for tests) whether or not a board is even
  /// connected.
  void addDart(ThrownDart dart) {
    switch (state) {
      case FreePracticeSession(:final practice):
        state = FreePracticeSession(
          foldFreePractice([...practice.darts, dart]),
        );
      case CheckoutPracticeSession(:final leg, :final checkoutsCompleted):
        // A finished attempt waits for "throw again" - a stray dart at an
        // already-checked-out board must not restart it on its own.
        if (leg.isFinished) return;

        final folded = foldLeg(leg.config, [...leg.darts, dart]);
        state = CheckoutPracticeSession(
          leg: folded,
          checkoutsCompleted: folded.isFinished
              ? checkoutsCompleted + 1
              : checkoutsCompleted,
        );
    }
  }

  /// Drops the last dart thrown and replays. Same idiom as
  /// `GameController.undo`.
  void undo() {
    switch (state) {
      case FreePracticeSession(:final practice):
        if (practice.darts.isEmpty) return;
        state = FreePracticeSession(
          foldFreePractice(
            practice.darts.sublist(0, practice.darts.length - 1),
          ),
        );
      case CheckoutPracticeSession(:final leg, :final checkoutsCompleted):
        if (leg.darts.isEmpty) return;
        final folded = foldLeg(
          leg.config,
          leg.darts.sublist(0, leg.darts.length - 1),
        );
        state = CheckoutPracticeSession(
          leg: folded,
          // Undoing the dart that checked out un-completes the attempt.
          checkoutsCompleted: leg.isFinished && !folded.isFinished
              ? checkoutsCompleted - 1
              : checkoutsCompleted,
        );
    }
  }

  /// Starts a fresh session for [drill]. [startScore] is only meaningful for
  /// [TrainingDrill.checkoutPractice].
  void start({required TrainingDrill drill, int startScore = 501}) {
    _live = true;
    state = switch (drill) {
      TrainingDrill.freePractice => FreePracticeSession(
        initialFreePracticeState(),
      ),
      TrainingDrill.checkoutPractice => CheckoutPracticeSession(
        leg: initialLegState(
          GameConfig(
            startScore: startScore,
            playerIds: const [soloTrainingSeat],
          ),
        ),
        checkoutsCompleted: 0,
      ),
    };
  }

  /// Resets the current checkout-practice attempt to the same start score,
  /// without leaving the screen or losing [CheckoutPracticeSession.checkoutsCompleted].
  ///
  /// No-op for free practice, which has no finished state to reset from.
  void throwAgain() {
    if (state case CheckoutPracticeSession(:final leg, :final checkoutsCompleted)) {
      state = CheckoutPracticeSession(
        leg: initialLegState(leg.config),
        checkoutsCompleted: checkoutsCompleted,
      );
    }
  }

  /// Steps away from the session without discarding it. Mirrors
  /// `GameController.leave`, minus anything to leave resumable - there is no
  /// database row to leave it in.
  void leave() => _live = false;
}
