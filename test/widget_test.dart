import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/main.dart';

/// Pumps a few frames to let the roster query land.
///
/// Not `pumpAndSettle`: a focused text field blinks its cursor forever, so
/// there is no settled state to wait for.
Future<void> pumpFrames(WidgetTester tester) async {
  // Long enough to cover a route transition, which is around 300ms.
  for (var i = 0; i < 25; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

Future<void> launch(WidgetTester tester, AppDatabase database) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const FlutterGranApp(),
    ),
  );
  await pumpFrames(tester);
}

/// Tears the tree down inside the test rather than at teardown.
///
/// Cancelling a watched drift query schedules a zero-duration timer, and a
/// timer still pending when the test ends is reported as a failure. Unmounting
/// here gives that timer a frame to fire in.
Future<void> closeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 10));
  await tester.pump(const Duration(milliseconds: 10));
}

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  testWidgets('the app opens on setup, with an empty roster', (tester) async {
    await launch(tester, database);

    expect(find.text('CHALK'), findsOneWidget);
    expect(
      find.text('No players yet. Add the first one above.'),
      findsOneWidget,
    );

    // 501 is the default, and a leg cannot start without a player.
    expect(find.text('501'), findsOneWidget);
    expect(find.text('PICK AT LEAST ONE PLAYER'), findsOneWidget);

    await closeApp(tester);
  });

  testWidgets('the empty roster prompt fits a phone width', (tester) async {
    tester.view.physicalSize = const Size(411, 923);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await launch(tester, database);

    expect(tester.takeException(), isNull);

    await closeApp(tester);
  });

  testWidgets('adding a player seats them and enables the start button', (
    tester,
  ) async {
    await launch(tester, database);

    await tester.enterText(find.byType(TextField), 'Finn');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpFrames(tester);

    expect(find.text('Finn'), findsOneWidget);
    expect(find.text('START LEG'), findsOneWidget);
    expect(find.text('1 of 4'), findsOneWidget);

    await closeApp(tester);
  });

  testWidgets('starting a leg opens the game on the full score', (
    tester,
  ) async {
    await launch(tester, database);

    await tester.enterText(find.byType(TextField), 'Finn');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpFrames(tester);

    await tester.tap(find.text('START LEG'));
    await pumpFrames(tester);

    expect(find.text('501 · DOUBLE OUT'), findsOneWidget);
    // Both the scoreboard and the start-score choice show 501 at this point.
    expect(find.text('501'), findsWidgets);

    await closeApp(tester);
  });

  testWidgets('leaving a leg keeps it, and it can be resumed', (tester) async {
    await launch(tester, database);

    await tester.enterText(find.byType(TextField), 'Finn');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpFrames(tester);
    await tester.tap(find.text('START LEG'));
    await pumpFrames(tester);

    // Throw a treble 20: 501 becomes 441.
    await tester.tap(find.text('TREBLE'));
    await tester.pump();
    await tester.tap(find.text('20'));
    await pumpFrames(tester);
    expect(find.text('441'), findsOneWidget);

    // Back raises the confirmation rather than leaving.
    final route = ModalRoute.of(tester.element(find.text('441')))!;
    unawaited(route.navigator!.maybePop());
    await pumpFrames(tester);
    expect(find.text('Leave this leg?'), findsOneWidget);

    // Staying returns to the leg untouched.
    await tester.tap(find.text('STAY'));
    await pumpFrames(tester);
    expect(find.text('Leave this leg?'), findsNothing);
    expect(find.text('441'), findsOneWidget);

    // Leaving returns to setup, where the leg is offered back.
    unawaited(route.navigator!.maybePop());
    await pumpFrames(tester);
    await tester.tap(find.text('LEAVE'));
    await pumpFrames(tester);

    expect(find.text('CHALK'), findsOneWidget);
    expect(find.text('LEG IN PROGRESS'), findsOneWidget);
    expect(find.text('441'), findsOneWidget);

    // Resuming puts the score back exactly where it was.
    await tester.tap(find.text('RESUME'));
    await pumpFrames(tester);

    expect(find.text('501 · DOUBLE OUT'), findsOneWidget);
    expect(find.text('441'), findsOneWidget);

    await closeApp(tester);
  });

  testWidgets('a leg with no darts leaves without asking', (tester) async {
    await launch(tester, database);

    await tester.enterText(find.byType(TextField), 'Finn');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpFrames(tester);
    await tester.tap(find.text('START LEG'));
    await pumpFrames(tester);

    final route = ModalRoute.of(tester.element(find.text('501 · DOUBLE OUT')))!;
    unawaited(route.navigator!.maybePop());
    await pumpFrames(tester);

    // Nothing thrown, nothing to protect.
    expect(find.text('Leave this leg?'), findsNothing);
    expect(find.text('CHALK'), findsOneWidget);
    expect(find.text('LEG IN PROGRESS'), findsNothing);

    await closeApp(tester);
  });

  testWidgets('the start button lines up with the form above it on a wide '
      'screen', (tester) async {
    tester.view.physicalSize = const Size(1333, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await launch(tester, database);

    final button = tester.getRect(find.byKey(const Key('start-leg-button')));
    final scoreRow = tester.getRect(find.byKey(const Key('start-score-row')));

    expect(button.left, scoreRow.left);
    expect(button.right, scoreRow.right);

    await closeApp(tester);
  });

  group('orientation follows device size', () {
    late List<MethodCall> platformCalls;

    setUp(() {
      platformCalls = [];
      TestDefaultBinaryMessengerBinding
          .instance
          .defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            platformCalls.add(call);
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding
          .instance
          .defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    /// The last orientation list this session asked the platform for, or
    /// null if it never has.
    List<Object?>? lastRequestedOrientations() {
      for (final call in platformCalls.reversed) {
        if (call.method == 'SystemChrome.setPreferredOrientations') {
          return call.arguments as List<Object?>;
        }
      }
      return null;
    }

    testWidgets('locks to landscape on the connected tablet', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1333, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await launch(tester, database);

      expect(
        lastRequestedOrientations(),
        unorderedEquals(['DeviceOrientation.landscapeLeft', 'DeviceOrientation.landscapeRight']),
      );

      await closeApp(tester);
    });

    testWidgets('leaves a phone free to rotate', (tester) async {
      tester.view.physicalSize = const Size(411, 923);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await launch(tester, database);

      expect(lastRequestedOrientations(), isEmpty);

      await closeApp(tester);
    });
  });
}
