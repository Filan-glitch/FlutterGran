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
    this.legsFinished = 0,
    this.scoringPoints = 0,
    this.scoringDarts = 0,
    this.scoringTrebles = 0,
    this.scoringVisitBands = const [0, 0, 0, 0, 0, 0, 0, 0],
    this.scoringVisitSquares = 0,
    this.checkoutVisitsByRule = const {},
    this.tonPlusCheckouts = 0,
    this.dartsToWinByStart = const {},
    this.legsFinishedByStart = const {},
    this.legsOnThrow = 0,
    this.legsWonOnThrow = 0,
    this.legsAgainstThrow = 0,
    this.legsWonAgainstThrow = 0,
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

  /// Legs entered, finished or not - an abandoned leg still had darts
  /// thrown in it, so it still counts towards the averages.
  final int legsPlayed;

  final int legsWon;

  /// Legs that reached a winner. The denominator for [winRate]: a leg left
  /// unfinished was neither won nor lost.
  final int legsFinished;

  /// Matches entered, whether or not they are decided yet.
  ///
  /// Separate from [legsPlayed]: a best of five is one match and up to five
  /// legs.
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
  /// finished the leg, per out-rule - "on a finish" means something different
  /// under each one.
  final Map<X01OutRule, ({int dartsAtFinish, int finishesHit})> checkoutsByRule;

  /// Highest score ever checked out from.
  final int? bestCheckout;

  /// Fewest darts taken to win a leg.
  final int? fewestDartsToWin;

  final int firstNinePoints;
  final int firstNineDarts;

  /// Points and darts from scoring visits: turns that started too high to
  /// finish in one visit under the leg's out-rule (above 170 under double
  /// out). With no checkout darts mixed in, this is pure scoring power - the
  /// figure behind the PDC's "scoring average".
  final int scoringPoints;

  final int scoringDarts;

  /// Trebles of any number hit during scoring visits.
  final int scoringTrebles;

  /// Scoring visits, counted into the bands of [visitScoreBands].
  final List<int> scoringVisitBands;

  /// Sum of the squared score of every scoring visit, for [visitScoreStdDev].
  final int scoringVisitSquares;

  /// Visits that started on a score finishable in three darts, and of those
  /// the ones that finished the leg, per out-rule. The per-visit counterpart
  /// of [checkoutsByRule], and the stronger predictor of winning of the two.
  final Map<X01OutRule, ({int visits, int won})> checkoutVisitsByRule;

  /// Legs won with a checkout of 100 or more.
  final int tonPlusCheckouts;

  /// Darts this player threw in each leg they won, keyed by the leg's start
  /// score - darts per leg mean nothing across start scores.
  final Map<int, List<int>> dartsToWinByStart;

  /// Finished legs per start score, the denominator for [fastLegRate].
  final Map<int, int> legsFinishedByStart;

  /// Finished legs of two or more players where this player threw first, and
  /// where they did not. Solo legs count as neither.
  final int legsOnThrow;

  final int legsWonOnThrow;
  final int legsAgainstThrow;
  final int legsWonAgainstThrow;

  /// Lower bounds of the visit-score bands, the last one being 180 alone.
  static const List<int> visitScoreBands = [0, 20, 40, 60, 80, 100, 140, 180];

  /// Index into [visitScoreBands] for a visit of [score].
  static int bandFor(int score) {
    for (var i = visitScoreBands.length - 1; i > 0; i--) {
      if (score >= visitScoreBands[i]) return i;
    }
    return 0;
  }

  /// Scoring visits counted, the sum of [scoringVisitBands].
  int get scoringVisits => scoringVisitBands.fold(0, (a, b) => a + b);

  /// Three-dart average over scoring visits only. See [scoringPoints].
  double? get scoringAverage =>
      scoringDarts == 0 ? null : scoringPoints / scoringDarts * dartsPerTurn;

  /// Share of scoring-visit darts that landed in a treble, 0 to 1.
  double? get trebleRate =>
      scoringDarts == 0 ? null : scoringTrebles / scoringDarts;

  /// Standard deviation of scoring-visit scores: how consistent the scoring
  /// is, separate from how high it is. Null below two visits.
  double? get visitScoreStdDev {
    final n = scoringVisits;
    if (n < 2) return null;
    final mean = scoringPoints / n;
    final variance = (scoringVisitSquares - n * mean * mean) / (n - 1);
    return variance <= 0 ? 0 : math.sqrt(variance);
  }

  /// Share of visits at a finish under [rule] that won the leg, 0 to 1.
  double? checkoutVisitRateFor(X01OutRule rule) {
    final entry = checkoutVisitsByRule[rule];
    if (entry == null || entry.visits == 0) return null;
    return entry.won / entry.visits;
  }

  /// Darts at a finish across every out-rule, and finishes hit.
  ({int dartsAtFinish, int finishesHit}) get checkoutTotals => (
    dartsAtFinish: checkoutsByRule.values.fold(
      0,
      (sum, e) => sum + e.dartsAtFinish,
    ),
    finishesHit: checkoutsByRule.values.fold(
      0,
      (sum, e) => sum + e.finishesHit,
    ),
  );

  /// Checkout rate across every out-rule, for a headline figure.
  double? get checkoutRate {
    final totals = checkoutTotals;
    return totals.dartsAtFinish == 0
        ? null
        : totals.finishesHit / totals.dartsAtFinish;
  }

  /// The start score with the most finished legs, or null before any.
  int? get mainStartScore {
    int? best;
    for (final entry in legsFinishedByStart.entries) {
      if (best == null || entry.value > legsFinishedByStart[best]!) {
        best = entry.key;
      }
    }
    return best;
  }

  /// Darts a leg from [start] takes at a hundred average: 15 for 501, 9 for
  /// 301, 21 for 701. A leg won inside it is a "fast leg".
  static int fastLegDarts(int start) => (start * dartsPerTurn / 100).round();

  /// Legs from [start] won within [fastLegDarts].
  int fastLegs(int start) => (dartsToWinByStart[start] ?? const [])
      .where((darts) => darts <= fastLegDarts(start))
      .length;

  /// Share of finished legs from [start] won within [fastLegDarts], 0 to 1.
  /// Legs won in 15 darts or fewer predicts a 501 match better than the
  /// average does.
  double? fastLegRate(int start) {
    final finished = legsFinishedByStart[start] ?? 0;
    return finished == 0 ? null : fastLegs(start) / finished;
  }

  /// Mean darts per leg won from [start].
  double? averageDartsPerLegWon(int start) {
    final darts = dartsToWinByStart[start];
    if (darts == null || darts.isEmpty) return null;
    return darts.fold(0, (a, b) => a + b) / darts.length;
  }

  double? get winRateOnThrow =>
      legsOnThrow == 0 ? null : legsWonOnThrow / legsOnThrow;

  double? get winRateAgainstThrow =>
      legsAgainstThrow == 0 ? null : legsWonAgainstThrow / legsAgainstThrow;

  /// [count] per leg played, for comparing 180s across records of different
  /// sizes.
  double? perLeg(int count) => legsPlayed == 0 ? null : count / legsPlayed;

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

  /// Share of finished legs won, 0 to 1. Legs, not matches - see
  /// [matchWinRate].
  double? get winRate => legsFinished == 0 ? null : legsWon / legsFinished;

  double? get matchWinRate =>
      matchesPlayed == 0 ? null : matchesWon / matchesPlayed;
}
