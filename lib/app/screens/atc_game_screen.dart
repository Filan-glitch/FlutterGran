import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/atc/atc_config.dart';
import '../../domain/atc/atc_leg_state.dart';
import '../../domain/atc/atc_stop.dart';
import '../../domain/segment.dart';
import '../../domain/stats/player_stats.dart';
import '../../domain/x01/thrown_dart.dart';
import '../../l10n/app_localizations.dart';
import '../l10n_extensions.dart';
import '../lights/lights_providers.dart';
import '../providers.dart';
import '../widgets/aim_card.dart';
import '../widgets/dart_keypad.dart';
import '../widgets/game_layout.dart';
import '../widgets/game_over_card.dart';
import '../widgets/scoreboard.dart';
import '../widgets/turn_ledger.dart';
import '../widgets/turn_result.dart';
import 'atc_setup_screen.dart' show atcVariantLabel;

/// Plays a leg of Around the Clock.
///
/// The same arrangement as every other game (see [GameLayout]): the stop each
/// player still needs in place of a remaining score, the stop to hit next in
/// place of a checkout. This mode has no match wrapping yet, so a leg won is
/// the game over, and offers another leg under the same config.
class AtcGameScreen extends ConsumerWidget {
  const AtcGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(atcGameProvider);
    // Nothing is read from it: watching keeps the board's lights following
    // this game, and turns them off when the screen goes.
    ref.watch(atcLightsProvider);
    // Same idiom for sound: its own listener on the game does the rest.
    ref.watch(atcSoundControllerProvider);
    final controller = ref.read(atcGameProvider.notifier);
    final names = ref.watch(playerNamesProvider);
    final leg = session.leg;
    final l10n = context.l10n;
    final hero = isHeroDevice(context);
    final variantLabel = atcVariantLabel(context, leg.config.variant);

    final pending = session.pendingTurn;
    final playing = !leg.isFinished && pending == null;
    final stop = leg.currentStopFor(leg.currentPlayerId);

    void leave() {
      controller.leave();
      ref.read(currentGameIdProvider.notifier).set(null);
    }

    return LeaveGuard(
      confirm: leg.darts.isNotEmpty && !leg.isFinished,
      onLeave: leave,
      child: Scaffold(
        appBar: GameAppBar(
          title: variantLabel,
          onUndo: leg.darts.isEmpty ? null : controller.undo,
        ),
        body: SafeArea(
          child: GameLayout(
            scoreboard: (expand) => Scoreboard(
              key: const Key('atc-scoreboard'),
              seats: [
                for (final id in leg.config.playerIds)
                  SeatView(
                    name: nameFor(context, names, id),
                    label: leg.currentStopFor(id).label,
                    progress: leg.stopIndex[id]! / AtcStop.track.length,
                    ticks: AtcStop.track.length,
                    caption: l10n.dartsCount(leg.dartsThrownBy(id)),
                    live: id == leg.currentPlayerId && !leg.isFinished,
                    won: leg.winnerId == id,
                  ),
              ],
              hero: hero,
              expand: expand,
            ),
            ledger: TurnLedger(
              darts: pending?.darts ?? leg.currentTurnDarts,
              total: _gain(pending?.stopsCleared ?? _clearedThisTurn(leg)),
            ),
            aim: playing
                ? AimCard(
                    stop: stop,
                    variant: leg.config.variant,
                    dartsLeft: leg.dartsLeftThisTurn,
                    hero: hero,
                  )
                : null,
            keypad: DartKeypad(
              onDart: (segment) => controller.addDart(ThrownDart(segment)),
              onMiss: () => controller.addDart(const ThrownDart.miss()),
              highlight: playing
                  ? {
                      for (final segment in Segment.all)
                        if (stop.clears(segment, leg.config.variant)) segment,
                    }
                  : const {},
            ),
            turnResult: pending == null
                ? null
                : TurnResultPanel(
                    name: nameFor(context, names, pending.playerId),
                    darts: pending.darts,
                    figure: _gain(pending.stopsCleared),
                    caption: _movedOn(l10n, pending),
                    finishing: leg.isFinished,
                    onConfirm: controller.confirmTurn,
                    onUndo: controller.undo,
                  ),
            gameOver: leg.isFinished && pending == null
                ? GameOverCard(
                    eyebrow: l10n.legWonLabel,
                    winnerName: nameFor(context, names, leg.winnerId!),
                    columns: [
                      for (final id in leg.config.playerIds)
                        _figures(
                          l10n,
                          nameFor(context, names, id),
                          leg,
                          computeAtcStats(id, [leg]),
                          id,
                        ),
                    ],
                    primary: (
                      label: l10n.playAgainButton,
                      onPressed: () => _playAgain(ref, leg.config),
                      key: const Key('atc-play-again'),
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
  Future<void> _playAgain(WidgetRef ref, AtcConfig config) async {
    final gameId = await ref.read(gameRepositoryProvider).startAtcGame(config);
    ref.read(currentGameIdProvider.notifier).set(gameId);
    ref.read(atcGameProvider.notifier).restart(config);
  }

  /// Stops cleared, the way the ledger and the turn result both write them.
  static String _gain(int cleared) => cleared == 0 ? '0' : '+$cleared';

  /// Stops the thrower has cleared so far this turn: where they stand now,
  /// less where their last turn left them.
  static int _clearedThisTurn(AtcLegState leg) {
    final thrower = leg.currentPlayerId;
    final earlier = leg.turns.where((turn) => turn.playerId == thrower);
    final start = earlier.isEmpty ? 0 : earlier.last.stopAfter;
    return leg.stopIndex[thrower]! - start;
  }

  /// Where the turn took the thrower, stop to stop - or that it won the leg.
  static String _movedOn(AppLocalizations l10n, AtcTurn turn) {
    String label(int index) =>
        AtcStop.track[index.clamp(0, AtcStop.track.length - 1)].label;

    if (turn.stopAfter >= AtcStop.track.length) return l10n.legWonLabel;
    return l10n.scoreArrow(label(turn.stopBefore), label(turn.stopAfter));
  }

  static FigureColumn _figures(
    AppLocalizations l10n,
    String name,
    AtcLegState leg,
    AtcStats stats,
    int playerId,
  ) {
    final hitRate = stats.dartsThrown == 0
        ? '—'
        : '${(stats.qualifyingDarts * 100 / stats.dartsThrown).round()}%';

    return (
      name: name,
      won: leg.winnerId == playerId,
      figures: [
        (label: l10n.statDarts, value: '${stats.dartsThrown}'),
        (label: l10n.figureHitRate, value: hitRate),
        (label: l10n.figureReached, value: leg.currentStopFor(playerId).label),
      ],
    );
  }
}
