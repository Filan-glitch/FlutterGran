import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/audio/sound_controller.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/atc_setup_screen.dart';
import 'package:fluttergran/app/screens/bulling_setup_screen.dart';
import 'package:fluttergran/app/screens/x01_setup_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/app/widgets/player_picker.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/atc/atc_variant.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/l10n/app_localizations.dart';

/// Silent, so nothing goes looking for an audio plugin once a game opens.
class _MutePlayer implements SoundPlayer {
  @override
  void playCue(String asset) {}

  @override
  void playSpeech(String asset, {Duration after = Duration.zero}) {}

  @override
  void silence() {}

  @override
  Future<void> dispose() async {}
}

class _LightsOff extends BoolSetting {
  _LightsOff() : super('led.enabled');

  @override
  bool build() => false;
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
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        boardSourceProvider.overrideWithValue(board),
        soundPlayerProvider.overrideWithValue(_MutePlayer()),
        ledEnabledProvider.overrideWith(_LightsOff.new),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await board.dispose();
    await database.close();
  });

  /// Pumps frames rather than settling: a game screen that opens lights its
  /// target keys with a looping pulse, which never settles.
  Future<void> frames(WidgetTester tester) async {
    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    Size size = const Size(400, 1400),
    Locale? locale,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          theme: buildTheme(),
          home: screen,
        ),
      ),
    );
    await frames(tester);
  }

  for (final (name, screen) in const [
    ('x01', X01SetupScreen()),
    ('Around the Clock', AtcSetupScreen()),
    ('Bulling', BullingSetupScreen()),
  ]) {
    group('$name setup', () {
      testWidgets('a player row seats and unseats, and deletes nobody', (
        tester,
      ) async {
        final player = await repository.addPlayer('Finn');
        await pump(tester, screen);

        final picker = find.byType(PlayerPicker);
        expect(
          find.descendant(of: picker, matching: find.byIcon(Icons.close)),
          findsNothing,
        );

        await tester.tap(find.text(player.name));
        await frames(tester);
        expect(find.text('1 of 4'), findsOneWidget);

        await tester.tap(find.text(player.name));
        await frames(tester);
        expect(find.text('1 of 4'), findsNothing);
        expect(await repository.allPlayers(), hasLength(1));
      });

      testWidgets('fits a narrow phone in German', (tester) async {
        await repository.addPlayer('Maximilian-Alexander');
        await pump(
          tester,
          screen,
          size: const Size(320, 1400),
          locale: const Locale('de'),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('a name typed in is added and seated', (tester) async {
        await pump(tester, screen);

        await tester.enterText(find.byType(TextField), 'Ada');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await frames(tester);

        expect(find.text('Ada'), findsOneWidget);
        expect(find.text('1 of 4'), findsOneWidget);
      });
    });
  }

  testWidgets('the Around the Clock variant picked is the one played', (
    tester,
  ) async {
    await repository.addPlayer('Finn');
    await pump(tester, const AtcSetupScreen());

    await tester.tap(find.text('MASTERS'));
    await tester.tap(find.text('Finn'));
    await frames(tester);
    await tester.tap(find.byKey(const Key('start-leg-button')));
    await frames(tester);

    expect(
      container.read(atcGameProvider).leg.config.variant,
      AtcVariant.masters,
    );
  });

  testWidgets('the Bulling value and target picked are the ones played', (
    tester,
  ) async {
    await repository.addPlayer('Finn');
    await pump(tester, const BullingSetupScreen());

    await tester.tap(find.text('BULLSEYE = 3'));
    await tester.tap(find.text('41'));
    await tester.tap(find.text('Finn'));
    await frames(tester);
    await tester.tap(find.byKey(const Key('start-leg-button')));
    await frames(tester);

    final config = container.read(bullingGameProvider).leg.config;
    expect(config.bullseyeValue, BullseyeValue.three);
    expect(config.target, 41);
  });
}
