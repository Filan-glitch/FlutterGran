/// [X01StatsTab], a player's x01 record: the figures that decide matches up
/// top, then scoring, finishing, doubles, legs and where the darts land.
///
/// Which figures lead follows the match-outcome research: three-dart average
/// and checkout rate carry the most weight (Liebscher & Kirschstein 2017),
/// and the share of legs won inside a hundred-average pace - fifteen darts at
/// 501 - predicts a result better than the average alone.
///
/// {@category App}
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/game_mode.dart';
import '../../../domain/segment.dart';
import '../../../domain/stats/mode_stats.dart';
import '../../../domain/training/aim_records.dart';
import '../../../domain/training/aim_target.dart';
import '../../../domain/x01/x01_rules.dart';
import '../../l10n_extensions.dart';
import '../../labels.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../../widgets/stats/stat_card.dart';
import '../../widgets/stats/stats_charts.dart';
import '../../widgets/stats/stats_grid.dart';
import 'stats_cards.dart';
import 'stats_format.dart';

/// Attempts at a double before it is ranked among the best or weakest.
const int minDoubleSample = 5;

class X01StatsTab extends ConsumerWidget {
  const X01StatsTab({super.key, required this.playerId, required this.since});

  final int playerId;

  /// Start of the range shown, or null for all time.
  final DateTime? since;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stats =
        ref.watch(
              playerStatsProvider((playerId: playerId, since: since)),
            )[GameMode.x01]
            as X01Stats?;
    if (stats == null || stats.legsPlayed == 0) return const RangeEmpty();

    final trend = ref
        .watch(playerTrendProvider((playerId: playerId, since: since)))
        .x01;
    final doubles = ref.watch(
      doublesRecordProvider((playerId: playerId, since: since)),
    );
    final start = stats.mainStartScore;
    final checkout = stats.checkoutTotals;

    final averages = <TrendPoint>[
      for (final day in trend)
        if (day.stats.average case final average?)
          (day: day.day, value: average),
    ];
    final firstNines = [for (final day in trend) ?day.stats.firstNineAverage];
    final checkouts = <TrendPoint>[
      for (final day in trend)
        if (day.stats.checkoutRate case final rate?)
          (day: day.day, value: rate * 100),
    ];

    return StatsTabBody(
      tiles: TileRow(
        children: [
          StatTile(
            accent: true,
            label: l10n.threeDartAverageLabel,
            value: decimal(stats.average, places: 2),
            detail: l10n.dartsOverLegs(stats.dartsThrown, stats.legsPlayed),
            spark: [for (final point in averages) point.value],
          ),
          StatTile(
            label: l10n.firstNineAverageRow,
            value: decimal(stats.firstNineAverage, places: 2),
            spark: firstNines,
          ),
          StatTile(
            label: l10n.checkoutRateLabel,
            value: sampledPercent(stats.checkoutRate, checkout.dartsAtFinish),
            detail: sampleDetail(
              context,
              checkout.dartsAtFinish,
              l10n.xOfYDarts(checkout.finishesHit, checkout.dartsAtFinish),
            ),
            spark: [for (final point in checkouts) point.value],
          ),
          if (start != null)
            StatTile(
              label: l10n.fastLegsLabel(X01Stats.fastLegDarts(start)),
              value: percent(stats.fastLegRate(start)),
              detail: l10n.fastLegsDetail(
                stats.fastLegs(start),
                stats.legsFinishedByStart[start] ?? 0,
                start,
              ),
            )
          else
            StatTile(
              label: l10n.winRateLabel,
              value: percent(stats.winRate),
              detail: l10n.wonRatio(stats.legsWon, stats.legsFinished),
            ),
        ],
      ),
      cards: StatsGrid(
        children: [
          TrendCard(
            series: [
              (
                label: l10n.trendAverageOption,
                points: averages,
                reference: stats.average,
                format: (v) => v.toStringAsFixed(0),
              ),
              (
                label: l10n.trendCheckoutOption,
                points: checkouts,
                reference: stats.checkoutRate == null
                    ? null
                    : stats.checkoutRate! * 100,
                format: (v) => '${v.round()}%',
              ),
            ],
          ),
          _ScoringCard(stats),
          _FinishingCard(stats),
          _DoublesCard(doubles),
          _LegsCard(stats),
          if (stats.matchesPlayed > 0)
            StatCard(
              title: l10n.matchesSectionTitle,
              children: [
                StatRow(
                  l10n.wonLabel,
                  l10n.wonRatio(stats.matchesWon, stats.matchesPlayed),
                ),
                StatRow(l10n.winRateLabel, percent(stats.matchWinRate)),
              ],
            ),
          HeatmapCard(playerId: playerId, since: since, mode: GameMode.x01),
        ],
      ),
    );
  }
}

