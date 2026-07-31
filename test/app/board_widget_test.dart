import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/widgets/board_widget.dart';
import 'package:fluttergran/domain/segment.dart';

/// Puts the board in a box of a given shape, as a real screen would.
Future<List<Segment>> pumpBoardIn(
  WidgetTester tester,
  Size box, {
  VoidCallback? onMiss,
}) async {
  final tapped = <Segment>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: box.width,
            height: box.height,
            child: BoardWidget(
              onSegmentTapped: tapped.add,
              onMissTapped: onMiss ?? () {},
            ),
          ),
        ),
      ),
    ),
  );
  return tapped;
}

void main() {
  // A CustomPaint with no child takes the size its constraints force, ignoring
  // the `size` argument. In a non-square box that put the painted board and the
  // hit test on different centres, so taps landed on the wrong segment - which
  // is exactly what a square box prevents.
  group('taps land where the board is drawn', () {
    for (final box in const [
      Size(300, 300),
      Size(400, 280),
      Size(260, 420),
    ]) {
      testWidgets('the centre is the bull in a ${box.width.toInt()}x'
          '${box.height.toInt()} box', (tester) async {
        final tapped = await pumpBoardIn(tester, box);

        await tester.tapAt(tester.getCenter(find.byType(BoardWidget)));
        await tester.pump();

        expect(tapped.single, Segment.innerBull);
      });
    }

    testWidgets('straight up from the centre is the 20', (tester) async {
      const box = Size(400, 280);
      final tapped = await pumpBoardIn(tester, box);

      final centre = tester.getCenter(find.byType(BoardWidget));
      // 0.8 of the radius, which is the outer single band.
      final radius = box.shortestSide / 2 * 0.86;
      await tester.tapAt(centre + Offset(0, -radius * 0.8));
      await tester.pump();

      expect(tapped.single.number, 20);
      expect(tapped.single.ring, Ring.outerSingle);
    });

    testWidgets('to the right of the centre is the 6', (tester) async {
      const box = Size(400, 280);
      final tapped = await pumpBoardIn(tester, box);

      final centre = tester.getCenter(find.byType(BoardWidget));
      final radius = box.shortestSide / 2 * 0.86;
      await tester.tapAt(centre + Offset(radius * 0.8, 0));
      await tester.pump();

      expect(tapped.single.number, 6);
    });

    testWidgets('a corner of a wide box is a miss, not a stray segment', (
      tester,
    ) async {
      var missed = 0;
      final tapped = await pumpBoardIn(
        tester,
        const Size(400, 280),
        onMiss: () => missed++,
      );

      // The board occupies a centred square, so the corner of that square is
      // inside the widget but well outside the scoring circle. Tapping the
      // corner of the wider box would miss the widget entirely and report
      // nothing at all.
      final centre = tester.getCenter(find.byType(BoardWidget));
      const half = 280 / 2;
      await tester.tapAt(centre - const Offset(half - 5, half - 5));
      await tester.pump();

      expect(tapped, isEmpty);
      expect(missed, 1);
    });
  });
}
