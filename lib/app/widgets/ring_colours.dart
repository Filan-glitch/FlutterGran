import 'package:flutter/painting.dart';

import '../../domain/segment.dart';
import '../theme.dart';

/// A dart's fill and ink, by the ring it lands in: the board's own colours.
///
/// Shared by the keypad and the checkout card, so a treble on the key that
/// enters it and a treble in the route that asks for it are the same green.
/// Null is a miss, which enters nothing.
(Color fill, Color ink) ringColours(Ring? ring) => switch (ring) {
  Ring.doubleRing || Ring.innerBull => (Palette.doubleBed, Palette.chalk),
  Ring.triple || Ring.outerBull => (Palette.trebleBed, Palette.chalk),
  null => (Palette.sunk, Palette.chalkDim),
  _ => (Palette.raised, Palette.chalk),
};
