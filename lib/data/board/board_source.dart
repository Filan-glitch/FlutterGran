import 'dart:async';

import '../../domain/board_event.dart';
import 'frame_assembler.dart';
import 'led_command.dart';
import 'segment_codec.dart';

/// Where a board connection currently stands.
///
/// Every state a player could need to tell apart has its own value: "not
/// trying" is not "Bluetooth is off", and neither is "lost it, trying again".
/// They used to share `disconnected`, which is how a red icon came to mean
/// four different things.
enum BoardConnectionState {
  /// Not trying: never asked to, or the player disconnected.
  disconnected,

  /// The phone's Bluetooth is off. Picks up on its own once it comes on.
  bluetoothOff,

  /// Bluetooth permission was refused. Needs the player to try again.
  unauthorized,

  /// This device has no Bluetooth Low Energy at all.
  unsupported,

  scanning,
  connecting,
  connected,

  /// Lost the board, or failed to reach it, and a retry is scheduled.
  retrying;

  bool get isConnected => this == BoardConnectionState.connected;

  /// Actively looking for or connecting to a board right now.
  bool get isWorking =>
      this == BoardConnectionState.scanning ||
      this == BoardConnectionState.connecting;

  /// Stuck on something only the player can fix.
  bool get needsUser =>
      this == BoardConnectionState.bluetoothOff ||
      this == BoardConnectionState.unauthorized ||
      this == BoardConnectionState.unsupported;
}

/// A source of raw board notification bytes, and the way back to its LEDs.
///
/// Deliberately the narrowest possible seam: bytes in, connection state out,
/// LED commands back.
/// Everything above it - frame assembly, decoding, scoring - is identical
/// whether the bytes come from Bluetooth or from a fake, which is what lets the
/// whole app be developed and tested without hardware.
abstract class BoardSource {
  /// Raw notification payloads, exactly as delivered. No framing is implied.
  Stream<List<int>> get rawFrames;

  Stream<BoardConnectionState> get connectionState;

  BoardConnectionState get currentState;

  /// The board's advertised name, once one has been found.
  String? get boardName;

  /// Whether a connection is wanted - asked for, and not since disconnected.
  /// Stays true through drops, retries and the adapter being off.
  bool get wantsConnection;

  /// Starts wanting a connection, and keeps retrying until [disconnect].
  Future<void> connect();

  /// Stops wanting a connection, and drops any there is.
  Future<void> disconnect();

  /// Skips whatever backoff is pending and tries now. Does nothing unless a
  /// connection is wanted and not already up or underway.
  Future<void> retryNow();

  /// Asks the platform to switch Bluetooth on. Android only - elsewhere this
  /// returns false and the player has to do it in the system settings.
  Future<bool> turnOnBluetooth();

  /// Forgets the remembered board, so the next connection scans afresh.
  Future<void> forgetBoard();

  /// Shows [command] on the board's LED ring.
  ///
  /// Takes a [LedCommand] rather than bytes on purpose: the settings frames the
  /// board also accepts on this characteristic cannot be built from one. Never
  /// throws and does nothing while disconnected - lighting is decoration, and
  /// a failed write must never reach the scoring path.
  Future<void> sendLed(LedCommand command);

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
