import 'package:flutter/material.dart';

import '../l10n_extensions.dart';
import '../rules_topic.dart';
import '../screens/rules_detail_screen.dart';

/// One tap to the rules reference for [topic], from wherever a setup
/// screen's rule choices (in/out rule, ATC variant, bullseye value) are
/// actually made.
///
/// A shared widget rather than a `Navigator.push` repeated on every setup
/// screen's `AppBar`, the same reasoning as `BoardConnectionButton`: one
/// place to own the icon, with only the destination's topic varying by
/// caller.
class RulesButton extends StatelessWidget {
  const RulesButton({super.key, required this.topic});

  final RulesTopic topic;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return IconButton(
      tooltip: l10n.rulesMenuLabel,
      icon: const Icon(Icons.help_outline),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => RulesDetailScreen(topic: topic),
        ),
      ),
    );
  }
}
