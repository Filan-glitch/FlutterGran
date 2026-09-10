/// How many points the inner bull (the bullseye) is worth in Bulling.
///
/// The outer bull is always worth 1 point regardless of this — only the
/// bullseye's value is a per-leg choice.
enum BullseyeValue {
  /// The bullseye is worth 2 points.
  two,

  /// The bullseye is worth 3 points.
  three;

  /// Points a hit on the bullseye is worth under this value.
  int get points => switch (this) {
    BullseyeValue.two => 2,
    BullseyeValue.three => 3,
  };
}
