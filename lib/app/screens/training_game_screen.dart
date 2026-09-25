import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/checkout/checkout_search.dart';
import '../../domain/training/free_practice_state.dart';
import '../../domain/x01/leg_state.dart';
import '../../domain/x01/thrown_dart.dart';
import '../../l10n/app_localizations.dart';
import '../l10n_extensions.dart';
import '../lights/lights_providers.dart';
import '../providers.dart';
import '../training_controller.dart';
import '../widgets/checkout_card.dart';
import '../widgets/dart_keypad.dart';
import '../widgets/game_layout.dart';
import '../widgets/outcome_panel.dart';
import '../widgets/scoreboard.dart';
import '../widgets/turn_ledger.dart';

/// Throw darts and see what happened - free practice, or a chosen checkout
/// worked at on repeat. Nothing shown here is ever written to the database;
/// see [TrainingController] for the guarantee.
///
/// Played in the same arrangement as every game (see [GameLayout]), keypad
/// included, so a session works with or without a board. There is no turn
/// to confirm: nothing here is kept, so there is nothing to get wrong.
class TrainingGameScreen extends ConsumerWidget {
  const TrainingGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(trainingProvider);
    final controller = ref.read(trainingProvider.notifier);
    final hero = isHeroDevice(context);

    // Nothing is read from it - watching is what keeps the training sound
    // listener alive for as long as this screen is on, the same idiom
    // `soundControllerProvider` uses for a real leg.
    ref.watch(trainingSoundControllerProvider);
    ref.watch(trainingLightsProvider);

    final darts = switch (session) {
      FreePracticeSession(:final practice) => practice.darts,
      CheckoutPracticeSession(:final leg) => leg.darts,
    };

    final routes = switch (session) {
      CheckoutPracticeSession(:final leg) when !leg.isFinished =>
        ref
            .watch(checkoutTableProvider(leg.config.outRule))
            .routesFor(leg.currentRemaining, leg.dartsLeftThisTurn),
      _ => const <CheckoutRoute>[],
    };

    final keypad = DartKeypad(
      onDart: (segment) => controller.addDart(ThrownDart(segment)),
      onMiss: () => controller.addDart(const ThrownDart.miss()),
      highlight: routes.isEmpty ? const {} : routes.first.darts.toSet(),
    );

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        // There is nothing to confirm before leaving - unlike a real leg,
        // nothing here is saved, so there is nothing to lose that the player
        // was not already choosing to lose by leaving.
        if (!didPop) return;
        controller.leave();
        // A checkout just completed can still have a delayed "game shot"
        // queued behind its cue (`SoundTiming.afterCheckoutCue`). Leaving
        // the training session must not let that line speak into whatever
        // screen comes next.
        ref.read(soundPlayerProvider).silence();
      },
      child: Scaffold(
        appBar: GameAppBar(
          title: switch (session) {
            FreePracticeSession() => l10n.freePracticeLabel,
            CheckoutPracticeSession(:final startScore) =>
              l10n.checkoutPracticeWithScore(startScore),
          },
          onUndo: darts.isEmpty ? null : controller.undo,
        ),
        body: SafeArea(
          child: switch (session) {
            FreePracticeSession(:final practice) => GameLayout(
              scoreboard: (expand) => Scoreboard(
                seats: _freePracticeFigures(l10n, practice),
                hero: hero,
                expand: expand,
              ),
              ledger: TurnLedger(
                darts: practice.currentTurnDarts,
                total: '${_sum(practice.currentTurnDarts)}',
              ),
              keypad: keypad,
            ),
            CheckoutPracticeSession(:final leg, :final checkoutsCompleted) =>
              GameLayout(
                scoreboard: (expand) => Scoreboard(
                  seats: [
                    SeatView(
                      name: l10n.remainingLabel,
                      count: leg.currentRemaining,
                      caption: l10n.dartsCount(leg.darts.length),
                      tally: l10n.checkoutsThisSession(checkoutsCompleted),
                      tallyLit: checkoutsCompleted > 0,
                      live: !leg.isFinished,
                      won: leg.isFinished,
                    ),
                  ],
                  hero: hero,
                  expand: expand,
                ),
                ledger: _ledger(leg),
                aim: CheckoutCard(
                  routes: routes,
                  remaining: leg.currentRemaining,
                  dartsLeft: leg.dartsLeftThisTurn,
                  hero: hero,
                ),
                keypad: keypad,
                outcome: leg.isFinished
                    ? OutcomePanel(
                        eyebrow: l10n.checkedOutLabel,
                        headline: '${leg.config.startScore}',
                        detail: l10n.inDartsCount(leg.darts.length),
                        primary: (
                          label: l10n.throwAgainButton,
                          onPressed: controller.throwAgain,
                          key: const Key('throw-again-button'),
                        ),
                        secondary: (
                          label: l10n.doneButton,
                          onPressed: () => Navigator.of(context).pop(),
                          key: const Key('training-done-button'),
                        ),
                      )
                    : null,
              ),
          },
        ),
      ),
    );
  }

  /// Free practice has no leg to end and nobody to beat, so its "seats" are
  /// the session's own numbers - the average lit, as the one worth watching.
  static List<SeatView> _freePracticeFigures(
    AppLocalizations l10n,
    FreePracticeState practice,
  ) {
    final best = practice.bestTurn;
    return [
      SeatView(
        name: l10n.statAverage,
        label: practice.average?.toStringAsFixed(1) ?? '—',
        caption: l10n.dartsCount(practice.dartsThrown),
        live: true,
        won: false,
      ),
      SeatView(
        name: l10n.statBestTurn,
        count: best,
        label: best == null ? '—' : null,
        live: false,
        won: false,
      ),
      SeatView(
        name: l10n.figure180s,
        count: practice.oneEightyCount,
        live: false,
        won: false,
      ),
    ];
  }

  /// The turn in progress - or, straight after a bust, the turn that bust,
  /// struck through, until the next dart lands. With no turn to confirm,
  /// this is the only place a bust would ever show.
  static TurnLedger _ledger(LegState leg) {
    final lastTurn = leg.lastTurn;
    if (leg.currentTurnDarts.isEmpty && lastTurn != null && lastTurn.busted) {
      return TurnLedger(
        darts: lastTurn.darts,
        total: '${_sum(lastTurn.darts)}',
        struck: true,
      );
    }
    return TurnLedger(
      darts: leg.currentTurnDarts,
      total: '${_sum(leg.currentTurnDarts)}',
    );
  }

  static int _sum(List<ThrownDart> darts) =>
      darts.fold<int>(0, (sum, dart) => sum + dart.value);
}
