import '../atc_controller.dart';
import 'sound_controller.dart';

/// What a change in an Around the Clock leg should sound like.
///
/// The same shape as [soundsFor], but not a call into it: there is no score
/// to read out here, only progress round the track. So every dart clicks,
/// the first calls "game on", a turn that moved nobody forward is "no score",
/// and reaching the end of the track is a checkout.
List<Sound> soundsForAtc(AtcSession? previous, AtcSession next) {
  if (previous == null) return const [];

  final before = previous.leg;
  final after = next.leg;

  // Only a single new dart is heard - see [soundsFor].
  if (after.darts.length != before.darts.length + 1) return const [];

  final sounds = <Sound>[const Sound.cue(SoundAssets.dartCue)];

  if (before.darts.isEmpty) {
    sounds.add(const Sound.speech(SoundAssets.spokenGameOn));
  }

  if (after.isFinished && !before.isFinished) {
    sounds
      ..add(const Sound.cue(SoundAssets.checkoutCue))
      ..add(
        const Sound.speech(
          SoundAssets.spokenGameShot,
          after: SoundTiming.afterCheckoutCue,
        ),
      );
  } else if (after.turns.length == before.turns.length + 1 &&
      after.turns.last.stopsCleared == 0) {
    sounds.add(const Sound.speech(SoundAssets.spokenNoScore));
  }

  return sounds;
}
