/// Riverpod wiring for the board lights: the one [LedScheduler], and a provider
/// per game mode that feeds it cues and the resting ring.
///
/// {@category App}
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/board/led_command.dart';
import '../../domain/x01/x01_rules.dart';
import '../providers.dart';
import '../training_controller.dart';
import 'led_cue.dart';
import 'led_reactions.dart';
import 'led_scheduler.dart';
import 'led_theme.dart';

/// The one scheduler that owns the ring, for the life of the app.
///
/// Also plays the connect sweep and owns the idle pulse between games: both
/// belong to the board, not to any game, so `main.dart` watches this for the
/// life of the app.
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

/// Lights for an x01 leg.
///
/// Listen-only, watched by the game screen - see [soundControllerProvider].
/// Auto-disposed when the screen goes, which hands the ring back to the idle
/// pulse; the other modes' light providers work the same way.
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

/// Lights for an Around the Clock leg - see [x01LightsProvider].
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

/// Lights for a Bulling leg - see [x01LightsProvider].
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

/// Lights for a Higher/Lower leg - see [x01LightsProvider].
final higherLowerLightsProvider = Provider.autoDispose<void>((ref) {
  _drive(
    ref,
    ring: () => higherLowerRing(ref.read(higherLowerGameProvider)),
    opening: ref.read(higherLowerGameProvider).leg.darts.isEmpty,
    listen: (perform) => ref.listen(
      higherLowerGameProvider,
      (previous, next) => perform(ledCuesForHigherLower(previous, next)),
    ),
  );
});

/// Lights for a training session - see [x01LightsProvider]. Free practice
/// has no resting ring; the checkout drills show the route, the target
/// drills the target.
final trainingLightsProvider = Provider.autoDispose<void>((ref) {
  RingPaint ring() => switch (ref.read(trainingProvider)) {
    FreePracticeSession() => RingPaint.off,
    CheckoutChallengeSession(:final state) =>
      state.config.showRoute && state.current != null
          ? x01Ring(
              state.current!.leg,
              awaitingTurnConfirm: false,
              bestRoute: ref
                  .read(checkoutTableProvider(state.config.outRule))
                  .bestFor,
            )
          : RingPaint.off,
    Ladder121Session(:final state) => switch (state.current) {
      null => RingPaint.off,
      final attempt => x01Ring(
        attempt.leg,
        awaitingTurnConfirm: false,
        bestRoute: ref.read(checkoutTableProvider(X01OutRule.double)).bestFor,
      ),
    },
    Bobs27Session(:final state) => aimRing(state.currentTarget),
    WeakSpotSession(:final state) => aimRing(state.currentTarget),
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
