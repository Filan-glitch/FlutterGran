import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/audio/sound_controller.dart';
import 'package:fluttergran/app/audio/sound_player.dart';

/// Guards the slowdown that made a long x01 session take seconds to show a
/// dart.
///
/// audioplayers polls a player's position every frame from the moment it
/// plays, and every `play()` starts another polling loop without stopping the
/// one before. Only completion stops them, and the low-latency cue player
/// never completes on Android. So each dart cue left one more loop polling
/// the platform every frame, forever: a few hundred darts in, the platform
/// channel the board's notifications arrive on was busy answering thousands
/// of position calls a second.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeAudioPlatform platform;

  setUp(() {
    platform = _FakeAudioPlatform();
    AudioplayersPlatformInterface.instance = platform;
    GlobalAudioplayersPlatformInterface.instance = _FakeGlobalAudioPlatform();
    AudioCache.instance = _FakeAudioCache();
  });

  /// Lets every queued play reach the platform.
  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 5));

  /// Runs one frame, which is when a polling loop polls and re-arms itself.
  var frameTime = Duration.zero;
  Future<void> frame() async {
    frameTime += const Duration(milliseconds: 16);
    binding
      ..handleBeginFrame(frameTime)
      ..handleDrawFrame();
    await settle();
  }

  // A plain test rather than a widget test: players built inside a widget
  // test's fake-async zone never finish disposing, and frames are easy
  // enough to run by hand.
  test('dart cues leave nothing running once they have played', () async {
    final player = AudioPlayersSoundPlayer();
    await settle();

    for (var dart = 0; dart < 20; dart++) {
      player.playCue(SoundAssets.dartCue);
      await settle();
    }
    // A turn's commentary, on the other player.
    player.playSpeech(SoundAssets.spokenTotal(60));
    await settle();

    // Plenty of frames for anything still running to show itself.
    for (var i = 0; i < 30; i++) {
      await frame();
    }

    // Every cue really reached the platform: a player that had quietly
    // switched itself off would pass the rest of this for the wrong reason.
    expect(platform.resumes, 21);
    expect(binding.transientCallbackCount, 0);
    expect(platform.positionPolls, 0);

    await player.dispose();
  });
}

/// Stands in for the Android plugin: prepares instantly, reports no position
/// and never completes a low-latency sound - exactly what a SoundPool does.
class _FakeAudioPlatform extends AudioplayersPlatformInterface {
  final Map<String, StreamController<AudioEvent>> _events = {};

  int resumes = 0;
  int positionPolls = 0;

  StreamController<AudioEvent> _eventsFor(String playerId) =>
      _events.putIfAbsent(playerId, StreamController<AudioEvent>.broadcast);

  @override
  Stream<AudioEvent> getEventStream(String playerId) =>
      _eventsFor(playerId).stream;

  @override
  Future<void> setSourceUrl(
    String playerId,
    String url, {
    bool? isLocal,
    String? mimeType,
  }) async {
    _eventsFor(playerId).add(
      const AudioEvent(eventType: AudioEventType.prepared, isPrepared: true),
    );
  }

  @override
  Future<void> resume(String playerId) async => resumes++;

  @override
  Future<int?> getCurrentPosition(String playerId) async {
    positionPolls++;
    return null;
  }

  @override
  Future<void> dispose(String playerId) async {
    await _events.remove(playerId)?.close();
  }

  @override
  Future<void> create(String playerId) async => _eventsFor(playerId);

  @override
  Future<void> setSourceBytes(
    String playerId,
    Uint8List bytes, {
    String? mimeType,
  }) async {}

  @override
  Future<int?> getDuration(String playerId) async => null;

  @override
  Future<void> pause(String playerId) async {}

  @override
  Future<void> stop(String playerId) async {}

  @override
  Future<void> release(String playerId) async {}

  @override
  Future<void> seek(String playerId, Duration position) async {}

  @override
  Future<void> setBalance(String playerId, double balance) async {}

  @override
  Future<void> setVolume(String playerId, double volume) async {}

  @override
  Future<void> setReleaseMode(String playerId, ReleaseMode releaseMode) async {}

  @override
  Future<void> setPlaybackRate(String playerId, double playbackRate) async {}

  @override
  Future<void> setAudioContext(
    String playerId,
    AudioContext audioContext,
  ) async {}

  @override
  Future<void> setPlayerMode(String playerId, PlayerMode playerMode) async {}

  @override
  Future<void> emitLog(String playerId, String message) async {}

  @override
  Future<void> emitError(String playerId, String code, String message) async {}
}

class _FakeGlobalAudioPlatform implements GlobalAudioplayersPlatformInterface {
  @override
  Future<void> init() async {}

  @override
  Future<void> setGlobalAudioContext(AudioContext ctx) async {}

  @override
  Future<void> emitGlobalLog(String message) async {}

  @override
  Future<void> emitGlobalError(String code, String message) async {}

  @override
  Stream<GlobalAudioEvent> getGlobalEventStream() => const Stream.empty();
}

/// Skips copying bundled assets to a temp file, which needs a real platform.
class _FakeAudioCache extends AudioCache {
  @override
  Future<String> loadPath(String fileName) async => '/fake/$fileName';

  @override
  Future<List<Uri>> loadAll(List<String> fileNames) async => [
    for (final fileName in fileNames) Uri.file('/fake/$fileName'),
  ];
}
