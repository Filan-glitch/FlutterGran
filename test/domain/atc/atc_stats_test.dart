import 'package:fluttergran/domain/atc/atc_config.dart';
import 'package:fluttergran/domain/atc/atc_leg_state.dart';
import 'package:fluttergran/domain/atc/atc_reducer.dart';
import 'package:fluttergran/domain/atc/atc_stop.dart';
import 'package:fluttergran/domain/atc/atc_variant.dart';
import 'package:fluttergran/domain/game_mode.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/stats/player_stats.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:test/test.dart';

ThrownDart s(int n) => ThrownDart(Segment(n, Ring.outerSingle));
ThrownDart d(int n) => ThrownDart(Segment(n, Ring.doubleRing));
const ThrownDart miss = ThrownDart.miss();
final ThrownDart sbull = ThrownDart(Segment.outerBull);
final ThrownDart dbull = ThrownDart(Segment.innerBull);

AtcLegState leg(
  List<ThrownDart> darts, {
  int players = 1,
  AtcVariant variant = AtcVariant.anyPart,
}) => foldAroundTheClock(
  AtcConfig(
    playerIds: [for (var i = 1; i <= players; i++) i],
    variant: variant,
  ),
  darts,
);

void main() {
  group('nothing thrown', () {
    test('reads as empty rather than zero', () {
      final stats = computeAtcStats(1, [leg(const [])]);
      expect(stats.legsPlayed, 1);
      expect(stats.dartsThrown, 0);
      expect(stats.hitRate, isNull);
      expect(stats.fewestDartsToWin, isNull);
    });

    test('a player who was not in the leg is skipped entirely', () {
      final stats = computeAtcStats(9, [leg([s(1)])]);
      expect(stats.legsPlayed, 0);
      expect(stats.dartsThrown, 0);
    });
  });

  group('darts and hit rate', () {
    test('every dart thrown counts, hits or not', () {
      final stats = computeAtcStats(1, [
        leg([s(1), miss, s(5)]),
      ]);
      expect(stats.dartsThrown, 3);
      expect(stats.qualifyingDarts, 1, reason: 'only s(1) clears stop 1');
      expect(stats.hitRate, closeTo(1 / 3, 0.0001));
    });
  });

  group('per-stop accuracy', () {
    test('attempts and hits are keyed by the stop that was current', () {
      final stats = computeAtcStats(1, [
        leg([s(5), s(1), s(1)]), // stop 1: miss, then a hit
      ]);

      final stop1 = AtcStop.track[0];
      expect(stats.perStop[stop1]?.attempts, 2);
      expect(stats.perStop[stop1]?.hits, 1);
    });

    test('a stop cleared is never attempted again', () {
      // s(1) clears stop 1, s(2) clears stop 2 (now current), then a second
      // s(1) is thrown while stop 3 is current - it is an attempt on stop 3,
      // not a second attempt on the already-cleared stop 1.
      final stats = computeAtcStats(1, [
        leg([s(1), s(2), s(1)]),
      ]);

      final stop1 = AtcStop.track[0];
      final stop2 = AtcStop.track[1];
      final stop3 = AtcStop.track[2];
      expect(stats.perStop[stop1], (attempts: 1, hits: 1));
      expect(stats.perStop[stop2], (attempts: 1, hits: 1));
      expect(stats.perStop[stop3], (attempts: 1, hits: 0));
    });
  });

  group('winning', () {
    test('records fewest darts to win', () {
      final log = [for (var n = 1; n <= 20; n++) s(n), sbull, dbull];
      final stats = computeAtcStats(1, [leg(log)]);

      expect(stats.legsWon, 1);
      expect(stats.fewestDartsToWin, 22);
    });

    test('keeps the shorter of two winning legs', () {
      final shortLog = [for (var n = 1; n <= 20; n++) d(n), sbull, dbull];
      final longLog = [
        for (var n = 1; n <= 20; n++) ...[miss, d(n)],
        sbull,
        dbull,
      ];

      final stats = computeAtcStats(1, [
        leg(longLog, variant: AtcVariant.doublesOnly),
        leg(shortLog, variant: AtcVariant.doublesOnly),
      ]);

      expect(stats.legsWon, 2);
      expect(stats.fewestDartsToWin, 22, reason: 'the leg with no misses');
    });

    test('a leg not won leaves fewestDartsToWin alone', () {
      final stats = computeAtcStats(1, [leg([s(1)])]);
      expect(stats.legsWon, 0);
      expect(stats.fewestDartsToWin, isNull);
    });
  });

  group('computePlayerStats, the mode dispatcher', () {
    test('keys both modes even when only one has data', () {
      final stats = computePlayerStats(1);

      expect(stats.keys, containsAll([GameMode.x01, GameMode.aroundTheClock]));
    });

    test('keys ATC legs under GameMode.aroundTheClock', () {
      final stats = computePlayerStats(
        1,
        atcLegs: [leg([s(1), miss, miss])],
      );

      final atc = stats[GameMode.aroundTheClock]! as AtcStats;
      expect(atc.dartsThrown, 3);
    });
  });
}
