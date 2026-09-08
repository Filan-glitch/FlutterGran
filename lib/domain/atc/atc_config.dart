import '../x01/game_config.dart';
import 'atc_variant.dart';

/// The rules an Around the Clock leg is played under.
///
/// No `startingSeat`, unlike [GameConfig]: a leg always opens on the first
/// seat, since v1 has no match wrapping to rotate the lead across.
class AtcConfig {
  AtcConfig({required this.playerIds, required this.variant})
    : assert(
        playerIds.isNotEmpty && playerIds.length <= GameConfig.maxPlayers,
        'a leg needs 1 to ${GameConfig.maxPlayers} players',
      ),
      assert(
        playerIds.toSet().length == playerIds.length,
        'the same player cannot occupy two seats',
      );

  /// Seats in throwing order. Fixed for the whole leg.
  final List<int> playerIds;

  final AtcVariant variant;
}
