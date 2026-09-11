import '../x01/x01_rules.dart';
import 'checkout_search.dart';

/// A memoising view over [findCheckouts].
///
/// The search itself is cheap, but the UI asks for advice on every rebuild and
/// there are only a few hundred distinct questions to answer, so the answers are
/// kept once they are computed.
///
/// Scoped to one [outRule] for its whole lifetime - build a separate table per
/// rule rather than passing the rule to each call, so the cache key stays as
/// simple as it always was.
class CheckoutTable {
  CheckoutTable({this.limit = 3, this.outRule = X01OutRule.double});

  /// How many routes to offer: the best one plus alternates.
  final int limit;

  /// The out-rule every answer from this table is scoped to.
  final X01OutRule outRule;

  final Map<int, List<CheckoutRoute>> _cache = {};

  /// Advice for a player on [remaining] with [dartsLeft] darts in hand.
  ///
  /// Empty when there is no route - too high, a bogey number, or not enough
  /// darts left - which the UI should read as "no checkout on".
  List<CheckoutRoute> routesFor(int remaining, int dartsLeft) {
    if (!isCheckoutRange(remaining) || dartsLeft < 1) {
      return const [];
    }
    return _cache.putIfAbsent(
      remaining * 4 + dartsLeft,
      () => findCheckouts(remaining, dartsLeft, limit: limit, outRule: outRule),
    );
  }

  /// The single best route, or null when there is nothing on.
  CheckoutRoute? bestFor(int remaining, int dartsLeft) {
    final routes = routesFor(remaining, dartsLeft);
    return routes.isEmpty ? null : routes.first;
  }

  /// Whether a score is low enough to be worth showing advice for at all.
  bool isCheckoutRange(int remaining) {
    final minScore = outRule == X01OutRule.straight ? 1 : 2;
    return remaining >= minScore && remaining <= maxCheckoutFor(outRule);
  }
}
