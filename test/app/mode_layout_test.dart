import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/audio/sound_controller.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/atc_game_screen.dart';
import 'package:fluttergran/app/screens/bulling_game_screen.dart';
import 'package:fluttergran/app/screens/training_game_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/app/widgets/aim_card.dart';
import 'package:fluttergran/app/widgets/dart_keypad.dart';
import 'package:fluttergran/app/widgets/scoreboard.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/atc/atc_config.dart';
import 'package:fluttergran/domain/atc/atc_stop.dart';
import 'package:fluttergran/domain/atc/atc_variant.dart';
import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/training/training_drill.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:fluttergran/l10n/app_localizations.dart';

const phonePortrait = Size(411, 923);
const phoneLandscape = Size(923, 411);
const tablet = Size(834, 1194);
const tabS6Lite = Size(1333, 800);

/// Silent, so nothing goes looking for an audio plugin.
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

/// What a test needs from a game mode to drive its screen: how to start it,
/// how to throw at it, how to confirm a turn, and one dart that is sure to
/// move the thrower on.
typedef _Mode = ({
  String name,
  Widget screen,
  Future<void> Function(ProviderContainer, GameRepository, List<int>) start,
  void Function(ProviderContainer, ThrownDart) throwDart,
  void Function(ProviderContainer) confirm,
  bool Function(ProviderContainer) awaiting,
  bool Function(ProviderContainer) finished,
  ThrownDart scoring,
  String playAgain,
});

final _atc = (
  name: 'Around the Clock',
  screen: const AtcGameScreen(),
  start:
      (ProviderContainer container, GameRepository repo, List<int> ids) async {
        final config = AtcConfig(playerIds: ids, variant: AtcVariant.anyPart);
        final gameId = await repo.startAtcGame(config);
        container.read(atcConfigProvider.notifier).update(config);
        container.read(currentGameIdProvider.notifier).set(gameId);
        container.read(atcGameProvider.notifier).restart(config);
      },
  throwDart: (ProviderContainer c, ThrownDart dart) =>
      c.read(atcGameProvider.notifier).addDart(dart),
  confirm: (ProviderContainer c) =>
      c.read(atcGameProvider.notifier).confirmTurn(),
  awaiting: (ProviderContainer c) =>
      c.read(atcGameProvider).awaitingTurnConfirm,
  finished: (ProviderContainer c) => c.read(atcGameProvider).leg.isFinished,
  // Stop 1 under "any part".
  scoring: const ThrownDart(Segment(1, Ring.outerSingle)),
  playAgain: 'atc-play-again',
);

