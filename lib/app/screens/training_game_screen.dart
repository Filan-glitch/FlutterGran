import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/checkout/checkout_search.dart';
import '../../domain/training/free_practice_state.dart';
import '../../domain/x01/leg_state.dart';
import '../../domain/x01/thrown_dart.dart';
import '../l10n_extensions.dart';
import '../providers.dart';
import '../theme.dart';
import '../training_controller.dart';
import '../widgets/board_connection_button.dart';

/// Throw darts and see what happened - free practice, or a chosen checkout
/// worked at on repeat. Nothing shown here is ever written to the database;
/// see [TrainingController] for the guarantee.
class TrainingGameScreen extends ConsumerWidget {
  const TrainingGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(trainingProvider);
    final controller = ref.read(trainingProvider.notifier);

    // Nothing is read from it - watching is what keeps the training sound
    // listener alive for as long as this screen is on, the same idiom
    // `soundControllerProvider` uses for a real leg.
    ref.watch(trainingSoundControllerProvider);

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
        appBar: AppBar(
          title: Text(switch (session) {
            FreePracticeSession() => l10n.freePracticeLabel,
            CheckoutPracticeSession(:final startScore) =>
              l10n.checkoutPracticeWithScore(startScore),
          }),
          actions: [
            const BoardConnectionButton(),
            IconButton(
              onPressed: darts.isEmpty ? null : controller.undo,
              icon: const Icon(Icons.undo),
              tooltip: l10n.undoLastDartTooltip,
            ),
            const SizedBox(width: Gap.xs),
          ],
        ),
        body: SafeArea(
          child: CenteredContent(
            child: switch (session) {
              FreePracticeSession(:final practice) => _FreePracticeBody(
                practice: practice,
              ),
              CheckoutPracticeSession(:final leg, :final checkoutsCompleted) =>
                _CheckoutPracticeBody(
                  leg: leg,
                  checkoutsCompleted: checkoutsCompleted,
                  routes: routes,
                  onThrowAgain: controller.throwAgain,
                ),
            },
          ),
        ),
      ),
    );
  }
}

class _FreePracticeBody extends StatelessWidget {
  const _FreePracticeBody({required this.practice});

  final FreePracticeState practice;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final darts = practice.currentTurnDarts;
    final total = darts.fold<int>(0, (sum, dart) => sum + dart.value);

    return ListView(
      padding: const EdgeInsets.all(Gap.lg),
      children: [
        _DartRow(darts: darts, total: total, struck: false),
        const SizedBox(height: Gap.xl),
        _StatGrid(
          stats: [
            _Stat(l10n.statDarts, '${practice.dartsThrown}'),
            _Stat(
              l10n.statAverage,
              practice.average == null
                  ? '—'
                  : practice.average!.toStringAsFixed(1),
            ),
            _Stat(l10n.statBestTurn, practice.bestTurn?.toString() ?? '—'),
            _Stat(l10n.figure180s, '${practice.oneEightyCount}'),
          ],
        ),
      ],
    );
  }
}

class _CheckoutPracticeBody extends StatelessWidget {
  const _CheckoutPracticeBody({
    required this.leg,
    required this.checkoutsCompleted,
    required this.routes,
    required this.onThrowAgain,
  });

  final LegState leg;
  final int checkoutsCompleted;
  final List<CheckoutRoute> routes;
  final VoidCallback onThrowAgain;

  @override
  Widget build(BuildContext context) {
    if (leg.isFinished) {
      return _CheckedOutPanel(
        dartsThrown: leg.darts.length,
        checkoutsCompleted: checkoutsCompleted,
        onThrowAgain: onThrowAgain,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(Gap.lg),
      children: [
        Text(
          '${leg.currentRemaining}',
          style: Type.score.copyWith(color: Palette.chalk),
        ),
        _CheckoutStrip(routes: routes),
        const SizedBox(height: Gap.lg),
        _DartRow(
          darts: leg.currentTurnDarts,
          total: leg.currentTurnDarts.fold<int>(
            0,
            (sum, dart) => sum + dart.value,
          ),
          // The last completed turn tells the player what a bust looked
          // like - by the time the third dart lands the current turn has
          // already moved on, so this is the only place it would show.
          struck: leg.lastTurn?.busted ?? false,
        ),
        const SizedBox(height: Gap.md),
        Text(
          context.l10n.checkoutsThisSession(checkoutsCompleted),
          style: Type.eyebrow.copyWith(color: Palette.chalkDim),
        ),
      ],
    );
  }
}

class _CheckedOutPanel extends StatelessWidget {
  const _CheckedOutPanel({
    required this.dartsThrown,
    required this.checkoutsCompleted,
    required this.onThrowAgain,
  });

