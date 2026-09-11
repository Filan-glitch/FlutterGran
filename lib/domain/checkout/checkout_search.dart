import '../segment.dart';
import '../x01/x01_rules.dart';

/// A way to finish a leg: an ordered list of darts whose values sum to the
/// remaining score, ending on a segment that may legally check out.
class CheckoutRoute {
  CheckoutRoute(List<Segment> darts)
    : darts = List<Segment>.unmodifiable(darts);

  final List<Segment> darts;

  int get total => darts.fold(0, (sum, segment) => sum + segment.value);

  /// The dart that finishes the leg. Legal under whichever out-rule the
  /// route was searched for - a double or the inner bull at minimum, also a
  /// triple under master-out, or anything at all under straight-out.
  Segment get finish => darts.last;

  @override
  String toString() => darts.map((segment) => segment.label).join(' ');
}

/// One representative segment per distinct scoring notation.
///
/// Inner and outer singles are the same suggestion to a player - "hit the 20" -
/// so only one is offered, otherwise every route would appear twice.
final List<Segment> _targets = List<Segment>.unmodifiable([
  for (var n = 1; n <= 20; n++) Segment(n, Ring.outerSingle),
  for (var n = 1; n <= 20; n++) Segment(n, Ring.doubleRing),
  for (var n = 1; n <= 20; n++) Segment(n, Ring.triple),
  Segment.outerBull,
  Segment.innerBull,
]);

/// Segments a leg may legally end on under [outRule].
List<Segment> _finishersFor(X01OutRule outRule) =>
    _targets.where(outRule.checksOut).toList();

/// Every distinct target, indexed by the points it scores.
///
/// Values collide - 20 is both a single 20 and a double 10 - and both are
/// genuinely different advice, so all of them are kept.
final Map<int, List<Segment>> _byValue = () {
  final map = <int, List<Segment>>{};
  for (final segment in _targets) {
    map.putIfAbsent(segment.value, () => <Segment>[]).add(segment);
  }
  return Map<int, List<Segment>>.unmodifiable(map);
}();

/// Cost of aiming a setup dart - any dart before the finish. Lower is better.
///
/// Doubles and bulls are terrible setup targets: they are small, and missing one
/// usually scores nothing useful.
///
/// Singles are all equally easy - a single 3 is no harder than a single 15 - so
/// they cost a flat amount. Triples are not: the board is practised from the 20
/// downwards, so a route through T7 is worse advice than one through T15 even
/// though both are triples. Without that gradient, 61 reads as `T7 D20` instead
/// of `T15 D8`.
int _setupCost(Segment segment) {
  switch (segment.ring) {
    case Ring.doubleRing:
    case Ring.outerBull:
    case Ring.innerBull:
      return 6000;
    case Ring.triple:
      return (20 - segment.number) * 600;
    case Ring.innerSingle:
    case Ring.outerSingle:
      return segment.number == 20 ? 0 : 1500;
  }
}

/// Cost of finishing on a segment under [outRule]. Lower is better.
///
/// Under double-out and master-out, the cost is inversely proportional to the
/// points the double is worth, which makes it flat at the top and steep at
/// the bottom - the gap between D16 and D10 is small, the gap between D8 and
/// D2 is enormous. That curve is what makes 80 read as `T20 D10` rather than
/// `T16 D16`, while 64 still reads as `T16 D8` rather than `T20 D2`.
///
/// Odd doubles carry a flat penalty because missing one leaves an odd score
/// that no double can finish. The bull carries a larger one, and under
/// master-out a triple finish carries the same one: both are the smallest
/// targets available and missing either leaves the full score behind, so
/// a double of similar value is preferred whenever one is reachable.
///
/// Under straight-out, nothing is a harder finish than any other dart of the
/// same type - hitting the last single is exactly as easy as any setup
/// single - so the finish costs the same as aiming it as a setup dart.
int _finishCost(Segment finish, X01OutRule outRule) {
  if (outRule == X01OutRule.straight) return _setupCost(finish);
  if (finish.ring == Ring.innerBull || finish.ring == Ring.triple) {
    return 40000 ~/ finish.value + 6000;
  }
  return 40000 ~/ finish.value + (finish.number.isOdd ? 3000 : 0);
}

int _routeCost(CheckoutRoute route, X01OutRule outRule) {
  var cost = _finishCost(route.finish, outRule);
  for (var i = 0; i < route.darts.length - 1; i++) {
    cost += _setupCost(route.darts[i]);
  }
  return cost;
}

/// Orders routes by how good the advice is under [outRule], best first.
///
/// Fewest darts always wins outright - finishing in two beats any three-dart
/// route however comfortable. Everything after that is the cost model above.
int _compare(CheckoutRoute a, CheckoutRoute b, X01OutRule outRule) {
  var result = a.darts.length.compareTo(b.darts.length);
  if (result != 0) return result;

  result = _routeCost(a, outRule).compareTo(_routeCost(b, outRule));
  if (result != 0) return result;

  // Same darts, different order: throw the biggest one first.
  for (var i = 0; i < a.darts.length - 1; i++) {
    result = b.darts[i].value.compareTo(a.darts[i].value);
    if (result != 0) return result;
  }

  // Stable, so the same score always yields the same advice.
  return a.toString().compareTo(b.toString());
}

/// Finds the best ways to check out [score] using at most [dartsLeft] darts,
/// under [outRule].
///
/// Returns up to [limit] routes, best advice first, or an empty list when the
/// score cannot be finished - which is the case for anything above
/// [maxCheckoutFor] the rule, for 1 under double or master-out, and for the
/// bogey numbers such as 169 and 159.
List<CheckoutRoute> findCheckouts(
  int score,
  int dartsLeft, {
  int limit = 3,
  X01OutRule outRule = X01OutRule.double,
}) {
  final minScore = outRule == X01OutRule.straight ? 1 : 2;
  if (score < minScore || dartsLeft < 1) return const [];

  final routes = <CheckoutRoute>[];

  for (final finish in _finishersFor(outRule)) {
    final beforeFinish = score - finish.value;

    if (beforeFinish == 0) {
      routes.add(CheckoutRoute([finish]));
      continue;
    }
    if (beforeFinish < 0 || dartsLeft < 2) continue;

    for (final first in _byValue[beforeFinish] ?? const <Segment>[]) {
      routes.add(CheckoutRoute([first, finish]));
    }
    if (dartsLeft < 3) continue;

    for (final first in _targets) {
      final beforeSecond = beforeFinish - first.value;
      if (beforeSecond <= 0) continue;
      for (final second in _byValue[beforeSecond] ?? const <Segment>[]) {
        routes.add(CheckoutRoute([first, second, finish]));
      }
    }
  }

  routes.sort((a, b) => _compare(a, b, outRule));
  return List<CheckoutRoute>.unmodifiable(
    routes.length <= limit ? routes : routes.sublist(0, limit),
  );
}

/// The highest score that can be checked out with three darts under
/// double-out: T20 T20 DB.
const int maxCheckout = 170;

/// The highest score checkable in three darts under [outRule].
///
/// Double-out tops out at [maxCheckout] (T20 T20 DB). Master-out and
/// straight-out both reach 180 - T20 T20 T20 - since neither requires the
/// last dart to be a double.
int maxCheckoutFor(X01OutRule outRule) =>
    outRule == X01OutRule.double ? maxCheckout : 180;
