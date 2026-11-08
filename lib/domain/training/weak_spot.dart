/// The Weak-spot Trainer: the app picks the targets, weighted towards the
/// ones the player hits least, in random order, and tracks which way the
/// misses go.
///
/// Like Checkout Challenge, the drawn targets are an input to
/// [foldWeakSpot]; the controller draws with [drawWeakSpotTarget].
///
/// {@category Game modes}
library;

import 'dart:math';

import '../x01/leg_state.dart' show dartsPerTurn;
import '../x01/thrown_dart.dart';
import 'aim_records.dart';
import 'aim_target.dart';
import 'training_random.dart';

/// Which kind of target a Weak-spot session draws from.
enum WeakSpotFocus {
  doubles,
  trebles,
  singles,

  /// All of the above, plus the bull.
  mixed,
}

/// Every target [focus] can draw.
List<AimTarget> weakSpotPool(WeakSpotFocus focus) {
  final doubles = [
    for (var n = 1; n <= 20; n++) AimTarget.double(n),
    AimTarget.bullseye,
  ];
  final trebles = [for (var n = 1; n <= 20; n++) AimTarget.triple(n)];
  final singles = [for (var n = 1; n <= 20; n++) AimTarget.single(n)];
  return List.unmodifiable(switch (focus) {
    WeakSpotFocus.doubles => doubles,
    WeakSpotFocus.trebles => trebles,
    WeakSpotFocus.singles => singles,
    WeakSpotFocus.mixed => [...doubles, ...trebles, ...singles, AimTarget.bull],
  });
}

/// How a Weak-spot session is set up.
class WeakSpotConfig {
  const WeakSpotConfig({
    this.focus = WeakSpotFocus.doubles,
    this.rounds = 10,
    this.history = const {},
  }) : assert(rounds > 0, 'a session needs at least one round');

  final WeakSpotFocus focus;

  final int rounds;

  /// What the player's saved games say about each target, from
  /// [inferAimRecords]. Empty for a session without a player.
  final Map<AimTarget, AimRecord> history;
}

/// One target in the session summary.
class WeakSpotResult {
  const WeakSpotResult({
    required this.target,
    required this.history,
    required this.session,
    required this.misses,
  });

  final AimTarget target;

  final AimRecord history;

  final AimRecord session;

  /// Misses this session, by direction.
  final Map<MissDirection, int> misses;

  /// The direction most misses went, or null with no misses.
  MissDirection? get usualMiss {
    if (misses.isEmpty) return null;
    return misses.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}

/// A Weak-spot session, folded from its targets and darts.
class WeakSpotState {
  const WeakSpotState({
    required this.config,
    required this.targets,
    required this.darts,
    required this.session,
    required this.misses,
    required this.currentVisitDarts,
    required this.visitsCompleted,
  });

  final WeakSpotConfig config;

  final List<AimTarget> targets;

  final List<ThrownDart> darts;

  /// Darts at each target this session.
  final Map<AimTarget, AimRecord> session;

  /// Misses at each target this session, by direction.
  final Map<AimTarget, Map<MissDirection, int>> misses;

  final List<ThrownDart> currentVisitDarts;

  final int visitsCompleted;

  bool get isFinished => visitsCompleted >= config.rounds;

  /// The target being thrown at, or null between visits and at the end.
  AimTarget? get currentTarget =>
      !isFinished && targets.length > visitsCompleted
      ? targets[visitsCompleted]
      : null;

  bool get needsTarget => !isFinished && currentTarget == null;

  int get round => min(visitsCompleted + 1, config.rounds);

  int get dartsLeftThisVisit => dartsPerTurn - currentVisitDarts.length;

  /// History and session together: what the next draw is weighted on.
  AimRecord combined(AimTarget target) =>
      (config.history[target] ?? const AimRecord()) +
      (session[target] ?? const AimRecord());

  /// Hits as a share of darts this session, or null before any.
  double? get hitRate {
    final thrown = session.values.fold(0, (sum, r) => sum + r.attempts);
    if (thrown == 0) return null;
    return session.values.fold(0, (sum, r) => sum + r.hits) / thrown;
  }

  /// The [count] targets thrown at this session with the lowest session hit
  /// rate, weakest first.
  List<WeakSpotResult> weakest([int count = 3]) {
    final thrown = session.keys.toList()
      ..sort(
        (a, b) => session[a]!.smoothedRate.compareTo(session[b]!.smoothedRate),
      );
    return [
      for (final target in thrown.take(count))
        WeakSpotResult(
          target: target,
          history: config.history[target] ?? const AimRecord(),
          session: session[target]!,
          misses: misses[target] ?? const {},
        ),
    ];
  }
}

/// Folds a session from the [targets] drawn so far and the [darts] thrown.
/// Each target gets one visit; darts with no target drawn are dropped.
WeakSpotState foldWeakSpot(
  WeakSpotConfig config,
  List<AimTarget> targets,
  List<ThrownDart> darts,
) {
  final session = <AimTarget, AimRecord>{};
  final misses = <AimTarget, Map<MissDirection, int>>{};
  var visitDarts = <ThrownDart>[];
  var visits = 0;

  for (final dart in darts) {
    if (visits >= config.rounds || visits >= targets.length) break;
    final target = targets[visits];
    final direction = target.missDirection(dart.segment);
    final hit = direction == MissDirection.hit;
    session[target] = (session[target] ?? const AimRecord()).record(hit: hit);
    if (!hit) {
      final tally = misses.putIfAbsent(target, () => {});
      tally[direction] = (tally[direction] ?? 0) + 1;
    }
    visitDarts.add(dart);
    if (visitDarts.length == dartsPerTurn) {
      visits++;
      visitDarts = [];
    }
  }

  return WeakSpotState(
    config: config,
    targets: List.unmodifiable(targets),
    darts: List.unmodifiable(darts),
    session: Map.unmodifiable(session),
    misses: Map.unmodifiable(misses),
    currentVisitDarts: List.unmodifiable(visitDarts),
    visitsCompleted: visits,
  );
}

/// Draws the next target, weighted by how often the player misses it: a
/// target's weight is one minus its smoothed hit rate, so weak targets come
/// up most but none is ever left out. Never the previous target.
AimTarget drawWeakSpotTarget(Random random, WeakSpotState state) =>
    drawWeighted(random, {
      for (final target in weakSpotPool(state.config.focus))
        target: 1 - state.combined(target).smoothedRate,
    }, previous: state.targets.isEmpty ? null : state.targets.last);
