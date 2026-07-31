import 'package:flutter/material.dart';

import '../../domain/segment.dart';
import '../theme.dart';

/// Entering a dart takes two decisions: which ring, then which wedge.
///
/// A plain 0-9 keypad is the wrong shape for darts - nobody thinks "sixty",
/// they think "treble twenty". So the ring is a mode and the wedges are the
/// keys, which is also what makes a single tap enough for the common case.
///
/// The keys take the colour of the ring they will enter, straight from the
/// board: green for a treble bed, red for a double. Switching mode repaints the
/// whole pad, so what a tap will do is visible from throwing distance without
/// reading the selector.
class DartKeypad extends StatefulWidget {
  const DartKeypad({
    super.key,
    required this.onDart,
    required this.onMiss,
    this.highlight = const {},
  });

  final ValueChanged<Segment> onDart;
  final VoidCallback onMiss;

  /// Segments the checkout suggestion is aiming at. The matching keys are
  /// outlined, so the advice can be followed without reading it.
  final Set<Segment> highlight;

  @override
  State<DartKeypad> createState() => _DartKeypadState();
}

class _DartKeypadState extends State<DartKeypad> {
  /// Which ring the next wedge key means.
  Ring _ring = Ring.outerSingle;

  void _enter(Segment segment) {
    widget.onDart(segment);
    // Back to singles after every dart: trebles and doubles are the exception,
    // and a sticky modifier is how you end up recording T5 by accident.
    if (_ring != Ring.outerSingle) {
      setState(() => _ring = Ring.outerSingle);
    }
  }

  bool _isHighlighted(int number) =>
      widget.highlight.contains(Segment(number, _ring));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<Ring>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: Ring.outerSingle, label: Text('SINGLE')),
              ButtonSegment(value: Ring.doubleRing, label: Text('DOUBLE')),
              ButtonSegment(value: Ring.triple, label: Text('TREBLE')),
            ],
            selected: {_ring},
            onSelectionChanged: (selection) =>
                setState(() => _ring = selection.first),
          ),
        ),
        const SizedBox(height: Gap.sm),
        // Rows of Expanded keys rather than a GridView: the keys have to fill
        // exactly the space available and never scroll. A grid with square
        // cells needs more height than a phone has, so the bottom row ends up
        // clipped off the screen.
        Expanded(
          child: Column(
            children: [
              for (var row = 0; row < 4; row++) ...[
                if (row > 0) const SizedBox(height: Gap.xs + 2),
                Expanded(
                  child: Row(
                    children: [
                      for (var column = 0; column < 5; column++) ...[
                        if (column > 0) const SizedBox(width: Gap.xs + 2),
                        Builder(
                          builder: (context) {
                            final number = row * 5 + column + 1;
                            return Expanded(
                              child: _Key(
                                label: '$number',
                                ring: _ring,
                                highlighted: _isHighlighted(number),
                                onTap: () => _enter(Segment(number, _ring)),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Gap.xs + 2),
        SizedBox(
          height: 52,
          child: Row(
            children: [
              Expanded(
                child: _Key(
                  label: '25',
                  ring: Ring.outerBull,
                  highlighted: widget.highlight.contains(Segment.outerBull),
                  onTap: () => _enter(Segment.outerBull),
                ),
              ),
              const SizedBox(width: Gap.xs + 2),
              Expanded(
                child: _Key(
                  label: 'BULL',
                  ring: Ring.innerBull,
                  highlighted: widget.highlight.contains(Segment.innerBull),
                  onTap: () => _enter(Segment.innerBull),
                ),
              ),
              const SizedBox(width: Gap.xs + 2),
              Expanded(
                flex: 2,
                child: _Key(
                  label: 'MISS',
                  ring: null,
                  highlighted: false,
                  onTap: widget.onMiss,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.label,
    required this.ring,
    required this.highlighted,
    required this.onTap,
  });

  final String label;

  /// The ring this key will enter, which decides its colour. Null for Miss,
  /// which enters nothing.
  final Ring? ring;

  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (ring) {
      Ring.doubleRing || Ring.innerBull => (
        Palette.doubleBed,
        Palette.chalk,
      ),
      Ring.triple || Ring.outerBull => (Palette.trebleBed, Palette.chalk),
      null => (Palette.slateSunk, Palette.chalkDim),
      _ => (Palette.slateRaised, Palette.chalk),
    };

    return Semantics(
      button: true,
      // Carries the checkout highlight to assistive tech, which otherwise has
      // no way to convey an outlined key.
      selected: highlighted,
      label: switch (ring) {
        Ring.doubleRing => 'double $label',
        Ring.triple => 'treble $label',
        _ => label,
      },
      child: Material(
        color: background,
        clipBehavior: Clip.antiAlias,
        // Shape rather than borderRadius, and always set: Material asserts if
        // both are given, so a highlighted key would otherwise throw the moment
        // a checkout suggestion lit one up.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: highlighted
              ? const BorderSide(color: Palette.oche, width: 2.5)
              : BorderSide(color: Palette.edge.withValues(alpha: 0.6)),
        ),
        child: InkWell(
          onTap: onTap,
          splashColor: Palette.chalk.withValues(alpha: 0.12),
          highlightColor: Palette.chalk.withValues(alpha: 0.06),
          child: Center(
            child: Text(
              label,
              style: Type.key.copyWith(color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}
