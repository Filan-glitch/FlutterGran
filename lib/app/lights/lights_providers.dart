import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/board/led_command.dart';
import '../providers.dart';
import '../training_controller.dart';
import 'led_cue.dart';
import 'led_reactions.dart';
import 'led_scheduler.dart';
import 'led_theme.dart';

/// The one scheduler that owns the ring, for the life of the app.
///
/// Also plays the connect sweep and owns the idle pulse between games: both
/// belong to the board, not to any game, so the app root keeps this alive by
/// watching it.
final ledSchedulerProvider = Provider<LedScheduler>((ref) {
  final source = ref.watch(boardSourceProvider);
  final scheduler = LedScheduler(
    (command) => unawaited(source.sendLed(command)),
    isConnected: () => source.currentState.isConnected,
    idle: idlePulse,
  )..enabled = ref.read(ledEnabledProvider);

  final connection = source.connectionState.listen((state) {
    if (state.isConnected && ref.read(ledEnabledProvider)) {
      scheduler.play(showFor(const BoardConnected()));
    }
  });

  // Off darkens the board once and then writes nothing; on paints back
  // whatever it should be resting on.
  ref.listen(ledEnabledProvider, (_, enabled) => scheduler.enabled = enabled);

  ref.onDispose(() {
    unawaited(connection.cancel());
    scheduler.dispose();
  });
  return scheduler;
});

/// Plays [cues] through [scheduler], leaving out whatever the settings
/// switch off.
void _perform(Ref ref, LedScheduler scheduler, List<LedCue> cues) {
  if (!ref.read(ledEnabledProvider)) return;
  for (final cue in cues) {
    final allowed = switch (cue.kind) {
      LedCueKind.dart => ref.read(ledDartFlashesProvider),
      LedCueKind.celebration => ref.read(ledCelebrationsProvider),
      LedCueKind.turn => true,
    };
    if (allowed) scheduler.play(showFor(cue));
  }
}

/// [ring] if the settings allow a resting ring, otherwise dark.
RingPaint _gateRing(Ref ref, RingPaint ring) =>
    ref.read(ledEnabledProvider) && ref.read(ledTargetRingProvider)
    ? ring
    : RingPaint.off;

/// The wiring every mode shares: react to the game, repaint the resting ring,
/// follow the switches, and hand back to the idle pulse when the game screen
/// goes away.
///
/// [ring] reads the current resting ring from scratch; [opening] is true when
/// the game on screen has not had a dart thrown yet.
void _drive(
  Ref ref, {
  required RingPaint Function() ring,
  required bool opening,
  required void Function(void Function(List<LedCue> cues) perform) listen,
}) {
  final scheduler = ref.watch(ledSchedulerProvider);
  void paint() => scheduler.ambient = _gateRing(ref, ring());

  listen((cues) {
    _perform(ref, scheduler, cues);
    paint();
  });

  ref.listen(ledEnabledProvider, (_, enabled) {
    if (enabled) paint();
  });
  ref.listen(ledTargetRingProvider, (_, _) => paint());

  scheduler.enterGame();
  if (opening) _perform(ref, scheduler, const [GameOn()]);
  paint();

  ref.onDispose(scheduler.leaveGame);
}

/// Lights for an x01 leg. The game screen keeps it alive by watching it.
final x01LightsProvider = Provider.autoDispose<void>((ref) {
  RingPaint ring() {
    final session = ref.read(gameProvider);
    final leg = session.leg;
    return x01Ring(
      leg,
      awaitingTurnConfirm: session.awaitingTurnConfirm,
      bestRoute: ref.read(checkoutTableProvider(leg.config.outRule)).bestFor,
    );
  }

  _drive(
    ref,
    ring: ring,
    opening: ref.read(gameProvider).leg.darts.isEmpty,
    listen: (perform) => ref.listen(gameProvider, (previous, next) {
      perform(
        ledCuesFor(
          previous,
          next,
          // No match at all means a lone leg, which is the whole game.
          endsMatch: ref.read(matchStateProvider)?.isFinished ?? true,
        ),
      );
    }),
  );
});

final atcLightsProvider = Provider.autoDispose<void>((ref) {
  _drive(
    ref,
    ring: () => atcRing(ref.read(atcGameProvider)),
    opening: ref.read(atcGameProvider).leg.darts.isEmpty,
    listen: (perform) => ref.listen(
      atcGameProvider,
      (previous, next) => perform(ledCuesForAtc(previous, next)),
    ),
  );
});

final bullingLightsProvider = Provider.autoDispose<void>((ref) {
  _drive(
    ref,
    ring: () => bullingRing(ref.read(bullingGameProvider)),
    opening: ref.read(bullingGameProvider).leg.darts.isEmpty,
    listen: (perform) => ref.listen(
      bullingGameProvider,
      (previous, next) => perform(ledCuesForBulling(previous, next)),
    ),
  );
});

final trainingLightsProvider = Provider.autoDispose<void>((ref) {
  RingPaint ring() => switch (ref.read(trainingProvider)) {
    CheckoutPracticeSession(:final leg) => x01Ring(
      leg,
      awaitingTurnConfirm: false,
      bestRoute: ref.read(checkoutTableProvider(leg.config.outRule)).bestFor,
    ),
    FreePracticeSession() => RingPaint.off,
  };

  _drive(
    ref,
    ring: ring,
    opening: false,
    listen: (perform) => ref.listen(
      trainingProvider,
      (previous, next) => perform(ledCuesForTraining(previous, next)),
    ),
  );
});
