import 'package:fluttergran/data/board/frame_assembler.dart';
import 'package:test/test.dart';

List<int> bytes(String text) => text.codeUnits;

/// A clock the test drives by hand, so dedupe behaviour is deterministic.
class FakeClock {
  DateTime now = DateTime(2026);
  DateTime call() => now;
  void advance(Duration by) => now = now.add(by);
}

void main() {
  group('the three framing cases real hardware produces', () {
    test('several frames arrive in one notification', () {
      final assembler = FrameAssembler();
      expect(assembler.feed(bytes('2.5@8.0@OUT@')), ['2.5', '8.0', 'OUT']);
    });

    test('one frame is split across two notifications', () {
      final assembler = FrameAssembler();
      expect(assembler.feed(bytes('2.')), isEmpty);
      expect(assembler.feed(bytes('5@')), ['2.5']);
    });

    test('the greeting is glued to the first hit', () {
      final assembler = FrameAssembler();
      expect(assembler.feed(bytes('GB8;1027.0@')), ['7.0']);
    });

    test('the greeting arrives on its own, ahead of the first hit', () {
      final assembler = FrameAssembler();
      expect(assembler.feed(bytes('GB7;101')), isEmpty);
      expect(assembler.feed(bytes('3.5@')), ['3.5']);
    });

    test('the greeting itself arrives split', () {
      final assembler = FrameAssembler();
      expect(assembler.feed(bytes('GB8;1')), isEmpty);
      expect(assembler.feed(bytes('02')), isEmpty);
      expect(assembler.feed(bytes('3.4@')), ['3.4']);
    });
  });

  group('dedupe', () {
    test('an identical frame inside the window is dropped', () {
      final clock = FakeClock();
      final assembler = FrameAssembler(clock: clock.call);

      expect(assembler.feed(bytes('3.4@')), ['3.4']);
      clock.advance(const Duration(milliseconds: 20));
      expect(assembler.feed(bytes('3.4@')), isEmpty);
    });

    test('the same frame after the window is a genuine second dart', () {
      final clock = FakeClock();
      final assembler = FrameAssembler(clock: clock.call);

      expect(assembler.feed(bytes('3.4@')), ['3.4']);
      clock.advance(const Duration(milliseconds: 800));
      expect(assembler.feed(bytes('3.4@')), ['3.4']);
    });

    test('a different frame inside the window is never dropped', () {
      final clock = FakeClock();
      final assembler = FrameAssembler(clock: clock.call);

      expect(assembler.feed(bytes('3.4@')), ['3.4']);
      clock.advance(const Duration(milliseconds: 5));
      expect(assembler.feed(bytes('3.5@')), ['3.5']);
    });

    test('a duplicate inside one notification is dropped too', () {
      final clock = FakeClock();
      final assembler = FrameAssembler(clock: clock.call);
      expect(assembler.feed(bytes('3.4@3.4@')), ['3.4']);
    });
  });

  group('robustness', () {
    test('empty frames are ignored', () {
      final assembler = FrameAssembler();
      expect(assembler.feed(bytes('@@2.5@')), ['2.5']);
    });

    test('an empty notification changes nothing', () {
      final assembler = FrameAssembler();
      expect(assembler.feed(const []), isEmpty);
      expect(assembler.feed(bytes('2.5@')), ['2.5']);
    });

    test('a non-ASCII byte does not throw', () {
      final assembler = FrameAssembler();
      expect(() => assembler.feed(const [0xff, 0xfe]), returnsNormally);
    });

    test('a stream with no terminator does not grow without bound', () {
      final assembler = FrameAssembler();
      for (var i = 0; i < 1000; i++) {
        assembler.feed(bytes('junkjunkjunk'));
      }

      // Flush whatever is held. It must be a bounded amount, not 12k of junk.
      final flushed = assembler.feed(bytes('@'));
      expect(flushed.single.length, lessThan(300));
    });

    test('parsing recovers on the frame after garbage', () {
      final assembler = FrameAssembler();

      // Garbage with no terminator is carried forward and corrupts the body it
      // gets glued to - which surfaces as an unknown frame rather than a wrong
      // score - but the frame after that is clean again.
      assembler.feed(bytes('garbage'));
      expect(assembler.feed(bytes('2.5@')), ['garbage2.5']);
      expect(assembler.feed(bytes('3.4@')), ['3.4']);
    });
  });

  group('reset', () {
    test('a partial frame does not survive a reconnect', () {
      final assembler = FrameAssembler();
      expect(assembler.feed(bytes('2.')), isEmpty);

      assembler.reset();

      // Without the reset this would parse as the bogus body '2.3.4'.
      expect(assembler.feed(bytes('3.4@')), ['3.4']);
    });

    test('dedupe state does not survive a reconnect', () {
      final clock = FakeClock();
      final assembler = FrameAssembler(clock: clock.call);

      expect(assembler.feed(bytes('3.4@')), ['3.4']);
      assembler.reset();
      expect(assembler.feed(bytes('3.4@')), ['3.4']);
    });
  });
}
