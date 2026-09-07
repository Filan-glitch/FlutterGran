import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/main.dart';

/// Pumps a few frames to let a route transition or a roster query land.
///
/// Not `pumpAndSettle`: a focused text field blinks its cursor forever, so
/// there is no settled state to wait for once a form is on screen.
Future<void> pumpFrames(WidgetTester tester) async {
  // Long enough to cover a route transition, which is around 300ms.
  for (var i = 0; i < 25; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

/// Launches the app and clears the splash screen, landing on the main menu.
///
/// Not `pumpAndSettle`: it stops as soon as one pump fails to schedule a new
/// frame, which the splash screen's bare 700ms `Timer` never does on its own
/// while it is idling. An explicit pump past that floor, with margin for the
/// route transition to the main menu, is what actually drives it forward.
Future<void> launch(WidgetTester tester, AppDatabase database) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const FlutterGranApp(),
    ),
  );
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump(const Duration(milliseconds: 500));
}

/// From the main menu, walks Play -> Select Game Mode -> X01 Setup.
Future<void> openX01Setup(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('menu-play-button')));
  await pumpFrames(tester);

  await tester.tap(find.text('X01'));
  await pumpFrames(tester);
}

/// Pops the current route via its own [ModalRoute], the same way the
/// leave-a-leg confirmation below already does - `Navigator.pop` needs no
/// widget to tap, which matters once a screen (like the main menu) has no
/// back button of its own to find.
Future<void> popRoute(WidgetTester tester, Finder onScreen) async {
  final route = ModalRoute.of(tester.element(onScreen))!;
  unawaited(route.navigator!.maybePop());
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

  testWidgets('the app opens on the main menu, and play reaches an empty '
      'roster', (tester) async {
    await launch(tester, database);

    expect(find.text('CHALK'), findsOneWidget);
    expect(find.byKey(const Key('menu-play-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('menu-play-button')));
    await pumpFrames(tester);

    expect(find.text('SELECT GAME MODE'), findsOneWidget);
    expect(find.text('X01'), findsOneWidget);

    await tester.tap(find.text('X01'));
    await pumpFrames(tester);

    expect(find.text('X01 SETUP'), findsOneWidget);
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
    await openX01Setup(tester);

    expect(tester.takeException(), isNull);

    await closeApp(tester);
  });

  testWidgets('adding a player seats them and enables the start button', (
    tester,
  ) async {
    await launch(tester, database);
    await openX01Setup(tester);

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
    await openX01Setup(tester);

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

  testWidgets('leaving a leg keeps it, and it can be resumed from the main '
      'menu', (tester) async {
    await launch(tester, database);
    await openX01Setup(tester);

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
    await popRoute(tester, find.text('441'));
    expect(find.text('Leave this leg?'), findsOneWidget);

    // Staying returns to the leg untouched.
    await tester.tap(find.text('STAY'));
    await pumpFrames(tester);
    expect(find.text('Leave this leg?'), findsNothing);
    expect(find.text('441'), findsOneWidget);

    // Leaving returns to X01 setup - the resume offer moved to the main
    // menu, so it is not shown here any more.
    await popRoute(tester, find.text('441'));
    await tester.tap(find.text('LEAVE'));
    await pumpFrames(tester);

    expect(find.text('X01 SETUP'), findsOneWidget);
    expect(find.text('LEG IN PROGRESS'), findsNothing);

    // Walking all the way back to the main menu is where the leg is offered.
    await popRoute(tester, find.text('X01 SETUP'));
    expect(find.text('SELECT GAME MODE'), findsOneWidget);
    await popRoute(tester, find.text('SELECT GAME MODE'));

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
    await openX01Setup(tester);

    await tester.enterText(find.byType(TextField), 'Finn');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpFrames(tester);
    await tester.tap(find.text('START LEG'));
    await pumpFrames(tester);

    await popRoute(tester, find.text('501 · DOUBLE OUT'));

    // Nothing thrown, nothing to protect - straight back to setup, with
    // nothing left to resume.
    expect(find.text('Leave this leg?'), findsNothing);
    expect(find.text('X01 SETUP'), findsOneWidget);

    await closeApp(tester);
  });

  testWidgets('the start button lines up with the form above it on a wide '
      'screen', (tester) async {
    tester.view.physicalSize = const Size(1333, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await launch(tester, database);
    await openX01Setup(tester);

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
