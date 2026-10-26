import 'package:fluttergran/domain/higher_lower/higher_lower_config.dart';
import 'package:fluttergran/domain/higher_lower/higher_lower_leg_state.dart';
import 'package:fluttergran/domain/higher_lower/higher_lower_reducer.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:test/test.dart';

ThrownDart s(int n) => ThrownDart(Segment(n, Ring.outerSingle));
ThrownDart d(int n) => ThrownDart(Segment(n, Ring.doubleRing));
ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));
const ThrownDart miss = ThrownDart.miss();
final ThrownDart sbull = ThrownDart(Segment.outerBull);
final ThrownDart dbull = ThrownDart(Segment.innerBull);

HigherLowerConfig config({int players = 2}) =>
    HigherLowerConfig(playerIds: [for (var i = 1; i <= players; i++) i]);

void main() {
  group('opening state', () {
    test('higher 45, lower 26, first seat up with three darts', () {
      final state = initialHigherLowerLegState(config(players: 3));
      expect(state.higher, 45);
      expect(state.lower, 26);
      expect(state.currentPlayerId, 1);
      expect(state.dartsLeftThisTurn, 3);
      expect(state.runningTotal, 0);
      expect(state.eliminated, isEmpty);
      expect(state.activePlayerIds, [1, 2, 3]);
      expect(state.isFinished, isFalse);
    });
  });

  group('pointsFor', () {
    test('a miss scores nothing at all', () {
      expect(pointsFor(null), isNull);
    });

    test('treble 1 counts as 0', () {
      expect(pointsFor(const Segment(1, Ring.triple)), 0);
    });

    test('every other segment scores its usual value', () {
      expect(pointsFor(const Segment(1, Ring.outerSingle)), 1);
      expect(pointsFor(const Segment(1, Ring.doubleRing)), 2);
      expect(pointsFor(const Segment(20, Ring.triple)), 60);
      expect(pointsFor(Segment.outerBull), 25);
      expect(pointsFor(Segment.innerBull), 50);
    });
  });

  group('a completed turn', () {
    test('beating higher moves higher to the total', () {
      final state = foldHigherLower(config(), [s(20), s(20), s(10)]);
      expect(state.higher, 50);
      expect(state.lower, 26);
      expect(state.lastTurn!.outcome, HigherLowerOutcome.higher);
      expect(state.lastTurn!.survived, isTrue);
      expect(state.lastTurn!.total, 50);
      expect(state.lastTurn!.higherBefore, 45);
      expect(state.lastTurn!.lowerBefore, 26);
      expect(state.currentPlayerId, 2);
      expect(state.eliminated, isEmpty);
    });

    test('going under lower moves lower to the total', () {
      final state = foldHigherLower(config(), [s(5), s(5), s(5)]);
      expect(state.lower, 15);
      expect(state.higher, 45);
      expect(state.lastTurn!.outcome, HigherLowerOutcome.lower);
    });

    test('a total between the two puts the player out', () {
      final state = foldHigherLower(config(players: 3), [s(10), s(10), s(10)]);
      expect(state.lastTurn!.outcome, HigherLowerOutcome.between);
      expect(state.lastTurn!.survived, isFalse);
      expect(state.eliminated, [1]);
      expect(state.higher, 45);
      expect(state.lower, 26);
    });

    test('equalling higher is not higher - out', () {
      final state = foldHigherLower(config(players: 3), [s(20), s(20), s(5)]);
      expect(state.lastTurn!.outcome, HigherLowerOutcome.between);
      expect(state.isOut(1), isTrue);
    });

    test('equalling lower is not lower - out', () {
      final state = foldHigherLower(config(players: 3), [s(20), s(5), s(1)]);
      expect(state.lastTurn!.outcome, HigherLowerOutcome.between);
      expect(state.isOut(1), isTrue);
    });

    test('three treble 1s total 0 and beat lower', () {
      final state = foldHigherLower(config(), [t(1), t(1), t(1)]);
      expect(state.lastTurn!.total, 0);
      expect(state.lower, 0);
    });

    test('bulls count 25 and 50', () {
      final state = foldHigherLower(config(), [sbull, dbull, s(1)]);
      expect(state.higher, 76);
    });

    test('the values carry over to the next player', () {
      final state = foldHigherLower(config(), [
        s(20), s(20), s(10), // p1: 50, higher
        s(20), s(20), s(5), // p2: 45 - between 26 and 50, out
      ]);
      expect(state.lastTurn!.outcome, HigherLowerOutcome.between);
      expect(state.higher, 50);
    });
  });

  group('a miss', () {
    test('on the first dart ends the turn at once and puts the player out', () {
      final state = foldHigherLower(config(players: 3), [miss]);
      expect(state.turns, hasLength(1));
      expect(state.lastTurn!.darts, [miss]);
      expect(state.lastTurn!.outcome, HigherLowerOutcome.missed);
      expect(state.eliminated, [1]);
      expect(state.currentPlayerId, 2);
      expect(state.dartsLeftThisTurn, 3);
    });

    test('on the third dart puts the player out even on a winning total', () {
      final state = foldHigherLower(config(players: 3), [t(20), t(20), miss]);
      expect(state.lastTurn!.outcome, HigherLowerOutcome.missed);
      expect(state.higher, 45);
      expect(state.isOut(1), isTrue);
    });

    test('totals only the darts that landed', () {
      final state = foldHigherLower(config(players: 3), [s(5), s(7), miss]);
      expect(state.lastTurn!.total, 12);
    });
  });

  group('elimination', () {
    test('eliminated seats are skipped in the rotation', () {
      final state = foldHigherLower(config(players: 3), [
        s(20), s(20), s(10), // p1: 50
        miss, // p2 out
        s(5), s(5), s(5), // p3: 15
      ]);
      expect(state.currentPlayerId, 1);
      expect(state.activePlayerIds, [1, 3]);

      final next = foldHigherLower(config(players: 3), [
        ...state.darts,
        t(20), t(20), t(20), // p1: 180
      ]);
      expect(next.currentPlayerId, 3);
    });

    test('the last player standing wins at once', () {
      final state = foldHigherLower(config(), [
        s(20), s(20), s(10), // p1: 50
        s(10), s(10), s(10), // p2: 30, out
      ]);
      expect(state.winnerId, 1);
      expect(state.isFinished, isTrue);
      expect(state.eliminated, [2]);
    });

    test('the first player can win without throwing again', () {
      final state = foldHigherLower(config(), [miss, miss]);
      expect(state.winnerId, 2);
      expect(state.turns, hasLength(1));
      expect(state.darts, [miss, miss]);
    });

    test('darts logged after the win change nothing', () {
      final won = foldHigherLower(config(), [miss]);
      final after = foldHigherLower(config(), [miss, t(20), t(20)]);
      expect(after.winnerId, won.winnerId);
      expect(after.turns, hasLength(won.turns.length));
      expect(after.higher, won.higher);
    });
  });

  group('per-player figures', () {
    test('turns survived and darts thrown', () {
      final state = foldHigherLower(config(players: 3), [
        s(20), s(20), s(10), // p1: 50 survived
        s(1), s(1), s(1), // p2: 3 survived
        miss, // p3 out
        t(20), s(1), // p1 in progress
      ]);
      expect(state.turnsSurvivedBy(1), 1);
      expect(state.turnsSurvivedBy(2), 1);
      expect(state.turnsSurvivedBy(3), 0);
      expect(state.dartsThrownBy(1), 5);
      expect(state.dartsThrownBy(3), 1);
      expect(state.runningTotal, 61);
    });
  });
}
