import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/higher_lower/higher_lower_config.dart';
import '../l10n_extensions.dart';
import '../providers.dart';
import '../rules_topic.dart';
import '../theme.dart';
import '../widgets/board_connection_button.dart';
import '../widgets/player_picker.dart';
import '../widgets/rules_button.dart';
import '../widgets/setup_controls.dart';
import 'higher_lower_game_screen.dart';

/// Picks who is playing, then starts a persisted leg.
///
/// Mirrors `BullingSetupScreen`'s shape, minus every choice: a Higher/Lower
/// leg always opens on the same two values, so the roster is all there is
/// to set up - and it needs two players, since last one standing needs
/// somebody to outlast.
class HigherLowerSetupScreen extends ConsumerStatefulWidget {
  const HigherLowerSetupScreen({super.key});

  @override
  ConsumerState<HigherLowerSetupScreen> createState() =>
      _HigherLowerSetupScreenState();
}

class _HigherLowerSetupScreenState
    extends ConsumerState<HigherLowerSetupScreen> {
  /// Selected players, in the order they were tapped - which is throwing
  /// order.
  List<int> _seats = const [];

  bool get _enoughPlayers => _seats.length >= HigherLowerConfig.minPlayers;

  Future<void> _start() async {
    final config = HigherLowerConfig(playerIds: _seats);
    final gameId = await ref
        .read(gameRepositoryProvider)
        .startHigherLowerGame(config);
    if (!mounted) return;

    ref.read(higherLowerConfigProvider.notifier).update(config);
    ref.read(currentGameIdProvider.notifier).set(gameId);
    ref.read(higherLowerGameProvider.notifier).restart(config);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const HigherLowerGameScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.higherLowerSetupTitle),
        actions: const [
          RulesButton(topic: RulesTopic.higherLower),
          BoardConnectionButton(),
          SizedBox(width: Gap.xs),
        ],
      ),
      body: SafeArea(
        child: CenteredContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.lg),
            children: [
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
        onPressed: _enoughPlayers ? _start : null,
        label: _enoughPlayers ? l10n.startLeg : l10n.pickAtLeastTwoPlayers,
      ),
    );
  }
}
