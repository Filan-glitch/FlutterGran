import 'package:flutter/material.dart';

import '../l10n_extensions.dart';
import '../screens/rules_screen.dart';

/// One tap to the rules reference, from wherever a setup screen's rule
/// choices (in/out rule, ATC variant, bullseye value) are actually made.
///
/// A shared widget rather than a `Navigator.push` repeated on every setup
/// screen's `AppBar`, the same reasoning as `BoardConnectionButton`: one
/// place to own the icon and its destination.
class RulesButton extends StatelessWidget {
  const RulesButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return IconButton(
      tooltip: l10n.rulesMenuLabel,
      icon: const Icon(Icons.help_outline),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (context) => const RulesScreen()),
      ),
    );
  }
}
