import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/bulling/bulling_config.dart';
import '../../domain/bulling/bulling_leg_state.dart';
import '../../domain/bulling/bulling_reducer.dart' show pointsFor;
import '../../domain/segment.dart';
import '../../domain/stats/player_stats.dart';
import '../../domain/x01/thrown_dart.dart';
import '../../l10n/app_localizations.dart';
import '../l10n_extensions.dart';
import '../lights/lights_providers.dart';
import '../providers.dart';
import '../widgets/dart_keypad.dart';
import '../widgets/game_layout.dart';
import '../widgets/game_over_card.dart';
import '../widgets/scoreboard.dart';
import '../widgets/turn_ledger.dart';
import '../widgets/turn_result.dart';
import 'bulling_setup_screen.dart' show bullseyeValueLabel;

/// Plays a leg of Bulling.
///
/// The same arrangement as every other game (see [GameLayout]): the running
/// score in place of a remaining one, with a rail filling towards the target.
/// There is no aim strip - the target never changes, and the keypad already
/// lights both bulls. Like Around the Clock, this mode has no match wrapping
/// yet, so a leg won is the game over, and offers another leg under the same
/// config.
class BullingGameScreen extends ConsumerWidget {
  const BullingGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(bullingGameProvider);
    // Nothing is read from it: watching keeps the board's lights following
    // this game, and turns them off when the screen goes.
    ref.watch(bullingLightsProvider);
    // Same idiom for sound: its own listener on the game does the rest.
    ref.watch(bullingSoundControllerProvider);
    final controller = ref.read(bullingGameProvider.notifier);
    final names = ref.watch(playerNamesProvider);
    final leg = session.leg;
    final config = leg.config;
    final l10n = context.l10n;
    final hero = isHeroDevice(context);

    final pending = session.pendingTurn;
    final playing = !leg.isFinished && pending == null;

    void leave() {
      controller.leave();
      ref.read(currentGameIdProvider.notifier).set(null);
    }

    return LeaveGuard(
      confirm: leg.darts.isNotEmpty && !leg.isFinished,
      onLeave: leave,
      child: Scaffold(
        appBar: GameAppBar(
          title:
              '${bullseyeValueLabel(context, config.bullseyeValue)} · '
              '${l10n.firstToTarget(config.target)}',
          onUndo: leg.darts.isEmpty ? null : controller.undo,
        ),
        body: SafeArea(
          child: GameLayout(
            scoreboard: (expand) => Scoreboard(
              key: const Key('bulling-scoreboard'),
              seats: [
                for (final id in config.playerIds)
                  SeatView(
                    name: nameFor(context, names, id),
                    count: leg.scoreFor(id),
                    progress: leg.scoreFor(id) / config.target,
                    caption: l10n.ofTarget(config.target),
                    live: id == leg.currentPlayerId && !leg.isFinished,
                    won: leg.winnerId == id,
                  ),
              ],
              hero: hero,
              expand: expand,
            ),
            ledger: TurnLedger(
              darts: pending?.darts ?? leg.currentTurnDarts,
              total: _gain(
                pending?.scored ??
                    leg.currentTurnDarts.fold<int>(
                      0,
                      (sum, dart) =>
                          sum + pointsFor(dart.segment, config.bullseyeValue),
                    ),
              ),
            ),
            // Both bull segments always score in this mode - there is no
            // per-player "current target" the way Around the Clock's track
            // has one, so the highlight never changes with whose turn it is.
            keypad: DartKeypad(
              onDart: (segment) => controller.addDart(ThrownDart(segment)),
              onMiss: () => controller.addDart(const ThrownDart.miss()),
              highlight: playing
                  ? {Segment.outerBull, Segment.innerBull}
                  : const {},
            ),
            turnResult: pending == null
                ? null
                : TurnResultPanel(
                    name: nameFor(context, names, pending.playerId),
                    darts: pending.darts,
                    figure: _gain(pending.scored),
                    caption: l10n.scoreArrow(
                      '${pending.scoreBefore}',
                      '${pending.scoreAfter}',
                    ),
                    finishing: leg.isFinished,
                    onConfirm: controller.confirmTurn,
                    onUndo: controller.undo,
                  ),
            gameOver: leg.isFinished && pending == null
                ? GameOverCard(
                    eyebrow: l10n.legWonLabel,
                    winnerName: nameFor(context, names, leg.winnerId!),
                    columns: [
                      for (final id in config.playerIds)
                        _figures(l10n, nameFor(context, names, id), leg, id),
                    ],
                    primary: (
                      label: l10n.playAgainButton,
                      onPressed: () => _playAgain(ref, config),
                      key: const Key('bulling-play-again'),
                    ),
                    onExit: () {
                      leave();
                      Navigator.of(context).pop();
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  /// Starts a fresh leg under the same config, persisted as its own row -
  /// the mode-agnostic equivalent of what `matchProvider.notifier.rematch`
  /// does for x01, done directly since this mode has no match controller.
  Future<void> _playAgain(WidgetRef ref, BullingConfig config) async {
    final gameId = await ref
        .read(gameRepositoryProvider)
        .startBullingGame(config);
    ref.read(currentGameIdProvider.notifier).set(gameId);
    ref.read(bullingGameProvider.notifier).restart(config);
  }

  /// Points scored, the way the ledger and the turn result both write them.
  static String _gain(int points) => points == 0 ? '0' : '+$points';

  static FigureColumn _figures(
    AppLocalizations l10n,
    String name,
    BullingLegState leg,
    int playerId,
  ) {
    final stats = computeBullingStats(playerId, [leg]);
    final hitRate = stats.dartsThrown == 0
        ? '—'
        : '${(stats.scoringDarts * 100 / stats.dartsThrown).round()}%';

    return (
      name: name,
      won: leg.winnerId == playerId,
      figures: [
        (label: l10n.figurePoints, value: '${leg.scoreFor(playerId)}'),
        (label: l10n.statDarts, value: '${stats.dartsThrown}'),
        (label: l10n.figureHitRate, value: hitRate),
      ],
    );
  }
}
