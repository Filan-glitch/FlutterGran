/// [SelectGameModeScreen], the tiles a player picks the next game from, drawn
/// from [gameModeRegistry].
///
/// {@category App}
library;

import 'package:flutter/material.dart';

import '../../domain/game_mode.dart';
import '../l10n_extensions.dart';
import '../rules_topic.dart';
import '../theme.dart';
import '../widgets/mode_glyph.dart';
import 'atc_setup_screen.dart';
import 'bulling_setup_screen.dart';
import 'higher_lower_setup_screen.dart';
import 'x01_setup_screen.dart';

/// Which setup screen a mode's tile opens. Presentation-layer routing - the
/// domain registry says nothing about screens.
Widget _setupScreenFor(GameMode mode) => switch (mode) {
  GameMode.x01 => const X01SetupScreen(),
  GameMode.aroundTheClock => const AtcSetupScreen(),
  GameMode.bulling => const BullingSetupScreen(),
  GameMode.higherLower => const HigherLowerSetupScreen(),
};

/// Lets a player choose which game to set up next.
///
/// One tile per [gameModeRegistry] entry, plus a trailing tile that says
/// more modes are coming without naming one.
///
/// [modes] defaults to the registry; tests pass it to inject a disabled
/// entry, which the real registry does not have.
class SelectGameModeScreen extends StatelessWidget {
  const SelectGameModeScreen({super.key, this.modes = gameModeRegistry});

  final List<GameModeDescriptor> modes;

  @override
  Widget build(BuildContext context) {
    // Columns follow the device ([isHeroSize], [wideLayout]), not the
    // container: `CenteredContent` caps the width, but a tablet or desktop
    // window still gets more columns.
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
/// Stateful only for the press-down scale, the same feedback the keypad's
/// keys give before the ripple lands.
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
        // Null, not a no-op, so `InkWell` renders an unavailable mode inert.
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
          // Dimmed beyond the disabled colours, with "COMING SOON" below.
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

/// The trailing "more modes coming" tile: a [_ModeTile]'s chrome with only
/// the topic-less [ModeGlyph] and a label inside.
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
