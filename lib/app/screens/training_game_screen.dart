/// [TrainingGameScreen], where every training drill is played.
///
/// {@category App}
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/checkout/checkout_search.dart';
import '../../domain/segment.dart';
import '../../domain/training/aim_target.dart';
import '../../domain/training/bobs_27.dart';
import '../../domain/training/checkout_attempt.dart';
import '../../domain/training/free_practice_state.dart';
import '../../domain/training/weak_spot.dart';
import '../../domain/x01/leg_state.dart';
import '../../domain/x01/thrown_dart.dart';
import '../../l10n/app_localizations.dart';
import '../l10n_extensions.dart';
import '../labels.dart';
import '../lights/lights_providers.dart';
import '../providers.dart';
import '../theme.dart';
import '../training_controller.dart';
import '../widgets/aim_strip.dart';
import '../widgets/checkout_card.dart';
import '../widgets/dart_keypad.dart';
import '../widgets/game_layout.dart';
import '../widgets/outcome_panel.dart';
import '../widgets/scoreboard.dart';
import '../widgets/turn_ledger.dart';

/// Throw darts and see what happened, whichever drill is running. Nothing
/// shown here is ever written to the database;
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

    // Keeps the sound and the board lights alive while this screen is up.
    ref.watch(trainingSoundControllerProvider);
    ref.watch(trainingLightsProvider);

    final darts = session.darts;

    // The leg being thrown at a checkout right now, in the drills that have
    // one, and whether its route may be shown yet.
    final (LegState? checkoutLeg, bool showRoute) = switch (session) {
      CheckoutPracticeSession(:final leg) => (
        leg.isFinished ? null : leg,
        true,
      ),
      CheckoutChallengeSession(:final state) => (
        state.current?.leg,
        state.config.showRoute,
      ),
      Ladder121Session(:final state) => (state.current?.leg, true),
      _ => (null, false),
    };

    final routes = switch (checkoutLeg) {
      final leg? =>
        ref
            .watch(checkoutTableProvider(leg.config.outRule))
            .routesFor(leg.currentRemaining, leg.dartsLeftThisTurn),
      null => const <CheckoutRoute>[],
    };

    final aim = switch (session) {
      Bobs27Session(:final state) => state.currentTarget,
      WeakSpotSession(:final state) => state.currentTarget,
      _ => null,
    };

    final keypad = DartKeypad(
      onDart: (segment) => controller.addDart(ThrownDart(segment)),
      onMiss: () => controller.addDart(const ThrownDart.miss()),
      highlight: aim != null
          ? _bedsOf(aim)
          : routes.isEmpty || !showRoute
          ? const {}
          : routes.first.darts.toSet(),
    );

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        // No leave confirmation: nothing here is saved, so nothing is lost.
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
            CheckoutChallengeSession() => l10n.checkoutChallengeLabel,
            Ladder121Session() => l10n.ladder121Label,
            Bobs27Session() => l10n.bobs27Label,
            WeakSpotSession() => l10n.weakSpotLabel,
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
            CheckoutChallengeSession(:final state) => _attemptLayout(
              context,
              hero: hero,
              current: state.current,
              last: state.lastCompleted,
              showRoute: state.config.showRoute,
              routes: routes,
              keypad: keypad,
              figures: [
                _remainingSeat(
                  l10n,
                  state.current,
                  caption: l10n.roundOfRounds(state.round, state.config.rounds),
                  tally: l10n.hitsOfAttempts(
                    state.checkouts,
                    state.completed.length,
                  ),
                  tallyLit: state.checkouts > 0,
                ),
                SeatView(
                  tally: _lastAttemptLine(
                    l10n,
                    state.current,
                    state.lastCompleted,
                  ),
                  tallyLit: state.lastCompleted?.succeeded ?? false,
                  name: state.config.isAdaptive
                      ? l10n.levelLabel
                      : l10n.hitRateLabel.toUpperCase(),
                  label: state.config.isAdaptive
                      ? '${state.nextBand.min}–${state.nextBand.max}'
                      : rateText(state.successRate),
                  caption: state.config.isAdaptive
                      ? rateText(state.successRate)
                      : null,
                  live: false,
                  won: false,
                ),
              ],
              outcome: state.isFinished
                  ? OutcomePanel(
                      eyebrow: l10n.sessionCompleteLabel,
                      headline: rateText(state.successRate),
                      detail: l10n.checkoutChallengeSummary(
                        state.checkouts,
                        state.completed.length,
                      ),
                      footer: [
                        if (state.highestCheckout case final best?)
                          l10n.highestFinishDetail(best),
                        if (state.dartsPerCheckout case final per?)
                          l10n.dartsPerCheckoutDetail(per.toStringAsFixed(1)),
                      ].join(' · '),
                      primary: _again(l10n, controller),
                      secondary: _done(l10n, context),
                    )
                  : null,
            ),
            Ladder121Session(:final state) => _attemptLayout(
              context,
              hero: hero,
              current: state.current,
              last: state.lastCompleted,
              showRoute: true,
              routes: routes,
              keypad: keypad,
              figures: [
                _remainingSeat(
                  l10n,
                  state.current,
                  caption: state.current == null
                      ? l10n.roundOfRounds(state.round, state.config.rounds)
                      : l10n.visitsLeftCount(state.current!.visitsLeft),
                  tally: l10n.hitsOfAttempts(
                    state.successes,
                    state.completed.length,
                  ),
                  tallyLit: state.successes > 0,
                ),
                SeatView(
                  tally: _lastAttemptLine(
                    l10n,
                    state.current,
                    state.lastCompleted,
                  ),
                  tallyLit: state.lastCompleted?.succeeded ?? false,
                  name: l10n.rungLabel,
                  count: state.target,
                  caption: l10n.roundOfRounds(state.round, state.config.rounds),
                  live: false,
                  won: false,
                ),
              ],
              outcome: state.isFinished
                  ? OutcomePanel(
                      eyebrow: l10n.sessionCompleteLabel,
                      headline: '${state.highestFinished ?? '—'}',
                      detail: switch (state.highestFinished) {
                        final rung? => l10n.ladderSummary(rung),
                        null => l10n.ladderNoFinish,
                      },
                      footer: l10n.hitsOfAttempts(
                        state.successes,
                        state.completed.length,
                      ),
                      primary: _again(l10n, controller),
                      secondary: _done(l10n, context),
                    )
                  : null,
            ),
            Bobs27Session(:final state) => GameLayout(
              scoreboard: (expand) => Scoreboard(
                seats: [
                  SeatView(
                    name: l10n.scoreLabel,
                    count: state.score,
                    caption: l10n.roundOfRounds(
                      state.visits.length + (state.isFinished ? 0 : 1),
                      bobs27Targets.length,
                    ),
                    live: !state.isFinished,
                    won: state.passed,
                  ),
                  SeatView(
                    name: l10n.hitRateLabel.toUpperCase(),
                    label: rateText(state.hitRate),
                    live: false,
                    won: false,
                  ),
                ],
                hero: hero,
                expand: expand,
              ),
              ledger: _bobsLedger(state),
              aim: switch (state.currentTarget) {
                final target? => _aimStrip(
                  context,
                  target,
                  state.dartsLeftThisVisit,
                  hero,
                ),
                null => null,
              },
              keypad: keypad,
              outcome: state.isFinished
                  ? OutcomePanel(
                      eyebrow: state.passed
                          ? l10n.bobs27PassedLabel
                          : l10n.bobs27OutLabel,
                      headline: '${state.score}',
                      detail: l10n.bobs27Detail(
                        state.visits.last.target.label,
                        rateText(state.hitRate),
                      ),
                      primary: _again(l10n, controller),
                      secondary: _done(l10n, context),
                    )
                  : null,
            ),
            WeakSpotSession(:final state) => GameLayout(
              scoreboard: (expand) => Scoreboard(
                seats: [
                  SeatView(
                    name: l10n.targetLabel.toUpperCase(),
                    label: state.currentTarget?.label ?? '—',
                    caption: l10n.roundOfRounds(
                      state.round,
                      state.config.rounds,
                    ),
                    tally: switch (state.currentTarget) {
                      final target? when state.config.history[target] != null =>
                        l10n.weakSpotHistoryRate(
                          hitRateText(
                            state.config.history[target]!.hits,
                            state.config.history[target]!.attempts,
                          ),
                        ),
                      _ => null,
                    },
                    live: !state.isFinished,
                    won: false,
                  ),
                  SeatView(
                    name: l10n.hitRateLabel.toUpperCase(),
                    label: rateText(state.hitRate),
                    live: false,
                    won: false,
                  ),
                ],
                hero: hero,
                expand: expand,
              ),
              ledger: TurnLedger(
                darts: state.currentVisitDarts,
                total:
                    '${_hitsOn(state.currentTarget, state.currentVisitDarts)}',
              ),
              aim: switch (state.currentTarget) {
                final target? => _aimStrip(
                  context,
                  target,
                  state.dartsLeftThisVisit,
                  hero,
                ),
                null => null,
              },
              keypad: keypad,
              outcome: state.isFinished
                  ? OutcomePanel(
                      eyebrow: l10n.sessionCompleteLabel,
                      headline: rateText(state.hitRate),
                      detail: l10n.weakSpotSummary(rateText(state.hitRate)),
                      footer: [
                        for (final result in state.weakest())
                          _weakSpotLine(context, result),
                      ].join('\n'),
                      primary: _again(l10n, controller),
                      secondary: _done(l10n, context),
                    )
                  : null,
            ),
          },
        ),
      ),
    );
  }

  static PanelAction _again(
    AppLocalizations l10n,
    TrainingController controller,
  ) => (
    label: l10n.throwAgainButton,
    onPressed: controller.throwAgain,
    key: const Key('throw-again-button'),
  );

  static PanelAction _done(AppLocalizations l10n, BuildContext context) => (
    label: l10n.doneButton,
    onPressed: () => Navigator.of(context).pop(),
    key: const Key('training-done-button'),
  );

  /// The points still needed in a checkout drill's attempt.
  static SeatView _remainingSeat(
    AppLocalizations l10n,
    CheckoutAttempt? current, {
    required String caption,
    required String tally,
    required bool tallyLit,
  }) => SeatView(
    name: l10n.remainingLabel,
    count: current?.remaining,
    label: current == null ? '—' : null,
    caption: caption,
    tally: tally,
    tallyLit: tallyLit,
    live: current != null,
    won: false,
  );

  /// Checkout Challenge and the 121 Ladder: a run of checkout attempts.
  ///
  /// Between attempts - straight after one ends - the ledger keeps the last
  /// attempt's final visit up, struck through when it failed, until the next
  /// dart lands; [_lastAttemptLine] says how it went.
  static Widget _attemptLayout(
    BuildContext context, {
    required bool hero,
    required CheckoutAttempt? current,
    required CheckoutAttempt? last,
    required bool showRoute,
    required List<CheckoutRoute> routes,
    required Widget keypad,
    required List<SeatView> figures,
    required Widget? outcome,
  }) {
    final l10n = context.l10n;
    final finished = _betweenAttempts(current, last) ? last : null;

    final TurnLedger ledger;
    if (finished != null) {
      final turn = finished.leg.turns.last;
      ledger = TurnLedger(
        darts: turn.darts,
        total: '${_sum(turn.darts)}',
        struck: !finished.succeeded,
      );
    } else if (current != null) {
      ledger = _ledger(current.leg);
    } else {
      ledger = const TurnLedger(darts: [], total: '0');
    }

    final Widget? aim;
    if (current == null) {
      aim = null;
    } else if (showRoute) {
      aim = CheckoutCard(
        routes: routes,
        remaining: current.remaining,
        dartsLeft: current.leg.dartsLeftThisTurn,
        hero: hero,
      );
    } else {
      // The route stays hidden while throwing; after a miss, this is where
      // it is revealed.
      final missed = finished != null && !finished.succeeded ? finished : null;
      final best = missed == null
          ? null
          : findCheckouts(
              missed.target,
              3,
              limit: 1,
              outRule: missed.leg.config.outRule,
            ).firstOrNull;
      aim = AimStrip(
        label: l10n.remainingLabel,
        target: '${current.remaining}',
        dartsLeft: current.leg.dartsLeftThisTurn,
        alternatives: best == null
            ? l10n.routeAfterVisitHint
            : l10n.bestRouteWas('${missed!.target}: $best'),
        hero: hero,
        chips: const [],
      );
    }

    return GameLayout(
      scoreboard: (expand) =>
          Scoreboard(seats: figures, hero: hero, expand: expand),
      ledger: ledger,
      aim: aim,
      keypad: keypad,
      outcome: outcome,
    );
  }

  /// How the attempt that just ended went, shown until the next dart
  /// lands. Null mid-attempt.
  static String? _lastAttemptLine(
    AppLocalizations l10n,
    CheckoutAttempt? current,
    CheckoutAttempt? last,
  ) {
    if (!_betweenAttempts(current, last)) return null;
    return last!.succeeded
        ? l10n.lastAttemptCheckedOut(last.target)
        : l10n.lastAttemptMissed(last.target);
  }

  /// Whether an attempt has just ended and the next has no dart in it yet.
  static bool _betweenAttempts(
    CheckoutAttempt? current,
    CheckoutAttempt? last,
  ) => last != null && (current == null || current.dartsUsed == 0);

  /// One target to hit: Bob's 27 and the Weak-spot Trainer.
  static Widget _aimStrip(
    BuildContext context,
    AimTarget target,
    int dartsLeft,
    bool hero,
  ) {
    final bed = _bedsOf(target).first;
    return AimStrip(
      label: context.l10n.aimLabel,
      target: target.label,
      dartsLeft: dartsLeft,
      hero: hero,
      chips: [
        SegmentChip(label: target.label, ring: bed.ring, lit: true, hero: hero),
      ],
    );
  }

  /// Every bed that counts as hitting [target].
  static Set<Segment> _bedsOf(AimTarget target) =>
      Segment.all.where(target.isHitBy).toSet();

  static int _hitsOn(AimTarget? target, List<ThrownDart> darts) =>
      target == null
      ? 0
      : darts.where((dart) => target.isHitBy(dart.segment)).length;

  /// Bob's 27's visit in progress, or the one just finished until the next
  /// dart lands - struck through when it was a blank.
  static TurnLedger _bobsLedger(Bobs27State state) {
    if (state.currentVisitDarts.isEmpty && state.visits.isNotEmpty) {
      final visit = state.visits.last;
      return TurnLedger(
        darts: visit.darts,
        total: '${visit.scored > 0 ? '+' : ''}${visit.scored}',
        struck: visit.hits == 0,
      );
    }
    return TurnLedger(
      darts: state.currentVisitDarts,
      total: '${_hitsOn(state.currentTarget, state.currentVisitDarts)}',
    );
  }

  static String _weakSpotLine(BuildContext context, WeakSpotResult result) {
    final l10n = context.l10n;
    final session = result.session;
    return switch (result.usualMiss) {
      final miss? => l10n.weakSpotResultLine(
        result.target.label,
        session.hits,
        session.attempts,
        missDirectionLabel(context, miss),
      ),
      null => l10n.weakSpotResultClean(
        result.target.label,
        session.hits,
        session.attempts,
      ),
    };
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
