import 'package:flutter/material.dart';

import '../../domain/segment.dart';
import '../l10n_extensions.dart';
import '../theme.dart';

/// Key on the whole card, for tests.
const Key boundsCardKey = Key('bounds-card');

/// Higher/Lower's answer to the checkout card: the two values a turn has to
/// beat, big enough to read from the oche, with the turn's running total
/// above them.
///
/// Laid out like `AimStrip` - a header line, then one row of tiles - so every
/// mode asks for its next dart in the same place. A value the turn in
/// progress can no longer beat dims, so the player sees which way is still
/// open without doing the sum.
class BoundsCard extends StatelessWidget {
  const BoundsCard({
    super.key,
    required this.higher,
    required this.lower,
    required this.runningTotal,
    required this.dartsLeft,
    this.hero = false,
  });

  final int higher;
  final int lower;

  /// What the turn in progress has scored so far.
  final int runningTotal;

  final int dartsLeft;
  final bool hero;

  /// The most one dart can add: treble 20.
  static final int _bestDart = Segment.all
      .map((segment) => segment.value)
      .reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      key: boundsCardKey,
      padding: EdgeInsets.fromLTRB(Gap.md, hero ? Gap.lg : Gap.md, Gap.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                l10n.turnTotalLabel,
                style: Type.eyebrow.copyWith(color: Palette.live),
              ),
              const SizedBox(width: Gap.sm),
              Text(
                '$runningTotal',
                style: Type.scoreSmall.copyWith(
                  color: Palette.chalk,
                  fontSize: hero ? 26 : 20,
                ),
              ),
              const SizedBox(width: Gap.sm),
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
            children: [
              Expanded(
                child: _BoundTile(
                  key: const Key('bound-higher'),
                  label: l10n.higherLabel,
                  figure: '> $higher',
                  open: runningTotal + dartsLeft * _bestDart > higher,
                  hero: hero,
                ),
              ),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: _BoundTile(
                  key: const Key('bound-lower'),
                  label: l10n.lowerLabel,
                  figure: '< $lower',
                  open: runningTotal < lower,
                  hero: hero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One of the two values: what it is called, and what beats it.
class _BoundTile extends StatelessWidget {
  const _BoundTile({
    super.key,
    required this.label,
    required this.figure,
    required this.open,
    required this.hero,
  });

  final String label;
  final String figure;

  /// Whether the turn in progress can still beat this value.
  final bool open;

  final bool hero;

  @override
  Widget build(BuildContext context) {
    final ink = open ? Palette.chalk : Palette.chalkDim;

    return Opacity(
      opacity: open ? 1 : 0.5,
      child: Container(
        constraints: BoxConstraints(minHeight: hero ? 104 : 68),
        padding: const EdgeInsets.all(Gap.sm),
        decoration: BoxDecoration(
          color: Palette.raised,
          borderRadius: BorderRadius.circular(6),
          border: open
              ? Border.all(color: Palette.live, width: 3)
              : Border.all(color: Palette.edge.withValues(alpha: 0.6)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: Type.eyebrow.copyWith(color: ink)),
            const SizedBox(height: Gap.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                figure,
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
          ],
        ),
      ),
    );
  }
}
