import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:fluttergran/domain/x01/x01_rules.dart';
import 'package:test/test.dart';

void main() {
  group('X01InRule.opens', () {
    test('straight-in opens on anything, including a single', () {
      expect(X01InRule.straight.opens(const Segment(5, Ring.outerSingle)), isTrue);
    });

    test('double-in opens only on a double or the inner bull', () {
      expect(X01InRule.double.opens(const Segment(20, Ring.doubleRing)), isTrue);
      expect(X01InRule.double.opens(Segment.innerBull), isTrue);
      expect(X01InRule.double.opens(const Segment(20, Ring.triple)), isFalse);
      expect(X01InRule.double.opens(const Segment(20, Ring.outerSingle)), isFalse);
      expect(X01InRule.double.opens(Segment.outerBull), isFalse);
    });

    test('master-in opens on a double, a triple, or the inner bull', () {
      expect(X01InRule.master.opens(const Segment(20, Ring.doubleRing)), isTrue);
      expect(X01InRule.master.opens(const Segment(20, Ring.triple)), isTrue);
      expect(X01InRule.master.opens(Segment.innerBull), isTrue);
      expect(X01InRule.master.opens(const Segment(20, Ring.outerSingle)), isFalse);
      expect(X01InRule.master.opens(Segment.outerBull), isFalse);
    });
  });

  group('X01OutRule.checksOut', () {
    test('straight-out checks out on anything', () {
      expect(
        X01OutRule.straight.checksOut(const Segment(1, Ring.outerSingle)),
        isTrue,
      );
    });

    test('double-out checks out only on a double or the inner bull', () {
      expect(X01OutRule.double.checksOut(const Segment(20, Ring.doubleRing)), isTrue);
      expect(X01OutRule.double.checksOut(Segment.innerBull), isTrue);
      expect(X01OutRule.double.checksOut(const Segment(20, Ring.triple)), isFalse);
      expect(X01OutRule.double.checksOut(Segment.outerBull), isFalse);
    });

    test('master-out checks out on a double, a triple, or the inner bull', () {
      expect(X01OutRule.master.checksOut(const Segment(20, Ring.doubleRing)), isTrue);
      expect(X01OutRule.master.checksOut(const Segment(19, Ring.triple)), isTrue);
      expect(X01OutRule.master.checksOut(Segment.innerBull), isTrue);
      expect(X01OutRule.master.checksOut(const Segment(20, Ring.outerSingle)), isFalse);
      expect(X01OutRule.master.checksOut(Segment.outerBull), isFalse);
    });
  });

  group('ThrownDart rule checks', () {
    test('a miss never opens or checks out, under any rule', () {
      const miss = ThrownDart.miss();
      expect(miss.opensUnder(X01InRule.straight), isFalse);
      expect(miss.checksOutUnder(X01OutRule.straight), isFalse);
    });

    test('opensUnder/checksOutUnder delegate to the segment', () {
      final dart = ThrownDart(const Segment(20, Ring.doubleRing));
      expect(dart.opensUnder(X01InRule.double), isTrue);
      expect(dart.opensUnder(X01InRule.master), isTrue);
      expect(dart.checksOutUnder(X01OutRule.double), isTrue);
    });
  });

  group('display', () {
    test('in-rule abbreviations and labels', () {
      expect(X01InRule.straight.abbreviation, 'SI');
      expect(X01InRule.double.abbreviation, 'DI');
      expect(X01InRule.master.abbreviation, 'MI');
      expect(X01InRule.straight.label, 'Straight');
      expect(X01InRule.double.label, 'Double');
      expect(X01InRule.master.label, 'Master');
    });

    test('out-rule abbreviations and labels', () {
      expect(X01OutRule.straight.abbreviation, 'SO');
      expect(X01OutRule.double.abbreviation, 'DO');
      expect(X01OutRule.master.abbreviation, 'MO');
      expect(X01OutRule.straight.label, 'Straight');
      expect(X01OutRule.double.label, 'Double');
      expect(X01OutRule.master.label, 'Master');
    });
  });
}
