/// [TrainingSetupScreen], which picks a drill and its settings.
///
/// {@category App}
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/training/bobs_27.dart';
import '../../domain/training/checkout_challenge.dart';
import '../../domain/training/ladder_121.dart';
import '../../domain/training/training_drill.dart';
import '../../domain/training/weak_spot.dart';
import '../../domain/x01/x01_rules.dart';
import '../l10n_extensions.dart';
import '../labels.dart';
import '../providers.dart';
import '../rules_topic.dart';
import '../theme.dart';
import '../training_controller.dart';
import '../widgets/board_connection_button.dart';
import '../widgets/player_picker.dart';
import '../widgets/rules_button.dart';
import '../widgets/setup_controls.dart';
import 'training_game_screen.dart';

/// Rounds a drill with rounds can be set to.
const List<int> offeredTrainingRounds = [10, 20];

/// Picks a drill and its settings, then opens a training session.
///
/// Training is always solo and never saved, so only the Weak-spot Trainer
/// asks for a player - and only to read their saved games, never to write.
class TrainingSetupScreen extends ConsumerStatefulWidget {
  const TrainingSetupScreen({super.key});

  @override
  ConsumerState<TrainingSetupScreen> createState() =>
      _TrainingSetupScreenState();
}

class _TrainingSetupScreenState extends ConsumerState<TrainingSetupScreen> {
  TrainingDrill _drill = TrainingDrill.freePractice;
  int _rounds = offeredTrainingRounds.first;

  // Checkout Challenge. A null band is adaptive.
  CheckoutBand? _band;
  X01OutRule _outRule = X01OutRule.double;
  bool _showRoute = true;

  int _ladderStart = 121;

  bool _playToEnd = false;

  WeakSpotFocus _focus = WeakSpotFocus.doubles;
  int? _playerId;

  TrainingPlan _plan() => switch (_drill) {
    TrainingDrill.freePractice => const FreePracticePlan(),
    TrainingDrill.checkoutChallenge => CheckoutChallengePlan(
      CheckoutChallengeConfig(
        outRule: _outRule,
        band: _band,
        rounds: _rounds,
        showRoute: _showRoute,
      ),
    ),
    TrainingDrill.ladder121 => Ladder121Plan(
      Ladder121Config(startScore: _ladderStart, rounds: _rounds),
    ),
    TrainingDrill.bobs27 => Bobs27Plan(Bobs27Config(playToEnd: _playToEnd)),
    TrainingDrill.weakSpot => WeakSpotPlan(
      WeakSpotConfig(
        focus: _focus,
        rounds: _rounds,
        history: switch (_playerId) {
          null => const {},
          final id => ref.read(aimRecordsProvider(id)),
        },
      ),
    ),
  };

  Future<void> _start() async {
    ref.read(trainingProvider.notifier).start(_plan());

    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const TrainingGameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Keeps the chosen player's history loading while setup is open, so it
    // is ready by the time Start is tapped.
    if (_playerId case final id?) ref.watch(aimRecordsProvider(id));

    Widget drill(TrainingDrill value, String label, String tagline) => Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: _DrillChoice(
        key: Key('drill-${value.name}'),
        label: label,
        tagline: tagline,
        selected: _drill == value,
        onTap: () => setState(() => _drill = value),
      ),
    );

    List<Widget> option(String label, Widget control) => [
      const SizedBox(height: Gap.xl),
      SectionLabel(label),
      const SizedBox(height: Gap.md),
      control,
    ];

    final rounds = option(
      l10n.roundsLabel,
      NumeralChoiceRow<int>(
        key: const Key('training-rounds-row'),
        values: offeredTrainingRounds,
        selected: _rounds,
        label: (rounds) => '$rounds',
        onSelected: (rounds) => setState(() => _rounds = rounds),
      ),
    );

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
                  drill(
                    TrainingDrill.freePractice,
                    l10n.freePracticeLabel,
                    l10n.freePracticeTagline,
                  ),
                  drill(
                    TrainingDrill.checkoutChallenge,
                    l10n.checkoutChallengeLabel,
                    l10n.checkoutChallengeTagline,
                  ),
                  drill(
                    TrainingDrill.ladder121,
                    l10n.ladder121Label,
                    l10n.ladder121Tagline,
                  ),
                  drill(
                    TrainingDrill.bobs27,
                    l10n.bobs27Label,
                    l10n.bobs27Tagline,
                  ),
                  drill(
                    TrainingDrill.weakSpot,
                    l10n.weakSpotLabel,
                    l10n.weakSpotTagline,
                  ),
                ],
              ),
              ...switch (_drill) {
                TrainingDrill.freePractice => const <Widget>[],
                TrainingDrill.checkoutChallenge => [
                  ...option(
                    l10n.difficultyLabel,
                    ChoiceRow<CheckoutBand?>(
                      key: const Key('training-band-row'),
                      values: [null, ...CheckoutBand.presets],
                      selected: _band,
                      label: (band) => band == null
                          ? l10n.difficultyAdaptive
                          : '${band.min}–${band.max}',
                      onSelected: (band) => setState(() => _band = band),
                    ),
                  ),
                  ...option(
                    l10n.outRuleLabel,
                    ChoiceRow<X01OutRule>(
                      values: X01OutRule.values,
                      selected: _outRule,
                      label: (rule) => x01OutRuleLabel(context, rule),
                      onSelected: (rule) => setState(() => _outRule = rule),
                    ),
                  ),
                  ...option(
                    l10n.routeHintLabel,
                    ChoiceRow<bool>(
                      key: const Key('training-route-row'),
                      values: const [true, false],
                      selected: _showRoute,
                      label: (show) =>
                          show ? l10n.routeShown : l10n.routeAfterVisit,
                      onSelected: (show) => setState(() => _showRoute = show),
                    ),
                  ),
                  ...rounds,
                ],
                TrainingDrill.ladder121 => [
                  ...option(
                    l10n.startScoreLabel,
                    NumeralChoiceRow<int>(
                      key: const Key('training-ladder-start-row'),
                      values: Ladder121Config.offeredStartScores,
                      selected: _ladderStart,
                      label: (score) => '$score',
                      onSelected: (score) =>
                          setState(() => _ladderStart = score),
                    ),
                  ),
                  ...rounds,
                ],
                TrainingDrill.bobs27 => option(
                  l10n.bobs27DropOutLabel,
                  ChoiceRow<bool>(
                    key: const Key('training-play-to-end-row'),
                    values: const [false, true],
                    selected: _playToEnd,
                    label: (playOn) =>
                        playOn ? l10n.bobs27PlayOn : l10n.bobs27StopAtZero,
                    onSelected: (playOn) => setState(() => _playToEnd = playOn),
                  ),
                ),
                TrainingDrill.weakSpot => [
                  ...option(
                    l10n.focusLabel,
                    ChoiceRow<WeakSpotFocus>(
                      key: const Key('training-focus-row'),
                      values: WeakSpotFocus.values,
                      selected: _focus,
                      label: (focus) => weakSpotFocusLabel(context, focus),
                      onSelected: (focus) => setState(() => _focus = focus),
                    ),
                  ),
                  ...rounds,
                  ...option(
                    l10n.trainingPlayerLabel,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.trainingPlayerHint,
                          style: Type.label.copyWith(color: Palette.chalkDim),
                        ),
                        const SizedBox(height: Gap.sm),
                        PlayerPicker(
                          seats: [?_playerId],
                          // One player at most: tapping another swaps.
                          onChanged: (seats) => setState(
                            () => _playerId = seats.isEmpty ? null : seats.last,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              },
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
    super.key,
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
