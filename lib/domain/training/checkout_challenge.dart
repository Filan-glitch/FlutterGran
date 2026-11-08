/// Checkout Challenge: a random finish each round, one visit to take it out.
///
/// [foldCheckoutChallenge] takes the drawn targets as input, so the fold is
/// pure and undo is a replay; the controller draws the next target with
/// [drawCheckoutTarget] whenever [CheckoutChallengeState.needsTarget].
///
/// {@category Game modes}
library;

import 'dart:math';

import '../checkout/checkout_search.dart';
import '../x01/thrown_dart.dart';
import '../x01/x01_rules.dart';
import 'checkout_attempt.dart';
import 'training_random.dart';

/// A range of finishes to draw from, both ends inclusive.
class CheckoutBand {
  const CheckoutBand(this.min, this.max)
    : assert(min >= 1 && min <= max, 'a band runs from min up to max');

  /// The fixed bands offered in setup.
  static const List<CheckoutBand> presets = [
    CheckoutBand(2, 40),
    CheckoutBand(41, 80),
    CheckoutBand(81, 120),
    CheckoutBand(121, 170),
  ];

  final int min;

  final int max;

  bool contains(int score) => score >= min && score <= max;

  @override
  bool operator ==(Object other) =>
      other is CheckoutBand && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);

  @override
  String toString() => '$min-$max';
}

/// Width of one adaptive level, in points.
const int checkoutLevelWidth = 10;

/// Misses in a row that drop the adaptive level by one. One checkout raises
/// it, so success settles near 38%: a hard but reachable challenge.
const int checkoutMissesToDrop = 2;

/// Number of adaptive levels under [outRule]: 2-10, 11-20, ... up to the
/// highest three-dart finish.
int checkoutLevelCount(X01OutRule outRule) =>
    (maxCheckoutFor(outRule) / checkoutLevelWidth).ceil();

/// The finishes adaptive [level] covers (0-based).
CheckoutBand checkoutLevelBand(int level, X01OutRule outRule) {
  final low = level == 0
      ? minCheckoutFor(outRule)
      : level * checkoutLevelWidth + 1;
  final high = min((level + 1) * checkoutLevelWidth, maxCheckoutFor(outRule));
  return CheckoutBand(max(low, minCheckoutFor(outRule)), high);
}

/// Every score in [band] that can be finished in one visit under [outRule].
/// The bogey numbers (169, 168, 166, 165, 163, 162, 159 under double out)
/// fall out because no route exists for them.
List<int> checkoutPool(CheckoutBand band, X01OutRule outRule) => [
  for (var score = band.min; score <= band.max; score++)
    if (findCheckouts(score, 3, limit: 1, outRule: outRule).isNotEmpty) score,
];

/// How a Checkout Challenge session is set up.
class CheckoutChallengeConfig {
  const CheckoutChallengeConfig({
    this.outRule = X01OutRule.double,
    this.band,
    this.startLevel = 3,
    this.rounds = 10,
    this.showRoute = true,
  }) : assert(rounds > 0, 'a session needs at least one round');

  final X01OutRule outRule;

  /// A fixed band to draw from, or null to adapt the band to the player.
  final CheckoutBand? band;

  /// The adaptive level the session opens on (0-based). Ignored with a band.
  final int startLevel;

  final int rounds;

  /// Whether the suggested route shows while throwing, or only once the
  /// visit is over - working the route out is part of the practice.
  final bool showRoute;

  bool get isAdaptive => band == null;
}

/// A Checkout Challenge session, folded from its targets and darts.
class CheckoutChallengeState {
  const CheckoutChallengeState({
    required this.config,
    required this.targets,
    required this.darts,
    required this.attempts,
    required this.level,
  });

  final CheckoutChallengeConfig config;

  /// Every target drawn so far, in order.
  final List<int> targets;

  /// The full ordered log.
  final List<ThrownDart> darts;

  /// Every attempt started, finished ones first; the last may be running.
  final List<CheckoutAttempt> attempts;

  /// The adaptive level the next target comes from.
  final int level;

  List<CheckoutAttempt> get completed =>
      attempts.where((attempt) => attempt.isOver).toList();

  /// The attempt being thrown, or null between attempts and at the end.
  CheckoutAttempt? get current =>
      attempts.isNotEmpty && !attempts.last.isOver ? attempts.last : null;

  /// The attempt that most recently ended, for the result of the visit.
  CheckoutAttempt? get lastCompleted {
    final done = completed;
    return done.isEmpty ? null : done.last;
  }

  bool get isFinished => completed.length >= config.rounds;

  /// Whether the controller must draw a target before the next dart.
  bool get needsTarget => !isFinished && current == null;

  /// The 1-based round being thrown, or the last one once finished.
  int get round => min(completed.length + 1, config.rounds);

  int get checkouts => completed.where((attempt) => attempt.succeeded).length;

  /// The band the next target is drawn from.
  CheckoutBand get nextBand =>
      config.band ?? checkoutLevelBand(level, config.outRule);

  /// Checkouts as a share of finished attempts, or null before the first.
  double? get successRate =>
      completed.isEmpty ? null : checkouts / completed.length;

  /// The highest target taken out, or null before the first checkout.
  int? get highestCheckout {
    final hits = completed.where((attempt) => attempt.succeeded);
    return hits.isEmpty ? null : hits.map((a) => a.target).reduce(max);
  }

  /// Darts per successful checkout, or null before the first.
  double? get dartsPerCheckout {
    final hits = completed.where((attempt) => attempt.succeeded).toList();
    if (hits.isEmpty) return null;
    return hits.fold(0, (sum, a) => sum + a.dartsUsed) / hits.length;
  }

  /// Checkouts and attempts per preset band, for the summary.
  Map<CheckoutBand, ({int attempts, int checkouts})> get byBand => {
    for (final band in CheckoutBand.presets)
      band: (
        attempts: completed.where((a) => band.contains(a.target)).length,
        checkouts: completed
            .where((a) => a.succeeded && band.contains(a.target))
            .length,
      ),
  };
}

/// Folds a session from the [targets] drawn so far and the [darts] thrown.
CheckoutChallengeState foldCheckoutChallenge(
  CheckoutChallengeConfig config,
  List<int> targets,
  List<ThrownDart> darts,
) {
  final attempts = splitAttempts(
    targets,
    darts,
    visits: 1,
    outRule: config.outRule,
  );

  final top = checkoutLevelCount(config.outRule) - 1;
  var level = config.startLevel.clamp(0, top);
  var missesInARow = 0;
  for (final attempt in attempts.where((a) => a.isOver)) {
    if (attempt.succeeded) {
      level = min(level + 1, top);
      missesInARow = 0;
    } else if (++missesInARow >= checkoutMissesToDrop) {
      level = max(level - 1, 0);
      missesInARow = 0;
    }
  }

  return CheckoutChallengeState(
    config: config,
    targets: List.unmodifiable(targets),
    darts: List.unmodifiable(darts),
    attempts: List.unmodifiable(attempts),
    level: level,
  );
}

/// Draws the next target for [state] from its [CheckoutChallengeState.nextBand],
/// never repeating the previous target.
int drawCheckoutTarget(Random random, CheckoutChallengeState state) {
  final pool = checkoutPool(state.nextBand, state.config.outRule);
  return drawAvoiding(
    random,
    pool,
    previous: state.targets.isEmpty ? null : state.targets.last,
  );
}
