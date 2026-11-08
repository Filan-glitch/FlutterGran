import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/roster_screen.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';

import '../support/database.dart';
import '../support/pump.dart';

void main() {
  late AppDatabase database;
  late GameRepository repository;
  late ProviderContainer container;

  setUp(() {
    database = memoryDatabase();
    repository = GameRepository(database);
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  /// Lets a delete's undo snackbar run its whole course - in, the window,
  /// out - without UNDO being tapped.
  Future<void> waitOutUndo(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 2));
    }
    await pumpFrames(tester, count: 12);
  }

  Future<void> open(WidgetTester tester) async {
    await pumpApp(tester, const RosterScreen(), container: container);
    await pumpFrames(tester, count: 12);
  }

  /// Tears the widget tree down before the container is disposed, so a
  /// snackbar's own dismiss timer, or the roster query's cancellation
  /// timer, gets a frame to fire in rather than being reported as still
  /// pending.
  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 10));
  }

  testWidgets('adding a player via the field shows them in the list', (
    tester,
  ) async {
    await open(tester);

    await tester.enterText(find.byType(TextField), 'Finn');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpFrames(tester, count: 12);

    expect(find.text('Finn'), findsOneWidget);
    expect((await repository.allPlayers()).single.name, 'Finn');

    await close(tester);
  });

  testWidgets('the empty roster shows the empty-state prompt', (tester) async {
    await open(tester);

    expect(
      find.text('No players yet. Add the first one above.'),
      findsOneWidget,
    );

    await close(tester);
  });

  testWidgets('tapping a name, editing it, and submitting renames them', (
    tester,
  ) async {
    final finn = await repository.addPlayer('Finn');
    await open(tester);

    await tester.tap(find.byKey(Key('player-name-${finn.id}')));
    await pumpFrames(tester, count: 12);

    await tester.enterText(
      find.byKey(Key('rename-field-${finn.id}')),
      'Finlay',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpFrames(tester, count: 12);

    expect(find.text('Finlay'), findsOneWidget);
    expect(find.text('Finn'), findsNothing);
    expect((await repository.allPlayers()).single.name, 'Finlay');

    await close(tester);
  });

  testWidgets('renaming to a blank value is rejected, name unchanged', (
    tester,
  ) async {
    final finn = await repository.addPlayer('Finn');
    await open(tester);

    await tester.tap(find.byKey(Key('player-name-${finn.id}')));
    await pumpFrames(tester, count: 12);

    await tester.enterText(find.byKey(Key('rename-field-${finn.id}')), '   ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpFrames(tester, count: 12);

    expect(find.text('Finn'), findsOneWidget);
    expect((await repository.allPlayers()).single.name, 'Finn');

    await close(tester);
  });

  testWidgets(
    'a long press hides the player and offers UNDO, which restores them',
    (tester) async {
      final finn = await repository.addPlayer('Finn');
      await open(tester);

      await tester.longPress(find.byKey(Key('delete-player-${finn.id}')));
      await pumpFrames(tester, count: 12);

      expect(find.text('Finn'), findsNothing);
      expect(find.text('Removed Finn'), findsOneWidget);
      expect(find.text('UNDO'), findsOneWidget);
      // Nothing written yet - the undo window is still open.
      expect(await repository.allPlayers(), hasLength(1));

      await tester.tap(find.text('UNDO'));
      await pumpFrames(tester, count: 12);

      expect(find.text('Finn'), findsOneWidget);
      expect(await repository.allPlayers(), hasLength(1));

      await close(tester);
    },
  );

  testWidgets('a held delete left to time out actually removes the player', (
    tester,
  ) async {
    final finn = await repository.addPlayer('Finn');
    await open(tester);

    await tester.longPress(find.byKey(Key('delete-player-${finn.id}')));
    await pumpFrames(tester, count: 12);
    expect(find.text('Finn'), findsNothing);
    // Nothing written yet - the undo window is still open.
    expect(await repository.allPlayers(), hasLength(1));

    // Really waits the window out. Don't shortcut with
    // `removeCurrentSnackBar()`: it hides that a snackbar with an action does
    // not time out on its own, which would leave the delete never landing.
    await waitOutUndo(tester);

    expect(await repository.allPlayers(), isEmpty);

    await close(tester);
  });

  testWidgets('a tap on the delete icon hides the player and offers UNDO', (
    tester,
  ) async {
    final finn = await repository.addPlayer('Finn');
    await open(tester);

    await tester.tap(find.byKey(Key('delete-player-${finn.id}')));
    await pumpFrames(tester, count: 12);

    expect(find.text('Finn'), findsNothing);
    expect(find.text('Removed Finn'), findsOneWidget);
    expect(find.text('UNDO'), findsOneWidget);

    await waitOutUndo(tester);
    expect(await repository.allPlayers(), isEmpty);

    await close(tester);
  });

  testWidgets('leaving the roster inside the undo window still deletes', (
    tester,
  ) async {
    final finn = await repository.addPlayer('Finn');
    await pumpApp(
      tester,
      const Scaffold(body: SizedBox.shrink()),
      container: container,
    );
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(MaterialPageRoute<void>(builder: (_) => const RosterScreen()));
    await pumpFrames(tester, count: 12);

    await tester.tap(find.byKey(Key('delete-player-${finn.id}')));
    await pumpFrames(tester, count: 12);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await pumpFrames(tester, count: 12);

    await waitOutUndo(tester);
    expect(await repository.allPlayers(), isEmpty);

    await close(tester);
  });
}
