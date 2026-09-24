import 'dart:async';

import '../../domain/segment.dart';
import 'board_source.dart';
import 'granboard_segment_map.dart';
import 'led_command.dart';

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
  FakeBoardSource({this.greeting = 'GB8;102', this.name = 'GRANBOARD'});

  /// Greeting sent on connect. Real boards send this with no `@` terminator,
  /// so it can arrive glued to the first hit.
  final String greeting;

  final StreamController<List<int>> _raw =
      StreamController<List<int>>.broadcast();
  final StreamController<BoardConnectionState> _state =
      StreamController<BoardConnectionState>.broadcast();

  /// The name reported once connected.
  final String name;

  BoardConnectionState _current = BoardConnectionState.disconnected;
  bool _wantConnection = false;
  bool _adapterOn = true;

  /// How many times each entry point was called, for tests of whoever
  /// drives the connection.
  int connectCalls = 0;
  int disconnectCalls = 0;
  int retryCalls = 0;
  int turnOnCalls = 0;
  int forgetCalls = 0;

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
  String? get boardName => _current.isConnected ? name : null;

  @override
  bool get wantsConnection => _wantConnection;

  @override
  Future<void> connect() async {
    connectCalls++;
    _wantConnection = true;
    _attempt();
  }

  void _attempt() {
    if (!_adapterOn) {
      _setState(BoardConnectionState.bluetoothOff);
      return;
    }
    _setState(BoardConnectionState.scanning);
    _setState(BoardConnectionState.connecting);
    _setState(BoardConnectionState.connected);
    emitRaw(greeting.codeUnits);
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
    _wantConnection = false;
    _setState(BoardConnectionState.disconnected);
  }

  @override
  Future<void> retryNow() async {
    retryCalls++;
    if (!_wantConnection || _current.isConnected) return;
    _attempt();
  }

  @override
  Future<bool> turnOnBluetooth() async {
    turnOnCalls++;
    setAdapterOn();
    return true;
  }

  @override
  Future<void> forgetBoard() async => forgetCalls++;

  /// Puts the source in [state] directly, for tests of how a state looks.
  void forceState(BoardConnectionState state) => _setState(state);

  /// The board fell away while still wanted: a retry is now pending.
  void dropConnection() => _setState(
    _wantConnection
        ? BoardConnectionState.retrying
        : BoardConnectionState.disconnected,
  );

  /// The phone's Bluetooth was switched off.
  void setAdapterOff() {
    _adapterOn = false;
    if (_wantConnection) _setState(BoardConnectionState.bluetoothOff);
  }

  /// The phone's Bluetooth came back on, and a wanted board reconnects.
  void setAdapterOn() {
    _adapterOn = true;
    if (_wantConnection && !_current.isConnected) _attempt();
  }

  /// Every LED command sent while connected, oldest first.
  final List<LedCommand> ledCommands = [];

  @override
  Future<void> sendLed(LedCommand command) async {
    if (!_current.isConnected) return;
    ledCommands.add(command);
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
