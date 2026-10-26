import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'board_source.dart';
import 'known_board_store.dart';
import 'led_command.dart';

/// The GranBoard's vendor GATT service and characteristics.
///
/// Six independent implementations agree on these. The board advertises the
/// service UUID, which is what lets the scan filter on it and so declare
/// `neverForLocation` on Android.
abstract final class GranBoardGatt {
  static final Guid service = Guid('442f1570-8a00-9a28-cbe1-e1d4212d53eb');

  /// Board to app: every hit, miss and button press.
  static final Guid notify = Guid('442f1571-8a00-9a28-cbe1-e1d4212d53eb');

  /// App to board, write without response. LED frames only - see
  /// `led_command.dart` for why nothing else can be sent.
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

/// Whether [error] is the platform refusing Bluetooth for want of permission.
///
/// flutter_blue_plus surfaces a denied permission as an ordinary exception
/// from the scan or connect call, with nothing more specific than its message
/// to go on. Retrying on a backoff would only re-prompt a player who already
/// said no, so this is told apart from "no board".
bool isPermissionError(Object error) =>
    error.toString().toLowerCase().contains('permission');

/// Reads a real GranBoard over Bluetooth Low Energy.
///
/// Deliberately thin: it produces raw notification bytes and connection state,
/// nothing else. Framing, decoding and scoring are shared with the fake, so
/// this class is the only thing that has to be verified against hardware.
///
/// Once [connect] has been called it keeps trying until [disconnect]: through
/// drops, failed attempts and the phone's Bluetooth being switched off and on
/// again, which it follows rather than polling for.
class BleBoardSource implements BoardSource {
  BleBoardSource({
    this.scanTimeout = const Duration(seconds: 15),
    this.connectTimeout = const Duration(seconds: 12),
    this.store = const NoKnownBoardStore(),
  });

  final Duration scanTimeout;

  /// Well under the plugin's 35-second default: a board that is switched off
  /// should fail over to the backoff quickly, not hold the button blue for
  /// half a minute.
  final Duration connectTimeout;

  /// Where the last board connected to is remembered across launches.
  final KnownBoardStore store;

  final StreamController<List<int>> _raw =
      StreamController<List<int>>.broadcast();
  final StreamController<BoardConnectionState> _state =
      StreamController<BoardConnectionState>.broadcast();

  BoardConnectionState _current = BoardConnectionState.disconnected;
  BluetoothDevice? _device;
  String? _boardName;
  StreamSubscription<List<int>>? _valueSubscription;
  BluetoothCharacteristic? _writeCharacteristic;
  StreamSubscription<BluetoothConnectionState>? _deviceStateSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  BluetoothAdapterState _adapter = BluetoothAdapterState.unknown;
  Completer<BluetoothDevice?>? _scan;
  Timer? _reconnect;
  DateTime? _lastScanAt;
  int _attempt = 0;
  bool _wantConnection = false;
  bool _busy = false;
  bool _disposed = false;

  @override
  Stream<List<int>> get rawFrames => _raw.stream;

  @override
  Stream<BoardConnectionState> get connectionState => _state.stream;

  @override
  BoardConnectionState get currentState => _current;

  @override
  String? get boardName => _boardName;

  @override
  bool get wantsConnection => _wantConnection;

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
    if (!await _watchAdapter()) return;
    await _attemptConnect();
  }

  @override
  Future<void> retryNow() async {
    if (!_wantConnection || _busy || _current.isConnected) return;
    _cancelReconnect();
    await _attemptConnect();
  }

  /// Starts following the adapter, once. False when there is no BLE at all.
  Future<bool> _watchAdapter() async {
    if (_adapterSubscription != null) return true;
    if (!await FlutterBluePlus.isSupported) {
      _wantConnection = false;
      _setState(BoardConnectionState.unsupported);
      return false;
    }
    _adapterSubscription = FlutterBluePlus.adapterState.listen(_onAdapter);
    return true;
  }

  void _onAdapter(BluetoothAdapterState adapter) {
    _adapter = adapter;
    switch (adapter) {
      case BluetoothAdapterState.on:
        // Bluetooth just came on - or was on all along and this is the first
        // report. Either way a wanted board is worth trying for now, not after
        // whatever backoff was pending while it was off.
        if (_wantConnection && !_current.isConnected && !_busy) {
          _cancelReconnect();
          _attempt = 0;
          unawaited(_attemptConnect());
        }
      case BluetoothAdapterState.off || BluetoothAdapterState.turningOff:
        _cancelReconnect();
        if (_wantConnection) _setState(BoardConnectionState.bluetoothOff);
      case BluetoothAdapterState.unauthorized:
        _cancelReconnect();
        if (_wantConnection) _setState(BoardConnectionState.unauthorized);
      case BluetoothAdapterState.unavailable:
        _cancelReconnect();
        _setState(BoardConnectionState.unsupported);
      case BluetoothAdapterState.unknown || BluetoothAdapterState.turningOn:
        break;
    }
  }

  bool get _adapterOff =>
      _adapter == BluetoothAdapterState.off ||
      _adapter == BluetoothAdapterState.turningOff;

