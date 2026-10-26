import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/game_mode.dart';
import '../../domain/higher_lower/higher_lower_config.dart';
import '../../domain/higher_lower/higher_lower_leg_state.dart';
import '../../domain/x01/thrown_dart.dart';
import '../../l10n/app_localizations.dart';
import '../l10n_extensions.dart';
import '../lights/lights_providers.dart';
import '../providers.dart';
import '../widgets/bounds_card.dart';
import '../widgets/dart_keypad.dart';
import '../widgets/game_layout.dart';
import '../widgets/game_over_card.dart';
import '../widgets/scoreboard.dart';
import '../widgets/turn_ledger.dart';
import '../widgets/turn_result.dart';

/// Plays a leg of Higher/Lower.
///
/// The same arrangement as every other game (see [GameLayout]). The two
/// values to beat sit where the checkout card would, in a [BoundsCard]; the
/// scoreboard counts turns survived, and a player who is out says so in
/// place of a figure. Like Bulling, a leg won is the game over, and offers
/// another leg with the same players.
class HigherLowerGameScreen extends ConsumerWidget {
  const HigherLowerGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(higherLowerGameProvider);
    // Nothing is read from either: watching keeps the board's lights and the
    // sound following this game, and stops them when the screen goes.
    ref.watch(higherLowerLightsProvider);
    ref.watch(higherLowerSoundControllerProvider);
    final controller = ref.read(higherLowerGameProvider.notifier);
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
          title: gameModeRegistry
              .firstWhere((mode) => mode.id == GameMode.higherLower)
              .displayName,
          onUndo: leg.darts.isEmpty ? null : controller.undo,
        ),
        body: SafeArea(
          child: GameLayout(
            scoreboard: (expand) => Scoreboard(
              key: const Key('higher-lower-scoreboard'),
              seats: [
                for (final id in config.playerIds)
                  leg.isOut(id)
                      ? SeatView(
                          name: nameFor(context, names, id),
                          label: l10n.eliminatedLabel,
                          live: false,
                          won: false,
                        )
                      : SeatView(
                          name: nameFor(context, names, id),
                          count: leg.turnsSurvivedBy(id),
                          caption: l10n.survivedCaption,
                          live: id == leg.currentPlayerId && !leg.isFinished,
                          won: leg.winnerId == id,
                        ),
              ],
              hero: hero,
              expand: expand,
            ),
            ledger: TurnLedger(
              darts: pending?.darts ?? leg.currentTurnDarts,
              total: '${pending?.total ?? leg.runningTotal}',
            ),
            aim: playing
                ? BoundsCard(
                    higher: leg.higher,
                    lower: leg.lower,
                    runningTotal: leg.runningTotal,
                    dartsLeft: leg.dartsLeftThisTurn,
                    hero: hero,
                  )
                : null,
            keypad: DartKeypad(
              onDart: (segment) => controller.addDart(ThrownDart(segment)),
              onMiss: () => controller.addDart(const ThrownDart.miss()),
            ),
            turnResult: pending == null
                ? null
                : TurnResultPanel(
                    name: nameFor(context, names, pending.playerId),
                    darts: pending.darts,
                    figure: '${pending.total}',
                    caption: _caption(l10n, pending),
                    busted: !pending.survived,
                    finishing: leg.isFinished,
                    onConfirm: controller.confirmTurn,
                    onUndo: controller.undo,
                  ),
            gameOver: leg.isFinished && pending == null
                ? GameOverCard(
                    eyebrow: l10n.lastStandingLabel,
                    winnerName: nameFor(context, names, leg.winnerId!),
                    columns: [
                      for (final id in config.playerIds)
                        _figures(l10n, nameFor(context, names, id), leg, id),
                    ],
                    primary: (
                      label: l10n.playAgainButton,
                      onPressed: () => _playAgain(ref, config),
                      key: const Key('higher-lower-play-again'),
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

  /// Starts a fresh leg with the same players, persisted as its own row -
  /// the same thing `BullingGameScreen` does for its own mode.
  Future<void> _playAgain(WidgetRef ref, HigherLowerConfig config) async {
    final gameId = await ref
        .read(gameRepositoryProvider)
        .startHigherLowerGame(config);
    ref.read(currentGameIdProvider.notifier).set(gameId);
    ref.read(higherLowerGameProvider.notifier).restart(config);
  }

  /// What the turn did to the values, or why it put its thrower out.
  static String _caption(AppLocalizations l10n, HigherLowerTurn turn) =>
      switch (turn.outcome) {
        HigherLowerOutcome.higher => l10n.higherArrow(
          turn.higherBefore,
          turn.total,
        ),
        HigherLowerOutcome.lower => l10n.lowerArrow(
          turn.lowerBefore,
          turn.total,
        ),
        HigherLowerOutcome.missed => l10n.missedOut,
        HigherLowerOutcome.between => l10n.betweenOut(
          turn.higherBefore,
          turn.lowerBefore,
        ),
      };

  static FigureColumn _figures(
    AppLocalizations l10n,
    String name,
    HigherLowerLegState leg,
    int playerId,
  ) {
    return (
      name: name,
      won: leg.winnerId == playerId,
      figures: [
        (label: l10n.figureTurns, value: '${leg.turnsSurvivedBy(playerId)}'),
        (label: l10n.statDarts, value: '${leg.dartsThrownBy(playerId)}'),
      ],
    );
  }
}