final _bulling = (
  name: 'Bulling',
  screen: const BullingGameScreen(),
  start:
      (ProviderContainer container, GameRepository repo, List<int> ids) async {
        final config = BullingConfig(
          playerIds: ids,
          bullseyeValue: BullseyeValue.three,
          target: 21,
        );
        final gameId = await repo.startBullingGame(config);
        container.read(bullingConfigProvider.notifier).update(config);
        container.read(currentGameIdProvider.notifier).set(gameId);
        container.read(bullingGameProvider.notifier).restart(config);
      },
  throwDart: (ProviderContainer c, ThrownDart dart) =>
      c.read(bullingGameProvider.notifier).addDart(dart),
  confirm: (ProviderContainer c) =>
      c.read(bullingGameProvider.notifier).confirmTurn(),
  awaiting: (ProviderContainer c) =>
      c.read(bullingGameProvider).awaitingTurnConfirm,
  finished: (ProviderContainer c) => c.read(bullingGameProvider).leg.isFinished,
  scoring: const ThrownDart(Segment.outerBull),
  playAgain: 'bulling-play-again',
);

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

  Future<void> frames(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  /// Puts [screen] on top of a home route, in a viewport of exactly [size],
  /// the app's own type scaling included.
  Future<void> pushAt(WidgetTester tester, Widget screen, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(),
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(typeScaleFor(media.size)),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: (_) => screen)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await frames(tester);
    await frames(tester);
  }

  /// Starts [mode] for two players and puts its screen up.
  Future<void> openAt(WidgetTester tester, _Mode mode, Size size) async {
    final finn = await repository.addPlayer('Finn');
    final ada = await repository.addPlayer('Ada');
    await mode.start(container, repository, [finn.id, ada.id]);
    await pushAt(tester, mode.screen, size);
  }

  /// Starts a [drill] session and puts the training screen up.
  Future<void> trainAt(
    WidgetTester tester,
    TrainingDrill drill,
    Size size,
  ) async {
    container.read(trainingProvider.notifier).start(drill: drill);
    await pushAt(tester, const TrainingGameScreen(), size);
  }

  Rect where(WidgetTester tester, Finder finder) => tester.getRect(finder);

  for (final mode in [_atc, _bulling]) {
    group(mode.name, () {
      group('fits the screen it is played on', () {
        for (final (name, size) in const [
          ('a phone held upright', phonePortrait),
          ('a phone on its side', phoneLandscape),
          ('a tablet', tablet),
          ('the Tab S6 Lite', tabS6Lite),
        ]) {
          testWidgets('mid-turn and with a turn held, on $name', (
            tester,
          ) async {
            await openAt(tester, mode, size);
            expect(tester.takeException(), isNull);

            mode.throwDart(container, mode.scoring);
            await frames(tester);
            expect(tester.takeException(), isNull);

            mode.throwDart(container, const ThrownDart.miss());
            mode.throwDart(container, const ThrownDart.miss());
            await frames(tester);
            expect(tester.takeException(), isNull);
          });
        }
      });

      testWidgets('a phone on its side puts the keypad beside the score', (
        tester,
      ) async {
        await openAt(tester, mode, phoneLandscape);

        final score = where(tester, find.byType(Scoreboard));
        final keypad = where(tester, find.byType(DartKeypad));
        expect(keypad.left, greaterThanOrEqualTo(score.right));
      });

      testWidgets('the tablet gets the hero scoreboard', (tester) async {
        await openAt(tester, mode, tabS6Lite);
        expect(find.byKey(const Key('hero-scoreboard')), findsOneWidget);
      });

      testWidgets('a connected board gives the players the whole width', (
        tester,
      ) async {
        await openAt(tester, mode, tabS6Lite);
        await board.connect();
        await frames(tester);

        expect(find.byType(DartKeypad), findsNothing);
        final body = where(tester, find.byKey(const Key('game-body')));
        final seats = where(tester, find.byKey(const Key('hero-scoreboard')));
        expect(seats.width, greaterThan(body.width * 0.9));
      });

      testWidgets('the tablet takes over the whole screen for a turn result', (
        tester,
      ) async {
        await openAt(tester, mode, tabS6Lite);

        mode.throwDart(container, mode.scoring);
        mode.throwDart(container, const ThrownDart.miss());
        mode.throwDart(container, const ThrownDart.miss());
        await frames(tester);

        expect(find.byKey(const Key('turn-result-overlay')), findsOneWidget);
      });

      testWidgets('the ledger keeps a running count mid-turn', (tester) async {
        await openAt(tester, mode, phonePortrait);
        mode.throwDart(container, mode.scoring);
        await frames(tester);

        expect(find.text('+1'), findsOneWidget);
      });

      testWidgets('the game over card plays again or goes back', (
        tester,
      ) async {
        await openAt(tester, mode, phonePortrait);

        // One seat keeps hitting while the other misses, confirming each
        // turn as it is held, until the leg is won.
        var dart = 0;
        while (!mode.finished(container)) {
          if (mode.awaiting(container)) {
            mode.confirm(container);
            continue;
          }
          final thrower = dart++ ~/ 3 % 2 == 0;
          mode.throwDart(
            container,
            thrower ? _nextScoring(mode, container) : const ThrownDart.miss(),
          );
        }
        if (mode.awaiting(container)) mode.confirm(container);
        await frames(tester);

        expect(find.byKey(Key(mode.playAgain)), findsOneWidget);
        expect(find.text('BACK TO SETUP'), findsOneWidget);

        await tester.tap(find.text('BACK TO SETUP'));
        await frames(tester);
        await frames(tester);
        await frames(tester);
        expect(find.byWidget(mode.screen), findsNothing);
        expect(find.text('open'), findsOneWidget);
      });
    });
  }

  group('the aim card asks for the beds the variant accepts', () {
    final seven = AtcStop.track[6];
    List<String> labels(AtcStop stop, AtcVariant variant) => [
      for (final aim in aimsFor(stop, variant)) aim.label,
    ];

    test('masters wants the double or the treble', () {
      expect(labels(seven, AtcVariant.masters), ['D7', 'T7']);
    });

    test('doubles only wants the double', () {
      expect(labels(seven, AtcVariant.doublesOnly), ['D7']);
    });

    test('any part is the number, once', () {
      expect(labels(seven, AtcVariant.anyPart), ['7']);
    });

    test('a bull stop is its own ring whatever the variant', () {
      for (final variant in AtcVariant.values) {
        expect(labels(AtcStop.track[20], variant), ['BULL']);
        expect(labels(AtcStop.track[21], variant), ['BULLSEYE']);
      }
    });
  });

  testWidgets('the Around the Clock aim card is on while a turn is open', (
    tester,
  ) async {
    await openAt(tester, _atc, phonePortrait);
    expect(find.byKey(aimCardKey), findsOneWidget);
  });

  group('training', () {
    for (final drill in TrainingDrill.values) {
      for (final (name, size) in const [
        ('a phone held upright', phonePortrait),
        ('a phone on its side', phoneLandscape),
        ('the Tab S6 Lite', tabS6Lite),
      ]) {
        testWidgets('${drill.name} fits $name', (tester) async {
          await trainAt(tester, drill, size);
          expect(tester.takeException(), isNull);

          container.read(trainingProvider.notifier)
            ..addDart(const ThrownDart(Segment(20, Ring.triple)))
            ..addDart(const ThrownDart(Segment(20, Ring.triple)));
          await frames(tester);
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('darts can be keyed in with no board connected', (
      tester,
    ) async {
      await trainAt(tester, TrainingDrill.freePractice, phonePortrait);
      expect(find.byType(DartKeypad), findsOneWidget);

      await tester.tap(
        find.descendant(of: find.byType(DartKeypad), matching: find.text('19')),
      );
      await frames(tester);

      expect(find.text('S19'), findsOneWidget);
    });

    testWidgets('the keypad gives way once a board connects', (tester) async {
      await trainAt(tester, TrainingDrill.freePractice, tabS6Lite);
      await board.connect();
      await frames(tester);

      expect(find.byType(DartKeypad), findsNothing);
      expect(find.byKey(const Key('hero-scoreboard')), findsOneWidget);
    });
  });
}

/// A dart that moves the current thrower on: the stop they need for Around
/// the Clock, a bullseye for Bulling.
ThrownDart _nextScoring(_Mode mode, ProviderContainer container) {
  if (mode.name == _bulling.name) {
    return const ThrownDart(Segment.innerBull);
  }
  final leg = container.read(atcGameProvider).leg;
  final stop = leg.currentStopFor(leg.currentPlayerId);
  return ThrownDart(
    stop.ring == null
        ? Segment(stop.number!, Ring.outerSingle)
        : Segment(25, stop.ring!),
  );
}
