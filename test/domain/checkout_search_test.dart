import 'package:fluttergran/domain/checkout/checkout_search.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:test/test.dart';

/// Scores below 171 that cannot be finished with three darts.
const Set<int> bogeyNumbers = {159, 162, 163, 165, 166, 168, 169};

String route(int score, int dartsLeft) =>
    findCheckouts(score, dartsLeft).first.toString();

void main() {
  group('route validity', () {
    test('every suggested route is legal, for every reachable score', () {
      for (var score = 2; score <= maxCheckout; score++) {
        for (var dartsLeft = 1; dartsLeft <= 3; dartsLeft++) {
          for (final candidate in findCheckouts(score, dartsLeft)) {
            expect(
              candidate.total,
              score,
              reason: '$candidate does not add up to $score',
            );
            expect(
              candidate.finish.isDouble,
              isTrue,
              reason: '$candidate finishes on a segment that cannot check out',
            );
            expect(
              candidate.darts.length,
              lessThanOrEqualTo(dartsLeft),
              reason: '$candidate uses more than $dartsLeft darts',
            );
          }
        }
      }
    });

    test('at most three suggestions are returned', () {
      for (var score = 2; score <= maxCheckout; score++) {
        expect(findCheckouts(score, 3).length, lessThanOrEqualTo(3));
      }
      expect(findCheckouts(60, 3, limit: 1), hasLength(1));
    });

    test('advice is ordered fewest darts first', () {
      for (var score = 2; score <= maxCheckout; score++) {
        final routes = findCheckouts(score, 3);
        for (var i = 1; i < routes.length; i++) {
          expect(
            routes[i].darts.length,
            greaterThanOrEqualTo(routes[i - 1].darts.length),
          );
        }
      }
    });
  });

  group('which scores can be finished at all', () {
    test('exactly the bogey numbers are unreachable below 171', () {
      final unreachable = <int>{
        for (var score = 2; score <= maxCheckout; score++)
          if (findCheckouts(score, 3).isEmpty) score,
      };
      expect(unreachable, bogeyNumbers);
    });

    test('nothing above 170 can be finished with three darts', () {
      for (var score = maxCheckout + 1; score <= 200; score++) {
        expect(findCheckouts(score, 3), isEmpty, reason: 'score $score');
      }
    });

    test('1 can never be finished, because no double is worth 1', () {
      expect(findCheckouts(1, 3), isEmpty);
    });

    test('170 is the highest checkout and it is the only route to it', () {
      expect(findCheckouts(maxCheckout, 3), hasLength(1));
      expect(route(maxCheckout, 3), 'T20 T20 DB');
    });
  });

  group('the big three-dart finishes everyone agrees on', () {
    test('bull finishes', () {
      expect(route(170, 3), 'T20 T20 DB');
      expect(route(167, 3), 'T20 T19 DB');
      expect(route(164, 3), 'T20 T18 DB');
      expect(route(161, 3), 'T20 T17 DB');
    });

    test('the highest finish on a double', () {
      expect(route(160, 3), 'T20 T20 D20');
    });

    test('the three-dart finishes just above 100', () {
      expect(route(120, 3), 'T20 S20 D20');
    });
  });

  group('finishes that match the published tables', () {
    // These are the entries the standard checkout tables agree on, and they are
    // what the preference model exists to reproduce. A change to the cost model
    // that breaks one of these has made the advice worse, not different.
    test('the T20 range', () {
      expect(route(96, 3), 'T20 D18');
      expect(route(92, 3), 'T20 D16');
      expect(route(84, 3), 'T20 D12');
      expect(route(76, 3), 'T20 D8');
    });

    test('setting up on the high triples', () {
      expect(route(97, 3), 'T19 D20');
      expect(route(89, 3), 'T19 D16');
      expect(route(81, 3), 'T19 D12');
      expect(route(78, 3), 'T18 D12');
      expect(route(77, 3), 'T19 D10');
    });

    test('the D8 ladder, where the double outweighs the familiar triple', () {
      expect(route(73, 3), 'T19 D8');
      expect(route(70, 3), 'T18 D8');
      expect(route(67, 3), 'T17 D8');
      expect(route(64, 3), 'T16 D8');
      expect(route(61, 3), 'T15 D8');
    });

    test('low scores leave the biggest double, never D2', () {
      expect(route(19, 3), 'S3 D8');
      expect(route(17, 3), 'S1 D8');
      expect(route(11, 3), 'S3 D4');
      expect(route(9, 3), 'S1 D4');
    });
  });

  group('one dart left', () {
    test('the doubles that finish outright', () {
      expect(route(40, 1), 'D20');
      expect(route(32, 1), 'D16');
      expect(route(36, 1), 'D18');
      expect(route(2, 1), 'D1');
      expect(route(50, 1), 'DB');
    });

    test('an odd score cannot be finished with one dart', () {
      for (var score = 3; score <= 40; score += 2) {
        expect(findCheckouts(score, 1), isEmpty, reason: 'score $score');
      }
    });

    test('41 needs a second dart', () {
      expect(findCheckouts(41, 1), isEmpty);
      expect(findCheckouts(41, 2), isNotEmpty);
    });
  });

  group('two darts left', () {
    test('the classic two-dart finishes', () {
      expect(route(100, 2), 'T20 D20');
      expect(route(110, 2), 'T20 DB');
      expect(route(80, 2), 'T20 D10');
    });

    test('100 cannot be done with one dart', () {
      expect(findCheckouts(100, 1), isEmpty);
    });

    test('a three-dart finish is withheld when only two darts remain', () {
      // 130 needs three darts; offering it on two would be wrong advice.
      expect(findCheckouts(130, 3), isNotEmpty);
      expect(findCheckouts(130, 2), isEmpty);
    });
  });

  group('preference', () {
    test('a shorter route always beats a longer one', () {
      // On 50 the bull ends it now; S10 then D20 takes two darts.
      expect(route(50, 3), 'DB');
    });

    test('D20 is preferred over an equally short finish on a worse double', () {
      final best = findCheckouts(60, 2).first;
      expect(best.finish, const Segment(20, Ring.doubleRing));
      expect(best.toString(), 'S20 D20');
    });

    test('suggestions are stable across calls', () {
      for (var score = 2; score <= maxCheckout; score++) {
        expect(
          findCheckouts(score, 3).map((r) => r.toString()),
          findCheckouts(score, 3).map((r) => r.toString()),
        );
      }
    });
  });
}
