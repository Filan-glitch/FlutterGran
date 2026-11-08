/// Cards every statistics tab shares: [TrendCard], a figure's form day by
/// day, and [HeatmapCard], where one mode's darts land.
///
/// {@category App}
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/game_mode.dart';
import '../../../domain/segment.dart';
import '../../l10n_extensions.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../../widgets/board_widget.dart';
import '../../widgets/stats/stat_card.dart';
import '../../widgets/stats/stats_charts.dart';
import 'stats_format.dart';

/// One figure a [TrendCard] can plot.
typedef TrendSeries = ({
  String label,
  List<TrendPoint> points,
  double? reference,
  String Function(double value) format,
});

/// A figure's form day by day. With more than one [series], a switch picks
/// which one is drawn.
class TrendCard extends StatefulWidget {
  const TrendCard({super.key, required this.series});

  final List<TrendSeries> series;

  @override
  State<TrendCard> createState() => _TrendCardState();
}

class _TrendCardState extends State<TrendCard> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final index = _selected.clamp(0, widget.series.length - 1);
    final series = widget.series[index];

    return StatCard(
      title: l10n.formSectionTitle,
      caption: series.points.length < 2 ? null : l10n.trendLegend,
      children: [
        if (widget.series.length > 1) ...[
          SegmentedButton<int>(
            showSelectedIcon: false,
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
            segments: [
              for (var i = 0; i < widget.series.length; i++)
                ButtonSegment(value: i, label: Text(widget.series[i].label)),
            ],
            selected: {index},
            onSelectionChanged: (picked) =>
                setState(() => _selected = picked.first),
          ),
          const SizedBox(height: Gap.md),
        ],
        if (series.points.length < 2)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Gap.lg),
            child: Text(
              l10n.trendNeedsMoreDays,
              style: Type.body.copyWith(color: Palette.chalkDim),
            ),
          )
        else
          TrendChart(
            points: series.points,
            reference: series.reference,
            format: series.format,
          ),
      ],
    );
  }
}

/// Where a player's darts in [mode] have landed, shaded against the busiest
/// segment.
class HeatmapCard extends ConsumerWidget {
  const HeatmapCard({super.key, required this.playerId, required this.mode});

  final int playerId;
  final GameMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final counts =
        ref
            .watch(segmentCountsProvider((playerId: playerId, mode: mode)))
            .value ??
        const <Segment, int>{};

    return StatCard(
      title: l10n.whereDartsLandTitle,
      caption: counts.isEmpty
          ? l10n.noDartsRecorded
          : l10n.shadedAgainstBusiest,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: BoardWidget(heat: normaliseCounts(counts), showNumbers: false),
        ),
      ],
    );
  }
}

/// A board shaded by a hit rate per segment, for doubles or Around the Clock
/// stops: segments with no attempts fade back.
class RateBoard extends StatelessWidget {
  const RateBoard({super.key, required this.rates});

  /// Hit rate per segment, 0 to 1.
  final Map<Segment, double> rates;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1,
    child: BoardWidget(heat: rates, dimUnheated: 0.6),
  );
}
