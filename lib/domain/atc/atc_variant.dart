/// Which ring counts as a hit on a numbered wedge (1-20) in Around the Clock.
///
/// The two bull stops are unaffected by any of these - each is already a
/// single physical ring, so there is nothing for a variant to restrict. See
/// [AtcStop.clears].
enum AtcVariant {
  /// Inner single, outer single, double, or triple all count.
  anyPart,

  /// Double or triple only. A single does not advance the target.
  masters,

  /// Double only.
  doublesOnly,
}
