/// The statistics screen's charts: [TrendChart] for form over time,
/// [Sparkline] for the same thing at tile size, [BarChart] for a
/// distribution and [SplitBar] for a two-way comparison.
///
/// Drawn by hand rather than with a chart package: four small charts do not
/// earn a dependency, and these pick up [Palette] and [Type] directly.
///
/// {@category App}
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../theme.dart';

/// One day's figure on a [TrendChart].
typedef TrendPoint = ({DateTime day, double value});

/// The mean of each value and the [window] - 1 values before it, smoothing
/// a day-by-day series without lagging behind it the way a longer one would.
List<double> rollingMean(List<double> values, int window) => [
  for (var i = 0; i < values.length; i++)
    () {
      final from = max(0, i - window + 1);
      final slice = values.sublist(from, i + 1);
      return slice.reduce((a, b) => a + b) / slice.length;
    }(),
];

/// A figure day by day: a dot per day, a rolling line through them, and a
/// dashed line at the [reference] the days are measured against.
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.points,
    required this.format,
    this.reference,
    this.window = 5,
    this.height = 160,
  });

  /// Oldest first. Two or more draw a chart; fewer leave the space empty.
  final List<TrendPoint> points;

  /// How an axis value reads: `62.4`, `38%`.
  final String Function(double value) format;

  final double? reference;

  /// Days in the rolling line.
  final int window;

  final double height;

  @override
  Widget build(BuildContext context) {
    final dates = DateFormat.MMMd(Localizations.localeOf(context).toString());
    return Semantics(
      label: points.isEmpty ? null : format(points.last.value),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _TrendPainter(
            points: points,
            format: format,
            reference: reference,
            window: window,
            firstLabel: points.isEmpty ? '' : dates.format(points.first.day),
            lastLabel: points.isEmpty ? '' : dates.format(points.last.day),
            textScaler: MediaQuery.textScalerOf(context),
          ),
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.points,
    required this.format,
    required this.reference,
    required this.window,
    required this.firstLabel,
    required this.lastLabel,
    required this.textScaler,
  });

  final List<TrendPoint> points;
  final String Function(double) format;
  final double? reference;
  final int window;
  final String firstLabel;
  final String lastLabel;
  final TextScaler textScaler;

  TextPainter _text(String text, Color colour) => TextPainter(
    text: TextSpan(
      text: text,
      style: Type.label.copyWith(color: colour),
    ),
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
  )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final values = [for (final p in points) p.value];
    var low = values.reduce(min);
    var high = values.reduce(max);
    if (reference case final r?) {
      low = min(low, r);
      high = max(high, r);
    }
    if (high - low < 1e-9) {
      low -= 1;
      high += 1;
    }
    final pad = (high - low) * 0.12;
    low -= pad;
    high += pad;

    // Axis labels decide the plot's insets, so measure them first.
    final ticks = [high, (high + low) / 2, low];
    final tickLabels = [
      for (final tick in ticks) _text(format(tick), Palette.chalkDim),
    ];
    final left = tickLabels.map((label) => label.width).reduce(max) + Gap.sm;
    final first = _text(firstLabel, Palette.chalkDim);
    final last = _text(lastLabel, Palette.chalkDim);
    final bottom = first.height + Gap.xs;
    final plot = Rect.fromLTRB(left, Gap.xs, size.width, size.height - bottom);

    double y(double value) =>
        plot.bottom - (value - low) / (high - low) * plot.height;
    double x(int index) => plot.left + index / (points.length - 1) * plot.width;

    final grid = Paint()
      ..color = Palette.edge
      ..strokeWidth = 1;
    for (var i = 0; i < ticks.length; i++) {
      final ty = y(ticks[i]);
      canvas.drawLine(Offset(plot.left, ty), Offset(plot.right, ty), grid);
      tickLabels[i].paint(canvas, Offset(0, ty - tickLabels[i].height / 2));
    }

    if (reference case final r?) {
      final dash = Paint()
        ..color = Palette.chalkDim
        ..strokeWidth = 1;
      final ry = y(r);
      for (var dx = plot.left; dx < plot.right; dx += 8) {
        canvas.drawLine(
          Offset(dx, ry),
          Offset(min(dx + 4, plot.right), ry),
          dash,
        );
      }
    }

    final dot = Paint()..color = Palette.chalkDim;
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(Offset(x(i), y(values[i])), 2.5, dot);
    }

    final rolling = rollingMean(values, window);
    final path = Path()..moveTo(x(0), y(rolling.first));
    for (var i = 1; i < rolling.length; i++) {
      path.lineTo(x(i), y(rolling[i]));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Palette.live
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(x(rolling.length - 1), y(rolling.last)),
      4,
      Paint()..color = Palette.live,
    );

    first.paint(canvas, Offset(plot.left, plot.bottom + Gap.xs));
    last.paint(canvas, Offset(plot.right - last.width, plot.bottom + Gap.xs));
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.points != points ||
      old.reference != reference ||
      old.window != window ||
      old.textScaler != textScaler;
}

/// A trend at tile size: just the line, no axes.
class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.values, required this.colour});

  final List<double> values;
  final Color colour;

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: CustomPaint(painter: _SparkPainter(values, colour)),
  );
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values, this.colour);

  final List<double> values;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final low = values.reduce(min);
    final span = max(values.reduce(max) - low, 1e-9);
    Offset at(int i) => Offset(
      i / (values.length - 1) * size.width,
      size.height - (values[i] - low) / span * (size.height - 2) - 1,
    );

    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(at(i).dx, at(i).dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = colour
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparkPainter old) =>
      old.values != values || old.colour != colour;
}

/// One bar of a [BarChart].
typedef Bar = ({String label, int count, bool highlight});

/// Counts side by side, each bar labelled underneath and topped with its
/// count. Highlighted bars are the ones worth bragging about.
class BarChart extends StatelessWidget {
  const BarChart({super.key, required this.bars, this.height = 120});

  final List<Bar> bars;
  final double height;

  @override
  Widget build(BuildContext context) {
    final most = bars.fold(0, (m, bar) => max(m, bar.count));
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final bar in bars)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${bar.count}',
                        style: Type.label.copyWith(
                          color: bar.highlight ? Palette.live : Palette.chalk,
                        ),
                      ),
                    ),
                    const SizedBox(height: Gap.xs),
                    Flexible(
                      child: FractionallySizedBox(
                        heightFactor: most == 0
                            ? 0
                            : max(bar.count / most, bar.count > 0 ? 0.03 : 0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: bar.highlight
                                ? Palette.live
                                : Palette.trebleBed.withValues(alpha: 0.6),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(2),
                            ),
                          ),
                          child: const SizedBox(width: double.infinity),
                        ),
                      ),
                    ),
                    const SizedBox(height: Gap.xs),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        bar.label,
                        maxLines: 1,
                        style: Type.label.copyWith(color: Palette.chalkDim),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Two shares of something, each with its own rate bar: legs won on and
/// against the throw, bull and bullseye hits.
class SplitBar extends StatelessWidget {
  const SplitBar({super.key, required this.rows});

  /// Label, the figure as read, and the 0..1 fill.
  final List<({String label, String value, double fill})> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Gap.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        row.label,
                        style: Type.body.copyWith(color: Palette.chalkDim),
                      ),
                    ),
                    const SizedBox(width: Gap.sm),
                    // Shrinks rather than overflows, as in StatRow.
                    Flexible(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            row.value,
                            style: Type.notation.copyWith(color: Palette.chalk),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: row.fill.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Palette.sunk,
                    color: Palette.live,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
