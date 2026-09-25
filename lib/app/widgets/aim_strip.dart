import 'package:flutter/material.dart';

import '../../domain/segment.dart';
import '../l10n_extensions.dart';
import '../theme.dart';
import 'ring_colours.dart';

/// What to throw at next, big enough to read from the oche: a header, up to
/// three [SegmentChip]s, and a quiet line of alternatives.
///
/// There are always three slots, whatever the number of chips, so a chip is
/// the same size on every turn and the eye learns where to look. The checkout
/// card and the Around the Clock aim card are both one of these, so a finish
/// and a stop are asked for in exactly the same place and the same way.
class AimStrip extends StatelessWidget {
  const AimStrip({
    super.key,
    required this.label,
    required this.target,
    required this.dartsLeft,
    required this.chips,
    this.alternatives,
    this.hero = false,
    this.padding,
  });

  /// What kind of aim this is: CHECKOUT, AIM.
  final String label;

  /// What is being aimed for: the score to check out, the stop.
  final String target;

  final int dartsLeft;

  /// At most three.
  final List<Widget> chips;

  /// Other ways to the same place, on one line under the chips.
  final String? alternatives;

  final bool hero;

  /// Around the strip. Defaults to the game screen's inset from its edges; a
  /// caller already inside a padded list passes its own.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final alternatives = this.alternatives;

    return Padding(
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
              Text(label, style: Type.eyebrow.copyWith(color: Palette.live)),
              const SizedBox(width: Gap.sm),
              Text(
                target,
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
                  child: slot < chips.length
                      ? chips[slot]
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
          if (alternatives != null) ...[
            SizedBox(height: hero ? Gap.md : Gap.sm),
            Text(
              alternatives,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (hero ? Type.title : Type.label).copyWith(
                color: Palette.chalkDim,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One place on the board to throw at: the notation large, a line under it.
///
/// Wears the colour of the bed it asks for, the same colour the keypad key for
/// that dart has, so "treble" and "double" read before the number does. A
/// [lit] chip carries the pale [Palette.live] outline, which is the app's one
/// way of saying "aim here" - the keypad lights its keys the same way.
///
/// Shared by the checkout card and the Around the Clock aim card. [hero] is
/// the tablet scale: the same chip with more room to say it in.
class SegmentChip extends StatelessWidget {
  const SegmentChip({
    super.key,
    required this.label,
    required this.ring,
    this.caption,
    this.lit = false,
    this.footnote,
    this.hero = false,
  });

  /// What to throw at: `T20`, `7`, `BULL`.
  final String label;

  /// The bed it is in, which decides its colours.
  final Ring ring;

  /// Under the notation, inside the chip - what the dart scores.
  final String? caption;

  final bool lit;

  /// Under the chip, outside it, in the live colour - "next dart".
  final String? footnote;

  final bool hero;

  @override
  Widget build(BuildContext context) {
    final (fill, ink) = ringColours(ring);
    final caption = this.caption;
    final footnote = this.footnote;

    final chip = Container(
      constraints: BoxConstraints(minHeight: hero ? 104 : 68),
      padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: Gap.sm),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(6),
        border: lit
            ? Border.all(color: Palette.live, width: 3)
            : Border.all(color: Palette.edge.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
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
          if (caption != null) ...[
            const SizedBox(height: Gap.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                caption,
                style: (hero ? Type.title : Type.label).copyWith(
                  color: ink.withValues(alpha: 0.75),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (footnote == null) return chip;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        chip,
        const SizedBox(height: Gap.xs),
        Text(
          footnote,
          textAlign: TextAlign.center,
          style: Type.label.copyWith(color: Palette.live),
        ),
      ],
    );
  }
}
