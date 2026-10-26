import 'package:flutter/material.dart';

import '../../../domain/segment.dart';
import '../../theme.dart';

/// One dart in a [WorkedExample]: where it landed and what the scoreboard
/// read after it.
///
/// [counts] false marks the dart the example is about - the single that does
/// not finish, the dart that busts - and draws its figure in
/// [Palette.doubleBed].
typedef ExampleDart = ({Segment segment, String after, bool counts});

/// How a [WorkedExample] ends: a finish in [Palette.live], a bust in
/// [Palette.doubleBed].
enum ExampleOutcome { good, bust }

/// A turn played out dart by dart - `40 LEFT: D20 → 0, GAME SHOT` - because
/// one real example says what a paragraph about the out rule cannot.
///
/// The darts are the game screen's own notation (`T20`, `DB`), taken from
/// [Segment.label] rather than translated, and arrive one after another the
/// way they would off the board.
class WorkedExample extends StatelessWidget {
  const WorkedExample({
    super.key,
    required this.caption,
    required this.start,
    required this.darts,
    required this.outcome,
    required this.outcomeLabel,
    required this.note,
  });

  /// The situation, in small capitals: `40 LEFT`, `ON 5 · MASTERS`.
  final String caption;

  /// The figure before the first dart.
  final String start;

  final List<ExampleDart> darts;
  final ExampleOutcome outcome;
  final String outcomeLabel;

  /// Why it ended that way, in a sentence.
  final String note;

  @override
  Widget build(BuildContext context) {
    final tone = switch (outcome) {
      ExampleOutcome.good => Palette.live,
      ExampleOutcome.bust => Palette.doubleBed,
    };

    return Container(
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(
        color: Palette.sunk,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Palette.edge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  caption,
                  style: Type.eyebrow.copyWith(color: Palette.chalkDim),
                ),
              ),
              const SizedBox(width: Gap.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Gap.sm,
                  vertical: Gap.xs,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: tone),
                ),
                child: Text(
                  outcomeLabel,
                  style: Type.eyebrow.copyWith(color: tone),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                start,
                style: Type.scoreSmall.copyWith(color: Palette.chalk),
              ),
              for (var i = 0; i < darts.length; i++) ...[
                const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Palette.chalkDim,
                ),
                StaggeredEntry(
                  index: i + 1,
                  child: _Dart(dart: darts[i]),
                ),
              ],
            ],
          ),
          const SizedBox(height: Gap.md),
          Text(note, style: Type.label.copyWith(color: Palette.chalkDim)),
        ],
      ),
    );
  }
}

class _Dart extends StatelessWidget {
  const _Dart({required this.dart});

  final ExampleDart dart;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.sm,
            vertical: Gap.xs,
          ),
          decoration: BoxDecoration(
            color: Palette.raised,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Palette.edge),
          ),
          child: Text(
            dart.segment.label,
            style: Type.notation.copyWith(color: Palette.chalk),
          ),
        ),
        const SizedBox(height: Gap.xs),
        Text(
          dart.after,
          style: Type.notation.copyWith(
            fontSize: 15,
            color: dart.counts ? Palette.chalkDim : Palette.doubleBed,
          ),
        ),
      ],
    );
  }
}
