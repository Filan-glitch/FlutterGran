/// The building blocks of the statistics screen: [StatCard], a titled
/// surface; [StatRow], a label-and-figure line inside one; [StatTile], a
/// headline figure; and [FadeIn], the entrance they share.
///
/// {@category App}
library;

import 'package:flutter/material.dart';

import '../../theme.dart';
import 'stats_charts.dart';

/// A titled, raised surface holding one topic of a player's record: rows,
/// a chart, or both.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.children,
    this.caption,
    this.trailing,
  });

  final String title;

  /// A line under the title saying how to read what follows.
  final String? caption;

  /// Sits at the right of the title, for a control that changes the card.
  final Widget? trailing;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Palette.raised,
          border: Border.all(color: Palette.edge),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.md, Gap.lg, Gap.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: Type.eyebrow.copyWith(color: Palette.chalkDim),
                    ),
                  ),
                  ?trailing,
                ],
              ),
              if (caption case final caption?) ...[
                const SizedBox(height: Gap.xs),
                Text(
                  caption,
                  style: Type.label.copyWith(color: Palette.chalkDim),
                ),
              ],
              const SizedBox(height: Gap.sm),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// A label and its figure, on a hairline. Rows rather than tiles inside a
/// card: a column of label-and-number pairs is easier to scan down than a
/// grid of boxes.
class StatRow extends StatelessWidget {
  const StatRow(
    this.label,
    this.value, {
    super.key,
    this.detail,
    this.milestone = false,
  });

  final String label;
  final String value;

  /// Small print under the label: the sample behind the figure.
  final String? detail;

  /// Marks a figure worth a second look - a 180, a personal-best checkout -
  /// rather than just another number in the record. Presentation only.
  final bool milestone;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Palette.edge)),
      ),
      padding: const EdgeInsets.symmetric(vertical: Gap.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Type.body.copyWith(color: Palette.chalkDim)),
                if (detail case final detail?)
                  Text(
                    detail,
                    style: Type.label.copyWith(
                      color: Palette.chalkDim.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Gap.sm),
          if (milestone) ...[
            const Icon(Icons.bolt, size: 15, color: Palette.live),
            const SizedBox(width: Gap.xs),
          ],
          Text(
            value,
            style: Type.notation.copyWith(
              color: milestone ? Palette.live : Palette.chalk,
            ),
          ),
        ],
      ),
    );
  }
}

/// A headline figure: what a player quotes when asked how they throw.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.detail,
    this.spark = const [],
    this.accent = false,
  });

  final String label;
  final String value;
  final String? detail;

  /// Day-by-day values for a sparkline under the figure; fewer than two
  /// draw nothing.
  final List<double> spark;

  /// The one tile a screen leads with, in [Palette.live].
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Palette.raised,
          border: Border.all(color: accent ? Palette.brand : Palette.edge),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Gap.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Type.eyebrow.copyWith(
                  color: accent ? Palette.live : Palette.chalkDim,
                ),
              ),
              const SizedBox(height: Gap.sm),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: Type.score.copyWith(color: Palette.chalk),
                ),
              ),
              const SizedBox(height: Gap.xs),
              SizedBox(
                height: 20,
                child: spark.length < 2
                    ? null
                    : Sparkline(
                        values: spark,
                        colour: accent ? Palette.live : Palette.chalkDim,
                      ),
              ),
              const SizedBox(height: Gap.xs),
              Text(
                detail ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Type.label.copyWith(color: Palette.chalkDim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A plain fade and rise on first build, for a record that otherwise appears
/// fully formed the moment its player is selected.
class FadeIn extends StatelessWidget {
  const FadeIn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Motion.scale(Motion.base),
      curve: Motion.enter,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 8),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
