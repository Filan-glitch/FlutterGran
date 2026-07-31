import '../../domain/segment.dart';

/// Frame bodies the board sends for things that are not darts.
const String buttonCode = 'BTN';
const String missCode = 'OUT';

/// The board's sensor-matrix codes, one row per wedge.
///
/// Each row is `[inner single, triple, outer single, double]`, matching the
/// column order of the published tables so this can be audited line by line.
/// The codes are physical `column.row` coordinates, not scores.
///
/// Derived from the GRANBOARD 3s, on which six independent implementations
/// agree exactly. **No public source has verified the GRANBOARD 132.** Treat
/// this as a provisional default that the calibration screen may override.
const Map<int, List<String>> wedgeCodes = {
  1: ['2.3', '2.4', '2.5', '2.6'],
  2: ['9.1', '9.0', '9.2', '8.2'],
  3: ['7.1', '7.0', '7.2', '8.4'],
  4: ['0.1', '0.3', '0.5', '0.6'],
  5: ['5.1', '5.2', '5.4', '4.6'],
  6: ['1.0', '1.1', '1.3', '4.4'],
  7: ['11.1', '11.2', '11.4', '8.6'],
  8: ['6.2', '6.4', '6.5', '6.6'],
  9: ['9.3', '9.4', '9.5', '9.6'],
  10: ['2.0', '2.1', '2.2', '4.3'],
  11: ['7.3', '7.4', '7.5', '7.6'],
  12: ['5.0', '5.3', '5.5', '5.6'],
  13: ['0.0', '0.2', '0.4', '4.5'],
  14: ['10.3', '10.4', '10.5', '10.6'],
  15: ['3.0', '3.1', '3.2', '4.2'],
  16: ['11.0', '11.3', '11.5', '11.6'],
  17: ['10.1', '10.0', '10.2', '8.3'],
  18: ['1.2', '1.4', '1.5', '1.6'],
  19: ['6.1', '6.0', '6.3', '8.5'],
  20: ['3.3', '3.4', '3.5', '3.6'],
};

/// Bull codes. `8.0` is the outer bull (25), `4.0` the inner bull (50).
const String outerBullCode = '8.0';
const String innerBullCode = '4.0';

/// The ring each column of [wedgeCodes] describes.
const List<Ring> _ringOrder = [
  Ring.innerSingle,
  Ring.triple,
  Ring.outerSingle,
  Ring.doubleRing,
];

/// Frame body to board segment, for a standard board.
final Map<String, Segment> granboardSegmentMap = Map<String, Segment>.unmodifiable({
  for (final entry in wedgeCodes.entries)
    for (var ring = 0; ring < _ringOrder.length; ring++)
      entry.value[ring]: Segment(entry.key, _ringOrder[ring]),
  outerBullCode: Segment.outerBull,
  innerBullCode: Segment.innerBull,
});

/// Matrix slots that exist in the hardware but carry no segment.
///
/// The grid is 12 columns of 7 rows. Ten columns serve two wedges each, which
/// needs eight segments in seven rows, so exactly one double per column
/// overflows into column 4 or 8 - the columns that also hold the bulls. That
/// accounts for 82 of the 84 slots and leaves these two empty, so a frame
/// carrying either is a decoding fault rather than a real hit.
const Set<String> unusedMatrixSlots = {'4.1', '8.1'};
