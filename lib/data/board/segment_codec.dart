import '../../domain/board_event.dart';
import '../../domain/segment.dart';
import 'granboard_segment_map.dart';

/// Turns a frame body into something the game understands.
///
/// The shipped table was verified against a real GranBoard 132 on hardware
/// day (2026-09-04): every one of the 82 scoring segments decoded correctly,
/// with nothing to correct.
class SegmentCodec {
  SegmentCodec({Map<String, Segment>? base}) : _base = base ?? granboardSegmentMap;

  final Map<String, Segment> _base;

  /// Decodes one frame body, with the `@` terminator already stripped.
  ///
  /// An unrecognised body becomes an [UnknownFrame] carrying the body verbatim,
  /// never a silently dropped or guessed hit.
  BoardEvent decode(String body) {
    if (body == buttonCode) return const ButtonPress();
    if (body == missCode) return const BoardMiss();

    final segment = _base[body];
    return segment == null ? UnknownFrame(body) : DartHit(segment);
  }

  /// Whether [body] decodes to a dart at all.
  bool knows(String body) => _base.containsKey(body);
}
