/// Sound players that never touch an audio plugin.
library;

import 'package:fluttergran/app/audio/sound_controller.dart';

/// Plays nothing, so nothing goes looking for an audio plugin once a game
/// opens. For tests that do not care what is heard.
class MuteSoundPlayer implements SoundPlayer {
  @override
  void playCue(String asset) {}

  @override
  void playSpeech(String asset, {Duration after = Duration.zero}) {}

  @override
  void silence() {}

  @override
  Future<void> dispose() async {}
}

/// Plays nothing but writes down what it was asked to play.
///
/// Unlike `AudioPlayersSoundPlayer`, it schedules no real `Timer` for a
/// delayed line, which would otherwise outlive a widget tree a test tears
/// down.
class RecordingSoundPlayer implements SoundPlayer {
  /// Every cue asset, in order.
  final List<String> cues = [];

  /// Every speech asset with its delay, in order.
  final List<(String, Duration)> spoken = [];

  /// How many times [silence] was called.
  int silenced = 0;

  @override
  void playCue(String asset) => cues.add(asset);

  @override
  void playSpeech(String asset, {Duration after = Duration.zero}) =>
      spoken.add((asset, after));

  @override
  void silence() => silenced++;

  @override
  Future<void> dispose() async {}
}
