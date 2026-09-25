import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/checkout/checkout_search.dart';
import '../../domain/stats/player_stats.dart';
import '../../domain/x01/leg_state.dart';
import '../../domain/x01/match_state.dart';
import '../../domain/x01/thrown_dart.dart';
import '../../domain/x01/x01_rules.dart';
import '../../l10n/app_localizations.dart';
import '../audio/sound_controller.dart' show maximumTurn;
import '../l10n_extensions.dart';
import '../lights/lights_providers.dart';
import '../providers.dart';
import '../widgets/checkout_card.dart';
import '../widgets/dart_keypad.dart';
import '../widgets/game_layout.dart';
import '../widgets/game_over_card.dart';
import '../widgets/outcome_panel.dart';
import '../widgets/scoreboard.dart';
import '../widgets/turn_ledger.dart';
import '../widgets/turn_result.dart';

/// The block of per-player figures on the match card.
const Key matchFiguresKey = Key('match-figures');

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameProvider);
    final controller = ref.read(gameProvider.notifier);
    final names = ref.watch(playerNamesProvider);
    final match = ref.watch(matchStateProvider);
    final leg = session.leg;
    final l10n = context.l10n;
    final hero = isHeroDevice(context);

    // Nothing is read from it. Watching is what keeps the sound controller
    // alive for as long as a leg is on screen, and its own listener on the game
    // does the rest - which is the point: this screen never asks for a sound.
    ref.watch(soundControllerProvider);
    // Same idiom for the board's lights, which also go dark when this leaves.
    ref.watch(x01LightsProvider);

    final routes = leg.isFinished || session.awaitingTurnConfirm
        ? const <CheckoutRoute>[]
        : ref
              .watch(checkoutTableProvider(leg.config.outRule))
              .routesFor(leg.currentRemaining, leg.dartsLeftThisTurn);

    // Only a real match says so. A best of one is the single leg the app has
    // always played, and labelling it would be noise.
    final format = match != null && match.config.isMultiLeg
        ? ' · ${match.config.formatLabel}'
        : '';

    final pending = session.pendingTurn;
    final ledgerDarts = pending?.darts ?? leg.currentTurnDarts;

    return LeaveGuard(
      confirm: leg.darts.isNotEmpty && !leg.isFinished,
      // Stop board input being scored into a leg nobody is watching, and stop
      // writing to it. The row itself is left alone, unfinished and ready to
      // resume.
      onLeave: () {
        controller.leave();
        ref.read(matchProvider.notifier).leave();
        ref.read(currentGameIdProvider.notifier).set(null);
      },
      child: Scaffold(
        appBar: GameAppBar(
          title:
              '${leg.config.startScore} · '
              '${leg.config.inRule.abbreviation}/'
              '${leg.config.outRule.abbreviation}$format',
          onUndo: leg.darts.isEmpty ? null : controller.undo,
        ),
        body: SafeArea(
          child: GameLayout(
            scoreboard: (expand) => Scoreboard(
              seats: _seats(context, leg, names, match),
              hero: hero,
              expand: expand,
            ),
            ledger: TurnLedger(
              darts: ledgerDarts,
              total:
                  '${pending?.scored ?? ledgerDarts.fold<int>(0, (sum, dart) => sum + dart.value)}',
              struck: pending?.busted ?? false,
            ),
            aim: CheckoutCard(
              routes: routes,
              remaining: leg.currentRemaining,
              dartsLeft: leg.dartsLeftThisTurn,
              hero: hero,
            ),
            keypad: DartKeypad(
              onDart: (segment) => controller.addDart(ThrownDart(segment)),
              onMiss: () => controller.addDart(const ThrownDart.miss()),
              highlight: routes.isEmpty ? const {} : routes.first.darts.toSet(),
            ),
            turnResult: pending == null
                ? null
                : TurnResultPanel(
                    name: nameFor(context, names, pending.playerId),
                    darts: pending.darts,
                    figure: pending.busted
                        ? l10n.bustLabel
                        : '${pending.scored}',
                    caption: l10n.scoreArrow(
                      '${pending.scoreBefore}',
                      '${pending.scoreAfter}',
                    ),
                    busted: pending.busted,
                    // The same total the spoken commentary already fanfares -
                    // one place decides what counts as the maximum, not two.
                    celebrate: !pending.busted && pending.scored == maximumTurn,
                    finishing: leg.isFinished,
                    onConfirm: controller.confirmTurn,
                    onUndo: controller.undo,
                  ),
            outcome: leg.isFinished
                ? _legWon(context, ref, l10n, leg, names, match)
                : null,
            gameOver: match != null && match.isFinished
                ? _MatchWon(match: match, names: names)
                : null,
          ),
        ),
      ),
    );
  }

  List<SeatView> _seats(
    BuildContext context,
    LegState leg,
    Map<int, String> names,
    MatchState? match,
  ) {
    final l10n = context.l10n;
    // A best of one has nothing to tally: the leg on screen is the whole
    // match, and a row of zeroes would only crowd the scores.
    final legsWon = match != null && match.config.isMultiLeg
        ? match.legsWon
        : null;

    return [
      for (final id in leg.config.playerIds)
        SeatView(
          name: nameFor(context, names, id),
          count: leg.remaining[id]!,
          caption: leg.averageFor(id)?.toStringAsFixed(1) ?? '—',
          heroCaption: switch (leg.averageFor(id)) {
            null => l10n.avgDash,
            final average => l10n.avgValue(average.toStringAsFixed(1)),
          },
          tally: legsWon == null ? null : l10n.legsCount(legsWon[id] ?? 0),
          tallyLit: (legsWon?[id] ?? 0) > 0,
          live: id == leg.currentPlayerId && !leg.isFinished,
          won: leg.winnerId == id,
        ),
    ];
  }

  /// The end of a leg, in the space the keypad has just given up.
  ///
  /// A leg inside a running match is a checkpoint rather than an ending, so
  /// this stays small and says only what the next thing to do is. The match
  /// ending is [_MatchWon]'s job, over the top of this one.
  Widget _legWon(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    LegState leg,
    Map<int, String> names,
    MatchState? match,
  ) {
    final winner = leg.winnerId!;
    final running = match != null && !match.isFinished;

    return OutcomePanel(
      eyebrow: l10n.legWonLabel,
      headline: nameFor(context, names, winner).toUpperCase(),
      detail: l10n.legWonStatsX01(
        leg.dartsThrownBy(winner),
        leg.averageFor(winner)?.toStringAsFixed(1) ?? '—',
      ),
      footer: running ? _standing(l10n, match) : null,
      primary: running
          ? (
              label: l10n.throwLegNumber(match.nextLegNumber + 1),
              onPressed: ref.read(matchProvider.notifier).startNextLeg,
              key: null,
            )
          : null,
    );
  }

  /// The tally and what is left of the match, on one line.
  ///
  /// Somebody has just won a leg, so there is always a tally to read and always
  /// something still to win - a match that had been decided would be showing
  /// [_MatchWon] instead.
  String _standing(AppLocalizations l10n, MatchState match) {
    final tally = [
      for (final id in match.config.playerIds) '${match.legsWon[id] ?? 0}',
    ].join(' – ');

    return l10n.standingLegsToWinIt(tally, match.legsToWinFrom);
  }
}

