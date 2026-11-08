import 'dart:math';

import 'package:fluttergran/domain/training/checkout_challenge.dart';
import 'package:fluttergran/domain/x01/x01_rules.dart';
import 'package:test/test.dart';

import '../../support/darts.dart';

void main() {
  group('checkoutPool', () {
    test('double out tops at 170 and drops the bogey numbers', () {
      final pool = checkoutPool(
        const CheckoutBand(150, 180),
        X01OutRule.double,
      );
      expect(pool.last, 170);
      for (final bogey in [169, 168, 166, 165, 163, 162, 159]) {
        expect(pool, isNot(contains(bogey)));
      }
      expect(pool, containsAll([160, 161, 164, 167, 170]));
    });

    test('straight out reaches 180', () {
      final pool = checkoutPool(
        const CheckoutBand(171, 180),
        X01OutRule.straight,
      );
      expect(pool, contains(180));
    });
  });

  group('levels', () {
    test('17 levels of ten under double out, 18 under straight', () {
      expect(checkoutLevelCount(X01OutRule.double), 17);
      expect(checkoutLevelCount(X01OutRule.straight), 18);
      expect(
        checkoutLevelBand(0, X01OutRule.double),
        const CheckoutBand(2, 10),
      );
      expect(
        checkoutLevelBand(3, X01OutRule.double),
        const CheckoutBand(31, 40),
      );
      expect(
        checkoutLevelBand(16, X01OutRule.double),
        const CheckoutBand(161, 170),
      );
    });
  });

  group('foldCheckoutChallenge', () {
    const config = CheckoutChallengeConfig(rounds: 3, startLevel: 5);

    test('needs a target before the first dart', () {
      final state = foldCheckoutChallenge(config, const [], const []);
      expect(state.needsTarget, isTrue);
      expect(state.current, isNull);
      expect(state.round, 1);
    });

    test('an attempt is one visit: checkout, bust or third dart ends it', () {
      var state = foldCheckoutChallenge(config, const [40], [s(20)]);
      expect(state.current!.remaining, 20);
      expect(state.needsTarget, isFalse);

      state = foldCheckoutChallenge(config, const [40], [s(20), d(10)]);
      expect(state.lastCompleted!.succeeded, isTrue);
      expect(state.needsTarget, isTrue);

      state = foldCheckoutChallenge(config, const [40], [t(20)]);
      expect(state.lastCompleted!.succeeded, isFalse, reason: 'bust');

      state = foldCheckoutChallenge(config, const [40], [s(1), s(1), s(1)]);
      expect(state.lastCompleted!.succeeded, isFalse);
      expect(state.lastCompleted!.dartsUsed, 3);
    });

    test('darts carry over into the next drawn target', () {
      final state = foldCheckoutChallenge(
        config,
        const [40, 32],
        [d(20), s(16)],
      );
      expect(state.completed, hasLength(1));
      expect(state.current!.target, 32);
      expect(state.current!.remaining, 16);
    });

    test('a checkout climbs a level, two misses in a row drop one', () {
      expect(foldCheckoutChallenge(config, const [], const []).level, 5);
      expect(foldCheckoutChallenge(config, const [40], [d(20)]).level, 6);
      expect(
        foldCheckoutChallenge(config, const [40], [miss, miss, miss]).level,
        5,
        reason: 'one miss is not enough',
      );
      expect(
        foldCheckoutChallenge(
          config,
          const [40, 40, 40],
          [
            ...[miss, miss, miss],
            ...[miss, miss, miss],
          ],
        ).level,
        4,
      );
    });

    test('finishes after the configured rounds, with a summary', () {
      final state = foldCheckoutChallenge(
        config,
        const [40, 100, 2],
        [
          s(20), d(10), // 40 in two
          t(20), miss, miss, // 100 missed
          d(1), // 2 in one
        ],
      );
      expect(state.isFinished, isTrue);
      expect(state.needsTarget, isFalse);
      expect(state.checkouts, 2);
      expect(state.successRate, closeTo(2 / 3, 1e-9));
      expect(state.highestCheckout, 40);
      expect(state.dartsPerCheckout, 1.5);
      expect(state.byBand[const CheckoutBand(2, 40)], (
        attempts: 2,
        checkouts: 2,
      ));
      expect(state.byBand[const CheckoutBand(81, 120)], (
        attempts: 1,
        checkouts: 0,
      ));
    });

    test('a fixed band ignores the level', () {
      const banded = CheckoutChallengeConfig(band: CheckoutBand(81, 120));
      final state = foldCheckoutChallenge(banded, const [100], [miss]);
      expect(state.nextBand, const CheckoutBand(81, 120));
    });
  });

  test('drawCheckoutTarget stays in band and never repeats', () {
    const config = CheckoutChallengeConfig(band: CheckoutBand(2, 6));
    final random = Random(1);
    final seen = <int>{};
    int? previous;
    var state = foldCheckoutChallenge(config, const [], const []);
    for (var i = 0; i < 40; i++) {
      final next = drawCheckoutTarget(random, state);
      expect(next, inInclusiveRange(2, 6));
      expect(next, isNot(previous));
      seen.add(next);
      previous = next;
      state = foldCheckoutChallenge(config, [next], const []);
    }
    expect(seen, {2, 3, 4, 5, 6});
  });
}
