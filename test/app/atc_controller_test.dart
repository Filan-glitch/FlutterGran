import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/atc_controller.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/domain/atc/atc_config.dart';
import 'package:fluttergran/domain/atc/atc_variant.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

/// Lets queued stream events reach the controller before assertions run.
Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeBoardSource board;
  late ProviderContainer container;

  AtcSession session() => container.read(atcGameProvider);
  AtcController controller() => container.read(atcGameProvider.notifier);

  setUp(() {
    board = FakeBoardSource();
    container = ProviderContainer(
      overrides: [boardSourceProvider.overrideWithValue(board)],
    );
    container.listen(atcGameProvider, (_, _) {});
  });

  tearDown(() {
    container.dispose();
    board.dispose();
  });

  ThrownDart s(int n) => ThrownDart(Segment(n, Ring.outerSingle));
  ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));

  group('scoring by hand', () {
    test('a hit on the current number advances the stop', () {
      controller().addDart(s(1));
      expect(session().leg.stopIndex[1], 1);
    });

    test('a third dart ends the turn and holds the summary', () {
      controller()
        ..addDart(s(1))
        ..addDart(const ThrownDart.miss())
        ..addDart(const ThrownDart.miss());

      expect(session().awaitingTurnConfirm, isTrue);
      expect(session().pendingTurn!.stopsCleared, 1);
      expect(session().leg.currentPlayerId, 2);
    });

    test('darts thrown while the summary is up are ignored', () {
      controller()
        ..addDart(s(1))
        ..addDart(const ThrownDart.miss())
        ..addDart(const ThrownDart.miss());

      controller().addDart(s(1));

      expect(session().leg.stopIndex[2], 0);
      expect(session().leg.darts, hasLength(3));
    });

    test('confirming lets play resume', () {
      controller()
        ..addDart(s(1))
        ..addDart(const ThrownDart.miss())
        ..addDart(const ThrownDart.miss())
        ..confirmTurn()
        ..addDart(s(1));

      expect(session().awaitingTurnConfirm, isFalse);
      expect(session().leg.stopIndex[2], 1);
    });
  });

  group('undo', () {
    test('drops the last dart', () {
      controller()
        ..addDart(s(1))
        ..addDart(s(2))
        ..undo();

      expect(session().leg.stopIndex[1], 1);
      expect(session().leg.darts, hasLength(1));
    });

    test('backs out of a turn summary', () {
      controller()
        ..addDart(s(1))
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

      board.hit(const Segment(1, Ring.outerSingle));
      await settle();

      expect(session().leg.darts, isEmpty);
    });

    test('a hit scores, through framing and decoding', () async {
      board.hit(const Segment(1, Ring.outerSingle));
      await settle();

      expect(session().leg.stopIndex[1], 1);
    });

    test('the button confirms the turn', () async {
      // Distinct segments, same frames `game_controller_test.dart` uses -
      // this test only cares that three darts arrive, not what they score.
      board.emitBatch(['3.4', '3.5', '3.6']);
      await settle();
      expect(session().awaitingTurnConfirm, isTrue);

      board.pressButton();
      await settle();

      expect(session().awaitingTurnConfirm, isFalse);
    });
  });

  group('resuming a stored leg', () {
    test('restores the track and whose turn it is', () {
      final config = AtcConfig(
        playerIds: const [1, 2],
        variant: AtcVariant.anyPart,
      );
      controller().resume(config, [s(1), s(2), s(3), s(1)]);

      expect(session().leg.stopIndex[1], 3);
      expect(session().leg.stopIndex[2], 1);
      expect(session().leg.currentPlayerId, 2);
      expect(session().leg.dartsThrownThisTurn, 1);
    });

    test('an empty log resumes as a fresh leg', () {
      final config = AtcConfig(
        playerIds: const [1],
        variant: AtcVariant.masters,
      );
      controller().resume(config, const []);

      expect(session().leg.stopIndex[1], 0);
      expect(session().leg.darts, isEmpty);
    });

    test('reopens the leg to board input', () async {
      controller()
        ..leave()
        ..resume(
          AtcConfig(playerIds: const [1, 2], variant: AtcVariant.anyPart),
          [s(1)],
        );

      board.hit(const Segment(2, Ring.outerSingle));
      await settle();

      expect(session().leg.darts, hasLength(2));
    });
  });

  group('configuration', () {
    test('changing the config starts a fresh leg', () {
      controller().addDart(s(1));

      container.read(atcConfigProvider.notifier).update(
        AtcConfig(playerIds: const [1, 2], variant: AtcVariant.doublesOnly),
      );

      expect(session().leg.config.variant, AtcVariant.doublesOnly);
      expect(session().leg.darts, isEmpty);
    });
  });

  test('a variant that requires a double ignores a single', () {
    container.read(atcConfigProvider.notifier).update(
      AtcConfig(playerIds: const [1, 2], variant: AtcVariant.doublesOnly),
    );
    controller().restart();

    controller().addDart(t(1));

    expect(session().leg.stopIndex[1], 0);
  });
}
