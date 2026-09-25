import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/roster_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/l10n/app_localizations.dart';

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

  /// Lets a delete's undo snackbar run its whole course - in, the window,
  /// out - without UNDO being tapped.
  Future<void> waitOutUndo(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 2));
    }
    await frames(tester);
  }

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(),
          home: const RosterScreen(),
        ),
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

      // Really waits the window out. This used to call
      // `removeCurrentSnackBar()` instead, which hid that a snackbar with an
      // action no longer times out on its own - so the delete never landed.
      await waitOutUndo(tester);

      expect(await repository.allPlayers(), isEmpty);

      await close(tester);
    },
  );

  testWidgets('a tap on the delete icon hides the player and offers UNDO', (
    tester,
  ) async {
    final finn = await repository.addPlayer('Finn');
    await open(tester);

    await tester.tap(find.byKey(Key('delete-player-${finn.id}')));
    await frames(tester);

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
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(),
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      ),
    );
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(MaterialPageRoute<void>(builder: (_) => const RosterScreen()));
    await frames(tester);

    await tester.tap(find.byKey(Key('delete-player-${finn.id}')));
    await frames(tester);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await frames(tester);

    await waitOutUndo(tester);
    expect(await repository.allPlayers(), isEmpty);

    await close(tester);
  });
}
