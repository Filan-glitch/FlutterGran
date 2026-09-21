import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/lights/led_scheduler.dart';
import 'package:fluttergran/app/lights/led_theme.dart';
import 'package:fluttergran/app/lights/lights_providers.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/board/led_command.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

// Timers drive the scheduler, so these run under `testWidgets` for its fake
// clock - no widget is ever pumped.
void main() {
  const gap = Duration(milliseconds: 60);
  const hit = EffectFrame(LedEffect.flicker, speed: 1);
  const big = EffectFrame(LedEffect.rainbowFlicker, speed: 2);
  const idle = EffectFrame(LedEffect.pulse, speed: 25);
  final yellow20 = RingPaint.only({20: RingColor.yellow});

  LedShow show(
    LedCommand command, {
    int priority = 1,
    Duration? hold = const Duration(seconds: 1),
  }) => LedShow([LedStep(command, hold)], priority: priority);

  late List<LedCommand> sent;
  late bool connected;
  late LedScheduler scheduler;

  setUp(() {
    sent = [];
    connected = true;
    scheduler = LedScheduler(
      sent.add,
      isConnected: () => connected,
      idle: idle,
    );
  });

  tearDown(() => scheduler.dispose());

  testWidgets('a show plays, then the resting ring comes back', (tester) async {
    scheduler.enterGame();
    scheduler.ambient = yellow20;
    await tester.pump(gap);
    scheduler.play(show(hit));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(gap);
    expect(sent, [RingPaint.off, yellow20, hit, yellow20]);
    expect(scheduler.isShowing, isFalse);
  });

  testWidgets('a lower-priority show does not cut a bigger one short', (
    tester,
  ) async {
    scheduler.play(show(big, priority: LedPriority.big));
    await tester.pump(gap);
    scheduler.play(show(hit));
    await tester.pump(gap);
    expect(sent, [big]);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('writes inside one gap collapse to the latest', (tester) async {
    scheduler.play(show(hit));
    scheduler.play(show(big));
    scheduler.play(show(hit, priority: 1));
    expect(sent, [hit]);
    await tester.pump(gap);
    expect(sent, [hit, hit]);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('the resting ring changing mid-show waits for the show', (
    tester,
  ) async {
    scheduler.enterGame();
    await tester.pump(gap);
    sent.clear();
    scheduler.play(show(hit));
    scheduler.ambient = yellow20;
    await tester.pump(gap);
    expect(sent, [hit]);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(gap);
    expect(sent.last, yellow20);
  });

  testWidgets('an unchanged resting ring is not resent', (tester) async {
    scheduler.enterGame();
    scheduler.ambient = yellow20;
    await tester.pump(gap);
    scheduler.ambient = RingPaint.only({20: RingColor.yellow});
    await tester.pump(gap);
    // Entering the game paints its (still empty) ring first.
    expect(sent, [RingPaint.off, yellow20]);
  });

  testWidgets('outside a game, a show ends on the idle pulse', (tester) async {
    scheduler.ambient = yellow20;
    scheduler.play(show(hit));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(gap);
    expect(sent, [hit, idle]);
  });

  testWidgets('a held step stays until the game is left, then idles', (
    tester,
  ) async {
    scheduler.enterGame();
    scheduler.play(show(big, hold: null));
    await tester.pump(const Duration(minutes: 1));
    expect(sent.last, big);
    scheduler.leaveGame();
    await tester.pump(gap);
    expect(sent.last, idle);
    expect(scheduler.isShowing, isFalse);
  });

  testWidgets('switched off, the ring goes dark once and stays dark', (
    tester,
  ) async {
    scheduler.play(show(hit));
    await tester.pump(gap);
    scheduler.enabled = false;
    scheduler.play(show(big));
    scheduler.enterGame();
    scheduler.ambient = yellow20;
    scheduler.leaveGame();
    await tester.pump(const Duration(seconds: 2));
    expect(sent, [hit, RingPaint.off]);

    scheduler.enabled = true;
    await tester.pump(gap);
    expect(sent.last, idle);
  });

  testWidgets('switching off inside a write gap still gets the dark frame '
      'out', (tester) async {
    scheduler.play(show(hit));
    scheduler.enabled = false;
    await tester.pump(gap);
    expect(sent, [hit, RingPaint.off]);
    await tester.pump(gap);
  });

  testWidgets('nothing is sent or started while disconnected', (tester) async {
    connected = false;
    scheduler.play(show(hit));
    scheduler.ambient = yellow20;
    expect(sent, isEmpty);
    expect(scheduler.isShowing, isFalse);
    expect(scheduler.ambient, yellow20);
  });

  group('wired to a game', () {
    /// A connected fake board behind a fresh container, set up inside the
    /// test body so every timer it starts runs on the test's fake clock.
    Future<(FakeBoardSource, ProviderContainer)> wire(WidgetTester tester) async {
      final board = FakeBoardSource();
      final container = ProviderContainer(
        overrides: [boardSourceProvider.overrideWithValue(board)],
      );
      addTearDown(() async {
        container.dispose();
        await board.dispose();
      });
      container.read(ledSchedulerProvider);
      await board.connect();
      await tester.pump(const Duration(seconds: 2));
      return (board, container);
    }

    void startLeg(ProviderContainer container) => container
        .read(gameProvider.notifier)
        .restart(GameConfig(startScore: 501, playerIds: const [1, 2]));

    void throwT20(ProviderContainer container) => container
        .read(gameProvider.notifier)
        .addDart(const ThrownDart(Segment(20, Ring.triple)));

    testWidgets('a leg sweeps on connect, flashes darts, and idles again on '
        'leaving', (tester) async {
      final (board, container) = await wire(tester);
      expect(
        board.ledCommands.first,
        isA<EffectFrame>().having(
          (frame) => frame.effect,
          'effect',
          LedEffect.sweepFade,
        ),
      );
      // Not in a game yet: the sweep hands over to the idle pulse.
      expect(board.ledCommands.last, idlePulse);

      startLeg(container);
      final lights = container.listen(x01LightsProvider, (_, _) {});
      await tester.pump(const Duration(seconds: 2));
      board.ledCommands.clear();

      throwT20(container);
      await tester.pump(gap);
      expect(
        board.ledCommands.single,
        isA<HitFlash>()
            .having((flash) => flash.number, 'number', 20)
            .having((flash) => flash.kind, 'kind', HitFlashKind.tripled),
      );

      lights.close();
      await tester.pump(const Duration(seconds: 2));
      expect(board.ledCommands.last, idlePulse);
    });

    testWidgets('switching the lights off leaves the board dark, once', (
      tester,
    ) async {
      final (board, container) = await wire(tester);
      board.ledCommands.clear();

      // Not awaited: the write to shared_preferences has no platform here.
      unawaited(container.read(ledEnabledProvider.notifier).set(false));
      await tester.pump(gap);
      expect(board.ledCommands, [RingPaint.off]);

      startLeg(container);
      final lights = container.listen(x01LightsProvider, (_, _) {});
      throwT20(container);
      await tester.pump(const Duration(seconds: 2));
      lights.close();
      await tester.pump(const Duration(seconds: 2));
      expect(board.ledCommands, [RingPaint.off]);
    });
  });
}
