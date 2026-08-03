import '../game_controller.dart';

/// Which of the two players a line belongs to.
///
/// They are kept apart because they want opposite things from the audio stack:
/// a cue must fire the instant a dart lands, and a spoken line must not be cut
/// off halfway by the next one.
enum SoundChannel {
  /// A synthesised cue. Short, fires immediately, overlaps whatever is
  /// speaking.
  cue,

  /// A pre-rendered spoken line. Only ever one at a time.
  speech,
}

/// Paths to the shipped audio, relative to `assets/` - which is what
/// `AssetSource` wants.
///
/// The cues are WAV and the speech is Ogg. That is not an oversight: the cues
/// are a few KB each and are handed to a low-latency player three times a turn,
/// where an undecoded buffer is the point, while the speech is 186 files and
/// compresses to a tenth of the size for no cost anyone can hear.
abstract final class SoundAssets {
  static const String dartCue = 'sounds/cues/dart.wav';
  static const String bustCue = 'sounds/cues/bust.wav';
  static const String checkoutCue = 'sounds/cues/checkout.wav';
  static const String oneEightyCue = 'sounds/cues/one_eighty.wav';

  static const String spokenBust = 'sounds/speech/bust.ogg';
  static const String spokenNoScore = 'sounds/speech/no_score.ogg';
  static const String spokenGameShot = 'sounds/speech/game_shot.ogg';
  static const String spokenGameOn = 'sounds/speech/game_on.ogg';
  static const String spokenOneEighty =
      'sounds/speech/one_hundred_and_eighty.ogg';

  /// The turn total, spoken. Every value 0 to 180 exists.
  static String spokenTotal(int total) => 'sounds/speech/$total.ogg';

  /// The four cues, for warming the cache before the first dart.
  static const List<String> cues = [
    dartCue,
    bustCue,
    checkoutCue,
    oneEightyCue,
  ];
}

/// How long a spoken line waits when a cue is playing under it.
///
/// The rule, and the answer to "do the fanfare and the shout fight": the cue
/// always goes first and the words follow, landing on its decaying tail rather
/// than on its attack. Both sounds stay whole and the pair still reads as one
/// event.
///
/// The numbers are each about 60ms short of the cue's own length, which is set
/// in `tool/make_cues.py`. They are written down in both places because the two
/// files cannot see each other; the generator is the authority, and if a cue
/// gets longer there it gets longer here.
abstract final class SoundTiming {
  /// The bust buzz runs 420ms.
  static const Duration afterBustCue = Duration(milliseconds: 360);

  /// The checkout chime runs 660ms.
  static const Duration afterCheckoutCue = Duration(milliseconds: 600);

  /// The 180 fanfare runs a full second, and earns it.
  static const Duration afterOneEightyCue = Duration(milliseconds: 940);
}

/// The highest three-dart total, and the only one worth a fanfare.
const int maximumTurn = 180;

/// One thing to be heard.
class Sound {
  const Sound._(this.channel, this.asset, this.delay);

  const Sound.cue(String asset)
    : this._(SoundChannel.cue, asset, Duration.zero);

  const Sound.speech(String asset, {Duration after = Duration.zero})
    : this._(SoundChannel.speech, asset, after);

  final SoundChannel channel;

  /// Path under `assets/`.
  final String asset;

  /// How long to hold this back, so it does not land on top of a cue.
  final Duration delay;

  @override
  bool operator ==(Object other) =>
      other is Sound &&
      other.channel == channel &&
      other.asset == asset &&
      other.delay == delay;

  @override
  int get hashCode => Object.hash(channel, asset, delay);

  @override
  String toString() =>
      'Sound(${channel.name}, $asset'
      '${delay == Duration.zero ? '' : ' +${delay.inMilliseconds}ms'})';
}

