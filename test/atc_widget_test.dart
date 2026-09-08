import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/widgets/dart_keypad.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/main.dart';

/// The keypad always shows every number 1-20 as a static key, and the
/// scoreboard shows a player's current stop with the same digits - so a bare
/// `find.text('1')` is ambiguous between "the button to tap" and "the number
/// on screen already". These two pin down which is meant.
Finder keypadKey(String label) =>
    find.descendant(of: find.byType(DartKeypad), matching: find.text(label));

Finder scoreboardText(String label) => find.descendant(
  of: find.byKey(const Key('atc-scoreboard')),
  matching: find.text(label),
);

/// Pumps a few frames to let a route transition or a roster query land.
Future<void> pumpFrames(WidgetTester tester) async {
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
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump(const Duration(milliseconds: 500));
}

/// From the main menu, walks Play -> Select Game Mode -> Around the Clock
/// Setup.
Future<void> openAtcSetup(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('menu-play-button')));
  await pumpFrames(tester);

  await tester.tap(find.text('AROUND THE CLOCK'));
  await pumpFrames(tester);
}

Future<void> popRoute(WidgetTester tester, Finder onScreen) async {
  final route = ModalRoute.of(tester.element(onScreen))!;
  unawaited(route.navigator!.maybePop());
  await pumpFrames(tester);
}

Future<void> closeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 10));
  await tester.pump(const Duration(milliseconds: 10));
}

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  testWidgets('the mode picker offers Around the Clock', (tester) async {
    await launch(tester, database);

    await tester.tap(find.byKey(const Key('menu-play-button')));
    await pumpFrames(tester);

    expect(find.text('AROUND THE CLOCK'), findsOneWidget);

    await closeApp(tester);
  });

  testWidgets('reaches setup with the default variant selected', (
    tester,
  ) async {
    await launch(tester, database);
    await openAtcSetup(tester);

    expect(find.text('AROUND THE CLOCK SETUP'), findsOneWidget);
    expect(find.text('PICK AT LEAST ONE PLAYER'), findsOneWidget);
    expect(find.text('ANY PART'), findsOneWidget);
    expect(find.text('MASTERS'), findsOneWidget);
    expect(find.text('DOUBLES ONLY'), findsOneWidget);

    await closeApp(tester);
  });

  testWidgets('starting a leg opens the game with everyone on stop 1', (
    tester,
  ) async {
    await launch(tester, database);
    await openAtcSetup(tester);

    await tester.enterText(find.byType(TextField), 'Finn');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpFrames(tester);

    await tester.tap(find.text('START LEG'));
    await pumpFrames(tester);

    expect(find.text('ANY PART'), findsOneWidget);
    expect(scoreboardText('1'), findsOneWidget);

    await closeApp(tester);
  });

  testWidgets('a hit on the current number advances the stop shown', (
    tester,
  ) async {
    await launch(tester, database);
    await openAtcSetup(tester);

    await tester.enterText(find.byType(TextField), 'Finn');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpFrames(tester);
    await tester.tap(find.text('START LEG'));
    await pumpFrames(tester);

    expect(scoreboardText('1'), findsOneWidget);
    await tester.tap(keypadKey('1'));
    await pumpFrames(tester);

    expect(scoreboardText('2'), findsOneWidget);
    expect(scoreboardText('1'), findsNothing);

    await closeApp(tester);
  });

  testWidgets('leaving a leg keeps it, and it can be resumed from the main '
      'menu', (tester) async {
    await launch(tester, database);
    await openAtcSetup(tester);

    await tester.enterText(find.byType(TextField), 'Finn');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpFrames(tester);
    await tester.tap(find.text('START LEG'));
    await pumpFrames(tester);

    await tester.tap(keypadKey('1'));
    await pumpFrames(tester);

    await popRoute(tester, find.text('ANY PART'));
    expect(find.text('Leave this leg?'), findsOneWidget);
    await tester.tap(find.text('LEAVE'));
    await pumpFrames(tester);

    expect(find.text('AROUND THE CLOCK SETUP'), findsOneWidget);

    await popRoute(tester, find.text('AROUND THE CLOCK SETUP'));
    expect(find.text('SELECT GAME MODE'), findsOneWidget);
    await popRoute(tester, find.text('SELECT GAME MODE'));

    expect(find.text('LEG IN PROGRESS'), findsOneWidget);
    expect(find.text('ANY PART'), findsOneWidget);

    await tester.tap(find.text('RESUME'));
    await pumpFrames(tester);

    expect(find.text('ANY PART'), findsOneWidget);

    await closeApp(tester);
  });
}
