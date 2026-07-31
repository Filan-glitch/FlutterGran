import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/segment.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/board_widget.dart';

/// A player's record across every leg they have played.
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int? _playerId;

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider).value ?? const <Player>[];
    final selected = _playerId ?? (players.isEmpty ? null : players.first.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('STATISTICS'),
        actions: [
          if (players.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: Gap.md),
              child: DropdownButton<int>(
                value: selected,
                underline: const SizedBox.shrink(),
                dropdownColor: Palette.slateRaised,
                iconEnabledColor: Palette.chalkDim,
                style: Type.body.copyWith(color: Palette.chalk),
                items: [
                  for (final player in players)
                    DropdownMenuItem(
                      value: player.id,
                      child: Text(player.name),
                    ),
                ],
                onChanged: (id) => setState(() => _playerId = id),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: selected == null
            ? _Empty(
                headline: 'No players yet',
                detail: 'Add one on the setup screen to start a record.',
              )
            : _Body(playerId: selected),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.playerId});

  final int playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(playerStatsProvider(playerId));
    final counts =
        ref.watch(segmentCountsProvider(playerId)).value ??
        const <Segment, int>{};

    if (stats.legsPlayed == 0) {
      return _Empty(
        headline: 'No legs yet',
        detail: 'Play a leg and every dart in it lands here.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.xxl),
      children: [
        // The three-dart average is the number a darts player quotes when
        // asked how they play, so it is the headline and everything else is
        // supporting evidence.
        _Headline(
          value: stats.average == null
              ? '—'
              : stats.average!.toStringAsFixed(2),
          label: 'Three-dart average',
          detail: '${stats.dartsThrown} darts over ${stats.legsPlayed} '
              '${stats.legsPlayed == 1 ? 'leg' : 'legs'}',
        ),
        const SizedBox(height: Gap.xl),
        _Section(
          title: 'Scoring',
          rows: [
            _Row('First 9 average', _decimal(stats.firstNineAverage)),
            _Row('Best turn', '${stats.bestTurn}'),
            _Row('180s', '${stats.turnsOf180}'),
            _Row('140+', '${stats.turnsOf140Plus}'),
            _Row('100+', '${stats.turnsOf100Plus}'),
            _Row('60+', '${stats.turnsOf60Plus}'),
          ],
        ),
        _Section(
          title: 'Finishing',
          rows: [
            _Row('Checkout', _percent(stats.checkoutRate)),
            _Row(
              'Darts at double',
              '${stats.doublesHit}/${stats.dartsAtDouble}',
            ),
            _Row('Best checkout', _optional(stats.bestCheckout)),
            _Row('Best leg', _optional(stats.fewestDartsToWin, suffix: ' darts')),
          ],
        ),
        _Section(
          title: 'Legs',
          rows: [
            _Row('Won', '${stats.legsWon} of ${stats.legsPlayed}'),
            _Row('Win rate', _percent(stats.winRate)),
          ],
        ),
        const SizedBox(height: Gap.lg),
        Text(
          'WHERE THE DARTS LAND',
          style: Type.eyebrow.copyWith(color: Palette.chalkDim),
        ),
        const SizedBox(height: Gap.xs),
        Text(
          counts.isEmpty
              ? 'No darts recorded yet.'
              : 'Shaded against the busiest segment.',
          style: Type.label.copyWith(color: Palette.chalkDim),
        ),
        const SizedBox(height: Gap.md),
        AspectRatio(
          aspectRatio: 1,
          child: BoardWidget(heat: _normalise(counts), showNumbers: false),
        ),
      ],
    );
  }

  /// Scales hit counts to 0..1 against the busiest segment, so the board reads
  /// as relative accuracy rather than raw volume.
  Map<Segment, double> _normalise(Map<Segment, int> counts) {
    if (counts.isEmpty) return const {};
    final busiest = counts.values.reduce((a, b) => a > b ? a : b);
    if (busiest == 0) return const {};
    return {
      for (final entry in counts.entries) entry.key: entry.value / busiest,
    };
  }

  static String _decimal(double? value) =>
      value == null ? '—' : value.toStringAsFixed(2);

  static String _percent(double? value) =>
      value == null ? '—' : '${(value * 100).toStringAsFixed(0)}%';

  static String _optional(int? value, {String suffix = ''}) =>
      value == null ? '—' : '$value$suffix';
}

class _Headline extends StatelessWidget {
  const _Headline({
    required this.value,
    required this.label,
    required this.detail,
  });

  final String value;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Type.eyebrow.copyWith(color: Palette.oche),
        ),
        const SizedBox(height: Gap.sm),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: Type.score.copyWith(color: Palette.chalk)),
        ),
        const SizedBox(height: Gap.sm),
        Text(detail, style: Type.label.copyWith(color: Palette.chalkDim)),
      ],
    );
  }
}

/// Rows rather than tiles: these are label-and-number pairs, and a row of them
/// under one heading is easier to scan down than a grid of boxes.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: Type.eyebrow.copyWith(color: Palette.chalkDim),
          ),
          const SizedBox(height: Gap.sm),
          const Divider(),
          for (final row in rows) row,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Palette.edge)),
      ),
      padding: const EdgeInsets.symmetric(vertical: Gap.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Type.body.copyWith(color: Palette.chalkDim),
            ),
          ),
          Text(value, style: Type.notation.copyWith(color: Palette.chalk)),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.headline, required this.detail});

  final String headline;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Gap.xl),
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
    );
  }
}
