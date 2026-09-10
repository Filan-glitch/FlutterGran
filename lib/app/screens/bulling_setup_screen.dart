import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/bulling/bulling_config.dart';
import '../../domain/bulling/bulling_variant.dart';
import '../../domain/x01/game_config.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/board_connection_button.dart';
import 'bulling_game_screen.dart';

/// How each [BullseyeValue] reads on the setup tile and everywhere else a
/// short label is needed for it.
String bullseyeValueLabel(BullseyeValue value) => switch (value) {
  BullseyeValue.two => 'BULLSEYE = 2',
  BullseyeValue.three => 'BULLSEYE = 3',
};

/// Picks the bullseye value, the target score, and who is playing, then
/// starts a persisted leg.
///
/// Mirrors `AtcSetupScreen`'s shape exactly — same reasons for what
/// belongs here and what does not.
class BullingSetupScreen extends ConsumerStatefulWidget {
  const BullingSetupScreen({super.key});

  @override
  ConsumerState<BullingSetupScreen> createState() =>
      _BullingSetupScreenState();
}

class _BullingSetupScreenState extends ConsumerState<BullingSetupScreen> {
  final TextEditingController _newPlayer = TextEditingController();

  /// Selected players, in the order they were tapped — which is throwing
  /// order.
  final List<int> _seats = [];

  BullseyeValue _bullseyeValue = BullseyeValue.two;
  int _target = 21;

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
    final config = BullingConfig(
      playerIds: _seats,
      bullseyeValue: _bullseyeValue,
      target: _target,
    );
    final gameId = await ref
        .read(gameRepositoryProvider)
        .startBullingGame(config);
    if (!mounted) return;

    ref.read(bullingConfigProvider.notifier).update(config);
    ref.read(currentGameIdProvider.notifier).set(gameId);
    ref.read(bullingGameProvider.notifier).restart(config);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const BullingGameScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BULLING SETUP'),
        actions: const [BoardConnectionButton(), SizedBox(width: Gap.xs)],
      ),
      body: SafeArea(
        child: CenteredContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.lg),
            children: [
              const _Eyebrow('Bullseye value'),
              const SizedBox(height: Gap.md),
              Column(
                key: const Key('bullseye-value-column'),
                children: [
                  for (final value in BullseyeValue.values) ...[
                    if (value != BullseyeValue.values.first)
                      const SizedBox(height: Gap.sm),
                    _VariantChoice(
                      label: bullseyeValueLabel(value),
                      selected: value == _bullseyeValue,
                      onTap: () => setState(() => _bullseyeValue = value),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: Gap.lg),
              const _Eyebrow('Target'),
              const SizedBox(height: Gap.md),
              Row(
                key: const Key('target-row'),
                children: [
                  for (final target in BullingConfig.offeredTargets) ...[
                    if (target != BullingConfig.offeredTargets.first)
                      const SizedBox(width: Gap.sm),
                    Expanded(
                      child: _ScoreChoice(
                        score: target,
                        selected: target == _target,
                        onTap: () => setState(() => _target = target),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: Gap.xl),
              Row(
                children: [
                  const _Eyebrow('Players'),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Text(
                      _seats.isEmpty
                          ? 'tap to add, in throwing order'
                          : '${_seats.length} of ${GameConfig.maxPlayers}',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Type.label.copyWith(color: Palette.chalkDim),
                    ),
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
                      cursorColor: Palette.live,
                      decoration: const InputDecoration(
                        labelText: 'Add a player',
                      ),
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
                _ => const SizedBox.shrink(),
              },
            ],
          ),
        ),
      ),
      bottomNavigationBar: CenteredContent(
        child: Padding(
          key: const Key('start-button-padding'),
          padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.lg),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('start-leg-button'),
              onPressed: _seats.isEmpty ? null : _start,
              child: Text(
                _seats.isEmpty ? 'PICK AT LEAST ONE PLAYER' : 'START LEG',
              ),
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
        color: selected ? Palette.raised : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: selected ? Palette.live : Palette.edge),
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
                SizedBox(
                  width: 26,
                  child: Text(
                    selected ? '${seat + 1}' : '',
                    style: Type.notation.copyWith(color: Palette.live),
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

/// One bullseye-value choice, as a full-width row — the same idiom
/// `AtcSetupScreen`'s `_VariantChoice` uses.
class _VariantChoice extends StatelessWidget {
  const _VariantChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Palette.chalk : Palette.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: selected ? Palette.chalk : Palette.edge),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.lg,
            vertical: Gap.md,
          ),
          child: Text(
            label,
            style: Type.body.copyWith(
              color: selected ? Palette.ground : Palette.chalk,
            ),
          ),
        ),
      ),
    );
  }
}

/// One number in a row of them — the same idiom `X01SetupScreen`'s
/// `_ScoreChoice` uses for the start score.
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
      color: selected ? Palette.chalk : Palette.raised,
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
                color: selected ? Palette.ground : Palette.chalkDim,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
