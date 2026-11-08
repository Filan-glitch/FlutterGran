/// [MainMenuScreen], the front door: new game, resume, players, statistics,
/// rules and settings, plus the update card.
///
/// {@category App}
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/game_mode.dart';
import '../l10n_extensions.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import '../update/update_controller.dart';
import '../widgets/board_connection_button.dart';
import '../widgets/chalk_mark.dart';
import '../widgets/update_card.dart';
import 'atc_game_screen.dart';
import 'bulling_game_screen.dart';
import 'game_screen.dart';
import 'higher_lower_game_screen.dart';
import 'roster_screen.dart';
import 'rules_screen.dart';
import 'select_game_mode_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'training_setup_screen.dart';

/// The app's front door; every other screen hangs off an action here.
///
/// Actions are ordered by how often a returning player wants them: resume an
/// open leg, play, training (the other place darts get thrown), rules,
/// statistics, roster (mostly a once-per-guest chore), settings.
class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  /// Loads a stored leg back up and hands off to the right game screen.
  ///
  /// Each mode's config must be set before its log is resumed: the
  /// controller's `build` watches the config provider and rebuilds to an
  /// empty leg whenever it changes.
  Future<void> _resume(
    BuildContext context,
    WidgetRef ref,
    ResumableLeg resumable,
  ) async {
    switch (resumable) {
      case ResumableX01Leg(:final gameId):
        final repository = ref.read(gameRepositoryProvider);
        final config = await repository.loadConfig(gameId);
        if (config == null || !context.mounted) return;
        final darts = await repository.loadLog(gameId);
        if (!context.mounted) return;

        await ref.read(matchProvider.notifier).resumeFrom(gameId);
        if (!context.mounted) return;

        ref.read(gameConfigProvider.notifier).update(config);
        ref.read(currentGameIdProvider.notifier).set(gameId);
        ref.read(gameProvider.notifier).resume(config, darts);

        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (context) => const GameScreen()),
        );
      case ResumableAtcLeg(:final gameId):
        final repository = ref.read(gameRepositoryProvider);
        final config = await repository.loadAtcConfig(gameId);
        if (config == null || !context.mounted) return;
        final darts = await repository.loadLog(gameId);
        if (!context.mounted) return;

        ref.read(atcConfigProvider.notifier).update(config);
        ref.read(currentGameIdProvider.notifier).set(gameId);
        ref.read(atcGameProvider.notifier).resume(config, darts);

        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (context) => const AtcGameScreen()),
        );
      case ResumableBullingLeg(:final gameId):
        final repository = ref.read(gameRepositoryProvider);
        final config = await repository.loadBullingConfig(gameId);
        if (config == null || !context.mounted) return;
        final darts = await repository.loadLog(gameId);
        if (!context.mounted) return;

        ref.read(bullingConfigProvider.notifier).update(config);
        ref.read(currentGameIdProvider.notifier).set(gameId);
        ref.read(bullingGameProvider.notifier).resume(config, darts);

        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const BullingGameScreen(),
          ),
        );
      case ResumableHigherLowerLeg(:final gameId):
        final repository = ref.read(gameRepositoryProvider);
        final config = await repository.loadHigherLowerConfig(gameId);
        if (config == null || !context.mounted) return;
        final darts = await repository.loadLog(gameId);
        if (!context.mounted) return;

        ref.read(higherLowerConfigProvider.notifier).update(config);
        ref.read(currentGameIdProvider.notifier).set(gameId);
        ref.read(higherLowerGameProvider.notifier).resume(config, darts);

        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const HigherLowerGameScreen(),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // Only offered once it has actually been left - while it is open the
    // game screen owns it, and offering to resume what is already on screen
    // is nonsense.
    final currentGameId = ref.watch(currentGameIdProvider);
    final resumableLeg = ref.watch(resumableLegProvider).value;
    final resumable = resumableLeg?.gameId == currentGameId
        ? null
        : resumableLeg;

    final hero = isHeroDevice(context);

    // Each piece is built once; the phone and hero layouts only arrange them.
    // Stagger indexes follow reading order in both.
    final header = _BrandHeader(large: hero);

    // A release is news, a leg in progress is already known, so the update
    // card goes above the resume card where they share a column.
    final update =
        ref.watch(updateProvider).release != null &&
            !ref.watch(updateCardDismissedProvider)
        ? UpdateCard(
            compact: true,
            onDismiss: ref.read(updateCardDismissedProvider.notifier).dismiss,
          )
        : null;

    final resume = resumable == null
        ? null
        : StaggeredEntry(
            index: 0,
            child: _ResumeBanner(
              resumable: resumable,
              names: ref.watch(playerNamesProvider),
              onResume: () => _resume(context, ref, resumable),
            ),
          );

    final play = StaggeredEntry(
      index: 1,
      child: SizedBox(
        height: hero ? 72 : 56,
        child: FilledButton(
          key: const Key('menu-play-button'),
          onPressed: () => _open(context, const SelectGameModeScreen()),
          child: Text(l10n.playButton),
        ),
      ),
    );

    final rows = [
      for (final (index, (key, icon, label, screen)) in [
        (
          'menu-training-row',
          Icons.fitness_center,
          l10n.trainingMenuLabel,
          const TrainingSetupScreen(),
        ),
        (
          'menu-rules-row',
          Icons.help_outline,
          l10n.rulesMenuLabel,
          const RulesScreen(),
        ),
        (
          'menu-statistics-row',
          Icons.insights,
          l10n.statisticsMenuLabel,
          const StatsScreen(),
        ),
        (
          'menu-roster-row',
          Icons.people_outline,
          l10n.rosterMenuLabel,
          const RosterScreen(),
        ),
        (
          'menu-settings-row',
          Icons.settings_outlined,
          l10n.settingsMenuLabel,
          const SettingsScreen(),
        ),
      ].indexed)
        StaggeredEntry(
          index: 2 + index,
          child: _MenuRow(
            key: Key(key),
            icon: icon,
            label: label,
            large: hero,
            onTap: () => _open(context, screen),
          ),
        ),
    ];

    const padding = EdgeInsets.all(Gap.lg);
    final Widget body;
    if (hero) {
      // Brand and PLAY on the left, everything else on the right: on a
      // tablet or desktop window one phone-width column would leave most of
      // the screen empty and push the rows below PLAY out of easy reach.
      body = CenteredContent(
        maxWidth: _heroMenuWidth,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: _FullHeightScrollView(
                padding: padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const SizedBox(height: Gap.xxl),
                    if (resume != null) ...[
                      resume,
                      const SizedBox(height: Gap.xl),
                    ],
                    play,
                  ],
                ),
              ),
            ),
            const SizedBox(width: Gap.xl),
            Expanded(
              flex: 4,
              child: _FullHeightScrollView(
                padding: padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (update != null) ...[
                      update,
                      const SizedBox(height: Gap.xl),
                    ],
                    ...rows,
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      body = CenteredContent(
        child: _FullHeightScrollView(
          padding: padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              const SizedBox(height: Gap.xxl),
              if (update != null) ...[update, const SizedBox(height: Gap.xl)],
              if (resume != null) ...[resume, const SizedBox(height: Gap.xl)],
              play,
              const SizedBox(height: Gap.xl),
              ...rows,
            ],
          ),
        ),
      );
    }

    return Scaffold(
      // No title and, as the root route, no back button: only the board
      // light, in the same corner as on every other screen, so the board can
      // be connected before a mode is even picked.
      appBar: AppBar(
        actions: const [BoardConnectionButton(key: Key('menu-board-button'))],
      ),
      body: SafeArea(top: false, child: body),
    );
  }

  Future<void> _open(BuildContext context, Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (context) => screen));
}

