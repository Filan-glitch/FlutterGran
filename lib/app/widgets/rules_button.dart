import 'package:flutter/material.dart';

import '../l10n_extensions.dart';
import '../rules_topic.dart';
import '../screens/rules_detail_screen.dart';

/// An app-bar button that opens the rules page for [topic], on each setup
/// screen next to the choices those rules explain.
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
