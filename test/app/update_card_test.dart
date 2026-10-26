import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/main_menu_screen.dart';
import 'package:fluttergran/app/screens/settings_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/app/update/update_controller.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/l10n/app_localizations.dart';

import 'fake_update.dart';

void main() {
  late Directory directory;
  late FakeUpdatePlatform platform;
  late AppDatabase database;
  late FakeBoardSource board;
  late ProviderContainer container;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('update_card');
    platform = FakeUpdatePlatform(directory);
    database = AppDatabase(NativeDatabase.memory());
    board = FakeBoardSource();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        boardSourceProvider.overrideWithValue(board),
        updatePlatformProvider.overrideWithValue(platform),
        updateHttpClientProvider.overrideWithValue(github()),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await board.dispose();
    await database.close();
    directory.deleteSync(recursive: true);
  });

  Future<void> pump(WidgetTester tester, Widget home) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(),
          home: home,
        ),
      ),
    );
    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> check(WidgetTester tester) async {
    await tester.runAsync(
      () => container.read(updateProvider.notifier).check(),
    );
    await tester.pump();
  }

  group('main menu', () {
    testWidgets('shows nothing until a newer release is found', (tester) async {
      await pump(tester, const MainMenuScreen());
      expect(find.byKey(const Key('update-card')), findsNothing);

      await check(tester);
      expect(find.byKey(const Key('update-card')), findsOneWidget);
      expect(find.text('Chalk 1.1.0 is available'), findsOneWidget);
      expect(find.text('UPDATE'), findsWidgets);
    });

    testWidgets('closes the card for the rest of the run', (tester) async {
      await pump(tester, const MainMenuScreen());
      await check(tester);

      await tester.tap(find.byKey(const Key('update-card-dismiss')));
      await tester.pump();

      expect(find.byKey(const Key('update-card')), findsNothing);
      expect(container.read(updateProvider), isA<UpdateAvailable>());
    });

    testWidgets('says nothing when already up to date', (tester) async {
      platform.version = '1.1.0';
      await pump(tester, const MainMenuScreen());
      await check(tester);

      expect(find.byKey(const Key('update-card')), findsNothing);
    });
  });

  group('settings', () {
    Future<void> scrollToUpdates(WidgetTester tester) =>
        tester.scrollUntilVisible(
          find.byKey(const Key('update-check-now')),
          200,
          scrollable: find.byType(Scrollable).first,
        );

    testWidgets('shows the running version and checks by hand', (tester) async {
      platform.version = '1.1.0';
      await pump(tester, const SettingsScreen());
      await tester.runAsync(() => container.read(appVersionProvider.future));
      await tester.pump();
      await scrollToUpdates(tester);

      expect(find.text('Version 1.1.0'), findsOneWidget);

      await tester.tap(find.byKey(const Key('update-check-now')));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();

      expect(find.text('Chalk is up to date'), findsOneWidget);
    });

    testWidgets('turns into the update card once something is found', (
      tester,
    ) async {
      await pump(tester, const SettingsScreen());
      await scrollToUpdates(tester);
      await check(tester);

      expect(find.byKey(const Key('update-card')), findsOneWidget);
      expect(find.byKey(const Key('update-check-now')), findsNothing);
    });

    testWidgets('sends Windows to the release page', (tester) async {
      await pump(tester, const SettingsScreen());
      await scrollToUpdates(tester);
      await check(tester);

      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pump();
      expect(find.text('DOWNLOAD'), findsOneWidget);
      await tester.tap(find.byKey(const Key('update-card-action')));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));

      expect(platform.opened, [Uri.parse('$base/tag/v1.1.0')]);
    }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
  });
}
