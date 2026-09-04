import 'package:fluttergran/data/board/board_source.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/domain/board_event.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:test/test.dart';

/// Lets queued stream events be delivered before assertions run.
Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeBoardSource board;
  late BoardReader reader;
  late List<BoardEvent> events;

  setUp(() {
    board = FakeBoardSource();
    reader = BoardReader(source: board);
    events = [];
    reader.events.listen(events.add);
  });

  tearDown(() async {
    await reader.dispose();
    await board.dispose();
  });

  group('the fake drives the same path the hardware will', () {
    test('a hit becomes a scored dart', () async {
      board.hit(const Segment(20, Ring.triple));
      await settle();

      expect(events.single, isA<DartHit>());
      expect((events.single as DartHit).segment.value, 60);
    });

    test('connecting sends a greeting that scores nothing', () async {
      await board.connect();
      await settle();

      expect(events, isEmpty);
      expect(board.currentState, BoardConnectionState.connected);
    });

    test('a hit glued to the greeting still scores', () async {
      board.emitGreetingGluedTo('3.4');
      await settle();

      expect(events.single, isA<DartHit>());
    });

    test('a split frame scores once, on completion', () async {
      board.emitSplit('3.4');
      await settle();

      expect(events.single, isA<DartHit>());
    });

    test('a batch of frames scores each one', () async {
      board.emitBatch(['2.5', '8.0', 'OUT']);
      await settle();

      expect(events, hasLength(3));
      expect(events[0], isA<DartHit>());
      expect(events[1], isA<DartHit>());
      expect(events[2], isA<BoardMiss>());
    });

    test('a repeated frame is not scored twice', () async {
      board.emitDuplicate('3.4');
      await settle();

      expect(events, hasLength(1));
    });

    test('the button comes through as a button, not a dart', () async {
      board.pressButton();
      await settle();

      expect(events.single, isA<ButtonPress>());
    });

    test('an unrecognised code surfaces with its body intact', () async {
      board.emitBody('4.1');
      await settle();

      expect(
        events.single,
        isA<UnknownFrame>().having((e) => e.body, 'body', '4.1'),
      );
    });
  });

  group('reconnecting', () {
    test('a frame cut short by a drop cannot corrupt the next one', () async {
      await board.connect();
      board.emitRaw('2.'.codeUnits);
      await settle();
      expect(events, isEmpty);

      await board.disconnect();
      await board.connect();
      board.emitBody('3.4');
      await settle();

      // Without the reset the body would be the bogus '2.3.4'.
      expect(events.single, isA<DartHit>());
      expect((events.single as DartHit).segment.value, 60);
    });
  });
}
