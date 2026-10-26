import '../x01/game_config.dart';

/// The rules a Higher/Lower leg is played under.
///
/// Only the roster: every leg opens on the same two values, so there is
/// nothing else to choose. Like Bulling, a leg always opens on the first
/// seat, since there is no match wrapping to rotate the lead across.
class HigherLowerConfig {
  HigherLowerConfig({required this.playerIds})
    : assert(
        playerIds.length >= minPlayers &&
            playerIds.length <= GameConfig.maxPlayers,
        'a leg needs $minPlayers to ${GameConfig.maxPlayers} players',
      ),
      assert(
        playerIds.toSet().length == playerIds.length,
        'the same player cannot occupy two seats',
      );

  /// Last one standing needs somebody to outlast.
  static const int minPlayers = 2;

  /// The value a turn has to beat by going over, when a leg opens.
  static const int startHigher = 45;

  /// The value a turn has to beat by going under, when a leg opens.
  static const int startLower = 26;

  /// Seats in throwing order. Fixed for the whole leg.
  final List<int> playerIds;
}
