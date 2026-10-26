import 'package:flutter/material.dart';

import '../../domain/game_mode.dart';
import '../l10n_extensions.dart';
import '../rules_topic.dart';
import '../theme.dart';
import '../widgets/mode_glyph.dart';
import 'atc_setup_screen.dart';
import 'bulling_setup_screen.dart';
import 'x01_setup_screen.dart';

/// Which setup screen a mode's tile opens. Presentation-layer routing - the
/// domain registry says nothing about screens.
Widget _setupScreenFor(GameMode mode) => switch (mode) {
  GameMode.x01 => const X01SetupScreen(),
  GameMode.aroundTheClock => const AtcSetupScreen(),
  GameMode.bulling => const BullingSetupScreen(),
};

/// Lets a player choose which game to set up next.
///
/// Renders one tile per [gameModeRegistry] entry - X01, Around the Clock and
/// Bulling today - plus a trailing tile that just signals more modes are
/// coming, without naming one: whatever comes next isn't built yet, so naming
/// a specific mode here would be a promise this pass has no business making.
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
    // or a desktop window gets more columns even though `CenteredContent`
    // below caps the actual rendering width on the very widest screens.
    final size = MediaQuery.sizeOf(context);
    final columns = isHeroSize(size)
        ? 3
        : size.shortestSide >= wideLayout
        ? 2
        : 1;

    // A single phone column reads better as a wide bar than a tall square -
    // a square that wide would waste height forcing a scroll for what should
    // be a one-glance grid. Multi-column layouts get close to square, which
    // is what makes them read as a grid of game cards rather than a table.
    final aspectRatio = switch (columns) {
      1 => 1.9,
      2 => 1.05,
      _ => 0.95,
    };

    final tiles = [
      for (final mode in modes) _ModeTile(mode: mode),
      const _ComingSoonTile(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.selectGameModeTitle)),
      body: SafeArea(
        child: CenteredContent(
          child: GridView.builder(
            padding: const EdgeInsets.all(Gap.lg),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: Gap.md,
              crossAxisSpacing: Gap.md,
              childAspectRatio: aspectRatio,
            ),
            itemCount: tiles.length,
            itemBuilder: (context, index) =>
                StaggeredEntry(index: index, child: tiles[index]),
          ),
        ),
      ),
    );
  }
}

/// One game mode, tappable only if [GameModeDescriptor.isAvailable].
///
/// Same tile chrome as the setup screens' choices (`setup_controls.dart`):
/// `Material` + a 4px rounded border + `InkWell`, coloured and bordered by
/// state rather than by a bespoke widget per screen. Stateful only to track
/// the press-down scale below - the same short, sharper feedback
/// `dart_keypad.dart`'s `_Key` gives before `InkWell`'s own ripple lands.
class _ModeTile extends StatefulWidget {
  const _ModeTile({required this.mode});

  final GameModeDescriptor mode;

  @override
  State<_ModeTile> createState() => _ModeTileState();
}

class _ModeTileState extends State<_ModeTile> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    final enabled = mode.isAvailable;

    final tile = Material(
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
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        child: Opacity(
          // The visual cue that a mode is not playable yet: dimmed further
          // than the disabled colours alone, plus the "COMING SOON" label
          // below.
          opacity: enabled ? 1 : 0.4,
          child: Padding(
            padding: const EdgeInsets.all(Gap.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ModeGlyph(topic: RulesTopic.of(mode.id)),
                const SizedBox(height: Gap.sm),
                Text(
                  mode.displayName,
                  textAlign: TextAlign.center,
                  style: Type.title.copyWith(
                    color: enabled ? Palette.chalk : Palette.chalkDim,
                  ),
                ),
                if (mode.tagline case final tagline?) ...[
                  const SizedBox(height: Gap.xs),
                  Text(
                    tagline,
                    textAlign: TextAlign.center,
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

    // Transform only - the tile's laid-out bounds never move, so pressing one
    // tile never nudges the grid around it.
    return AnimatedScale(
      scale: _pressed ? 0.96 : 1,
      duration: Motion.scale(Motion.fast),
      curve: Motion.enter,
      child: tile,
    );
  }
}

/// A hard-coded, generic trailing tile - not driven by [gameModeRegistry] -
/// that signals the grid will grow without naming any specific mode that
/// isn't built yet. Same chrome and grid cell as a real [_ModeTile], quieter
/// inside: no name, just the dim ring family ([ModeGlyph] with no topic) and
/// the label.
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
          padding: const EdgeInsets.all(Gap.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const ModeGlyph(topic: null),
              const SizedBox(height: Gap.sm),
              Text(
                context.l10n.moreModesComingLabel,
                textAlign: TextAlign.center,
                style: Type.eyebrow.copyWith(color: Palette.chalkDim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
