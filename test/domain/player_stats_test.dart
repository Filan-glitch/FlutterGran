import 'package:fluttergran/domain/game_mode.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/stats/player_stats.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:fluttergran/domain/x01/leg_reducer.dart';
import 'package:fluttergran/domain/x01/leg_state.dart';
import 'package:fluttergran/domain/x01/match_state.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:fluttergran/domain/x01/x01_rules.dart';
import 'package:test/test.dart';

import '../support/darts.dart';

LegState leg(int start, List<ThrownDart> darts, {int players = 1}) => foldLeg(
  GameConfig(
    startScore: start,
    playerIds: [for (var i = 1; i <= players; i++) i],
  ),
  darts,
);

X01Stats statsFor(List<LegState> legs, {int playerId = 1}) =>
    computeX01Stats(playerId, legs);

void main() {
  group('isOneDartFinishFor under double-out', () {
    test('even scores up to 40, and the bull', () {
      expect(isOneDartFinishFor(40, X01OutRule.double), isTrue);
      expect(isOneDartFinishFor(32, X01OutRule.double), isTrue);
      expect(isOneDartFinishFor(2, X01OutRule.double), isTrue);
      expect(isOneDartFinishFor(50, X01OutRule.double), isTrue);
    });

    test('odd scores, and anything above 40 that is not the bull', () {
      expect(isOneDartFinishFor(41, X01OutRule.double), isFalse);
      expect(isOneDartFinishFor(33, X01OutRule.double), isFalse);
      expect(isOneDartFinishFor(42, X01OutRule.double), isFalse);
      expect(isOneDartFinishFor(1, X01OutRule.double), isFalse);
      expect(isOneDartFinishFor(0, X01OutRule.double), isFalse);
    });
  });

  group('nothing thrown', () {
    test('reads as empty rather than zero', () {
      final stats = statsFor([leg(501, const [])]);
      expect(stats.average, isNull);
      expect(stats.checkoutRateFor(X01OutRule.double), isNull);
      expect(stats.firstNineAverage, isNull);
      expect(stats.bestCheckout, isNull);
      expect(stats.fewestDartsToWin, isNull);
      expect(stats.legsPlayed, 1);
    });

    test('a player who was not in the leg is skipped entirely', () {
      final stats = computeX01Stats(9, [
        leg(501, [t(20)]),
      ]);
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
        leg(170, [
          t(20),
          t(20),
          const ThrownDart(Segment.innerBull),
        ], players: 2),
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

      expect(stats.checkoutsByRule[X01OutRule.double], (
        dartsAtFinish: 1,
        finishesHit: 1,
      ));
      expect(stats.checkoutRateFor(X01OutRule.double), 1.0);
    });

    test('missing the double costs an attempt', () {
      // Three single 1s from 40 are thrown on 40, 39 and 38: the first and
      // third are at a finish, the second is not.
      final stats = statsFor([
        leg(40, [s(1), s(1), s(1)], players: 2),
      ]);

      expect(stats.checkoutsByRule[X01OutRule.double], (
        dartsAtFinish: 2,
        finishesHit: 0,
      ));
      expect(stats.checkoutRateFor(X01OutRule.double), 0.0);
    });

    test('the bull counts as a double', () {
      final stats = statsFor([
        leg(50, [const ThrownDart(Segment.innerBull)], players: 2),
      ]);

      expect(stats.checkoutsByRule[X01OutRule.double], (
        dartsAtFinish: 1,
        finishesHit: 1,
      ));
    });

    test('kept separate per out-rule, not mixed into one aggregate', () {
      final stats = computeX01Stats(1, [
        foldLeg(
          GameConfig(
            startScore: 40,
            playerIds: const [1],
            outRule: X01OutRule.straight,
          ),
          [s(20), s(20)],
        ),
      ]);

      expect(stats.checkoutsByRule.containsKey(X01OutRule.double), isFalse);
      expect(stats.checkoutsByRule[X01OutRule.straight], (
        dartsAtFinish: 2,
        finishesHit: 1,
      ));
      expect(stats.checkoutRateFor(X01OutRule.double), isNull);
    });

    test('a triple counts as a finish attempt and hit under master-out', () {
      final stats = computeX01Stats(1, [
        foldLeg(
          GameConfig(
            startScore: 60,
            playerIds: const [1],
            outRule: X01OutRule.master,
          ),
          [t(20)],
        ),
      ]);

      expect(stats.checkoutsByRule[X01OutRule.master], (
        dartsAtFinish: 1,
        finishesHit: 1,
      ));
    });
  });

  group('winning', () {
    test('records the checkout and the darts it took', () {
      final stats = statsFor([
        leg(101, [t(17), const ThrownDart(Segment.innerBull)], players: 2),
      ]);

      expect(stats.legsWon, 1);
      expect(stats.bestCheckout, 101);
      expect(stats.fewestDartsToWin, 2);
      expect(stats.winRate, 1.0);
    });

    test('keeps the best of each across legs', () {
      final stats = statsFor([
        leg(101, [t(17), const ThrownDart(Segment.innerBull)], players: 2),
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

      final loser = computeX01Stats(1, [lost]);
      expect(loser.legsPlayed, 1);
      expect(loser.legsWon, 0);
      expect(loser.winRate, 0.0);
      expect(loser.bestCheckout, isNull);

      final winner = computeX01Stats(2, [lost]);
      expect(winner.legsWon, 1);
      expect(winner.bestCheckout, 40);
    });
  });

  group('scoring visits, the turns that could not have finished', () {
    test('average, trebles, bands and spread over scoring visits', () {
      final stats = statsFor([
        leg(501, [
          t(20), t(20), t(20), // 501 -> 321, a 180
          s(20), s(20), s(20), // 321 -> 261, a 60
        ]),
      ]);

      expect(stats.scoringVisits, 2);
      expect(stats.scoringAverage, 120.0);
      expect(stats.trebleRate, 0.5);
      expect(stats.scoringVisitBands[X01Stats.bandFor(180)], 1);
      expect(stats.scoringVisitBands[X01Stats.bandFor(60)], 1);
      // Sample standard deviation of 180 and 60.
      expect(stats.visitScoreStdDev, closeTo(84.85, 0.01));
    });

    test('a visit starting on a finish is not a scoring visit', () {
      final stats = statsFor([
        leg(301, [
          t(20), t(20), t(20), // 301 -> 121, scoring
          s(1), s(1), s(1), //   121 is on a finish
        ]),
      ]);
      expect(stats.scoringVisits, 1);
      expect(stats.scoringDarts, 3);
    });

    test('under straight out, 180 left is a finish, not a scoring visit', () {
      final stats = computeX01Stats(1, [
        foldLeg(
          GameConfig(
            startScore: 180,
            playerIds: const [1, 2],
            outRule: X01OutRule.straight,
          ),
          [s(1), s(1), s(1)],
        ),
      ]);
      expect(stats.scoringVisits, 0);
      expect(stats.scoringAverage, isNull);
    });

    test('a visit left unfinished is not a three-dart score', () {
      final stats = statsFor([
        leg(501, [t(20), t(20)]),
      ]);
      expect(stats.scoringVisits, 0);
    });

    test('bands put each visit under its lower bound', () {
      expect(X01Stats.bandFor(0), 0);
      expect(X01Stats.bandFor(19), 0);
      expect(X01Stats.bandFor(20), 1);
      expect(X01Stats.bandFor(99), 4);
      expect(X01Stats.bandFor(100), 5);
      expect(X01Stats.bandFor(179), 6);
      expect(X01Stats.bandFor(180), 7);
    });
  });

  group('visits at a finish', () {
    test('counts every visit on a three-dart finish, and the one won', () {
      final stats = statsFor([
        leg(100, [
          s(20), s(20), s(20), // player 1 on 100: a visit, not won
          s(1), s(1), s(1), //    player 2
          d(20), //               player 1 on 40: won
        ], players: 2),
      ]);

      expect(stats.checkoutVisitsByRule[X01OutRule.double], (
        visits: 2,
        won: 1,
      ));
      expect(stats.checkoutVisitRateFor(X01OutRule.double), 0.5);
    });

    test('a bogey number is not on a finish', () {
      final stats = statsFor([
        leg(169, [s(1), s(1), s(1)], players: 2),
      ]);
      expect(stats.checkoutVisitsByRule, isEmpty);
      expect(stats.checkoutVisitRateFor(X01OutRule.double), isNull);
    });
  });

  group('legs', () {
    test('win rate counts finished legs only', () {
      final stats = statsFor([
        leg(40, [d(20)], players: 2),
        leg(501, [t(20)], players: 2), // abandoned
      ]);
      expect(stats.legsPlayed, 2);
      expect(stats.legsFinished, 1);
      expect(stats.winRate, 1.0);
    });

    test('a fast leg is a hundred-average pace for its start score', () {
      expect(X01Stats.fastLegDarts(501), 15);
      expect(X01Stats.fastLegDarts(301), 9);
      expect(X01Stats.fastLegDarts(701), 21);
    });

    test('fast legs and their rate', () {
      final stats = statsFor([
        leg(40, [d(20)], players: 2), // 1 dart, inside the 1-dart pace
        leg(40, [
          s(1), s(1), s(1), // 3 darts
          s(1), s(1), s(1),
          s(1), d(18), //      5 darts, outside it
        ], players: 2),
      ]);

      expect(X01Stats.fastLegDarts(40), 1);
      expect(stats.dartsToWinByStart[40], [1, 5]);
      expect(stats.fastLegs(40), 1);
      expect(stats.fastLegRate(40), 0.5);
      expect(stats.averageDartsPerLegWon(40), 3.0);
      expect(stats.mainStartScore, 40);
      expect(stats.averageDartsPerLegWon(501), isNull);
    });

    test('on the throw and against it, from the starting seat', () {
      final leg2Starts = foldLeg(
        GameConfig(startScore: 40, playerIds: const [1, 2], startingSeat: 1),
        [d(20)],
      );

      final starter = computeX01Stats(2, [leg2Starts]);
      expect(starter.legsOnThrow, 1);
      expect(starter.winRateOnThrow, 1.0);
      expect(starter.legsAgainstThrow, 0);

      final other = computeX01Stats(1, [leg2Starts]);
      expect(other.legsAgainstThrow, 1);
      expect(other.winRateAgainstThrow, 0.0);
      expect(other.winRateOnThrow, isNull);
    });

    test('a solo leg is neither on nor against the throw', () {
      final stats = statsFor([
        leg(40, [d(20)]),
      ]);
      expect(stats.legsOnThrow + stats.legsAgainstThrow, 0);
    });

    test('ton-plus checkouts', () {
      final stats = statsFor([
        leg(101, [t(17), const ThrownDart(Segment.innerBull)], players: 2),
        leg(40, [d(20)], players: 2),
      ]);
      expect(stats.tonPlusCheckouts, 1);
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
      final stats = computeX01Stats(
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
      final stats = computeX01Stats(
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
      final stats = computeX01Stats(
        1,
        const [],
        matches: [
          match(const [1]),
        ],
      );

      expect(stats.matchesPlayed, 1);
      expect(stats.matchesWon, 0);
    });

    test('a match somebody else played is skipped', () {
      final stats = computeX01Stats(
        9,
        const [],
        matches: [
          match(const [1, 1]),
        ],
      );

      expect(stats.matchesPlayed, 0);
    });
  });

  group('computePlayerStats, the mode dispatcher', () {
    test('keys x01 legs under GameMode.x01', () {
      final stats = computePlayerStats(
        1,
        x01Legs: [
          leg(501, [t(20), t(20), t(20)]),
        ],
      );

      expect((stats[GameMode.x01]! as X01Stats).dartsThrown, 3);
    });

    test('a player with nothing thrown still gets an empty entry per mode', () {
      final stats = computePlayerStats(1);

      expect(stats.keys, containsAll([GameMode.x01, GameMode.aroundTheClock]));
      expect((stats[GameMode.x01]! as X01Stats).legsPlayed, 0);
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
