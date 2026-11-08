/// [ChalkMark] and [ChalkWordmark], the app's brand: a five-bar tally and
/// its name, shared by the splash screen and the main menu header.
///
/// {@category App}
library;

import 'package:flutter/material.dart';

import '../theme.dart';

/// The [Hero] tag the splash screen's mark flies to the main menu under.
const chalkMarkHeroTag = 'chalk-mark';

/// The tally mark from the launcher icon (`tool/make_icon.py`), redrawn in
/// widgets rather than shared as an asset - the icon is a rasterised PNG with
/// hand-drawn chalk texture, and none of that is worth reproducing for a
/// widget this small. The idea is what has to carry: four strokes struck
/// through by a fifth.
///
/// [progress] draws it in, from nothing at 0 to the whole mark at 1: the
/// four uprights one after another, then the stroke through them, the way it
/// is chalked on a board.
class ChalkMark extends StatelessWidget {
  const ChalkMark({super.key, this.size = 120, this.progress = 1});

  /// The mark's width; its height is four fifths of it.
  final double size;

  /// How much of the mark is drawn, 0 to 1.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.8,
      child: CustomPaint(painter: TallyPainter(progress: progress)),
    );
  }
}

/// The app's name, letter-spaced, as it sits under [ChalkMark].
class ChalkWordmark extends StatelessWidget {
  const ChalkWordmark({super.key, this.fontSize = 13});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      'C H A L K',
      textAlign: TextAlign.center,
      style: Type.eyebrow.copyWith(color: Palette.chalkDim, fontSize: fontSize),
    );
  }
}

/// Paints [ChalkMark]. Public so a test can ask what it would draw.
class TallyPainter extends CustomPainter {
  const TallyPainter({this.progress = 1});

  final double progress;

  /// How much of the timeline each stroke takes. With [_strokeOffset] it
  /// overlaps the next one slightly, so the hand never looks like it stops.
  static const double _strokeLength = 0.28;

  /// How far into the timeline each stroke starts after the one before.
  /// Four offsets and one length add up to exactly 1.
  static const double _strokeOffset = 0.18;

  /// How much of stroke [index] (0 to 4) is drawn at [progress], 0 to 1.
  static double strokeProgress(double progress, int index) {
    final start = index * _strokeOffset;
    final t = ((progress - start) / _strokeLength).clamp(0.0, 1.0);
    return Curves.easeOut.transform(t);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Palette.chalk
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Four uprights, evenly spaced across the width, chalked top to bottom.
    final top = size.height * 0.08;
    final bottom = size.height * 0.92;
    final strokes = [
      for (var i = 0; i < 4; i++)
        (
          Offset(size.width * (0.14 + i * 0.24), top),
          Offset(size.width * (0.14 + i * 0.24), bottom),
        ),
      // The fifth stroke, on the diagonal through the middle of the other four.
      (
        Offset(size.width * 0.04, size.height * 0.72),
        Offset(size.width * 0.96, size.height * 0.18),
      ),
    ];

    for (final (index, (start, end)) in strokes.indexed) {
      final t = strokeProgress(progress, index);
      // A zero-length line with a round cap is still a dot; nothing drawn
      // yet means nothing on screen.
      if (t <= 0) continue;
      canvas.drawLine(start, Offset.lerp(start, end, t)!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant TallyPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
