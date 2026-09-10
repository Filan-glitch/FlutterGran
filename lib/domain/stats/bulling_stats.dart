part of 'mode_stats.dart';

/// Everything the stats screens show for one player's Bulling record.
class BullingStats extends ModeStats {
  const BullingStats({
    required this.legsPlayed,
    required this.legsWon,
    required this.dartsThrown,
    required this.scoringDarts,
    required this.pointsScored,
    required this.outerBullHits,
    required this.innerBullHits,
    required this.fewestDartsToWin,
  });

  static const BullingStats empty = BullingStats(
    legsPlayed: 0,
    legsWon: 0,
    dartsThrown: 0,
    scoringDarts: 0,
    pointsScored: 0,
    outerBullHits: 0,
    innerBullHits: 0,
    fewestDartsToWin: null,
  );

  final int legsPlayed;
  final int legsWon;

  final int dartsThrown;

  /// Darts that landed on either bull ring — the only ones worth anything.
  final int scoringDarts;

  final int pointsScored;
  final int outerBullHits;
  final int innerBullHits;

  /// Fewest darts taken to reach the target and win a leg.
  final int? fewestDartsToWin;

  /// Share of darts that scored, 0 to 1.
  double? get hitRate => dartsThrown == 0 ? null : scoringDarts / dartsThrown;

  /// Share of legs won, 0 to 1.
  double? get winRate => legsPlayed == 0 ? null : legsWon / legsPlayed;
}