/// What a change in the game should be heard as.
///
/// A pure function of the two states, which is the whole reason audio is wired
/// this way round: nothing in `lib/domain` and nothing in [GameController] has
/// to know sound exists, and this can be tested by asserting on the list
/// without an audio device anywhere near it.
List<Sound> soundsFor(GameSession? previous, GameSession next) {
  if (previous == null) return const [];

  final before = previous.leg;
  final after = next.leg;

  // Everything the app says is caused by a dart being thrown, and a dart being
  // thrown is exactly one entry appended to the log. Restarting, resuming a
  // stored log and changing the config all move the log by more than one - or
  // backwards - and none of them is someone at the oche. Resuming in
  // particular arrives with completed turns already in it, and reading out the
  // total of a turn thrown yesterday is the bug this guard exists to stop.
  //
  // The one case this cannot tell apart is resuming a leg whose stored log is a
  // single dart, which clicks once. That is a 45ms sound on a rare path and not
  // worth carrying state to prevent.
  if (after.darts.length != before.darts.length + 1) return const [];

  final sounds = <Sound>[const Sound.cue(SoundAssets.dartCue)];

  // "Game on" belongs to the first dart of the leg, which is when a referee
  // calls it - not to the setup screen, where nobody is at the oche yet.
  if (before.darts.isEmpty) {
    sounds.add(const Sound.speech(SoundAssets.spokenGameOn));
  }

  // A turn only ever closes on the dart that closed it, so this is that dart.
  if (after.turns.length == before.turns.length + 1) {
    final turn = after.turns.last;

    if (turn.busted) {
      sounds
        ..add(const Sound.cue(SoundAssets.bustCue))
        ..add(
          const Sound.speech(
            SoundAssets.spokenBust,
            after: SoundTiming.afterBustCue,
          ),
        );
    } else if (after.isFinished && !before.isFinished) {
      // Checked before the maximum on purpose. Double-out makes a 180 checkout
      // impossible, but if that rule is ever relaxed, the leg being over is the
      // more important of the two things to say.
      sounds
        ..add(const Sound.cue(SoundAssets.checkoutCue))
        ..add(
          const Sound.speech(
            SoundAssets.spokenGameShot,
            after: SoundTiming.afterCheckoutCue,
          ),
        );
    } else if (turn.scored == maximumTurn) {
      sounds
        ..add(const Sound.cue(SoundAssets.oneEightyCue))
        ..add(
          const Sound.speech(
            SoundAssets.spokenOneEighty,
            after: SoundTiming.afterOneEightyCue,
          ),
        );
    } else if (turn.scored == 0) {
      // `0.ogg` exists and says "zero", which no commentator has ever said
      // about a darts turn.
      sounds.add(const Sound.speech(SoundAssets.spokenNoScore));
    } else {
      sounds.add(Sound.speech(SoundAssets.spokenTotal(turn.scored)));
    }
  }

  return sounds;
}

/// The only thing [SoundController] needs from an audio engine.
///
/// Narrow on purpose. Tests assert which asset a state change asks for, and a
/// fake with three methods is enough to do that without a plugin, a device or a
/// widget binding.
abstract interface class SoundPlayer {
  /// Fires now, over whatever else is sounding.
  void playCue(String asset);

  /// Speaks, replacing any line already speaking or waiting to.
  ///
  /// Replacing rather than queueing is deliberate: when two lines are produced
  /// close together the later one is always the one worth hearing. A player who
  /// busts on their first dart wants "bust", not "game on" followed by "bust"
  /// a beat too late.
  void playSpeech(String asset, {Duration after});

  /// Drops anything waiting to be spoken. Used when the toggles go off.
  void silence();

  Future<void> dispose();
}

/// Turns changes in the game into sound.
///
/// Holds no state of its own: it is handed both sides of a transition and both
/// toggles, so what it plays is a function of its arguments and nothing else.
class SoundController {
  const SoundController(this.player);

  final SoundPlayer player;

  /// Plays whatever the move from [previous] to [next] should be heard as.
  ///
  /// [soundEnabled] silences everything; [speechEnabled] silences only the
  /// commentary, because the commentary is what wears out first and the cues
  /// are worth keeping after it does.
  void observe(
    GameSession? previous,
    GameSession next, {
    required bool soundEnabled,
    required bool speechEnabled,
  }) {
    if (!soundEnabled) {
      player.silence();
      return;
    }

    for (final sound in soundsFor(previous, next)) {
      switch (sound.channel) {
        case SoundChannel.cue:
          player.playCue(sound.asset);
        case SoundChannel.speech:
          if (speechEnabled) {
            player.playSpeech(sound.asset, after: sound.delay);
          }
      }
    }
  }
}
