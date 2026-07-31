import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/game_controller.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

/// Lets queued stream events reach the controller before assertions run.
Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeBoardSource board;
  late ProviderContainer container;

  GameSession session() => container.read(gameProvider);
  GameController controller() => container.read(gameProvider.notifier);

  setUp(() {
    board = FakeBoardSource();
    container = ProviderContainer(
      overrides: [boardSourceProvider.overrideWithValue(board)],
    );
    // Providers auto-dispose in Riverpod 3, and `read` alone does not keep one
    // alive. A listener stands in for the widget that watches it in the app -
    // without it the controller, and its board subscription, would be torn down
    // at the first await.
    container.listen(gameProvider, (_, _) {});
  });

  tearDown(() {
    container.dispose();
    board.dispose();
  });

  ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));
  ThrownDart d(int n) => ThrownDart(Segment(n, Ring.doubleRing));

  group('scoring by hand', () {
    test('a dart comes off the remaining score', () {
      controller().addDart(t(20));
      expect(session().leg.remaining[1], 441);
    });

    test('a third dart ends the turn and holds the summary', () {
      controller()
        ..addDart(t(20))
        ..addDart(t(20))
        ..addDart(t(20));

      expect(session().awaitingTurnConfirm, isTrue);
      expect(session().pendingTurn!.scored, 180);
      expect(session().leg.currentPlayerId, 2);
    });

    test('darts thrown while the summary is up are ignored', () {
      controller()
        ..addDart(t(20))
        ..addDart(t(20))
        ..addDart(t(20));

      // A stray frame as the player walks to the board must not score for the
      // player who is next up.
      controller().addDart(t(20));

      expect(session().leg.remaining[2], 501);
      expect(session().leg.darts, hasLength(3));
    });

    test('confirming lets play resume', () {
      controller()
        ..addDart(t(20))
        ..addDart(t(20))
        ..addDart(t(20))
        ..confirmTurn()
        ..addDart(t(20));

      expect(session().awaitingTurnConfirm, isFalse);
      expect(session().leg.remaining[2], 441);
    });

    test('a bust ends the turn immediately', () {
      container.read(gameConfigProvider.notifier).update(
        GameConfig(startScore: 40, playerIds: const [1, 2]),
      );

      controller().addDart(t(20));

      expect(session().pendingTurn!.busted, isTrue);
      expect(session().leg.remaining[1], 40);
    });
  });

  group('undo', () {
    test('drops the last dart', () {
      controller()
        ..addDart(t(20))
        ..addDart(t(20))
        ..undo();

      expect(session().leg.remaining[1], 441);
      expect(session().leg.darts, hasLength(1));
    });

    test('backs out of a turn summary', () {
      controller()
        ..addDart(t(20))
        ..addDart(t(20))
        ..addDart(t(20));
      expect(session().awaitingTurnConfirm, isTrue);

      controller().undo();

      expect(session().awaitingTurnConfirm, isFalse);
      expect(session().leg.currentPlayerId, 1);
      expect(session().leg.dartsThrownThisTurn, 2);
    });

    test('backs out of a finished leg', () {
      container.read(gameConfigProvider.notifier).update(
        GameConfig(startScore: 40, playerIds: const [1, 2]),
      );

      controller().addDart(d(20));
      expect(session().leg.isFinished, isTrue);

      controller().undo();

      expect(session().leg.isFinished, isFalse);
      expect(session().leg.remaining[1], 40);
    });

    test('does nothing on an empty leg', () {
      controller().undo();
      expect(session().leg.darts, isEmpty);
    });
  });

  group('driven by the board', () {
    test('a hit scores, through framing and decoding', () async {
      board.hit(const Segment(20, Ring.triple));
      await settle();

      expect(session().leg.remaining[1], 441);
    });

    test('a split frame scores once', () async {
      board.emitSplit('3.4');
      await settle();

      expect(session().leg.remaining[1], 441);
      expect(session().leg.darts, hasLength(1));
    });

    test('the greeting glued to a hit does not score twice', () async {
      board.emitGreetingGluedTo('3.4');
      await settle();

      expect(session().leg.darts, hasLength(1));
    });

    test('a re-emitted frame is not scored twice', () async {
      board.emitDuplicate('3.4');
      await settle();

      expect(session().leg.remaining[1], 441);
      expect(session().leg.darts, hasLength(1));
    });

    test('a miss uses a dart and scores nothing', () async {
      board.emitMiss();
      await settle();

      expect(session().leg.remaining[1], 501);
      expect(session().leg.darts, hasLength(1));
    });

    test('the button confirms the turn', () async {
      // Distinct segments: three identical frames this close together are a
      // re-emission, not three darts, and are deduped by design.
      board.emitBatch(['3.4', '3.5', '3.6']);
      await settle();
      expect(session().awaitingTurnConfirm, isTrue);

      board.pressButton();
      await settle();

      expect(session().awaitingTurnConfirm, isFalse);
    });

    test('an unknown frame is never scored', () async {
      board.emitBody('4.1');
      await settle();

      expect(session().leg.darts, isEmpty);
      expect(session().leg.remaining[1], 501);
    });

    test('a full turn arriving in one notification scores all three', () async {
      board.emitBatch(['3.4', '3.5', '3.6']);
      await settle();

      expect(session().pendingTurn!.scored, 60 + 20 + 40);
    });
  });

  group('configuration', () {
    test('changing the config starts a fresh leg', () {
      controller().addDart(t(20));

      container.read(gameConfigProvider.notifier).setStartScore(301);

      expect(session().leg.config.startScore, 301);
      expect(session().leg.darts, isEmpty);
      expect(session().leg.remaining[1], 301);
    });

    test('player count is reflected in the seats', () {
      container.read(gameConfigProvider.notifier).setPlayerCount(4);
      expect(session().leg.config.playerIds, [1, 2, 3, 4]);
      expect(session().leg.remaining, hasLength(4));
    });
  });
}
