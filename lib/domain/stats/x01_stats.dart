part of 'mode_stats.dart';

/// Everything the stats screens show for one player's x01 record.
class X01Stats extends ModeStats {
  const X01Stats({
    required this.legsPlayed,
    required this.legsWon,
    required this.matchesPlayed,
    required this.matchesWon,
    required this.dartsThrown,
    required this.pointsScored,
    required this.bestTurn,
    required this.turnsOf180,
    required this.turnsOf140Plus,
    required this.turnsOf100Plus,
    required this.turnsOf60Plus,
    required this.checkoutsByRule,
    required this.bestCheckout,
    required this.fewestDartsToWin,
    required this.firstNinePoints,
    required this.firstNineDarts,
  });

  static const X01Stats empty = X01Stats(
    legsPlayed: 0,
    legsWon: 0,
    matchesPlayed: 0,
    matchesWon: 0,
    dartsThrown: 0,
    pointsScored: 0,
    bestTurn: 0,
    turnsOf180: 0,
    turnsOf140Plus: 0,
    turnsOf100Plus: 0,
    turnsOf60Plus: 0,
    checkoutsByRule: {},
    bestCheckout: null,
    fewestDartsToWin: null,
    firstNinePoints: 0,
    firstNineDarts: 0,
  );

  final int legsPlayed;
  final int legsWon;

  /// Matches entered, whether or not they are decided yet.
  ///
  /// Deliberately a separate count from [legsPlayed] rather than a
  /// reinterpretation of it: a best of five is one match and up to five legs,
  /// and both numbers are worth knowing.
  final int matchesPlayed;

  final int matchesWon;

  final int dartsThrown;

  /// Points that survived - a busted turn contributes nothing.
  final int pointsScored;

  final int bestTurn;
  final int turnsOf180;
  final int turnsOf140Plus;
  final int turnsOf100Plus;
  final int turnsOf60Plus;

  /// Darts thrown while on a finish, and of those the ones that actually
  /// finished the leg - kept separate per out-rule, rather than one figure
  /// mixing legs played under different rules together, since "on a finish"
  /// means something different under each one.
  final Map<X01OutRule, ({int dartsAtFinish, int finishesHit})> checkoutsByRule;

  /// Highest score ever checked out from.
  final int? bestCheckout;

  /// Fewest darts taken to win a leg.
  final int? fewestDartsToWin;

  final int firstNinePoints;
  final int firstNineDarts;

  /// Three-dart average, or null before anything has been thrown.
  double? get average =>
      dartsThrown == 0 ? null : pointsScored / dartsThrown * dartsPerTurn;

  /// Average over the opening three turns of each leg, which separates scoring
  /// power from finishing ability.
  double? get firstNineAverage => firstNineDarts == 0
      ? null
      : firstNinePoints / firstNineDarts * dartsPerTurn;

  /// Share of darts at a finish under [rule] that actually won the leg,
  /// 0 to 1, or null when nothing has been thrown at a finish under it.
  double? checkoutRateFor(X01OutRule rule) {
    final entry = checkoutsByRule[rule];
    if (entry == null || entry.dartsAtFinish == 0) return null;
    return entry.finishesHit / entry.dartsAtFinish;
  }

  /// Share of legs won, 0 to 1. Legs, not matches - this is what it has always
  /// meant and what the rest of the app reads it as.
  double? get winRate => legsPlayed == 0 ? null : legsWon / legsPlayed;

  double? get matchWinRate =>
      matchesPlayed == 0 ? null : matchesWon / matchesPlayed;
}
