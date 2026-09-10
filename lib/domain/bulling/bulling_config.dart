import '../x01/game_config.dart';
import 'bulling_variant.dart';

/// The rules a Bulling leg is played under.
///
/// No `startingSeat`, unlike [GameConfig]: a leg always opens on the first
/// seat, since v1 has no match wrapping to rotate the lead across.
class BullingConfig {
  BullingConfig({
    required this.playerIds,
    required this.bullseyeValue,
    required this.target,
  }) : assert(
         playerIds.isNotEmpty && playerIds.length <= GameConfig.maxPlayers,
         'a leg needs 1 to ${GameConfig.maxPlayers} players',
       ),
       assert(
         playerIds.toSet().length == playerIds.length,
         'the same player cannot occupy two seats',
       ),
       assert(target > 0, 'target must be above 0');

  /// Target values offered in the UI. The engine accepts any value above 0.
  static const List<int> offeredTargets = [21, 31, 41];

  /// Seats in throwing order. Fixed for the whole leg.
  final List<int> playerIds;

  final BullseyeValue bullseyeValue;

  /// Points needed to win. A leg ends the instant a player reaches or
  /// passes this, mid-turn — darts thrown after that in the same turn do
  /// not count.
  final int target;
}
