/// The rules a leg is played under.
///
/// The MVP fixes straight-in and single-leg play, so the only variables are the
/// starting score, who is playing, and whether a double is required to finish.
class GameConfig {
  GameConfig({
    required this.startScore,
    required this.playerIds,
    this.doubleOut = true,
  }) : assert(startScore > 1, 'start score must be above 1'),
       assert(
         playerIds.isNotEmpty && playerIds.length <= maxPlayers,
         'a leg needs 1 to $maxPlayers players',
       ),
       assert(
         playerIds.toSet().length == playerIds.length,
         'the same player cannot occupy two seats',
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
}
