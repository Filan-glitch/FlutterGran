/// [soundsForTraining], the cues and commentary for a change in a training
/// session.
///
/// {@category App}
library;

import '../../domain/training/checkout_attempt.dart';
import '../../domain/x01/leg_state.dart';
import '../training_controller.dart';
import 'sound_controller.dart';

/// What a change in a training session should sound like.
///
/// Trimmed hard from [soundsFor], which this deliberately does not call:
/// there is no turn total worth speaking aloud when nobody is being scored
/// against. What is left: a dart landed, a checkout (or a passed Bob's 27)
/// finished, and - in the drills that keep score - a bust or a blank visit
/// at a Bob's 27 double.
List<Sound> soundsForTraining(TrainingSession? previous, TrainingSession next) {
  // Only a single new dart is heard - see [soundsFor].
  if (previous == null ||
      previous.runtimeType != next.runtimeType ||
      next.darts.length != previous.darts.length + 1) {
    return const [];
  }

  const dart = Sound.cue(SoundAssets.dartCue);
  const checkout = [
    dart,
    Sound.cue(SoundAssets.checkoutCue),
    Sound.speech(
      SoundAssets.spokenGameShot,
      after: SoundTiming.afterCheckoutCue,
    ),
  ];
  const bust = [dart, Sound.cue(SoundAssets.bustCue)];

  switch ((previous, next)) {
    case (
      CheckoutPracticeSession(leg: final before),
      CheckoutPracticeSession(leg: final after),
    ):
      // Checkout practice has always stayed quiet on a bust: the attempt
      // just carries on.
      return after.isFinished && !before.isFinished ? checkout : const [dart];
    case (
      CheckoutChallengeSession(state: final before),
      CheckoutChallengeSession(state: final after),
    ):
      return _attemptSounds(
        before.attempts,
        after.attempts,
        checkout: checkout,
        bust: bust,
      );
    case (
      Ladder121Session(state: final before),
      Ladder121Session(state: final after),
    ):
      return _attemptSounds(
        before.attempts,
        after.attempts,
        checkout: checkout,
        bust: bust,
      );
    case (
      Bobs27Session(state: final before),
      Bobs27Session(state: final after),
    ):
      if (after.visits.length == before.visits.length) return const [dart];
      if (after.passed) return checkout;
      if (after.visits.last.hits == 0) return bust;
      return const [dart];
    default:
      return const [dart];
  }
}

/// The sound of the dart that took [before] to [after], found in the attempt
/// it landed in: the one that was running before it.
List<Sound> _attemptSounds(
  List<CheckoutAttempt> before,
  List<CheckoutAttempt> after, {
  required List<Sound> checkout,
  required List<Sound> bust,
}) {
  final index = before.length - 1;
  if (index < 0 || index >= after.length) {
    return const [Sound.cue(SoundAssets.dartCue)];
  }
  return _legSounds(
    before[index].leg,
    after[index].leg,
    checkout: checkout,
    bust: bust,
  );
}

/// A checkout, a bust, or just a dart, between two folds of one leg.
List<Sound> _legSounds(
  LegState before,
  LegState after, {
  required List<Sound> checkout,
  required List<Sound> bust,
}) {
  if (after.isFinished && !before.isFinished) return checkout;
  if (after.turns.length > before.turns.length && after.turns.last.busted) {
    return bust;
  }
  return const [Sound.cue(SoundAssets.dartCue)];
}
