/// The 121 Ladder: finish the target in three visits. A finish climbs one
/// rung, a failure drops one, never below the start.
///
/// {@category Game modes}
library;

import 'dart:math';

import '../x01/thrown_dart.dart';
import '../x01/x01_rules.dart';
import 'checkout_attempt.dart';

/// Visits each rung gets: nine darts.
const int ladderVisits = 3;

/// How a 121 Ladder session is set up.
class Ladder121Config {
  const Ladder121Config({this.startScore = 121, this.rounds = 10})
    : assert(startScore >= 2 && startScore <= 170, 'start must be a finish'),
      assert(rounds > 0, 'a session needs at least one round');

  /// Start scores offered in setup. 81 and 101 give quicker reps.
  static const List<int> offeredStartScores = [81, 101, 121];

  final int startScore;

  final int rounds;
}

/// A 121 Ladder session, folded from its darts.
class Ladder121State {
  const Ladder121State({
    required this.config,
    required this.darts,
    required this.attempts,
  });

  final Ladder121Config config;

  final List<ThrownDart> darts;

  /// Every attempt started; the last may still be running.
  final List<CheckoutAttempt> attempts;

  List<CheckoutAttempt> get completed =>
      attempts.where((attempt) => attempt.isOver).toList();

  CheckoutAttempt? get current =>
      attempts.isNotEmpty && !attempts.last.isOver ? attempts.last : null;

  CheckoutAttempt? get lastCompleted {
    final done = completed;
    return done.isEmpty ? null : done.last;
  }

  bool get isFinished => completed.length >= config.rounds;

  int get round => min(completed.length + 1, config.rounds);

  /// The rung the next attempt is on.
  int get target => nextRung(config, completed);

  int get successes => completed.where((a) => a.succeeded).length;

  double? get successRate =>
      completed.isEmpty ? null : successes / completed.length;

  /// The highest rung finished, or null before the first finish.
  int? get highestFinished {
    final hits = completed.where((attempt) => attempt.succeeded);
    return hits.isEmpty ? null : hits.map((a) => a.target).reduce(max);
  }
}

/// The rung after [completed] attempts: up one per finish, down one per
/// failure, never below the start or above 170.
int nextRung(Ladder121Config config, Iterable<CheckoutAttempt> completed) {
  var rung = config.startScore;
  for (final attempt in completed) {
    rung = attempt.succeeded
        ? min(rung + 1, 170)
        : max(rung - 1, config.startScore);
  }
  return rung;
}

/// Folds a ladder session from its [darts]. Every rung is fixed by the
/// results before it, so unlike Checkout Challenge nothing is drawn.
Ladder121State foldLadder121(Ladder121Config config, List<ThrownDart> darts) {
  final attempts = <CheckoutAttempt>[];
  var start = 0;
  while (attempts.length < config.rounds) {
    final target = nextRung(config, attempts);
    final split = splitAttempts(
      [target],
      darts.sublist(start),
      visits: ladderVisits,
      outRule: X01OutRule.double,
    );
    final attempt = split.single;
    attempts.add(attempt);
    start += attempt.dartsUsed;
    if (!attempt.isOver) break;
  }
  return Ladder121State(
    config: config,
    darts: List.unmodifiable(darts),
    attempts: List.unmodifiable(attempts),
  );
}
