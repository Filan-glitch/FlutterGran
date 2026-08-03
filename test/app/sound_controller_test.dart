import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/audio/sound_controller.dart';
import 'package:fluttergran/app/game_controller.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:fluttergran/domain/x01/leg_reducer.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

/// Records what it was asked for instead of making a noise.
///
/// The whole reason [SoundPlayer] is three methods wide: the mapping from a
/// state change to a sound can be asserted exactly, with no audio device, no
/// plugin and no waiting.
class _FakePlayer implements SoundPlayer {
  final List<String> cues = [];
  final List<(String, Duration)> spoken = [];
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));
  ThrownDart d(int n) => ThrownDart(Segment(n, Ring.doubleRing));
  ThrownDart s(int n) => ThrownDart(Segment(n, Ring.outerSingle));
  const miss = ThrownDart.miss();

  GameConfig config(int startScore) =>
      GameConfig(startScore: startScore, playerIds: const [1, 2]);

  GameSession at(GameConfig cfg, List<ThrownDart> darts) =>
      GameSession(leg: foldLeg(cfg, darts), acknowledgedTurns: 0);

  /// The sounds produced by throwing [darts] where all but the last were
  /// already thrown - which is the only transition a dart ever causes.
  List<Sound> throwing(GameConfig cfg, List<ThrownDart> darts) => soundsFor(
    at(cfg, darts.sublist(0, darts.length - 1)),
    at(cfg, darts),
  );

  group('what a dart sounds like', () {
    test('nothing is played before there is a previous state to compare', () {
      expect(soundsFor(null, at(config(501), [t(20)])), isEmpty);
    });

    test('a dart clicks', () {
      expect(throwing(config(501), [t(20), t(20)]), [
        const Sound.cue(SoundAssets.dartCue),
      ]);
    });

    test('the first dart of a leg is called on', () {
      expect(throwing(config(501), [t(20)]), [
        const Sound.cue(SoundAssets.dartCue),
        const Sound.speech(SoundAssets.spokenGameOn),
      ]);
    });

    test('undo is silent', () {
      final cfg = config(501);
      expect(soundsFor(at(cfg, [t(20), t(20)]), at(cfg, [t(20)])), isEmpty);
    });

    test('resuming a stored log is silent', () {
      // Three darts appear at once. Nobody threw them just now, so nothing
      // clicks and no total is read out.
      final cfg = config(501);
      expect(soundsFor(at(cfg, const []), at(cfg, [t(20), t(20), t(20)])), isEmpty);
    });

    test('starting a fresh leg is silent', () {
      final cfg = config(501);
      expect(soundsFor(at(cfg, [t(20), t(20)]), at(cfg, const [])), isEmpty);
    });
  });

  group('what the end of a turn sounds like', () {
    test('the total is spoken', () {
      expect(throwing(config(501), [t(20), t(20), s(20)]), [
        const Sound.cue(SoundAssets.dartCue),
        Sound.speech(SoundAssets.spokenTotal(140)),
      ]);
    });

    test('a turn worth nothing is "no score", not "zero"', () {
      expect(throwing(config(501), [miss, miss, miss]), [
        const Sound.cue(SoundAssets.dartCue),
        const Sound.speech(SoundAssets.spokenNoScore),
      ]);
    });

    test('a bust buzzes, and the word waits for the buzz', () {
      expect(throwing(config(100), [t(20), t(20)]), [
        const Sound.cue(SoundAssets.dartCue),
        const Sound.cue(SoundAssets.bustCue),
        const Sound.speech(
          SoundAssets.spokenBust,
          after: SoundTiming.afterBustCue,
        ),
      ]);
    });

    test('a maximum gets the fanfare, then the call', () {
      final sounds = throwing(config(501), [t(20), t(20), t(20)]);

      expect(sounds, [
        const Sound.cue(SoundAssets.dartCue),
        const Sound.cue(SoundAssets.oneEightyCue),
        const Sound.speech(
          SoundAssets.spokenOneEighty,
          after: SoundTiming.afterOneEightyCue,
        ),
      ]);
      // The ordering that matters: the words are held back until the fanfare is
      // nearly done, rather than landing on top of its attack.
      expect(sounds.last.delay, greaterThan(const Duration(milliseconds: 500)));
      // And it is the call, not the flat number the scorer would read.
      expect(sounds.last.asset, isNot(SoundAssets.spokenTotal(180)));
    });

    test('the winning double chimes and calls game shot', () {
      expect(throwing(config(100), [t(20), d(20)]), [
        const Sound.cue(SoundAssets.dartCue),
        const Sound.cue(SoundAssets.checkoutCue),
        const Sound.speech(
          SoundAssets.spokenGameShot,
          after: SoundTiming.afterCheckoutCue,
        ),
      ]);
    });

    test('every total a turn can produce has a line to play', () {
      // 0 is covered by "no score" and 180 by the call, but both files exist
      // and the mapping must never reach for one that does not.
      for (var total = 0; total <= maximumTurn; total++) {
        expect(SoundAssets.spokenTotal(total), 'sounds/speech/$total.ogg');
      }
    });
  });

  group('the toggles', () {
    late _FakePlayer player;
    late SoundController controller;

    setUp(() {
      player = _FakePlayer();
      controller = SoundController(player);
    });

    void maximum({required bool sound, required bool speech}) {
      final cfg = config(501);
      controller.observe(
        at(cfg, [t(20), t(20)]),
        at(cfg, [t(20), t(20), t(20)]),
        soundEnabled: sound,
        speechEnabled: speech,
      );
    }

    test('both on plays the cue and the call', () {
      maximum(sound: true, speech: true);

      expect(player.cues, [SoundAssets.dartCue, SoundAssets.oneEightyCue]);
      expect(player.spoken, [
        (SoundAssets.spokenOneEighty, SoundTiming.afterOneEightyCue),
      ]);
    });

    test('speech off keeps the cues', () {
      maximum(sound: true, speech: false);

      expect(player.cues, [SoundAssets.dartCue, SoundAssets.oneEightyCue]);
      expect(player.spoken, isEmpty);
    });

    test('sound off silences everything, including what was queued', () {
      maximum(sound: false, speech: true);

      expect(player.cues, isEmpty);
      expect(player.spoken, isEmpty);
      expect(player.silenced, 1);
    });
  });

  group('wired to the game', () {
    late _FakePlayer player;
    late FakeBoardSource board;
    late ProviderContainer container;

    setUp(() {
      // shared_preferences has no platform behind it under the test binding, so
      // both toggles stay on their defaults - which is on, which is what these
      // expect.
      player = _FakePlayer();
      board = FakeBoardSource();
      container = ProviderContainer(
        overrides: [
          boardSourceProvider.overrideWithValue(board),
          soundPlayerProvider.overrideWithValue(player),
        ],
      );
      // Stands in for the game screen, which watches the controller for exactly
      // this reason: watching it is what subscribes it to the game.
      container.listen(soundControllerProvider, (_, _) {});
    });

    tearDown(() {
      container.dispose();
      board.dispose();
    });

    test('a dart thrown into the real controller clicks', () {
      container.read(gameProvider.notifier).addDart(t(20));

      expect(player.cues, [SoundAssets.dartCue]);
      expect(player.spoken, [(SoundAssets.spokenGameOn, Duration.zero)]);
    });

    test('a full turn is read out', () {
      container.read(gameProvider.notifier)
        ..addDart(t(20))
        ..addDart(s(20))
        ..addDart(s(20));

      expect(player.cues, List.filled(3, SoundAssets.dartCue));
      expect(player.spoken.last, (SoundAssets.spokenTotal(100), Duration.zero));
    });
  });
}
