import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/atc_game_screen.dart';
import 'package:fluttergran/app/screens/bulling_game_screen.dart';
import 'package:fluttergran/app/screens/higher_lower_game_screen.dart';
import 'package:fluttergran/app/screens/training_game_screen.dart';
import 'package:fluttergran/app/training_controller.dart';
import 'package:fluttergran/app/widgets/aim_card.dart';
import 'package:fluttergran/app/widgets/bounds_card.dart';
import 'package:fluttergran/app/widgets/dart_keypad.dart';
import 'package:fluttergran/app/widgets/scoreboard.dart';
import 'package:fluttergran/app/widgets/turn_ledger.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/atc/atc_config.dart';
import 'package:fluttergran/domain/atc/atc_stop.dart';
import 'package:fluttergran/domain/atc/atc_variant.dart';
import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/higher_lower/higher_lower_config.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/training/training_drill.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

import '../support/database.dart';
import '../support/devices.dart';
import '../support/lights.dart';
import '../support/pump.dart';
import '../support/sound.dart';

/// Maximised Windows windows.
const desktopWindows = [
  ('the smallest window', smallestWindow),
  ('a laptop', laptop),
  ('a monitor', monitor),
];

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
  String scoringLedger,
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
  scoringLedger: '+1',
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
  scoringLedger: '+1',
  playAgain: 'bulling-play-again',
);

final _higherLower = (
  name: 'Higher/Lower',
  screen: const HigherLowerGameScreen(),
  start:
      (ProviderContainer container, GameRepository repo, List<int> ids) async {
        final config = HigherLowerConfig(playerIds: ids);
        final gameId = await repo.startHigherLowerGame(config);
        container.read(higherLowerConfigProvider.notifier).update(config);
        container.read(currentGameIdProvider.notifier).set(gameId);
        container.read(higherLowerGameProvider.notifier).restart(config);
      },
  throwDart: (ProviderContainer c, ThrownDart dart) =>
      c.read(higherLowerGameProvider.notifier).addDart(dart),
  confirm: (ProviderContainer c) =>
      c.read(higherLowerGameProvider.notifier).confirmTurn(),
  awaiting: (ProviderContainer c) =>
      c.read(higherLowerGameProvider).awaitingTurnConfirm,
  finished: (ProviderContainer c) =>
      c.read(higherLowerGameProvider).leg.isFinished,
  scoring: const ThrownDart(Segment(20, Ring.triple)),
  scoringLedger: '60',
  playAgain: 'higher-lower-play-again',
);

