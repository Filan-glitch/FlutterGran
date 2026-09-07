import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/roster_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';

void main() {
  late AppDatabase database;
  late GameRepository repository;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = GameRepository(database);
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  /// Pumps frames without settling: the roster query lands a frame or two
  /// after the write that caused it, and a focused text field's cursor
  /// blinks forever, so there is no settled state to wait for.
  Future<void> frames(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: buildTheme(), home: const RosterScreen()),
      ),
    );
    await frames(tester);
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
    await frames(tester);

    expect(find.text('Finn'), findsOneWidget);
    expect((await repository.allPlayers()).single.name, 'Finn');

    await close(tester);
  });

  testWidgets('the empty roster shows the empty-state prompt', (
    tester,
  ) async {
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
    await frames(tester);

    await tester.enterText(
      find.byKey(Key('rename-field-${finn.id}')),
      'Finlay',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await frames(tester);

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
    await frames(tester);

    await tester.enterText(find.byKey(Key('rename-field-${finn.id}')), '   ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await frames(tester);

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
      await frames(tester);

      expect(find.text('Finn'), findsNothing);
      expect(find.text('Removed Finn'), findsOneWidget);
      expect(find.text('UNDO'), findsOneWidget);
      // Nothing written yet - the undo window is still open.
      expect(await repository.allPlayers(), hasLength(1));

      await tester.tap(find.text('UNDO'));
      await frames(tester);

      expect(find.text('Finn'), findsOneWidget);
      expect(await repository.allPlayers(), hasLength(1));

      await close(tester);
    },
  );

  testWidgets(
    'a held delete left to time out actually removes the player',
    (tester) async {
      final finn = await repository.addPlayer('Finn');
      await open(tester);

      await tester.longPress(find.byKey(Key('delete-player-${finn.id}')));
      await frames(tester);
      expect(find.text('Finn'), findsNothing);
      // Nothing written yet - the undo window is still open.
      expect(await repository.allPlayers(), hasLength(1));

      // Standing in for waiting out the snackbar's real ~4s window without
      // ever tapping UNDO: `removeCurrentSnackBar` completes its `.closed`
      // future the same way the real timeout does - with any reason other
      // than `action` - but does it immediately rather than only after a
      // real entrance/exit animation each get a settled frame, which is
      // what keeps this deterministic instead of pumping through several
      // seconds of real time.
      ScaffoldMessenger.of(
        tester.element(find.byType(RosterScreen)),
      ).removeCurrentSnackBar();
      await frames(tester);

      expect(await repository.allPlayers(), isEmpty);

      await close(tester);
    },
  );

  testWidgets('a single tap on the delete icon deletes nothing', (
    tester,
  ) async {
    final finn = await repository.addPlayer('Finn');
    await open(tester);

    await tester.tap(find.byKey(Key('delete-player-${finn.id}')));
    await frames(tester);

    expect(find.text('Finn'), findsOneWidget);
    expect(find.text('Removed Finn'), findsNothing);
    expect(await repository.allPlayers(), hasLength(1));

    await close(tester);
  });
}
