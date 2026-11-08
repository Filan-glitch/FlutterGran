/// [StatsScreen], a player's record: one tab per mode they have played, cut
/// to a time range.
///
/// The tabs themselves live in `stats/`; this file is the frame around them.
///
/// {@category App}
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/game_mode.dart';
import '../../domain/stats/dated.dart';
import '../l10n_extensions.dart';
import '../providers.dart';
import '../theme.dart';
import 'stats/practice_stats_tabs.dart';
import 'stats/stats_format.dart';
import 'stats/x01_stats_tab.dart';

/// A player's record, mode by mode.
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int? _playerId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final players = ref.watch(playersProvider).value ?? const <Player>[];
    final selected = _playerId ?? (players.isEmpty ? null : players.first.id);
    final modes = selected == null
        ? const <GameMode>[]
        : ref.watch(playedModesProvider(selected));

    final playerPicker = players.isEmpty
        ? null
        : Padding(
            padding: const EdgeInsets.only(right: Gap.md),
            child: DropdownButton<int>(
              key: const Key('stats-player-picker'),
              value: selected,
              underline: const SizedBox.shrink(),
              dropdownColor: Palette.raised,
              iconEnabledColor: Palette.chalkDim,
              style: Type.body.copyWith(color: Palette.chalk),
              items: [
                for (final player in players)
                  DropdownMenuItem(value: player.id, child: Text(player.name)),
              ],
              onChanged: (id) => setState(() => _playerId = id),
            ),
          );

    if (selected == null || modes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.statisticsTitle),
          actions: [?playerPicker],
        ),
        body: SafeArea(
          child: selected == null
              ? StatsEmpty(
                  headline: l10n.noPlayersYetHeadline,
                  detail: l10n.noPlayersYetDetail,
                )
              : StatsEmpty(
                  headline: l10n.noLegsYetHeadline,
                  detail: l10n.noLegsYetDetail,
                ),
        ),
      );
    }

    // Keyed by player and modes: a different set of tabs is a different
    // controller, so a player with fewer modes never inherits an index past
    // the end.
    return DefaultTabController(
      key: ValueKey((selected, modes.join(','))),
      length: modes.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.statisticsTitle),
          actions: [?playerPicker],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kTextTabBarHeight + 52),
            child: Column(
              children: [
                TabBar(
                  isScrollable: modes.length > 2,
                  tabAlignment: modes.length > 2 ? TabAlignment.start : null,
                  tabs: [
                    for (final mode in modes)
                      Tab(text: _modeLabel(context, mode)),
                  ],
                ),
                const _RangePicker(),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              for (final mode in modes)
                switch (mode) {
                  GameMode.x01 => X01StatsTab(playerId: selected),
                  GameMode.aroundTheClock => AtcStatsTab(playerId: selected),
                  GameMode.bulling => BullingStatsTab(playerId: selected),
                  GameMode.higherLower => HigherLowerStatsTab(
                    playerId: selected,
                  ),
                },
            ],
          ),
        ),
      ),
    );
  }

  static String _modeLabel(BuildContext context, GameMode mode) {
    final l10n = context.l10n;
    return switch (mode) {
      GameMode.x01 => l10n.x01Label,
      GameMode.aroundTheClock => l10n.aroundTheClockLabel,
      GameMode.bulling => l10n.bullingLabel,
      GameMode.higherLower => l10n.higherLowerLabel,
    };
  }
}

/// All time, 30 days, 7 days: how far back every tab looks.
class _RangePicker extends ConsumerWidget {
  const _RangePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(statsRangeProvider);
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Gap.lg,
          vertical: Gap.sm,
        ),
        child: Semantics(
          label: l10n.statsRangeLabel,
          child: SegmentedButton<StatsRange>(
            key: const Key('stats-range'),
            showSelectedIcon: false,
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
            segments: [
              ButtonSegment(
                value: StatsRange.allTime,
                label: Text(l10n.statsRangeAllTime),
              ),
              ButtonSegment(
                value: StatsRange.days30,
                label: Text(l10n.statsRange30Days),
              ),
              ButtonSegment(
                value: StatsRange.days7,
                label: Text(l10n.statsRange7Days),
              ),
            ],
            selected: {range},
            onSelectionChanged: (picked) =>
                ref.read(statsRangeProvider.notifier).set(picked.first),
          ),
        ),
      ),
    );
  }
}
