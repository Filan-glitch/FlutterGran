import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/bulling/bulling_config.dart';
import '../../domain/bulling/bulling_variant.dart';
import '../l10n_extensions.dart';
import '../providers.dart';
import '../rules_topic.dart';
import '../theme.dart';
import '../widgets/board_connection_button.dart';
import '../widgets/player_picker.dart';
import '../widgets/rules_button.dart';
import '../widgets/setup_controls.dart';
import 'bulling_game_screen.dart';

/// How each [BullseyeValue] reads on the setup tile and everywhere else a
/// short label is needed for it.
String bullseyeValueLabel(BuildContext context, BullseyeValue value) {
  final l10n = context.l10n;
  return switch (value) {
    BullseyeValue.two => l10n.bullseyeValueTwo,
    BullseyeValue.three => l10n.bullseyeValueThree,
  };
}

/// Picks the bullseye value, the target score, and who is playing, then
/// starts a persisted leg.
///
/// Mirrors `AtcSetupScreen`'s shape exactly — same reasons for what
/// belongs here and what does not.
class BullingSetupScreen extends ConsumerStatefulWidget {
  const BullingSetupScreen({super.key});

  @override
  ConsumerState<BullingSetupScreen> createState() => _BullingSetupScreenState();
}

class _BullingSetupScreenState extends ConsumerState<BullingSetupScreen> {
  /// Selected players, in the order they were tapped — which is throwing
  /// order.
  List<int> _seats = const [];

  BullseyeValue _bullseyeValue = BullseyeValue.two;
  int _target = 21;

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
      MaterialPageRoute<void>(builder: (context) => const BullingGameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bullingSetupTitle),
        actions: const [
          RulesButton(topic: RulesTopic.bulling),
          BoardConnectionButton(),
          SizedBox(width: Gap.xs),
        ],
      ),
      body: SafeArea(
        child: CenteredContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.lg),
            children: [
              SectionLabel(l10n.bullseyeValueSectionLabel),
              const SizedBox(height: Gap.md),
              ChoiceRow<BullseyeValue>(
                key: const Key('bullseye-value-column'),
                values: BullseyeValue.values,
                selected: _bullseyeValue,
                label: (value) => bullseyeValueLabel(context, value),
                onSelected: (value) => setState(() => _bullseyeValue = value),
              ),
              const SizedBox(height: Gap.lg),
              SectionLabel(l10n.targetLabel),
              const SizedBox(height: Gap.md),
              NumeralChoiceRow<int>(
                key: const Key('target-row'),
                values: BullingConfig.offeredTargets,
                selected: _target,
                label: (target) => '$target',
                onSelected: (target) => setState(() => _target = target),
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
