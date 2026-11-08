import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/audio/sound_controller.dart';
import 'package:fluttergran/app/audio/training_sound.dart';
import 'package:fluttergran/app/training_controller.dart';
import 'package:fluttergran/domain/training/bobs_27.dart';
import 'package:fluttergran/domain/training/checkout_challenge.dart';
import 'package:fluttergran/domain/training/free_practice_state.dart';
import 'package:fluttergran/domain/training/ladder_121.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

import '../support/darts.dart';

void main() {
  const dart = Sound.cue(SoundAssets.dartCue);
  const checkout = [
    dart,
    Sound.cue(SoundAssets.checkoutCue),
    Sound.speech(
      SoundAssets.spokenGameShot,
      after: SoundTiming.afterCheckoutCue,
    ),
  ];
  const bust = [dart, Sound.cue(SoundAssets.bustCue)];

  test('a dart in free practice is just the dart', () {
    expect(
      soundsForTraining(
        FreePracticeSession(foldFreePractice([])),
        FreePracticeSession(foldFreePractice([t(20)])),
      ),
      [dart],
    );
  });

  group('checkout challenge', () {
    CheckoutChallengeSession at(List<ThrownDart> darts) =>
        CheckoutChallengeSession(
          foldCheckoutChallenge(const CheckoutChallengeConfig(), const [
            40,
            32,
          ], darts),
        );

    test('a checkout gets the chime and the call', () {
      expect(soundsForTraining(at([s(20)]), at([s(20), d(10)])), checkout);
    });

    test('a bust buzzes', () {
      expect(soundsForTraining(at([]), at([t(20)])), bust);
    });

    test('an undo is silent', () {
      expect(soundsForTraining(at([s(20)]), at([])), isEmpty);
    });
  });

  test('a bust part-way up a ladder rung buzzes', () {
    Ladder121Session at(List<ThrownDart> darts) =>
        Ladder121Session(foldLadder121(const Ladder121Config(), darts));
    // 121 - 60 - 57 = 4, then S5 overshoots.
    expect(
      soundsForTraining(at([t(20), t(19)]), at([t(20), t(19), s(5)])),
      bust,
    );
  });

  group('bob\'s 27', () {
    Bobs27Session at(List<ThrownDart> darts) =>
        Bobs27Session(foldBobs27(const Bobs27Config(), darts));

    test('a blank visit buzzes', () {
      expect(soundsForTraining(at([miss, miss]), at([miss, miss, miss])), bust);
    });

    test('a visit with a hit is just the dart', () {
      expect(soundsForTraining(at([d(1), miss]), at([d(1), miss, miss])), [
        dart,
      ]);
    });
  });
}
