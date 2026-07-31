import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/checkout/checkout_search.dart';
import '../../domain/x01/leg_state.dart';
import '../../domain/x01/thrown_dart.dart';
import '../game_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/dart_keypad.dart';

/// Falls back to a seat label for a player who has since been deleted.
String nameFor(Map<int, String> names, int playerId) =>
    names[playerId] ?? 'Player $playerId';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameProvider);
    final controller = ref.read(gameProvider.notifier);
    final names = ref.watch(playerNamesProvider);
    final leg = session.leg;

    final routes = leg.isFinished || session.awaitingTurnConfirm
        ? const <CheckoutRoute>[]
        : ref
              .watch(checkoutTableProvider)
              .routesFor(leg.currentRemaining, leg.dartsLeftThisTurn);

    return Scaffold(
      appBar: AppBar(
        title: Text('${leg.config.startScore} · DOUBLE OUT'),
        actions: [
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
          children: [
            _Scoreboard(leg: leg, names: names),
            const Divider(),
            _TurnLedger(session: session, names: names),
            const Divider(),
            if (session.awaitingTurnConfirm)
              Expanded(
                child: _TurnConfirm(
                  turn: session.pendingTurn!,
                  leg: leg,
                  names: names,
                  onConfirm: controller.confirmTurn,
                  onUndo: controller.undo,
                ),
              )
            else if (leg.isFinished)
              Expanded(child: _WinnerPanel(leg: leg, names: names))
            else ...[
              _CheckoutStrip(routes: routes),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Gap.md,
                    Gap.sm,
                    Gap.md,
                    Gap.md,
                  ),
                  child: DartKeypad(
                    onDart: (segment) =>
                        controller.addDart(ThrownDart(segment)),
                    onMiss: () => controller.addDart(const ThrownDart.miss()),
                    highlight: routes.isEmpty
                        ? const {}
                        : routes.first.darts.toSet(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Players side by side, split by a hairline, as on a chalk scoreboard.
///
/// Only the player at the oche is lit: their column carries the amber rule and
/// chalk-white numerals, everyone else recedes. At throwing distance that is
/// the fastest way to answer "whose turn, and what do they need".
class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.leg, required this.names});

  final LegState leg;
  final Map<int, String> names;

  @override
  Widget build(BuildContext context) {
    final players = leg.config.playerIds;

    return Padding(
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
                  remaining: leg.remaining[players[seat]]!,
                  average: leg.averageFor(players[seat]),
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
    required this.remaining,
    required this.average,
    required this.live,
    required this.won,
  });

  final String name;
  final int remaining;
  final double? average;
  final bool live;
  final bool won;

  @override
  Widget build(BuildContext context) {
    final accent = won ? Palette.trebleBed : Palette.oche;
    final lit = live || won;

    return Column(
      children: [
        // The rule above the name is the only thing marking the throw. It is
        // three pixels tall and it is enough, because nothing else is amber.
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
          style: Type.eyebrow.copyWith(
            color: lit ? accent : Palette.chalkDim,
          ),
        ),
        const SizedBox(height: Gap.sm),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$remaining',
            style: Type.score.copyWith(
              color: lit ? Palette.chalk : Palette.chalkDim,
            ),
          ),
        ),
        const SizedBox(height: Gap.xs),
        Text(
          average == null ? '—' : average!.toStringAsFixed(1),
          style: Type.label.copyWith(color: Palette.chalkDim),
        ),
      ],
    );
  }
}

/// The turn in progress, written out dart by dart with a running total.
///
/// This is the chalk line a scorer keeps beside the board: three marks and what
/// they add up to. When a turn busts the marks are struck through in red, which
/// is exactly how it is scored on a board, and is legible at a glance from the
/// oche in a way that a word never is.
class _TurnLedger extends StatelessWidget {
  const _TurnLedger({required this.session, required this.names});

  final GameSession session;
  final Map<int, String> names;

