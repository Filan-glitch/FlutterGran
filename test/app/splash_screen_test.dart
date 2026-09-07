import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/main_menu_screen.dart';
import 'package:fluttergran/app/screens/splash_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

void main() {
  late AppDatabase database;
  late FakeBoardSource board;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    board = FakeBoardSource();
    container = ProviderContainer(
      overrides: [
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

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: buildTheme(), home: const SplashScreen()),
    ),
  );

  testWidgets('lands on the main menu once the database has answered', (
    tester,
  ) async {
    await pump(tester);

    // Still on the splash a moment in - the 700ms floor has not elapsed.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(MainMenuScreen), findsNothing);

    // `pumpAndSettle` is the wrong tool here: it stops as soon as one pump
    // fails to schedule a new frame, which a bare `Timer` idling in the
    // background never does on its own. An explicit pump past the 700ms
    // floor, then one more to let the resulting route push build, is what
    // actually drives the wait to completion.
    await tester.pump(const Duration(milliseconds: 700));
    // Longer than the pushReplacement's route transition (around 300ms) with
    // margin - a pump that only just covers it can leave the outgoing route
    // one frame short of fully gone.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MainMenuScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
  });

  testWidgets('does not flash a menu with no resume card before the '
      'database answers', (tester) async {
    final repository = GameRepository(database);
    final finn = await repository.addPlayer('Finn');
    final gameId = await repository.startGame(
      GameConfig(startScore: 501, playerIds: [finn.id]),
    );
    await repository.appendDart(
      gameId: gameId,
      ordinal: 0,
      playerId: finn.id,
      dart: const ThrownDart.miss(),
    );

    await pump(tester);
    await tester.pump(const Duration(milliseconds: 700));
    // Long enough to cover the pushReplacement's route transition, which is
    // around 300ms - a single zero-duration pump leaves the outgoing route
    // still mid-animation.
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MainMenuScreen), findsOneWidget);
    expect(find.byKey(const Key('menu-resume-banner')), findsOneWidget);
  });
}
