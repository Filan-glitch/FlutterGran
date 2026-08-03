import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:fluttergran/domain/x01/leg_reducer.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:test/test.dart';

ThrownDart s(int n) => ThrownDart(Segment(n, Ring.outerSingle));
ThrownDart d(int n) => ThrownDart(Segment(n, Ring.doubleRing));
ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));
const ThrownDart miss = ThrownDart.miss();
final ThrownDart dbull = ThrownDart(Segment.innerBull);
final ThrownDart sbull = ThrownDart(Segment.outerBull);

/// Most rule tests start from a contrived low score so the interesting dart is
/// the first one thrown.
GameConfig config(
  int start, {
  int players = 1,
  bool doubleOut = true,
  int startingSeat = 0,
}) => GameConfig(
  startScore: start,
  playerIds: [for (var i = 1; i <= players; i++) i],
  doubleOut: doubleOut,
  startingSeat: startingSeat,
);

void main() {
  group('opening state', () {
    test('everyone starts on the full score with three darts', () {
      final state = initialLegState(config(501, players: 3));
      expect(state.remaining, {1: 501, 2: 501, 3: 501});
      expect(state.currentPlayerId, 1);
      expect(state.dartsThrownThisTurn, 0);
      expect(state.dartsLeftThisTurn, 3);
      expect(state.isFinished, isFalse);
      expect(state.turns, isEmpty);
    });
  });

  group('scoring', () {
    test('a maximum leaves 321 and hands over', () {
      final state = foldLeg(config(501, players: 2), [t(20), t(20), t(20)]);
      expect(state.remaining[1], 321);
      expect(state.currentPlayerId, 2);
      expect(state.turns.single.scored, 180);
      expect(state.turns.single.busted, isFalse);
    });

    test('a miss scores nothing but still uses a dart', () {
      final state = foldLeg(config(501), [t(20), miss, s(5)]);
      expect(state.remaining[1], 501 - 60 - 5);
      expect(state.turns.single.darts, hasLength(3));
      expect(state.dartsThrownBy(1), 3);
    });

    test('three-dart average counts darts thrown, not turns', () {
      final state = foldLeg(config(501), [t(20), t(20), t(20)]);
      expect(state.averageFor(1), 180.0);
    });

    test('average is null before a player throws', () {
      expect(initialLegState(config(501)).averageFor(1), isNull);
    });
  });

  group('busting', () {
    test('overshooting reverts the whole turn and ends it', () {
      // On 40, a triple 20 overshoots by 20.
      final state = foldLeg(config(40, players: 2), [t(20)]);
      expect(state.remaining[1], 40, reason: 'score reverts to start of turn');
      expect(state.turns.single.busted, isTrue);
      expect(state.turns.single.scored, 0);
      expect(state.turns.single.darts, hasLength(1));
      expect(state.currentPlayerId, 2, reason: 'the turn ends immediately');
    });

    test('a bust discards points scored earlier in the same turn', () {
      // 100 - 60 - 60 overshoots, so the first triple is discarded too.
      final state = foldLeg(config(100, players: 2), [t(20), t(20)]);
      expect(state.remaining[1], 100);
      expect(state.turns.single.scored, 0);
    });

    test('landing on zero without a double busts', () {
      final state = foldLeg(config(40, players: 2), [s(20), s(20)]);
      expect(state.remaining[1], 40);
      expect(state.turns.single.busted, isTrue);
      expect(state.isFinished, isFalse);
    });

    test('being left on 1 busts, because no double can finish it', () {
      final state = foldLeg(config(20, players: 2), [s(19)]);
      expect(state.remaining[1], 20);
      expect(state.turns.single.busted, isTrue);
    });

    test('the outer bull does not check out', () {
      final state = foldLeg(config(25, players: 2), [sbull]);
      expect(state.isFinished, isFalse);
      expect(state.turns.single.busted, isTrue);
    });

    test('without double-out, landing on zero wins however you get there', () {
      final state = foldLeg(config(40, doubleOut: false), [s(20), s(20)]);
      expect(state.winnerId, 1);
    });

    test('without double-out, being left on 1 is legal', () {
      final state = foldLeg(config(20, players: 2, doubleOut: false), [s(19)]);
      expect(state.remaining[1], 1);
      expect(state.turns, isEmpty, reason: 'the turn is still running');
    });
  });

  group('checking out', () {
    test('a double finishes the leg', () {
      final state = foldLeg(config(40, players: 2), [d(20)]);
      expect(state.winnerId, 1);
      expect(state.isFinished, isTrue);
      expect(state.remaining[1], 0);
      expect(state.turns.single.darts, hasLength(1));
    });

    test('the inner bull finishes the leg', () {
      final state = foldLeg(config(50, players: 2), [dbull]);
      expect(state.winnerId, 1);
    });

    test('darts logged after the win cannot change the result', () {
      final state = foldLeg(config(40, players: 2), [d(20), t(20), t(20)]);
      expect(state.winnerId, 1);
      expect(state.remaining[1], 0);
      expect(state.turns, hasLength(1));
    });
  });

  group('rotation', () {
    test('four players cycle back round after a full round of turns', () {
      final state = foldLeg(config(501, players: 4), [
        for (var i = 0; i < 12; i++) miss,
      ]);
      expect(state.turns, hasLength(4));
      expect(state.turns.map((turn) => turn.playerId), [1, 2, 3, 4]);
      expect(state.currentPlayerId, 1);
      expect(state.dartsThrownThisTurn, 0);
    });

    test('each player keeps their own score', () {
      final state = foldLeg(config(501, players: 2), [
        t(20), t(20), t(20), // player 1: 180
        s(1), s(1), s(1), //   player 2: 3
      ]);
      expect(state.remaining, {1: 321, 2: 498});
    });
  });

  group('starting seat', () {
    test('the first seat leads off unless told otherwise', () {
      expect(initialLegState(config(501, players: 2)).currentPlayerId, 1);
    });

    test('a later seat really does throw the first dart', () {
      final state = foldLeg(config(501, players: 2, startingSeat: 1), [t(20)]);
      expect(state.currentPlayerId, 2);
      expect(state.remaining, {1: 501, 2: 441});
      expect(state.dartsThrownBy(2), 1);
      expect(state.dartsThrownBy(1), 0);
    });

    test('rotation carries on from wherever it started', () {
      final state = foldLeg(config(501, players: 3, startingSeat: 2), [
        for (var i = 0; i < 6; i++) miss,
      ]);
      expect(state.turns.map((turn) => turn.playerId), [3, 1]);
      expect(state.currentPlayerId, 2);
    });

    test('the leg can still be won by whoever leads off', () {
      final state = foldLeg(config(40, players: 2, startingSeat: 1), [d(20)]);
      expect(state.winnerId, 2);
    });
  });

  group('undo, by folding a shorter log', () {
    final log = [t(20), t(20), t(20), s(5)];

    test('the full log has handed over and player 2 has thrown once', () {
      final state = foldLeg(config(501, players: 2), log);
      expect(state.currentPlayerId, 2);
      expect(state.dartsThrownThisTurn, 1);
      expect(state.remaining[2], 496);
    });

    test('dropping one dart rewinds to the start of player 2s turn', () {
      final state = foldLeg(config(501, players: 2), log.sublist(0, 3));
      expect(state.currentPlayerId, 2);
      expect(state.dartsThrownThisTurn, 0);
      expect(state.remaining[2], 501);
    });

    test('dropping two crosses the turn boundary back to player 1', () {
      final state = foldLeg(config(501, players: 2), log.sublist(0, 2));
      expect(state.currentPlayerId, 1);
      expect(state.dartsThrownThisTurn, 2);
      expect(state.remaining[1], 381);
      expect(state.turns, isEmpty);
    });

    test('undoing a checkout puts the leg back in play', () {
      final finished = foldLeg(config(40, players: 2), [d(20)]);
      expect(finished.isFinished, isTrue);
      final rewound = foldLeg(config(40, players: 2), []);
      expect(rewound.isFinished, isFalse);
      expect(rewound.remaining[1], 40);
    });

    test('undoing a bust restores the points it discarded', () {
      final busted = foldLeg(config(100, players: 2), [t(20), t(20)]);
      expect(busted.remaining[1], 100);
      final rewound = foldLeg(config(100, players: 2), [t(20)]);
      expect(rewound.remaining[1], 40);
      expect(rewound.currentPlayerId, 1);
    });
  });
}
