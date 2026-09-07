part of 'mode_stats.dart';

/// Everything the stats screens show for one player's Around the Clock
/// record.
class AtcStats extends ModeStats {
  const AtcStats({
    required this.legsPlayed,
    required this.legsWon,
    required this.dartsThrown,
    required this.qualifyingDarts,
    required this.fewestDartsToWin,
    required this.perStop,
  });

  static const AtcStats empty = AtcStats(
    legsPlayed: 0,
    legsWon: 0,
    dartsThrown: 0,
    qualifyingDarts: 0,
    fewestDartsToWin: null,
    perStop: {},
  );

  final int legsPlayed;
  final int legsWon;

  final int dartsThrown;

  /// Darts that cleared whatever stop was current when they were thrown.
  final int qualifyingDarts;

  /// Fewest darts taken to clear the bullseye and win a leg.
  final int? fewestDartsToWin;

  /// Attempts and hits against each stop, keyed by the stop that was current
  /// when the dart was thrown - not by what the dart happened to land on.
  final Map<AtcStop, ({int attempts, int hits})> perStop;

  /// Share of darts that cleared their stop, 0 to 1.
  double? get hitRate =>
      dartsThrown == 0 ? null : qualifyingDarts / dartsThrown;

  /// Share of legs won, 0 to 1.
  double? get winRate => legsPlayed == 0 ? null : legsWon / legsPlayed;
}
