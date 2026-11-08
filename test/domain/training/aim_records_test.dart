import 'package:fluttergran/domain/atc/atc_config.dart';
import 'package:fluttergran/domain/atc/atc_reducer.dart';
import 'package:fluttergran/domain/atc/atc_variant.dart';
import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_reducer.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/training/aim_records.dart';
import 'package:fluttergran/domain/training/aim_target.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:fluttergran/domain/x01/leg_reducer.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:fluttergran/domain/x01/x01_rules.dart';
import 'package:test/test.dart';

import '../../support/darts.dart';

void main() {
  group('AimRecord', () {
    test('smoothed rate starts at a half and moves with the data', () {
      expect(const AimRecord().smoothedRate, 0.5);
      expect(const AimRecord(attempts: 8, hits: 8).smoothedRate, 0.9);
      expect(const AimRecord(attempts: 8, hits: 0).smoothedRate, 0.1);
    });

    test('adding records sums them', () {
      final sum =
          const AimRecord(attempts: 2, hits: 1) +
          const AimRecord(attempts: 3, hits: 2);
      expect(sum.attempts, 5);
      expect(sum.hits, 3);
    });
  });

  group('x01 under double out', () {
    test('a dart on a one-dart finish was aimed at that double', () {
      // 40 left: miss (S20 leaves 20), then D10 finishes.
      final leg = foldLeg(GameConfig(startScore: 40, playerIds: const [1]), [
        s(20),
        d(10),
      ]);
      final records = inferAimRecords(1, x01Legs: [leg]);

      expect(records[const AimTarget.double(20)], const AimRecord(attempts: 1));
      expect(
        records[const AimTarget.double(10)],
        const AimRecord(attempts: 1, hits: 1),
      );
    });

    test('50 left means the bullseye', () {
      final leg = foldLeg(GameConfig(startScore: 50, playerIds: const [1]), [
        const ThrownDart(Segment.innerBull),
      ]);
      expect(
        inferAimRecords(1, x01Legs: [leg])[AimTarget.bullseye],
        const AimRecord(attempts: 1, hits: 1),
      );
    });

    test('darts off a finish, and other players, are ignored', () {
      final leg = foldLeg(
        GameConfig(startScore: 101, playerIds: const [1, 2]),
        // 101, 81, 61: never on a finish. Player 2 throws at 101.
        [s(20), s(20), s(1), s(20), s(20), s(20)],
      );
      expect(inferAimRecords(1, x01Legs: [leg]), isEmpty);
    });

    test('straight and master out legs are skipped as ambiguous', () {
      final leg = foldLeg(
        GameConfig(
          startScore: 40,
          playerIds: const [1],
          outRule: X01OutRule.straight,
        ),
        [s(20), d(10)],
      );
      expect(inferAimRecords(1, x01Legs: [leg]), isEmpty);
    });
  });

  group('Around the Clock', () {
    test('doubles only aims at the double of each stop', () {
      final leg = foldAroundTheClock(
        AtcConfig(playerIds: const [1], variant: AtcVariant.doublesOnly),
        [d(1), s(2), d(2)],
      );
      final records = inferAimRecords(1, atcLegs: [leg]);
      expect(
        records[const AimTarget.double(1)],
        const AimRecord(attempts: 1, hits: 1),
      );
      expect(
        records[const AimTarget.double(2)],
        const AimRecord(attempts: 2, hits: 1),
      );
    });

    test('any part aims at the number and any ring clears it', () {
      final leg = foldAroundTheClock(
        AtcConfig(playerIds: const [1], variant: AtcVariant.anyPart),
        // Only completed turns count, so finish the visit.
        [t(1), s(3), s(4)],
      );
      final records = inferAimRecords(1, atcLegs: [leg]);
      expect(
        records[const AimTarget.single(1)],
        const AimRecord(attempts: 1, hits: 1),
      );
      expect(records[const AimTarget.single(2)], const AimRecord(attempts: 2));
    });

    test('masters is skipped: double or treble, the aim is unknown', () {
      final leg = foldAroundTheClock(
        AtcConfig(playerIds: const [1], variant: AtcVariant.masters),
        [d(1)],
      );
      expect(inferAimRecords(1, atcLegs: [leg]), isEmpty);
    });
  });

  test('Bulling darts were aimed at the bull', () {
    final leg = foldBulling(
      BullingConfig(
        playerIds: const [1],
        bullseyeValue: BullseyeValue.two,
        target: 10,
      ),
      [const ThrownDart(Segment.outerBull), s(20), miss],
    );
    expect(
      inferAimRecords(1, bullingLegs: [leg])[AimTarget.bull],
      const AimRecord(attempts: 3, hits: 1),
    );
  });
}
