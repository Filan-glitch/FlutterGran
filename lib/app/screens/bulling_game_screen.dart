import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/bulling/bulling_config.dart';
import '../../domain/bulling/bulling_leg_state.dart';
import '../../domain/segment.dart';
import '../../domain/x01/leg_state.dart' show dartsPerTurn;
import '../../domain/x01/thrown_dart.dart';
import '../bulling_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/dart_keypad.dart';
import 'bulling_setup_screen.dart' show bullseyeValueLabel;
import 'game_screen.dart' show nameFor;

/// Plays a leg of Bulling.
///
/// Mirrors `AtcGameScreen`'s shape: a scoreboard, a turn ledger, and
/// whichever of the keypad / turn-confirm / leg-won panel the moment calls
/// for. Like Around the Clock, this mode has no match wrapping yet, so
/// there is no match-won equivalent — a leg won here just offers another
/// leg under the same config.
class BullingGameScreen extends ConsumerWidget {
  const BullingGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(bullingGameProvider);
    final controller = ref.read(bullingGameProvider.notifier);
    final names = ref.watch(playerNamesProvider);
    final leg = session.leg;

    final confirmBeforeLeaving = leg.darts.isNotEmpty && !leg.isFinished;

    return PopScope(
      canPop: !confirmBeforeLeaving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (!await _confirmLeave(context)) return;

        controller.leave();
        ref.read(currentGameIdProvider.notifier).set(null);
        if (context.mounted) Navigator.of(context).pop();
      },
      child: _build(context, ref, session, controller, names, leg),
    );
  }

  /// Starts a fresh leg under the same config, persisted as its own row —
  /// the mode-agnostic equivalent of what `matchProvider.notifier.rematch`
  /// does for x01, done directly since this mode has no match controller.
  Future<void> _playAgain(WidgetRef ref, BullingConfig config) async {
    final gameId = await ref
        .read(gameRepositoryProvider)
        .startBullingGame(config);
    ref.read(currentGameIdProvider.notifier).set(gameId);
    ref.read(bullingGameProvider.notifier).restart(config);
  }

  Future<bool> _confirmLeave(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave this leg?'),
        content: Text(
          'Your darts are saved. Resume from the main menu whenever '
          'you like.',
          style: Type.body.copyWith(color: Palette.chalkDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('STAY'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('LEAVE'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  Widget _build(
    BuildContext context,
    WidgetRef ref,
    BullingSession session,
    BullingController controller,
    Map<int, String> names,
    BullingLegState leg,
  ) {
    final connectionState = ref.watch(boardConnectionProvider).value;
    final boardConnected = connectionState?.isConnected ?? false;
    final manualOverride = ref.watch(keypadOverrideProvider);
    final keypadVisible = !boardConnected || manualOverride;

    // Both bull segments always score in this mode — there is no
    // per-player "current target" the way Around the Clock's track has
    // one, so the highlight never changes with whose turn it is.
    final highlight = leg.isFinished || session.awaitingTurnConfirm
        ? const <Segment>{}
        : {Segment.outerBull, Segment.innerBull};

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${bullseyeValueLabel(leg.config.bullseyeValue)} · '
          'FIRST TO ${leg.config.target}',
        ),
        actions: [
          if (boardConnected)
            IconButton(
              key: const Key('keypad-override-toggle'),
              onPressed: () =>
                  ref.read(keypadOverrideProvider.notifier).toggle(),
              icon: Icon(
                manualOverride ? Icons.videogame_asset : Icons.dialpad,
              ),
              tooltip: manualOverride
                  ? 'Hide manual entry'
                  : 'Enter a score by hand',
            ),
          IconButton(
            onPressed: leg.darts.isEmpty ? null : controller.undo,
            icon: const Icon(Icons.undo),
            tooltip: 'Undo last dart',
          ),
          const SizedBox(width: Gap.xs),
        ],
      ),
      body: SafeArea(
        child: Column(
          key: const Key('bulling-game-body'),
          children: [
            _Scoreboard(leg: leg, names: names),
            const Divider(),
            _TurnLedger(session: session, names: names),
            const Divider(),
            Expanded(
              child: session.awaitingTurnConfirm
                  ? _TurnConfirm(
                      turn: session.pendingTurn!,
                      leg: leg,
                      names: names,
                      onConfirm: controller.confirmTurn,
                      onUndo: controller.undo,
                    )
                  : leg.isFinished
                  ? _LegWon(
                      leg: leg,
                      names: names,
                      onPlayAgain: () => _playAgain(ref, leg.config),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Gap.md,
                        Gap.sm,
                        Gap.md,
                        Gap.md,
                      ),
                      child: keypadVisible
                          ? DartKeypad(
                              onDart: (segment) =>
                                  controller.addDart(ThrownDart(segment)),
                              onMiss: () =>
                                  controller.addDart(const ThrownDart.miss()),
                              highlight: highlight,
                            )
                          : const _BoardScoringAlone(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown in the keypad's place while a real board is scoring for itself.
class _BoardScoringAlone extends StatelessWidget {
  const _BoardScoringAlone();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'THROW WHEN READY',
        style: Type.eyebrow.copyWith(color: Palette.chalkDim),
      ),
    );
  }
}

/// Players side by side, the running score in place of a remaining score —
/// the same "only the thrower is lit" idiom `game_screen.dart`'s
/// `_PlayerColumn` and `atc_game_screen.dart`'s use.
class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.leg, required this.names});

  final BullingLegState leg;
  final Map<int, String> names;

  @override
  Widget build(BuildContext context) {
    final players = leg.config.playerIds;

    return Padding(
      key: const Key('bulling-scoreboard'),
      padding: const EdgeInsets.only(top: Gap.sm, bottom: Gap.lg),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var seat = 0; seat < players.length; seat++) ...[
              if (seat > 0) const VerticalDivider(width: 1),
              Expanded(
                child: _PlayerColumn(
                  name: nameFor(names, players[seat]),
                  score: leg.scoreFor(players[seat]),
                  target: leg.config.target,
                  live: players[seat] == leg.currentPlayerId && !leg.isFinished,
                  won: leg.winnerId == players[seat],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlayerColumn extends StatelessWidget {
  const _PlayerColumn({
    required this.name,
    required this.score,
    required this.target,
    required this.live,
    required this.won,
  });

  final String name;
  final int score;
  final int target;
  final bool live;
  final bool won;

  @override
  Widget build(BuildContext context) {
    final accent = won ? Palette.trebleBed : Palette.live;
    final lit = live || won;

    return Column(
      children: [
        AnimatedContainer(
          duration: Motion.scale(Motion.base),
          curve: Motion.enter,
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: Gap.lg),
          color: lit ? accent : Colors.transparent,
        ),
        const SizedBox(height: Gap.md),
        AnimatedDefaultTextStyle(
          duration: Motion.scale(Motion.base),
          curve: Motion.enter,
          style: Type.eyebrow.copyWith(color: lit ? accent : Palette.chalkDim),
          child: Text(
            name.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: Gap.sm),
        Expanded(
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.contain,
              child: AnimatedFigure(
                value: score,
                style: Type.score.copyWith(
                  color: lit ? Palette.chalk : Palette.chalkDim,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Gap.xs),
        Text('of $target', style: Type.label.copyWith(color: Palette.chalkDim)),
      ],
    );
  }
}

/// The turn in progress, dart by dart — the same idiom
/// `atc_game_screen.dart`'s `_TurnLedger` uses, minus the bust
/// strikethrough this mode has no use for.
class _TurnLedger extends StatelessWidget {
  const _TurnLedger({required this.session, required this.names});

  final BullingSession session;
  final Map<int, String> names;

  @override
  Widget build(BuildContext context) {
    final pending = session.pendingTurn;
    final darts = pending?.darts ?? session.leg.currentTurnDarts;
    final scored = pending?.scored ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.md),
      child: Row(
        children: [
          for (var i = 0; i < dartsPerTurn; i++) ...[
            if (i > 0) const SizedBox(width: Gap.sm),
            Expanded(
              child: _DartSlot(dart: i < darts.length ? darts[i] : null),
            ),
          ],
          const SizedBox(width: Gap.lg),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 72),
            child: Text(
              scored == 0 ? '·' : '+$scored',
              textAlign: TextAlign.right,
              style: Type.scoreSmall.copyWith(
                color: scored == 0 ? Palette.chalkDim : Palette.live,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DartSlot extends StatelessWidget {
  const _DartSlot({required this.dart});

  final ThrownDart? dart;

  @override
  Widget build(BuildContext context) {
    final empty = dart == null;

    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(vertical: Gap.xs),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: empty ? Palette.sunk : Palette.raised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Palette.edge),
      ),
      child: Text(
        empty ? '·' : dart!.label,
        style: Type.notation.copyWith(
          color: empty ? Palette.chalkDim : Palette.chalk,
        ),
      ),
    );
  }
}

/// Held after every turn, in place of the keypad — the same reasoning as
/// `atc_game_screen.dart`'s `_TurnConfirm`.
class _TurnConfirm extends StatelessWidget {
  const _TurnConfirm({
    required this.turn,
    required this.leg,
    required this.names,
    required this.onConfirm,
    required this.onUndo,
  });

  final BullingTurn turn;
  final BullingLegState leg;
  final Map<int, String> names;
  final VoidCallback onConfirm;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final dartsThrown = turn.darts.map((dart) => dart.label).join('  ·  ');

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Gap.xl),
        child: EntrancePop(
          child: Column(
            children: [
              const SizedBox(height: Gap.xl),
              Text(
                nameFor(names, turn.playerId).toUpperCase(),
                style: Type.eyebrow.copyWith(color: Palette.chalkDim),
              ),
              const SizedBox(height: Gap.md),
              Text(
                turn.scored == 0
                    ? 'NOTHING SCORED'
                    : turn.scored == 1
                    ? '1 POINT SCORED'
                    : '${turn.scored} POINTS SCORED',
                style: Type.score.copyWith(color: Palette.chalk),
              ),
              const SizedBox(height: Gap.sm),
              Text(
                'now on ${turn.scoreAfter}',
                style: Type.label.copyWith(color: Palette.chalkDim),
              ),
              if (dartsThrown.isNotEmpty) ...[
                const SizedBox(height: Gap.md),
                Text(
                  dartsThrown,
                  style: Type.label.copyWith(color: Palette.chalkDim),
                ),
              ],
              const SizedBox(height: Gap.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onUndo,
                      child: const Text('WRONG'),
                    ),
                  ),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: onConfirm,
                      child: Text(leg.isFinished ? 'FINISH' : 'NEXT PLAYER'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.md),
              Text(
                'or press the board button',
                style: Type.label.copyWith(color: Palette.chalkDim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The end of a leg. No match to fold in — v1 has none — so this simply
/// offers another leg under the same config.
class _LegWon extends StatelessWidget {
  const _LegWon({
    required this.leg,
    required this.names,
    required this.onPlayAgain,
  });

  final BullingLegState leg;
  final Map<int, String> names;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final winner = leg.winnerId!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.xl, Gap.xl, Gap.lg),
        child: EntrancePop(
          child: Column(
            children: [
              Text(
                'LEG WON',
                style: Type.eyebrow.copyWith(color: Palette.trebleBed),
              ),
              const SizedBox(height: Gap.md),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  nameFor(names, winner).toUpperCase(),
                  style: Type.score.copyWith(color: Palette.chalk),
                ),
              ),
              const SizedBox(height: Gap.lg),
              Text(
                '${leg.scoreFor(winner)} points · '
                '${leg.dartsThrownBy(winner)} darts',
                style: Type.label.copyWith(color: Palette.chalkDim),
              ),
              const SizedBox(height: Gap.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('bulling-play-again'),
                  onPressed: onPlayAgain,
                  child: const Text('PLAY AGAIN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
