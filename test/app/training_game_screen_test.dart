import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/audio/sound_controller.dart' show SoundPlayer;
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/training_game_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/app/training_controller.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/training/training_drill.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:fluttergran/l10n/app_localizations.dart';

/// Records rather than plays, and - unlike `AudioPlayersSoundPlayer` -
/// schedules no real `Timer` for a delayed line, which would otherwise
/// outlive the widget tree these tests tear down. Same shape as the
/// `_FakePlayer` in `sound_controller_test.dart`.
class _FakePlayer implements SoundPlayer {
  int silenced = 0;

  @override
  void playCue(String asset) {}

  @override
  void playSpeech(String asset, {Duration after = Duration.zero}) {}

  @override
  void silence() => silenced++;

  @override
  Future<void> dispose() async {}
}

void main() {
  late FakeBoardSource board;
  late ProviderContainer container;
  late _FakePlayer player;

  TrainingController controller() => container.read(trainingProvider.notifier);

  setUp(() {
    board = FakeBoardSource();
    player = _FakePlayer();
    container = ProviderContainer(
      overrides: [
        boardSourceProvider.overrideWithValue(board),
        soundPlayerProvider.overrideWithValue(player),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    board.dispose();
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(),
          home: const TrainingGameScreen(),
        ),
      ),
    );
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
    setUp(() => controller().start(drill: TrainingDrill.freePractice));

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
    setUp(
      () => controller().start(
        drill: TrainingDrill.checkoutPractice,
        startScore: 40,
      ),
    );

    testWidgets('shows the remaining score and the checkout suggestion', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text('40'), findsOneWidget);
      expect(find.text('CHECKOUT'), findsOneWidget);
      expect(find.text('D20'), findsOneWidget);
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
      expect(find.text('40'), findsOneWidget);
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
}
