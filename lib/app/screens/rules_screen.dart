import 'package:flutter/material.dart';

import '../l10n_extensions.dart';
import '../rules_topic.dart';
import '../theme.dart';
import 'rules_detail_screen.dart';

/// A quick "which mode does what" picker, reached from the main menu.
///
/// Deliberately shallow: one icon and one line per mode, nothing to read
/// here beyond deciding where to go. Full detail - what "Master" means,
/// what busts a leg - lives one tap away in [RulesDetailScreen], the same
/// screen a setup screen's info button opens directly for whichever mode
/// it's already for.
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
              for (final topic in RulesTopic.values)
                _RulesTopicRow(topic: topic),
            ],
          ),
        ),
      ),
    );
  }
}

/// One mode's picker row, in the same chrome as `main_menu_screen.dart`'s
/// `_MenuRow`.
class _RulesTopicRow extends StatelessWidget {
  const _RulesTopicRow({required this.topic});

  final RulesTopic topic;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Palette.edge),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('rules-overview-${topic.name}'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => RulesDetailScreen(topic: topic),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.lg,
              vertical: Gap.md,
            ),
            child: Row(
              children: [
                Icon(topic.icon, size: 20, color: Palette.chalkDim),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Text(
                    topic.overview(l10n),
                    style: Type.body.copyWith(color: Palette.chalk),
                  ),
                ),
                const SizedBox(width: Gap.md),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Palette.chalkDim,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
