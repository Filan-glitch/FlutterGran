import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/rules_topic.dart';
import 'package:fluttergran/app/screens/rules_detail_screen.dart';
import 'package:fluttergran/app/screens/training_game_screen.dart';
import 'package:fluttergran/app/screens/training_setup_screen.dart';
import 'package:fluttergran/app/training_controller.dart';
import 'package:fluttergran/app/widgets/player_picker.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/domain/training/aim_target.dart';
import 'package:fluttergran/domain/training/checkout_challenge.dart';
import 'package:fluttergran/domain/training/training_drill.dart';
import 'package:fluttergran/domain/training/weak_spot.dart';

import '../support/database.dart';
import '../support/pump.dart';

void main() {
  late AppDatabase database;
  late FakeBoardSource board;
  late ProviderContainer container;

  setUp(() {
    database = memoryDatabase();
    board = FakeBoardSource();
    container = ProviderContainer(
      overrides: [
        // The Weak-spot Trainer's player picker reads the roster.
        databaseProvider.overrideWithValue(database),
        boardSourceProvider.overrideWithValue(board),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await board.dispose();
    await database.close();
  });

  /// The drill list is long enough that a drill's options can start below
  /// the fold.
  /// Scrolls [key] fully on screen. `scrollUntilVisible` alone stops as soon
  /// as the row is built, which can still leave it in the list's cache area
  /// below the start bar, out of reach of a tap.
  Future<void> revealOption(WidgetTester tester, Key key) async {
    await tester.scrollUntilVisible(
      find.byKey(key),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(key));
    await tester.pumpAndSettle();
  }

  Future<void> pump(WidgetTester tester) async {
    await pumpApp(tester, const TrainingSetupScreen(), container: container);
  }

  testWidgets('the rules icon opens the training rules, scoped to it alone', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    final detail = tester.widget<RulesDetailScreen>(
      find.byType(RulesDetailScreen),
    );
    expect(detail.topic, RulesTopic.training);
    expect(find.text('TRAINING RULES'), findsOneWidget);
  });

  testWidgets('offers every drill', (tester) async {
    await pump(tester);

    expect(find.text('FREE PRACTICE'), findsOneWidget);
    for (final drill in TrainingDrill.values) {
      expect(find.byKey(Key('drill-${drill.name}')), findsOneWidget);
    }
    expect(find.byKey(const Key('drill-checkoutPractice')), findsNothing);
  });

  testWidgets('starting free practice opens the game screen unscored', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('start-training-button')));
    await tester.pumpAndSettle();

    expect(find.byType(TrainingGameScreen), findsOneWidget);
    expect(find.text('FREE PRACTICE'), findsOneWidget);
    expect(
      container.read(trainingProvider),
      isA<FreePracticeSession>().having(
        (session) => session.practice.dartsThrown,
        'dartsThrown',
        0,
      ),
    );
  });

  testWidgets('checkout challenge starts with the band, rule and hint chosen', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('drill-checkoutChallenge')));
    await tester.pump();
    await revealOption(tester, const Key('training-band-row'));
    await tester.tap(find.text('41–80'));
    await revealOption(tester, const Key('training-route-row'));
    await tester.tap(find.text('AFTER THE VISIT'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('start-training-button')));
    await tester.pumpAndSettle();

    final session = container.read(trainingProvider);
    expect(session, isA<CheckoutChallengeSession>());
    final state = (session as CheckoutChallengeSession).state;
    expect(state.config.band, const CheckoutBand(41, 80));
    expect(state.config.showRoute, isFalse);
    expect(state.current!.target, inInclusiveRange(41, 80));
  });

  testWidgets('121 ladder starts on the chosen rung', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('drill-ladder121')));
    await tester.pump();
    await revealOption(tester, const Key('training-ladder-start-row'));
    await tester.tap(find.text('81'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('start-training-button')));
    await tester.pumpAndSettle();

    final session = container.read(trainingProvider) as Ladder121Session;
    expect(session.state.target, 81);
  });

  testWidgets('bob\'s 27 can be set to play on', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('drill-bobs27')));
    await tester.pump();
    await revealOption(tester, const Key('training-play-to-end-row'));
    await tester.tap(find.text('PLAY ON'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('start-training-button')));
    await tester.pumpAndSettle();

    final session = container.read(trainingProvider) as Bobs27Session;
    expect(session.state.config.playToEnd, isTrue);
  });

  testWidgets('weak-spot trainer asks for a player only for that drill', (
    tester,
  ) async {
    await pump(tester);
    expect(find.byType(PlayerPicker), findsNothing);

    await tester.tap(find.byKey(const Key('drill-weakSpot')));
    await tester.pump();
    await revealOption(tester, const Key('training-focus-row'));
    await tester.tap(find.text('TREBLES'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byType(PlayerPicker),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(PlayerPicker), findsOneWidget);

    await tester.tap(find.byKey(const Key('start-training-button')));
    await tester.pumpAndSettle();

    final session = container.read(trainingProvider) as WeakSpotSession;
    expect(session.state.config.focus, WeakSpotFocus.trebles);
    expect(session.state.config.history, isEmpty);
    expect(session.state.currentTarget!.kind, AimKind.triple);
  });
}
