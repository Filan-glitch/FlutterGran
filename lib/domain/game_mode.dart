/// Which game a leg is played under.
///
/// The only member today is [x01] - nothing else has an engine yet. Adding a
/// second mode means adding a value here, a matching entry in
/// [gameModeRegistry], and its own stats calculator; nothing about picking a
/// mode or reading its record should need to change shape again.
enum GameMode { x01 }

/// What the mode-select screen needs to render a tile, without pulling in
/// anything Flutter.
class GameModeDescriptor {
  const GameModeDescriptor({
    required this.id,
    required this.displayName,
    required this.tagline,
    required this.isAvailable,
  });

  final GameMode id;
  final String displayName;
  final String tagline;

  /// Whether this mode has an engine and a setup screen behind it yet.
  final bool isAvailable;
}

/// Every mode the select-screen can show a tile for, in display order.
///
/// x01 is the only one with a real engine behind it. A future mode is added
/// here with `isAvailable: false` until it has one.
const List<GameModeDescriptor> gameModeRegistry = [
  GameModeDescriptor(
    id: GameMode.x01,
    displayName: 'X01',
    tagline: '301 · 501 · 701',
    isAvailable: true,
  ),
];
