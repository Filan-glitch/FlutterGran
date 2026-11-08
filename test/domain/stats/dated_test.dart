import 'package:fluttergran/domain/stats/dated.dart';
import 'package:test/test.dart';

void main() {
  group('StatsRange.since', () {
    final now = DateTime(2026, 11, 8, 15, 30);

    test('all time has no start', () {
      expect(StatsRange.allTime.since(now), isNull);
    });

    test('counts whole calendar days back, today included', () {
      expect(StatsRange.days7.since(now), DateTime(2026, 11, 2));
      expect(StatsRange.days30.since(now), DateTime(2026, 10, 10));
    });

    test('crosses a month and a year boundary', () {
      expect(
        StatsRange.days7.since(DateTime(2027, 1, 3)),
        DateTime(2026, 12, 28),
      );
    });
  });

  group('playedSince', () {
    final items = [
      Dated('old', DateTime(2026, 10, 1)),
      Dated('edge', DateTime(2026, 11, 2)),
      Dated('new', DateTime(2026, 11, 8, 9)),
    ];

    test('null keeps everything', () {
      expect(playedSince(items, null), ['old', 'edge', 'new']);
    });

    test('keeps items at or after the start', () {
      expect(playedSince(items, DateTime(2026, 11, 2)), ['edge', 'new']);
    });
  });

  group('byDay', () {
    test('groups by local calendar day, oldest first', () {
      final days = byDay([
        Dated(3, DateTime(2026, 11, 8, 20)),
        Dated(1, DateTime(2026, 11, 7, 23, 59)),
        Dated(2, DateTime(2026, 11, 8, 0, 1)),
      ], (values) => values.fold(0, (a, b) => a + b));

      expect(
        [for (final d in days) d.day],
        [DateTime(2026, 11, 7), DateTime(2026, 11, 8)],
      );
      expect([for (final d in days) d.stats], [1, 5]);
    });

    test('nothing in, nothing out', () {
      expect(byDay(const <Dated<int>>[], (v) => v.length), isEmpty);
    });
  });
}
