/// [AimRecord] and [inferAimRecords]: how often a player hits each target,
/// rebuilt from saved legs wherever the rules make the aim unambiguous.
///
/// Nothing stores what a dart was aimed at, so this replays each mode's rules
/// to recover it, the same way the statistics calculators do.
///
/// {@category Game modes}
library;

import '../atc/atc_leg_state.dart';
import '../atc/atc_stop.dart';
import '../atc/atc_variant.dart';
import '../bulling/bulling_leg_state.dart';
import '../segment.dart';
import '../stats/player_stats.dart' show isOneDartFinishFor;
import '../x01/leg_state.dart';
import '../x01/x01_rules.dart';
import 'aim_target.dart';

/// Darts thrown at one target and how many of them hit it.
class AimRecord {
  const AimRecord({this.attempts = 0, this.hits = 0})
    : assert(hits >= 0 && hits <= attempts, 'hits must be 0 to attempts');

  final int attempts;

  final int hits;

  /// Hit rate with one hit and one miss assumed up front (Laplace
  /// smoothing), so a target with little data sits near a half rather than
  /// at 0% or 100% after a single dart.
  double get smoothedRate => (hits + 1) / (attempts + 2);

  /// This record with one more dart, a hit or not.
  AimRecord record({required bool hit}) =>
      AimRecord(attempts: attempts + 1, hits: hits + (hit ? 1 : 0));

  AimRecord operator +(AimRecord other) =>
      AimRecord(attempts: attempts + other.attempts, hits: hits + other.hits);

  @override
  bool operator ==(Object other) =>
      other is AimRecord && other.attempts == attempts && other.hits == hits;

  @override
  int get hashCode => Object.hash(attempts, hits);

  @override
  String toString() => 'AimRecord($hits/$attempts)';
}

/// Every target [playerId] has a known aim at in these legs, with their
/// record on it.
///
/// Only darts whose aim follows from the rules count:
/// - x01 under double out, a dart thrown on a one-dart finish was aimed at
///   that double (the bullseye on 50). Straight and master out are skipped:
///   20 left could be a single, a double or nothing in particular.
/// - Around the Clock, the standing stop: its double under doubles-only, the
///   number under any-part (where any ring of it clears), the bull stops as
///   themselves. Masters is skipped, since a double and a treble both count.
/// - Bulling, every dart was aimed at the bull.
Map<AimTarget, AimRecord> inferAimRecords(
  int playerId, {
  Iterable<LegState> x01Legs = const [],
  Iterable<AtcLegState> atcLegs = const [],
  Iterable<BullingLegState> bullingLegs = const [],
}) {
  final records = <AimTarget, AimRecord>{};
  void add(AimTarget target, {required bool hit}) {
    records[target] = (records[target] ?? const AimRecord()).record(hit: hit);
  }

  for (final leg in x01Legs) {
    if (leg.config.outRule != X01OutRule.double) continue;
    var opened = leg.config.inRule == X01InRule.straight;
    for (final turn in leg.turns) {
      if (turn.playerId != playerId) continue;
      var standing = turn.scoreBefore;
      for (final dart in turn.darts) {
        final effective = opened || dart.opensUnder(leg.config.inRule)
            ? dart.value
            : 0;
        opened |= effective > 0;
        // A player who has not opened yet is aiming to get in, not out.
        if (opened && isOneDartFinishFor(standing, X01OutRule.double)) {
          final target = standing == 50
              ? AimTarget.bullseye
              : AimTarget.double(standing ~/ 2);
          add(target, hit: target.isHitBy(dart.segment));
        }
        // A bust resets the turn, but every later dart in a bust turn never
        // happened, so walking on with the raw value is safe.
        standing -= effective;
      }
    }
  }

  for (final leg in atcLegs) {
    final variant = leg.config.variant;
    if (variant == AtcVariant.masters) continue;
    for (final turn in leg.turns) {
      if (turn.playerId != playerId) continue;
      var standing = turn.stopBefore;
      for (final dart in turn.darts) {
        if (standing >= AtcStop.track.length) break;
        final stop = AtcStop.track[standing];
        final segment = dart.segment;
        final cleared = segment != null && stop.clears(segment, variant);
        add(_atcTarget(stop, variant), hit: cleared);
        if (cleared) standing++;
      }
    }
  }

  for (final leg in bullingLegs) {
    for (final turn in leg.turns) {
      if (turn.playerId != playerId) continue;
      for (final dart in turn.darts) {
        add(AimTarget.bull, hit: AimTarget.bull.isHitBy(dart.segment));
      }
    }
  }

  return records;
}

AimTarget _atcTarget(AtcStop stop, AtcVariant variant) {
  final number = stop.number;
  if (number == null) {
    return stop.ring == Ring.innerBull ? AimTarget.bullseye : AimTarget.bull;
  }
  return variant == AtcVariant.doublesOnly
      ? AimTarget.double(number)
      : AimTarget.single(number);
}
