/// How the statistics screen writes its figures, and how little data is too
/// little to quote one.
///
/// {@category App}
library;

import 'package:flutter/widgets.dart';

import '../../../domain/segment.dart';
import '../../l10n_extensions.dart';
import '../../theme.dart';
import '../../widgets/stats/stat_card.dart';

/// Attempts below which a rate is shown as `—` with how many more are
/// needed, rather than as a percentage: one double out of two is not "50%".
const int minRateSample = 10;

/// What a figure that is not there reads as.
const String noFigure = '—';

String decimal(double? value, {int places = 1}) =>
    value == null ? noFigure : value.toStringAsFixed(places);

String percent(double? value) =>
    value == null ? noFigure : '${(value * 100).toStringAsFixed(0)}%';

/// [rate] as a percentage once [sample] reaches [minRateSample], else `—`.
String sampledPercent(double? rate, int sample) =>
    sample < minRateSample ? noFigure : percent(rate);

/// The small print under a sampled rate: its sample while that is too small,
/// otherwise [detail].
String? sampleDetail(BuildContext context, int sample, String? detail) =>
    sample < minRateSample
    ? context.l10n.needsMoreDarts(minRateSample - sample)
    : detail;

/// Hit counts scaled to 0..1 against the busiest segment, so the board
/// reads as relative accuracy rather than raw volume.
Map<Segment, double> normaliseCounts(Map<Segment, int> counts) {
  if (counts.isEmpty) return const {};
  final busiest = counts.values.reduce((a, b) => a > b ? a : b);
  if (busiest == 0) return const {};
  return {for (final entry in counts.entries) entry.key: entry.value / busiest};
}

/// A tab's body: its tiles, then its cards, centred and capped so a monitor
/// gets three columns of cards rather than one stretched across it.
class StatsTabBody extends StatelessWidget {
  const StatsTabBody({super.key, required this.tiles, required this.cards});

  final Widget tiles;
  final Widget cards;

  @override
  Widget build(BuildContext context) {
    return CenteredContent(
      maxWidth: 1200,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.md, Gap.lg, Gap.xxl),
        children: [
          tiles,
          const SizedBox(height: Gap.md),
          cards,
        ],
      ),
    );
  }
}

/// What a tab shows when the range holds nothing for it.
class StatsEmpty extends StatelessWidget {
  const StatsEmpty({super.key, required this.headline, required this.detail});

  final String headline;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Gap.xl),
        child: FadeIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(headline, style: Type.title.copyWith(color: Palette.chalk)),
              const SizedBox(height: Gap.sm),
              Text(
                detail,
                textAlign: TextAlign.center,
                style: Type.body.copyWith(color: Palette.chalkDim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The empty state for a mode the player has played, just not in the range.
class RangeEmpty extends StatelessWidget {
  const RangeEmpty({super.key});

  @override
  Widget build(BuildContext context) => StatsEmpty(
    headline: context.l10n.noLegsInRangeHeadline,
    detail: context.l10n.noLegsInRangeDetail,
  );
}
