import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/atc/atc_config.dart';
import '../../domain/atc/atc_variant.dart';
import '../l10n_extensions.dart';
import '../providers.dart';
import '../rules_topic.dart';
import '../theme.dart';
import '../widgets/board_connection_button.dart';
import '../widgets/player_picker.dart';
import '../widgets/rules_button.dart';
import '../widgets/setup_controls.dart';
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
  /// Selected players, in the order they were tapped - which is throwing order.
  List<int> _seats = const [];

  AtcVariant _variant = AtcVariant.anyPart;

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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.atcSetupTitle),
        actions: const [
          RulesButton(topic: RulesTopic.aroundTheClock),
          BoardConnectionButton(),
          SizedBox(width: Gap.xs),
        ],
      ),
      body: SafeArea(
        child: CenteredContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.lg),
            children: [
              SectionLabel(l10n.variantLabel),
              const SizedBox(height: Gap.md),
              ChoiceRow<AtcVariant>(
                key: const Key('variant-column'),
                values: AtcVariant.values,
                selected: _variant,
                label: (variant) => atcVariantLabel(context, variant),
                onSelected: (variant) => setState(() => _variant = variant),
              ),
              const SizedBox(height: Gap.xl),
              PlayerPicker(
                seats: _seats,
                onChanged: (seats) => setState(() => _seats = seats),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: StartBar(
        buttonKey: const Key('start-leg-button'),
        onPressed: _seats.isEmpty ? null : _start,
        label: _seats.isEmpty ? l10n.pickAtLeastOnePlayer : l10n.startLeg,
      ),
    );
  }
}
