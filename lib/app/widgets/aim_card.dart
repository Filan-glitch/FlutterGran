import 'package:flutter/material.dart';

import '../../domain/atc/atc_stop.dart';
import '../../domain/atc/atc_variant.dart';
import '../../domain/segment.dart';
import '../l10n_extensions.dart';
import 'aim_strip.dart';

/// Key on the whole card, for tests.
const Key aimCardKey = Key('aim-card');

/// Around the Clock's answer to the checkout card: the stop to hit next, as
/// one chip per bed that clears it.
///
/// The chips come from the variant's own rule, so "doubles only" asks for a
/// double and "masters" for a double or a treble - read from across the room
/// in the colours of the keys that would enter them.
class AimCard extends StatelessWidget {
  const AimCard({
    super.key,
    required this.stop,
    required this.variant,
    required this.dartsLeft,
    this.hero = false,
  });

  final AtcStop stop;
  final AtcVariant variant;

  final int dartsLeft;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    return AimStrip(
      key: aimCardKey,
      label: context.l10n.aimLabel,
      target: stop.label,
      dartsLeft: dartsLeft,
      hero: hero,
      chips: [
        for (final aim in aimsFor(stop, variant))
          SegmentChip(
            label: aim.label,
            ring: aim.ring,
            caption: aim.caption,
            lit: true,
            hero: hero,
          ),
      ],
    );
  }
}

/// One chip's worth of aim: what it says, which bed it is coloured as, and
/// the line under it.
typedef Aim = ({String label, Ring ring, String? caption});

/// The beds that clear [stop] under [variant], as chips.
///
/// A bull stop is a single ring, so it is one chip whatever the variant. A
/// numbered stop under "any part" is one plain chip for the number rather
/// than three for its beds - any of them will do, and saying so once is
/// clearer than three lit chips.
List<Aim> aimsFor(AtcStop stop, AtcVariant variant) {
  if (stop.ring case final ring?) {
    return [
      (label: stop.label, ring: ring, caption: '${Segment(25, ring).value}'),
    ];
  }

  final number = stop.number!;
  Aim bed(Ring ring) =>
      (label: Segment(number, ring).label, ring: ring, caption: null);

  return switch (variant) {
    AtcVariant.anyPart => [
      (label: '$number', ring: Ring.outerSingle, caption: null),
    ],
    AtcVariant.masters => [bed(Ring.doubleRing), bed(Ring.triple)],
    AtcVariant.doublesOnly => [bed(Ring.doubleRing)],
  };
}
