import 'package:flutter_riverpod/misc.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/data/board/board_source.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/board/frame_assembler.dart';

/// The clock a board reader's frame dedupe runs on, moved by hand.
///
/// The assembler drops an identical frame arriving within 50 ms of the last,
/// by design. Two misses thrown a few seconds apart are two frames that look
/// exactly alike, so a test of that has to step past the window - and waiting
/// out real milliseconds would make it slow and timing-dependent.
class BoardClock {
  DateTime now = DateTime(2026, 9, 24);

  /// Moves well past the dedupe window, as a real throw would.
  void advance([Duration by = const Duration(seconds: 2)]) =>
      now = now.add(by);

  /// Reads [board] through an assembler on this clock.
  Override readerFor(FakeBoardSource board) =>
      boardReaderProvider.overrideWith((ref) {
        final reader = BoardReader(
          source: board,
          assembler: FrameAssembler(clock: () => now),
        );
        ref.onDispose(reader.dispose);
        return reader;
      });
}
