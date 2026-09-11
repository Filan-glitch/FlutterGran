import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/training/free_practice_state.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:test/test.dart';

ThrownDart s(int n) => ThrownDart(Segment(n, Ring.outerSingle));
ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));
const ThrownDart miss = ThrownDart.miss();

void main() {
  group('opening state', () {
    test('nothing thrown yet', () {
      final state = initialFreePracticeState();
      expect(state.dartsThrown, 0);
      expect(state.totalScored, 0);
      expect(state.turns, isEmpty);
      expect(state.currentTurnDarts, isEmpty);
      expect(state.bestTurn, isNull);
      expect(state.average, isNull);
    });
  });

  group('folding', () {
    test('groups darts into turns of three, never stopping', () {
      final state = foldFreePractice([t(20), t(20), t(20), s(5), miss]);

      expect(state.turns, hasLength(1));
      expect(state.turns.single.scored, 180);
      expect(state.currentTurnDarts, [s(5), miss]);
      expect(state.dartsThrown, 5);
      expect(state.totalScored, 185);
    });

    test('a fourth turn closes exactly like the first', () {
      final darts = [
        t(20), t(20), t(20), // turn 1: 180
        s(1), s(1), s(1), // turn 2: 3
      ];
      final state = foldFreePractice(darts);

      expect(state.turns, hasLength(2));
      expect(state.turns[0].scored, 180);
      expect(state.turns[1].scored, 3);
      expect(state.currentTurnDarts, isEmpty);
    });
  });

  group('derived numbers', () {
    test('oneEightyCount only counts maximum turns', () {
      final state = foldFreePractice([
        t(20), t(20), t(20), // 180
        s(1), s(1), s(1), // 3
        t(20), t(20), t(20), // 180
      ]);
      expect(state.oneEightyCount, 2);
    });

    test('bestTurn is the highest completed turn', () {
      final state = foldFreePractice([
        s(1), s(1), s(1), // 3
        t(20), t(20), t(20), // 180
        s(5), s(5), s(5), // 15
      ]);
      expect(state.bestTurn, 180);
    });

    test('average is the three-dart average over the whole session', () {
      // 60 points from 3 darts -> 60 average.
      final state = foldFreePractice([t(20), miss, miss]);
      expect(state.average, 60);
    });

    test('average counts darts still in progress this turn', () {
      final state = foldFreePractice([t(20)]);
      // 60 points from 1 dart, scaled to a three-dart average: 180.
      expect(state.average, 180);
    });
  });
}