  @override
  Widget build(BuildContext context) {
    final pending = session.pendingTurn;
    final darts = pending?.darts ?? session.leg.currentTurnDarts;
    final busted = pending?.busted ?? false;
    final total =
        pending?.scored ??
        darts.fold<int>(0, (sum, dart) => sum + dart.value);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Gap.md,
        vertical: Gap.md,
      ),
      child: Row(
        children: [
          for (var i = 0; i < dartsPerTurn; i++) ...[
            if (i > 0) const SizedBox(width: Gap.sm),
            Expanded(
              child: _DartSlot(
                dart: i < darts.length ? darts[i] : null,
                struck: busted,
              ),
            ),
          ],
          const SizedBox(width: Gap.lg),
          SizedBox(
            width: 72,
            child: Text(
              busted ? 'BUST' : '$total',
              textAlign: TextAlign.right,
              style: busted
                  ? Type.notation.copyWith(color: Palette.doubleBed)
                  : Type.scoreSmall.copyWith(
                      color: darts.isEmpty ? Palette.chalkDim : Palette.oche,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DartSlot extends StatelessWidget {
  const _DartSlot({required this.dart, required this.struck});

  final ThrownDart? dart;
  final bool struck;

  @override
  Widget build(BuildContext context) {
    final empty = dart == null;

    return Container(
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: empty ? Palette.sunk : Palette.raised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Palette.edge),
      ),
      child: Text(
        empty ? '·' : dart!.label,
        style: Type.notation.copyWith(
          color: empty
              ? Palette.chalkDim
              : struck
              ? Palette.doubleBed
              : Palette.chalk,
          decoration: struck ? TextDecoration.lineThrough : null,
          decorationColor: Palette.doubleBed,
          decorationThickness: 2,
        ),
      ),
    );
  }
}

/// What to throw, when there is something on.
class _CheckoutStrip extends StatelessWidget {
  const _CheckoutStrip({required this.routes});

  final List<CheckoutRoute> routes;

  @override
  Widget build(BuildContext context) {
    if (routes.isEmpty) {
      return const SizedBox(height: Gap.sm);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('CHECKOUT', style: Type.eyebrow.copyWith(color: Palette.oche)),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Text(
              routes.first.toString(),
              style: Type.notation.copyWith(
                color: Palette.oche,
                fontSize: 22,
              ),
            ),
          ),
          if (routes.length > 1)
            Flexible(
              child: Text(
                routes.skip(1).join('   '),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Type.label.copyWith(color: Palette.chalkDim),
              ),
            ),
        ],
      ),
    );
  }
}

/// Held after every turn, in place of the keypad rather than over it.
///
/// Taking the keys away is the point: it makes a stray tap impossible while
/// darts are being pulled out of the board, which is when they happen.
class _TurnConfirm extends StatelessWidget {
  const _TurnConfirm({
    required this.turn,
    required this.leg,
    required this.names,
    required this.onConfirm,
    required this.onUndo,
  });

  final Turn turn;
  final LegState leg;
  final Map<int, String> names;
  final VoidCallback onConfirm;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        children: [
          const Spacer(),
          Text(
            nameFor(names, turn.playerId).toUpperCase(),
            style: Type.eyebrow.copyWith(color: Palette.chalkDim),
          ),
          const SizedBox(height: Gap.md),
          Text(
            turn.busted ? 'BUST' : '${turn.scored}',
            style: Type.score.copyWith(
              color: turn.busted ? Palette.doubleBed : Palette.chalk,
            ),
          ),
          const SizedBox(height: Gap.sm),
          Text(
            '${turn.scoreBefore} → ${turn.scoreAfter}',
            style: Type.label.copyWith(color: Palette.chalkDim),
          ),
          const Spacer(),
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
    );
  }
}

class _WinnerPanel extends StatelessWidget {
  const _WinnerPanel({required this.leg, required this.names});

  final LegState leg;
  final Map<int, String> names;

  @override
  Widget build(BuildContext context) {
    final winner = leg.winnerId!;

    return Padding(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            '${leg.dartsThrownBy(winner)} darts · '
            '${leg.averageFor(winner)?.toStringAsFixed(1) ?? '—'} average',
            style: Type.label.copyWith(color: Palette.chalkDim),
          ),
        ],
      ),
    );
  }
}
