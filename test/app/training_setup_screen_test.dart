import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/training_game_screen.dart';
import 'package:fluttergran/app/screens/training_setup_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/app/training_controller.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';

void main() {
  late FakeBoardSource board;
  late ProviderContainer container;

  setUp(() {
    board = FakeBoardSource();
    container = ProviderContainer(
      overrides: [boardSourceProvider.overrideWithValue(board)],
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
          theme: buildTheme(),
          home: const TrainingSetupScreen(),
        ),
      ),
    );
  }

  testWidgets('offers free practice and checkout practice', (tester) async {
    await pump(tester);

    expect(find.text('FREE PRACTICE'), findsOneWidget);
    expect(find.text('CHECKOUT PRACTICE'), findsOneWidget);
    // The start-score picker is only relevant to checkout practice.
    expect(find.byKey(const Key('training-start-score-row')), findsNothing);
  });

  testWidgets('picking checkout practice reveals the start-score picker', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.text('CHECKOUT PRACTICE'));
    await tester.pump();

    expect(find.byKey(const Key('training-start-score-row')), findsOneWidget);
    expect(find.text('501'), findsOneWidget);
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

  testWidgets('starting checkout practice opens the game screen at the '
      'chosen score', (tester) async {
    await pump(tester);

    await tester.tap(find.text('CHECKOUT PRACTICE'));
    await tester.pump();
    await tester.tap(find.text('701'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('start-training-button')));
    await tester.pumpAndSettle();

    expect(find.byType(TrainingGameScreen), findsOneWidget);
    expect(find.text('701 · CHECKOUT PRACTICE'), findsOneWidget);
    expect(
      container.read(trainingProvider),
      isA<CheckoutPracticeSession>().having(
        (session) => session.startScore,
        'startScore',
        701,
      ),
    );
  });
}
