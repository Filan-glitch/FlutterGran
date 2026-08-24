import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/checkout/checkout_search.dart';
import '../../domain/stats/player_stats.dart';
import '../../domain/x01/leg_state.dart';
import '../../domain/x01/match_state.dart';
import '../../domain/x01/thrown_dart.dart';
import '../game_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/dart_keypad.dart';

/// The block of per-player figures on the match card.
const Key matchFiguresKey = Key('match-figures');

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

    // Nothing is read from it. Watching is what keeps the sound controller
    // alive for as long as a leg is on screen, and its own listener on the game
    // does the rest - which is the point: this screen never asks for a sound.
    ref.watch(soundControllerProvider);

    final routes = leg.isFinished || session.awaitingTurnConfirm
        ? const <CheckoutRoute>[]
        : ref
              .watch(checkoutTableProvider)
              .routesFor(leg.currentRemaining, leg.dartsLeftThisTurn);

    // A leg with darts in it is worth confirming before leaving; a fresh or
    // finished one is not, and gets out of the way with the platform's own
    // back gesture intact.
    final confirmBeforeLeaving = leg.darts.isNotEmpty && !leg.isFinished;

    return PopScope(
      canPop: !confirmBeforeLeaving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (!await _confirmLeave(context)) return;

        // Stop board input being scored into a leg nobody is watching, and
        // stop writing to it. The row itself is left alone, unfinished and
        // ready to resume.
        controller.leave();
        ref.read(matchProvider.notifier).leave();
        ref.read(currentGameIdProvider.notifier).set(null);
        if (context.mounted) Navigator.of(context).pop();
      },
      child: _build(context, ref, session, controller, names, leg, routes),
    );
  }

  /// Asks before leaving, and says plainly that nothing is being thrown away.
  ///
  /// This is a "we are keeping it" confirmation, not a warning. Telling someone
  /// they are about to lose a leg when they are not would teach them to fear
  /// the back button.
  Future<bool> _confirmLeave(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave this leg?'),
        content: Text(
          'Your darts are saved. Resume from the setup screen whenever '
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
    GameSession session,
    GameController controller,
    Map<int, String> names,
    LegState leg,
    List<CheckoutRoute> routes,
  ) {
    final match = ref.watch(matchStateProvider);

    // Only a real match says so. A best of one is the single leg the app has
    // always played, and labelling it would be noise.
    final format = match != null && match.config.isMultiLeg
        ? ' · ${match.config.formatLabel}'
        : '';

    // Shortest side, not the local width a LayoutBuilder would give: this is
    // "how big is the device", the same question typeScaleFor answers, and
    // the two are meant to move together - the device that earns bigger type
    // earns the hero layout with it.
    final hero = MediaQuery.sizeOf(context).shortestSide >= heroLayout;

    final connectionState = ref.watch(boardConnectionProvider).value;
    final boardConnected = connectionState?.isConnected ?? false;
    final manualOverride = ref.watch(keypadOverrideProvider);

    // The keypad is the fallback path: it disappears the moment a real board
    // can be trusted to score for itself, and comes back the moment someone
    // says otherwise, board present or not.
    final keypadVisible = !boardConnected || manualOverride;

    return Scaffold(
      appBar: AppBar(
        title: Text('${leg.config.startScore} · DOUBLE OUT$format'),
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
        // The match card is stacked over the board rather than pushed as a
        // route: a leg ends where it was played, and the scoreboard behind the
        // card is what makes it read as the end of a game instead of a
        // different screen.
        child: Stack(
          key: const Key('game-body'),
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                // Whatever is asking for a decision right now: the keypad, the
                // turn being confirmed, or the leg that has just ended. It is
                // the same widget either way round - only where it sits moves.
                final Widget play;
                if (hero && session.awaitingTurnConfirm) {
                  // The full-screen overlay below covers this slot entirely
                  // (or, if the match just ended too, `_MatchWon` does) - so
                  // there is nothing here worth spending a `_TurnConfirm`'s
                  // layout and paint on every frame it is invisible.
                  play = const SizedBox.shrink();
                } else if (session.awaitingTurnConfirm) {
                  play = _TurnConfirm(
                    turn: session.pendingTurn!,
                    leg: leg,
                    names: names,
                    onConfirm: controller.confirmTurn,
                    onUndo: controller.undo,
                  );
                } else if (leg.isFinished) {
                  play = _LegWon(
                    leg: leg,
                    names: names,
                    match: match,
                    onNextLeg: ref.read(matchProvider.notifier).startNextLeg,
                  );
                } else {
                  play = Column(
                    children: [
                      hero
                          ? _CheckoutPanel(routes: routes)
                          : _CheckoutStrip(routes: routes),
                      Expanded(
                        child: keypadVisible
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  Gap.md,
                                  Gap.sm,
                                  Gap.md,
                                  Gap.md,
                                ),
                                child: DartKeypad(
                                  onDart: (segment) => controller.addDart(
                                    ThrownDart(segment),
                                  ),
                                  onMiss: () => controller.addDart(
                                    const ThrownDart.miss(),
                                  ),
                                  highlight: routes.isEmpty
                                      ? const {}
                                      : routes.first.darts.toSet(),
                                ),
                              )
                            : const _BoardIsScoring(),
                      ),
                    ],
                  );
                }

                final board = [
                  _Scoreboard(leg: leg, names: names, match: match, hero: hero),
                  const Divider(),
                  _TurnLedger(session: session, names: names),
                ];

                // Side by side once there is width for it. Stacked, the score
                // and the keypad are both squeezed into a height neither has;
                // beside each other they each get a whole half and nothing has
                // to shrink - which is the point, because the size of the score
                // is what makes it readable from the oche.
                if (constraints.maxWidth >= wideLayout) {
                  return Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(children: board),
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: play),
                    ],
                  );
                }

                return Column(
                  children: [
                    ...board,
                    const Divider(),
                    Expanded(child: play),
                  ],
                );
              },
            ),
            // On the tablet a turn result is the whole screen, not a panel
            // sharing it - the score everyone was just watching goes away
            // for a moment, on purpose, for the number that came off the
            // board. Skipped when the match just ended too: `_MatchWon`
            // below takes over instead, and its own 95%-opaque card is
            // meant to show the scoreboard through it, not this.
            if (hero &&
                session.awaitingTurnConfirm &&
                !(match != null && match.isFinished))
              Positioned.fill(
                child: ColoredBox(
                  key: const Key('turn-result-overlay'),
                  color: Palette.ground,
                  child: _TurnConfirm(
                    turn: session.pendingTurn!,
                    leg: leg,
                    names: names,
                    onConfirm: controller.confirmTurn,
                    onUndo: controller.undo,
                  ),
                ),
              ),
            if (match != null && match.isFinished)
              Positioned.fill(
                child: _MatchWon(match: match, names: names),
              ),
          ],
        ),
      ),
    );
  }
}

