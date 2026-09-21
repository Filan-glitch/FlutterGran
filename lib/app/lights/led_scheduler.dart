import 'dart:async';

import '../../data/board/led_command.dart';
import 'led_theme.dart';

/// Decides what the ring shows right now, and when.
///
/// Two layers: a resting state, and short shows played over it. When a show
/// ends the resting state is painted back. What "resting" means depends on
/// where the app is:
///
/// - **in a game:** the game's [ambient] ring - the checkout route, the ATC
///   target, or nothing;
/// - **anywhere else:** the [idle] effect, a slow pulse;
/// - **lights switched off:** dark, and nothing else is ever written.
///
/// Writes are spaced at least [minimumGap] apart, and when several arrive
/// inside one gap only the latest is sent: the ring can only show one thing,
/// so an older frame queued behind a newer one would be wrong the moment it
/// landed.
///
/// Nothing is sent, and no show is started, while [isConnected] says no: a
/// flash nobody can see is not worth a timer. The resting state is still
/// remembered, and the connect sweep paints it back once a board arrives.
class LedScheduler {
  LedScheduler(
    this._send, {
    required this.isConnected,
    required this.idle,
    this.minimumGap = const Duration(milliseconds: 60),
  });

  final void Function(LedCommand command) _send;
  final bool Function() isConnected;

  /// What the ring does outside a game.
  final LedCommand idle;
  final Duration minimumGap;

  bool _disposed = false;
  bool _enabled = true;
  bool _inGame = false;

  RingPaint _ambient = RingPaint.off;
  LedShow? _show;
  Timer? _stepTimer;

  bool _gateClosed = false;
  LedCommand? _pending;
  Timer? _gateTimer;

  RingPaint get ambient => _ambient;

  /// Whether a show currently owns the ring.
  bool get isShowing => _show != null;

  bool get inGame => _inGame;

  LedCommand get _resting => _inGame ? _ambient : idle;

  /// The master switch. Off darkens the ring once and then writes nothing;
  /// on paints the resting state back.
  set enabled(bool value) {
    if (value == _enabled) return;
    if (!value) {
      _stopShow();
      _write(RingPaint.off);
      _enabled = false;
    } else {
      _enabled = true;
      _write(_resting);
    }
  }

  /// The game's resting ring. Painted now if a game is on and nothing is
  /// showing, otherwise kept for when that is true.
  set ambient(RingPaint ring) {
    if (ring == _ambient) return;
    _ambient = ring;
    if (_inGame && _show == null) _write(ring);
  }

  /// A game screen has opened: the idle pulse gives way to its ring.
  void enterGame() {
    if (_inGame) return;
    _inGame = true;
    if (_show == null) _write(_ambient);
  }

  /// The game screen has gone: stop whatever it was showing and go back to
  /// idling.
  void leaveGame() {
    _inGame = false;
    _stopShow();
    _ambient = RingPaint.off;
    _write(idle);
  }

  /// Plays [show], unless one of higher priority is still running.
  void play(LedShow show) {
    if (_disposed || !_enabled || !isConnected()) return;
    final running = _show;
    if (running != null && show.priority < running.priority) return;
    _stepTimer?.cancel();
    _show = show;
    _runStep(show, 0);
  }

  void _runStep(LedShow show, int index) {
    if (index >= show.steps.length) {
      _show = null;
      _write(_resting);
      return;
    }
    final step = show.steps[index];
    _write(step.command);
    final hold = step.hold;
    if (hold != null) {
      _stepTimer = Timer(hold, () => _runStep(show, index + 1));
    }
  }

  void _stopShow() {
    _stepTimer?.cancel();
    _stepTimer = null;
    _show = null;
  }

  void _write(LedCommand command) {
    if (!_enabled) return;
    _deliver(command);
  }

  /// Past the master switch already: a frame queued in the gap is sent even
  /// if the switch went off meanwhile, which is exactly how the "off" frame
  /// that switching off queues still gets out.
  void _deliver(LedCommand command) {
    if (_disposed || !isConnected()) return;
    if (_gateClosed) {
      _pending = command;
      return;
    }
    _send(command);
    _gateClosed = true;
    _gateTimer = Timer(minimumGap, () {
      _gateClosed = false;
      final pending = _pending;
      _pending = null;
      if (pending != null) _deliver(pending);
    });
  }

  void dispose() {
    _disposed = true;
    _stepTimer?.cancel();
    _gateTimer?.cancel();
  }
}