class _ScoringCard extends StatelessWidget {
  const _ScoringCard(this.stats);

  final X01Stats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String perLeg(int count) =>
        l10n.perLegValue(count, (stats.perLeg(count) ?? 0).toStringAsFixed(2));
    const bandLabels = [
      '0+',
      '20+',
      '40+',
      '60+',
      '80+',
      '100+',
      '140+',
      '180',
    ];

    return StatCard(
      title: l10n.scoringSectionTitle,
      children: [
        StatRow(
          l10n.scoringAverageRow,
          decimal(stats.scoringAverage, places: 2),
        ),
        StatRow(l10n.trebleRateRow, percent(stats.trebleRate)),
        StatRow(
          l10n.visitSpreadRow,
          stats.visitScoreStdDev == null
              ? noFigure
              : '±${stats.visitScoreStdDev!.toStringAsFixed(0)}',
        ),
        StatRow(l10n.bestTurnRow, '${stats.bestTurn}'),
        StatRow(
          l10n.figure180s,
          perLeg(stats.turnsOf180),
          milestone: stats.turnsOf180 > 0,
        ),
        StatRow(l10n.oneFortyPlusRow, perLeg(stats.turnsOf140Plus)),
        StatRow(l10n.oneHundredPlusRow, perLeg(stats.turnsOf100Plus)),
        StatRow(l10n.sixtyPlusRow, perLeg(stats.turnsOf60Plus)),
        if (stats.scoringVisits > 0) ...[
          const SizedBox(height: Gap.md),
          Text(
            l10n.visitScoresTitle.toUpperCase(),
            style: Type.eyebrow.copyWith(color: Palette.chalkDim),
          ),
          const SizedBox(height: Gap.xs),
          Text(
            l10n.visitScoresCaption,
            style: Type.label.copyWith(color: Palette.chalkDim),
          ),
          const SizedBox(height: Gap.md),
          BarChart(
            bars: [
              for (var i = 0; i < bandLabels.length; i++)
                (
                  label: bandLabels[i],
                  count: stats.scoringVisitBands[i],
                  highlight: X01Stats.visitScoreBands[i] >= 100,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _FinishingCard extends StatelessWidget {
  const _FinishingCard(this.stats);

  final X01Stats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StatCard(
      title: l10n.finishingSectionTitle,
      children: [
        // One block per out-rule actually played: "on a finish" means
        // something different under each, so they are never pooled here.
        for (final rule in X01OutRule.values) ...[
          if (stats.checkoutsByRule[rule] case final darts?)
            StatRow(
              l10n.ruleCheckoutRow(x01OutRuleLabel(context, rule)),
              sampledPercent(stats.checkoutRateFor(rule), darts.dartsAtFinish),
              detail: sampleDetail(
                context,
                darts.dartsAtFinish,
                l10n.xOfYDarts(darts.finishesHit, darts.dartsAtFinish),
              ),
            ),
          if (stats.checkoutVisitsByRule[rule] case final visits?)
            StatRow(
              l10n.ruleCheckoutVisitRow(x01OutRuleLabel(context, rule)),
              percent(stats.checkoutVisitRateFor(rule)),
              detail: l10n.wonRatio(visits.won, visits.visits),
            ),
        ],
        StatRow(
          l10n.bestCheckoutRow,
          stats.bestCheckout == null ? noFigure : '${stats.bestCheckout}',
          milestone: stats.bestCheckout != null,
        ),
        StatRow(
          l10n.tonPlusCheckoutsRow,
          '${stats.tonPlusCheckouts}',
          milestone: stats.tonPlusCheckouts > 0,
        ),
      ],
    );
  }
}

class _DoublesCard extends StatelessWidget {
  const _DoublesCard(this.records);

  final Map<AimTarget, AimRecord> records;

  static Segment? _segmentFor(AimTarget target) => switch (target.kind) {
    AimKind.double => Segment(target.number, Ring.doubleRing),
    AimKind.bullseye => Segment.innerBull,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final doubles = [
      for (final entry in records.entries)
        if (_segmentFor(entry.key) != null && entry.value.attempts > 0) entry,
    ];
    if (doubles.isEmpty) {
      return StatCard(
        title: l10n.doublesSectionTitle,
        children: [
          Text(
            l10n.noDoublesYet,
            style: Type.body.copyWith(color: Palette.chalkDim),
          ),
        ],
      );
    }

    double rate(AimRecord r) => r.hits / r.attempts;
    final ranked =
        doubles.where((e) => e.value.attempts >= minDoubleSample).toList()
          ..sort((a, b) => rate(b.value).compareTo(rate(a.value)));
    final best = ranked.take(3).toList();
    final weakest = ranked.reversed
        .where((e) => !best.contains(e))
        .take(3)
        .toList();

    StatRow row(MapEntry<AimTarget, AimRecord> entry) => StatRow(
      entry.key.label,
      l10n.doubleHitsRate(
        entry.value.hits,
        entry.value.attempts,
        percent(rate(entry.value)),
      ),
    );

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: Gap.md, bottom: Gap.xs),
      child: Text(
        text.toUpperCase(),
        style: Type.eyebrow.copyWith(color: Palette.chalkDim),
      ),
    );

    return StatCard(
      title: l10n.doublesSectionTitle,
      caption: l10n.doublesCaption,
      children: [
        RateBoard(
          rates: {
            for (final entry in doubles)
              _segmentFor(entry.key)!: rate(entry.value),
          },
        ),
        if (best.isNotEmpty) ...[
          heading(l10n.bestDoublesLabel),
          for (final entry in best) row(entry),
        ],
        if (weakest.isNotEmpty) ...[
          heading(l10n.worstDoublesLabel),
          for (final entry in weakest) row(entry),
        ],
      ],
    );
  }
}

class _LegsCard extends StatelessWidget {
  const _LegsCard(this.stats);

  final X01Stats stats;

  /// Darts-per-leg buckets for legs from [start]: the fast-leg pace and
  /// under, then a visit at a time, then everything slower.
  static List<Bar> _dartsBars(List<int> darts, int start) {
    final fast = X01Stats.fastLegDarts(start);
    const steps = 5;
    final counts = List.filled(steps + 2, 0);
    for (final d in darts) {
      if (d <= fast) {
        counts[0]++;
      } else {
        final step = (d - fast - 1) ~/ 3 + 1;
        counts[step > steps ? steps + 1 : step]++;
      }
    }
    return [
      (label: '≤$fast', count: counts[0], highlight: true),
      for (var i = 1; i <= steps; i++)
        (
          label: '${fast + 3 * (i - 1) + 1}–${fast + 3 * i}',
          count: counts[i],
          highlight: false,
        ),
      (label: '${fast + 3 * steps + 1}+', count: counts.last, highlight: false),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final start = stats.mainStartScore;
    final wonDarts = start == null
        ? const <int>[]
        : stats.dartsToWinByStart[start] ?? const <int>[];
    final hasThrowSplit = stats.legsOnThrow + stats.legsAgainstThrow > 0;

    String split(double? rate, int won, int played) =>
        '${percent(rate)} · ${l10n.wonRatio(won, played)}';

    return StatCard(
      title: l10n.legsSectionTitle,
      children: [
        StatRow(
          l10n.wonLabel,
          l10n.wonRatio(stats.legsWon, stats.legsFinished),
        ),
        StatRow(l10n.winRateLabel, percent(stats.winRate)),
        if (start != null)
          StatRow(
            l10n.dartsPerLegWonRow,
            decimal(stats.averageDartsPerLegWon(start)),
            detail: '$start',
          ),
        StatRow(
          l10n.bestLegRow,
          stats.fewestDartsToWin == null
              ? noFigure
              : l10n.dartsCount(stats.fewestDartsToWin!),
        ),
        if (hasThrowSplit) ...[
          const SizedBox(height: Gap.md),
          Text(
            l10n.throwSplitTitle.toUpperCase(),
            style: Type.eyebrow.copyWith(color: Palette.chalkDim),
          ),
          const SizedBox(height: Gap.xs),
          SplitBar(
            rows: [
              (
                label: l10n.onThrowLabel,
                value: split(
                  stats.winRateOnThrow,
                  stats.legsWonOnThrow,
                  stats.legsOnThrow,
                ),
                fill: stats.winRateOnThrow ?? 0,
              ),
              (
                label: l10n.againstThrowLabel,
                value: split(
                  stats.winRateAgainstThrow,
                  stats.legsWonAgainstThrow,
                  stats.legsAgainstThrow,
                ),
                fill: stats.winRateAgainstThrow ?? 0,
              ),
            ],
          ),
        ],
        if (start != null && wonDarts.isNotEmpty) ...[
          const SizedBox(height: Gap.md),
          Text(
            l10n.dartsPerLegTitle(start).toUpperCase(),
            style: Type.eyebrow.copyWith(color: Palette.chalkDim),
          ),
          const SizedBox(height: Gap.md),
          BarChart(bars: _dartsBars(wonDarts, start)),
        ],
      ],
    );
  }
}
