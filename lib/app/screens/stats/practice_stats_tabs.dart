/// The statistics tabs for the modes that are not x01: [AtcStatsTab],
/// [BullingStatsTab] and [HigherLowerStatsTab]. Each leads with its hit or
/// survival rate, the figure that mode exists to improve.
///
/// {@category App}
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/atc/atc_variant.dart';
import '../../../domain/game_mode.dart';
import '../../../domain/segment.dart';
import '../../../domain/stats/dated.dart';
import '../../../domain/stats/mode_stats.dart';
import '../../l10n_extensions.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../../widgets/stats/stat_card.dart';
import '../../widgets/stats/stats_charts.dart';
import '../../widgets/stats/stats_grid.dart';
import 'stats_cards.dart';
import 'stats_format.dart';

/// A day-by-day rate as percentages, for a [TrendCard].
List<TrendPoint> _ratePoints<S>(
  List<Daily<S>> days,
  double? Function(S stats) rate,
) => [
  for (final day in days)
    if (rate(day.stats) case final value?) (day: day.day, value: value * 100),
];

String _percentAxis(double v) => '${v.round()}%';

class AtcStatsTab extends ConsumerWidget {
  const AtcStatsTab({super.key, required this.playerId});

  final int playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stats =
        ref.watch(playerStatsProvider(playerId))[GameMode.aroundTheClock]
            as AtcStats?;
    if (stats == null || stats.legsPlayed == 0) return const RangeEmpty();

    final points = _ratePoints(
      ref.watch(playerTrendProvider(playerId)).atc,
      (AtcStats s) => s.hitRate,
    );

    final attempted = [
      for (final entry in stats.perStop.entries)
        if (entry.value.attempts > 0) entry,
    ];
    double rate(({int attempts, int hits}) r) => r.hits / r.attempts;
    final weakest = [...attempted]
      ..sort((a, b) => rate(a.value).compareTo(rate(b.value)));

    return StatsTabBody(
      tiles: TileRow(
        children: [
          StatTile(
            accent: true,
            label: l10n.hitRateLabel,
            value: percent(stats.hitRate),
            detail: l10n.xOfYDarts(stats.qualifyingDarts, stats.dartsThrown),
            spark: [for (final p in points) p.value],
          ),
          StatTile(
            label: l10n.winRateLabel,
            value: percent(stats.winRate),
            detail: l10n.wonRatio(stats.legsWon, stats.legsFinished),
          ),
          StatTile(
            label: l10n.bestLegRow,
            value: stats.fewestDartsToWin == null
                ? noFigure
                : '${stats.fewestDartsToWin}',
            detail: l10n.statDarts,
          ),
          StatTile(
            label: l10n.statDarts,
            value: '${stats.dartsThrown}',
            detail: l10n.dartsOverLegs(stats.dartsThrown, stats.legsPlayed),
          ),
        ],
      ),
      cards: StatsGrid(
        children: [
          TrendCard(
            series: [
              (
                label: l10n.hitRateLabel,
                points: points,
                reference: stats.hitRate == null ? null : stats.hitRate! * 100,
                format: _percentAxis,
              ),
            ],
          ),
          if (attempted.isNotEmpty)
            StatCard(
              title: l10n.stopsSectionTitle,
              caption: l10n.stopHeatCaption,
              children: [
                RateBoard(
                  rates: {
                    for (final entry in attempted)
                      for (final segment in Segment.all)
                        if (entry.key.clears(segment, AtcVariant.anyPart))
                          segment: rate(entry.value),
                  },
                ),
                const SizedBox(height: Gap.md),
                Text(
                  l10n.weakSpotsSectionTitle.toUpperCase(),
                  style: Type.eyebrow.copyWith(color: Palette.chalkDim),
                ),
                for (final entry in weakest.take(5))
                  StatRow(
                    entry.key.label,
                    '${entry.value.hits}/${entry.value.attempts}',
                  ),
              ],
            ),
          StatCard(
            title: l10n.legsSectionTitle,
            children: [
              StatRow(
                l10n.wonLabel,
                l10n.wonRatio(stats.legsWon, stats.legsFinished),
              ),
              StatRow(l10n.winRateLabel, percent(stats.winRate)),
              StatRow(
                l10n.bestLegRow,
                stats.fewestDartsToWin == null
                    ? noFigure
                    : l10n.dartsCount(stats.fewestDartsToWin!),
              ),
            ],
          ),
          HeatmapCard(playerId: playerId, mode: GameMode.aroundTheClock),
        ],
      ),
    );
  }
}

class BullingStatsTab extends ConsumerWidget {
  const BullingStatsTab({super.key, required this.playerId});

  final int playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stats =
        ref.watch(playerStatsProvider(playerId))[GameMode.bulling]
            as BullingStats?;
    if (stats == null || stats.legsPlayed == 0) return const RangeEmpty();

    final points = _ratePoints(
      ref.watch(playerTrendProvider(playerId)).bulling,
      (BullingStats s) => s.hitRate,
    );
    final darts = stats.dartsThrown;
    double share(int hits) => darts == 0 ? 0 : hits / darts;

