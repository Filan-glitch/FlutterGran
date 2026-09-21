/// Commands for the board's LED ring, and the only bytes the app ever writes.
///
/// Everything here was reverse-engineered by others from the official app's
/// traffic and then checked against a real 132 - see "LED control" in
/// `docs/BOARD_PROTOCOL.md`. The board also accepts 12-byte *settings* frames
/// (reply interval, out sensitivity, target sensitivity) on the same
/// characteristic. Those change how the board scores and are deliberately
/// unrepresentable: [encodeLedCommand] can only produce a 20-byte ring frame or
/// a 16-byte effect frame, from the closed set of commands below.
library;

import 'dart:typed_data';

/// The static ring's palette. The 20-byte frame carries one of these per
/// segment, not RGB.
enum RingColor {
  off(0x00),
  red(0x01),
  orange(0x02),
  yellow(0x03),
  lightGreen(0x04),
  turquoise(0x05),
  purple(0x06),
  white(0x07);

  const RingColor(this.code);

  final int code;
}

/// A colour for an effect frame, which unlike the ring does take RGB.
class Rgb {
  const Rgb(this.r, this.g, this.b);

  static const Rgb black = Rgb(0, 0, 0);

  final int r;
  final int g;
  final int b;

  @override
  bool operator ==(Object other) =>
      other is Rgb && other.r == r && other.g == g && other.b == b;

  @override
  int get hashCode => Object.hash(r, g, b);

  @override
  String toString() => 'Rgb($r, $g, $b)';
}

/// The effect op-codes confirmed on a 132.
///
/// An allow-list, not a catalogue: `0x19` ("hunt flicker") exists on other
/// boards and does nothing on the 132, so it is not here.
enum LedEffect {
  touchRainbow(0x0C),
  rainbowFlicker(0x0D),
  rainbowRotate(0x0F),
  splitRainbow(0x10),
  nextSweep(0x11),
  pulse(0x14),
  dimSolid(0x15),
  colourCycle(0x16),
  blink(0x17),
  flicker(0x18),
  shake(0x1B),
  sweepFade(0x1D),
  triFade(0x1F);

  const LedEffect(this.op);

  final int op;
}

/// Which hit-flash animation to play on a number.
enum HitFlashKind {
  single(0x01),
  doubled(0x02),
  tripled(0x03);

  const HitFlashKind(this.op);

  final int op;
}

/// Something the ring can be told to do.
sealed class LedCommand {
  const LedCommand();
}

/// Holds a colour per number, S1 to S20.
///
/// Indexed by the number printed on the board, not by position around it -
/// confirmed on the 132.
class RingPaint extends LedCommand {
  RingPaint(List<RingColor> byNumber)
    : assert(byNumber.length == 20, 'one colour per number, 1 to 20'),
      byNumber = List<RingColor>.unmodifiable(byNumber);

  /// Every number [colour].
  RingPaint.all(RingColor colour) : this(List.filled(20, colour));

  /// Only the given numbers lit, everything else off.
  factory RingPaint.only(Map<int, RingColor> colours) => RingPaint([
    for (var number = 1; number <= 20; number++)
      colours[number] ?? RingColor.off,
  ]);

  /// The whole ring dark.
  static final RingPaint off = RingPaint.all(RingColor.off);

  final List<RingColor> byNumber;

  RingColor colourOf(int number) => byNumber[number - 1];

  bool get isOff => byNumber.every((colour) => colour == RingColor.off);

  @override
  bool operator ==(Object other) {
    if (other is! RingPaint) return false;
    for (var i = 0; i < 20; i++) {
      if (other.byNumber[i] != byNumber[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(byNumber);

  @override
  String toString() =>
      'RingPaint(${byNumber.map((colour) => colour.code).join()})';
}

/// The board's own "you hit this number" animation.
class HitFlash extends LedCommand {
  const HitFlash({
    required this.number,
    required this.kind,
    required this.primary,
    required this.secondary,
    this.speed = 20,
  }) : assert(number >= 1 && number <= 20, 'hit flash targets 1 to 20');

  final int number;
  final HitFlashKind kind;
  final Rgb primary;
  final Rgb secondary;

  /// 0 (slow) to 255 (fast).
  final int speed;

  @override
  String toString() => 'HitFlash(${kind.name} $number, $primary, $secondary)';
}

/// One of the board's canned animations.
class EffectFrame extends LedCommand {
  const EffectFrame(
    this.effect, {
    this.a = Rgb.black,
    this.b = Rgb.black,
    this.c = Rgb.black,
    this.speed = 10,
  });

  final LedEffect effect;
  final Rgb a;
  final Rgb b;
  final Rgb c;

  /// 0 (fast) to 35 (slow). Note this runs the opposite way to
  /// [HitFlash.speed] - that is how the board takes them.
  final int speed;

  @override
  String toString() => 'EffectFrame(${effect.name}, $a, $b, $c, $speed)';
}

/// Hit-flash target ids, by number. Not derivable - lifted from captures.
const List<int> _hitTargetIds = [
  0x1C, 0x31, 0x37, 0x22, 0x16, 0x28, 0x01, 0x07, 0x10, 0x2B, //
  0x0A, 0x13, 0x25, 0x0D, 0x2E, 0x04, 0x34, 0x1F, 0x3A, 0x19,
];

/// The highest speed byte an effect frame is sent with.
const int maxEffectSpeed = 35;

/// The bytes for [command], ready for the board's write characteristic.
Uint8List encodeLedCommand(LedCommand command) => switch (command) {
  RingPaint(:final byNumber) => Uint8List.fromList([
    for (final colour in byNumber) colour.code,
  ]),
  HitFlash() => _effectFrame(command.kind.op, (frame) {
    _putRgb(frame, 1, command.primary);
    _putRgb(frame, 4, command.secondary);
    final target = _hitTargetIds[command.number - 1];
    frame[10] = target & 0xFF;
    frame[11] = (target >> 8) & 0xFF;
    frame[12] = command.speed.clamp(0, 255);
  }),
  EffectFrame(:final effect) => _effectFrame(effect.op, (frame) {
    _putRgb(frame, 1, command.a);
    _putRgb(frame, 4, command.b);
    _putRgb(frame, 7, command.c);
    frame[12] = command.speed.clamp(0, maxEffectSpeed);
    // Mode bytes the captures always carry for these ops. Without them the
    // board plays something else or nothing.
    switch (effect) {
      case LedEffect.rainbowFlicker:
        frame[11] = 0x02;
        frame[13] = 0x02;
      case LedEffect.nextSweep:
        frame[10] = 0x10;
      case LedEffect.pulse:
        frame[4] = 0x7D;
      default:
        break;
    }
  }),
};

Uint8List _effectFrame(int op, void Function(Uint8List frame) fill) {
  final frame = Uint8List(16);
  frame[0] = op;
  fill(frame);
  // Every captured effect frame ends in 0x01.
  frame[15] = 0x01;
  return frame;
}

void _putRgb(Uint8List frame, int at, Rgb colour) {
  frame[at] = colour.r.clamp(0, 255);
  frame[at + 1] = colour.g.clamp(0, 255);
  frame[at + 2] = colour.b.clamp(0, 255);
}
