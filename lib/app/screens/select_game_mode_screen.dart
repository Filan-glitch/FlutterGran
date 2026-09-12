import 'package:flutter/material.dart';

import '../../domain/game_mode.dart';
import '../l10n_extensions.dart';
import '../theme.dart';
import 'atc_setup_screen.dart';
import 'bulling_setup_screen.dart';
import 'x01_setup_screen.dart';

/// A tile's icon, keyed by mode. Presentation only - the domain registry in
/// `game_mode.dart` knows nothing about icons, the same way it knows nothing
/// else about Flutter.
const Map<GameMode, IconData> _icons = {
  GameMode.x01: Icons.adjust,
  GameMode.aroundTheClock: Icons.timelapse,
  GameMode.bulling: Icons.gps_fixed,
};

/// Which setup screen a mode's tile opens. Presentation-layer routing, the
/// same reason [_icons] lives here rather than on [GameModeDescriptor]:
/// the domain registry says nothing about screens.
Widget _setupScreenFor(GameMode mode) => switch (mode) {
  GameMode.x01 => const X01SetupScreen(),
  GameMode.aroundTheClock => const AtcSetupScreen(),
  GameMode.bulling => const BullingSetupScreen(),
};

/// Lets a player choose which game to set up next.
///
/// Renders one tile per [gameModeRegistry] entry - X01 and Around the Clock
/// today - plus a trailing tile that just signals more modes are coming,
/// without naming one: whatever comes next isn't built yet, so naming a
/// specific mode here would be a promise this pass has no business making.
///
/// [modes] defaults to the real registry and exists as a constructor
/// parameter only so a test can inject a disabled entry: production never
/// passes it, since the registry itself has nothing disabled to show yet.
class SelectGameModeScreen extends StatelessWidget {
  const SelectGameModeScreen({super.key, this.modes = gameModeRegistry});

  final List<GameModeDescriptor> modes;

  @override
  Widget build(BuildContext context) {
    // Device-based, not container-based: the same breakpoints
    // `game_screen.dart` uses for its own hero/wide thresholds, so a tablet
    // gets more columns even though `CenteredContent` below caps the actual
    // rendering width on the very widest screens.
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final columns = shortestSide >= heroLayout
        ? 3
        : shortestSide >= wideLayout
        ? 2
        : 1;

    final tiles = [
      for (final mode in modes) _ModeTile(mode: mode),
      const _ComingSoonTile(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.selectGameModeTitle),
      ),
      body: SafeArea(
        child: CenteredContent(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Gap.lg),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const spacing = Gap.md;
                final width =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final tile in tiles)
                      SizedBox(width: width, child: tile),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// One game mode, tappable only if [GameModeDescriptor.isAvailable].
///
/// Same tile idiom as `_ScoreChoice`/`_tile` in `x01_setup_screen.dart`:
/// `Material` + a 4px rounded border + `InkWell`, coloured and bordered by
/// state rather than by a bespoke widget per screen.
class _ModeTile extends StatelessWidget {
  const _ModeTile({required this.mode});

  final GameModeDescriptor mode;

  @override
  Widget build(BuildContext context) {
    final enabled = mode.isAvailable;

    return Material(
      color: Palette.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Palette.edge),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Null rather than a no-op: an unavailable mode has nowhere to go
        // yet, and `InkWell` already renders as inert (no ripple, no tap
        // feedback) when its handler is null.
        onTap: enabled
            ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => _setupScreenFor(mode.id),
                ),
              )
            : null,
        child: Opacity(
          // The visual cue that a mode is not playable yet: dimmed further
          // than the disabled colours alone, plus the "COMING SOON" label
          // below.
          opacity: enabled ? 1 : 0.4,
          child: Padding(
            padding: const EdgeInsets.all(Gap.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _icons[mode.id] ?? Icons.sports_esports,
                  color: enabled ? Palette.live : Palette.chalkDim,
                  size: 26,
                ),
                const SizedBox(height: Gap.md),
                Text(
                  mode.displayName,
                  style: Type.title.copyWith(
                    color: enabled ? Palette.chalk : Palette.chalkDim,
                  ),
                ),
                if (mode.tagline case final tagline?) ...[
                  const SizedBox(height: Gap.xs),
                  Text(
                    tagline,
                    style: Type.label.copyWith(color: Palette.chalkDim),
                  ),
                ],
                if (!enabled) ...[
                  const SizedBox(height: Gap.sm),
                  Text(
                    context.l10n.comingSoonLabel,
                    style: Type.eyebrow.copyWith(color: Palette.chalkDim),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A hard-coded, generic trailing tile - not driven by [gameModeRegistry] -
/// that signals the grid will grow without naming any specific mode that
/// isn't built yet.
class _ComingSoonTile extends StatelessWidget {
  const _ComingSoonTile();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Palette.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Palette.edge),
      ),
      clipBehavior: Clip.antiAlias,
      child: Opacity(
        opacity: 0.4,
        child: Padding(
          padding: const EdgeInsets.all(Gap.lg),
          child: Center(
            child: Text(
              context.l10n.moreModesComingLabel,
              textAlign: TextAlign.center,
              style: Type.eyebrow.copyWith(color: Palette.chalkDim),
            ),
          ),
        ),
      ),
    );
  }
}
