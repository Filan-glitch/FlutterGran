/// [SegmentCodec], the lookup from one complete frame body to the [BoardEvent]
/// it stands for.
///
/// {@category Data}
library;

import '../../domain/board_event.dart';
import 'granboard_segment_map.dart';

/// Turns a frame body into something the game understands, using
/// [granboardSegmentMap].
class SegmentCodec {
  /// Decodes one frame body, with the `@` terminator already stripped.
  ///
  /// An unrecognised body becomes an [UnknownFrame] carrying the body verbatim,
  /// never a silently dropped or guessed hit.
  BoardEvent decode(String body) {
    if (body == buttonCode) return const ButtonPress();
    if (body == missCode) return const BoardMiss();

    final segment = granboardSegmentMap[body];
    return segment == null ? UnknownFrame(body) : DartHit(segment);
  }
}
