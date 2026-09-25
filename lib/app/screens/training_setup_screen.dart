import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/training/training_drill.dart';
import '../../domain/x01/game_config.dart';
import '../l10n_extensions.dart';
import '../providers.dart';
import '../rules_topic.dart';
import '../theme.dart';
import '../widgets/board_connection_button.dart';
import '../widgets/rules_button.dart';
import '../widgets/setup_controls.dart';
import 'training_game_screen.dart';

/// Picks a drill and, for checkout practice, a start score - then opens a
/// training session. No name, no roster: training is always solo and never
/// saved, so there is nobody to pick and nothing to seat.
class TrainingSetupScreen extends ConsumerStatefulWidget {
  const TrainingSetupScreen({super.key});

  @override
  ConsumerState<TrainingSetupScreen> createState() =>
      _TrainingSetupScreenState();
}

class _TrainingSetupScreenState extends ConsumerState<TrainingSetupScreen> {
  TrainingDrill _drill = TrainingDrill.freePractice;
  int _startScore = 501;

  Future<void> _start() async {
    ref
        .read(trainingProvider.notifier)
        .start(drill: _drill, startScore: _startScore);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const TrainingGameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trainingSetupTitle),
        actions: const [
          RulesButton(topic: RulesTopic.training),
          BoardConnectionButton(),
          SizedBox(width: Gap.xs),
        ],
      ),
      body: SafeArea(
        child: CenteredContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.lg),
            children: [
              SectionLabel(l10n.drillLabel),
              const SizedBox(height: Gap.md),
              Column(
                key: const Key('drill-column'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DrillChoice(
                    label: l10n.freePracticeLabel,
                    tagline: l10n.freePracticeTagline,
                    selected: _drill == TrainingDrill.freePractice,
                    onTap: () =>
                        setState(() => _drill = TrainingDrill.freePractice),
                  ),
                  const SizedBox(height: Gap.sm),
                  _DrillChoice(
                    label: l10n.checkoutPracticeLabel,
                    tagline: l10n.checkoutPracticeTagline,
                    selected: _drill == TrainingDrill.checkoutPractice,
                    onTap: () =>
                        setState(() => _drill = TrainingDrill.checkoutPractice),
                  ),
                ],
              ),
              if (_drill == TrainingDrill.checkoutPractice) ...[
                const SizedBox(height: Gap.xl),
                SectionLabel(l10n.startScoreLabel),
                const SizedBox(height: Gap.md),
                NumeralChoiceRow<int>(
                  key: const Key('training-start-score-row'),
                  values: GameConfig.offeredStartScores,
                  selected: _startScore,
                  label: (score) => '$score',
                  onSelected: (score) => setState(() => _startScore = score),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: StartBar(
        buttonKey: const Key('start-training-button'),
        onPressed: _start,
        label: l10n.startButton,
      ),
    );
  }
}

/// One drill choice, as a full-width tile with a tagline underneath - the
/// same fill-when-selected idiom as `SelectableTile`, with room for the
/// second line a bare label wouldn't have.
class _DrillChoice extends StatelessWidget {
  const _DrillChoice({
    required this.label,
    required this.tagline,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String tagline;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Type.body.copyWith(
                  color: selected ? Palette.ground : Palette.chalk,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tagline,
                style: Type.label.copyWith(
                  color: selected ? Palette.ground : Palette.chalkDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
