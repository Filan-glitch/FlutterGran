part of 'mode_stats.dart';

/// Everything the stats screens show for one player's Higher/Lower record.
class HigherLowerStats extends ModeStats {
  const HigherLowerStats({
    required this.legsPlayed,
    required this.legsWon,
    required this.turnsPlayed,
    required this.turnsSurvived,
    required this.higherCalls,
    required this.lowerCalls,
    required this.dartsThrown,
    required this.longestRun,
  });

  static const HigherLowerStats empty = HigherLowerStats(
    legsPlayed: 0,
    legsWon: 0,
    turnsPlayed: 0,
    turnsSurvived: 0,
    higherCalls: 0,
    lowerCalls: 0,
    dartsThrown: 0,
    longestRun: 0,
  );

  final int legsPlayed;

  /// Legs this player was the last one standing in.
  final int legsWon;

  final int turnsPlayed;

  /// Turns that went over the higher value or under the lower one.
  final int turnsSurvived;

  /// Survived turns that went over the higher value.
  final int higherCalls;

  /// Survived turns that went under the lower value.
  final int lowerCalls;

  final int dartsThrown;

  /// Most turns survived in any one leg.
  final int longestRun;

  /// Share of turns survived, 0 to 1.
  double? get survivalRate =>
      turnsPlayed == 0 ? null : turnsSurvived / turnsPlayed;

  /// Share of legs won, 0 to 1.
  double? get winRate => legsPlayed == 0 ? null : legsWon / legsPlayed;
}