/// Lays its child out at the height it is given, and scrolls it when that is
/// not enough.
///
/// The panels that end a turn or a leg are built around [Spacer]s, which need a
/// bounded height, and are also the first thing to overflow on a phone lying on
/// its side. This gives them the height when there is height, and a scroll when
/// there is not, rather than making them choose one for both cases.
class _FitOrScroll extends StatelessWidget {
  const _FitOrScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(child: child),
        ),
      ),
    );
  }
}

/// Players side by side, split by a hairline, as on a chalk scoreboard.
///
/// Only the player at the oche is lit: their column carries the pale rule and
/// chalk-white numerals, everyone else recedes. At throwing distance that is
/// the fastest way to answer "whose turn, and what do they need".
class _Scoreboard extends StatelessWidget {
  const _Scoreboard({
    required this.leg,
    required this.names,
    required this.match,
    required this.hero,
  });

  final LegState leg;
  final Map<int, String> names;

  /// The match behind the leg, or null when there is not one worth showing.
  final MatchState? match;

  /// Whether the device earns the per-player card treatment. See [heroLayout].
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final players = leg.config.playerIds;

    // A best of one has nothing to tally: the leg on screen is the whole
    // match, and a row of zeroes would only crowd the scores.
    final legsWon = match != null && match!.config.isMultiLeg
        ? match!.legsWon
        : null;

