import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/x01/game_config.dart';
import '../providers.dart';
import '../theme.dart';
import 'diagnostics_screen.dart';
import 'game_screen.dart';
import 'stats_screen.dart';

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
      appBar: AppBar(
        title: const Text('FLUTTERGRAN'),
        actions: [
          IconButton(
            tooltip: 'Board diagnostics',
            icon: const Icon(Icons.sensors),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const DiagnosticsScreen(),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Statistics',
            icon: const Icon(Icons.insights),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const StatsScreen(),
              ),
            ),
          ),
          const SizedBox(width: Gap.xs),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.lg),
          children: [
            // The start score set as a scoreboard number rather than a form
            // field: it is the number everyone is about to count down from.
            const _Eyebrow('Start score'),
            const SizedBox(height: Gap.md),
            Row(
              children: [
                for (final score in GameConfig.offeredStartScores) ...[
                  if (score != GameConfig.offeredStartScores.first)
                    const SizedBox(width: Gap.sm),
                  Expanded(
                    child: _ScoreChoice(
                      score: score,
                      selected: score == _startScore,
                      onTap: () => setState(() => _startScore = score),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: Gap.xl),
            Row(
              children: [
                const _Eyebrow('Players'),
                const Spacer(),
                Text(
                  _seats.isEmpty
                      ? 'tap to add, in throwing order'
                      : '${_seats.length} of ${GameConfig.maxPlayers}',
                  style: Type.label.copyWith(color: Palette.chalkDim),
                ),
              ],
            ),
            const SizedBox(height: Gap.md),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newPlayer,
                    style: Type.body.copyWith(color: Palette.chalk),
                    cursorColor: Palette.oche,
                    decoration: const InputDecoration(labelText: 'Add a player'),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addPlayer(),
                  ),
                ),
                const SizedBox(width: Gap.sm),
                SizedBox(
                  height: 46,
                  width: 46,
                  child: FilledButton(
                    onPressed: _addPlayer,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Icon(Icons.add, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.md),
            switch (players) {
              AsyncError(:final error) => Text(
                'Could not load players: $error',
                style: Type.body.copyWith(color: Palette.doubleBed),
              ),
              AsyncData(:final value) when value.isEmpty => Padding(
                padding: const EdgeInsets.symmetric(vertical: Gap.xl),
                child: Text(
                  'No players yet. Add the first one above.',
                  style: Type.body.copyWith(color: Palette.chalkDim),
                ),
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
        padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.lg),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _seats.isEmpty ? null : _start,
            child: Text(
              _seats.isEmpty ? 'PICK AT LEAST ONE PLAYER' : 'START LEG',
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(Player player) {
    final seat = _seats.indexOf(player.id);
    final selected = seat >= 0;
    final full = _seats.length >= GameConfig.maxPlayers;

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Material(
        color: selected ? Palette.slateRaised : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: selected ? Palette.oche : Palette.edge,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: selected
              ? () => setState(() => _seats.remove(player.id))
              : full
              ? null
              : () => setState(() => _seats.add(player.id)),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.md,
              vertical: Gap.md,
            ),
            child: Row(
              children: [
                // The seat number is the throwing order, so it only appears
                // once a player actually has one.
                SizedBox(
                  width: 26,
                  child: Text(
                    selected ? '${seat + 1}' : '',
                    style: Type.notation.copyWith(color: Palette.oche),
                  ),
                ),
                Expanded(
                  child: Text(
                    player.name,
                    style: Type.body.copyWith(
                      color: selected ? Palette.chalk : Palette.chalkDim,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Remove ${player.name}',
                  onPressed: () async {
                    setState(() => _seats.remove(player.id));
                    await ref
                        .read(gameRepositoryProvider)
                        .removePlayer(player.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: Type.eyebrow.copyWith(color: Palette.chalkDim),
  );
}

class _ScoreChoice extends StatelessWidget {
  const _ScoreChoice({
    required this.score,
    required this.selected,
    required this.onTap,
  });

  final int score;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Palette.chalk : Palette.slateRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: selected ? Palette.chalk : Palette.edge),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Gap.md),
          child: Center(
            child: Text(
              '$score',
              style: Type.scoreSmall.copyWith(
                color: selected ? Palette.slate : Palette.chalkDim,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
