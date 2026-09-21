import '../../data/board/led_command.dart';
import '../../domain/checkout/checkout_search.dart';
import '../../domain/x01/leg_state.dart';
import '../../domain/x01/thrown_dart.dart';
import '../atc_controller.dart';
import '../audio/sound_controller.dart' show maximumTurn;
import '../bulling_controller.dart';
import '../game_controller.dart';
import '../training_controller.dart';
import 'led_cue.dart';

/// What the board should light up for a change in the game.
///
/// The same shape as `soundsFor`, and for the same reason: a pure function of
/// both sides of a transition, so nothing on the scoring path has to know the
/// ring exists, and every reaction is tested by asserting on a list.
///
/// A dart is exactly one entry appended to the log. Undo, resume and restart
/// move it by anything else, and light nothing - the resting ring is repainted
/// separately, from the state alone.
///
/// [endsMatch] is whether the leg finishing in [next], if it does, is the last
/// one - that turns a leg celebration into the held match-over one.
List<LedCue> ledCuesFor(
  GameSession? previous,
  GameSession next, {
  required bool endsMatch,
}) {
  if (previous == null) return const [];

  final dart = _legCues(previous.leg, next.leg, endsMatch: endsMatch);
  if (dart != null) return dart;

  if (_turnConfirmed(
    wasAwaiting: previous.awaitingTurnConfirm,
    isAwaiting: next.awaitingTurnConfirm,
    sameDarts: previous.leg.darts.length == next.leg.darts.length,
    finished: next.leg.isFinished,
    players: next.leg.config.playerIds.length,
  )) {
    return [NextThrower(next.leg.currentPlayerIndex)];
  }

  if (_newLegOpened(previous.leg, next.leg)) return const [GameOn()];
  return const [];
}

/// Around the Clock: only hitting the current target counts as a hit.
List<LedCue> ledCuesForAtc(AtcSession? previous, AtcSession next) {
  if (previous == null) return const [];
  final before = previous.leg;
  final after = next.leg;

  if (after.darts.length == before.darts.length + 1) {
    final seat = before.currentPlayerIndex;
    if (after.isFinished && !before.isFinished) return [MatchWon(seat)];

    final playerId = before.currentPlayerId;
    final cleared = after.stopIndex[playerId]! > before.stopIndex[playerId]!;
    final segment = after.darts.last.segment;
    if (cleared && segment != null) return [TargetHit(segment)];
    return const [DartMissed()];
  }

  if (_turnConfirmed(
    wasAwaiting: previous.awaitingTurnConfirm,
    isAwaiting: next.awaitingTurnConfirm,
    sameDarts: before.darts.length == after.darts.length,
    finished: after.isFinished,
    players: after.config.playerIds.length,
  )) {
    return [NextThrower(after.currentPlayerIndex)];
  }

  if (before.isFinished && after.darts.isEmpty) return const [GameOn()];
  return const [];
}

/// Bulling: the bull is the only target, and anything else is a miss.
List<LedCue> ledCuesForBulling(BullingSession? previous, BullingSession next) {
  if (previous == null) return const [];
  final before = previous.leg;
  final after = next.leg;

  if (after.darts.length == before.darts.length + 1) {
    final seat = before.currentPlayerIndex;
    if (after.isFinished && !before.isFinished) return [MatchWon(seat)];

    final segment = after.darts.last.segment;
    if (segment != null && segment.number == 25) {
      return [DartLanded(segment, seat: seat)];
    }
    return const [DartMissed()];
  }

  if (_turnConfirmed(
    wasAwaiting: previous.awaitingTurnConfirm,
    isAwaiting: next.awaitingTurnConfirm,
    sameDarts: before.darts.length == after.darts.length,
    finished: after.isFinished,
    players: after.config.playerIds.length,
  )) {
    return [NextThrower(after.currentPlayerIndex)];
  }

  if (before.isFinished && after.darts.isEmpty) return const [GameOn()];
  return const [];
}

