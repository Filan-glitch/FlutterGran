import 'x01_rules.dart';

/// The rules a leg is played under.
///
/// The variables are the starting score, who is playing, the in-rule and
/// out-rule (each independently single/straight, double, or master - see
/// [X01InRule]/[X01OutRule]), and which seat throws first.
class GameConfig {
  GameConfig({
    required this.startScore,
    required this.playerIds,
    this.inRule = X01InRule.straight,
    this.outRule = X01OutRule.double,
    this.startingSeat = 0,
  }) : assert(startScore > 1, 'start score must be above 1'),
       assert(
         playerIds.isNotEmpty && playerIds.length <= maxPlayers,
         'a leg needs 1 to $maxPlayers players',
       ),
       assert(
         playerIds.toSet().length == playerIds.length,
         'the same player cannot occupy two seats',
       ),
       assert(
         startingSeat >= 0 && startingSeat < playerIds.length,
         'the starting seat must be one of the seats',
       );

  /// Start values offered in the UI. The engine accepts any value above 1.
  static const List<int> offeredStartScores = [301, 501, 701];

  static const int maxPlayers = 4;

  /// Points each player starts on.
  final int startScore;

  /// Seats in throwing order. Order is fixed for the whole leg.
  final List<int> playerIds;

  /// What it takes to open the leg. Straight-in needs nothing.
  final X01InRule inRule;

  /// What it takes to finish the leg.
  final X01OutRule outRule;

  /// Seat that throws the first dart of the leg.
  ///
  /// Throwing first is a real advantage, so across a match this rotates rather
  /// than staying with whoever was seated first. Defaults to the first seat,
  /// which is every leg played outside a match.
  final int startingSeat;
}