/// The end of the match, over the board it was won on.
///
/// Every figure here comes from [computeX01Stats] over this match's legs, so
/// a number shown at the end of a match is arrived at the same way as the same
/// number on the statistics screen - there is one implementation of what a
/// first-nine average is, and this is not a second one.
class _MatchWon extends ConsumerWidget {
  const _MatchWon({required this.match, required this.names});

  final MatchState match;
  final Map<int, String> names;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // The leg that ended it is still live rather than re-read: it was won a
    // frame ago, and its last dart may not have reached the database yet.
    final current = ref.watch(gameProvider).leg;
    final decided = ref.watch(decidedMatchLegsProvider);

    // Null until every leg of the match is in hand. The earlier legs are read
    // when this card mounts, so there is a frame or two before they arrive, and
    // a query that fails never arrives at all. Averaging the final leg on its
    // own would put a number under BEST LEG that nobody played to - a figure
    // that is wrong reads exactly like a figure that is right, so until they
    // are all here there is no figure.
    final legs = switch (decided) {
      AsyncData(:final value) => [...value, current],
      _ => null,
    };

    final winner = match.winnerId!;

    return GameOverCard(
      eyebrow: l10n.matchWonLabel,
      winnerName: nameFor(context, names, winner),
      subtitle: [
        for (final id in match.config.playerIds) '${match.legsWon[id] ?? 0}',
      ].join(' – '),
      figuresKey: matchFiguresKey,
      columns: [
        for (final id in match.config.playerIds)
          _figures(
            l10n,
            nameFor(context, names, id),
            legs == null ? null : computeX01Stats(id, legs),
            won: id == winner,
          ),
      ],
      error: decided.hasError ? l10n.earlierLegsCouldNotBeRead : null,
      primary: (
        label: l10n.rematchButton,
        onPressed: ref.read(matchProvider.notifier).rematch,
        key: null,
      ),
      onExit: () {
        // The same wind-down as leaving a leg, minus the question: there is
        // nothing unfinished left to keep.
        ref.read(gameProvider.notifier).leave();
        ref.read(matchProvider.notifier).leave();
        ref.read(currentGameIdProvider.notifier).set(null);
        Navigator.of(context).pop();
      },
    );
  }

  /// One player's match. Null [stats] while the match's legs are still being
  /// read, and if they cannot be.
  static FigureColumn _figures(
    AppLocalizations l10n,
    String name,
    X01Stats? stats, {
    required bool won,
  }) {
    String decimal(double? value) => value?.toStringAsFixed(1) ?? '—';
    String whole(int? value) => value?.toString() ?? '—';

    return (
      name: name,
      won: won,
      figures: [
        (label: l10n.figureAverage, value: decimal(stats?.average)),
        (label: l10n.figureFirstNine, value: decimal(stats?.firstNineAverage)),
        (label: l10n.figure180s, value: whole(stats?.turnsOf180)),
        (label: l10n.figureBestOut, value: whole(stats?.bestCheckout)),
        (label: l10n.figureBestLeg, value: whole(stats?.fewestDartsToWin)),
      ],
    );
  }
}