/// Training: free practice flashes every dart; checkout practice reacts like
/// an x01 leg, with a checkout as a leg won.
List<LedCue> ledCuesForTraining(
  TrainingSession? previous,
  TrainingSession next,
) {
  switch ((previous, next)) {
    case (
      FreePracticeSession(practice: final before),
      FreePracticeSession(practice: final after),
    ):
      if (after.darts.length != before.darts.length + 1) return const [];
      return [_dartCue(after.darts.last, seat: 0)];
    case (
      CheckoutPracticeSession(leg: final before),
      CheckoutPracticeSession(leg: final after),
    ):
      return _legCues(before, after, endsMatch: false) ??
          (_newLegOpened(before, after) ? const [GameOn()] : const []);
    default:
      return const [];
  }
}

/// The cues for one x01 dart, or null when [before] to [after] is not one.
List<LedCue>? _legCues(
  LegState before,
  LegState after, {
  required bool endsMatch,
}) {
  if (after.darts.length != before.darts.length + 1) return null;

  final seat = before.currentPlayerIndex;

  // A turn only closes on the dart that closed it, so this is that dart.
  if (after.turns.length == before.turns.length + 1) {
    final turn = after.turns.last;
    if (turn.busted) return const [TurnBusted()];
    if (after.isFinished && !before.isFinished) {
      return [endsMatch ? MatchWon(seat) : LegWon(seat)];
    }
    if (turn.scored == maximumTurn) return const [Maximum()];
    if (turn.scored >= 100) return const [TonPlus()];
  }

  return [_dartCue(after.darts.last, seat: seat)];
}

LedCue _dartCue(ThrownDart dart, {required int seat}) {
  final segment = dart.segment;
  return segment == null
      ? const DartMissed()
      : DartLanded(segment, seat: seat);
}

/// The turn summary was dismissed and play moved on to someone else.
bool _turnConfirmed({
  required bool wasAwaiting,
  required bool isAwaiting,
  required bool sameDarts,
  required bool finished,
  required int players,
}) => wasAwaiting && !isAwaiting && sameDarts && !finished && players > 1;

/// A finished leg made way for a fresh one: the next leg of a match, or a
/// rematch. Anything else that empties the log is an undo, and stays dark.
bool _newLegOpened(LegState before, LegState after) =>
    before.isFinished && after.darts.isEmpty;

/// The resting ring for an x01 turn in progress: the next dart of the
/// suggested checkout in yellow, the darts after it in orange.
///
/// A bull as the next dart lights the whole ring turquoise - the ring has no
/// way to point at the bull itself.
RingPaint checkoutRing(CheckoutRoute? route) {
  if (route == null || route.darts.isEmpty) return RingPaint.off;
  final first = route.darts.first;
  if (first.number == 25) return RingPaint.all(RingColor.turquoise);

  final colours = <int, RingColor>{
    for (final later in route.darts.skip(1))
      if (later.number != 25) later.number: RingColor.orange,
  };
  colours[first.number] = RingColor.yellow;
  return RingPaint.only(colours);
}

/// The resting ring for an x01 leg, given how the route would be looked up.
///
/// Dark between turns, before a player has opened under a double or master
/// in, and once the leg is over.
RingPaint x01Ring(
  LegState leg, {
  required bool awaitingTurnConfirm,
  required CheckoutRoute? Function(int remaining, int dartsLeft) bestRoute,
}) {
  if (leg.isFinished || awaitingTurnConfirm) return RingPaint.off;
  if (!leg.hasOpened(leg.currentPlayerId)) return RingPaint.off;
  return checkoutRing(bestRoute(leg.currentRemaining, leg.dartsLeftThisTurn));
}

/// The resting ring for Around the Clock: the current player's target.
RingPaint atcRing(AtcSession session) {
  final leg = session.leg;
  if (leg.isFinished || session.awaitingTurnConfirm) return RingPaint.off;
  final stop = leg.currentStopFor(leg.currentPlayerId);
  final number = stop.number;
  if (number == null) return RingPaint.all(RingColor.turquoise);
  return RingPaint.only({number: RingColor.yellow});
}

/// The resting ring for bulling: turquoise all round, "aim for the middle".
RingPaint bullingRing(BullingSession session) {
  if (session.leg.isFinished || session.awaitingTurnConfirm) {
    return RingPaint.off;
  }
  return RingPaint.all(RingColor.turquoise);
}
