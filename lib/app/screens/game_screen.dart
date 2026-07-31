import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/checkout/checkout_search.dart';
import '../../domain/x01/game_config.dart';
import '../../domain/x01/leg_state.dart';
import '../../domain/x01/thrown_dart.dart';
import '../providers.dart';
import '../widgets/board_widget.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameProvider);
    final controller = ref.read(gameProvider.notifier);
    final leg = session.leg;

    final routes = leg.isFinished
        ? const <CheckoutRoute>[]
        : ref
              .watch(checkoutTableProvider)
              .routesFor(leg.currentRemaining, leg.dartsLeftThisTurn);

    return Scaffold(
      appBar: AppBar(
        title: Text('${leg.config.startScore} · double out'),
        actions: [
          IconButton(
            onPressed: leg.darts.isEmpty ? null : controller.undo,
            icon: const Icon(Icons.undo),
            tooltip: 'Undo last dart',
          ),
          IconButton(
            onPressed: () => _showSetup(context, ref),
            icon: const Icon(Icons.tune),
            tooltip: 'New leg',
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _Scoreboard(leg: leg),
                _CheckoutStrip(routes: routes, leg: leg),
                _CurrentTurn(leg: leg),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: BoardWidget(
                      onSegmentTapped: (segment) =>
                          controller.addDart(ThrownDart(segment)),
                      onMissTapped: () =>
                          controller.addDart(const ThrownDart.miss()),
                      highlight: routes.isEmpty
                          ? const {}
                          : routes.first.darts.toSet(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        controller.addDart(const ThrownDart.miss()),
                    icon: const Icon(Icons.not_interested),
                    label: const Text('Miss / bounce-out'),
                  ),
                ),
              ],
            ),
            if (session.awaitingTurnConfirm)
              _TurnSummaryOverlay(
                turn: session.pendingTurn!,
                leg: leg,
                onConfirm: controller.confirmTurn,
                onUndo: controller.undo,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSetup(BuildContext context, WidgetRef ref) async {
    final config = ref.read(gameConfigProvider);
    final chosen = await showModalBottomSheet<GameConfig>(
      context: context,
      builder: (context) => _SetupSheet(initial: config),
    );
    if (chosen == null) return;
    ref.read(gameConfigProvider.notifier).update(chosen);
    ref.read(gameProvider.notifier).restart(chosen);
  }
}

class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.leg});

  final LegState leg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          for (final playerId in leg.config.playerIds)
            Expanded(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: playerId == leg.currentPlayerId && !leg.isFinished
                    ? theme.colorScheme.primaryContainer
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 6,
                  ),
                  child: Column(
                    children: [
                      Text(
                        playerName(playerId),
                        style: theme.textTheme.labelMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${leg.remaining[playerId]}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: leg.winnerId == playerId
                              ? theme.colorScheme.primary
                              : null,
                        ),
                      ),
                      Text(
                        leg.averageFor(playerId) == null
                            ? '—'
                            : 'avg ${leg.averageFor(playerId)!.toStringAsFixed(1)}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CheckoutStrip extends StatelessWidget {
  const _CheckoutStrip({required this.routes, required this.leg});

  final List<CheckoutRoute> routes;
  final LegState leg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (leg.isFinished) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          '${playerName(leg.winnerId!)} wins',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: routes.isEmpty
          ? Text('No checkout on', style: theme.textTheme.labelLarge)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routes.first.toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (routes.length > 1)
                  Text(
                    'or ${routes.skip(1).join('  ·  ')}',
                    style: theme.textTheme.labelSmall,
                  ),
              ],
            ),
    );
  }
}

class _CurrentTurn extends StatelessWidget {
  const _CurrentTurn({required this.leg});

  final LegState leg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < dartsPerTurn; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Chip(
                label: Text(
                  i < leg.currentTurnDarts.length
                      ? leg.currentTurnDarts[i].label
                      : '–',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Held after every turn so a misread can be caught before it is committed.
class _TurnSummaryOverlay extends StatelessWidget {
  const _TurnSummaryOverlay({
    required this.turn,
    required this.leg,
    required this.onConfirm,
    required this.onUndo,
  });

  final Turn turn;
  final LegState leg;
  final VoidCallback onConfirm;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned.fill(
      child: GestureDetector(
        onTap: onConfirm,
        child: ColoredBox(
          color: theme.colorScheme.scrim.withValues(alpha: 0.6),
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(32),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      playerName(turn.playerId),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      turn.busted ? 'BUST' : '${turn.scored}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: turn.busted ? theme.colorScheme.error : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      turn.darts.map((dart) => dart.label).join('  '),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${turn.scoreBefore} → ${turn.scoreAfter}',
                      style: theme.textTheme.labelMedium,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: onUndo,
                          icon: const Icon(Icons.undo),
                          label: const Text('Wrong'),
                        ),
                        FilledButton(
                          onPressed: onConfirm,
                          child: Text(
                            leg.isFinished ? 'Finish' : 'Next player',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'or press the board button',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupSheet extends StatefulWidget {
  const _SetupSheet({required this.initial});

  final GameConfig initial;

  @override
  State<_SetupSheet> createState() => _SetupSheetState();
}

class _SetupSheetState extends State<_SetupSheet> {
  late int _startScore = widget.initial.startScore;
  late int _players = widget.initial.playerIds.length;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Start score', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: [
              for (final score in GameConfig.offeredStartScores)
                ButtonSegment(value: score, label: Text('$score')),
            ],
            selected: {_startScore},
            onSelectionChanged: (selection) =>
                setState(() => _startScore = selection.first),
          ),
          const SizedBox(height: 20),
          Text('Players', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: [
              for (var count = 1; count <= GameConfig.maxPlayers; count++)
                ButtonSegment(value: count, label: Text('$count')),
            ],
            selected: {_players},
            onSelectionChanged: (selection) =>
                setState(() => _players = selection.first),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(
                GameConfig(
                  startScore: _startScore,
                  playerIds: [for (var i = 1; i <= _players; i++) i],
                ),
              ),
              child: const Text('Start leg'),
            ),
          ),
        ],
      ),
    );
  }
}
