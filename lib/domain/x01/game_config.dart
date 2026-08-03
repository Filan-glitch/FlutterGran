/// The rules a leg is played under.
///
/// Straight-in is fixed, so the variables are the starting score, who is
/// playing, whether a double is required to finish, and which seat throws
/// first.
class GameConfig {
  GameConfig({
    required this.startScore,
    required this.playerIds,
    this.doubleOut = true,
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

  /// Whether the leg must be finished on a double.
  final bool doubleOut;

  /// Seat that throws the first dart of the leg.
  ///
  /// Throwing first is a real advantage, so across a match this rotates rather
  /// than staying with whoever was seated first. Defaults to the first seat,
  /// which is every leg played outside a match.
  final int startingSeat;
}
