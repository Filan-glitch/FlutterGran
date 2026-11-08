/// [AimTarget], what a player was aiming at, and [MissDirection], where a dart
/// went relative to it. Training drills and aim inference both speak in these.
///
/// {@category Game modes}
library;

import '../segment.dart';

/// Which part of a number counts as hitting it.
enum AimKind {
  /// Either single bed of the number.
  single,

  /// The double ring.
  double,

  /// The triple ring.
  triple,

  /// Either bull, outer or inner.
  bull,

  /// The inner bull only.
  bullseye,
}

/// Where a dart landed relative to the [AimTarget] it was thrown at.
enum MissDirection {
  /// It hit the target.
  hit,

  /// Same number, but closer to the centre than the target ring - or a bull
  /// when a wedge was the target.
  inside,

  /// Same number but further out, off the board, or a wedge when a bull was
  /// the target.
  outside,

  /// One wedge anticlockwise of the target.
  left,

  /// One wedge clockwise of the target.
  right,

  /// Some other wedge, not a neighbour.
  elsewhere,
}

/// A target a player aims at: a number and which part of it counts.
class AimTarget {
  const AimTarget(this.number, this.kind)
    : assert(
        (kind == AimKind.bull || kind == AimKind.bullseye)
            ? number == 25
            : number >= 1 && number <= 20,
        'bull targets must be numbered 25, wedges 1-20',
      );

  const AimTarget.double(int number) : this(number, AimKind.double);

  const AimTarget.triple(int number) : this(number, AimKind.triple);

  const AimTarget.single(int number) : this(number, AimKind.single);

  static const AimTarget bull = AimTarget(25, AimKind.bull);

  static const AimTarget bullseye = AimTarget(25, AimKind.bullseye);

  final int number;

  final AimKind kind;

  bool get isBull => number == 25;

  /// Short notation in the same style as [Segment.label]: `D16`, `T20`,
  /// `S5`, `BULL` for either bull, `DB` for the bullseye.
  String get label => switch (kind) {
    AimKind.single => 'S$number',
    AimKind.double => 'D$number',
    AimKind.triple => 'T$number',
    AimKind.bull => 'BULL',
    AimKind.bullseye => 'DB',
  };

  /// Whether a dart in [segment] counts as hitting this target. A miss
  /// (null) never does.
  bool isHitBy(Segment? segment) {
    if (segment == null) return false;
    return switch (kind) {
      AimKind.single =>
        segment.number == number &&
            (segment.ring == Ring.innerSingle ||
                segment.ring == Ring.outerSingle),
      AimKind.double =>
        segment.number == number && segment.ring == Ring.doubleRing,
      AimKind.triple => segment.number == number && segment.ring == Ring.triple,
      AimKind.bull => segment.number == 25,
      AimKind.bullseye => segment.ring == Ring.innerBull,
    };
  }

  /// Where a dart in [segment] went relative to this target.
  MissDirection missDirection(Segment? segment) {
    if (isHitBy(segment)) return MissDirection.hit;
    if (segment == null) return MissDirection.outside;

    if (isBull) {
      // Only an outer bull at the bullseye stays in the bull; it fell short
      // of the centre, so it counts as outside.
      return MissDirection.outside;
    }
    if (segment.number == 25) return MissDirection.inside;

    if (segment.number == number) {
      return _radius(segment.ring) < _targetRadius
          ? MissDirection.inside
          : MissDirection.outside;
    }

    final at = boardOrder.indexOf(number);
    final hit = boardOrder.indexOf(segment.number);
    if (hit == (at + 1) % boardOrder.length) return MissDirection.right;
    if (hit == (at - 1 + boardOrder.length) % boardOrder.length) {
      return MissDirection.left;
    }
    return MissDirection.elsewhere;
  }

  /// The target's distance from the centre, on the [_radius] scale. Only
  /// asked of wedge targets whose miss landed in the same number, so a
  /// single target - which accepts both single beds - never reaches here.
  int get _targetRadius => switch (kind) {
    AimKind.triple => _radius(Ring.triple),
    _ => _radius(Ring.doubleRing),
  };

  static int _radius(Ring ring) => switch (ring) {
    Ring.innerBull || Ring.outerBull => 0,
    Ring.innerSingle => 1,
    Ring.triple => 2,
    Ring.outerSingle => 3,
    Ring.doubleRing => 4,
  };

  @override
  bool operator ==(Object other) =>
      other is AimTarget && other.number == number && other.kind == kind;

  @override
  int get hashCode => Object.hash(number, kind);

  @override
  String toString() => label;
}
