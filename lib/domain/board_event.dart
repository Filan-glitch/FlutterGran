import 'segment.dart';

/// Anything the board can tell us, after the raw frame stream has been parsed.
///
/// Only [DartHit] and [BoardMiss] are scoring events; the others are handled by
/// the UI layer and never reach the x01 fold.
sealed class BoardEvent {
  const BoardEvent();
}

/// A dart landed in [segment].
final class DartHit extends BoardEvent {
  const DartHit(this.segment);

  final Segment segment;

  @override
  String toString() => 'DartHit(${segment.label})';
}

/// The board reported a miss (`OUT@`).
///
/// Confirmed on the 132. Every miss is this same const instance, which is why
/// board events must never be carried as provider state: two in a row are
/// equal, and state that equals the last state is not announced.
final class BoardMiss extends BoardEvent {
  const BoardMiss();

  @override
  String toString() => 'BoardMiss()';
}

/// The change-player button or touch sensor was pressed (`BTN@`).
///
/// Confirmed on the 132. Ends the turn in every turn-based mode, with the
/// darts not thrown counted as misses. Nothing the game needs depends on it
/// arriving - every screen can end a turn by itself.
final class ButtonPress extends BoardEvent {
  const ButtonPress();

  @override
  String toString() => 'ButtonPress()';
}

/// A well-formed frame whose body is not in the segment table.
///
/// [body] is the raw payload with the `@` terminator already stripped. It is
/// carried verbatim because it is the only useful diagnostic when bringing up
/// a board whose segment map has not been verified.
final class UnknownFrame extends BoardEvent {
  const UnknownFrame(this.body);

  final String body;

  @override
  String toString() => 'UnknownFrame($body)';
}
