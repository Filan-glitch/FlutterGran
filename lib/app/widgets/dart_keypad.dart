import 'package:flutter/material.dart';

import '../../domain/segment.dart';

/// Entering a dart takes two decisions: which ring, then which wedge.
///
/// A plain 0-9 keypad is the wrong shape for darts - nobody thinks "sixty",
/// they think "treble twenty". So the ring is a mode and the wedges are the
/// keys, which is also what makes a single tap enough for the common case.
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
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SegmentedButton<Ring>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: Ring.outerSingle, label: Text('Single')),
            ButtonSegment(value: Ring.doubleRing, label: Text('Double')),
            ButtonSegment(value: Ring.triple, label: Text('Treble')),
          ],
          selected: {_ring},
          onSelectionChanged: (selection) =>
              setState(() => _ring = selection.first),
        ),
        const SizedBox(height: 8),
        // Rows of Expanded keys rather than a GridView: the keys have to fill
        // exactly the space available and never scroll. A grid with square
        // cells needs more height than a phone has, so the bottom row ends up
        // clipped off the screen.
        Expanded(
          child: Column(
            children: [
              for (var row = 0; row < 4; row++) ...[
                if (row > 0) const SizedBox(height: 6),
                Expanded(
                  child: Row(
                    children: [
                      for (var column = 0; column < 5; column++) ...[
                        if (column > 0) const SizedBox(width: 6),
                        Builder(
                          builder: (context) {
                            final number = row * 5 + column + 1;
                            return Expanded(
                              child: _Key(
                                label: '$number',
                                emphasis: _ring,
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
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _Key(
                label: '25',
                emphasis: Ring.outerBull,
                highlighted: widget.highlight.contains(Segment.outerBull),
                onTap: () => _enter(Segment.outerBull),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _Key(
                label: 'Bull',
                emphasis: Ring.innerBull,
                highlighted: widget.highlight.contains(Segment.innerBull),
                onTap: () => _enter(Segment.innerBull),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: widget.onMiss,
                icon: const Icon(Icons.not_interested, size: 18),
                label: const Text('Miss'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.label,
    required this.emphasis,
    required this.highlighted,
    required this.onTap,
  });

  final String label;

  /// Colours the key by ring, so the active mode is obvious without reading
  /// the selector - the same red and green as the board itself.
  final Ring emphasis;

  final bool highlighted;
  final VoidCallback onTap;

  static const Color _double = Color(0xFFC0392B);
  static const Color _treble = Color(0xFF1E8449);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (background, foreground) = switch (emphasis) {
      Ring.doubleRing => (_double, Colors.white),
      Ring.triple => (_treble, Colors.white),
      Ring.innerBull => (_double, Colors.white),
      Ring.outerBull => (_treble, Colors.white),
      _ => (
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.onSurface,
      ),
    };

    return Semantics(
      button: true,
      // Carries the checkout highlight to assistive tech, which otherwise has
      // no way to convey a coloured border.
      selected: highlighted,
      label: switch (emphasis) {
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
          borderRadius: BorderRadius.circular(10),
          side: highlighted
              ? BorderSide(color: theme.colorScheme.primary, width: 3)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.titleLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
