import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/x01/game_config.dart';
import '../providers.dart';
import 'game_screen.dart';

/// Picks who is playing and under what rules, then starts a persisted leg.
class NewGameScreen extends ConsumerStatefulWidget {
  const NewGameScreen({super.key});

  @override
  ConsumerState<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends ConsumerState<NewGameScreen> {
  final TextEditingController _newPlayer = TextEditingController();

  /// Selected players, in the order they were tapped - which is throwing order.
  final List<int> _seats = [];

  int _startScore = 501;

  @override
  void dispose() {
    _newPlayer.dispose();
    super.dispose();
  }

  Future<void> _addPlayer() async {
    final name = _newPlayer.text.trim();
    if (name.isEmpty) return;

    final player = await ref.read(gameRepositoryProvider).addPlayer(name);
    _newPlayer.clear();
    if (_seats.length < GameConfig.maxPlayers) {
      setState(() => _seats.add(player.id));
    }
  }

  Future<void> _start() async {
    final config = GameConfig(startScore: _startScore, playerIds: _seats);

    final gameId = await ref.read(gameRepositoryProvider).startGame(config);
    if (!mounted) return;

    ref.read(gameConfigProvider.notifier).update(config);
    ref.read(currentGameIdProvider.notifier).set(gameId);
    ref.read(gameProvider.notifier).restart(config);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New leg')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Players',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const Spacer(),
                Text(
                  _seats.isEmpty
                      ? 'tap to add, in throwing order'
                      : '${_seats.length} of ${GameConfig.maxPlayers}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newPlayer,
                    decoration: const InputDecoration(
                      labelText: 'Add a player',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addPlayer(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addPlayer,
                  icon: const Icon(Icons.person_add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            switch (players) {
              AsyncError(:final error) => Text('Could not load players: $error'),
              AsyncData(:final value) when value.isEmpty => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No players yet. Add the first one above.'),
              ),
              AsyncData(:final value) => Column(
                children: [for (final player in value) _tile(player)],
              ),
              // Deliberately blank rather than a spinner: this is a local
              // query that resolves in a frame, and a flash of spinner is
              // worse than nothing.
              _ => const SizedBox.shrink(),
            },
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _seats.isEmpty ? null : _start,
          child: Text(
            _seats.isEmpty ? 'Pick at least one player' : 'Start leg',
          ),
        ),
      ),
    );
  }

  Widget _tile(Player player) {
    final seat = _seats.indexOf(player.id);
    final selected = seat >= 0;
    final full = _seats.length >= GameConfig.maxPlayers;

    return ListTile(
      onTap: selected
          ? () => setState(() => _seats.remove(player.id))
          : full
          ? null
          : () => setState(() => _seats.add(player.id)),
      leading: CircleAvatar(
        backgroundColor: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: selected
            ? Theme.of(context).colorScheme.onPrimary
            : null,
        child: Text(selected ? '${seat + 1}' : ''),
      ),
      title: Text(player.name),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () async {
          setState(() => _seats.remove(player.id));
          await ref.read(gameRepositoryProvider).removePlayer(player.id);
        },
      ),
    );
  }
}
