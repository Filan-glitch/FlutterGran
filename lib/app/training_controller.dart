/// [TrainingController], which runs a solo training session from board
/// events, without storing anything.
///
/// {@category App}
library;

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttergran/app/game_controller.dart' show GameController;

import '../domain/board_event.dart';
import '../domain/training/aim_target.dart';
import '../domain/training/bobs_27.dart';
import '../domain/training/checkout_challenge.dart';
import '../domain/training/free_practice_state.dart';
import '../domain/training/ladder_121.dart';
import '../domain/training/training_drill.dart';
import '../domain/training/weak_spot.dart';
import '../domain/x01/thrown_dart.dart';
import 'providers.dart';

/// The random source for drills that draw their targets. Overridden with a
/// seeded [Random] in tests, so a drawn sequence is repeatable.
final trainingRandomProvider = Provider<Random>((ref) => Random());

/// What a training session is started with: which drill, and its settings.
///
/// Sealed, so [TrainingController.start] handles every drill explicitly.
sealed class TrainingPlan {
  const TrainingPlan();

  /// [drill] with its default settings.
  factory TrainingPlan.of(TrainingDrill drill) => switch (drill) {
    TrainingDrill.freePractice => const FreePracticePlan(),
    TrainingDrill.checkoutChallenge => const CheckoutChallengePlan(),
    TrainingDrill.ladder121 => const Ladder121Plan(),
    TrainingDrill.bobs27 => const Bobs27Plan(),
    TrainingDrill.weakSpot => const WeakSpotPlan(),
  };

  TrainingDrill get drill;
}

class FreePracticePlan extends TrainingPlan {
  const FreePracticePlan();

  @override
  TrainingDrill get drill => TrainingDrill.freePractice;
}

class CheckoutChallengePlan extends TrainingPlan {
  const CheckoutChallengePlan([this.config = const CheckoutChallengeConfig()]);

  final CheckoutChallengeConfig config;

  @override
  TrainingDrill get drill => TrainingDrill.checkoutChallenge;
}

class Ladder121Plan extends TrainingPlan {
  const Ladder121Plan([this.config = const Ladder121Config()]);

  final Ladder121Config config;

  @override
  TrainingDrill get drill => TrainingDrill.ladder121;
}

class Bobs27Plan extends TrainingPlan {
  const Bobs27Plan([this.config = const Bobs27Config()]);

  final Bobs27Config config;

  @override
  TrainingDrill get drill => TrainingDrill.bobs27;
}

class WeakSpotPlan extends TrainingPlan {
  const WeakSpotPlan([this.config = const WeakSpotConfig()]);

  /// Carries the player's history already, resolved by the setup screen.
  final WeakSpotConfig config;

  @override
  TrainingDrill get drill => TrainingDrill.weakSpot;
}

/// A training session in progress: which drill, and where it stands.
///
/// Sealed, so a screen reading this has to handle every drill explicitly
/// rather than assuming free practice.
sealed class TrainingSession {
  const TrainingSession();

  /// Every dart thrown this session - what undo steps back through.
  List<ThrownDart> get darts;
}

/// Free practice: darts at anything, with no target and no end.
class FreePracticeSession extends TrainingSession {
  const FreePracticeSession(this.practice);

  final FreePracticeState practice;

  @override
  List<ThrownDart> get darts => practice.darts;
}

class CheckoutChallengeSession extends TrainingSession {
  const CheckoutChallengeSession(this.state);

  final CheckoutChallengeState state;

  @override
  List<ThrownDart> get darts => state.darts;
}

class Ladder121Session extends TrainingSession {
  const Ladder121Session(this.state);

  final Ladder121State state;

  @override
  List<ThrownDart> get darts => state.darts;
}

class Bobs27Session extends TrainingSession {
  const Bobs27Session(this.state);

  final Bobs27State state;

  @override
  List<ThrownDart> get darts => state.darts;
}

class WeakSpotSession extends TrainingSession {
  const WeakSpotSession(this.state);

  final WeakSpotState state;

  @override
  List<ThrownDart> get darts => state.darts;
}

