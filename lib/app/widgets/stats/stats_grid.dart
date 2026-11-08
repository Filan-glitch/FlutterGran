/// [StatsGrid] and [TileRow], the two responsive layouts of the statistics
/// screen.
///
/// {@category App}
library;

import 'package:flutter/material.dart';

import '../../theme.dart';

/// Width below which cards stack in one column.
const double statsTwoColumns = 700;

/// Width from which cards sit three abreast.
const double statsThreeColumns = 1100;

/// How many card columns fit in [width].
int statsColumnsFor(double width) => width >= statsThreeColumns
    ? 3
    : width >= statsTwoColumns
    ? 2
    : 1;

/// Cards in as many columns as the width allows: one on a phone, two on a
/// tablet or a laptop window, three on a wide monitor.
///
/// Children are dealt into columns in turn rather than laid in rows, so a
/// tall card does not leave a gap beside a short one - order still reads
/// left to right, top to bottom.
class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = statsColumnsFor(constraints.maxWidth);
        if (columns == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final child in children) ...[
                child,
                const SizedBox(height: Gap.md),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var column = 0; column < columns; column++) ...[
              if (column > 0) const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = column; i < children.length; i += columns) ...[
                      children[i],
                      const SizedBox(height: Gap.md),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Headline tiles, two abreast on a phone and four on anything wider.
class TileRow extends StatelessWidget {
  const TileRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow = constraints.maxWidth >= statsTwoColumns ? 4 : 2;
        final width = (constraints.maxWidth - Gap.md * (perRow - 1)) / perRow;
        return Wrap(
          spacing: Gap.md,
          runSpacing: Gap.md,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}
