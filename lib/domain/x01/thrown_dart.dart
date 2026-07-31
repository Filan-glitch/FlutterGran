import '../segment.dart';

/// One dart as recorded in a leg.
///
/// [segment] is null for a miss - either the board's `OUT@` or, far more often,
/// a dart the player marked as missed because it bounced out or landed off the
/// board entirely.
class ThrownDart {
  const ThrownDart(Segment this.segment);

  const ThrownDart.miss() : segment = null;

  final Segment? segment;

  /// Points scored. A miss scores zero.
  int get value => segment?.value ?? 0;

  /// Whether this dart may legally finish a leg under double-out.
  bool get isDouble => segment?.isDouble ?? false;

  String get label => segment?.label ?? 'MISS';

  @override
  bool operator ==(Object other) =>
      other is ThrownDart && other.segment == segment;

  @override
  int get hashCode => segment.hashCode;

  @override
  String toString() => label;
}
