import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme.dart';
import 'game_screen.dart';
import 'roster_screen.dart';
import 'select_game_mode_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

/// The app's front door. Everything else hangs off one of the five actions
/// here, in the order a returning player actually wants them: pick a leg
/// back up if one is open, otherwise start a new one; statistics is a
/// routine visit so it outranks roster, which is mostly a once-per-guest
/// chore; settings is last because it is rarely touched at all.
class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  /// Loads a stored leg back up and hands off to [GameScreen].
  ///
  /// The same sequence the setup screen used to run before resuming moved
  /// here: the config has to land before the log, because
  /// `GameController.build` watches [gameConfigProvider] and rebuilds to an
  /// empty leg whenever it changes.
  Future<void> _resume(
    BuildContext context,
    WidgetRef ref,
    ResumableLeg resumable,
  ) async {
    final repository = ref.read(gameRepositoryProvider);
    final config = await repository.loadConfig(resumable.gameId);
    if (config == null || !context.mounted) return;
    final darts = await repository.loadLog(resumable.gameId);
    if (!context.mounted) return;

    await ref.read(matchProvider.notifier).resumeFrom(resumable.gameId);
    if (!context.mounted) return;

    ref.read(gameConfigProvider.notifier).update(config);
    ref.read(currentGameIdProvider.notifier).set(resumable.gameId);
    ref.read(gameProvider.notifier).resume(config, darts);

    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => const GameScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only offered once it has actually been left - while it is open the
    // game screen owns it, and offering to resume what is already on screen
    // is nonsense.
    final currentGameId = ref.watch(currentGameIdProvider);
    final resumableLeg = ref.watch(resumableLegProvider).value;
    final resumable = resumableLeg?.gameId == currentGameId
        ? null
        : resumableLeg;

    return Scaffold(
      body: SafeArea(
        child: CenteredContent(
          child: Padding(
            padding: const EdgeInsets.all(Gap.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'CHALK',
                  textAlign: TextAlign.center,
                  style: Type.eyebrow.copyWith(
                    color: Palette.chalkDim,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: Gap.xxl),
                if (resumable != null) ...[
                  _ResumeBanner(
                    resumable: resumable,
                    names: ref.watch(playerNamesProvider),
                    onResume: () => _resume(context, ref, resumable),
                  ),
                  const SizedBox(height: Gap.xl),
                ],
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    key: const Key('menu-play-button'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const SelectGameModeScreen(),
                      ),
                    ),
                    child: const Text('PLAY'),
                  ),
                ),
                const SizedBox(height: Gap.xl),
                _MenuRow(
                  key: const Key('menu-statistics-row'),
                  icon: Icons.insights,
                  label: 'Statistics',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const StatsScreen(),
                    ),
                  ),
                ),
                _MenuRow(
                  key: const Key('menu-roster-row'),
                  icon: Icons.people_outline,
                  label: 'Roster',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const RosterScreen(),
                    ),
                  ),
                ),
                _MenuRow(
                  key: const Key('menu-settings-row'),
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const SettingsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

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
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.lg,
              vertical: Gap.md,
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

/// Offers the leg that was left unfinished.
///
/// Moved here from the setup screen, which trimmed down to `X01SetupScreen`
/// and no longer makes this offer - the main menu is now the only place a
/// leg in progress gets surfaced. Shows the scores rather than just a
/// button, so the leg can be
/// recognised before committing to it - there is no point resuming the
/// wrong one.
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
    final leg = resumable.leg;

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
                  Text(
                    'LEG IN PROGRESS',
                    style: Type.eyebrow.copyWith(color: Palette.live),
                  ),
                  const Spacer(),
                  Text(
                    '${leg.config.startScore}',
                    style: Type.eyebrow.copyWith(color: Palette.chalkDim),
                  ),
                ],
              ),
              const SizedBox(height: Gap.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final playerId in leg.config.playerIds) ...[
                    if (playerId != leg.config.playerIds.first)
                      const SizedBox(width: Gap.lg),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nameFor(names, playerId).toUpperCase(),
                          style: Type.eyebrow.copyWith(
                            color: playerId == leg.currentPlayerId
                                ? Palette.live
                                : Palette.chalkDim,
                          ),
                        ),
                        const SizedBox(height: Gap.xs),
                        Text(
                          '${leg.remaining[playerId]}',
                          style: Type.scoreSmall.copyWith(
                            color: playerId == leg.currentPlayerId
                                ? Palette.chalk
                                : Palette.chalkDim,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Spacer(),
                  Text(
                    'RESUME',
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
