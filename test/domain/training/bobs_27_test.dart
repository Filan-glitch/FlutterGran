import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/training/aim_target.dart';
import 'package:fluttergran/domain/training/bobs_27.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:test/test.dart';

import '../../support/darts.dart';

void main() {
  const config = Bobs27Config();
  final blank = [miss, miss, miss];

  test('targets run D1 to D20 then the bullseye; max is 1437', () {
    expect(bobs27Targets.first, const AimTarget.double(1));
    expect(bobs27Targets[19], const AimTarget.double(20));
    expect(bobs27Targets.last, AimTarget.bullseye);
    expect(bobs27MaxScore, 1437);
  });

  test('starts on 27 at D1', () {
    final state = foldBobs27(config, const []);
    expect(state.score, 27);
    expect(state.currentTarget, const AimTarget.double(1));
  });

  test('each hit adds the double, a blank visit takes it away', () {
    var state = foldBobs27(config, [d(1), d(1), miss]);
    expect(state.score, 31);
    expect(state.currentTarget, const AimTarget.double(2));

    state = foldBobs27(config, [d(1), d(1), miss, ...blank]);
    expect(state.score, 27);
    expect(state.visits.last.scored, -4);
  });

  test('scores are settled per visit, not per dart', () {
    final state = foldBobs27(config, [d(1)]);
    expect(state.score, 27);
    expect(state.dartsLeftThisVisit, 2);
  });

  test('dropping to zero knocks you out', () {
    // 27 - 2 - 4 - 6 - 8 = 7, then -10 = -3.
    final state = foldBobs27(config, [for (var i = 0; i < 5; i++) ...blank]);
    expect(state.score, -3);
    expect(state.isFinished, isTrue);
    expect(state.passed, isFalse);
    expect(state.currentTarget, isNull);
    expect(foldBobs27(config, [...state.darts, d(6)]).darts.length, 16);
    expect(foldBobs27(config, [...state.darts, d(6)]).visits.length, 5);
  });

  test('play to the end keeps going but never passes', () {
    const toEnd = Bobs27Config(playToEnd: true);
    final state = foldBobs27(toEnd, [for (var i = 0; i < 21; i++) ...blank]);
    expect(state.visits, hasLength(21));
    expect(state.isFinished, isTrue);
    expect(state.passed, isFalse);
  });

  test('a run that stays above zero to the bull passes', () {
    final state = foldBobs27(config, [
      for (var n = 1; n <= 20; n++) ...[d(n), miss, miss],
      const ThrownDart(Segment.innerBull),
      miss,
      miss,
    ]);
    expect(state.passed, isTrue);
    expect(state.score, 27 + 420 + 50);
    expect(state.hitRate, closeTo(1 / 3, 1e-9));
  });
}
