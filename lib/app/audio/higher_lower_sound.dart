import '../higher_lower_controller.dart';
import 'sound_controller.dart';

/// What a change in a Higher/Lower leg should sound like.
///
/// The same shape as `soundsForBulling`: every dart clicks and the first
/// calls "game on". A turn that stays in has its total read out the way an
/// x01 total is; a turn that puts the player out is a bust; and the turn
/// that leaves one player standing is the game shot.
List<Sound> soundsForHigherLower(
  HigherLowerSession? previous,
  HigherLowerSession next,
) {
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
    final turn = after.turns.last;
    if (turn.survived) {
      sounds.add(Sound.speech(SoundAssets.spokenTotal(turn.total)));
    } else {
      sounds
        ..add(const Sound.cue(SoundAssets.bustCue))
        ..add(
          const Sound.speech(
            SoundAssets.spokenBust,
            after: SoundTiming.afterBustCue,
          ),
        );
    }
  }

  return sounds;
}