void main() {
  late AppDatabase database;
  late GameRepository repository;
  late FakeBoardSource board;
  late ProviderContainer container;

  setUp(() {
    database = memoryDatabase();
    repository = GameRepository(database);
    board = FakeBoardSource();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        boardSourceProvider.overrideWithValue(board),
        soundPlayerProvider.overrideWithValue(MuteSoundPlayer()),
        lightsOff(),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await board.dispose();
    await database.close();
  });

  /// Puts [screen] on top of a home route, in a viewport of exactly [size],
  /// the app's own type scaling included.
  Future<void> pushAt(WidgetTester tester, Widget screen, Size size) async {
    setViewSize(tester, size);

    await pumpApp(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (_) => screen)),
            child: const Text('open'),
          ),
        ),
      ),
      container: container,
      typeScaled: true,
    );
    await tester.tap(find.text('open'));
    await pumpFrames(tester, count: 12);
    await pumpFrames(tester, count: 12);
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
    container.read(trainingProvider.notifier).start(TrainingPlan.of(drill));
    await pushAt(tester, const TrainingGameScreen(), size);
  }

  Rect where(WidgetTester tester, Finder finder) => tester.getRect(finder);

  for (final mode in [_atc, _bulling, _higherLower]) {
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
            await pumpFrames(tester, count: 12);
            expect(tester.takeException(), isNull);

            mode.throwDart(container, const ThrownDart.miss());
            mode.throwDart(container, const ThrownDart.miss());
            await pumpFrames(tester, count: 12);
            expect(tester.takeException(), isNull);
          });
        }
      });

      group('fits a desktop window', () {
        for (final (name, size) in desktopWindows) {
          testWidgets('mid-turn and with a turn held, on $name', (
            tester,
          ) async {
            await openAt(tester, mode, size);
            expect(tester.takeException(), isNull);
            expect(find.byKey(const Key('hero-scoreboard')), findsOneWidget);

            mode.throwDart(container, mode.scoring);
            await pumpFrames(tester, count: 12);
            expect(tester.takeException(), isNull);

            mode.throwDart(container, const ThrownDart.miss());
            mode.throwDart(container, const ThrownDart.miss());
            await pumpFrames(tester, count: 12);
            expect(tester.takeException(), isNull);
          }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
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
        await pumpFrames(tester, count: 12);

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
        await pumpFrames(tester, count: 12);

        expect(find.byKey(const Key('turn-result-overlay')), findsOneWidget);
      });

      testWidgets('the ledger keeps a running count mid-turn', (tester) async {
        await openAt(tester, mode, phonePortrait);
        mode.throwDart(container, mode.scoring);
        await pumpFrames(tester, count: 12);

        expect(
          find.descendant(
            of: find.byType(TurnLedger),
            matching: find.text(mode.scoringLedger),
          ),
          findsOneWidget,
        );
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
        await pumpFrames(tester, count: 12);

        expect(find.byKey(Key(mode.playAgain)), findsOneWidget);
        expect(find.text('BACK TO SETUP'), findsOneWidget);

        await tester.tap(find.text('BACK TO SETUP'));
        await pumpFrames(tester, count: 12);
        await pumpFrames(tester, count: 12);
        await pumpFrames(tester, count: 12);
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

  testWidgets('the Higher/Lower values are on while a turn is open', (
    tester,
  ) async {
    await openAt(tester, _higherLower, phonePortrait);
    expect(find.byKey(boundsCardKey), findsOneWidget);
    expect(find.text('> 45'), findsOneWidget);
    expect(find.text('< 26'), findsOneWidget);
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
          await pumpFrames(tester, count: 12);
          expect(tester.takeException(), isNull);
        });
      }
    }

    for (final drill in TrainingDrill.values) {
      for (final (name, size) in desktopWindows) {
        testWidgets('${drill.name} fits $name', (tester) async {
          await trainAt(tester, drill, size);
          expect(tester.takeException(), isNull);

          container.read(trainingProvider.notifier)
            ..addDart(const ThrownDart(Segment(20, Ring.triple)))
            ..addDart(const ThrownDart(Segment(20, Ring.triple)));
          await pumpFrames(tester, count: 12);
          expect(tester.takeException(), isNull);
        }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
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
      await pumpFrames(tester, count: 12);

      expect(find.text('S19'), findsOneWidget);
    });

    testWidgets('the keypad gives way once a board connects', (tester) async {
      await trainAt(tester, TrainingDrill.freePractice, tabS6Lite);
      await board.connect();
      await pumpFrames(tester, count: 12);

      expect(find.byType(DartKeypad), findsNothing);
      expect(find.byKey(const Key('hero-scoreboard')), findsOneWidget);
    });
  });
}

/// A dart that moves the current thrower on: the stop they need for Around
/// the Clock, a bullseye for Bulling, a treble 20 for Higher/Lower - three of
/// those beat any higher value but 180.
ThrownDart _nextScoring(_Mode mode, ProviderContainer container) {
  if (mode.name == _bulling.name) {
    return const ThrownDart(Segment.innerBull);
  }
  if (mode.name == _higherLower.name) {
    return const ThrownDart(Segment(20, Ring.triple));
  }
  final leg = container.read(atcGameProvider).leg;
  final stop = leg.currentStopFor(leg.currentPlayerId);
  return ThrownDart(
    stop.ring == null
        ? Segment(stop.number!, Ring.outerSingle)
        : Segment(25, stop.ring!),
  );
}