    return StatsTabBody(
      tiles: TileRow(
        children: [
          StatTile(
            accent: true,
            label: l10n.hitRateLabel,
            value: percent(stats.hitRate),
            detail: l10n.xOfYDarts(stats.scoringDarts, darts),
            spark: [for (final p in points) p.value],
          ),
          StatTile(
            label: l10n.winRateLabel,
            value: percent(stats.winRate),
            detail: l10n.wonRatio(stats.legsWon, stats.legsFinished),
          ),
          StatTile(label: l10n.pointsScoredRow, value: '${stats.pointsScored}'),
          StatTile(
            label: l10n.bestLegRow,
            value: stats.fewestDartsToWin == null
                ? noFigure
                : '${stats.fewestDartsToWin}',
            detail: l10n.statDarts,
          ),
        ],
      ),
      cards: StatsGrid(
        children: [
          TrendCard(
            series: [
              (
                label: l10n.hitRateLabel,
                points: points,
                reference: stats.hitRate == null ? null : stats.hitRate! * 100,
                format: _percentAxis,
              ),
            ],
          ),
          StatCard(
            title: l10n.bullSplitTitle,
            children: [
              SplitBar(
                rows: [
                  (
                    label: l10n.outerBullHitsRow,
                    value:
                        '${stats.outerBullHits} · '
                        '${percent(share(stats.outerBullHits))}',
                    fill: share(stats.outerBullHits),
                  ),
                  (
                    label: l10n.bullseyeHitsRow,
                    value:
                        '${stats.innerBullHits} · '
                        '${percent(share(stats.innerBullHits))}',
                    fill: share(stats.innerBullHits),
                  ),
                ],
              ),
            ],
          ),
          StatCard(
            title: l10n.legsSectionTitle,
            children: [
              StatRow(
                l10n.wonLabel,
                l10n.wonRatio(stats.legsWon, stats.legsFinished),
              ),
              StatRow(l10n.winRateLabel, percent(stats.winRate)),
              StatRow(
                l10n.bestLegRow,
                stats.fewestDartsToWin == null
                    ? noFigure
                    : l10n.dartsCount(stats.fewestDartsToWin!),
              ),
            ],
          ),
          HeatmapCard(playerId: playerId, mode: GameMode.bulling),
        ],
      ),
    );
  }
}

class HigherLowerStatsTab extends ConsumerWidget {
  const HigherLowerStatsTab({super.key, required this.playerId});

  final int playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stats =
        ref.watch(playerStatsProvider(playerId))[GameMode.higherLower]
            as HigherLowerStats?;
    if (stats == null || stats.legsPlayed == 0) return const RangeEmpty();

    final points = _ratePoints(
      ref.watch(playerTrendProvider(playerId)).higherLower,
      (HigherLowerStats s) => s.survivalRate,
    );
    final survived = stats.higherCalls + stats.lowerCalls;
    double share(int calls) => survived == 0 ? 0 : calls / survived;

    return StatsTabBody(
      tiles: TileRow(
        children: [
          StatTile(
            accent: true,
            label: l10n.survivalRateLabel,
            value: percent(stats.survivalRate),
            detail: l10n.xOfYTurns(stats.turnsSurvived, stats.turnsPlayed),
            spark: [for (final p in points) p.value],
          ),
          StatTile(
            label: l10n.longestRunRow,
            value: '${stats.longestRun}',
            detail: l10n.turnsCount(stats.longestRun),
          ),
          StatTile(
            label: l10n.winRateLabel,
            value: percent(stats.winRate),
            detail: l10n.wonRatio(stats.legsWon, stats.legsFinished),
          ),
          StatTile(
            label: l10n.statDarts,
            value: '${stats.dartsThrown}',
            detail: l10n.dartsOverLegs(stats.dartsThrown, stats.legsPlayed),
          ),
        ],
      ),
      cards: StatsGrid(
        children: [
          TrendCard(
            series: [
              (
                label: l10n.survivalRateLabel,
                points: points,
                reference: stats.survivalRate == null
                    ? null
                    : stats.survivalRate! * 100,
                format: _percentAxis,
              ),
            ],
          ),
          StatCard(
            title: l10n.callsSplitTitle,
            children: [
              SplitBar(
                rows: [
                  (
                    label: l10n.higherCallsRow,
                    value: '${stats.higherCalls}',
                    fill: share(stats.higherCalls),
                  ),
                  (
                    label: l10n.lowerCallsRow,
                    value: '${stats.lowerCalls}',
                    fill: share(stats.lowerCalls),
                  ),
                ],
              ),
            ],
          ),
          StatCard(
            title: l10n.legsSectionTitle,
            children: [
              StatRow(
                l10n.wonLabel,
                l10n.wonRatio(stats.legsWon, stats.legsFinished),
              ),
              StatRow(l10n.winRateLabel, percent(stats.winRate)),
              StatRow(l10n.longestRunRow, l10n.turnsCount(stats.longestRun)),
            ],
          ),
          HeatmapCard(playerId: playerId, mode: GameMode.higherLower),
        ],
      ),
    );
  }
}
