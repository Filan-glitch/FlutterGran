import 'package:flutter/material.dart';

import '../theme.dart';
import 'turn_result.dart';

/// A button on an end-of-something panel: what it says, what it does, and a
/// key for a test to find it by.
typedef PanelAction = ({String label, VoidCallback onPressed, Key? key});

/// Something just ended - a leg in a running match, a checkout attempt - in
/// the space the keypad has just given up.
///
/// A checkpoint rather than an ending, so it stays small and says only what
/// happened and what the next thing to do is. A game that is over for good
/// gets `GameOverCard` over the top instead.
class OutcomePanel extends StatelessWidget {
  const OutcomePanel({
    super.key,
    required this.eyebrow,
    required this.headline,
    required this.detail,
    this.footer,
    this.primary,
    this.secondary,
  });

  /// What ended, e.g. LEG WON.
  final String eyebrow;

  /// Set at scoreboard size: who won it, what was checked out.
  final String headline;

  /// The one line of figures under it.
  final String detail;

  /// Where things stand now, just above the actions.
  final String? footer;

  final PanelAction? primary;
  final PanelAction? secondary;

  @override
  Widget build(BuildContext context) {
    final primary = this.primary;
    final secondary = this.secondary;
    final footer = this.footer;

    return FitOrScroll(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.xl, Gap.xl, Gap.lg),
        child: EntrancePop(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                eyebrow,
                style: Type.eyebrow.copyWith(color: Palette.trebleBed),
              ),
              const SizedBox(height: Gap.md),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  headline,
                  style: Type.score.copyWith(color: Palette.chalk),
                ),
              ),
              const SizedBox(height: Gap.lg),
              Text(detail, style: Type.label.copyWith(color: Palette.chalkDim)),
              if (footer != null || primary != null || secondary != null)
                const Spacer(),
              if (footer != null) ...[
                Text(
                  footer,
                  textAlign: TextAlign.center,
                  style: Type.eyebrow.copyWith(color: Palette.chalkDim),
                ),
                const SizedBox(height: Gap.md),
              ],
              if (primary != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: primary.key,
                    onPressed: primary.onPressed,
                    child: Text(primary.label),
                  ),
                ),
              if (secondary != null) ...[
                const SizedBox(height: Gap.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    key: secondary.key,
                    onPressed: secondary.onPressed,
                    child: Text(secondary.label),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
