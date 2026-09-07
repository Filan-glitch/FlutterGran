import '../segment.dart';
import 'atc_variant.dart';

/// One of the 22 positions on an Around the Clock track.
///
/// The first 20 are the numbered wedges, 1 through 20 in order; the last two
/// are the outer bull and the bullseye. The two bull stops are each a single
/// physical ring, so - unlike a numbered stop - a variant has nothing to
/// restrict on them: any hit on the correct bull ring clears the stop,
/// regardless of [AtcVariant].
///
/// Instances are only ever the 22 canonical ones in [track], so identity
/// equality is enough - nothing constructs an `AtcStop` outside this file.
class AtcStop {
  const AtcStop._numbered(this.number) : ring = null, label = '$number';

  const AtcStop._bull(this.ring, this.label) : number = null;

  /// The wedge number this stop is for, or null for a bull stop.
  final int? number;

  /// The bull ring this stop is for, or null for a numbered stop.
  final Ring? ring;

  /// How this stop reads on screen: the number, `BULL`, or `BULLSEYE`.
  final String label;

  /// The full track in throwing order: 1 through 20, then the outer bull,
  /// then the bullseye.
  static final List<AtcStop> track = List.unmodifiable([
    for (var number = 1; number <= 20; number++) AtcStop._numbered(number),
    const AtcStop._bull(Ring.outerBull, 'BULL'),
    const AtcStop._bull(Ring.innerBull, 'BULLSEYE'),
  ]);

  /// Whether [segment] clears this stop under [variant].
  bool clears(Segment segment, AtcVariant variant) {
    final ring = this.ring;
    if (ring != null) return segment.ring == ring;

    if (segment.number != number) return false;
    return switch (variant) {
      AtcVariant.anyPart => true,
      AtcVariant.masters =>
        segment.ring == Ring.doubleRing || segment.ring == Ring.triple,
      AtcVariant.doublesOnly => segment.ring == Ring.doubleRing,
    };
  }

  @override
  String toString() => label;
}
