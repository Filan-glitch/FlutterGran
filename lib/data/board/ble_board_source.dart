import 'dart:async';
import 'dart:math';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'board_source.dart';

/// The GranBoard's vendor GATT service and characteristics.
///
/// Six independent implementations agree on these. The board advertises the
/// service UUID, which is what lets the scan filter on it and so declare
/// `neverForLocation` on Android.
abstract final class GranBoardGatt {
  static final Guid service = Guid('442f1570-8a00-9a28-cbe1-e1d4212d53eb');

  /// Board to app. The only characteristic the MVP uses.
  static final Guid notify = Guid('442f1571-8a00-9a28-cbe1-e1d4212d53eb');

  /// App to board, write without response. Unused: the MVP never writes.
  static final Guid write = Guid('442f1572-8a00-9a28-cbe1-e1d4212d53eb');

  /// Advertised name prefix, used only as a fallback when the service filter
  /// finds nothing. The full name is not documented anywhere.
  static const String namePrefix = 'GRAN';
}

/// How long to wait before the next reconnect attempt.
///
/// Exponential with a jittered tail, capped at 30 seconds. The jitter matters
/// because a board that drops repeatedly would otherwise be retried on a fixed
/// cadence that can line up with whatever caused the drop.
Duration reconnectDelay(int attempt, {Random? random}) {
  // The exponent is clamped before it is raised: `pow` on two ints overflows
  // 64-bit at attempt 64 and wraps to zero, which would turn a board that has
  // been missing for a long time into a tight reconnect loop.
  final exponent = attempt.clamp(0, 16);
  final seconds = min(30.0, 0.5 * pow(2, exponent).toDouble());
  final jitter = (random ?? Random()).nextDouble() * 0.3 * seconds;
  return Duration(milliseconds: ((seconds + jitter) * 1000).round());
}

/// Android refuses a scan when an app starts more than five within 30 seconds,
/// answering `onScannerRegistered(status=6)` - "scanning too frequently" - and
/// the rejection is silent from Dart's side. Once tripped, the board stays
/// undiscoverable even though it is advertising, so scans are spaced out.
const Duration minimumScanInterval = Duration(seconds: 7);

/// How long to hold off before starting another scan.
///
/// Zero when the last scan is old enough, or there has not been one.
Duration scanCooldown(DateTime? lastScanAt, DateTime now) {
  if (lastScanAt == null) return Duration.zero;
  final since = now.difference(lastScanAt);
  if (since >= minimumScanInterval || since.isNegative) return Duration.zero;
  return minimumScanInterval - since;
}

/// Consecutive failures against a known board before scanning again.
///
/// Reconnecting to a device we have already seen needs no scan, which is both
/// faster and immune to the throttle. But a board that has been replaced or
/// re-paired will never connect by that route, so eventually give up and look.
const int reconnectsBeforeRescan = 3;

/// Reads a real GranBoard over Bluetooth Low Energy.
///
/// Deliberately thin: it produces raw notification bytes and connection state,
/// nothing else. Framing, decoding and scoring are shared with the fake, so
/// this class is the only thing that has to be verified against hardware.
class BleBoardSource implements BoardSource {
  BleBoardSource({this.scanTimeout = const Duration(seconds: 15)});

  final Duration scanTimeout;

  final StreamController<List<int>> _raw =
      StreamController<List<int>>.broadcast();
  final StreamController<BoardConnectionState> _state =
      StreamController<BoardConnectionState>.broadcast();

  BoardConnectionState _current = BoardConnectionState.disconnected;
  BluetoothDevice? _device;
  StreamSubscription<List<int>>? _valueSubscription;
  StreamSubscription<BluetoothConnectionState>? _deviceStateSubscription;
  Timer? _reconnect;
  DateTime? _lastScanAt;
  int _attempt = 0;
  bool _wantConnection = false;
  bool _disposed = false;

  @override
  Stream<List<int>> get rawFrames => _raw.stream;

  @override
  Stream<BoardConnectionState> get connectionState => _state.stream;

  @override
  BoardConnectionState get currentState => _current;

  /// The board this source last connected to, for display.
  BluetoothDevice? get device => _device;

  void _setState(BoardConnectionState state) {
    if (_disposed || _current == state) return;
    _current = state;
    _state.add(state);
  }

  @override
  Future<void> connect() async {
    _wantConnection = true;
    _attempt = 0;
    await _attemptConnect();
  }

