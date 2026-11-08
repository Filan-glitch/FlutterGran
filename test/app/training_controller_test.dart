import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/training_controller.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/domain/segment.dart';

import 'package:fluttergran/domain/training/aim_records.dart';
import 'package:fluttergran/domain/training/aim_target.dart';
import 'package:fluttergran/domain/training/checkout_challenge.dart';
import 'package:fluttergran/domain/training/ladder_121.dart';
import 'package:fluttergran/domain/training/training_drill.dart';
import 'package:fluttergran/domain/training/weak_spot.dart';

import '../support/async.dart';
import '../support/board_clock.dart';
import '../support/darts.dart';

void main() {
  late FakeBoardSource board;
  late BoardClock clock;
  late ProviderContainer container;

  TrainingSession session() => container.read(trainingProvider);
  TrainingController controller() => container.read(trainingProvider.notifier);

  setUp(() {
    board = FakeBoardSource();
    clock = BoardClock();
    container = ProviderContainer(
      overrides: [
        boardSourceProvider.overrideWithValue(board),
        clock.readerFor(board),
        // Drawn targets repeat run to run.
        trainingRandomProvider.overrideWithValue(Random(3)),
      ],
    );
    // Providers auto-dispose without a listener - see the equivalent setUp in
    // game_controller_test.dart.
    container.listen(trainingProvider, (_, _) {});
  });

  tearDown(() {
    container.dispose();
    board.dispose();
  });

  group('free practice', () {
    setUp(() => controller().start(const FreePracticePlan()));

    test('starts with nothing thrown', () {
      final s = session() as FreePracticeSession;
      expect(s.practice.dartsThrown, 0);
    });

    test('addDart folds into the running session', () {
      controller().addDart(t(20));
      final s = session() as FreePracticeSession;
      expect(s.practice.dartsThrown, 1);
      expect(s.practice.totalScored, 60);
    });

    test('never stops accepting darts - there is no win condition', () {
      for (var i = 0; i < 10; i++) {
        controller().addDart(t(20));
      }
      final s = session() as FreePracticeSession;
      expect(s.practice.dartsThrown, 10);
    });

    test('undo drops the last dart', () {
      controller()
        ..addDart(t(20))
        ..addDart(t(19))
        ..undo();
      final s = session() as FreePracticeSession;
      expect(s.practice.darts, [t(20)]);
    });

    test('driven by the board', () async {
      board.hit(const Segment(20, Ring.triple));
      await settle();
      final s = session() as FreePracticeSession;
      expect(s.practice.dartsThrown, 1);
    });

    test('two misses in a row both use a dart', () async {
      board.emitMiss();
      await settle();
      clock.advance();
      board.emitMiss();
      await settle();
      final s = session() as FreePracticeSession;
      expect(s.practice.dartsThrown, 2);
    });

    test('board darts are ignored once the player has left', () async {
      controller().leave();
      board.hit(const Segment(20, Ring.triple));
      await settle();
      final s = session() as FreePracticeSession;
      expect(s.practice.dartsThrown, 0);
    });

    test('board darts are ignored while the keypad is pulled up', () async {
      container.read(keypadOverrideProvider.notifier).set(true);
      board.hit(const Segment(20, Ring.triple));
      await settle();
      expect((session() as FreePracticeSession).practice.dartsThrown, 0);

      container.read(keypadOverrideProvider.notifier).set(false);
      clock.advance();
      board.hit(const Segment(20, Ring.triple));
      await settle();
      expect((session() as FreePracticeSession).practice.dartsThrown, 1);
    });
  });

  group('never persisted', () {
    test('a full checkout session never touches the game repository '
        'or the current-game id', () {
      controller().start(
        const CheckoutChallengePlan(
          CheckoutChallengeConfig(band: CheckoutBand(40, 40), rounds: 2),
        ),
      );
      controller()
        ..addDart(d(20))
        ..throwAgain()
        ..addDart(t(20)) // bust
        ..undo()
        ..addDart(d(20));

      expect(container.exists(gameRepositoryProvider), isFalse);
      expect(container.exists(currentGameIdProvider), isFalse);
      expect(container.exists(databaseProvider), isFalse);
    });
  });

  test('every drill has a default plan', () {
    for (final drill in TrainingDrill.values) {
      expect(TrainingPlan.of(drill).drill, drill);
    }
  });

  group('checkout challenge', () {
    CheckoutChallengeState challenge() =>
        (session() as CheckoutChallengeSession).state;

    setUp(
      () => controller().start(
        const CheckoutChallengePlan(
          CheckoutChallengeConfig(band: CheckoutBand(2, 40), rounds: 3),
        ),
      ),
    );

    test('draws a target from the band before the first dart', () {
      expect(challenge().current!.target, inInclusiveRange(2, 40));
      expect(challenge().targets, hasLength(1));
    });

    test('a finished attempt draws the next, different target', () {
      final first = challenge().current!.target;
      controller()
        ..addDart(miss)
        ..addDart(miss)
        ..addDart(miss);
      expect(challenge().completed, hasLength(1));
      expect(challenge().current!.target, isNot(first));
    });

    test('undo across an attempt boundary drops the target drawn after it', () {
      controller()
        ..addDart(miss)
        ..addDart(miss)
        ..addDart(miss);
      expect(challenge().targets, hasLength(2));

      controller().undo();
      expect(challenge().targets, hasLength(1));
      expect(challenge().current!.dartsUsed, 2);
    });

    test('stops taking darts once every round is thrown', () {
      for (var i = 0; i < 12; i++) {
        controller().addDart(miss);
      }
      expect(challenge().isFinished, isTrue);
      expect(challenge().darts, hasLength(9));
    });

    test('throw again starts a fresh session with the same settings', () {
      controller()
        ..addDart(miss)
        ..throwAgain();
      expect(challenge().darts, isEmpty);
      expect(challenge().config.band, const CheckoutBand(2, 40));
    });

    test('board darts reach it while live', () async {
      board.emitMiss();
      await settle();
      expect(challenge().darts, hasLength(1));
    });
  });

  group('121 ladder', () {
    test('climbs a rung on a finish', () {
      controller()
        ..start(const Ladder121Plan(Ladder121Config(startScore: 81)))
        ..addDart(t(19))
        ..addDart(d(12));
      expect((session() as Ladder121Session).state.target, 82);
    });
  });

  group("bob's 27", () {
    test('a blank visit costs the double', () {
      controller()
        ..start(const Bobs27Plan())
        ..addDart(miss)
        ..addDart(miss)
        ..addDart(miss);
      expect((session() as Bobs27Session).state.score, 25);
    });
  });

  group('weak-spot trainer', () {
    WeakSpotState weakSpot() => (session() as WeakSpotSession).state;

    test('draws from the focus, weighted by history', () {
      controller().start(
        WeakSpotPlan(
          WeakSpotConfig(
            focus: WeakSpotFocus.trebles,
            history: {
              const AimTarget.triple(20): const AimRecord(
                attempts: 100,
                hits: 99,
              ),
            },
          ),
        ),
      );
      expect(weakSpot().currentTarget!.kind, AimKind.triple);
    });

    test('undo back into a visit keeps its target', () {
      controller()
        ..start(const WeakSpotPlan())
        ..addDart(miss)
        ..addDart(miss)
        ..addDart(miss);
      final first = weakSpot().targets.first;
      expect(weakSpot().targets, hasLength(2));

      controller().undo();
      expect(weakSpot().targets, [first]);
      expect(weakSpot().currentTarget, first);
    });
  });
}
