import 'package:fluttergran/data/board/segment_codec.dart';
import 'package:fluttergran/domain/board_event.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:test/test.dart';

void main() {
  group('decoding', () {
    final codec = SegmentCodec();

    test('a dart hit', () {
      expect(
        codec.decode('3.4'),
        isA<DartHit>().having(
          (e) => e.segment,
          'segment',
          const Segment(20, Ring.triple),
        ),
      );
    });

    test('both bulls', () {
      expect(
        codec.decode('8.0'),
        isA<DartHit>().having((e) => e.segment, 'segment', Segment.outerBull),
      );
      expect(
        codec.decode('4.0'),
        isA<DartHit>().having((e) => e.segment, 'segment', Segment.innerBull),
      );
    });

    test('the button and the miss', () {
      expect(codec.decode('BTN'), isA<ButtonPress>());
      expect(codec.decode('OUT'), isA<BoardMiss>());
    });
  });

  group('unknown frames', () {
    final codec = SegmentCodec();

    test('carry the body verbatim, because it is the only diagnostic', () {
      expect(
        codec.decode('99.9'),
        isA<UnknownFrame>().having((e) => e.body, 'body', '99.9'),
      );
    });

    test('the two empty matrix slots decode as unknown, not as a hit', () {
      // A valid hit can never produce these, so seeing one means the board is
      // not wired the way the table assumes.
      expect(codec.decode('4.1'), isA<UnknownFrame>());
      expect(codec.decode('8.1'), isA<UnknownFrame>());
    });

    test('garbage never becomes a score', () {
      expect(codec.decode(''), isA<UnknownFrame>());
      expect(codec.decode('garbage2.5'), isA<UnknownFrame>());
      expect(codec.decode('btn'), isA<UnknownFrame>());
    });
  });

  group('calibration overrides', () {
    test('an override wins over the shipped table', () {
      final codec = SegmentCodec();
      expect(
        codec.decode('3.4'),
        isA<DartHit>().having(
          (e) => e.segment,
          'segment',
          const Segment(20, Ring.triple),
        ),
      );

      codec.setOverride('3.4', const Segment(5, Ring.doubleRing));

      expect(
        codec.decode('3.4'),
        isA<DartHit>().having(
          (e) => e.segment,
          'segment',
          const Segment(5, Ring.doubleRing),
        ),
      );
    });

    test('an override can teach a code the table has never seen', () {
      final codec = SegmentCodec();
      expect(codec.decode('4.1'), isA<UnknownFrame>());

      codec.setOverride('4.1', const Segment(20, Ring.triple));

      expect(codec.decode('4.1'), isA<DartHit>());
      expect(codec.knows('4.1'), isTrue);
    });

    test('clearing restores the shipped table', () {
      final codec = SegmentCodec()
        ..setOverride('3.4', const Segment(1, Ring.outerSingle));
      codec.clearOverride('3.4');

      expect(
        codec.decode('3.4'),
        isA<DartHit>().having(
          (e) => e.segment,
          'segment',
          const Segment(20, Ring.triple),
        ),
      );
    });

    test('overrides survive as data, and are read-only from outside', () {
      final codec = SegmentCodec(
        overrides: {'4.1': const Segment(20, Ring.triple)},
      );
      expect(codec.overrides, hasLength(1));
      expect(
        () => codec.overrides['9.9'] = Segment.outerBull,
        throwsUnsupportedError,
      );
    });
  });
}
