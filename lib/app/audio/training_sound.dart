import '../../domain/x01/thrown_dart.dart';
import '../training_controller.dart';
import 'sound_controller.dart';

/// What a change in a training session should sound like.
///
/// Trimmed hard from `soundsFor` (`sound_controller.dart`), which this
/// deliberately does not call: a training dart never busts a match, never
/// wins one, and there is no turn total worth speaking aloud when nobody is
/// being scored against. The only two events left are "a dart landed" and
/// "a checkout finished".
List<Sound> soundsForTraining(TrainingSession? previous, TrainingSession next) {
  final before = _darts(previous);
  // `next` is never null, so `_darts` always matches a case for it.
  final after = _darts(next)!;

  // Same guard as `soundsFor`: starting a session, restarting an attempt and
  // undoing all move the log by anything other than exactly one dart, and
  // none of those is someone at the oche.
  if (before == null || after.length != before.length + 1) return const [];

  final sounds = <Sound>[const Sound.cue(SoundAssets.dartCue)];

  if (next case CheckoutPracticeSession(:final leg)) {
    final wasFinished =
        previous is CheckoutPracticeSession && previous.leg.isFinished;
    if (leg.isFinished && !wasFinished) {
      sounds
        ..add(const Sound.cue(SoundAssets.checkoutCue))
        ..add(
          const Sound.speech(
            SoundAssets.spokenGameShot,
            after: SoundTiming.afterCheckoutCue,
          ),
        );
    }
  }

  return sounds;
}

List<ThrownDart>? _darts(TrainingSession? session) => switch (session) {
  null => null,
  FreePracticeSession(:final practice) => practice.darts,
  CheckoutPracticeSession(:final leg) => leg.darts,
};