  Future<void> _attemptConnect() async {
    if (_disposed || !_wantConnection || _busy || _current.isConnected) return;
    if (_adapterOff) {
      _setState(BoardConnectionState.bluetoothOff);
      return;
    }

    _busy = true;
    try {
      // A board we have already seen can be reconnected to directly - this
      // session's, or the one remembered from the last launch. That skips the
      // scan entirely, which is faster and cannot hit the throttle. After
      // [reconnectsBeforeRescan] failures it stops trusting either and looks.
      var board = _device;
      if (board == null && _attempt < reconnectsBeforeRescan) {
        final remembered = await store.read();
        if (remembered != null) board = BluetoothDevice.fromId(remembered);
      }
      if (board == null) {
        _setState(BoardConnectionState.scanning);
        board = await _findBoard();
      }
      if (!_wantConnection) return;
      if (board == null) {
        _scheduleReconnect();
        return;
      }

      _setState(BoardConnectionState.connecting);

      // `nonprofit` is the licence tier this project is distributed under.
      // Shipping commercially requires a purchased licence, or swapping the
      // package for flutter_blue_ultra or universal_ble.
      await board.connect(license: License.nonprofit, timeout: connectTimeout);

      // Disconnect was pressed while the connect was in flight.
      if (!_wantConnection) {
        await _quietlyDisconnect(board);
        return;
      }

      await _subscribe(board);

      _device = board;
      final name = board.platformName;
      _boardName = name.isEmpty ? null : name;
      _attempt = 0;
      _setState(BoardConnectionState.connected);
      unawaited(store.write(board.remoteId.str));
    } on Exception catch (error) {
      if (isPermissionError(error)) {
        // No backoff: retrying would only re-prompt someone who said no. The
        // next tap, or coming back to the app, asks again.
        _setState(BoardConnectionState.unauthorized);
        return;
      }
      // Any other failure - scan timeout, GATT error, a board that is off -
      // is the same situation: no board. Back off and try again.
      if (_attempt >= reconnectsBeforeRescan) _device = null;
      _scheduleReconnect();
    } finally {
      _busy = false;
    }
  }

  /// Finds a board by advertised service, falling back to the name prefix.
  Future<BluetoothDevice?> _findBoard() async {
    final cooldown = scanCooldown(_lastScanAt, DateTime.now());
    if (cooldown > Duration.zero) await Future<void>.delayed(cooldown);
    if (!_wantConnection) return null;
    _lastScanAt = DateTime.now();

    final found = _scan = Completer<BluetoothDevice?>();

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
      _scan = null;
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

    // Optional: a board without it still scores, it just stays dark.
    _writeCharacteristic = service.characteristics
        .where((candidate) => candidate.uuid == GranBoardGatt.write)
        .firstOrNull;

    await _valueSubscription?.cancel();
    _valueSubscription = characteristic.onValueReceived.listen(_raw.add);

    await _deviceStateSubscription?.cancel();
    _deviceStateSubscription = board.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) _onDropped();
    });
  }

  void _onDropped() {
    _writeCharacteristic = null;
    unawaited(_valueSubscription?.cancel());
    _valueSubscription = null;
    if (_wantConnection) {
      _scheduleReconnect();
    } else {
      _setState(BoardConnectionState.disconnected);
    }
  }

  void _scheduleReconnect() {
    if (_disposed || !_wantConnection || _reconnect != null) return;
    if (_adapterOff) {
      // Nothing to retry against. The adapter coming back on retries at once.
      _setState(BoardConnectionState.bluetoothOff);
      return;
    }

    _setState(BoardConnectionState.retrying);
    final delay = reconnectDelay(_attempt);
    _attempt++;

    _reconnect = Timer(delay, () {
      _reconnect = null;
      unawaited(_attemptConnect());
    });
  }

  void _cancelReconnect() {
    _reconnect?.cancel();
    _reconnect = null;
  }

  @override
  Future<void> sendLed(LedCommand command) async {
    final characteristic = _writeCharacteristic;
    if (characteristic == null || !_current.isConnected) return;
    try {
      await characteristic.write(
        encodeLedCommand(command),
        withoutResponse: characteristic.properties.writeWithoutResponse,
      );
    } on Exception {
      // A dropped frame is a missed flash, nothing more. The drop itself, if
      // that is what this was, arrives through the connection state.
    }
  }

  @override
  Future<bool> turnOnBluetooth() async {
    if (!Platform.isAndroid) return false;
    try {
      await FlutterBluePlus.turnOn();
      return true;
    } on Exception {
      return false;
    }
  }

  @override
  Future<void> forgetBoard() async {
    _device = null;
    _boardName = null;
    await store.write(null);
  }

  @override
  Future<void> disconnect() async {
    _wantConnection = false;
    _cancelReconnect();

    // A scan in progress would otherwise hold the source busy until it timed
    // out, swallowing a Connect tapped straight after this.
    final scan = _scan;
    if (scan != null && !scan.isCompleted) scan.complete(null);

    await _valueSubscription?.cancel();
    _valueSubscription = null;
    await _deviceStateSubscription?.cancel();
    _deviceStateSubscription = null;
    _writeCharacteristic = null;

    final board = _device;
    if (board != null) await _quietlyDisconnect(board);

    _setState(BoardConnectionState.disconnected);
  }

  Future<void> _quietlyDisconnect(BluetoothDevice board) async {
    try {
      await board.disconnect();
    } on Exception {
      // Already gone; nothing to do.
    }
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await _adapterSubscription?.cancel();
    _disposed = true;
    await _raw.close();
    await _state.close();
  }
}
