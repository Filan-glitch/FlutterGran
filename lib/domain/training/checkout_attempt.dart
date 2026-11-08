/// [CheckoutAttempt], one try at finishing a score in a fixed number of
/// visits - the unit Checkout Challenge and the 121 Ladder are built from.
///
/// {@category Game modes}
library;

import '../x01/game_config.dart';
import '../x01/leg_reducer.dart';
import '../x01/leg_state.dart';
import '../x01/thrown_dart.dart';
import '../x01/x01_rules.dart';

/// The seat id a training attempt's solo leg plays under. Never stored.
const int trainingSeat = 0;

/// One try at checking out [target] within [visits] visits.
///
/// [leg] is a genuine solo x01 leg, so busts and the out-rule come from
/// [foldLeg]. The attempt is over on a checkout or once [visits] turns have
/// ended, a bust counting as a turn.
class CheckoutAttempt {
  const CheckoutAttempt._(this.target, this.visits, this.leg);

  /// The attempt at [target] after [darts], under [outRule].
  factory CheckoutAttempt.fold(
    int target,
    List<ThrownDart> darts, {
    required int visits,
    required X01OutRule outRule,
  }) => CheckoutAttempt._(
    target,
    visits,
    foldLeg(
      GameConfig(
        startScore: target,
        playerIds: const [trainingSeat],
        outRule: outRule,
      ),
      darts,
    ),
  );

  final int target;

  final int visits;

  final LegState leg;

  bool get succeeded => leg.isFinished;

  bool get isOver => succeeded || leg.turns.length >= visits;

  int get dartsUsed => leg.darts.length;

  /// Points still needed right now.
  int get remaining => leg.currentRemaining;

  /// Visits not yet started or in progress, counting the current one.
  int get visitsLeft => visits - leg.turns.length;
}

/// Splits [darts] into consecutive attempts, one per entry of [targets],
/// each over once it is [CheckoutAttempt.isOver].
///
/// Returns every attempt that has at least started or has a target waiting:
/// the last one may still be in progress. Darts past the last target are
/// dropped - a caller draws the next target before the next dart lands.
List<CheckoutAttempt> splitAttempts(
  List<int> targets,
  List<ThrownDart> darts, {
  required int visits,
  required X01OutRule outRule,
}) {
  final attempts = <CheckoutAttempt>[];
  var start = 0;
  for (final target in targets) {
    var attempt = CheckoutAttempt.fold(
      target,
      const [],
      visits: visits,
      outRule: outRule,
    );
    var end = start;
    while (!attempt.isOver && end < darts.length) {
      end++;
      attempt = CheckoutAttempt.fold(
        target,
        darts.sublist(start, end),
        visits: visits,
        outRule: outRule,
      );
    }
    attempts.add(attempt);
    start = end;
    if (!attempt.isOver) break;
  }
  return attempts;
}
