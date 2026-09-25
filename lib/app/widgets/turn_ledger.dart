import 'package:flutter/material.dart';

import '../../domain/x01/leg_state.dart' show dartsPerTurn;
import '../../domain/x01/thrown_dart.dart';
import '../l10n_extensions.dart';
import '../theme.dart';

/// The turn in progress, written out dart by dart with a running total.
///
/// This is the chalk line a scorer keeps beside the board: three marks and what
/// they add up to. When a turn busts the marks are struck through in red, which
/// is exactly how it is scored on a board, and is legible at a glance from the
/// oche in a way that a word never is.
///
/// Every game keeps the same line. Only what [total] counts changes - points
/// scored, stops cleared - and the game says that in its own terms.
class TurnLedger extends StatelessWidget {
  const TurnLedger({
    super.key,
    required this.darts,
    required this.total,
    this.struck = false,
  });

  final List<ThrownDart> darts;

  /// What the darts so far add up to, already written the way the game
  /// counts it.
  final String total;

  /// A bust: the marks are struck and the total reads as one.
  final bool struck;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.md),
      child: Row(
        children: [
          for (var i = 0; i < dartsPerTurn; i++) ...[
            if (i > 0) const SizedBox(width: Gap.sm),
            Expanded(
              child: DartSlot(
                dart: i < darts.length ? darts[i] : null,
                struck: struck,
              ),
            ),
          ],
          const SizedBox(width: Gap.lg),
          ConstrainedBox(
            // Room for 180 at the current type size, and no more: the slots
            // beside it are what should take the rest of the row.
            constraints: const BoxConstraints(minWidth: 72),
            child: Text(
              struck ? context.l10n.bustLabel : total,
              textAlign: TextAlign.right,
              style: struck
                  ? Type.notation.copyWith(color: Palette.doubleBed)
                  : Type.scoreSmall.copyWith(
                      color: darts.isEmpty ? Palette.chalkDim : Palette.live,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One dart of the turn, or the dot of one still to come.
class DartSlot extends StatelessWidget {
  const DartSlot({super.key, required this.dart, this.struck = false});

  final ThrownDart? dart;
  final bool struck;

  @override
  Widget build(BuildContext context) {
    final empty = dart == null;

    return Container(
      // A floor rather than a height: the notation inside it grows with the
      // platform's text size and with the viewport, and a box that could not
      // follow it would clip the dart it is there to show.
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(vertical: Gap.xs),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: empty ? Palette.sunk : Palette.raised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Palette.edge),
      ),
      child: Text(
        empty ? '·' : dart!.label,
        style: Type.notation.copyWith(
          color: empty
              ? Palette.chalkDim
              : struck
              ? Palette.doubleBed
              : Palette.chalk,
          decoration: struck ? TextDecoration.lineThrough : null,
          decorationColor: Palette.doubleBed,
          decorationThickness: 2,
        ),
      ),
    );
  }
}
