import 'package:flutter/material.dart';

import '../l10n_extensions.dart';
import '../rules_topic.dart';
import '../theme.dart';

/// The detailed rules for exactly one [RulesTopic] - what a setup screen's
/// info button opens now that it no longer has to open the same page every
/// other mode's setup screen does too.
///
/// Reached from two places: a setup screen's `RulesButton`, already knowing
/// which mode it's for, and the overview `RulesScreen`, after a tap picks
/// one. Either way the content is the same - the split is scope, not
/// audience.
class RulesDetailScreen extends StatelessWidget {
  const RulesDetailScreen({super.key, required this.topic});

  final RulesTopic topic;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(topic.title(l10n))),
      body: SafeArea(
        child: CenteredContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.lg),
            children: switch (topic) {
              RulesTopic.x01 => [
                _RuleParagraph(l10n.rulesX01Objective),
                _RuleParagraph(l10n.rulesX01InRule),
                _RuleParagraph(l10n.rulesX01OutRule),
                _RuleParagraph(l10n.rulesX01Format),
              ],
              RulesTopic.aroundTheClock => [
                _RuleParagraph(l10n.rulesAtcObjective),
                _RuleParagraph(l10n.rulesAtcVariant),
              ],
              RulesTopic.bulling => [
                _RuleParagraph(l10n.rulesBullingObjective),
                _RuleParagraph(l10n.rulesBullingValue),
              ],
              RulesTopic.training => [
                _RuleParagraph(l10n.rulesTrainingFreePractice),
                _RuleParagraph(l10n.rulesTrainingCheckoutPractice),
              ],
            },
          ),
        ),
      ),
    );
  }
}

/// One block of explanatory copy. Moved from the old monolithic
/// `RulesScreen`, which no longer needs it - a detail page's `AppBar`
/// already names the mode, so no `_Eyebrow` heading is needed here too.
class _RuleParagraph extends StatelessWidget {
  const _RuleParagraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Gap.sm),
    child: Text(text, style: Type.body.copyWith(color: Palette.chalk)),
  );
}