    if (hero) {
      return Padding(
        key: const Key('hero-scoreboard'),
        padding: const EdgeInsets.symmetric(
          horizontal: Gap.md,
          vertical: Gap.md,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var seat = 0; seat < players.length; seat++) ...[
                if (seat > 0) const SizedBox(width: Gap.md),
                Expanded(
                  child: _HeroPlayerCard(
                    name: nameFor(names, players[seat]),
                    remaining: leg.remaining[players[seat]]!,
                    average: leg.averageFor(players[seat]),
                    live:
                        players[seat] == leg.currentPlayerId &&
                        !leg.isFinished,
                    won: leg.winnerId == players[seat],
                    legsWon: legsWon?[players[seat]],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

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
                  legsWon: legsWon?[players[seat]],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A player's score as its own card, for a device far enough away to read as
/// a piece of furniture rather than a phone: real borders instead of a
/// hairline, room for the average and leg tally to sit beside the name rather
/// than stacked under the score.
///
/// Carries the same fields and the same "only the thrower is lit" rule as
/// [_PlayerColumn] - this is that idea with more room to say it in, not a
/// different one.
class _HeroPlayerCard extends StatelessWidget {
  const _HeroPlayerCard({
    required this.name,
    required this.remaining,
    required this.average,
    required this.live,
    required this.won,
    required this.legsWon,
  });

  final String name;
  final int remaining;
  final double? average;
  final bool live;
  final bool won;
  final int? legsWon;

  @override
  Widget build(BuildContext context) {
    final accent = won ? Palette.trebleBed : Palette.live;
    final lit = live || won;

    return Container(
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: lit ? Palette.raised : Palette.sunk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: lit ? accent : Palette.edge, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Type.title.copyWith(
                    color: lit ? Palette.chalk : Palette.chalkDim,
                  ),
                ),
              ),
              if (legsWon != null)
                Text(
                  'LEGS $legsWon',
                  // Chalk, not `accent`: this is a match tally, not this
                  // leg's live state, and `Palette.live` is spent only on
                  // state, per its own doc - the same rule `_PlayerColumn`
                  // follows for the identical figure.
                  style: Type.eyebrow.copyWith(
                    color: legsWon! > 0 ? Palette.chalk : Palette.chalkDim,
                  ),
                ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '$remaining',
              style: Type.score.copyWith(
                color: lit ? Palette.chalk : Palette.chalkDim,
              ),
            ),
          ),
          const SizedBox(height: Gap.xs),
          Text(
            average == null ? 'AVG —' : 'AVG ${average!.toStringAsFixed(1)}',
            style: Type.label.copyWith(color: Palette.chalkDim),
          ),
        ],
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
    required this.legsWon,
  });

  final String name;
  final int remaining;
  final double? average;
  final bool live;
  final bool won;

  /// Legs taken in the match so far, or null outside a multi-leg match.
  final int? legsWon;

  @override
  Widget build(BuildContext context) {
    final accent = won ? Palette.trebleBed : Palette.live;
    final lit = live || won;

    return Column(
      children: [
        // The rule above the name is the only thing marking the throw. It is
        // three pixels tall and it is enough, because nothing else on the
        // screen is this pale.
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
        // The leg tally sits under the average rather than beside the name:
        // it is what the match hangs on, but it is not what you look up to
        // check mid-turn, so it goes last.
        if (legsWon != null) ...[
          const SizedBox(height: Gap.sm),
          Text(
            'LEGS $legsWon',
            style: Type.eyebrow.copyWith(
              color: legsWon! > 0 ? Palette.chalk : Palette.chalkDim,
            ),
          ),
        ],
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
        pending?.scored ?? darts.fold<int>(0, (sum, dart) => sum + dart.value);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.md),
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
          ConstrainedBox(
            // Room for 180 at the current type size, and no more: the slots
            // beside it are what should take the rest of the row.
            constraints: const BoxConstraints(minWidth: 72),
            child: Text(
              busted ? 'BUST' : '$total',
              textAlign: TextAlign.right,
              style: busted
                  ? Type.notation.copyWith(color: Palette.doubleBed)
                  : Type.scoreSmall.copyWith(
                      color: darts.isEmpty ? Palette.chalkDim : Palette.live,
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
      // A floor rather than a height: the notation inside it grows with the
      // platform's text size and with the viewport, and a box that could not
      // follow it would clip the dart it is there to show.
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
          Text('CHECKOUT', style: Type.eyebrow.copyWith(color: Palette.live)),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Text(
              routes.first.toString(),
              style: Type.notation.copyWith(color: Palette.live, fontSize: 22),
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

/// What to throw, when there is something on - the tablet's own dedicated
/// panel rather than a strip sharing a line with everything else.
///
/// This is exactly the figure the whole hero pass is for: the thing a player
/// three metres from the screen, darts in hand, needs to read without walking
/// closer. The best route gets real size; the alternates get their own lines
/// underneath it rather than trailing off the edge of the screen.
class _CheckoutPanel extends StatelessWidget {
  const _CheckoutPanel({required this.routes});

  final List<CheckoutRoute> routes;

  @override
  Widget build(BuildContext context) {
    if (routes.isEmpty) {
      return const SizedBox(height: Gap.md);
    }

    final alternates = routes.skip(1);

    return Container(
      key: const Key('checkout-panel'),
      margin: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, 0),
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: Palette.raised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Palette.live, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CHECKOUT', style: Type.eyebrow.copyWith(color: Palette.live)),
          const SizedBox(height: Gap.sm),
          Text(
            routes.first.toString(),
            style: Type.notation.copyWith(color: Palette.live, fontSize: 34),
          ),
          for (final route in alternates)
            Padding(
              padding: const EdgeInsets.only(top: Gap.xs),
              child: Text(
                route.toString(),
                style: Type.label.copyWith(color: Palette.chalkDim),
              ),
            ),
        ],
      ),
    );
  }
}

/// Stands in for the keypad while a real board is trusted to score for
/// itself. Says where the keys went, so the toggle in the corner is
/// discoverable rather than a control nobody knew to look for.
class _BoardIsScoring extends StatelessWidget {
  const _BoardIsScoring();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bluetooth, color: Palette.chalkDim, size: 28),
            const SizedBox(height: Gap.md),
            Text(
              'BLUETOOTH IS SCORING',
              style: Type.eyebrow.copyWith(color: Palette.chalkDim),
            ),
            const SizedBox(height: Gap.sm),
            Text(
              'Use the corner button to key in a score by hand.',
              textAlign: TextAlign.center,
              style: Type.label.copyWith(color: Palette.chalkDim),
            ),
          ],
        ),
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
    return _FitOrScroll(
      child: Padding(
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
      ),
    );
  }
}

/// The end of a leg, in the space the keypad has just given up.
///
/// A leg inside a running match is a checkpoint rather than an ending, so this
/// stays small and says only what the next thing to do is. The match ending is
/// [_MatchWon]'s job, over the top of this one.
class _LegWon extends StatelessWidget {
  const _LegWon({
    required this.leg,
    required this.names,
    required this.match,
    required this.onNextLeg,
  });

  final LegState leg;
  final Map<int, String> names;

  /// The match this leg belonged to, or null for a leg played outside one -
  /// which is every leg the app stored before matches existed.
  final MatchState? match;

  final VoidCallback onNextLeg;

  @override
  Widget build(BuildContext context) {
    final winner = leg.winnerId!;
    final match = this.match;
    final running = match != null && !match.isFinished;

    return _FitOrScroll(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.xl, Gap.xl, Gap.lg),
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
            if (running) ...[
              const Spacer(),
              Text(
                _standing(match),
                style: Type.eyebrow.copyWith(color: Palette.chalkDim),
              ),
              const SizedBox(height: Gap.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onNextLeg,
                  child: Text('THROW LEG ${match.nextLegNumber + 1}'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// The tally and what is left of the match, on one line.
  ///
  /// Somebody has just won a leg, so there is always a tally to read and always
  /// something still to win - a match that had been decided would be showing
  /// [_MatchWon] instead.
  String _standing(MatchState match) {
    final tally = [
      for (final id in match.config.playerIds) '${match.legsWon[id] ?? 0}',
    ].join(' – ');

    final left = match.legsToWinFrom;
    return '$tally · $left ${left == 1 ? 'LEG' : 'LEGS'} TO WIN IT';
  }
}

/// The end of the match, over the board it was won on.
///
/// Every figure here comes from [computePlayerStats] over this match's legs, so
/// a number shown at the end of a match is arrived at the same way as the same
/// number on the statistics screen - there is one implementation of what a
/// first-nine average is, and this is not a second one.
class _MatchWon extends ConsumerWidget {
  const _MatchWon({required this.match, required this.names});

  final MatchState match;
  final Map<int, String> names;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final players = match.config.playerIds;
    final winner = match.winnerId!;

    return ColoredBox(
      // Not quite opaque: the scoreboard reads through it, which is what says
      // this happened here rather than somewhere else.
      color: Palette.ground.withValues(alpha: 0.95),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            children: [
              Text(
                'MATCH WON',
                style: Type.eyebrow.copyWith(color: Palette.live),
              ),
              const SizedBox(height: Gap.md),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  nameFor(names, winner).toUpperCase(),
                  style: Type.score.copyWith(color: Palette.chalk),
                ),
              ),
              const SizedBox(height: Gap.sm),
              Text(
                [
                  for (final id in players) '${match.legsWon[id] ?? 0}',
                ].join(' – '),
                style: Type.scoreSmall.copyWith(color: Palette.chalkDim),
              ),
              const SizedBox(height: Gap.xl),
              IntrinsicHeight(
                // Named so a test can ask what this block says without
                // catching the scoreboard showing the same numbers behind it.
                key: matchFiguresKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var seat = 0; seat < players.length; seat++) ...[
                      if (seat > 0) const VerticalDivider(width: 1),
                      Expanded(
                        child: _MatchFigures(
                          name: nameFor(names, players[seat]),
                          stats: legs == null
                              ? null
                              : computePlayerStats(players[seat], legs),
                          won: players[seat] == winner,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (decided.hasError) ...[
                const SizedBox(height: Gap.md),
                Text(
                  'THE EARLIER LEGS COULD NOT BE READ',
                  style: Type.eyebrow.copyWith(color: Palette.doubleBed),
                ),
              ],
              const SizedBox(height: Gap.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: ref.read(matchProvider.notifier).rematch,
                  child: const Text('REMATCH'),
                ),
              ),
              const SizedBox(height: Gap.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // The same wind-down as leaving a leg, minus the question:
                    // there is nothing unfinished left to keep.
                    ref.read(gameProvider.notifier).leave();
                    ref.read(matchProvider.notifier).leave();
                    ref.read(currentGameIdProvider.notifier).set(null);
                    Navigator.of(context).pop();
                  },
                  child: const Text('BACK TO SETUP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One player's match, as a column of figures under their name.
class _MatchFigures extends StatelessWidget {
  const _MatchFigures({
    required this.name,
    required this.stats,
    required this.won,
  });

  final String name;

  /// Null while the match's legs are still being read, and if they cannot be.
  /// The rows keep their places and show nothing, so the card neither jumps nor
  /// claims a total it has not got.
  final PlayerStats? stats;

  final bool won;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.toUpperCase(),
            style: Type.eyebrow.copyWith(
              color: won ? Palette.chalk : Palette.chalkDim,
            ),
          ),
          const SizedBox(height: Gap.md),
          _Figure('AVERAGE', _decimal(stats?.average)),
          _Figure('FIRST NINE', _decimal(stats?.firstNineAverage)),
          _Figure('180s', _whole(stats?.turnsOf180)),
          _Figure('BEST OUT', _whole(stats?.bestCheckout)),
          _Figure('BEST LEG', _whole(stats?.fewestDartsToWin)),
        ],
      ),
    );
  }

  static String _decimal(double? value) => value?.toStringAsFixed(1) ?? '—';

  static String _whole(int? value) => value?.toString() ?? '—';
}

/// A label and its number, on one line, in the statistics screen's idiom.
class _Figure extends StatelessWidget {
  const _Figure(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Type.label.copyWith(color: Palette.chalkDim)),
          const SizedBox(width: Gap.sm),
          Text(value, style: Type.data.copyWith(color: Palette.chalk)),
        ],
      ),
    );
  }
}
