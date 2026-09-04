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
}
