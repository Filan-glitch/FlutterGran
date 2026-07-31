import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/segment.dart';

/// Wedge numbers clockwise from the top, as they appear on a real board.
const List<int> boardWedgeOrder = [
  20, 1, 18, 4, 13, 6, 10, 15, 2, 17, //
  3, 19, 7, 16, 8, 11, 14, 9, 12, 5,
];

/// Ring boundaries as a fraction of the double ring's outer radius, taken from
/// standard board dimensions.
abstract final class BoardGeometry {
  static const double doubleOuter = 1.0;
  static const double doubleInner = 0.94;
  static const double tripleOuter = 0.629;
  static const double tripleInner = 0.583;
  static const double outerBullEdge = 0.094;
  static const double innerBullEdge = 0.0375;

  /// Radians each wedge spans.
  static const double wedgeSweep = 2 * pi / 20;

  /// Angle of the centre of the wedge at [index], with 0 pointing right and
  /// angles increasing clockwise (screen coordinates, y downwards).
  static double wedgeCentre(int index) => -pi / 2 + index * wedgeSweep;

  /// Which segment a point falls in, or null for a miss outside the board.
  ///
  /// [radius] is the double ring's outer radius; [offset] is measured from the
  /// board centre.
  static Segment? segmentAt(Offset offset, double radius) {
    if (radius <= 0) return null;
    final distance = offset.distance / radius;

    if (distance <= innerBullEdge) return Segment.innerBull;
    if (distance <= outerBullEdge) return Segment.outerBull;
    if (distance > doubleOuter) return null;

    // Rotate so the 20 sits at zero, then bias by half a wedge so the wedge a
    // point belongs to is a plain division rather than a range check.
    final angle = atan2(offset.dy, offset.dx) + pi / 2 + wedgeSweep / 2;
    final turns = angle / (2 * pi);
    final index = ((turns - turns.floor()) * 20).floor() % 20;
    final number = boardWedgeOrder[index];

    if (distance < tripleInner) return Segment(number, Ring.innerSingle);
    if (distance <= tripleOuter) return Segment(number, Ring.triple);
    if (distance < doubleInner) return Segment(number, Ring.outerSingle);
    return Segment(number, Ring.doubleRing);
  }
}

/// A dartboard that can be tapped, highlighted, and shaded.
///
/// One widget covers three jobs: entering a dart by hand when the board misread
/// one, showing where darts actually land, and picking the segment a frame code
/// really means during calibration.
class BoardWidget extends StatelessWidget {
  const BoardWidget({
    super.key,
    this.onSegmentTapped,
    this.onMissTapped,
    this.highlight = const {},
    this.heat = const {},
    this.showNumbers = true,
  });

  /// Called with the segment under the tap.
  final ValueChanged<Segment>? onSegmentTapped;

  /// Called when the tap lands outside the scoring area.
  final VoidCallback? onMissTapped;

  /// Segments to outline - the darts a checkout suggestion is aiming at.
  final Set<Segment> highlight;

  /// Per-segment intensity from 0 to 1, shaded over the board.
  final Map<Segment, double> heat;

  final bool showNumbers;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = min(constraints.maxWidth, constraints.maxHeight);
        // Leave room outside the double ring for the numbers.
        final radius = side / 2 * (showNumbers ? 0.86 : 0.98);

