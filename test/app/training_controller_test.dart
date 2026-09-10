import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/training_controller.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/training/training_drill.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

/// Lets queued stream events reach the controller before assertions run.
Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeBoardSource board;
  late ProviderContainer container;

  TrainingSession session() => container.read(trainingProvider);
  TrainingController controller() => container.read(trainingProvider.notifier);

  setUp(() {
    board = FakeBoardSource();
    container = ProviderContainer(
      overrides: [boardSourceProvider.overrideWithValue(board)],
    );
    // Providers auto-dispose without a listener - see the equivalent setUp in
    // game_controller_test.dart.
    container.listen(trainingProvider, (_, _) {});
  });

  tearDown(() {
    container.dispose();
    board.dispose();
  });

  ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));
  ThrownDart d(int n) => ThrownDart(Segment(n, Ring.doubleRing));

  group('free practice', () {
    setUp(() => controller().start(drill: TrainingDrill.freePractice));

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

    test('board darts are ignored once the player has left', () async {
      controller().leave();
      board.hit(const Segment(20, Ring.triple));
      await settle();
      final s = session() as FreePracticeSession;
      expect(s.practice.dartsThrown, 0);
    });
  });

  group('checkout practice', () {
    setUp(
      () => controller().start(
        drill: TrainingDrill.checkoutPractice,
        startScore: 40,
      ),
    );

    test('starts a solo leg at the chosen score', () {
      final s = session() as CheckoutPracticeSession;
      expect(s.leg.currentRemaining, 40);
      expect(s.checkoutsCompleted, 0);
    });

    test('a checkout finishes the attempt and counts it', () {
      controller().addDart(d(20));
      final s = session() as CheckoutPracticeSession;
      expect(s.leg.isFinished, isTrue);
      expect(s.checkoutsCompleted, 1);
    });

    test('a stray dart after checkout does not restart the attempt', () {
      controller()
        ..addDart(d(20))
        ..addDart(d(20));
      final s = session() as CheckoutPracticeSession;
      expect(s.leg.darts, hasLength(1));
      expect(s.checkoutsCompleted, 1);
    });

    test('throwAgain resets the attempt but keeps the count', () {
      controller()
        ..addDart(d(20))
        ..throwAgain();
      final s = session() as CheckoutPracticeSession;
      expect(s.leg.darts, isEmpty);
      expect(s.leg.currentRemaining, 40);
      expect(s.checkoutsCompleted, 1);
    });

    test('undoing the checkout dart un-completes the attempt', () {
      controller()
        ..addDart(d(20))
        ..undo();
      final s = session() as CheckoutPracticeSession;
      expect(s.leg.isFinished, isFalse);
      expect(s.checkoutsCompleted, 0);
    });

    test('a bust does not count as a checkout', () {
      controller().addDart(t(20)); // 40 - 60, busts
      final s = session() as CheckoutPracticeSession;
      expect(s.leg.currentRemaining, 40);
      expect(s.checkoutsCompleted, 0);
    });
  });

  group('never persisted', () {
    test(
      'a full checkout-practice session never touches the game repository '
      'or the current-game id',
      () {
        controller().start(drill: TrainingDrill.checkoutPractice, startScore: 40);
        controller()
          ..addDart(d(20))
          ..throwAgain()
          ..addDart(t(20)) // bust
          ..undo()
          ..addDart(d(20));

        expect(container.exists(gameRepositoryProvider), isFalse);
        expect(container.exists(currentGameIdProvider), isFalse);
        expect(container.exists(databaseProvider), isFalse);
      },
    );
  });
}