/// Owns a training session's dart log and turns board events into feedback.
///
/// Nothing here reads [gameRepositoryProvider] or writes
/// [currentGameIdProvider], so no training dart can reach a database row.
/// Otherwise gated like [GameController]: board input only while a training
/// screen is open, and no board darts while the keypad override is up.
///
/// Drills that draw random targets fold from the targets drawn so far, so
/// the fold stays pure; this draws the next one whenever the session needs
/// it, and undo trims any target drawn after the dart it takes back.
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

  Random get _random => ref.read(trainingRandomProvider);

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
      case CheckoutChallengeSession(state: final s):
        if (s.isFinished) return;
        state = _challenge(s.config, s.targets, [...s.darts, dart]);
      case Ladder121Session(state: final s):
        if (s.isFinished) return;
        state = Ladder121Session(foldLadder121(s.config, [...s.darts, dart]));
      case Bobs27Session(state: final s):
        if (s.isFinished) return;
        state = Bobs27Session(foldBobs27(s.config, [...s.darts, dart]));
      case WeakSpotSession(state: final s):
        if (s.isFinished) return;
        state = _weakSpot(s.config, s.targets, [...s.darts, dart]);
    }
  }

  /// Drops the last dart thrown and replays, as [GameController.undo] does.
  void undo() {
    final current = state;
    if (current.darts.isEmpty) return;
    final shorter = current.darts.sublist(0, current.darts.length - 1);

    switch (current) {
      case FreePracticeSession():
        state = FreePracticeSession(foldFreePractice(shorter));
      case CheckoutChallengeSession(state: final s):
        // Only the targets of attempts the shorter log reaches survive: a
        // target drawn after the dart being undone is dropped.
        final reached = foldCheckoutChallenge(s.config, s.targets, shorter);
        state = _challenge(
          s.config,
          s.targets.take(reached.attempts.length).toList(),
          shorter,
        );
      case Ladder121Session(state: final s):
        state = Ladder121Session(foldLadder121(s.config, shorter));
      case Bobs27Session(state: final s):
        state = Bobs27Session(foldBobs27(s.config, shorter));
      case WeakSpotSession(state: final s):
        final reached = foldWeakSpot(s.config, s.targets, shorter);
        final kept = min(
          s.targets.length,
          reached.visitsCompleted + (reached.isFinished ? 0 : 1),
        );
        state = _weakSpot(s.config, s.targets.take(kept).toList(), shorter);
    }
  }

  /// Starts a fresh session for [plan].
  void start(TrainingPlan plan) {
    _live = true;
    state = switch (plan) {
      FreePracticePlan() => FreePracticeSession(initialFreePracticeState()),
      CheckoutChallengePlan(:final config) => _challenge(
        config,
        const [],
        const [],
      ),
      Ladder121Plan(:final config) => Ladder121Session(
        foldLadder121(config, const []),
      ),
      Bobs27Plan(:final config) => Bobs27Session(foldBobs27(config, const [])),
      WeakSpotPlan(:final config) => _weakSpot(config, const [], const []),
    };
  }

  /// Goes again with the same settings: a whole new session.
  ///
  /// No-op for free practice, which has no finished state to reset from.
  void throwAgain() {
    switch (state) {
      case FreePracticeSession():
        break;
      case CheckoutChallengeSession(state: final s):
        start(CheckoutChallengePlan(s.config));
      case Ladder121Session(state: final s):
        start(Ladder121Plan(s.config));
      case Bobs27Session(state: final s):
        start(Bobs27Plan(s.config));
      case WeakSpotSession(state: final s):
        start(WeakSpotPlan(s.config));
    }
  }

  /// Steps away without discarding the session; the board stops scoring
  /// into it. Nothing is stored, so there is nothing to resume later.
  void leave() => _live = false;

  /// Folds a Checkout Challenge and draws the next target if one is due.
  CheckoutChallengeSession _challenge(
    CheckoutChallengeConfig config,
    List<int> targets,
    List<ThrownDart> darts,
  ) {
    final folded = foldCheckoutChallenge(config, targets, darts);
    if (!folded.needsTarget) return CheckoutChallengeSession(folded);
    final next = drawCheckoutTarget(_random, folded);
    return CheckoutChallengeSession(
      foldCheckoutChallenge(config, [...targets, next], darts),
    );
  }

  /// Folds a Weak-spot session and draws the next target if one is due.
  WeakSpotSession _weakSpot(
    WeakSpotConfig config,
    List<AimTarget> targets,
    List<ThrownDart> darts,
  ) {
    final folded = foldWeakSpot(config, targets, darts);
    if (!folded.needsTarget) return WeakSpotSession(folded);
    final next = drawWeakSpotTarget(_random, folded);
    return WeakSpotSession(foldWeakSpot(config, [...targets, next], darts));
  }
}
