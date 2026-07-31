/// Which ring of the board a dart landed in.
///
/// The board reports inner and outer singles as distinct physical segments even
/// though both score the same, so the distinction is preserved here: it is
/// meaningless for scoring but useful for the accuracy heatmap.
enum Ring {
  /// Single area between the bull and the triple ring.
  innerSingle(1),

  /// Triple ring.
  triple(3),

  /// Single area between the triple and double rings.
  outerSingle(1),

  /// Double ring.
  doubleRing(2),

  /// Outer bull, worth 25.
  outerBull(1),

  /// Inner bull, worth 50. Counts as a double when checking out.
  innerBull(2);

  const Ring(this.multiplier);

  /// What the segment number is multiplied by to get the score.
  final int multiplier;
}

/// A single scoring area of the dartboard.
///
/// [number] is 1-20 for the numbered wedges and 25 for either bull.
class Segment {
  const Segment(this.number, this.ring)
    : assert(
        (ring == Ring.outerBull || ring == Ring.innerBull)
            ? number == 25
            : number >= 1 && number <= 20,
        'bull segments must be numbered 25, wedges 1-20',
      );

  /// The outer bull, worth 25. Does not count as a double.
  static const Segment outerBull = Segment(25, Ring.outerBull);

  /// The inner bull, worth 50. Counts as a double.
  static const Segment innerBull = Segment(25, Ring.innerBull);

  /// The wedge number, or 25 for a bull.
  final int number;

  final Ring ring;

  /// Points this segment is worth.
  int get value => number * ring.multiplier;

  /// Whether a checkout may legally finish on this segment under double-out.
  bool get isDouble => ring == Ring.doubleRing || ring == Ring.innerBull;

  /// Short scoring notation: `T20`, `D16`, `S5`, `SB`, `DB`.
  ///
  /// Inner and outer singles share the `S` label because they share a score.
  String get label => switch (ring) {
    Ring.innerSingle || Ring.outerSingle => 'S$number',
    Ring.triple => 'T$number',
    Ring.doubleRing => 'D$number',
    Ring.outerBull => 'SB',
    Ring.innerBull => 'DB',
  };

  /// Every scoring area on the board: 20 wedges x 4 rings, plus both bulls.
  ///
  /// This is the full set the board can report and the full search space for
  /// checkout routes.
  static final List<Segment> all = List.unmodifiable([
    for (var number = 1; number <= 20; number++)
      for (final ring in const [
        Ring.innerSingle,
        Ring.triple,
        Ring.outerSingle,
        Ring.doubleRing,
      ])
        Segment(number, ring),
    outerBull,
    innerBull,
  ]);

  @override
  bool operator ==(Object other) =>
      other is Segment && other.number == number && other.ring == ring;

  @override
  int get hashCode => Object.hash(number, ring);

  @override
  String toString() => label;
}
