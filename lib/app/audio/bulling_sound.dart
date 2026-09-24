import '../bulling_controller.dart';
import 'sound_controller.dart';

/// What a change in a Bulling leg should sound like.
///
/// The same shape as `soundsForAtc`: every dart clicks, the first calls
/// "game on", and reaching the target is a checkout. A turn's points are
/// read out the way an x01 total is - there is a spoken line for every number
/// a turn here can make - and a turn without a bull is "no score".
List<Sound> soundsForBulling(BullingSession? previous, BullingSession next) {
  if (previous == null) return const [];

  final before = previous.leg;
  final after = next.leg;

  // Same guard as `soundsFor`: only a single thrown dart is heard.
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
  } else if (after.turns.length == before.turns.length + 1) {
    final scored = after.turns.last.scored;
    sounds.add(
      Sound.speech(
        scored == 0
            ? SoundAssets.spokenNoScore
            : SoundAssets.spokenTotal(scored),
      ),
    );
  }

  return sounds;
}