  Future<void> _attemptConnect() async {
    if (_disposed || !_wantConnection) return;

    try {
      // A board we have already seen can be reconnected to directly. That
      // skips the scan entirely, which is faster and cannot hit the throttle.
      var board = _device;
      if (board == null) {
        _setState(BoardConnectionState.scanning);
        board = await _findBoard();
      }
      if (board == null) {
        _scheduleReconnect();
        return;
      }

      if (!_wantConnection) return;
      _setState(BoardConnectionState.connecting);

      // `nonprofit` is the licence tier this project is distributed under.
      // Shipping commercially requires a purchased licence, or swapping the
      // package for flutter_blue_ultra or universal_ble.
      await board.connect(license: License.nonprofit);

      await _subscribe(board);

      _device = board;
      _attempt = 0;
      _setState(BoardConnectionState.connected);
    } on Exception {
      // Any failure - adapter off, scan timeout, GATT error - is the same
      // situation: no board. Back off and try again.
      if (_attempt >= reconnectsBeforeRescan) _device = null;
      _scheduleReconnect();
    }
  }

  /// Finds a board by advertised service, falling back to the name prefix.
  Future<BluetoothDevice?> _findBoard() async {
    final cooldown = scanCooldown(_lastScanAt, DateTime.now());
    if (cooldown > Duration.zero) await Future<void>.delayed(cooldown);
    _lastScanAt = DateTime.now();

    final found = Completer<BluetoothDevice?>();

    final subscription = FlutterBluePlus.onScanResults.listen((results) {
      for (final result in results) {
        final advertisesService = result.advertisementData.serviceUuids
            .contains(GranBoardGatt.service);
        final namedLikeABoard = result.advertisementData.advName
            .toUpperCase()
            .startsWith(GranBoardGatt.namePrefix);

        if (advertisesService || namedLikeABoard) {
          if (!found.isCompleted) found.complete(result.device);
          return;
        }
      }
    });

    try {
      // `startScan`'s Future resolves as soon as the platform call to *start*
      // scanning returns, not after `timeout` elapses - the timeout is a
      // fire-and-forget `Timer(timeout, stopScan)` on the plugin's side. So
      // this cannot be awaited to learn whether anything was found; only
      // `found.future` can answer that, bounded by our own timeout below.
      await FlutterBluePlus.startScan(
        withServices: [GranBoardGatt.service],
        // The board advertises its service UUID, so filtering by service means
        // Android never needs a location permission for this scan.
        androidUsesFineLocation: false,
      );

      return await found.future.timeout(
        scanTimeout,
        onTimeout: () => null,
      );
    } finally {
      await subscription.cancel();
      await FlutterBluePlus.stopScan();
    }
  }

  Future<void> _subscribe(BluetoothDevice board) async {
    // Services must be rediscovered on every connection; handles from a
    // previous session are not valid.
    final services = await board.discoverServices();
    final service = services.firstWhere(
      (candidate) => candidate.uuid == GranBoardGatt.service,
      orElse: () => throw StateError('board has no GranBoard service'),
    );

    final characteristic = service.characteristics.firstWhere(
      (candidate) => candidate.uuid == GranBoardGatt.notify,
      // Some boards expose the pair without matching the documented UUID;
      // any notify characteristic on the vendor service is the right one.
      orElse: () => service.characteristics.firstWhere(
        (candidate) => candidate.properties.notify,
        orElse: () => throw StateError('board has no notify characteristic'),
      ),
    );

    await characteristic.setNotifyValue(true);

    await _valueSubscription?.cancel();
    _valueSubscription = characteristic.onValueReceived.listen(_raw.add);

    await _deviceStateSubscription?.cancel();
    _deviceStateSubscription = board.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) _onDropped();
    });
  }

  void _onDropped() {
    _setState(BoardConnectionState.disconnected);
    unawaited(_valueSubscription?.cancel());
    _valueSubscription = null;
    if (_wantConnection) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || !_wantConnection || _reconnect != null) return;

    _setState(BoardConnectionState.disconnected);
    final delay = reconnectDelay(_attempt);
    _attempt++;

    _reconnect = Timer(delay, () {
      _reconnect = null;
      unawaited(_attemptConnect());
    });
  }

  @override
  Future<void> disconnect() async {
    _wantConnection = false;
    _reconnect?.cancel();
    _reconnect = null;

    await _valueSubscription?.cancel();
    _valueSubscription = null;
    await _deviceStateSubscription?.cancel();
    _deviceStateSubscription = null;

    final board = _device;
    _device = null;
    if (board != null) {
      try {
        await board.disconnect();
      } on Exception {
        // Already gone; nothing to do.
      }
    }

    _setState(BoardConnectionState.disconnected);
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    _disposed = true;
    await _raw.close();
    await _state.close();
  }
}
