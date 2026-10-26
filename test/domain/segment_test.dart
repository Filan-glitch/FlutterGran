import 'package:fluttergran/domain/segment.dart';
import 'package:test/test.dart';

void main() {
  group('Segment scoring', () {
    test('rings multiply the wedge number', () {
      expect(const Segment(20, Ring.innerSingle).value, 20);
      expect(const Segment(20, Ring.outerSingle).value, 20);
      expect(const Segment(20, Ring.doubleRing).value, 40);
      expect(const Segment(20, Ring.triple).value, 60);
    });

    test('bulls are worth 25 and 50', () {
      expect(Segment.outerBull.value, 25);
      expect(Segment.innerBull.value, 50);
    });

    test('only the double ring and the inner bull can check out', () {
      expect(const Segment(16, Ring.doubleRing).isDouble, isTrue);
      expect(Segment.innerBull.isDouble, isTrue);
      expect(Segment.outerBull.isDouble, isFalse);
      expect(const Segment(20, Ring.triple).isDouble, isFalse);
      expect(const Segment(20, Ring.innerSingle).isDouble, isFalse);
    });

    test('labels use standard notation, singles collapsing to S', () {
      expect(const Segment(20, Ring.triple).label, 'T20');
      expect(const Segment(16, Ring.doubleRing).label, 'D16');
      expect(const Segment(5, Ring.innerSingle).label, 'S5');
      expect(const Segment(5, Ring.outerSingle).label, 'S5');
      expect(Segment.outerBull.label, 'SB');
      expect(Segment.innerBull.label, 'DB');
    });

    test('inner and outer singles score alike but are not equal', () {
      const inner = Segment(5, Ring.innerSingle);
      const outer = Segment(5, Ring.outerSingle);
      expect(inner.value, outer.value);
      expect(inner, isNot(outer));
    });
  });

  group('Segment.all', () {
    test('covers every scoring area exactly once', () {
      // 20 wedges x 4 rings, plus both bulls - the 82 areas the board reports.
      expect(Segment.all, hasLength(82));
      expect(Segment.all.toSet(), hasLength(82));
    });

    test('contains both bulls', () {
      expect(Segment.all, contains(Segment.outerBull));
      expect(Segment.all, contains(Segment.innerBull));
    });

    test('the highest scoring area is the triple 20', () {
      final best = Segment.all.map((s) => s.value).reduce((a, b) => a > b ? a : b);
      expect(best, 60);
    });
  });
}
