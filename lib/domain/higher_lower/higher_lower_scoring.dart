import '../segment.dart';

/// Points a dart is worth in Higher/Lower, or null for a miss.
///
/// Every segment scores its usual value except treble 1, which counts as 0 -
/// the one way to bring a turn in under 3. A miss is null rather than 0
/// because it is not a low score: it ends the turn and puts the player out.
int? higherLowerPointsFor(Segment? segment) {
  if (segment == null) return null;
  if (segment.number == 1 && segment.ring == Ring.triple) return 0;
  return segment.value;
}
