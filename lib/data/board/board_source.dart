import 'dart:async';

import '../../domain/board_event.dart';
import 'frame_assembler.dart';
import 'segment_codec.dart';

/// Where a board connection currently stands.
enum BoardConnectionState {
  disconnected,
  scanning,
  connecting,
  connected;

  bool get isConnected => this == BoardConnectionState.connected;
}

/// A source of raw board notification bytes.
///
/// Deliberately the narrowest possible seam: bytes in, connection state out.
/// Everything above it - frame assembly, decoding, scoring - is identical
/// whether the bytes come from Bluetooth or from a fake, which is what lets the
/// whole app be developed and tested without hardware.
abstract class BoardSource {
  /// Raw notification payloads, exactly as delivered. No framing is implied.
  Stream<List<int>> get rawFrames;

  Stream<BoardConnectionState> get connectionState;

  BoardConnectionState get currentState;

  Future<void> connect();

  Future<void> disconnect();

  Future<void> dispose();
}

/// Composes a [BoardSource] with framing and decoding into board events.
///
/// This is the only place the three layers are wired together, so the fake and
/// the real Bluetooth source go through exactly the same parsing path.
class BoardReader {
  BoardReader({
    required this.source,
    FrameAssembler? assembler,
    SegmentCodec? codec,
  }) : assembler = assembler ?? FrameAssembler(),
       codec = codec ?? SegmentCodec() {
    _rawSubscription = source.rawFrames.listen(_onRaw);
    _stateSubscription = source.connectionState.listen(_onStateChange);
  }

  /// The byte source being read. Exposed so callers can drive connection.
  final BoardSource source;
  final FrameAssembler assembler;
  final SegmentCodec codec;

  final StreamController<BoardEvent> _events =
      StreamController<BoardEvent>.broadcast();

  late final StreamSubscription<List<int>> _rawSubscription;
  late final StreamSubscription<BoardConnectionState> _stateSubscription;

  BoardConnectionState _lastState = BoardConnectionState.disconnected;

  Stream<BoardEvent> get events => _events.stream;

  Stream<BoardConnectionState> get connectionState => source.connectionState;

  BoardConnectionState get currentState => source.currentState;

  void _onRaw(List<int> chunk) {
    for (final body in assembler.feed(chunk)) {
      _events.add(codec.decode(body));
    }
  }

  void _onStateChange(BoardConnectionState state) {
    // A half-received frame from before a drop must never be glued to the first
    // frame after reconnecting.
    if (_lastState.isConnected && !state.isConnected) {
      assembler.reset();
    }
    _lastState = state;
  }

  Future<void> dispose() async {
    await _rawSubscription.cancel();
    await _stateSubscription.cancel();
    await _events.close();
  }
}
