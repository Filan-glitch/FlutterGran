import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_reducer.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:test/test.dart';

ThrownDart s(int n) => ThrownDart(Segment(n, Ring.outerSingle));
ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));
const ThrownDart miss = ThrownDart.miss();
final ThrownDart sbull = ThrownDart(Segment.outerBull);
final ThrownDart dbull = ThrownDart(Segment.innerBull);

BullingConfig config({
  int players = 1,
  BullseyeValue bullseyeValue = BullseyeValue.two,
  int target = 21,
}) => BullingConfig(
  playerIds: [for (var i = 1; i <= players; i++) i],
  bullseyeValue: bullseyeValue,
  target: target,
);

void main() {
  group('opening state', () {
    test('everyone starts on zero with three darts', () {
      final state = initialBullingLegState(config(players: 3));
      expect(state.score, {1: 0, 2: 0, 3: 0});
      expect(state.currentPlayerId, 1);
      expect(state.dartsThrownThisTurn, 0);
      expect(state.dartsLeftThisTurn, 3);
      expect(state.isFinished, isFalse);
      expect(state.turns, isEmpty);
    });
  });

  group('pointsFor', () {
    test('the outer bull is worth 1 point regardless of bullseye value', () {
      expect(pointsFor(Segment.outerBull, BullseyeValue.two), 1);
      expect(pointsFor(Segment.outerBull, BullseyeValue.three), 1);
    });

    test('the inner bull is worth the bullseye value', () {
      expect(pointsFor(Segment.innerBull, BullseyeValue.two), 2);
      expect(pointsFor(Segment.innerBull, BullseyeValue.three), 3);
    });

    test('anything off a bull is worth nothing', () {
      expect(pointsFor(const Segment(20, Ring.triple), BullseyeValue.three), 0);
      expect(pointsFor(const Segment(1, Ring.doubleRing), BullseyeValue.three), 0);
      expect(pointsFor(null, BullseyeValue.three), 0);
    });
  });

  group('scoring darts', () {
    test('an outer bull adds 1', () {
      final state = foldBulling(config(players: 2), [sbull]);
      expect(state.score[1], 1);
    });

    test('an inner bull adds the bullseye value', () {
      final state = foldBulling(
        config(players: 2, bullseyeValue: BullseyeValue.three),
        [dbull],
      );
      expect(state.score[1], 3);
    });

    test('a numbered wedge adds nothing', () {
      final state = foldBulling(config(players: 2), [t(20)]);
      expect(state.score[1], 0);
    });

    test('a miss adds nothing', () {
      final state = foldBulling(config(players: 2), [miss]);
      expect(state.score[1], 0);
    });

    test('points accumulate across darts in a turn', () {
      final state = foldBulling(config(players: 2), [sbull, sbull, s(5)]);
      expect(state.score[1], 2);
    });
  });

  group('winning', () {
    test('landing exactly on the target wins', () {
      final state = foldBulling(
        config(target: 2, bullseyeValue: BullseyeValue.two),
        [dbull],
      );
      expect(state.winnerId, 1);
      expect(state.isFinished, isTrue);
    });

    test('passing the target also wins', () {
      final state = foldBulling(
        config(target: 2, bullseyeValue: BullseyeValue.three),
        [dbull],
      );
      expect(state.winnerId, 1, reason: '3 points passes a target of 2');
    });

    test('darts logged after the win cannot change the result', () {
      final state = foldBulling(
        config(target: 1),
        [sbull, sbull, sbull],
      );
      expect(state.winnerId, 1);
      expect(
        state.turns.single.darts,
        hasLength(1),
        reason: 'the winning dart alone closes the turn',
      );
      expect(state.score[1], 1);
    });
  });

  group('turns', () {
    test('a turn always closes after three darts, scoring or not', () {
      final state = foldBulling(config(players: 2, target: 99), [
        sbull,
        miss,
        miss,
      ]);
      expect(state.turns, hasLength(1));
      expect(state.currentPlayerId, 2);
    });

    test('turns hand over between players', () {
      final state = foldBulling(config(players: 2, target: 99), [
        sbull, miss, miss, // player 1's turn
        sbull, miss, miss, // player 2's turn
      ]);
      expect(state.turns, hasLength(2));
      expect(state.turns.map((turn) => turn.playerId), [1, 2]);
      expect(state.currentPlayerId, 1);
    });
  });

  group('undo, by folding a shorter log', () {
    final log = [sbull, sbull, miss, sbull];

    test('the full log has handed over and player 2 has thrown once', () {
      final state = foldBulling(config(players: 2, target: 99), log);
      expect(state.currentPlayerId, 2);
      expect(state.dartsThrownThisTurn, 1);
      expect(state.score[2], 1);
    });

    test('dropping the last dart rewinds to the start of player 2s turn', () {
      final state = foldBulling(
        config(players: 2, target: 99),
        log.sublist(0, 3),
      );
      expect(state.currentPlayerId, 2);
      expect(state.dartsThrownThisTurn, 0);
      expect(state.score[2], 0);
    });
  });
}
