import 'package:fluttergran/domain/atc/atc_config.dart';
import 'package:fluttergran/domain/atc/atc_reducer.dart';
import 'package:fluttergran/domain/atc/atc_variant.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:test/test.dart';

ThrownDart s(int n) => ThrownDart(Segment(n, Ring.outerSingle));
ThrownDart d(int n) => ThrownDart(Segment(n, Ring.doubleRing));
ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));
const ThrownDart miss = ThrownDart.miss();
final ThrownDart sbull = ThrownDart(Segment.outerBull);
final ThrownDart dbull = ThrownDart(Segment.innerBull);

AtcConfig config({
  int players = 1,
  AtcVariant variant = AtcVariant.anyPart,
}) => AtcConfig(
  playerIds: [for (var i = 1; i <= players; i++) i],
  variant: variant,
);

void main() {
  group('opening state', () {
    test('everyone starts on stop 1 with three darts', () {
      final state = initialAtcLegState(config(players: 3));
      expect(state.stopIndex, {1: 0, 2: 0, 3: 0});
      expect(state.currentPlayerId, 1);
      expect(state.dartsThrownThisTurn, 0);
      expect(state.dartsLeftThisTurn, 3);
      expect(state.isFinished, isFalse);
      expect(state.turns, isEmpty);
    });
  });

  group('advancing', () {
    test('a hit on the current number advances by one', () {
      final state = foldAroundTheClock(config(players: 2), [s(1)]);
      expect(state.stopIndex[1], 1);
    });

    test('a miss does not advance', () {
      final state = foldAroundTheClock(config(players: 2), [miss]);
      expect(state.stopIndex[1], 0);
    });

    test('a hit on the wrong number does not advance', () {
      final state = foldAroundTheClock(config(players: 2), [s(5)]);
      expect(state.stopIndex[1], 0);
    });

    test('multiple stops can clear in one turn', () {
      final state = foldAroundTheClock(config(players: 2), [s(1), s(2), s(3)]);
      expect(state.stopIndex[1], 3);
      expect(state.turns.single.stopBefore, 0);
      expect(state.turns.single.stopAfter, 3);
    });

    test('a turn always closes after three darts, hits or not', () {
      final state = foldAroundTheClock(config(players: 2), [s(1), miss, miss]);
      expect(state.turns, hasLength(1));
      expect(state.currentPlayerId, 2);
    });

    test('a triple never advances more than one stop', () {
      final state = foldAroundTheClock(config(players: 2), [t(1)]);
      expect(state.stopIndex[1], 1);
    });
  });

  group('bull and bullseye', () {
    // Single player throughout: with more than one seated, the turn boundary
    // (every 3 darts) would hand a 22-dart log to whoever is up next, which
    // is not what these tests are about.
    test('stop 21 (index 20) needs the outer bull', () {
      final log = [for (var n = 1; n <= 20; n++) s(n)];
      final withoutBull = foldAroundTheClock(config(), log);
      expect(withoutBull.stopIndex[1], 20);
      expect(withoutBull.isFinished, isFalse);

      final withBull = foldAroundTheClock(config(), [...log, sbull]);
      expect(withBull.stopIndex[1], 21);
    });

    test('the inner bull does not clear the outer bull stop', () {
      final log = [for (var n = 1; n <= 20; n++) s(n), dbull];
      final state = foldAroundTheClock(config(), log);
      expect(state.stopIndex[1], 20, reason: 'still needs the outer bull');
    });

    test('clearing the bullseye wins the leg', () {
      final log = [for (var n = 1; n <= 20; n++) s(n), sbull, dbull];
      final state = foldAroundTheClock(config(), log);
      expect(state.winnerId, 1);
      expect(state.isFinished, isTrue);
    });

    test('darts logged after the win cannot change the result', () {
      final log = [
        for (var n = 1; n <= 20; n++) s(n),
        sbull,
        dbull,
        t(20),
        t(20),
      ];
      final state = foldAroundTheClock(config(), log);
      expect(state.winnerId, 1);
      expect(state.turns.last.darts, hasLength(1), reason: 'the winning dart alone closes the turn');
    });
  });

  group('variants', () {
    test('masters rejects a single, needs a double or triple', () {
      final state = foldAroundTheClock(
        config(players: 2, variant: AtcVariant.masters),
        [s(1), d(1)],
      );
      expect(state.stopIndex[1], 1, reason: 'the single did nothing, the double advanced once');
    });

    test('doubles only rejects a triple', () {
      final state = foldAroundTheClock(
        config(players: 2, variant: AtcVariant.doublesOnly),
        [t(1), d(1)],
      );
      expect(state.stopIndex[1], 1, reason: 'the triple did nothing, the double advanced once');
    });

    test('bull stops ignore the variant entirely', () {
      final log = [for (var n = 1; n <= 20; n++) d(n)];
      final state = foldAroundTheClock(
        config(variant: AtcVariant.doublesOnly),
        [...log, sbull],
      );
      expect(state.stopIndex[1], 21, reason: 'any hit clears a bull stop, even under doubles only');
    });
  });

  group('rotation', () {
    test('turns hand over between players', () {
      final state = foldAroundTheClock(config(players: 2), [
        s(1), miss, miss, // player 1's turn
        s(1), miss, miss, // player 2's turn
      ]);
      expect(state.turns, hasLength(2));
      expect(state.turns.map((turn) => turn.playerId), [1, 2]);
      expect(state.currentPlayerId, 1);
    });
  });

  group('undo, by folding a shorter log', () {
    final log = [s(1), s(2), s(3), s(1)];

    test('the full log has handed over and player 2 has thrown once', () {
      final state = foldAroundTheClock(config(players: 2), log);
      expect(state.currentPlayerId, 2);
      expect(state.dartsThrownThisTurn, 1);
      expect(state.stopIndex[2], 1);
    });

    test('dropping the last dart rewinds to the start of player 2s turn', () {
      final state = foldAroundTheClock(config(players: 2), log.sublist(0, 3));
      expect(state.currentPlayerId, 2);
      expect(state.dartsThrownThisTurn, 0);
      expect(state.stopIndex[2], 0);
    });
  });
}
