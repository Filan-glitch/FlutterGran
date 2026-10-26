import 'package:fluttergran/domain/game_mode.dart';
import 'package:fluttergran/domain/higher_lower/higher_lower_config.dart';
import 'package:fluttergran/domain/higher_lower/higher_lower_leg_state.dart';
import 'package:fluttergran/domain/higher_lower/higher_lower_reducer.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/stats/player_stats.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:test/test.dart';

ThrownDart s(int n) => ThrownDart(Segment(n, Ring.outerSingle));
ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));
const ThrownDart miss = ThrownDart.miss();

HigherLowerLegState leg(List<ThrownDart> darts, {int players = 2}) =>
    foldHigherLower(
      HigherLowerConfig(playerIds: [for (var i = 1; i <= players; i++) i]),
      darts,
    );

void main() {
  group('nothing thrown', () {
    test('reads as empty rather than zero', () {
      final stats = computeHigherLowerStats(1, [leg(const [])]);
      expect(stats.legsPlayed, 1);
      expect(stats.turnsPlayed, 0);
      expect(stats.survivalRate, isNull);
      expect(stats.winRate, 0);
      expect(stats.longestRun, 0);
    });

    test('a player who was not in the leg is skipped entirely', () {
      final stats = computeHigherLowerStats(9, [
        leg([miss]),
      ]);
      expect(stats.legsPlayed, 0);
      expect(stats.winRate, isNull);
    });
  });

  test('counts turns, calls and darts per player', () {
    final played = leg(players: 3, [
      t(20), t(20), t(20), // p1: 180, higher
      s(1), s(1), s(1), // p2: 3, lower
      miss, // p3 out
      t(1), t(1), t(1), // p1: 0, lower
      s(5), s(5), s(5), // p2: 15, between 0 and 180 - out
    ]);

    final p1 = computeHigherLowerStats(1, [played]);
    expect(p1.legsPlayed, 1);
    expect(p1.legsWon, 1);
    expect(p1.turnsPlayed, 2);
    expect(p1.turnsSurvived, 2);
    expect(p1.higherCalls, 1);
    expect(p1.lowerCalls, 1);
    expect(p1.dartsThrown, 6);
    expect(p1.longestRun, 2);
    expect(p1.survivalRate, 1);

    final p2 = computeHigherLowerStats(2, [played]);
    expect(p2.legsWon, 0);
    expect(p2.turnsPlayed, 2);
    expect(p2.turnsSurvived, 1);
    expect(p2.survivalRate, 0.5);

    final p3 = computeHigherLowerStats(3, [played]);
    expect(p3.dartsThrown, 1);
    expect(p3.turnsSurvived, 0);
  });

  test('longest run is the most turns survived in any one leg', () {
    final stats = computeHigherLowerStats(1, [
      leg([s(20), s(20), s(10), miss]), // p1 survives 1, p2 out
      leg([s(20), s(20), s(10), s(1), s(1), s(1), t(20), t(20), t(20), miss]),
    ]);
    expect(stats.legsPlayed, 2);
    expect(stats.legsWon, 2);
    expect(stats.longestRun, 2);
    expect(stats.winRate, 1);
  });

  group('computePlayerStats, the mode dispatcher', () {
    test('keys Higher/Lower even when there is no data', () {
      expect(computePlayerStats(1).keys, contains(GameMode.higherLower));
    });

    test('keys Higher/Lower legs under GameMode.higherLower', () {
      final stats = computePlayerStats(
        1,
        higherLowerLegs: [
          leg([s(20), s(20), s(10)]),
        ],
      );
      final higherLower = stats[GameMode.higherLower]! as HigherLowerStats;
      expect(higherLower.turnsSurvived, 1);
    });
  });
}
