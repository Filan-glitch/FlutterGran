import 'package:flutter/material.dart';

import '../rules_topic.dart';
import '../theme.dart';

/// Small painted rings standing in for a dartboard, one per [RulesTopic] -
/// concentric bands like the board itself, with a highlight that encodes the
/// mode's own rule rather than an arbitrary per-mode colour. The app's own
/// rule is that green is told apart by lightness, not hue (see `Palette`), so
/// every mode shares the same ring/[Palette.trebleBed] base; only the
/// highlight below changes:
///
///  - X01 strokes the outer ring in [Palette.doubleBed] - a leg ends on a
///    double.
///  - Around the Clock adds a bright dot riding the rim - the numbers are
///    played in order, all the way around.
///  - Bulling fills the centre solid - the whole game is aiming for the bull.
///  - Higher/Lower puts a dot at the top and the bottom of the rim - over the
///    higher value or under the lower one.
///  - Training groups three dots on the treble ring - a practice grouping.
///
/// A null [topic] is the dim, un-highlighted family with a plus in the
/// middle: the select-mode screen's "more modes coming" tile, which names no
/// mode.
///
/// Plain widgets (stacked circles, dots placed with [Align]), not a
/// `CustomPainter` - three circles don't need one.
class ModeGlyph extends StatelessWidget {
  const ModeGlyph({super.key, required this.topic, this.size = 52});

  final RulesTopic? topic;
  final double size;

  @override
  Widget build(BuildContext context) {
    final topic = this.topic;
    // Stroke and dot grow with the glyph, so a hero-sized one is not drawn in
    // hairlines.
    final stroke = size / 26;
    final dot = size * 0.17;

    if (topic == null) {
      return SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _ring(diameter: size, color: Palette.edge, stroke: stroke),
            _ring(diameter: size * 0.62, color: Palette.edge, stroke: stroke),
            Icon(Icons.add, color: Palette.chalkDim, size: size * 0.35),
          ],
        ),
      );
    }

    final outerColor = topic == RulesTopic.x01
        ? Palette.doubleBed
        : Palette.chalkDim;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _ring(diameter: size, color: outerColor, stroke: stroke),
          _ring(
            diameter: size * 0.62,
            color: Palette.trebleBed,
            stroke: stroke,
          ),
          _ring(
            diameter: size * 0.28,
            color: Palette.trebleBed,
            stroke: stroke,
            filled: topic == RulesTopic.bulling,
          ),
          if (topic == RulesTopic.aroundTheClock)
            Align(
              alignment: const Alignment(0.8, -0.8),
              child: _dot(dot, Palette.trebleBed),
            ),
          if (topic == RulesTopic.higherLower)
            for (final alignment in const [
              Alignment.topCenter,
              Alignment.bottomCenter,
            ])
              Align(alignment: alignment, child: _dot(dot, Palette.trebleBed)),
          if (topic == RulesTopic.training)
            for (final alignment in const [
              Alignment(-0.14, -0.62),
              Alignment(0.14, -0.62),
              Alignment(0, -0.42),
            ])
              Align(alignment: alignment, child: _dot(dot * 0.8, Palette.live)),
        ],
      ),
    );
  }

  static Widget _ring({
    required double diameter,
    required Color color,
    required double stroke,
    bool filled = false,
  }) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : null,
        border: filled ? null : Border.all(color: color, width: stroke),
      ),
    );
  }

  static Widget _dot(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
