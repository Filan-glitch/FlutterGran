import 'package:flutter/material.dart';

import '../l10n_extensions.dart';
import '../theme.dart';

/// A static reference for what each game mode does - what a leg is racing
/// toward, and what its setup-screen rule choices actually change.
///
/// Nothing here is interactive or persisted: it exists purely to be read.
/// The setup screens themselves only ever show bare rule labels ("Straight",
/// "ANY PART") - correct for a screen you use every game, but useless the
/// one time you actually need reminding what "Master" means. This is that
/// second place.
class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rulesTitle)),
      body: SafeArea(
        child: CenteredContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.lg),
            children: [
              _Eyebrow(l10n.x01Label),
              const SizedBox(height: Gap.sm),
              _RuleParagraph(l10n.rulesX01Objective),
              _RuleParagraph(l10n.rulesX01InRule),
              _RuleParagraph(l10n.rulesX01OutRule),
              _RuleParagraph(l10n.rulesX01Format),
              const SizedBox(height: Gap.lg),
              _Eyebrow(l10n.aroundTheClockLabel),
              const SizedBox(height: Gap.sm),
              _RuleParagraph(l10n.rulesAtcObjective),
              _RuleParagraph(l10n.rulesAtcVariant),
              const SizedBox(height: Gap.lg),
              _Eyebrow(l10n.bullingLabel),
              const SizedBox(height: Gap.sm),
              _RuleParagraph(l10n.rulesBullingObjective),
              _RuleParagraph(l10n.rulesBullingValue),
              const SizedBox(height: Gap.lg),
              _Eyebrow(l10n.trainingSetupTitle),
              const SizedBox(height: Gap.sm),
              _RuleParagraph(l10n.rulesTrainingFreePractice),
              _RuleParagraph(l10n.rulesTrainingCheckoutPractice),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section heading, in the settings screen's uppercase-eyebrow idiom
/// (`settings_screen.dart`'s `_Eyebrow`) - each screen keeps its own copy of
/// this rather than sharing one private widget across files.
class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: Type.eyebrow.copyWith(color: Palette.chalkDim),
  );
}

/// One block of explanatory copy under a mode's heading.
class _RuleParagraph extends StatelessWidget {
  const _RuleParagraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Gap.sm),
    child: Text(text, style: Type.body.copyWith(color: Palette.chalk)),
  );
}
