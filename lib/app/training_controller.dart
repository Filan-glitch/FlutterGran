/// [TrainingController], which runs a solo training session - free practice or
/// checkout practice - from board events, without storing anything.
///
/// {@category App}
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttergran/app/game_controller.dart' show GameController;

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
/// Sealed, so a screen reading this has to handle both drills explicitly
/// rather than assuming free practice.
sealed class TrainingSession {
  const TrainingSession();
}

/// Free practice: darts at anything, with no target and no end.
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
/// Nothing here reads [gameRepositoryProvider] or writes
/// [currentGameIdProvider], so no training dart can reach a database row.
/// Otherwise gated like [GameController]: board input only while a training
/// screen is open, and no board darts while the keypad override is up.
class TrainingController extends Notifier<TrainingSession> {
  bool _live = false;
  bool _manualOverrideOpen = false;

  @override
  TrainingSession build() {
    final events = ref.watch(boardEventsProvider).listen(_handleBoardEvent);
    ref.onDispose(events.cancel);

    _manualOverrideOpen = ref.read(keypadOverrideProvider);
    ref.listen(keypadOverrideProvider, (previous, next) {
      _manualOverrideOpen = next;
    });

    return FreePracticeSession(initialFreePracticeState());
  }

  void _handleBoardEvent(BoardEvent event) {
    if (!_live) return;

    switch (event) {
      case DartHit(:final segment):
        if (_manualOverrideOpen) return;
        addDart(ThrownDart(segment));
      case BoardMiss():
        if (_manualOverrideOpen) return;
        addDart(const ThrownDart.miss());
      case ButtonPress():
      case UnknownFrame():
        // Training has no turn summary for the button to dismiss, and an
        // unknown frame is never scored.
        break;
    }
  }

  /// Records a dart. Ungated, like [GameController.addDart]: only the board
  /// path is gated on [_live], so the keypad and tests can always use this.
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

  /// Drops the last dart thrown and replays, as [GameController.undo] does.
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
  /// keeping [CheckoutPracticeSession.checkoutsCompleted].
  ///
  /// No-op for free practice, which has no finished state to reset from.
  void throwAgain() {
    if (state case CheckoutPracticeSession(
      :final leg,
      :final checkoutsCompleted,
    )) {
      state = CheckoutPracticeSession(
        leg: initialLegState(leg.config),
        checkoutsCompleted: checkoutsCompleted,
      );
    }
  }

  /// Steps away without discarding the session; the board stops scoring
  /// into it. Nothing is stored, so there is nothing to resume later.
  void leave() => _live = false;
}
