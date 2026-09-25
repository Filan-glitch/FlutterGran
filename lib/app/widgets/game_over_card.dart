import 'package:flutter/material.dart';

import '../l10n_extensions.dart';
import '../theme.dart';
import 'outcome_panel.dart';

/// One player's column of figures on the [GameOverCard].
///
/// [figures] keep their rows whether or not the values are in yet: a value
/// still being worked out is written `—`, so the card neither jumps nor claims
/// a total it has not got.
typedef FigureColumn = ({
  String name,
  bool won,
  List<({String label, String value})> figures,
});

/// The end of a game, over the board it was won on.
///
/// Not quite opaque: the scoreboard reads through it, which is what says this
/// happened here rather than somewhere else. Every mode ends the same way -
/// the winner, each player's figures side by side, go again or go back.
class GameOverCard extends StatelessWidget {
  const GameOverCard({
    super.key,
    required this.eyebrow,
    required this.winnerName,
    required this.columns,
    required this.primary,
    required this.onExit,
    this.subtitle,
    this.figuresKey,
    this.error,
  });

  final String eyebrow;
  final String winnerName;

  /// Under the winner's name - the legs tally of a match.
  final String? subtitle;

  final List<FigureColumn> columns;

  /// On the block of figures, so a test can ask what it says without catching
  /// the scoreboard showing the same numbers behind it.
  final Key? figuresKey;

  /// Said in red under the figures when some of them could not be worked out.
  final String? error;

  /// Play the same thing again.
  final PanelAction primary;

  /// Back to where this game was set up.
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final error = this.error;

    return ColoredBox(
      color: Palette.ground.withValues(alpha: 0.95),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Gap.xl),
          child: EntrancePop(
            child: Column(
              children: [
                Text(
                  eyebrow,
                  style: Type.eyebrow.copyWith(color: Palette.live),
                ),
                const SizedBox(height: Gap.md),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    winnerName.toUpperCase(),
                    style: Type.score.copyWith(color: Palette.chalk),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: Gap.sm),
                  Text(
                    subtitle,
                    style: Type.scoreSmall.copyWith(color: Palette.chalkDim),
                  ),
                ],
                const SizedBox(height: Gap.xl),
                IntrinsicHeight(
                  key: figuresKey,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < columns.length; i++) ...[
                        if (i > 0) const VerticalDivider(width: 1),
                        Expanded(child: _Figures(column: columns[i])),
                      ],
                    ],
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: Gap.md),
                  Text(
                    error,
                    style: Type.eyebrow.copyWith(color: Palette.doubleBed),
                  ),
                ],
                const SizedBox(height: Gap.xl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: primary.key,
                    onPressed: primary.onPressed,
                    child: Text(primary.label),
                  ),
                ),
                const SizedBox(height: Gap.sm),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onExit,
                    child: Text(context.l10n.backToSetupButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One player's game, as a column of figures under their name.
class _Figures extends StatelessWidget {
  const _Figures({required this.column});

  final FigureColumn column;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            column.name.toUpperCase(),
            style: Type.eyebrow.copyWith(
              color: column.won ? Palette.chalk : Palette.chalkDim,
            ),
          ),
          const SizedBox(height: Gap.md),
          for (final figure in column.figures)
            FigureRow(label: figure.label, value: figure.value),
        ],
      ),
    );
  }
}

/// A label and its number, on one line, in the statistics screen's idiom.
class FigureRow extends StatelessWidget {
  const FigureRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: Type.label.copyWith(color: Palette.chalkDim),
            ),
          ),
          const SizedBox(width: Gap.sm),
          Text(value, style: Type.data.copyWith(color: Palette.chalk)),
        ],
      ),
    );
  }
}
