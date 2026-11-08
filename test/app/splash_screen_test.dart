import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/main_menu_screen.dart';
import 'package:fluttergran/app/screens/splash_screen.dart';
import 'package:fluttergran/app/update/update_controller.dart';
import 'package:fluttergran/app/widgets/chalk_mark.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

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

  Future<void> pump(WidgetTester tester) =>
      pumpApp(tester, const SplashScreen(), container: container);

  testWidgets('lands on the main menu once the database has answered', (
    tester,
  ) async {
    await pump(tester);

    // Still on the splash a moment in - the minimum hold has not elapsed.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(MainMenuScreen), findsNothing);

    // `pumpAndSettle` is the wrong tool here: it stops as soon as one pump
    // fails to schedule a new frame, which a bare `Timer` idling in the
    // background never does on its own. An explicit pump past the minimum
    // hold, then one more to let the resulting route push build, is what
    // actually drives the wait to completion.
    await tester.pump(SplashScreen.minimumHold);
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
    await tester.pump(SplashScreen.minimumHold);
    // Long enough to cover the pushReplacement's route transition, which is
    // around 300ms - a single zero-duration pump leaves the outgoing route
    // still mid-animation.
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MainMenuScreen), findsOneWidget);
    expect(find.byKey(const Key('menu-resume-banner')), findsOneWidget);
  });

  /// How much of the tally the splash is drawing right now.
  double drawn(WidgetTester tester) =>
      tester.widget<ChalkMark>(find.byType(ChalkMark)).progress;

  /// Lets the splash finish and hand over, so no timer outlives the test.
  Future<void> finish(WidgetTester tester) async {
    await tester.pump(SplashScreen.minimumHold);
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('chalks the tally in, stroke by stroke', (tester) async {
    await pump(tester);
    expect(drawn(tester), 0);

    await tester.pump(SplashScreen.drawDuration ~/ 2);
    expect(drawn(tester), inExclusiveRange(0, 1));

    await tester.pump(SplashScreen.drawDuration);
    expect(drawn(tester), 1);

    await finish(tester);
  });

  testWidgets('shows the finished tally at once under reduced motion', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await pump(tester);
    expect(drawn(tester), 1);

    await finish(tester);
  });

  testWidgets('shows the running version', (tester) async {
    final versioned = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        boardSourceProvider.overrideWithValue(board),
        appVersionProvider.overrideWith((ref) async => '1.3.2'),
      ],
    );
    addTearDown(versioned.dispose);

    await pumpApp(tester, const SplashScreen(), container: versioned);
    await tester.pump();

    expect(find.byKey(const Key('splash-version')), findsOneWidget);
    expect(find.textContaining('1.3.2'), findsOneWidget);

    await finish(tester);
  });

  testWidgets('shows no version where the platform cannot say', (tester) async {
    await pump(tester);
    await tester.pump();

    expect(find.byKey(const Key('splash-version')), findsNothing);

    await finish(tester);
  });
}
