/// Random draws for training drills: never the same target twice in a row,
/// optionally weighted.
///
/// Randomness lives only here and is always handed a [Random], so a test can
/// seed it and every fold stays a pure function of the targets drawn.
///
/// {@category Game modes}
library;

import 'dart:math';

/// A uniformly random entry of [pool] other than [previous].
///
/// Back-to-back repeats are what make practice "blocked"; random order is
/// what helps retention. [previous] is allowed only when it is all there is.
T drawAvoiding<T>(Random random, List<T> pool, {T? previous}) => drawWeighted(
  random,
  {for (final item in pool) item: 1.0},
  previous: previous,
);

/// A random key of [weights], picked in proportion to its weight, other than
/// [previous] unless nothing else has a positive weight.
T drawWeighted<T>(Random random, Map<T, double> weights, {T? previous}) {
  assert(weights.isNotEmpty, 'nothing to draw from');
  var candidates = {
    for (final MapEntry(:key, :value) in weights.entries)
      if (value > 0 && key != previous) key: value,
  };
  if (candidates.isEmpty) {
    candidates = {
      for (final MapEntry(:key, :value) in weights.entries)
        if (value > 0) key: value,
    };
  }
  if (candidates.isEmpty) return weights.keys.first;

  final total = candidates.values.fold(0.0, (sum, w) => sum + w);
  var pick = random.nextDouble() * total;
  for (final MapEntry(:key, :value) in candidates.entries) {
    pick -= value;
    if (pick < 0) return key;
  }
  return candidates.keys.last;
}
