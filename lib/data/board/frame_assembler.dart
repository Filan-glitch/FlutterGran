/// Turns the board's raw notification bytes into complete frame bodies.
///
/// The board sends ASCII frames terminated by `@`, but the byte stream does not
/// respect frame boundaries. All three of these happen on real hardware:
///
/// * several frames arrive in one notification - `2.5@8.0@OUT@`
/// * one frame is split across two notifications - `2.` then `5@`
/// * the connect greeting is glued to the first hit - `GB8;1027.0@`
///
/// and the board also re-emits an identical frame within a few tens of
/// milliseconds, which would otherwise score the same dart twice.
class FrameAssembler {
  FrameAssembler({
    this.dedupeWindow = const Duration(milliseconds: 50),
    this.clock = DateTime.now,
  });

  /// How long an identical frame is treated as a repeat of the previous one.
  ///
  /// Matched to the 50 ms the board has been observed to re-emit within.
  final Duration dedupeWindow;

  /// Injectable so dedupe behaviour is deterministic under test.
  final DateTime Function() clock;

  /// The greeting sent on connect, e.g. `GB8;102`. It has no `@` terminator, so
  /// it must be recognised by shape and stripped before splitting.
  static final RegExp _greeting = RegExp(r'^GB\d;\d{3}');

  /// Guards against a garbage stream growing the buffer without bound. Any real
  /// frame is a handful of characters.
  static const int _maxBufferLength = 256;

  String _buffer = '';
  String? _lastBody;
  DateTime? _lastAt;

  /// Feeds one notification's bytes in and returns any frame bodies completed
  /// by it, `@` already stripped, in arrival order.
  List<String> feed(List<int> chunk) {
    // Latin-1 rather than UTF-8: the payload is plain ASCII, and a malformed
    // byte must not throw in the middle of a game.
    _buffer += String.fromCharCodes(chunk);

    final greeting = _greeting.firstMatch(_buffer);
    if (greeting != null) {
      _buffer = _buffer.substring(greeting.end);
    }

    if (!_buffer.contains('@')) {
      if (_buffer.length > _maxBufferLength) _buffer = '';
      return const [];
    }

    final parts = _buffer.split('@');
    // Whatever follows the last terminator is the start of the next frame.
    _buffer = parts.removeLast();

    final bodies = <String>[];
    for (final body in parts) {
      if (body.isEmpty) continue;
      if (_isRepeat(body)) continue;
      bodies.add(body);
    }
    return bodies;
  }

  bool _isRepeat(String body) {
    final now = clock();
    final last = _lastAt;
    final repeated =
        body == _lastBody &&
        last != null &&
        now.difference(last) < dedupeWindow;

    _lastBody = body;
    _lastAt = now;
    return repeated;
  }

  /// Discards partial and dedupe state.
  ///
  /// Must be called on every reconnect: a half-received frame from before the
  /// drop would otherwise be glued to the first frame after it.
  void reset() {
    _buffer = '';
    _lastBody = null;
    _lastAt = null;
  }
}
