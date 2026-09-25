import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/x01/game_config.dart';
import '../l10n_extensions.dart';
import '../providers.dart';
import '../theme.dart';
import 'setup_controls.dart';

/// Who is playing, and in what order: every setup screen's roster.
///
/// Tapping a player seats them next, tapping again stands them up; the seat
/// number beside a name is their place in the throwing order. A new name
/// typed in is added to the roster and seated in one go.
///
/// Nothing here deletes a player. Deleting takes a player's history with them,
/// which is too much to hang off a tap made while picking who throws first -
/// that lives on the roster screen, which is built for it.
class PlayerPicker extends ConsumerStatefulWidget {
  const PlayerPicker({super.key, required this.seats, required this.onChanged});

  /// Player ids in throwing order.
  final List<int> seats;

  final ValueChanged<List<int>> onChanged;

  @override
  ConsumerState<PlayerPicker> createState() => _PlayerPickerState();
}

class _PlayerPickerState extends ConsumerState<PlayerPicker> {
  final TextEditingController _newPlayer = TextEditingController();

  bool get _full => widget.seats.length >= GameConfig.maxPlayers;

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
    if (!mounted || _full) return;
    widget.onChanged([...widget.seats, player.id]);
  }

  void _toggle(int playerId) {
    final seats = widget.seats;
    if (seats.contains(playerId)) {
      widget.onChanged([
        for (final id in seats)
          if (id != playerId) id,
      ]);
    } else if (!_full) {
      widget.onChanged([...seats, playerId]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final players = ref.watch(playersProvider);
    final seats = widget.seats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(
          l10n.playersLabel,
          trailing: seats.isEmpty
              ? l10n.tapToAddPlayers
              : l10n.seatsOfMax(seats.length, GameConfig.maxPlayers),
        ),
        const SizedBox(height: Gap.md),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newPlayer,
                style: Type.body.copyWith(color: Palette.chalk),
                cursorColor: Palette.live,
                decoration: InputDecoration(
                  labelText: l10n.addPlayerFieldLabel,
                ),
                textCapitalization: TextCapitalization.words,
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
                child: Icon(
                  Icons.add,
                  size: 22,
                  semanticLabel: l10n.addPlayerFieldLabel,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Gap.md),
        switch (players) {
          AsyncError(:final error) => Text(
            l10n.couldNotLoadPlayers('$error'),
            style: Type.body.copyWith(color: Palette.doubleBed),
          ),
          AsyncData(:final value) when value.isEmpty => Padding(
            padding: const EdgeInsets.symmetric(vertical: Gap.xl),
            child: Text(
              l10n.noPlayersYet,
              style: Type.body.copyWith(color: Palette.chalkDim),
            ),
          ),
          AsyncData(:final value) => Column(
            children: [
              for (final player in value)
                _PlayerRow(
                  player: player,
                  seat: seats.indexOf(player.id),
                  enabled: seats.contains(player.id) || !_full,
                  onTap: () => _toggle(player.id),
                ),
            ],
          ),
          // Deliberately blank rather than a spinner: this is a local query
          // that resolves in a frame, and a flash of spinner is worse than
          // nothing.
          _ => const SizedBox.shrink(),
        },
      ],
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.player,
    required this.seat,
    required this.enabled,
    required this.onTap,
  });

  final Player player;

  /// Place in the throwing order, or -1 when not playing.
  final int seat;

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = seat >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Semantics(
        selected: selected,
        child: Material(
          color: selected ? Palette.raised : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: selected ? Palette.live : Palette.edge),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: ConstrainedBox(
              // The tap target a row of text alone would fall short of.
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gap.md),
                child: Row(
                  children: [
                    // The seat number is the throwing order, so it only
                    // appears once a player actually has one.
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Type.body.copyWith(
                          color: selected ? Palette.chalk : Palette.chalkDim,
                        ),
                      ),
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
