import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/higher_lower_controller.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/domain/higher_lower/higher_lower_config.dart';
import 'package:fluttergran/domain/higher_lower/higher_lower_leg_state.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

import 'board_clock.dart';

/// Lets queued stream events reach the controller before assertions run.
Future<void> settle() => Future<void>.delayed(Duration.zero);

const ThrownDart s20 = ThrownDart(Segment(20, Ring.outerSingle));
const ThrownDart s10 = ThrownDart(Segment(10, Ring.outerSingle));
const ThrownDart miss = ThrownDart.miss();

void main() {
  late FakeBoardSource board;
  late BoardClock clock;
  late ProviderContainer container;

  HigherLowerSession session() => container.read(higherLowerGameProvider);
  HigherLowerController controller() =>
      container.read(higherLowerGameProvider.notifier);

  setUp(() {
    board = FakeBoardSource();
    clock = BoardClock();
    container = ProviderContainer(
      overrides: [
        boardSourceProvider.overrideWithValue(board),
        clock.readerFor(board),
      ],
    );
    container.listen(higherLowerGameProvider, (_, _) {});
  });

  tearDown(() {
    container.dispose();
    board.dispose();
  });

  group('scoring by hand', () {
    test('a third dart ends the turn and holds the summary', () {
      controller()
        ..addDart(s20)
        ..addDart(s20)
        ..addDart(s10);

      expect(session().awaitingTurnConfirm, isTrue);
      expect(session().pendingTurn!.outcome, HigherLowerOutcome.higher);
      expect(session().leg.higher, 50);
      expect(session().leg.currentPlayerId, 2);
    });

    test('a miss ends the turn on the spot', () {
      controller()
        ..restart(HigherLowerConfig(playerIds: const [1, 2, 3]))
        ..addDart(s20)
        ..addDart(miss);

      expect(session().awaitingTurnConfirm, isTrue);
      expect(session().pendingTurn!.outcome, HigherLowerOutcome.missed);
      expect(session().leg.isOut(1), isTrue);
    });

    test('darts thrown while the summary is up are ignored', () {
      controller()
        ..restart(HigherLowerConfig(playerIds: const [1, 2, 3]))
        ..addDart(miss)
        ..addDart(s20);

      expect(session().leg.darts, [miss]);
    });

    test('the last one standing wins', () {
      controller()
        ..addDart(s20)
        ..addDart(s20)
        ..addDart(s10)
        ..confirmTurn()
        ..addDart(s10)
        ..addDart(s10)
        ..addDart(s10);

      expect(session().leg.winnerId, 1);
    });
  });

  group('undo', () {
    test('brings an eliminated player back', () {
      controller()
        ..restart(HigherLowerConfig(playerIds: const [1, 2, 3]))
        ..addDart(miss)
        ..undo();

      expect(session().awaitingTurnConfirm, isFalse);
      expect(session().leg.eliminated, isEmpty);
      expect(session().leg.currentPlayerId, 1);
    });

    test('takes back a win', () {
      controller()
        ..addDart(miss)
        ..undo();

      expect(session().leg.isFinished, isFalse);
    });

    test('does nothing on an empty leg', () {
      controller().undo();
      expect(session().leg.darts, isEmpty);
    });
  });

  group('driven by the board', () {
    setUp(
      () => controller().restart(HigherLowerConfig(playerIds: const [1, 2, 3])),
    );

    test('a hit is ignored when no leg is open', () async {
      controller().leave();

      board.hit(Segment.outerBull);
      await settle();

      expect(session().leg.darts, isEmpty);
    });

    test('a hit counts, through framing and decoding', () async {
      board.hit(Segment.outerBull);
      await settle();

      expect(session().leg.runningTotal, 25);
    });

    test('a board miss puts the player out', () async {
      board.emitMiss();
      await settle();

      expect(session().leg.isOut(1), isTrue);
    });

    test('the button mid-turn is a miss: out, and handed over', () async {
      board.hit(Segment.outerBull);
      await settle();

      board.pressButton();
      await settle();

      expect(session().leg.darts, [ThrownDart(Segment.outerBull), miss]);
      expect(session().leg.isOut(1), isTrue);
      expect(session().awaitingTurnConfirm, isFalse);
      expect(session().leg.currentPlayerId, 2);
    });

    test('the button confirms the turn', () async {
      board.emitBatch(['3.4', '3.5', '3.6']);
      await settle();
      expect(session().awaitingTurnConfirm, isTrue);

      board.pressButton();
      await settle();

      expect(session().awaitingTurnConfirm, isFalse);
    });
  });

  group('resuming a stored leg', () {
    test('restores the values, the eliminations and whose turn it is', () {
      controller().resume(HigherLowerConfig(playerIds: const [1, 2, 3]), [
        s20, s20, s10, // p1: 50
        miss, // p2 out
        s10,
      ]);

      expect(session().leg.higher, 50);
      expect(session().leg.eliminated, [2]);
      expect(session().leg.currentPlayerId, 3);
      expect(session().leg.dartsThrownThisTurn, 1);
      expect(session().awaitingTurnConfirm, isFalse);
    });
  });

  group('persisting', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      container.dispose();
      container = ProviderContainer(
        overrides: [
          boardSourceProvider.overrideWithValue(board),
          clock.readerFor(board),
          databaseProvider.overrideWithValue(database),
        ],
      );
      container.listen(higherLowerGameProvider, (_, _) {});
    });

    tearDown(() => database.close());

    test('the winning dart finishes the stored game', () async {
      final repository = container.read(gameRepositoryProvider);
      final a = await repository.addPlayer('A');
      final b = await repository.addPlayer('B');
      final config = HigherLowerConfig(playerIds: [a.id, b.id]);
      final gameId = await repository.startHigherLowerGame(config);
      container.read(currentGameIdProvider.notifier).set(gameId);

      controller()
        ..restart(config)
        ..addDart(miss);
      await settle();

      expect((await repository.loadGame(gameId))!.winnerPlayerId, b.id);
      expect(await repository.loadLog(gameId), [miss]);
    });
  });
}
