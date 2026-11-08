import 'package:fluttergran/domain/training/ladder_121.dart';
import 'package:test/test.dart';

import '../../support/darts.dart';

void main() {
  const config = Ladder121Config(rounds: 4);

  test('opens on the start score with nine darts', () {
    final state = foldLadder121(config, const []);
    expect(state.target, 121);
    expect(state.current!.target, 121);
    expect(state.current!.visitsLeft, 3);
  });

  test('a finish climbs one rung', () {
    // 121: T20 T11 D14 = 60 + 33 + 28.
    final state = foldLadder121(config, [t(20), t(11), d(14)]);
    expect(state.lastCompleted!.succeeded, isTrue);
    expect(state.target, 122);
    expect(state.current!.target, 122);
    expect(state.highestFinished, 121);
  });

  test('nine darts without a finish fail, and never drop below the start', () {
    final nine = [for (var i = 0; i < 9; i++) miss];
    final state = foldLadder121(config, nine);
    expect(state.completed, hasLength(1));
    expect(state.lastCompleted!.succeeded, isFalse);
    expect(state.target, 121);
  });

  test('a failure after a climb drops one rung', () {
    final state = foldLadder121(config, [
      t(20), t(11), d(14), // 121 done
      for (var i = 0; i < 9; i++) miss, // 122 failed
    ]);
    expect(state.target, 121);
    expect(state.successRate, 0.5);
  });

  test('a bust uses up a visit', () {
    // 121 - 60 - 57 = 4, then S5 overshoots: bust.
    final state = foldLadder121(config, [t(20), t(19), s(5)]);
    expect(state.current!.visitsLeft, 2);
    expect(state.current!.remaining, 121);
  });

  test('ends after the configured rounds', () {
    const two = Ladder121Config(startScore: 81, rounds: 2);
    final state = foldLadder121(two, [
      t(19), d(12), // 81 in two
      t(20), d(11), // 82 in two
      miss, // ignored, session over
    ]);
    expect(state.isFinished, isTrue);
    expect(state.successes, 2);
    expect(state.highestFinished, 82);
    expect(state.current, isNull);
  });
}
