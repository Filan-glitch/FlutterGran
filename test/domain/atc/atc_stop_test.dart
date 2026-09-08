import 'package:fluttergran/domain/atc/atc_stop.dart';
import 'package:fluttergran/domain/atc/atc_variant.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:test/test.dart';

void main() {
  group('track', () {
    test('has 22 stops: 1 to 20, then bull, then bullseye', () {
      expect(AtcStop.track, hasLength(22));
      expect(AtcStop.track.take(20).map((stop) => stop.number), [
        for (var n = 1; n <= 20; n++) n,
      ]);
      expect(AtcStop.track[20].label, 'BULL');
      expect(AtcStop.track[21].label, 'BULLSEYE');
    });
  });

  group('numbered stop, any part', () {
    final stop = AtcStop.track[6]; // number 7

    test('a single on the matching number clears it', () {
      expect(stop.clears(Segment(7, Ring.outerSingle), AtcVariant.anyPart), isTrue);
    });

    test('a double on the matching number clears it', () {
      expect(stop.clears(Segment(7, Ring.doubleRing), AtcVariant.anyPart), isTrue);
    });

    test('a triple on the matching number clears it', () {
      expect(stop.clears(Segment(7, Ring.triple), AtcVariant.anyPart), isTrue);
    });

    test('any ring on a different number does not clear it', () {
      expect(stop.clears(Segment(8, Ring.triple), AtcVariant.anyPart), isFalse);
    });
  });

  group('numbered stop, masters', () {
    final stop = AtcStop.track[6]; // number 7

    test('a double on the matching number clears it', () {
      expect(stop.clears(Segment(7, Ring.doubleRing), AtcVariant.masters), isTrue);
    });

    test('a triple on the matching number clears it', () {
      expect(stop.clears(Segment(7, Ring.triple), AtcVariant.masters), isTrue);
    });

    test('a single on the matching number does not clear it', () {
      expect(stop.clears(Segment(7, Ring.outerSingle), AtcVariant.masters), isFalse);
      expect(stop.clears(Segment(7, Ring.innerSingle), AtcVariant.masters), isFalse);
    });
  });

  group('numbered stop, doubles only', () {
    final stop = AtcStop.track[6]; // number 7

    test('a double on the matching number clears it', () {
      expect(
        stop.clears(Segment(7, Ring.doubleRing), AtcVariant.doublesOnly),
        isTrue,
      );
    });

    test('a triple on the matching number does not clear it', () {
      expect(stop.clears(Segment(7, Ring.triple), AtcVariant.doublesOnly), isFalse);
    });

    test('a single on the matching number does not clear it', () {
      expect(
        stop.clears(Segment(7, Ring.outerSingle), AtcVariant.doublesOnly),
        isFalse,
      );
    });
  });

  group('bull stop (index 20)', () {
    final bull = AtcStop.track[20];

    test('clears on the outer bull under every variant', () {
      for (final variant in AtcVariant.values) {
        expect(bull.clears(Segment.outerBull, variant), isTrue, reason: '$variant');
      }
    });

    test('does not clear on the inner bull', () {
      expect(bull.clears(Segment.innerBull, AtcVariant.anyPart), isFalse);
    });

    test('does not clear on a numbered segment', () {
      expect(bull.clears(Segment(20, Ring.triple), AtcVariant.anyPart), isFalse);
    });
  });

  group('bullseye stop (index 21)', () {
    final bullseye = AtcStop.track[21];

    test('clears on the inner bull under every variant', () {
      for (final variant in AtcVariant.values) {
        expect(bullseye.clears(Segment.innerBull, variant), isTrue, reason: '$variant');
      }
    });

    test('does not clear on the outer bull', () {
      expect(bullseye.clears(Segment.outerBull, AtcVariant.anyPart), isFalse);
    });
  });
}