/// How wide the hero menu's two panes may get together, before
/// [CenteredContent] scales it up for a desktop.
const double _heroMenuWidth = 1100;

/// The tally mark and the app's name, at the top of the menu. The mark is the
/// one the splash screen drew; it flies here under [chalkMarkHeroTag].
class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.large});

  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Hero(
          tag: chalkMarkHeroTag,
          child: ChalkMark(size: large ? 96 : 56),
        ),
        const SizedBox(height: Gap.md),
        ChalkWordmark(fontSize: large ? 15 : 13),
      ],
    );
  }
}

/// Scrolls the menu, with [child] at least as tall as the viewport so the
/// column can centre itself when it fits: it only scrolls on a phone on its
/// side, or with the update and resume cards both up on a short screen.
class _FullHeightScrollView extends StatelessWidget {
  const _FullHeightScrollView({required this.padding, required this.child});

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: math.max(0, constraints.maxHeight - padding.vertical),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// One plain action beneath PLAY. Deliberately quieter than a `FilledButton`
/// - Play is the one action every visit ends with, everything below it is a
/// detour on the way there.
class _MenuRow extends StatelessWidget {
  const _MenuRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.large = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Roomier, for the hero layout, where the rows have a pane to themselves.
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Palette.edge),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Gap.lg,
              vertical: large ? Gap.lg : Gap.md,
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Palette.chalkDim),
                const SizedBox(width: Gap.md),
                Text(
                  label.toUpperCase(),
                  style: Type.eyebrow.copyWith(color: Palette.chalk),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Palette.chalkDim,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Offers the leg that was left unfinished - the only place one is offered.
///
/// Shows the scores rather than just a button, so the leg can be recognised
/// before committing to it. The card is shared by every mode; only the format
/// eyebrow and the per-player figures switch on the kind of [resumable].
class _ResumeBanner extends StatelessWidget {
  const _ResumeBanner({
    required this.resumable,
    required this.names,
    required this.onResume,
  });

  final ResumableLeg resumable;
  final Map<int, String> names;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final resumable = this.resumable;
    final (format, playerIds, currentPlayerId, figures) = switch (resumable) {
      ResumableX01Leg(:final leg) => (
        '${gameModeName(GameMode.x01)} · ${leg.config.startScore}',
        leg.config.playerIds,
        leg.currentPlayerId,
        <int, String>{
          for (final id in leg.config.playerIds) id: '${leg.remaining[id]}',
        },
      ),
      ResumableAtcLeg(:final leg) => (
        '${gameModeName(GameMode.aroundTheClock)} · '
            '${atcVariantLabel(context, leg.config.variant)}',
        leg.config.playerIds,
        leg.currentPlayerId,
        <int, String>{
          for (final id in leg.config.playerIds)
            id: leg.currentStopFor(id).label,
        },
      ),
      ResumableBullingLeg(:final leg) => (
        '${gameModeName(GameMode.bulling)} · '
            '${bullseyeValueLabel(context, leg.config.bullseyeValue)} · '
            '${leg.config.target}',
        leg.config.playerIds,
        leg.currentPlayerId,
        <int, String>{
          for (final id in leg.config.playerIds) id: '${leg.scoreFor(id)}',
        },
      ),
      ResumableHigherLowerLeg(:final leg) => (
        '${gameModeName(GameMode.higherLower)} · ${leg.higher} · ${leg.lower}',
        leg.config.playerIds,
        leg.currentPlayerId,
        <int, String>{
          for (final id in leg.config.playerIds)
            id: leg.isOut(id)
                ? l10n.eliminatedLabel
                : '${leg.turnsSurvivedBy(id)}',
        },
      ),
    };

    return Material(
      color: Palette.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Palette.live),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const Key('menu-resume-banner'),
        onTap: onResume,
        child: Padding(
          padding: const EdgeInsets.all(Gap.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Pulse(
                    min: 0.75,
                    child: Text(
                      l10n.legInProgressLabel,
                      style: Type.eyebrow.copyWith(color: Palette.live),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      format,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Type.eyebrow.copyWith(color: Palette.chalkDim),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final playerId in playerIds) ...[
                    if (playerId != playerIds.first)
                      const SizedBox(width: Gap.lg),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nameFor(context, names, playerId).toUpperCase(),
                          style: Type.eyebrow.copyWith(
                            color: playerId == currentPlayerId
                                ? Palette.live
                                : Palette.chalkDim,
                          ),
                        ),
                        const SizedBox(height: Gap.xs),
                        Text(
                          figures[playerId]!,
                          style: Type.scoreSmall.copyWith(
                            color: playerId == currentPlayerId
                                ? Palette.chalk
                                : Palette.chalkDim,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Spacer(),
                  Text(
                    l10n.resumeLabel,
                    style: Type.eyebrow.copyWith(color: Palette.live),
                  ),
                  const SizedBox(width: Gap.xs),
                  const Icon(Icons.play_arrow, color: Palette.live, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
