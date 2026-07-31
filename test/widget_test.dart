import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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
  for (var i = 0; i < 5; i++) {
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

    expect(find.text('FLUTTERGRAN'), findsOneWidget);
    expect(
      find.text('No players yet. Add the first one above.'),
      findsOneWidget,
    );

    // 501 is the default, and a leg cannot start without a player.
    expect(find.text('501'), findsOneWidget);
    expect(find.text('PICK AT LEAST ONE PLAYER'), findsOneWidget);

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
}
