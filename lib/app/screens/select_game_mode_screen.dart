import 'package:flutter/material.dart';

import '../../domain/game_mode.dart';
import '../l10n_extensions.dart';
import '../theme.dart';
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
    // gets more columns even though `CenteredContent` below caps the actual
    // rendering width on the very widest screens.
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final columns = shortestSide >= heroLayout
        ? 3
        : shortestSide >= wideLayout
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
      appBar: AppBar(
        title: Text(context.l10n.selectGameModeTitle),
      ),
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

/// Small painted rings standing in for a dartboard, one per [GameMode] -
/// concentric bands like the board itself, with a highlight that encodes the
/// mode's own rule rather than an arbitrary per-mode colour. The app's own
/// rule is that green is told apart by lightness, not hue (see `Palette`), so
/// every mode shares the same ring/[Palette.trebleBed] base; only the
/// highlight below changes:
///
///  - X01 strokes the outer ring in [Palette.doubleBed] - a leg ends on a
///    double.
///  - Around the Clock adds a bright dot riding the rim - the numbers are
///    played in order, all the way around.
///  - Bulling fills the centre solid - the whole game is aiming for the bull.
///
/// Plain widgets (stacked circles, one dot placed with [Align]), not a
/// `CustomPainter` - the app draws nothing on a canvas anywhere else, and
/// three circles don't need one.
class _ModeGlyph extends StatelessWidget {
  const _ModeGlyph({required this.mode});

  final GameMode mode;

  static const double _size = 52;

  @override
  Widget build(BuildContext context) {
    final outerColor = mode == GameMode.x01
        ? Palette.doubleBed
        : Palette.chalkDim;

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _ring(diameter: _size, color: outerColor),
          _ring(diameter: _size * 0.62, color: Palette.trebleBed),
          _ring(
            diameter: _size * 0.28,
            color: Palette.trebleBed,
            filled: mode == GameMode.bulling,
          ),
          if (mode == GameMode.aroundTheClock)
            const Align(
              alignment: Alignment(0.8, -0.8),
              child: _Dot(color: Palette.trebleBed),
            ),
        ],
      ),
    );
  }

  static Widget _ring({
    required double diameter,
    required Color color,
    bool filled = false,
  }) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : null,
        border: filled ? null : Border.all(color: color, width: 2),
      ),
    );
  }
}

/// The dim, un-highlighted ring family used for [_ComingSoonTile] - the same
/// shape language as [_ModeGlyph] with nothing lit up, since it names no mode.
class _ComingSoonGlyph extends StatelessWidget {
  const _ComingSoonGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _ModeGlyph._size,
      height: _ModeGlyph._size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _ModeGlyph._ring(diameter: _ModeGlyph._size, color: Palette.edge),
          _ModeGlyph._ring(
            diameter: _ModeGlyph._size * 0.62,
            color: Palette.edge,
          ),
          const Icon(Icons.add, color: Palette.chalkDim, size: 18),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// One game mode, tappable only if [GameModeDescriptor.isAvailable].
///
/// Same tile chrome as `_ScoreChoice`/`_tile` in `x01_setup_screen.dart`:
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
                _ModeGlyph(mode: mode.id),
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
/// inside: no name, just the dim ring family and the label.
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
              const _ComingSoonGlyph(),
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
