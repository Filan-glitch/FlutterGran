import 'dart:async';

import '../../domain/segment.dart';
import 'board_source.dart';
import 'granboard_segment_map.dart';

/// Frame body for a segment, on a standard board.
final Map<Segment, String> segmentToCode = Map<Segment, String>.unmodifiable({
  for (final entry in granboardSegmentMap.entries) entry.value: entry.key,
});

/// A board that is not a board.
///
/// It emits the same raw byte chunks real hardware does, through the same
/// [FrameAssembler] and [SegmentCodec], rather than handing clean segments to
/// the game. That matters: framing is the most failure-prone part of this
/// integration, and it is the part that would otherwise go completely
/// unexercised until hardware arrives.
class FakeBoardSource implements BoardSource {
  FakeBoardSource({this.greeting = 'GB8;102'});

  /// Greeting sent on connect. Real boards send this with no `@` terminator,
  /// so it can arrive glued to the first hit.
  final String greeting;

  final StreamController<List<int>> _raw =
      StreamController<List<int>>.broadcast();
  final StreamController<BoardConnectionState> _state =
      StreamController<BoardConnectionState>.broadcast();

  BoardConnectionState _current = BoardConnectionState.disconnected;

  @override
  Stream<List<int>> get rawFrames => _raw.stream;

  @override
  Stream<BoardConnectionState> get connectionState => _state.stream;

  @override
  BoardConnectionState get currentState => _current;

  void _setState(BoardConnectionState state) {
    _current = state;
    _state.add(state);
  }

  @override
  Future<void> connect() async {
    _setState(BoardConnectionState.scanning);
    _setState(BoardConnectionState.connecting);
    _setState(BoardConnectionState.connected);
    emitRaw(greeting.codeUnits);
  }

  @override
  Future<void> disconnect() async {
    _setState(BoardConnectionState.disconnected);
  }

  @override
  Future<void> dispose() async {
    await _raw.close();
    await _state.close();
  }

  /// Pushes bytes through exactly as a notification would deliver them.
  void emitRaw(List<int> bytes) => _raw.add(bytes);

  /// Sends one well-formed frame.
  void emitBody(String body) => emitRaw('$body@'.codeUnits);

  /// Sends a dart hit.
  void hit(Segment segment) {
    final code = segmentToCode[segment];
    if (code == null) {
      throw ArgumentError.value(segment, 'segment', 'no frame code');
    }
    emitBody(code);
  }

  void pressButton() => emitBody(buttonCode);

  void emitMiss() => emitBody(missCode);

  /// Sends several frames in a single notification, as the board does when
  /// darts land in quick succession.
  void emitBatch(Iterable<String> bodies) =>
      emitRaw(bodies.map((body) => '$body@').join().codeUnits);

  /// Splits one frame across two notifications, as the board does when a frame
  /// straddles a packet boundary.
  void emitSplit(String body) {
    final frame = '$body@';
    final at = (frame.length / 2).floor();
    emitRaw(frame.substring(0, at).codeUnits);
    emitRaw(frame.substring(at).codeUnits);
  }

  /// Sends the same frame twice in immediate succession, which the board does
  /// and which must be deduped rather than scored twice.
  void emitDuplicate(String body) {
    emitBody(body);
    emitBody(body);
  }

  /// Sends the greeting glued to the front of a hit, as happens when the board
  /// is thrown at immediately after connecting.
  void emitGreetingGluedTo(String body) =>
      emitRaw('$greeting$body@'.codeUnits);
}
