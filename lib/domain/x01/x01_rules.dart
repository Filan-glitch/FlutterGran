import '../segment.dart';
import 'thrown_dart.dart';

/// The rule for a player's first scoring dart of a leg.
///
/// Straight-in needs nothing - every dart scores from the first one thrown.
/// Double-in and master-in require a qualifying dart before anything counts;
/// see [X01InRuleChecks.opens].
enum X01InRule { straight, double, master }

/// The rule for the dart that finishes a leg.
///
/// Mirrors [X01InRule]: the same three values, checked against the finishing
/// dart instead of the opening one. See [X01OutRuleChecks.checksOut].
enum X01OutRule { straight, double, master }

/// What it takes to open a leg under each [X01InRule].
extension X01InRuleChecks on X01InRule {
  /// Whether [segment] is a legal opening dart under this rule.
  bool opens(Segment segment) => switch (this) {
    X01InRule.straight => true,
    X01InRule.double => segment.isDouble,
    X01InRule.master => segment.isDouble || segment.ring == Ring.triple,
  };

  /// Short form for the setup screen and the in-game rule badge.
  String get abbreviation => switch (this) {
    X01InRule.straight => 'SI',
    X01InRule.double => 'DI',
    X01InRule.master => 'MI',
  };

  /// Long form for setup screen chips and stats labels.
  String get label => switch (this) {
    X01InRule.straight => 'Straight',
    X01InRule.double => 'Double',
    X01InRule.master => 'Master',
  };
}

/// What it takes to finish a leg under each [X01OutRule].
extension X01OutRuleChecks on X01OutRule {
  /// Whether [segment] may legally finish a leg under this rule.
  bool checksOut(Segment segment) => switch (this) {
    X01OutRule.straight => true,
    X01OutRule.double => segment.isDouble,
    X01OutRule.master => segment.isDouble || segment.ring == Ring.triple,
  };

  /// Short form for the setup screen and the in-game rule badge.
  String get abbreviation => switch (this) {
    X01OutRule.straight => 'SO',
    X01OutRule.double => 'DO',
    X01OutRule.master => 'MO',
  };

  /// Long form for setup screen chips and stats labels.
  String get label => switch (this) {
    X01OutRule.straight => 'Straight',
    X01OutRule.double => 'Double',
    X01OutRule.master => 'Master',
  };
}

/// Rule checks for a dart as actually thrown, including a miss.
extension X01RuleDartChecks on ThrownDart {
  /// Whether this dart legally opens a leg under [rule]. A miss never opens.
  bool opensUnder(X01InRule rule) {
    final thrown = segment;
    return thrown != null && rule.opens(thrown);
  }

  /// Whether this dart legally finishes a leg under [rule]. A miss never
  /// finishes.
  bool checksOutUnder(X01OutRule rule) {
    final thrown = segment;
    return thrown != null && rule.checksOut(thrown);
  }
}
