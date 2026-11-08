import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/training/aim_target.dart';
import 'package:test/test.dart';

void main() {
  group('isHitBy', () {
    test('a single accepts either single bed', () {
      const target = AimTarget.single(5);
      expect(target.isHitBy(const Segment(5, Ring.innerSingle)), isTrue);
      expect(target.isHitBy(const Segment(5, Ring.outerSingle)), isTrue);
      expect(target.isHitBy(const Segment(5, Ring.triple)), isFalse);
    });

    test('bull accepts both bulls, bullseye only the inner', () {
      expect(AimTarget.bull.isHitBy(Segment.outerBull), isTrue);
      expect(AimTarget.bull.isHitBy(Segment.innerBull), isTrue);
      expect(AimTarget.bullseye.isHitBy(Segment.outerBull), isFalse);
      expect(AimTarget.bullseye.isHitBy(Segment.innerBull), isTrue);
    });

    test('a miss hits nothing', () {
      expect(const AimTarget.double(16).isHitBy(null), isFalse);
    });
  });

  group('missDirection', () {
    const d16 = AimTarget.double(16);

    test('hit', () {
      expect(
        d16.missDirection(const Segment(16, Ring.doubleRing)),
        MissDirection.hit,
      );
    });

    test('single 16 at D16 is inside, a board miss outside', () {
      expect(
        d16.missDirection(const Segment(16, Ring.outerSingle)),
        MissDirection.inside,
      );
      expect(d16.missDirection(null), MissDirection.outside);
    });

    test('neighbours are left and right in board order', () {
      // Board order runs ... 7, 16, 8 ... clockwise.
      expect(
        d16.missDirection(const Segment(8, Ring.doubleRing)),
        MissDirection.right,
      );
      expect(
        d16.missDirection(const Segment(7, Ring.doubleRing)),
        MissDirection.left,
      );
      expect(
        d16.missDirection(const Segment(20, Ring.doubleRing)),
        MissDirection.elsewhere,
      );
    });

    test('neighbours wrap around the top of the board', () {
      const d20 = AimTarget.double(20);
      expect(
        d20.missDirection(const Segment(1, Ring.doubleRing)),
        MissDirection.right,
      );
      expect(
        d20.missDirection(const Segment(5, Ring.doubleRing)),
        MissDirection.left,
      );
    });

    test('a treble target sees the outer single as outside', () {
      const t20 = AimTarget.triple(20);
      expect(
        t20.missDirection(const Segment(20, Ring.outerSingle)),
        MissDirection.outside,
      );
      expect(
        t20.missDirection(const Segment(20, Ring.innerSingle)),
        MissDirection.inside,
      );
      expect(t20.missDirection(Segment.innerBull), MissDirection.inside);
    });

    test('anything but a bull is outside the bull', () {
      expect(
        AimTarget.bullseye.missDirection(Segment.outerBull),
        MissDirection.outside,
      );
      expect(
        AimTarget.bull.missDirection(const Segment(20, Ring.innerSingle)),
        MissDirection.outside,
      );
    });
  });
}
