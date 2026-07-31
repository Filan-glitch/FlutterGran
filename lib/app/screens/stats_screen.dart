import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/segment.dart';
import '../providers.dart';
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
        title: const Text('Statistics'),
        actions: [
          if (players.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: DropdownButton<int>(
                value: selected,
                underline: const SizedBox.shrink(),
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
            ? const Center(child: Text('No players yet.'))
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
      return const Center(child: Text('No legs played yet.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Section(
          title: 'Scoring',
          tiles: [
            _Tile('3-dart average', _decimal(stats.average)),
            _Tile('First 9 average', _decimal(stats.firstNineAverage)),
            _Tile('Best turn', '${stats.bestTurn}'),
            _Tile('Darts thrown', '${stats.dartsThrown}'),
          ],
        ),
        _Section(
          title: 'Big turns',
          tiles: [
            _Tile('180s', '${stats.turnsOf180}'),
            _Tile('140+', '${stats.turnsOf140Plus}'),
            _Tile('100+', '${stats.turnsOf100Plus}'),
            _Tile('60+', '${stats.turnsOf60Plus}'),
          ],
        ),
        _Section(
          title: 'Finishing',
          tiles: [
            _Tile('Checkout %', _percent(stats.checkoutRate)),
            _Tile(
              'Darts at double',
              '${stats.doublesHit}/${stats.dartsAtDouble}',
            ),
            _Tile('Best checkout', _optional(stats.bestCheckout)),
            _Tile('Best leg', _optional(stats.fewestDartsToWin, suffix: ' darts')),
          ],
        ),
        _Section(
          title: 'Legs',
          tiles: [
            _Tile('Played', '${stats.legsPlayed}'),
            _Tile('Won', '${stats.legsWon}'),
            _Tile('Win rate', _percent(stats.winRate)),
          ],
        ),
        const SizedBox(height: 24),
        Text('Where the darts land', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          counts.isEmpty
              ? 'No darts recorded yet.'
              : 'Shaded by how often each segment is hit.',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1,
          child: BoardWidget(heat: _normalise(counts), showNumbers: false),
        ),
        const SizedBox(height: 24),
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
      value == null ? '—' : value.toStringAsFixed(1);

  static String _percent(double? value) =>
      value == null ? '—' : '${(value * 100).toStringAsFixed(0)}%';

  static String _optional(int? value, {String suffix = ''}) =>
      value == null ? '—' : '$value$suffix';
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.tiles});

  final String title;
  final List<_Tile> tiles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: tiles),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
