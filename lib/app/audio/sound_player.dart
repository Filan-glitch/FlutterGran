import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'sound_controller.dart';

/// [SoundPlayer] backed by `audioplayers`, with a player per channel.
///
/// Two players rather than one, because the two kinds of audio want opposite
/// things. Cues run on [PlayerMode.lowLatency] - on Android that is a SoundPool
/// holding decoded PCM, which is the only way a click fired as a dart lands
/// actually sounds like it landed. The commentary runs on the normal media
/// player, which handles a compressed Ogg and does not care about a few tens of
/// milliseconds.
class AudioPlayersSoundPlayer implements SoundPlayer {
  AudioPlayersSoundPlayer() {
    unawaited(_prepare());
  }

  final AudioPlayer _cues = AudioPlayer(playerId: 'chalk-cues');
  final AudioPlayer _speech = AudioPlayer(playerId: 'chalk-speech');

  /// The line waiting to be spoken behind a cue, if any.
  Timer? _pending;

  bool _disposed = false;

  /// Cleared once the audio stack has said it cannot serve this device.
  ///
  /// Playing into a player that failed to prepare would raise the same error on
  /// every dart, three times a turn, for the rest of the leg.
  bool _ready = true;

  /// Whether there is any point asking for a sound.
  bool get _live => _ready && !_disposed;

  Future<void> _prepare() async {
    // Nothing about warming up audio is worth taking the app down for. A host
    // with no plugin behind the channel - a widget test - and a device that
    // refuses audio focus both land here, and in both cases the right answer is
    // a silent app that still scores darts.
    try {
      await _cues.setPlayerMode(PlayerMode.lowLatency);

      // Nothing here should outlive its own playback, and a released player
      // cannot be resumed by a stray completion.
      await _cues.setReleaseMode(ReleaseMode.stop);
      await _speech.setReleaseMode(ReleaseMode.stop);

      // Pull the four cues out of the bundle now. The first play of an uncached
      // asset copies it to a temp file, and paying for that on the first dart
      // of the first leg is exactly the lag low-latency mode exists to avoid.
      // The 186 spoken lines are deliberately not warmed: they are needed once
      // a turn, not three times, and unpacking all of them at startup would be
      // a second of work to save a few milliseconds nobody is listening for.
      await AudioCache.instance.loadAll(SoundAssets.cues);
    } on Exception {
      _ready = false;
    }
  }

  @override
  void playCue(String asset) {
    if (!_live) return;
    _fire(_cues, asset);
  }

  @override
  void playSpeech(String asset, {Duration after = Duration.zero}) {
    if (!_live) return;

    // The newest line is always the one worth hearing, so it takes the slot
    // from whatever was waiting for its cue to finish.
    _pending?.cancel();

    if (after == Duration.zero) {
      _speak(asset);
      return;
    }
    _pending = Timer(after, () => _speak(asset));
  }

  void _speak(String asset) {
    if (!_live) return;
    _fire(_speech, asset);
  }

  /// Plays an asset on the given player, with error recovery.
  ///
  /// If the player cannot decode the asset, one failure disables audio for the
  /// entire session. Going silent is better than raising the same unhandled
  /// exception on every dart, three times a turn for the rest of the leg.
  void _fire(AudioPlayer player, String asset) {
    unawaited(
      player.play(AssetSource(asset)).onError((_, _) {
        _ready = false;
      }),
    );
  }

  @override
  void silence() {
    _pending?.cancel();
    _pending = null;
    if (!_live) return;
    unawaited(_speech.stop());
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _pending?.cancel();
    await _cues.dispose();
    await _speech.dispose();
  }
}
