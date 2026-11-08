import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/training_game_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/app/training_controller.dart';
import 'package:fluttergran/app/widgets/checkout_card.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/training/bobs_27.dart';
import 'package:fluttergran/domain/training/checkout_challenge.dart';
import 'package:fluttergran/domain/training/weak_spot.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

import '../support/pump.dart';
import '../support/sound.dart';

void main() {
  late FakeBoardSource board;
  late ProviderContainer container;
  late RecordingSoundPlayer player;

  TrainingController controller() => container.read(trainingProvider.notifier);

  setUp(() {
    board = FakeBoardSource();
    player = RecordingSoundPlayer();
    container = ProviderContainer(
      overrides: [
        boardSourceProvider.overrideWithValue(board),
        soundPlayerProvider.overrideWithValue(player),
        trainingRandomProvider.overrideWithValue(Random(5)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    board.dispose();
  });

  Future<void> pump(WidgetTester tester) async {
    await pumpApp(tester, const TrainingGameScreen(), container: container);
  }

  /// Lets a board frame travel through the stream pipeline before the next
  /// assertion runs. `board.hit` fires real broadcast-stream microtasks that
  /// a `pump()` alone does not flush inside the fake-async zone a widget
  /// test runs in, so this steps outside it for one real event-loop turn.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
  }

  group('free practice', () {
    setUp(() => controller().start(const FreePracticePlan()));

    testWidgets('a board hit shows the dart and updates the session stats', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('·'), findsNWidgets(3));

      board.hit(const Segment(20, Ring.triple));
      await settle(tester);

      expect(find.text('T20'), findsOneWidget);
      expect(find.text('60'), findsWidgets);
    });
  });

  group('checkout practice', () {
    /// The big remaining score, not the same figure repeated in the
    /// checkout card's header and on its D20 chip.
    Finder remainingScore(String score) => find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == score &&
          widget.style?.fontSize == Type.score.fontSize,
    );

    setUp(() => controller().start(const CheckoutPracticePlan(startScore: 40)));

    testWidgets('shows the remaining score and the checkout suggestion', (
      tester,
    ) async {
      await pump(tester);

      expect(remainingScore('40'), findsOneWidget);
      expect(find.text('CHECKOUT'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(checkoutNextDartKey),
          matching: find.text('D20'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('checking out shows the completion panel', (tester) async {
      await pump(tester);

      controller().addDart(const ThrownDart(Segment(20, Ring.doubleRing)));
      await tester.pump();

      expect(find.text('CHECKED OUT'), findsOneWidget);
      expect(find.text('in 1 dart'), findsOneWidget);
      expect(find.text('CHECKOUTS THIS SESSION: 1'), findsOneWidget);
    });

    testWidgets('throw again resets the attempt and keeps the count', (
      tester,
    ) async {
      await pump(tester);

      controller().addDart(const ThrownDart(Segment(20, Ring.doubleRing)));
      await tester.pump();
      await tester.tap(find.byKey(const Key('throw-again-button')));
      await tester.pump();

      expect(find.text('CHECKED OUT'), findsNothing);
      expect(remainingScore('40'), findsOneWidget);
      expect(find.text('CHECKOUTS THIS SESSION: 1'), findsOneWidget);
    });

    testWidgets('done leaves the screen', (tester) async {
      await pump(tester);

      controller().addDart(const ThrownDart(Segment(20, Ring.doubleRing)));
      await tester.pump();
      await tester.tap(find.byKey(const Key('training-done-button')));
      await tester.pumpAndSettle();

      expect(find.byType(TrainingGameScreen), findsNothing);
    });

    testWidgets(
      'leaving after a checkout silences any delayed speech still queued',
      (tester) async {
        await pump(tester);

        // The checkout cue queues a delayed "game shot" line behind it -
        // still pending when the player walks away from the screen.
        controller().addDart(const ThrownDart(Segment(20, Ring.doubleRing)));
        await tester.pump();

        await tester.tap(find.byKey(const Key('training-done-button')));
        await tester.pumpAndSettle();

        expect(player.silenced, greaterThan(0));
      },
    );

    testWidgets(
      'turning sound off mid-session silences a line already queued',
      (tester) async {
        await pump(tester);

        controller().addDart(const ThrownDart(Segment(20, Ring.doubleRing)));
        await tester.pump();
        final silencedBefore = player.silenced;

        // Nothing about the training session changes here - only the
        // toggle - so a fresh dart is not what should trigger this.
        //
        // Deliberately not awaited: `BoolSetting.set` flips `state`
        // synchronously before its first `await` (the shared_preferences
        // write), which is all this needs - awaiting the returned future
        // here would await a real plugin channel call from inside the
        // fake-async test zone, which never resolves without a `pump` in
        // between and deadlocks the test.
        unawaited(container.read(soundEnabledProvider.notifier).set(false));
        await tester.pump();

        expect(player.silenced, greaterThan(silencedBefore));
      },
    );
  });

  group('checkout challenge', () {
    testWidgets('a hidden route shows a hint, then the best route after a '
        'miss', (tester) async {
      controller().start(
        const CheckoutChallengePlan(
          CheckoutChallengeConfig(
            band: CheckoutBand(40, 40),
            rounds: 2,
            showRoute: false,
          ),
        ),
      );
      await pump(tester);
      expect(find.byType(CheckoutCard), findsNothing);
      expect(
        find.text('Work it out - the route shows after the visit'),
        findsOneWidget,
      );

      for (var i = 0; i < 3; i++) {
        controller().addDart(const ThrownDart.miss());
      }
      await tester.pump();
      expect(find.text('40 MISSED'), findsOneWidget);
      expect(find.text('Best was 40: D20'), findsOneWidget);
    });

    testWidgets('the end shows the session summary', (tester) async {
      controller().start(
        const CheckoutChallengePlan(
          CheckoutChallengeConfig(band: CheckoutBand(40, 40), rounds: 1),
        ),
      );
      await pump(tester);
      controller().addDart(const ThrownDart(Segment(20, Ring.doubleRing)));
      await tester.pumpAndSettle();

      expect(find.text('SESSION COMPLETE'), findsOneWidget);
      expect(find.text('1 of 1 checked out'), findsOneWidget);
      expect(find.byKey(const Key('throw-again-button')), findsOneWidget);
    });
  });

  testWidgets("bob's 27 shows the knock-out", (tester) async {
    controller().start(const Bobs27Plan(Bobs27Config()));
    await pump(tester);
    expect(find.text('D1'), findsWidgets);

    for (var i = 0; i < 15; i++) {
      controller().addDart(const ThrownDart.miss());
    }
    await tester.pumpAndSettle();
    expect(find.text('KNOCKED OUT'), findsOneWidget);
  });

  testWidgets('the weak-spot summary names the usual miss', (tester) async {
    controller().start(
      const WeakSpotPlan(
        WeakSpotConfig(focus: WeakSpotFocus.singles, rounds: 1),
      ),
    );
    await pump(tester);
    final target = (container.read(
      trainingProvider,
    ) as WeakSpotSession).state.currentTarget!;

    for (var i = 0; i < 3; i++) {
      controller().addDart(const ThrownDart.miss());
    }
    await tester.pumpAndSettle();

    expect(find.text('SESSION COMPLETE'), findsOneWidget);
    expect(
      find.textContaining('${target.label}: 0 of 3, misses mostly outside'),
      findsOneWidget,
    );
  });
}