        // The SizedBox is what makes taps land where the board is drawn. A
        // CustomPaint with no child takes whatever size its constraints force,
        // ignoring the `size` argument, so under the tight constraints of a
        // Column it fills a non-square box and paints the board off-centre
        // from where the hit test expects it. Pinning a square box means the
        // painter and the hit test share one centre.
        return Center(
          child: SizedBox.square(
            dimension: side,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                final centre = Offset(side / 2, side / 2);
                final segment = BoardGeometry.segmentAt(
                  details.localPosition - centre,
                  radius,
                );
                if (segment == null) {
                  onMissTapped?.call();
                } else {
                  onSegmentTapped?.call(segment);
                }
              },
              child: CustomPaint(
                size: Size.square(side),
                painter: _BoardPainter(
                  radius: radius,
                  highlight: highlight,
                  heat: heat,
                  showNumbers: showNumbers,
                  highlightColour: Theme.of(context).colorScheme.primary,
                  numberColour: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({
    required this.radius,
    required this.highlight,
    required this.heat,
    required this.showNumbers,
    required this.highlightColour,
    required this.numberColour,
  });

  final double radius;
  final Set<Segment> highlight;
  final Map<Segment, double> heat;
  final bool showNumbers;
  final Color highlightColour;
  final Color numberColour;

  static const Color _cream = Color(0xFFEFE3C4);
  static const Color _black = Color(0xFF1B1B1B);
  static const Color _red = Color(0xFFC0392B);
  static const Color _green = Color(0xFF1E8449);
  static const Color _wire = Color(0xFF8A8A8A);

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final wire = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _wire;

    canvas.drawCircle(
      centre,
      radius * 1.06,
      Paint()..color = _black.withValues(alpha: 0.9),
    );

    for (var index = 0; index < boardWedgeOrder.length; index++) {
      final number = boardWedgeOrder[index];
      final start =
          BoardGeometry.wedgeCentre(index) - BoardGeometry.wedgeSweep / 2;
      final even = index.isEven;

      void wedge(Ring ring, double inner, double outer, Color colour) {
        final path = _sector(centre, inner * radius, outer * radius, start);
        canvas.drawPath(path, Paint()..color = _shade(Segment(number, ring), colour));
        canvas.drawPath(path, wire);
        if (highlight.contains(Segment(number, ring))) {
          canvas.drawPath(
            path,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = highlightColour,
          );
        }
      }

      wedge(
        Ring.innerSingle,
        BoardGeometry.outerBullEdge,
        BoardGeometry.tripleInner,
        even ? _cream : _black,
      );
      wedge(
        Ring.triple,
        BoardGeometry.tripleInner,
        BoardGeometry.tripleOuter,
        even ? _red : _green,
      );
      wedge(
        Ring.outerSingle,
        BoardGeometry.tripleOuter,
        BoardGeometry.doubleInner,
        even ? _cream : _black,
      );
      wedge(
        Ring.doubleRing,
        BoardGeometry.doubleInner,
        BoardGeometry.doubleOuter,
        even ? _red : _green,
      );

      if (showNumbers) {
        _paintNumber(canvas, centre, index, number);
      }
    }

    for (final (segment, edge, colour) in [
      (Segment.outerBull, BoardGeometry.outerBullEdge, _green),
      (Segment.innerBull, BoardGeometry.innerBullEdge, _red),
    ]) {
      canvas.drawCircle(
        centre,
        edge * radius,
        Paint()..color = _shade(segment, colour),
      );
      canvas.drawCircle(centre, edge * radius, wire);
      if (highlight.contains(segment)) {
        canvas.drawCircle(
          centre,
          edge * radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = highlightColour,
        );
      }
    }
  }

  /// Blends a segment's base colour towards the heat colour by its intensity.
  Color _shade(Segment segment, Color base) {
    final intensity = heat[segment];
    if (intensity == null || intensity <= 0) return base;
    return Color.lerp(base, highlightColour, intensity.clamp(0, 1)) ?? base;
  }

  Path _sector(Offset centre, double inner, double outer, double start) {
    const sweep = BoardGeometry.wedgeSweep;
    return Path()
      ..moveTo(
        centre.dx + inner * cos(start),
        centre.dy + inner * sin(start),
      )
      ..lineTo(
        centre.dx + outer * cos(start),
        centre.dy + outer * sin(start),
      )
      ..arcTo(Rect.fromCircle(center: centre, radius: outer), start, sweep, false)
      ..lineTo(
        centre.dx + inner * cos(start + sweep),
        centre.dy + inner * sin(start + sweep),
      )
      ..arcTo(
        Rect.fromCircle(center: centre, radius: inner),
        start + sweep,
        -sweep,
        false,
      )
      ..close();
  }

  void _paintNumber(Canvas canvas, Offset centre, int index, int number) {
    final angle = BoardGeometry.wedgeCentre(index);
    final distance = radius * 1.14;
    final painter = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TextStyle(
          color: numberColour,
          fontSize: radius * 0.11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      centre +
          Offset(distance * cos(angle), distance * sin(angle)) -
          Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_BoardPainter old) =>
      old.radius != radius ||
      old.highlight != highlight ||
      old.heat != heat ||
      old.showNumbers != showNumbers ||
      old.highlightColour != highlightColour;
}
