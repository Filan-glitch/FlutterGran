import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/atc_setup_screen.dart';
import 'package:fluttergran/app/screens/bulling_setup_screen.dart';
import 'package:fluttergran/app/screens/select_game_mode_screen.dart';
import 'package:fluttergran/app/screens/x01_setup_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/domain/game_mode.dart';
import 'package:fluttergran/l10n/app_localizations.dart';

/// [SelectGameModeScreen] itself is a plain [StatelessWidget], but tapping
/// its one real tile pushes [X01SetupScreen], which watches
/// `playersProvider`/`boardConnectionProvider` - so the navigation test still
/// needs a database and a board to push those providers over, the same as
/// any test that ends up on a screen backed by Riverpod. The container is
/// managed explicitly (`UncontrolledProviderScope`, disposed in `tearDown`)
/// rather than left to a bare `ProviderScope`'s own teardown, matching
/// `responsive_layout_test.dart` - a container disposed only when the widget
/// tree unmounts itself leaves a drift stream-closing timer still pending
/// once the test framework checks for one.
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

  Future<void> pumpScreen(
    WidgetTester tester, {
    List<GameModeDescriptor> modes = gameModeRegistry,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(),
          home: SelectGameModeScreen(modes: modes),
        ),
      ),
    );
    // Tiles stagger in (see `StaggeredEntry`); settle that one-shot entrance
    // before asserting so its timer is never still pending at tear-down.
    await tester.pumpAndSettle();
  }

  testWidgets('the x01 tile navigates to X01 Setup', (tester) async {
    await pumpScreen(tester);

    expect(find.text('X01'), findsOneWidget);
    expect(find.text('301 · 501 · 701'), findsOneWidget);

    await tester.tap(find.text('X01'));
    await tester.pumpAndSettle();

    expect(find.byType(X01SetupScreen), findsOneWidget);
  });

  testWidgets('the Around the Clock tile navigates to its setup screen', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('AROUND THE CLOCK'), findsOneWidget);

    await tester.tap(find.text('AROUND THE CLOCK'));
    await tester.pumpAndSettle();

    expect(find.byType(AtcSetupScreen), findsOneWidget);
  });

  testWidgets('the Bulling tile navigates to its setup screen', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('BULLING'), findsOneWidget);

    await tester.tap(find.text('BULLING'));
    await tester.pumpAndSettle();

    expect(find.byType(BullingSetupScreen), findsOneWidget);
  });

  testWidgets('the trailing tile names no specific unbuilt mode', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('MORE MODES COMING'), findsOneWidget);
  });

  group('a disabled mode (test-injected - the registry ships none today)', () {
    const modes = [
      GameModeDescriptor(
        id: GameMode.x01,
        displayName: 'X01',
        tagline: '301 · 501 · 701',
        isAvailable: true,
      ),
      GameModeDescriptor(
        id: GameMode.x01,
        displayName: 'Test Mode',
        tagline: 'not built yet',
        isAvailable: false,
      ),
    ];

    testWidgets('renders dimmed rather than the same as the enabled tile', (
      tester,
    ) async {
      await pumpScreen(tester, modes: modes);

      final enabled = tester.widget<Text>(find.text('X01'));
      final disabled = tester.widget<Text>(find.text('Test Mode'));

      expect(enabled.style?.color, Palette.chalk);
      expect(disabled.style?.color, Palette.chalkDim);
      expect(find.text('COMING SOON'), findsOneWidget);
    });

    testWidgets('does not navigate anywhere when tapped', (tester) async {
      await pumpScreen(tester, modes: modes);

      await tester.tap(find.text('Test Mode'));
      await tester.pumpAndSettle();

      expect(find.byType(SelectGameModeScreen), findsOneWidget);
      expect(find.byType(X01SetupScreen), findsNothing);
    });
  });
}
