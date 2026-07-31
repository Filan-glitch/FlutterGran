import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/data/board/ble_board_source.dart';

/// A stand-in for Random that returns a fixed value, so the jitter is testable.
class FixedRandom implements Random {
  FixedRandom(this.value);

  final double value;

  @override
  double nextDouble() => value;

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  int nextInt(int max) => throw UnimplementedError();
}

void main() {
  group('reconnect backoff', () {
    test('starts fast, so a brief drop recovers quickly', () {
      final first = reconnectDelay(0, random: FixedRandom(0));
      expect(first, const Duration(milliseconds: 500));
    });

    test('doubles each attempt', () {
      final noJitter = FixedRandom(0);
      expect(reconnectDelay(1, random: noJitter).inMilliseconds, 1000);
      expect(reconnectDelay(2, random: noJitter).inMilliseconds, 2000);
      expect(reconnectDelay(3, random: noJitter).inMilliseconds, 4000);
    });

    test('caps at 30 seconds however long the board stays away', () {
      final noJitter = FixedRandom(0);
      for (final attempt in [8, 12, 40, 200]) {
        expect(
          reconnectDelay(attempt, random: noJitter).inSeconds,
          30,
          reason: 'attempt $attempt',
        );
      }
    });

    test('jitter only ever adds, up to 30 percent', () {
      const attempt = 4; // 8 seconds before jitter.
      expect(reconnectDelay(attempt, random: FixedRandom(0)).inSeconds, 8);
      expect(
        reconnectDelay(attempt, random: FixedRandom(1)).inMilliseconds,
        (8 * 1.3 * 1000).round(),
      );
    });

    test('never returns a negative or zero delay', () {
      for (var attempt = 0; attempt < 50; attempt++) {
        expect(reconnectDelay(attempt).inMilliseconds, greaterThan(0));
      }
    });
  });

  group('GATT identifiers', () {
    test('match the values every implementation agrees on', () {
      expect(
        GranBoardGatt.service.toString(),
        '442f1570-8a00-9a28-cbe1-e1d4212d53eb',
      );
      expect(
        GranBoardGatt.notify.toString(),
        '442f1571-8a00-9a28-cbe1-e1d4212d53eb',
      );
      expect(
        GranBoardGatt.write.toString(),
        '442f1572-8a00-9a28-cbe1-e1d4212d53eb',
      );
      expect(GranBoardGatt.namePrefix, 'GRAN');
    });
  });
}