  final int dartsThrown;
  final int checkoutsCompleted;
  final VoidCallback onThrowAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Gap.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.checkedOutLabel,
              style: Type.title.copyWith(color: Palette.live),
            ),
            const SizedBox(height: Gap.sm),
            Text(
              l10n.inDartsCount(dartsThrown),
              style: Type.body.copyWith(color: Palette.chalkDim),
            ),
            const SizedBox(height: Gap.md),
            Text(
              l10n.checkoutsThisSession(checkoutsCompleted),
              style: Type.eyebrow.copyWith(color: Palette.chalkDim),
            ),
            const SizedBox(height: Gap.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('throw-again-button'),
                onPressed: onThrowAgain,
                child: Text(l10n.throwAgainButton),
              ),
            ),
            const SizedBox(height: Gap.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                key: const Key('training-done-button'),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.doneButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Three darts, written out with a running total - the training-screen
/// equivalent of `_TurnLedger` in `game_screen.dart`. Duplicated rather than
/// imported: that widget is private to its own file, and this one has no
/// `GameSession`/turn-confirm state to read.
class _DartRow extends StatelessWidget {
  const _DartRow({
    required this.darts,
    required this.total,
    required this.struck,
  });

  final List<ThrownDart> darts;
  final int total;
  final bool struck;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < dartsPerTurn; i++) ...[
          if (i > 0) const SizedBox(width: Gap.sm),
          Expanded(
            child: _DartSlot(
              dart: i < darts.length ? darts[i] : null,
              struck: struck,
            ),
          ),
        ],
        const SizedBox(width: Gap.lg),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 72),
          child: Text(
            struck ? context.l10n.bustLabel : '$total',
            textAlign: TextAlign.right,
            style: struck
                ? Type.notation.copyWith(color: Palette.doubleBed)
                : Type.scoreSmall.copyWith(
                    color: darts.isEmpty ? Palette.chalkDim : Palette.live,
                  ),
          ),
        ),
      ],
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

/// What to throw, when there is something on - the training-screen's own
/// copy of `_CheckoutStrip` in `game_screen.dart`, same reason as
/// [_DartSlot].
class _CheckoutStrip extends StatelessWidget {
  const _CheckoutStrip({required this.routes});

  final List<CheckoutRoute> routes;

  @override
  Widget build(BuildContext context) {
    if (routes.isEmpty) return const SizedBox(height: Gap.sm);

    return Padding(
      padding: const EdgeInsets.only(top: Gap.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            context.l10n.checkoutLabel,
            style: Type.eyebrow.copyWith(color: Palette.live),
          ),
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

class _Stat {
  const _Stat(this.label, this.value);

  final String label;
  final String value;
}

/// A 2x2 grid of session numbers - free practice has no leg to end, so this
/// is the only feedback the player gets on how the session is going.
class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});

  final List<_Stat> stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: Gap.sm,
      crossAxisSpacing: Gap.sm,
      childAspectRatio: 2,
      children: [for (final stat in stats) _StatTile(stat: stat)],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});

  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(
        color: Palette.raised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Palette.edge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stat.label,
            style: Type.eyebrow.copyWith(color: Palette.chalkDim),
          ),
          const SizedBox(height: Gap.xs),
          Text(
            stat.value,
            style: Type.scoreSmall.copyWith(color: Palette.chalk, fontSize: 24),
          ),
        ],
      ),
    );
  }
}
