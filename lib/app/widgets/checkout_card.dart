import 'package:flutter/material.dart';

import '../../domain/checkout/checkout_search.dart';
import '../l10n_extensions.dart';
import '../theme.dart';
import 'aim_strip.dart';

/// Key on the whole card, for tests.
const Key checkoutCardKey = Key('checkout-card');

/// Key on the chip for the dart to throw next.
const Key checkoutNextDartKey = Key('checkout-next-dart');

/// What to throw, when there is a finish on: the best route as one chip per
/// dart, big enough to read from the oche.
///
/// The next dart carries the pale outline and says so under it; the rest of
/// the route follows beside it, and up to two alternates sit on a line below.
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
        child: AimStrip(
          key: checkoutCardKey,
          label: l10n.checkoutLabel,
          target: '$remaining',
          dartsLeft: dartsLeft,
          hero: hero,
          padding: padding,
          chips: [
            for (var i = 0; i < best.darts.length; i++)
              SegmentChip(
                key: i == 0 ? checkoutNextDartKey : null,
                label: best.darts[i].label,
                caption: '${best.darts[i].value}',
                ring: best.darts[i].ring,
                lit: i == 0,
                footnote: i == 0 ? l10n.checkoutNextDart : null,
                hero: hero,
              ),
          ],
          alternatives: alternates.isEmpty
              ? null
              : '${l10n.checkoutOr}   ${alternates.join('   ·   ')}',
        ),
      ),
    );
  }
}
