import 'package:flutter/material.dart';

import '../../theme.dart';

/// What a [RuleCallout] is warning about: a bust is the board's red, a plain
/// note the live green.
enum CalloutTone { bust, note }

/// A rule worth stopping on - what busts a turn, a leg that ends mid-turn -
/// set apart from the page in a bordered card, its conditions as a short
/// numbered list rather than a sentence held together by semicolons.
class RuleCallout extends StatelessWidget {
  const RuleCallout({
    super.key,
    required this.tone,
    required this.title,
    this.points = const [],
    this.footer,
  });

  final CalloutTone tone;
  final String title;
  final List<String> points;

  /// What happens once it applies, under the list.
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final (colour, icon) = switch (tone) {
      CalloutTone.bust => (Palette.doubleBed, Icons.block),
      CalloutTone.note => (Palette.live, Icons.bolt),
    };
    final footer = this.footer;

    return Container(
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: Palette.raised,
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: colour, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colour),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Text(
                  title,
                  style: Type.eyebrow.copyWith(color: colour, fontSize: 12),
                ),
              ),
            ],
          ),
          for (var i = 0; i < points.length; i++) ...[
            const SizedBox(height: Gap.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${i + 1}',
                    style: Type.scoreSmall.copyWith(
                      fontSize: 22,
                      color: colour,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    points[i],
                    style: Type.body.copyWith(color: Palette.chalk),
                  ),
                ),
              ],
            ),
          ],
          if (footer != null) ...[
            SizedBox(height: points.isEmpty ? Gap.sm : Gap.lg),
            Text(
              footer,
              style: Type.body.copyWith(
                color: points.isEmpty ? Palette.chalk : Palette.chalkDim,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
