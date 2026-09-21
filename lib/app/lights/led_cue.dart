import '../../domain/segment.dart';

/// Something that happened at the board and is worth lighting up.
///
/// Semantic on purpose: this is *what* happened, and `led_theme.dart` alone
/// decides what it looks like. The reaction functions can then be tested by
/// asserting on a list of these, without a single byte or colour in sight.
sealed class LedCue {
  const LedCue();

  /// Which settings switch lets this cue through.
  LedCueKind get kind;
}

/// The groups the settings screen switches on and off.
enum LedCueKind {
  /// One dart: a hit or a miss.
  dart,

  /// Turn bookkeeping that is always shown while lights are on.
  turn,

  /// The big moments: game on, ton plus, 180, leg and match won.
  celebration,
}

/// A dart landed on [segment], thrown by the player in [seat].
final class DartLanded extends LedCue {
  const DartLanded(this.segment, {required this.seat});

  final Segment segment;
  final int seat;

  @override
  LedCueKind get kind => LedCueKind.dart;

  @override
  bool operator ==(Object other) =>
      other is DartLanded && other.segment == segment && other.seat == seat;

  @override
  int get hashCode => Object.hash(segment, seat);

  @override
  String toString() => 'DartLanded($segment, seat $seat)';
}

/// A dart landed on the target it was thrown at, where there is one - Around
/// the Clock's current number.
final class TargetHit extends LedCue {
  const TargetHit(this.segment);

  final Segment segment;

  @override
  LedCueKind get kind => LedCueKind.dart;

  @override
  bool operator ==(Object other) =>
      other is TargetHit && other.segment == segment;

  @override
  int get hashCode => segment.hashCode;

  @override
  String toString() => 'TargetHit($segment)';
}

/// A dart that scored nothing, or missed the target it was meant for.
final class DartMissed extends LedCue {
  const DartMissed();

  @override
  LedCueKind get kind => LedCueKind.dart;

  @override
  bool operator ==(Object other) => other is DartMissed;

  @override
  int get hashCode => (DartMissed).hashCode;

  @override
  String toString() => 'DartMissed()';
}

final class TurnBusted extends LedCue {
  const TurnBusted();

  @override
  LedCueKind get kind => LedCueKind.turn;

  @override
  bool operator ==(Object other) => other is TurnBusted;

  @override
  int get hashCode => (TurnBusted).hashCode;

  @override
  String toString() => 'TurnBusted()';
}

/// The next player is up, after the last turn was confirmed.
final class NextThrower extends LedCue {
  const NextThrower(this.seat);

  final int seat;

  @override
  LedCueKind get kind => LedCueKind.turn;

  @override
  bool operator ==(Object other) => other is NextThrower && other.seat == seat;

  @override
  int get hashCode => seat.hashCode;

  @override
  String toString() => 'NextThrower($seat)';
}

final class BoardConnected extends LedCue {
  const BoardConnected();

  @override
  LedCueKind get kind => LedCueKind.turn;

  @override
  bool operator ==(Object other) => other is BoardConnected;

  @override
  int get hashCode => (BoardConnected).hashCode;

  @override
  String toString() => 'BoardConnected()';
}

/// A fresh leg is open and nobody has thrown yet.
final class GameOn extends LedCue {
  const GameOn();

  @override
  LedCueKind get kind => LedCueKind.celebration;

  @override
  bool operator ==(Object other) => other is GameOn;

  @override
  int get hashCode => (GameOn).hashCode;

  @override
  String toString() => 'GameOn()';
}

/// A turn of 100 to 179.
final class TonPlus extends LedCue {
  const TonPlus();

  @override
  LedCueKind get kind => LedCueKind.celebration;

  @override
  bool operator ==(Object other) => other is TonPlus;

  @override
  int get hashCode => (TonPlus).hashCode;

  @override
  String toString() => 'TonPlus()';
}

final class Maximum extends LedCue {
  const Maximum();

  @override
  LedCueKind get kind => LedCueKind.celebration;

  @override
  bool operator ==(Object other) => other is Maximum;

  @override
  int get hashCode => (Maximum).hashCode;

  @override
  String toString() => 'Maximum()';
}

/// A leg is over, but the match it belongs to is not.
final class LegWon extends LedCue {
  const LegWon(this.seat);

  final int seat;

  @override
  LedCueKind get kind => LedCueKind.celebration;

  @override
  bool operator ==(Object other) => other is LegWon && other.seat == seat;

  @override
  int get hashCode => seat.hashCode;

  @override
  String toString() => 'LegWon($seat)';
}

/// The whole game is over - the last leg of a match, or a single-leg mode.
final class MatchWon extends LedCue {
  const MatchWon(this.seat);

  final int seat;

  @override
  LedCueKind get kind => LedCueKind.celebration;

  @override
  bool operator ==(Object other) => other is MatchWon && other.seat == seat;

  @override
  int get hashCode => seat.hashCode;

  @override
  String toString() => 'MatchWon($seat)';
}
