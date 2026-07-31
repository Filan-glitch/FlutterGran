import '../../domain/board_event.dart';
import '../../domain/segment.dart';
import 'granboard_segment_map.dart';

/// Turns a frame body into something the game understands.
///
/// The base table is the standard board map. Calibration writes corrections
/// into an override layer on top of it, so a board whose matrix differs can be
/// fixed without changing the shipped table - which matters because the
/// GRANBOARD 132's matrix has never been verified against a public source.
class SegmentCodec {
  SegmentCodec({
    Map<String, Segment>? base,
    Map<String, Segment> overrides = const {},
  }) : _base = base ?? granboardSegmentMap,
       _overrides = Map<String, Segment>.of(overrides);

  final Map<String, Segment> _base;
  final Map<String, Segment> _overrides;

  /// Corrections recorded during calibration, keyed by frame body.
  Map<String, Segment> get overrides => Map<String, Segment>.unmodifiable(_overrides);

  /// Decodes one frame body, with the `@` terminator already stripped.
  ///
  /// An unrecognised body becomes an [UnknownFrame] carrying the body verbatim,
  /// never a silently dropped or guessed hit: on an unverified board that log
  /// line is the only way to find out what the hardware actually sends.
  BoardEvent decode(String body) {
    if (body == buttonCode) return const ButtonPress();
    if (body == missCode) return const BoardMiss();

    final segment = _overrides[body] ?? _base[body];
    return segment == null ? UnknownFrame(body) : DartHit(segment);
  }

  /// Records that [body] really means [segment] on this board.
  void setOverride(String body, Segment segment) {
    _overrides[body] = segment;
  }

  void clearOverride(String body) {
    _overrides.remove(body);
  }

  void clearAllOverrides() {
    _overrides.clear();
  }

  /// Whether [body] decodes to a dart at all, before or after overrides.
  bool knows(String body) =>
      _overrides.containsKey(body) || _base.containsKey(body);
}
