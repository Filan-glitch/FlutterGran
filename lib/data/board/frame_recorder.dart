import 'dart:async';
import 'dart:io';

/// One notification's bytes, with when it arrived relative to the recording.
class RecordedChunk {
  const RecordedChunk(this.offset, this.bytes);

  /// Time since the recording started.
  final Duration offset;

  final List<int> bytes;

  /// Printable rendering of the payload, for eyeballing a capture file.
  String get ascii => String.fromCharCodes(
    bytes.map((b) => b >= 0x20 && b < 0x7f ? b : 0x2e),
  );

  @override
  String toString() => '${offset.inMilliseconds}ms $ascii';
}

/// Appends every raw notification to a file, so a session can be replayed.
///
/// The point is hardware day: whatever the board does that the code does not
/// expect gets captured once and becomes a permanent regression fixture,
/// instead of something that has to be reproduced live with darts in hand.
///
/// Format is one line per notification, tab separated:
/// `<milliseconds>\t<hex>\t<printable>`. The hex is authoritative; the
/// printable column is only there to make the file readable.
class FrameRecorder {
  FrameRecorder(this.file);

  final File file;

  DateTime? _startedAt;
  IOSink? _sink;

  bool get isRecording => _sink != null;

  Future<void> start() async {
    if (_sink != null) return;
    await file.parent.create(recursive: true);
    _sink = file.openWrite(mode: FileMode.writeOnlyAppend);
    _startedAt = DateTime.now();
  }

  void record(List<int> chunk) {
    final sink = _sink;
    final startedAt = _startedAt;
    if (sink == null || startedAt == null) return;

    final offset = DateTime.now().difference(startedAt).inMilliseconds;
    final hex = chunk
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    final printable = RecordedChunk(Duration.zero, chunk).ascii;
    sink.writeln('$offset\t$hex\t$printable');
  }

  Future<void> stop() async {
    final sink = _sink;
    _sink = null;
    _startedAt = null;
    if (sink == null) return;
    await sink.flush();
    await sink.close();
  }

  /// Reads a capture back. Malformed lines are skipped rather than throwing:
  /// a truncated final line is normal if the app died mid-write.
  static Future<List<RecordedChunk>> load(File file) async {
    final chunks = <RecordedChunk>[];
    for (final line in await file.readAsLines()) {
      final parts = line.split('\t');
      if (parts.length < 2) continue;
      final millis = int.tryParse(parts[0]);
      final hex = parts[1];
      if (millis == null || hex.isEmpty || hex.length.isOdd) continue;

      final bytes = <int>[];
      var malformed = false;
      for (var i = 0; i < hex.length; i += 2) {
        final byte = int.tryParse(hex.substring(i, i + 2), radix: 16);
        if (byte == null) {
          malformed = true;
          break;
        }
        bytes.add(byte);
      }
      if (malformed) continue;

      chunks.add(RecordedChunk(Duration(milliseconds: millis), bytes));
    }
    return chunks;
  }
}
