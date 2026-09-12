/// Which game a leg is played under.
///
/// Adding a mode means adding a value here, a matching entry in
/// [gameModeRegistry], and its own stats calculator; nothing about picking a
/// mode or reading its record should need to change shape again.
enum GameMode { x01, aroundTheClock, bulling }

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

  /// Null when there is no short, honest way to sum the mode up in a line -
  /// the select-screen tile then shows no tagline at all rather than an
  /// empty one.
  final String? tagline;

  /// Whether this mode has an engine and a setup screen behind it yet.
  final bool isAvailable;
}

/// Every mode the select-screen can show a tile for, in display order.
///
/// A future mode is added here with `isAvailable: false` until it has an
/// engine and a setup screen behind it.
const List<GameModeDescriptor> gameModeRegistry = [
  GameModeDescriptor(
    id: GameMode.x01,
    displayName: 'X01',
    tagline: '301 · 501 · 701',
    isAvailable: true,
  ),
  GameModeDescriptor(
    id: GameMode.aroundTheClock,
    displayName: 'AROUND THE CLOCK',
    tagline: null,
    isAvailable: true,
  ),
  GameModeDescriptor(
    id: GameMode.bulling,
    displayName: 'BULLING',
    tagline: '21 · 31 · 41',
    isAvailable: true,
  ),
];
