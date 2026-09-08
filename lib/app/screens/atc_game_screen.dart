import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/atc/atc_config.dart';
import '../../domain/atc/atc_leg_state.dart';
import '../../domain/atc/atc_stop.dart';
import '../../domain/segment.dart';
import '../../domain/x01/leg_state.dart' show dartsPerTurn;
import '../../domain/x01/thrown_dart.dart';
import '../atc_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/dart_keypad.dart';
import 'atc_setup_screen.dart' show atcVariantLabel;
import 'game_screen.dart' show nameFor;

/// Plays a leg of Around the Clock.
///
/// Mirrors `GameScreen`'s shape: a scoreboard, a turn ledger, and whichever
/// of the keypad / turn-confirm / leg-won panel the moment calls for. This
/// mode has no match wrapping yet, so there is no `_MatchWon` equivalent -
/// a leg won here just offers another leg under the same config.
class AtcGameScreen extends ConsumerWidget {
  const AtcGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(atcGameProvider);
    final controller = ref.read(atcGameProvider.notifier);
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

  /// Starts a fresh leg under the same config, persisted as its own row -
  /// the mode-agnostic equivalent of what `matchProvider.notifier.rematch`
  /// does for x01, done directly since this mode has no match controller.
  Future<void> _playAgain(WidgetRef ref, AtcConfig config) async {
    final gameId = await ref.read(gameRepositoryProvider).startAtcGame(config);
    ref.read(currentGameIdProvider.notifier).set(gameId);
    ref.read(atcGameProvider.notifier).restart(config);
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
    AtcSession session,
    AtcController controller,
    Map<int, String> names,
    AtcLegState leg,
  ) {
    final connectionState = ref.watch(boardConnectionProvider).value;
    final boardConnected = connectionState?.isConnected ?? false;
    final manualOverride = ref.watch(keypadOverrideProvider);
    final keypadVisible = !boardConnected || manualOverride;

    final highlight = leg.isFinished || session.awaitingTurnConfirm
        ? const <Segment>{}
        : {
            for (final segment in Segment.all)
              if (leg
                  .currentStopFor(leg.currentPlayerId)
                  .clears(segment, leg.config.variant))
                segment,
          };

    return Scaffold(
      appBar: AppBar(
        title: Text(atcVariantLabel(leg.config.variant)),
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
          key: const Key('atc-game-body'),
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
                              onMiss: () => controller.addDart(
                                const ThrownDart.miss(),
                              ),
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

/// Players side by side, the stop still needed in place of a remaining
/// score - the same "only the thrower is lit" idiom `game_screen.dart`'s
/// `_PlayerColumn` uses.
class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.leg, required this.names});

  final AtcLegState leg;
  final Map<int, String> names;

  @override
  Widget build(BuildContext context) {
    final players = leg.config.playerIds;

    return Padding(
      key: const Key('atc-scoreboard'),
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
                  stop: leg.currentStopFor(players[seat]),
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
    required this.stop,
    required this.live,
    required this.won,
  });

  final String name;
  final AtcStop stop;
  final bool live;
  final bool won;

  @override
  Widget build(BuildContext context) {
    final accent = won ? Palette.trebleBed : Palette.live;
    final lit = live || won;

    return Column(
      children: [
        Container(
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: Gap.lg),
          color: lit ? accent : Colors.transparent,
        ),
        const SizedBox(height: Gap.md),
        Text(
          name.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Type.eyebrow.copyWith(color: lit ? accent : Palette.chalkDim),
        ),
        const SizedBox(height: Gap.sm),
        Expanded(
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                stop.label,
                style: (stop.label.length > 2 ? Type.scoreSmall : Type.score)
                    .copyWith(color: lit ? Palette.chalk : Palette.chalkDim),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The turn in progress, dart by dart - the same idiom `game_screen.dart`'s
/// `_TurnLedger` uses, minus the bust strikethrough this mode has no use for.
class _TurnLedger extends StatelessWidget {
  const _TurnLedger({required this.session, required this.names});

  final AtcSession session;
  final Map<int, String> names;

  @override
  Widget build(BuildContext context) {
    final pending = session.pendingTurn;
    final darts = pending?.darts ?? session.leg.currentTurnDarts;
    final cleared = pending?.stopsCleared ?? 0;

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
              cleared == 0 ? '·' : '+$cleared',
              textAlign: TextAlign.right,
              style: Type.scoreSmall.copyWith(
                color: cleared == 0 ? Palette.chalkDim : Palette.live,
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

/// Held after every turn, in place of the keypad - the same reasoning as
/// `game_screen.dart`'s `_TurnConfirm`: taking the keys away makes a stray
/// tap impossible while darts are being pulled out of the board.
class _TurnConfirm extends StatelessWidget {
  const _TurnConfirm({
    required this.turn,
    required this.leg,
    required this.names,
    required this.onConfirm,
    required this.onUndo,
  });

  final AtcTurn turn;
  final AtcLegState leg;
  final Map<int, String> names;
  final VoidCallback onConfirm;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final dartsThrown = turn.darts.map((dart) => dart.label).join('  ·  ');

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Gap.xl),
        child: Column(
          children: [
            const SizedBox(height: Gap.xl),
            Text(
              nameFor(names, turn.playerId).toUpperCase(),
              style: Type.eyebrow.copyWith(color: Palette.chalkDim),
            ),
            const SizedBox(height: Gap.md),
            Text(
              turn.stopsCleared == 0
                  ? 'NOTHING CLEARED'
                  : turn.stopsCleared == 1
                  ? '1 STOP CLEARED'
                  : '${turn.stopsCleared} STOPS CLEARED',
              style: Type.score.copyWith(color: Palette.chalk),
            ),
            const SizedBox(height: Gap.sm),
            Text(
              'now on ${AtcStop.track[turn.stopAfter.clamp(0, AtcStop.track.length - 1)].label}',
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
    );
  }
}

/// The end of a leg. No match to fold in - v1 has none - so this simply
/// offers another leg under the same config.
class _LegWon extends StatelessWidget {
  const _LegWon({
    required this.leg,
    required this.names,
    required this.onPlayAgain,
  });

  final AtcLegState leg;
  final Map<int, String> names;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final winner = leg.winnerId!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.xl, Gap.xl, Gap.lg),
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
              '${leg.dartsThrownBy(winner)} darts',
              style: Type.label.copyWith(color: Palette.chalkDim),
            ),
            const SizedBox(height: Gap.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('atc-play-again'),
                onPressed: onPlayAgain,
                child: const Text('PLAY AGAIN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
