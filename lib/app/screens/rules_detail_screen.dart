import 'package:flutter/material.dart';

import '../l10n_extensions.dart';
import '../rules_topic.dart';
import '../theme.dart';
import '../widgets/game_layout.dart' show isHeroDevice;
import '../widgets/rules/rules_body.dart';

/// How wide a rules page may get on a device with the hero treatment: wide
/// enough to set a board beside its options and two examples side by side,
/// not so wide a line of explanation runs the length of a tablet. Scaled with
/// the type on a desktop, like every [CenteredContent] cap.
double rulesContentWidth(BuildContext context) {
  if (!isHeroDevice(context)) return formContentWidth;
  return isDesktop ? 760 : 1100;
}

/// The rules for exactly one [RulesTopic], as a [RulesBody] page.
///
/// Reached from two places: a setup screen's `RulesButton`, already knowing
/// which mode it's for, and the overview `RulesScreen` on a phone or tablet,
/// after a tap picks one. The desktop overview shows the same [RulesBody] in
/// a pane of its own instead of pushing this.
class RulesDetailScreen extends StatelessWidget {
  const RulesDetailScreen({super.key, required this.topic});

  final RulesTopic topic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(topic.title(context.l10n))),
      body: SafeArea(
        child: CenteredContent(
          maxWidth: rulesContentWidth(context),
          child: RulesBody(topic: topic),
        ),
      ),
    );
  }
}
