import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/atc/atc_config.dart';
import '../../domain/atc/atc_variant.dart';
import '../../domain/x01/game_config.dart';
import '../../l10n/app_localizations.dart';
import '../l10n_extensions.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/board_connection_button.dart';
import 'atc_game_screen.dart';

/// How each [AtcVariant] reads on the setup tile and everywhere else a short
/// label is needed for it.
String atcVariantLabel(BuildContext context, AtcVariant variant) {
  final l10n = context.l10n;
  return switch (variant) {
    AtcVariant.anyPart => l10n.atcVariantAnyPart,
    AtcVariant.masters => l10n.atcVariantMasters,
    AtcVariant.doublesOnly => l10n.atcVariantDoublesOnly,
  };
}

/// Picks the Around the Clock variant and who is playing it, then starts a
/// persisted leg.
///
/// Mirrors `X01SetupScreen`'s shape exactly - same reasons for what belongs
/// here (just the format and the roster) and what does not (branding,
/// resuming, sound toggles).
class AtcSetupScreen extends ConsumerStatefulWidget {
  const AtcSetupScreen({super.key});

  @override
  ConsumerState<AtcSetupScreen> createState() => _AtcSetupScreenState();
}

class _AtcSetupScreenState extends ConsumerState<AtcSetupScreen> {
  final TextEditingController _newPlayer = TextEditingController();

  /// Selected players, in the order they were tapped - which is throwing order.
  final List<int> _seats = [];

  AtcVariant _variant = AtcVariant.anyPart;

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
    final config = AtcConfig(playerIds: _seats, variant: _variant);
    final gameId = await ref.read(gameRepositoryProvider).startAtcGame(config);
    if (!mounted) return;

    ref.read(atcConfigProvider.notifier).update(config);
    ref.read(currentGameIdProvider.notifier).set(gameId);
    ref.read(atcGameProvider.notifier).restart(config);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const AtcGameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final players = ref.watch(playersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.atcSetupTitle),
        actions: const [
          BoardConnectionButton(),
          SizedBox(width: Gap.xs),
        ],
      ),
      body: SafeArea(
        child: CenteredContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.lg),
            children: [
              _Eyebrow(l10n.variantLabel),
              const SizedBox(height: Gap.md),
              Row(
                key: const Key('variant-column'),
                children: [
                  for (final variant in AtcVariant.values) ...[
                    if (variant != AtcVariant.values.first)
                      const SizedBox(width: Gap.sm),
                    _VariantChoice(
                      label: atcVariantLabel(context, variant),
                      selected: variant == _variant,
                      onTap: () => setState(() => _variant = variant),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: Gap.xl),
              Row(
                children: [
                  _Eyebrow(l10n.playersLabel),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Text(
                      _seats.isEmpty
                          ? l10n.tapToAddPlayers
                          : l10n.seatsOfMax(
                              _seats.length,
                              GameConfig.maxPlayers,
                            ),
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
                      decoration: InputDecoration(
                        labelText: l10n.addPlayerFieldLabel,
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
                  children: [for (final player in value) _tile(player, l10n)],
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
                _seats.isEmpty ? l10n.pickAtLeastOnePlayer : l10n.startLeg,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(Player player, AppLocalizations l10n) {
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
                  tooltip: l10n.removePlayerTooltip(player.name),
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

/// One variant, as a full-width row rather than `X01SetupScreen`'s
/// `_ScoreChoice` grid - a variant name reads better full width than
/// squeezed into a third of the row the way a numeral does.
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
