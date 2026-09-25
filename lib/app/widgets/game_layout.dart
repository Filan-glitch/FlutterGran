import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n_extensions.dart';
import '../providers.dart';
import '../theme.dart';
import 'board_connection_button.dart';

/// Whether this device earns the hero treatment. See [heroLayout].
///
/// Shortest side, not the local width a `LayoutBuilder` would give: this is
/// "how big is the device", the same question [typeScaleFor] answers, and the
/// two are meant to move together - the device that earns bigger type earns
/// the hero layout with it.
bool isHeroDevice(BuildContext context) =>
    MediaQuery.sizeOf(context).shortestSide >= heroLayout;

/// Whether darts are being keyed in by hand right now.
///
/// The keypad is the fallback path: it disappears the moment a real board can
/// be trusted to score for itself, and comes back the moment someone says
/// otherwise, board present or not.
bool keypadVisible(WidgetRef ref) =>
    !ref.watch(boardConnectionProvider).isConnected ||
    ref.watch(keypadOverrideProvider);

/// The one arrangement every game is played in.
///
/// Aim, scoreboard and ledger on one side; on the other, whatever is asking
/// for a decision right now - the keypad, the turn being confirmed, or what
/// just ended. It is the same widget either way round - only where it sits
/// moves. A game fills the slots in its own terms and this decides where they
/// go on the device in hand.
class GameLayout extends ConsumerWidget {
  const GameLayout({
    super.key,
    required this.scoreboard,
    required this.ledger,
    required this.keypad,
    this.aim,
    this.turnResult,
    this.outcome,
    this.gameOver,
  });

  /// The seats, told whether they are the only thing on screen and should
  /// fill the height that would otherwise sit empty.
  final Widget Function(bool expand) scoreboard;

  final Widget ledger;

  /// What to throw at next - a checkout, a stop. Null when there is nothing
  /// worth saying.
  final Widget? aim;

  final Widget keypad;

  /// The turn just thrown, held for confirmation.
  final Widget? turnResult;

  /// Something that ended but did not end the game, in the keypad's place.
  final Widget? outcome;

  /// The game is over: laid over everything.
  final Widget? gameOver;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hero = isHeroDevice(context);
    final showKeypad = keypadVisible(ref);
    final turnResult = this.turnResult;
    final outcome = this.outcome;
    final gameOver = this.gameOver;
    final aim = this.aim ?? SizedBox(height: hero ? Gap.md : Gap.sm);

    // The game-over card is stacked over the board rather than pushed as a
    // route: a game ends where it was played, and the scoreboard behind the
    // card is what makes it read as the end of a game instead of a different
    // screen.
    return Stack(
      key: const Key('game-body'),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Nothing to key in, and nothing coming from a keypad that isn't
            // there: a board doing its own scoring has no use for the half of
            // the screen the keypad would otherwise reserve. Give that space
            // to the players instead of an idle placeholder standing in for a
            // control nobody can use.
            final boardScoringAlone =
                !showKeypad &&
                turnResult == null &&
                outcome == null &&
                gameOver == null;
            if (boardScoringAlone) {
              return Column(
                children: [
                  aim,
                  Expanded(child: scoreboard(true)),
                  const Divider(),
                  ledger,
                ],
              );
            }

            final board = [scoreboard(false), const Divider(), ledger];

            final Widget play;
            if (hero && turnResult != null) {
              // The full-screen overlay below covers this slot entirely (or
              // the game-over card does) - so there is nothing here worth
              // spending a turn result's layout and paint on every frame it
              // is invisible.
              play = const SizedBox.shrink();
            } else if (turnResult != null) {
              play = turnResult;
            } else if (outcome != null) {
              play = outcome;
            } else if (gameOver != null) {
              play = const SizedBox.shrink();
            } else {
              play = Column(
                children: [
                  aim,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Gap.md,
                        Gap.sm,
                        Gap.md,
                        Gap.md,
                      ),
                      child: keypad,
                    ),
                  ),
                ],
              );
            }

            // Side by side once there is width for it. Stacked, the score and
            // the keypad are both squeezed into a height neither has; beside
            // each other they each get a whole half and nothing has to shrink
            // - which is the point, because the size of the score is what
            // makes it readable from the oche.
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
        // On the tablet a turn result is the whole screen, not a panel sharing
        // it - the score everyone was just watching goes away for a moment, on
        // purpose, for the number that came off the board. Skipped when the
        // game just ended too: the game-over card takes over instead, and its
        // own 95%-opaque card is meant to show the scoreboard through it, not
        // this.
        if (hero && turnResult != null && gameOver == null)
          Positioned.fill(
            child: ColoredBox(
              key: const Key('turn-result-overlay'),
              color: Palette.ground,
              child: turnResult,
            ),
          ),
        if (gameOver != null) Positioned.fill(child: gameOver),
      ],
    );
  }
}

/// Every game's app bar: what is being played, the board light, the keypad
/// toggle while a board is scoring, and undo.
class GameAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const GameAppBar({super.key, required this.title, required this.onUndo});

  final String title;

  /// Null when there is nothing to undo.
  final VoidCallback? onUndo;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final boardConnected = ref.watch(boardConnectionProvider).isConnected;
    final manualOverride = ref.watch(keypadOverrideProvider);

    return AppBar(
      title: Text(title),
      actions: [
        const BoardConnectionButton(),
        if (boardConnected)
          IconButton(
            key: const Key('keypad-override-toggle'),
            onPressed: () => ref.read(keypadOverrideProvider.notifier).toggle(),
            icon: Icon(manualOverride ? Icons.videogame_asset : Icons.dialpad),
            tooltip: manualOverride
                ? l10n.hideManualEntryTooltip
                : l10n.enterScoreByHandTooltip,
          ),
        IconButton(
          onPressed: onUndo,
          icon: const Icon(Icons.undo),
          tooltip: l10n.undoLastDartTooltip,
        ),
        const SizedBox(width: Gap.xs),
      ],
    );
  }
}

/// Asks before leaving a leg that has darts in it, and leaves only on yes.
///
/// A fresh or finished leg is not worth confirming, and gets out of the way
/// with the platform's own back gesture intact.
class LeaveGuard extends StatelessWidget {
  const LeaveGuard({
    super.key,
    required this.confirm,
    required this.onLeave,
    required this.child,
  });

  /// Whether leaving needs a yes first.
  final bool confirm;

  /// Winds the game down - stops board input being scored into a leg nobody
  /// is watching - before the screen goes.
  final VoidCallback onLeave;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !confirm,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (!await _confirmLeave(context)) return;

        onLeave();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: child,
    );
  }

  /// Says plainly that nothing is being thrown away.
  ///
  /// This is a "we are keeping it" confirmation, not a warning. Telling
  /// someone they are about to lose a leg when they are not would teach them
  /// to fear the back button.
  static Future<bool> _confirmLeave(BuildContext context) async {
    final l10n = context.l10n;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.leaveLegTitle),
        content: Text(
          l10n.leaveLegBody,
          style: Type.body.copyWith(color: Palette.chalkDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.stayButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.leaveButton),
          ),
        ],
      ),
    );
    return leave ?? false;
  }
}
