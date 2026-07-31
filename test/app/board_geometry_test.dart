import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/widgets/board_widget.dart';
import 'package:fluttergran/domain/segment.dart';

const double radius = 100;

/// A point at [fraction] of the board radius, [degrees] clockwise from the top.
Offset at(double fraction, double degrees) {
  final angle = (degrees - 90) * pi / 180;
  return Offset(cos(angle), sin(angle)) * (fraction * radius);
}

Segment? hit(double fraction, double degrees) =>
    BoardGeometry.segmentAt(at(fraction, degrees), radius);

void main() {
  group('rings, straight up the 20', () {
    test('the bulls', () {
      expect(BoardGeometry.segmentAt(Offset.zero, radius), Segment.innerBull);
      expect(hit(0.02, 0), Segment.innerBull);
      expect(hit(0.06, 0), Segment.outerBull);
    });

    test('the wedge rings, from the bull outwards', () {
      expect(hit(0.30, 0), const Segment(20, Ring.innerSingle));
      expect(hit(0.60, 0), const Segment(20, Ring.triple));
      expect(hit(0.80, 0), const Segment(20, Ring.outerSingle));
      expect(hit(0.97, 0), const Segment(20, Ring.doubleRing));
    });

    test('outside the double ring is a miss', () {
      expect(hit(1.05, 0), isNull);
      expect(hit(3.00, 45), isNull);
    });
  });

  group('wedge layout', () {
    test('the compass points match a real board', () {
      // 20 at the top, 3 at the bottom, 6 to the right, 11 to the left.
      expect(hit(0.8, 0)?.number, 20);
      expect(hit(0.8, 180)?.number, 3);
      expect(hit(0.8, 90)?.number, 6);
      expect(hit(0.8, 270)?.number, 11);
    });

    test('every wedge is reachable at its own centre', () {
      for (var index = 0; index < boardWedgeOrder.length; index++) {
        expect(
          hit(0.8, index * 18.0)?.number,
          boardWedgeOrder[index],
          reason: 'wedge index $index',
        );
      }
    });

    test('the wedge boundaries fall halfway between centres', () {
      // Just inside the 20 on either side, then just over into its neighbours.
      expect(hit(0.8, 8.9)?.number, 20);
      expect(hit(0.8, -8.9)?.number, 20);
      expect(hit(0.8, 9.1)?.number, 1);
      expect(hit(0.8, -9.1)?.number, 5);
    });

    test('angles wrap rather than falling off the end', () {
      expect(hit(0.8, 360)?.number, 20);
      expect(hit(0.8, 720)?.number, 20);
      expect(hit(0.8, -360)?.number, 20);
    });
  });

  test('every segment the board can report is reachable by tapping', () {
    final reachable = <Segment>{};
    for (var index = 0; index < 20; index++) {
      final degrees = index * 18.0;
      reachable
        ..add(hit(0.30, degrees)!)
        ..add(hit(0.60, degrees)!)
        ..add(hit(0.80, degrees)!)
        ..add(hit(0.97, degrees)!);
    }
    reachable
      ..add(Segment.innerBull)
      ..add(Segment.outerBull);

    expect(reachable, Segment.all.toSet());
  });
}
