import 'package:flutter/material.dart';

import '../../domain/checkout/checkout_search.dart';
import '../../domain/segment.dart';
import '../l10n_extensions.dart';
import '../theme.dart';
import 'ring_colours.dart';

/// Key on the whole card, for tests.
const Key checkoutCardKey = Key('checkout-card');

/// Key on the chip for the dart to throw next.
const Key checkoutNextDartKey = Key('checkout-next-dart');

/// What to throw, when there is a finish on: the best route as one chip per
/// dart, big enough to read from the oche.
///
/// Each chip wears the colour of the bed it asks for, the same colour the
/// keypad key for that dart has, so "treble" and "double" read before the
/// number does. The next dart carries the pale [Palette.live] outline, which
/// is the app's one way of saying "aim here" - the keypad lights its keys the
/// same way. There are always three slots, whatever the route's length, so a
/// chip is the same size on every turn and the eye learns where to look.
///
/// Shared by the x01 game screen and checkout practice. [hero] is the tablet
/// scale: the same card with more room to say it in.
class CheckoutCard extends StatelessWidget {
  const CheckoutCard({
    super.key,
    required this.routes,
    required this.remaining,
    required this.dartsLeft,
    this.hero = false,
    this.padding,
  });

  /// Best first, as the checkout table ranks them.
  final List<CheckoutRoute> routes;

  final int remaining;
  final int dartsLeft;
  final bool hero;

  /// Around the card. Defaults to the game screen's inset from its edges;
  /// a caller already inside a padded list passes its own.
  final EdgeInsetsGeometry? padding;

  /// Alternates beyond the best route. Two is what fits on a line at the
  /// oche and is still worth reading.
  static const int _alternates = 2;

  @override
  Widget build(BuildContext context) {
    if (routes.isEmpty) {
      return SizedBox(height: hero ? Gap.md : Gap.sm);
    }

    final l10n = context.l10n;
    final best = routes.first;
    final alternates = routes.skip(1).take(_alternates);

    return Semantics(
      container: true,
      label: l10n.semanticCheckoutRoute(remaining, best.toString()),
      child: ExcludeSemantics(
        child: Padding(
          key: checkoutCardKey,
          padding:
              padding ??
              EdgeInsets.fromLTRB(Gap.md, hero ? Gap.lg : Gap.md, Gap.md, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    l10n.checkoutLabel,
                    style: Type.eyebrow.copyWith(color: Palette.live),
                  ),
                  const SizedBox(width: Gap.sm),
                  Text(
                    '$remaining',
                    style: Type.scoreSmall.copyWith(
                      color: Palette.chalk,
                      fontSize: hero ? 26 : 20,
                    ),
                  ),
                  const SizedBox(width: Gap.sm),
                  // Gives way first when a half-width column at the tablet's
                  // type scale has no room for the whole line.
                  Expanded(
                    child: Text(
                      l10n.checkoutDartsLeft(dartsLeft),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Type.eyebrow.copyWith(color: Palette.chalkDim),
                    ),
                  ),
                ],
              ),
              SizedBox(height: hero ? Gap.md : Gap.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var slot = 0; slot < 3; slot++) ...[
                    if (slot > 0) const SizedBox(width: Gap.sm),
                    Expanded(
                      child: slot < best.darts.length
                          ? _DartChip(
                              key: slot == 0 ? checkoutNextDartKey : null,
                              segment: best.darts[slot],
                              next: slot == 0,
                              hero: hero,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
              if (alternates.isNotEmpty) ...[
                SizedBox(height: hero ? Gap.md : Gap.sm),
                Text(
                  '${l10n.checkoutOr}   ${alternates.join('   ·   ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (hero ? Type.title : Type.label).copyWith(
                    color: Palette.chalkDim,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One dart of the route: the notation large, what it scores under it.
class _DartChip extends StatelessWidget {
  const _DartChip({
    super.key,
    required this.segment,
    required this.next,
    required this.hero,
  });

  final Segment segment;

  /// Whether this is the dart to throw now.
  final bool next;

  final bool hero;

  @override
  Widget build(BuildContext context) {
    final (fill, ink) = ringColours(segment.ring);

    final chip = Container(
      constraints: BoxConstraints(minHeight: hero ? 104 : 68),
      padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: Gap.sm),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(6),
        border: next
            ? Border.all(color: Palette.live, width: 3)
            : Border.all(color: Palette.edge.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              segment.label,
              style: Type.notation.copyWith(
                color: ink,
                fontSize: hero ? 48 : 32,
                fontVariations: const [
                  FontVariation('wdth', Width.condensed),
                  FontVariation('wght', 800),
                ],
              ),
            ),
          ),
          const SizedBox(height: Gap.xs),
          Text(
            '${segment.value}',
            style: (hero ? Type.title : Type.label).copyWith(
              color: ink.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );

    if (!next) return chip;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        chip,
        const SizedBox(height: Gap.xs),
        Text(
          context.l10n.checkoutNextDart,
          textAlign: TextAlign.center,
          style: Type.label.copyWith(color: Palette.live),
        ),
      ],
    );
  }
}
