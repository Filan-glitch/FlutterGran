import '../../data/board/led_command.dart';
import '../../domain/segment.dart';
import 'led_cue.dart';

/// One frame of a show and how long it owns the ring.
class LedStep {
  const LedStep(this.command, this.hold);

  final LedCommand command;

  /// Null holds until something of equal or higher priority replaces it.
  final Duration? hold;
}

/// What a cue looks like: a few steps, then back to the resting ring.
class LedShow {
  const LedShow(this.steps, {required this.priority});

  final List<LedStep> steps;

  /// A show is not interrupted by one of lower priority. A 180 is not cut
  /// short by a stray dart landing during it.
  final int priority;
}

/// Show priorities, lowest first.
abstract final class LedPriority {
  static const int dart = 1;
  static const int turn = 2;
  static const int big = 3;
  static const int matchOver = 4;
}

/// Each seat's colour on the board, as RGB for effects and as the nearest
/// ring palette code, so a flash and the resting ring never disagree.
const List<(Rgb, RingColor)> seatColours = [
  (Rgb(0, 220, 200), RingColor.turquoise),
  (Rgb(255, 120, 0), RingColor.orange),
  (Rgb(160, 0, 255), RingColor.purple),
  (Rgb(120, 255, 40), RingColor.lightGreen),
];

Rgb seatRgb(int seat) => seatColours[seat % seatColours.length].$1;

const Rgb _white = Rgb(255, 255, 255);
const Rgb _red = Rgb(255, 0, 0);
const Rgb _gold = Rgb(255, 190, 0);
const Rgb _brandGreen = Rgb(47, 143, 91);
const Rgb _hitGreen = Rgb(0, 255, 60);
const Rgb _missPurple = Rgb(90, 0, 120);
const Rgb _forestGreen = Rgb(34, 139, 34);

/// What the ring does outside a game: a slow forest-green pulse, so a
/// connected board reads as "on and waiting" rather than off.
const LedCommand idlePulse = EffectFrame(
  LedEffect.pulse,
  a: _forestGreen,
  speed: 25,
);

/// How long each show holds the ring before the resting ring comes back.
///
/// The board's own effects loop or end on their own - it varies by op - so
/// the app does not rely on either: it holds for this long and then repaints.
abstract final class LedTiming {
  static const Duration hit = Duration(milliseconds: 900);
  static const Duration miss = Duration(milliseconds: 600);
  static const Duration bust = Duration(milliseconds: 1500);
  static const Duration tonPlus = Duration(milliseconds: 1500);
  static const Duration maximum = Duration(milliseconds: 3000);
  static const Duration nextThrower = Duration(milliseconds: 1200);
  static const Duration gameOn = Duration(milliseconds: 1500);
  static const Duration connected = Duration(milliseconds: 1500);
  static const Duration legWonFade = Duration(milliseconds: 1500);
  static const Duration legWonRainbow = Duration(milliseconds: 2000);
  static const Duration matchWonBurst = Duration(milliseconds: 2500);
}

/// The curated look of every cue. The one place to tune colours and speeds.
LedShow showFor(LedCue cue) => switch (cue) {
  DartLanded(:final segment, :final seat) => LedShow([
    LedStep(_flashFor(segment, seatRgb(seat)), LedTiming.hit),
  ], priority: LedPriority.dart),
  TargetHit(:final segment) => LedShow([
    LedStep(_flashFor(segment, _hitGreen), LedTiming.hit),
  ], priority: LedPriority.dart),
  DartMissed() => const LedShow([
    LedStep(
      EffectFrame(LedEffect.flicker, a: _missPurple, speed: 15),
      LedTiming.miss,
    ),
  ], priority: LedPriority.dart),
  TurnBusted() => const LedShow([
    LedStep(EffectFrame(LedEffect.flicker, a: _red, speed: 4), LedTiming.bust),
  ], priority: LedPriority.turn),
  NextThrower(:final seat) => LedShow([
    LedStep(
      EffectFrame(LedEffect.nextSweep, a: seatRgb(seat), b: _white, speed: 5),
      LedTiming.nextThrower,
    ),
  ], priority: LedPriority.turn),
  BoardConnected() => const LedShow([
    LedStep(
      EffectFrame(LedEffect.sweepFade, a: _brandGreen, speed: 10),
      LedTiming.connected,
    ),
  ], priority: LedPriority.turn),
  GameOn() => const LedShow([
    LedStep(EffectFrame(LedEffect.rainbowRotate, speed: 3), LedTiming.gameOn),
  ], priority: LedPriority.dart),
  TonPlus() => const LedShow([
    LedStep(EffectFrame(LedEffect.pulse, a: _gold, speed: 8), LedTiming.tonPlus),
  ], priority: LedPriority.turn),
  Maximum() => const LedShow([
    LedStep(
      EffectFrame(LedEffect.rainbowFlicker, speed: 4),
      LedTiming.maximum,
    ),
  ], priority: LedPriority.big),
  LegWon(:final seat) => LedShow([
    LedStep(
      EffectFrame(
        LedEffect.triFade,
        a: seatRgb(seat),
        b: _white,
        c: seatRgb(seat),
        speed: 8,
      ),
      LedTiming.legWonFade,
    ),
    const LedStep(
      EffectFrame(LedEffect.splitRainbow, speed: 5),
      LedTiming.legWonRainbow,
    ),
  ], priority: LedPriority.big),
  MatchWon(:final seat) => LedShow([
    LedStep(
      EffectFrame(
        LedEffect.triFade,
        a: seatRgb(seat),
        b: _white,
        c: seatRgb(seat),
        speed: 8,
      ),
      LedTiming.legWonFade,
    ),
    const LedStep(
      EffectFrame(LedEffect.splitRainbow, speed: 5),
      LedTiming.matchWonBurst,
    ),
    // Held for as long as the end screen is up; leaving the game hands the
    // ring back to the idle pulse.
    const LedStep(EffectFrame(LedEffect.rainbowRotate, speed: 20), null),
  ], priority: LedPriority.matchOver),
};

/// The hit flash for a wedge, or a bull fade for the bull - the hit flash has
/// no target id for the bull.
LedCommand _flashFor(Segment segment, Rgb colour) => switch (segment.ring) {
  Ring.outerBull => const EffectFrame(
    LedEffect.triFade,
    a: Rgb(0, 80, 255),
    b: Rgb(0, 220, 200),
    c: _white,
    speed: 12,
  ),
  Ring.innerBull => const EffectFrame(
    LedEffect.triFade,
    a: _red,
    b: Rgb(255, 120, 0),
    c: Rgb(255, 220, 0),
    speed: 8,
  ),
  Ring.innerSingle || Ring.outerSingle => HitFlash(
    number: segment.number,
    kind: HitFlashKind.single,
    primary: colour,
    secondary: _white,
    speed: 20,
  ),
  Ring.doubleRing => HitFlash(
    number: segment.number,
    kind: HitFlashKind.doubled,
    primary: colour,
    secondary: _white,
    speed: 40,
  ),
  Ring.triple => HitFlash(
    number: segment.number,
    kind: HitFlashKind.tripled,
    primary: colour,
    secondary: _white,
    speed: 60,
  ),
};
