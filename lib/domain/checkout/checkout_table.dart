import 'checkout_search.dart';

/// A memoising view over [findCheckouts].
///
/// The search itself is cheap, but the UI asks for advice on every rebuild and
/// there are only a few hundred distinct questions to answer, so the answers are
/// kept once they are computed.
class CheckoutTable {
  CheckoutTable({this.limit = 3});

  /// How many routes to offer: the best one plus alternates.
  final int limit;

  final Map<int, List<CheckoutRoute>> _cache = {};

  /// Advice for a player on [remaining] with [dartsLeft] darts in hand.
  ///
  /// Empty when there is no route - too high, a bogey number, or not enough
  /// darts left - which the UI should read as "no checkout on".
  List<CheckoutRoute> routesFor(int remaining, int dartsLeft) {
    if (remaining < 2 || remaining > maxCheckout || dartsLeft < 1) {
      return const [];
    }
    return _cache.putIfAbsent(
      remaining * 4 + dartsLeft,
      () => findCheckouts(remaining, dartsLeft, limit: limit),
    );
  }

  /// The single best route, or null when there is nothing on.
  CheckoutRoute? bestFor(int remaining, int dartsLeft) {
    final routes = routesFor(remaining, dartsLeft);
    return routes.isEmpty ? null : routes.first;
  }

  /// Whether a score is low enough to be worth showing advice for at all.
  bool isCheckoutRange(int remaining) =>
      remaining >= 2 && remaining <= maxCheckout;
}
