import 'package:flutter/material.dart';

import '../../l10n_extensions.dart';
import '../../rules_topic.dart';
import '../../theme.dart';
import '../mode_glyph.dart';

/// The [Hero] tag a topic's glyph flies under, from an overview card to the
/// top of its rules page.
Object rulesGlyphTag(RulesTopic topic) => 'rules-glyph-${topic.name}';

/// The top of a rules page: the mode's glyph and name set large, the whole
/// game in one sentence, and the handful of numbers that define it -
/// `301 · 501 · 701`, `22 STOPS` - in scoreboard numerals.
///
/// [wide] puts the glyph beside the name at hero size; narrow it stays
/// beside it, smaller, so the objective is still above the fold on a phone.
class RulesHero extends StatelessWidget {
  const RulesHero({
    super.key,
    required this.topic,
    required this.wide,
    this.flight = true,
  });

  final RulesTopic topic;
  final bool wide;

  /// Whether the glyph flies in from the overview card tapped to get here
  /// ([rulesGlyphTag]). Off where both sit on one route - the desktop's rail
  /// beside its pane - since two heroes sharing a tag on a route fail the
  /// moment that route is popped.
  final bool flight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final facts = topic.facts(l10n);
    final glyph = ModeGlyph(topic: topic, size: wide ? 104 : 64);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (flight)
              Hero(tag: rulesGlyphTag(topic), child: glyph)
            else
              glyph,
            SizedBox(width: wide ? Gap.xl : Gap.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.displayName(l10n),
                    style: Type.score.copyWith(
                      fontSize: wide ? 56 : 36,
                      letterSpacing: wide ? -1.5 : -1,
                      color: Palette.chalk,
                    ),
                  ),
                  const SizedBox(height: Gap.sm),
                  Text(
                    topic.objective(l10n),
                    style: (wide ? Type.title : Type.body).copyWith(
                      color: Palette.chalkDim,
                      fontVariations: const [FontVariation('wght', 400)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Gap.xl),
        Wrap(
          spacing: Gap.xl,
          runSpacing: Gap.lg,
          children: [
            for (final fact in facts)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fact.figure,
                    style: Type.scoreSmall.copyWith(color: Palette.chalk),
                  ),
                  const SizedBox(height: Gap.xs),
                  Text(
                    fact.label,
                    style: Type.eyebrow.copyWith(color: Palette.chalkDim),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
