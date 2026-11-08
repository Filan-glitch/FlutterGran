import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/widgets/chalk_mark.dart';

void main() {
  group('TallyPainter.strokeProgress', () {
    test('draws nothing at the start and every stroke at the end', () {
      for (var stroke = 0; stroke < 5; stroke++) {
        expect(TallyPainter.strokeProgress(0, stroke), 0);
        expect(TallyPainter.strokeProgress(1, stroke), 1);
      }
    });

    test('draws the uprights in order, then the stroke through them', () {
      // Partway through, an earlier stroke is always further along.
      for (final progress in [0.2, 0.4, 0.6, 0.8]) {
        for (var stroke = 1; stroke < 5; stroke++) {
          expect(
            TallyPainter.strokeProgress(progress, stroke - 1),
            greaterThanOrEqualTo(TallyPainter.strokeProgress(progress, stroke)),
          );
        }
      }
      // The diagonal has not started while the first upright is going down.
      expect(TallyPainter.strokeProgress(0.1, 4), 0);
    });
  });

  test('repaints only when the progress changes', () {
    const half = TallyPainter(progress: 0.5);
    expect(half.shouldRepaint(const TallyPainter(progress: 0.5)), isFalse);
    expect(half.shouldRepaint(const TallyPainter()), isTrue);
  });

  testWidgets('is four fifths as tall as it is wide', (tester) async {
    await tester.pumpWidget(const Center(child: ChalkMark(size: 100)));
    expect(tester.getSize(find.byType(ChalkMark)), const Size(100, 80));
  });
}
