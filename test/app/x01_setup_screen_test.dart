import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/x01_setup_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/x01/x01_rules.dart';
import 'package:fluttergran/l10n/app_localizations.dart';

/// Returns [value] without ever touching shared_preferences, so a test can
/// seed the setup screen's starting point without depending on the plugin
/// channel being present.
class _FixedX01Defaults extends X01DefaultsController {
  _FixedX01Defaults(this.value);

  final X01Defaults value;

  @override
  X01Defaults build() => value;
}

void main() {
  late AppDatabase database;
  late GameRepository repository;
  late FakeBoardSource board;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = GameRepository(database);
    board = FakeBoardSource();
  });

  tearDown(() async {
    container.dispose();
    await board.dispose();
    await database.close();
  });

  /// Builds the container, optionally pinning [defaults], and pumps the
  /// screen. Kept as one helper so every test starts from the same wiring.
  Future<void> pump(WidgetTester tester, {X01Defaults? defaults}) async {
    // Two extra chip rows push the player roster further down than the
    // default 800x600 test surface comfortably fits - taller rather than
    // scrolling keeps every tap a plain, un-obscured hit.
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        boardSourceProvider.overrideWithValue(board),
        if (defaults != null)
          x01DefaultsProvider.overrideWith(() => _FixedX01Defaults(defaults)),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(),
          home: const X01SetupScreen(),
        ),
      ),
    );
  }

  testWidgets('starting without touching the rule chips uses straight-in, '
      'double-out', (tester) async {
    final player = await repository.addPlayer('Finn');
    await pump(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text(player.name));
    await tester.pump();
    await tester.tap(find.byKey(const Key('start-leg-button')));
    await tester.pumpAndSettle();

    final config = container.read(matchProvider)!.config;
    expect(config.inRule, X01InRule.straight);
    expect(config.outRule, X01OutRule.double);
  });

  testWidgets('pre-fills from the remembered defaults', (tester) async {
    final player = await repository.addPlayer('Finn');
    await pump(
      tester,
      defaults: (
        startScore: 701,
        inRule: X01InRule.master,
        outRule: X01OutRule.master,
      ),
    );
    await tester.pumpAndSettle();

    // Starting immediately, without touching anything, proves the screen's
    // own state was seeded from the remembered defaults rather than the
    // hardcoded fallback.
    await tester.tap(find.text(player.name));
    await tester.pump();
    await tester.tap(find.byKey(const Key('start-leg-button')));
    await tester.pumpAndSettle();

    final config = container.read(matchProvider)!.config;
    expect(config.startScore, 701);
    expect(config.inRule, X01InRule.master);
    expect(config.outRule, X01OutRule.master);
  });

  testWidgets('picking rules and starting a leg carries them through, and '
      'remembers the choice', (tester) async {
    final player = await repository.addPlayer('Finn');
    await pump(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text(player.name));
    await tester.pump();

    await tester.tap(find.byKey(const Key('in-rule-double')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('out-rule-master')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('start-leg-button')));
    await tester.pumpAndSettle();

    final config = container.read(matchProvider)!.config;
    expect(config.inRule, X01InRule.double);
    expect(config.outRule, X01OutRule.master);

    // The choice is remembered for next time the setup screen opens.
    final defaults = container.read(x01DefaultsProvider);
    expect(defaults.inRule, X01InRule.double);
    expect(defaults.outRule, X01OutRule.master);
  });
}
