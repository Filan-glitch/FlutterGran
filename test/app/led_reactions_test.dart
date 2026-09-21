import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/atc_controller.dart';
import 'package:fluttergran/app/bulling_controller.dart';
import 'package:fluttergran/app/game_controller.dart';
import 'package:fluttergran/app/lights/led_cue.dart';
import 'package:fluttergran/app/lights/led_reactions.dart';
import 'package:fluttergran/app/training_controller.dart';
import 'package:fluttergran/data/board/led_command.dart';
import 'package:fluttergran/domain/atc/atc_config.dart';
import 'package:fluttergran/domain/atc/atc_reducer.dart';
import 'package:fluttergran/domain/atc/atc_variant.dart';
import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_reducer.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/checkout/checkout_table.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/training/free_practice_state.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:fluttergran/domain/x01/leg_reducer.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:fluttergran/domain/x01/x01_rules.dart';

void main() {
  ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));
  ThrownDart d(int n) => ThrownDart(Segment(n, Ring.doubleRing));
  ThrownDart s(int n) => ThrownDart(Segment(n, Ring.outerSingle));
  const miss = ThrownDart.miss();
  const bull = ThrownDart(Segment.innerBull);

  GameConfig config(int startScore, {int players = 2}) => GameConfig(
    startScore: startScore,
    playerIds: [for (var i = 1; i <= players; i++) i],
  );

  GameSession at(GameConfig cfg, List<ThrownDart> darts, {int? acked}) {
    final leg = foldLeg(cfg, darts);
    return GameSession(leg: leg, acknowledgedTurns: acked ?? leg.turns.length);
  }

  /// Throwing the last of [darts], with every closed turn already confirmed.
  List<LedCue> throwing(
    GameConfig cfg,
    List<ThrownDart> darts, {
    bool endsMatch = true,
  }) {
    final before = at(cfg, darts.sublist(0, darts.length - 1));
    final after = at(cfg, darts, acked: before.leg.turns.length);
    return ledCuesFor(before, after, endsMatch: endsMatch);
  }

  group('x01 darts', () {
    test('nothing before there is a previous state', () {
      expect(ledCuesFor(null, at(config(501), [t(20)]), endsMatch: true), isEmpty);
    });

    test('a hit flashes the number in the thrower\'s seat colour', () {
      expect(throwing(config(501), [t(20)]), [
        DartLanded(Segment(20, Ring.triple), seat: 0),
      ]);
      expect(throwing(config(501), [s(1), s(1), s(1), d(5)]), [
        DartLanded(Segment(5, Ring.doubleRing), seat: 1),
      ]);
    });

    test('a miss flickers', () {
      expect(throwing(config(501), [miss]), [const DartMissed()]);
    });

    test('a bust says so instead of flashing the dart', () {
      expect(throwing(config(40), [t(20)]), [const TurnBusted()]);
    });

    test('ton plus and 180 close a turn with a celebration', () {
      expect(throwing(config(501), [t(20), t(20), s(20)]), [const TonPlus()]);
      expect(throwing(config(501), [t(20), t(20), t(20)]), [const Maximum()]);
    });

    test('a checkout wins the leg, or the match when it is the last one', () {
      final darts = [d(20)];
      expect(throwing(config(40), darts, endsMatch: false), [const LegWon(0)]);
      expect(throwing(config(40), darts), [const MatchWon(0)]);
    });

    test('undo lights nothing', () {
      final cfg = config(501);
      expect(
        ledCuesFor(at(cfg, [t(20), t(20)]), at(cfg, [t(20)]), endsMatch: true),
        isEmpty,
      );
    });

    test('resuming a leg with darts in it lights nothing', () {
      final cfg = config(501);
      expect(
        ledCuesFor(at(cfg, []), at(cfg, [t(20), t(20), t(5)]), endsMatch: true),
        isEmpty,
      );
    });
  });

  group('x01 turns', () {
    test('confirming a turn sweeps in the next player', () {
      final cfg = config(501);
      final darts = [t(20), t(20), s(1)];
      final awaiting = at(cfg, darts, acked: 0);
      final confirmed = at(cfg, darts);
      expect(ledCuesFor(awaiting, confirmed, endsMatch: true), [
        const NextThrower(1),
      ]);
    });

    test('a solo leg has nobody to sweep in', () {
      final cfg = config(501, players: 1);
      final darts = [t(20), t(20), s(1)];
      expect(
        ledCuesFor(at(cfg, darts, acked: 0), at(cfg, darts), endsMatch: true),
        isEmpty,
      );
    });

    test('a fresh leg after a finished one is game on', () {
      final cfg = config(40);
      expect(ledCuesFor(at(cfg, [d(20)]), at(cfg, []), endsMatch: true), [
        const GameOn(),
      ]);
    });
  });

  group('checkout ring', () {
    final table = CheckoutTable(outRule: X01OutRule.double);

    test('lights the next dart yellow and the rest of the route orange', () {
      // 100 is T20 D20: twenty first, then twenty again for the double.
      final ring = checkoutRing(table.bestFor(100, 3));
      expect(ring.colourOf(20), RingColor.yellow);
      expect(ring.byNumber.where((c) => c != RingColor.off), hasLength(1));

      // 61 is T15 D8.
      final other = checkoutRing(table.bestFor(61, 3));
      expect(other.colourOf(15), RingColor.yellow);
      expect(other.colourOf(8), RingColor.orange);
    });

    test('a bull to throw next turns the whole ring turquoise', () {
      expect(checkoutRing(table.bestFor(50, 1)), RingPaint.all(RingColor.turquoise));
    });

    test('is dark with no route, between turns and once the leg is over', () {
      expect(checkoutRing(null), RingPaint.off);

      final leg = foldLeg(config(501), [t(20)]);
      expect(
        x01Ring(leg, awaitingTurnConfirm: false, bestRoute: table.bestFor),
        RingPaint.off,
      );

      final inRange = foldLeg(config(100), []);
      expect(
        x01Ring(inRange, awaitingTurnConfirm: true, bestRoute: table.bestFor),
        RingPaint.off,
      );
      expect(
        x01Ring(inRange, awaitingTurnConfirm: false, bestRoute: table.bestFor),
        isNot(RingPaint.off),
      );
    });

    test('is dark until a player has opened under double in', () {
      final cfg = GameConfig(
        startScore: 100,
        playerIds: const [1],
        inRule: X01InRule.double,
      );
      final leg = foldLeg(cfg, []);
      expect(
        x01Ring(leg, awaitingTurnConfirm: false, bestRoute: table.bestFor),
        RingPaint.off,
      );
    });
  });

  group('around the clock', () {
    final cfg = AtcConfig(playerIds: const [1, 2], variant: AtcVariant.anyPart);
    AtcSession atc(List<ThrownDart> darts) => AtcSession(
      leg: foldAroundTheClock(cfg, darts),
      acknowledgedTurns: foldAroundTheClock(cfg, darts).turns.length,
    );

    test('the target number flashes green, anything else is a miss', () {
      expect(ledCuesForAtc(atc([]), atc([s(1)])), [
        TargetHit(Segment(1, Ring.outerSingle)),
      ]);
      expect(ledCuesForAtc(atc([]), atc([s(7)])), [const DartMissed()]);
    });

    test('the ring shows the current target', () {
      expect(atcRing(atc([])), RingPaint.only({1: RingColor.yellow}));
      expect(atcRing(atc([s(1)])), RingPaint.only({2: RingColor.yellow}));
    });
  });

  group('bulling', () {
    final cfg = BullingConfig(
      playerIds: const [1, 2],
      bullseyeValue: BullseyeValue.two,
      target: 21,
    );
    BullingSession bulling(List<ThrownDart> darts) => BullingSession(
      leg: foldBulling(cfg, darts),
      acknowledgedTurns: foldBulling(cfg, darts).turns.length,
    );

    test('a bull flashes, anything else is a miss', () {
      expect(ledCuesForBulling(bulling([]), bulling([bull])), [
        const DartLanded(Segment.innerBull, seat: 0),
      ]);
      expect(ledCuesForBulling(bulling([]), bulling([t(20)])), [
        const DartMissed(),
      ]);
    });

    test('the ring is turquoise all round while play is live', () {
      expect(bullingRing(bulling([])), RingPaint.all(RingColor.turquoise));
    });
  });

  group('training', () {
    test('free practice flashes every dart', () {
      final before = FreePracticeSession(foldFreePractice([t(20)]));
      final after = FreePracticeSession(foldFreePractice([t(20), miss]));
      expect(ledCuesForTraining(before, after), [const DartMissed()]);
    });

    test('a checkout in checkout practice is a leg won', () {
      final cfg = GameConfig(startScore: 40, playerIds: const [0]);
      final before = CheckoutPracticeSession(
        leg: foldLeg(cfg, []),
        checkoutsCompleted: 0,
      );
      final after = CheckoutPracticeSession(
        leg: foldLeg(cfg, [d(20)]),
        checkoutsCompleted: 1,
      );
      expect(ledCuesForTraining(before, after), [const LegWon(0)]);
      expect(ledCuesForTraining(after, before), [const GameOn()]);
    });
  });
}
