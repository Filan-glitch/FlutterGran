import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_leg_state.dart';
import 'package:fluttergran/domain/bulling/bulling_reducer.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/game_mode.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/stats/player_stats.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:test/test.dart';

ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));
const ThrownDart miss = ThrownDart.miss();
final ThrownDart sbull = ThrownDart(Segment.outerBull);
final ThrownDart dbull = ThrownDart(Segment.innerBull);

BullingLegState leg(
  List<ThrownDart> darts, {
  int players = 1,
  BullseyeValue bullseyeValue = BullseyeValue.two,
  int target = 21,
}) => foldBulling(
  BullingConfig(
    playerIds: [for (var i = 1; i <= players; i++) i],
    bullseyeValue: bullseyeValue,
    target: target,
  ),
  darts,
);

void main() {
  group('nothing thrown', () {
    test('reads as empty rather than zero', () {
      final stats = computeBullingStats(1, [leg(const [])]);
      expect(stats.legsPlayed, 1);
      expect(stats.dartsThrown, 0);
      expect(stats.hitRate, isNull);
      expect(stats.fewestDartsToWin, isNull);
    });

    test('a player who was not in the leg is skipped entirely', () {
      final stats = computeBullingStats(9, [
        leg([sbull]),
      ]);
      expect(stats.legsPlayed, 0);
      expect(stats.dartsThrown, 0);
    });
  });

  group('darts and hit rate', () {
    test('every dart thrown counts, scoring or not', () {
      final stats = computeBullingStats(1, [
        leg([sbull, miss, t(20)], target: 99),
      ]);
      expect(stats.dartsThrown, 3);
      expect(stats.scoringDarts, 1, reason: 'only the outer bull scored');
      expect(stats.hitRate, closeTo(1 / 3, 0.0001));
    });
  });

  group('point breakdown', () {
    test('counts outer and inner bull hits separately', () {
      final stats = computeBullingStats(1, [
        leg(
          [sbull, dbull, t(20)],
          target: 99,
          bullseyeValue: BullseyeValue.three,
        ),
      ]);
      expect(stats.outerBullHits, 1);
      expect(stats.innerBullHits, 1);
      expect(stats.pointsScored, 1 + 3);
    });
  });

  group('winning', () {
    test('records fewest darts to win', () {
      final stats = computeBullingStats(1, [
        leg([sbull, sbull], target: 2),
      ]);
      expect(stats.legsWon, 1);
      expect(stats.fewestDartsToWin, 2);
    });

    test('keeps the shorter of two winning legs', () {
      final stats = computeBullingStats(1, [
        leg([miss, sbull, sbull], target: 2),
        leg([sbull, sbull], target: 2),
      ]);
      expect(stats.legsWon, 2);
      expect(stats.fewestDartsToWin, 2, reason: 'the leg with no misses');
    });

    test('a leg not won leaves fewestDartsToWin alone', () {
      final stats = computeBullingStats(1, [
        leg([sbull], target: 99),
      ]);
      expect(stats.legsWon, 0);
      expect(stats.fewestDartsToWin, isNull);
    });
  });

  group('computePlayerStats, the mode dispatcher', () {
    test('keys all three modes even when only some have data', () {
      final stats = computePlayerStats(1);
      expect(
        stats.keys,
        containsAll([GameMode.x01, GameMode.aroundTheClock, GameMode.bulling]),
      );
    });

    test('keys Bulling legs under GameMode.bulling', () {
      final stats = computePlayerStats(
        1,
        bullingLegs: [
          leg([sbull, miss, miss], target: 99),
        ],
      );
      final bulling = stats[GameMode.bulling]! as BullingStats;
      expect(bulling.dartsThrown, 3);
    });
  });
}
