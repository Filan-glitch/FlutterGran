import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/stats/player_stats.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:fluttergran/domain/x01/leg_reducer.dart';
import 'package:fluttergran/domain/x01/leg_state.dart';
import 'package:fluttergran/domain/x01/match_state.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:test/test.dart';

ThrownDart s(int n) => ThrownDart(Segment(n, Ring.outerSingle));
ThrownDart d(int n) => ThrownDart(Segment(n, Ring.doubleRing));
ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));
const ThrownDart miss = ThrownDart.miss();

LegState leg(int start, List<ThrownDart> darts, {int players = 1}) => foldLeg(
  GameConfig(
    startScore: start,
    playerIds: [for (var i = 1; i <= players; i++) i],
  ),
  darts,
);

PlayerStats statsFor(List<LegState> legs, {int playerId = 1}) =>
    computePlayerStats(playerId, legs);

void main() {
  group('isOneDartFinish', () {
    test('even scores up to 40, and the bull', () {
      expect(isOneDartFinish(40), isTrue);
      expect(isOneDartFinish(32), isTrue);
      expect(isOneDartFinish(2), isTrue);
      expect(isOneDartFinish(50), isTrue);
    });

    test('odd scores, and anything above 40 that is not the bull', () {
      expect(isOneDartFinish(41), isFalse);
      expect(isOneDartFinish(33), isFalse);
      expect(isOneDartFinish(42), isFalse);
      expect(isOneDartFinish(1), isFalse);
      expect(isOneDartFinish(0), isFalse);
    });
  });

  group('nothing thrown', () {
    test('reads as empty rather than zero', () {
      final stats = statsFor([leg(501, const [])]);
      expect(stats.average, isNull);
      expect(stats.checkoutRate, isNull);
      expect(stats.firstNineAverage, isNull);
      expect(stats.bestCheckout, isNull);
      expect(stats.fewestDartsToWin, isNull);
      expect(stats.legsPlayed, 1);
    });

    test('a player who was not in the leg is skipped entirely', () {
      final stats = computePlayerStats(9, [leg(501, [t(20)])]);
      expect(stats.legsPlayed, 0);
      expect(stats.dartsThrown, 0);
    });
  });

  group('scoring', () {
    test('average counts darts thrown, not turns', () {
      final stats = statsFor([
        leg(501, [t(20), t(20), t(20)]),
      ]);
      expect(stats.dartsThrown, 3);
      expect(stats.pointsScored, 180);
      expect(stats.average, 180.0);
    });

    test('a busted turn scores nothing but its darts still count', () {
      // 100 - 60 - 60 busts, so both darts are thrown for no points.
      final stats = statsFor([
        leg(100, [t(20), t(20)], players: 2),
      ]);
      expect(stats.dartsThrown, 2);
      expect(stats.pointsScored, 0);
      expect(stats.average, 0.0);
    });

    test('turn buckets, counted once each at every threshold met', () {
      final stats = statsFor([
        leg(501, [
          t(20), t(20), t(20), // 180
          t(20), t(20), s(20), // 140
          t(20), s(20), s(20), //  100
          s(20), s(20), s(20), //   60
          s(1), s(1), s(1), //       3
        ]),
      ]);

      expect(stats.turnsOf180, 1);
      expect(stats.turnsOf140Plus, 2);
      expect(stats.turnsOf100Plus, 3);
      expect(stats.turnsOf60Plus, 4);
      expect(stats.bestTurn, 180);
    });
  });

  group('first nine', () {
    test('covers only the opening three turns', () {
      // 701, so three maximums do not bust.
      final stats = statsFor([
        leg(701, [
          t(20), t(20), t(20), // turn 1
          t(20), t(20), t(20), // turn 2
          t(20), t(20), t(20), // turn 3
          s(1), s(1), s(1), //   turn 4, must not count
        ]),
      ]);

      expect(stats.firstNineDarts, 9);
      expect(stats.firstNinePoints, 540);
      expect(stats.firstNineAverage, 180.0);
      // The whole-leg average is dragged down by the fourth turn.
      expect(stats.average, lessThan(180));
    });

    test('a leg shorter than nine darts still averages correctly', () {
      final stats = statsFor([
        leg(170, [t(20), t(20), ThrownDart(Segment.innerBull)], players: 2),
      ]);
      expect(stats.firstNineDarts, 3);
    });
  });

  group('checkout statistics', () {
    test('a dart only counts when a double could have finished it', () {
      // On 60, then 40 after a single 20: only the second dart is at a double.
      final stats = statsFor([
        leg(60, [s(20), d(20)], players: 2),
      ]);

      expect(stats.dartsAtDouble, 1);
      expect(stats.doublesHit, 1);
      expect(stats.checkoutRate, 1.0);
    });

    test('missing the double costs an attempt', () {
      // On 40: a single 20 leaves 20, a triple 5 leaves 5, then D... all three
      // darts are thrown from finishable scores except the last.
      final stats = statsFor([
        leg(40, [s(1), s(1), s(1)], players: 2),
      ]);

      // 40 and 38 are finishable, 39 is not.
      expect(stats.dartsAtDouble, 2);
      expect(stats.doublesHit, 0);
      expect(stats.checkoutRate, 0.0);
    });

    test('the bull counts as a double', () {
      final stats = statsFor([
        leg(50, [ThrownDart(Segment.innerBull)], players: 2),
      ]);

      expect(stats.dartsAtDouble, 1);
      expect(stats.doublesHit, 1);
    });

    test('not counted at all when the leg is not double out', () {
      final stats = computePlayerStats(1, [
        foldLeg(
          GameConfig(startScore: 40, playerIds: const [1], doubleOut: false),
          [s(20), s(20)],
        ),
      ]);

      expect(stats.dartsAtDouble, 0);
    });
  });

  group('winning', () {
    test('records the checkout and the darts it took', () {
      final stats = statsFor([
        leg(101, [t(17), ThrownDart(Segment.innerBull)], players: 2),
      ]);

      expect(stats.legsWon, 1);
      expect(stats.bestCheckout, 101);
      expect(stats.fewestDartsToWin, 2);
      expect(stats.winRate, 1.0);
    });

    test('keeps the best of each across legs', () {
      final stats = statsFor([
        leg(101, [t(17), ThrownDart(Segment.innerBull)], players: 2),
        leg(40, [d(20)], players: 2),
      ]);

      expect(stats.legsWon, 2);
      expect(stats.bestCheckout, 101, reason: 'the higher checkout');
      expect(stats.fewestDartsToWin, 1, reason: 'the shorter leg');
    });

    test('a leg lost leaves the winning stats alone', () {
      // Player 2 wins; player 1 threw and lost.
      final lost = foldLeg(
        GameConfig(startScore: 40, playerIds: const [1, 2]),
        [s(1), s(1), s(1), d(20)],
      );

      final loser = computePlayerStats(1, [lost]);
      expect(loser.legsPlayed, 1);
      expect(loser.legsWon, 0);
      expect(loser.winRate, 0.0);
      expect(loser.bestCheckout, isNull);

      final winner = computePlayerStats(2, [lost]);
      expect(winner.legsWon, 1);
      expect(winner.bestCheckout, 40);
    });
  });

  group('matches, counted alongside legs and never instead of them', () {
    MatchState match(List<int> legWinners, {int legsToPlay = 3}) => foldMatch(
      MatchConfig(
        startScore: 501,
        playerIds: const [1, 2],
        legsToPlay: legsToPlay,
      ),
      legWinners,
    );

    test('no matches means no match figures, and legs are untouched', () {
      final stats = statsFor([
        leg(501, [t(20), t(20), t(20)]),
      ]);

      expect(stats.legsPlayed, 1);
      expect(stats.matchesPlayed, 0);
      expect(stats.matchesWon, 0);
      expect(stats.matchWinRate, isNull);
    });

    test('a best of three won two one is one match and three legs', () {
      final stats = computePlayerStats(
        1,
        [
          leg(40, [d(20)], players: 2),
          leg(40, [d(20)], players: 2),
          leg(40, [d(20)], players: 2),
        ],
        matches: [
          match(const [1, 2, 1]),
        ],
      );

      expect(stats.legsPlayed, 3, reason: 'legs still mean legs');
      expect(stats.matchesPlayed, 1);
      expect(stats.matchesWon, 1);
      expect(stats.matchWinRate, 1.0);
    });

    test('losing a match counts as played, not won', () {
      final stats = computePlayerStats(
        1,
        const [],
        matches: [
          match(const [2, 2]),
        ],
      );

      expect(stats.matchesPlayed, 1);
      expect(stats.matchesWon, 0);
      expect(stats.matchWinRate, 0.0);
    });

    test('a match still running counts as played', () {
      final stats = computePlayerStats(1, const [], matches: [match(const [1])]);

      expect(stats.matchesPlayed, 1);
      expect(stats.matchesWon, 0);
    });

    test('a match somebody else played is skipped', () {
      final stats = computePlayerStats(
        9,
        const [],
        matches: [match(const [1, 1])],
      );

      expect(stats.matchesPlayed, 0);
    });
  });

  group('across many legs', () {
    test('totals add up', () {
      final stats = statsFor([
        leg(501, [t(20), t(20), t(20)]),
        leg(501, [t(20), t(20), t(20)]),
      ]);

      expect(stats.legsPlayed, 2);
      expect(stats.dartsThrown, 6);
      expect(stats.pointsScored, 360);
      expect(stats.average, 180.0);
      expect(stats.turnsOf180, 2);
    });
  });
}
