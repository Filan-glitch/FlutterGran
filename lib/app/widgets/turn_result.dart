import 'package:flutter/material.dart';

import '../../domain/x01/thrown_dart.dart';
import '../l10n_extensions.dart';
import '../theme.dart';

/// Lays its child out at the height it is given, and scrolls it when that is
/// not enough.
///
/// The panels that end a turn or a leg are built around [Spacer]s, which need a
/// bounded height, and are also the first thing to overflow on a phone lying on
/// its side. This gives them the height when there is height, and a scroll when
/// there is not, rather than making them choose one for both cases.
class FitOrScroll extends StatelessWidget {
  const FitOrScroll({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(child: child),
        ),
      ),
    );
  }
}

/// Held after every turn, in place of the keypad rather than over it.
///
/// Taking the keys away is the point: it makes a stray tap impossible while
/// darts are being pulled out of the board, which is when they happen.
///
/// Every game shows a turn the same way: who threw, one short figure for what
/// the turn was worth, and where it left them. [figure] is always that short
/// figure - a score, `+2` - never a sentence, because it is set at the size
/// of the scoreboard itself.
class TurnResultPanel extends StatelessWidget {
  const TurnResultPanel({
    super.key,
    required this.name,
    required this.darts,
    required this.figure,
    required this.caption,
    required this.finishing,
    required this.onConfirm,
    required this.onUndo,
    this.busted = false,
    this.celebrate = false,
  });

  final String name;
  final List<ThrownDart> darts;

  /// What the turn was worth, as the game counts it.
  final String figure;

  /// Where the turn left the thrower, e.g. `321 → 141`.
  final String caption;

  /// Whether confirming this turn ends the leg.
  final bool finishing;

  final VoidCallback onConfirm;
  final VoidCallback onUndo;

  /// Drawn in the double bed's red, with a beat of emphasis.
  final bool busted;

  /// The turn that earns a fanfare - a 180.
  final bool celebrate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // This is always either the phone's inline panel or the tablet's
    // full-screen takeover, never both from the same call site - the two
    // never overlap, so the device is enough to tell which one this is.
    final hero = MediaQuery.sizeOf(context).shortestSide >= heroLayout;
    final dartsThrown = darts.map((dart) => dart.label).join('  ·  ');

    Widget score = Text(
      figure,
      style: (hero ? Type.scoreHero : Type.score).copyWith(
        color: busted ? Palette.doubleBed : Palette.chalk,
      ),
    );
    // A pop rather than a shake for a bust: the number that is wrong gets a
    // beat of emphasis before it settles into red, same idea as the
    // celebration below, opposite reason.
    if (busted) score = EntrancePop(minScale: 1.12, child: score);
    if (celebrate) {
      score = Pulse(
        min: 0.85,
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Palette.live.withValues(alpha: 0.55),
                blurRadius: 48,
                spreadRadius: 8,
              ),
            ],
          ),
          child: score,
        ),
      );
    }

    return FitOrScroll(
      child: Padding(
        padding: const EdgeInsets.all(Gap.xl),
        child: EntrancePop(
          child: Column(
            children: [
              const Spacer(),
              Text(
                name.toUpperCase(),
                style: hero
                    ? Type.title.copyWith(
                        color: Palette.chalkDim,
                        letterSpacing: 2,
                      )
                    : Type.eyebrow.copyWith(color: Palette.chalkDim),
              ),
              if (hero && dartsThrown.isNotEmpty) ...[
                const SizedBox(height: Gap.sm),
                Text(
                  dartsThrown,
                  style: Type.title.copyWith(color: Palette.chalkDim),
                ),
              ],
              const SizedBox(height: Gap.md),
              score,
              const SizedBox(height: Gap.sm),
              Text(
                caption,
                style: (hero ? Type.scoreSmall : Type.label).copyWith(
                  color: Palette.chalkDim,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onUndo,
                      child: Text(l10n.wrongButton),
                    ),
                  ),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: onConfirm,
                      child: Text(
                        finishing ? l10n.finishButton : l10n.nextPlayerButton,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.md),
              Text(
                l10n.orPressBoardButton,
                style: Type.label.copyWith(color: Palette.chalkDim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
