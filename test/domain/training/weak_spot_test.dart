import 'dart:math';

import 'package:fluttergran/domain/training/aim_records.dart';
import 'package:fluttergran/domain/training/aim_target.dart';
import 'package:fluttergran/domain/training/weak_spot.dart';
import 'package:test/test.dart';

import '../../support/darts.dart';

void main() {
  test('pools per focus', () {
    expect(weakSpotPool(WeakSpotFocus.doubles), hasLength(21));
    expect(weakSpotPool(WeakSpotFocus.trebles), hasLength(20));
    expect(weakSpotPool(WeakSpotFocus.singles), hasLength(20));
    expect(weakSpotPool(WeakSpotFocus.mixed), hasLength(62));
    expect(weakSpotPool(WeakSpotFocus.mixed), contains(AimTarget.bull));
  });

  group('foldWeakSpot', () {
    const config = WeakSpotConfig(rounds: 2);
    const d16 = AimTarget.double(16);
    const d8 = AimTarget.double(8);

    test('one visit per target, then a new target is needed', () {
      var state = foldWeakSpot(config, const [d16], [d(16), s(16)]);
      expect(state.currentTarget, d16);
      expect(state.dartsLeftThisVisit, 1);

      state = foldWeakSpot(config, const [d16], [d(16), s(16), miss]);
      expect(state.needsTarget, isTrue);
      expect(state.round, 2);
    });

    test('records hits and miss directions per target', () {
      final state = foldWeakSpot(
        config,
        const [d16, d8],
        [
          d(16), s(16), s(16), // one hit, two inside
          d(16), d(8), miss, // D16 sits left of D8 on the board
        ],
      );
      expect(state.isFinished, isTrue);
      expect(state.session[d16], const AimRecord(attempts: 3, hits: 1));
      expect(state.misses[d16], {MissDirection.inside: 2});
      expect(state.session[d8], const AimRecord(attempts: 3, hits: 1));
      expect(state.misses[d8], {
        MissDirection.left: 1,
        MissDirection.outside: 1,
      });
      expect(state.hitRate, closeTo(2 / 6, 1e-9));
    });

    test('weakest sorts by session rate and names the usual miss', () {
      final state = foldWeakSpot(
        config,
        const [d16, d8],
        [s(16), s(16), miss, d(8), d(8), miss],
      );
      final weakest = state.weakest();
      expect(weakest.first.target, d16);
      expect(weakest.first.usualMiss, MissDirection.inside);
      expect(weakest.last.target, d8);
    });

    test('history and session combine', () {
      final withHistory = WeakSpotConfig(
        history: {d16: const AimRecord(attempts: 10, hits: 2)},
      );
      final state = foldWeakSpot(withHistory, const [d16], [d(16)]);
      expect(state.combined(d16), const AimRecord(attempts: 11, hits: 3));
    });
  });

  test('draws favour weak targets, reach every target, never repeat', () {
    // D20 is a near-certain hit, D1 a near-certain miss.
    final config = WeakSpotConfig(
      history: {
        const AimTarget.double(20): const AimRecord(attempts: 200, hits: 198),
        const AimTarget.double(1): const AimRecord(attempts: 200, hits: 2),
      },
    );
    final random = Random(7);
    final counts = <AimTarget, int>{};
    var state = foldWeakSpot(config, const [], const []);
    AimTarget? previous;
    for (var i = 0; i < 4000; i++) {
      final next = drawWeakSpotTarget(random, state);
      expect(next, isNot(previous));
      counts[next] = (counts[next] ?? 0) + 1;
      previous = next;
      state = foldWeakSpot(config, [next], const []);
    }
    expect(counts.keys, hasLength(21));
    expect(
      counts[const AimTarget.double(1)]!,
      greaterThan(counts[const AimTarget.double(20)]! * 10),
    );
  });
}
