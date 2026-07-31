import 'package:fluttergran/domain/checkout/checkout_search.dart';
import 'package:fluttergran/domain/checkout/checkout_table.dart';
import 'package:test/test.dart';

void main() {
  test('agrees with the search it caches, everywhere', () {
    final table = CheckoutTable();
    for (var score = 2; score <= maxCheckout; score++) {
      for (var dartsLeft = 1; dartsLeft <= 3; dartsLeft++) {
        expect(
          table.routesFor(score, dartsLeft).map((r) => r.toString()),
          findCheckouts(score, dartsLeft).map((r) => r.toString()),
          reason: 'score $score with $dartsLeft darts',
        );
      }
    }
  });

  test('a repeated question gives an identical answer', () {
    final table = CheckoutTable();
    expect(table.routesFor(96, 3), same(table.routesFor(96, 3)));
  });

  test('scores out of range have nothing on', () {
    final table = CheckoutTable();
    expect(table.routesFor(171, 3), isEmpty);
    expect(table.routesFor(1, 3), isEmpty);
    expect(table.routesFor(169, 3), isEmpty);
    expect(table.isCheckoutRange(171), isFalse);
    expect(table.isCheckoutRange(170), isTrue);
    expect(table.isCheckoutRange(1), isFalse);
  });

  test('bestFor is the head of routesFor, or null', () {
    final table = CheckoutTable();
    expect(table.bestFor(40, 1)?.toString(), 'D20');
    expect(table.bestFor(169, 3), isNull);
    expect(table.bestFor(100, 1), isNull);
  });

  test('the limit is respected', () {
    expect(CheckoutTable(limit: 1).routesFor(96, 3), hasLength(1));
  });
}
