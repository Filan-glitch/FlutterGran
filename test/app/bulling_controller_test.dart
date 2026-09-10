import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/bulling_controller.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

/// Lets queued stream events reach the controller before assertions run.
Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeBoardSource board;
  late ProviderContainer container;

  BullingSession session() => container.read(bullingGameProvider);
  BullingController controller() =>
      container.read(bullingGameProvider.notifier);

  setUp(() {
    board = FakeBoardSource();
    container = ProviderContainer(
      overrides: [boardSourceProvider.overrideWithValue(board)],
    );
    container.listen(bullingGameProvider, (_, _) {});
  });

  tearDown(() {
    container.dispose();
    board.dispose();
  });

  final ThrownDart sbull = ThrownDart(Segment.outerBull);
  final ThrownDart dbull = ThrownDart(Segment.innerBull);

  group('scoring by hand', () {
    test('an outer bull adds a point', () {
      controller().addDart(sbull);
      expect(session().leg.score[1], 1);
    });

    test('a third dart ends the turn and holds the summary', () {
      controller()
        ..addDart(sbull)
        ..addDart(const ThrownDart.miss())
        ..addDart(const ThrownDart.miss());

      expect(session().awaitingTurnConfirm, isTrue);
      expect(session().pendingTurn!.scored, 1);
      expect(session().leg.currentPlayerId, 2);
    });

    test('darts thrown while the summary is up are ignored', () {
      controller()
        ..addDart(sbull)
        ..addDart(const ThrownDart.miss())
        ..addDart(const ThrownDart.miss());

      controller().addDart(sbull);

      expect(session().leg.score[2], 0);
      expect(session().leg.darts, hasLength(3));
    });

    test('confirming lets play resume', () {
      controller()
        ..addDart(sbull)
        ..addDart(const ThrownDart.miss())
        ..addDart(const ThrownDart.miss())
        ..confirmTurn()
        ..addDart(sbull);

      expect(session().awaitingTurnConfirm, isFalse);
      expect(session().leg.score[2], 1);
    });
  });

  group('undo', () {
    test('drops the last dart', () {
      controller()
        ..addDart(sbull)
        ..addDart(sbull)
        ..undo();

      expect(session().leg.score[1], 1);
      expect(session().leg.darts, hasLength(1));
    });

    test('backs out of a turn summary', () {
      controller()
        ..addDart(sbull)
        ..addDart(const ThrownDart.miss())
        ..addDart(const ThrownDart.miss());
      expect(session().awaitingTurnConfirm, isTrue);

      controller().undo();

      expect(session().awaitingTurnConfirm, isFalse);
      expect(session().leg.currentPlayerId, 1);
      expect(session().leg.dartsThrownThisTurn, 2);
    });

    test('does nothing on an empty leg', () {
      controller().undo();
      expect(session().leg.darts, isEmpty);
    });
  });

  group('driven by the board', () {
    setUp(() => controller().restart());

    test('a hit is ignored when no leg is open', () async {
      controller().leave();

      board.hit(Segment.outerBull);
      await settle();

      expect(session().leg.darts, isEmpty);
    });

    test('a hit scores, through framing and decoding', () async {
      board.hit(Segment.outerBull);
      await settle();

      expect(session().leg.score[1], 1);
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
    test('restores the score and whose turn it is', () {
      final config = BullingConfig(
        playerIds: const [1, 2],
        bullseyeValue: BullseyeValue.two,
        target: 99,
      );
      controller().resume(config, [sbull, sbull, const ThrownDart.miss(), sbull]);

      expect(session().leg.score[1], 2);
      expect(session().leg.score[2], 1);
      expect(session().leg.currentPlayerId, 2);
      expect(session().leg.dartsThrownThisTurn, 1);
    });

    test('an empty log resumes as a fresh leg', () {
      final config = BullingConfig(
        playerIds: const [1],
        bullseyeValue: BullseyeValue.three,
        target: 21,
      );
      controller().resume(config, const []);

      expect(session().leg.score[1], 0);
      expect(session().leg.darts, isEmpty);
    });

    test('reopens the leg to board input', () async {
      controller()
        ..leave()
        ..resume(
          BullingConfig(
            playerIds: const [1, 2],
            bullseyeValue: BullseyeValue.two,
            target: 99,
          ),
          [sbull],
        );

      board.hit(Segment.outerBull);
      await settle();

      expect(session().leg.darts, hasLength(2));
    });
  });

  group('configuration', () {
    test('changing the config starts a fresh leg', () {
      controller().addDart(sbull);

      container.read(bullingConfigProvider.notifier).update(
        BullingConfig(
          playerIds: const [1, 2],
          bullseyeValue: BullseyeValue.three,
          target: 31,
        ),
      );

      expect(session().leg.config.bullseyeValue, BullseyeValue.three);
      expect(session().leg.darts, isEmpty);
    });
  });

  test('reaching the target wins the leg instantly', () {
    container.read(bullingConfigProvider.notifier).update(
      BullingConfig(
        playerIds: const [1, 2],
        bullseyeValue: BullseyeValue.three,
        target: 3,
      ),
    );
    controller().restart();

    controller().addDart(dbull);

    expect(session().leg.isFinished, isTrue);
    expect(session().leg.winnerId, 1);
  });
}
