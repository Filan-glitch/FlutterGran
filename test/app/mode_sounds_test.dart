import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/atc_controller.dart';
import 'package:fluttergran/app/audio/atc_sound.dart';
import 'package:fluttergran/app/audio/bulling_sound.dart';
import 'package:fluttergran/app/audio/sound_controller.dart';
import 'package:fluttergran/app/bulling_controller.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/domain/atc/atc_config.dart';
import 'package:fluttergran/domain/atc/atc_reducer.dart';
import 'package:fluttergran/domain/atc/atc_stop.dart';
import 'package:fluttergran/domain/atc/atc_variant.dart';
import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_reducer.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

/// Records what it was asked for instead of making a noise.
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

const miss = ThrownDart.miss();
const _gameOn = Sound.speech(SoundAssets.spokenGameOn);
const _click = Sound.cue(SoundAssets.dartCue);
const _gameShot = [
  Sound.cue(SoundAssets.checkoutCue),
  Sound.speech(
    SoundAssets.spokenGameShot,
    after: SoundTiming.afterCheckoutCue,
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Around the Clock', () {
    final solo = AtcConfig(playerIds: const [1], variant: AtcVariant.anyPart);

    AtcSession at(List<ThrownDart> darts) => AtcSession(
      leg: foldAroundTheClock(solo, darts),
      acknowledgedTurns: 0,
    );

    List<Sound> throwing(List<ThrownDart> darts) =>
        soundsForAtc(at(darts.sublist(0, darts.length - 1)), at(darts));

    /// One dart on each stop of the track, in order.
    final aroundTheBoard = [
      for (final stop in AtcStop.track)
        ThrownDart(
          stop.number == null
              ? Segment(25, stop.ring!)
              : Segment(stop.number!, Ring.outerSingle),
        ),
    ];

    test('the first dart clicks and calls game on', () {
      expect(throwing([miss]), [_click, _gameOn]);
    });

    test('a dart mid-turn just clicks', () {
      expect(throwing([miss, ThrownDart(Segment(1, Ring.outerSingle))]), [
        _click,
      ]);
    });

    test('a turn that clears nothing is no score', () {
      expect(throwing([miss, miss, miss]), [
        _click,
        const Sound.speech(SoundAssets.spokenNoScore),
      ]);
    });

    test('a turn that moved forward says nothing more', () {
      final one = ThrownDart(Segment(1, Ring.outerSingle));
      expect(throwing([one, miss, miss]), [_click]);
    });

    test('finishing the track is a checkout', () {
      expect(throwing(aroundTheBoard), [_click, ..._gameShot]);
    });

    test('undo and restart are silent', () {
      expect(soundsForAtc(at([miss, miss]), at([miss])), isEmpty);
      expect(soundsForAtc(null, at([miss])), isEmpty);
    });
  });

  group('Bulling', () {
    final solo = BullingConfig(
      playerIds: const [1],
      bullseyeValue: BullseyeValue.two,
      target: 21,
    );

    BullingSession at(List<ThrownDart> darts) => BullingSession(
      leg: foldBulling(solo, darts),
      acknowledgedTurns: 0,
    );

    List<Sound> throwing(List<ThrownDart> darts) =>
        soundsForBulling(at(darts.sublist(0, darts.length - 1)), at(darts));

    final sbull = ThrownDart(Segment.outerBull);
    final dbull = ThrownDart(Segment.innerBull);

    test('the first dart clicks and calls game on', () {
      expect(throwing([sbull]), [_click, _gameOn]);
    });

    test("a turn's points are read out", () {
      expect(throwing([sbull, dbull, miss]), [
        _click,
        Sound.speech(SoundAssets.spokenTotal(3)),
      ]);
    });

    test('a turn without a bull is no score', () {
      expect(throwing([miss, miss, miss]), [
        _click,
        const Sound.speech(SoundAssets.spokenNoScore),
      ]);
    });

    test('reaching the target is a checkout', () {
      // Seven turns of three inner bulls is 42 points, well past 21: the
      // leg ends on the dart that gets there.
      final darts = <ThrownDart>[];
      while (!at(darts).leg.isFinished) {
        darts.add(dbull);
      }
      expect(throwing(darts), [_click, ..._gameShot]);
    });
  });

  group('wired to the game', () {
    late _FakePlayer player;
    late FakeBoardSource board;
    late ProviderContainer container;

    setUp(() {
      player = _FakePlayer();
      board = FakeBoardSource();
      container = ProviderContainer(
        overrides: [
          boardSourceProvider.overrideWithValue(board),
          soundPlayerProvider.overrideWithValue(player),
        ],
      );
      // Stand in for the game screens, which watch these to keep them alive.
      container
        ..listen(atcSoundControllerProvider, (_, _) {})
        ..listen(bullingSoundControllerProvider, (_, _) {});
    });

    tearDown(() {
      container.dispose();
      board.dispose();
    });

    test('an Around the Clock dart clicks', () {
      container.read(atcGameProvider.notifier).addDart(miss);

      expect(player.cues, [SoundAssets.dartCue]);
      expect(player.spoken, [(SoundAssets.spokenGameOn, Duration.zero)]);
    });

    test('a Bulling dart clicks', () {
      container
          .read(bullingGameProvider.notifier)
          .addDart(ThrownDart(Segment.outerBull));

      expect(player.cues, [SoundAssets.dartCue]);
      expect(player.spoken, [(SoundAssets.spokenGameOn, Duration.zero)]);
    });
  });
}
