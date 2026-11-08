/// Bob's 27: a doubles drill with something at stake. Start on 27, throw one
/// visit at each double from D1 to D20 and then the bullseye; hits add the
/// double's value, a visit without one takes it away.
///
/// {@category Game modes}
library;

import '../x01/leg_state.dart' show dartsPerTurn;
import '../x01/thrown_dart.dart';
import 'aim_target.dart';

/// Points a Bob's 27 run starts on.
const int bobs27StartScore = 27;

/// The targets in order: D1 to D20, then the bullseye.
final List<AimTarget> bobs27Targets = List.unmodifiable([
  for (var number = 1; number <= 20; number++) AimTarget.double(number),
  AimTarget.bullseye,
]);

/// The best possible run: every dart a hit.
final int bobs27MaxScore =
    bobs27StartScore +
    bobs27Targets.fold(0, (sum, t) => sum + dartsPerTurn * _value(t));

int _value(AimTarget target) => target.isBull ? 50 : target.number * 2;

/// How a Bob's 27 run is set up.
class Bobs27Config {
  const Bobs27Config({this.playToEnd = false});

  /// Keep going after the score drops to zero or below. The run still
  /// counts as failed - this only lets a beginner see the whole board.
  final bool playToEnd;
}

/// One finished visit.
class Bobs27Visit {
  const Bobs27Visit({
    required this.target,
    required this.darts,
    required this.scoreAfter,
  });

  final AimTarget target;

  final List<ThrownDart> darts;

  final int scoreAfter;

  int get hits => darts.where((d) => target.isHitBy(d.segment)).length;

  /// Points the visit added, negative for a blank.
  int get scored => hits == 0 ? -_value(target) : hits * _value(target);
}

/// A Bob's 27 run, folded from its darts.
class Bobs27State {
  const Bobs27State({
    required this.config,
    required this.darts,
    required this.visits,
    required this.currentVisitDarts,
  });

  final Bobs27Config config;

  final List<ThrownDart> darts;

  final List<Bobs27Visit> visits;

  final List<ThrownDart> currentVisitDarts;

  int get score => visits.isEmpty ? bobs27StartScore : visits.last.scoreAfter;

  /// Whether the score has dropped to zero or below at any point.
  bool get droppedOut => visits.any((visit) => visit.scoreAfter <= 0);

  bool get isFinished =>
      visits.length == bobs27Targets.length ||
      (droppedOut && !config.playToEnd);

  /// A run passes only by reaching the end without ever dropping out.
  bool get passed => visits.length == bobs27Targets.length && !droppedOut;

  /// The target being thrown at, or null once finished.
  AimTarget? get currentTarget =>
      isFinished ? null : bobs27Targets[visits.length];

  int get dartsLeftThisVisit => dartsPerTurn - currentVisitDarts.length;

  /// Doubles hit as a share of darts thrown at them, or null before any.
  double? get hitRate {
    final thrown = visits.fold(0, (sum, v) => sum + v.darts.length);
    if (thrown == 0) return null;
    return visits.fold(0, (sum, v) => sum + v.hits) / thrown;
  }
}

/// Folds a Bob's 27 run from its [darts]. Darts after the run ends are
/// ignored.
Bobs27State foldBobs27(Bobs27Config config, List<ThrownDart> darts) {
  final visits = <Bobs27Visit>[];
  var visitDarts = <ThrownDart>[];
  var score = bobs27StartScore;
  var droppedOut = false;

  for (final dart in darts) {
    if (visits.length == bobs27Targets.length) break;
    if (droppedOut && !config.playToEnd) break;

    visitDarts.add(dart);
    if (visitDarts.length < dartsPerTurn) continue;

    final target = bobs27Targets[visits.length];
    final hits = visitDarts.where((d) => target.isHitBy(d.segment)).length;
    score += hits == 0 ? -_value(target) : hits * _value(target);
    visits.add(
      Bobs27Visit(
        target: target,
        darts: List.unmodifiable(visitDarts),
        scoreAfter: score,
      ),
    );
    droppedOut |= score <= 0;
    visitDarts = [];
  }

  return Bobs27State(
    config: config,
    darts: List.unmodifiable(darts),
    visits: List.unmodifiable(visits),
    currentVisitDarts: List.unmodifiable(visitDarts),
  );
}
