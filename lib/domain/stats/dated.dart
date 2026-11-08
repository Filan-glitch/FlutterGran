/// [Dated], a replayed leg or match paired with when it was played, and
/// [StatsRange], the window of time a statistics view covers.
///
/// {@category Domain}
library;

/// A replayed leg (or match) and when it started.
///
/// The leg states themselves carry no time - they are folds over darts, and a
/// dart's value does not depend on when it was thrown - so the date rides
/// alongside rather than inside them.
class Dated<T> {
  const Dated(this.value, this.playedAt);

  final T value;

  /// When the leg or match was started, in local time.
  final DateTime playedAt;

  @override
  String toString() => 'Dated($value @ $playedAt)';
}

/// How far back a statistics view looks.
enum StatsRange {
  allTime(null),
  days30(30),
  days7(7);

  const StatsRange(this.days);

  /// Calendar days covered, today included, or null for no limit.
  final int? days;

  /// The earliest moment this range covers, counted back from [now] in whole
  /// calendar days so "7 days" means this day last week onwards rather than
  /// exactly 168 hours ago. Null for [allTime].
  DateTime? since(DateTime now) => switch (days) {
    null => null,
    final days => DateTime(now.year, now.month, now.day - (days - 1)),
  };
}

/// The [items] played at or after [since], or all of them when [since] is
/// null, still dated.
List<Dated<T>> datedSince<T>(Iterable<Dated<T>> items, DateTime? since) => [
  for (final item in items)
    if (since == null || !item.playedAt.isBefore(since)) item,
];

/// The values of [items] played at or after [since], or all of them when
/// [since] is null. See [datedSince].
List<T> playedSince<T>(Iterable<Dated<T>> items, DateTime? since) => [
  for (final item in datedSince(items, since)) item.value,
];

/// One calendar day's worth of a statistic.
class Daily<S> {
  const Daily(this.day, this.stats);

  /// Local midnight of the day.
  final DateTime day;

  final S stats;

  @override
  String toString() => 'Daily($day, $stats)';
}

/// [items] grouped by the local calendar day they were played on, oldest day
/// first, with [compute] applied to each day's values.
///
/// Each day goes through the same calculator as the all-time record, so a
/// trend point always agrees with what the record would say for that day.
List<Daily<S>> byDay<T, S>(
  Iterable<Dated<T>> items,
  S Function(List<T> values) compute,
) {
  final days = <DateTime, List<T>>{};
  for (final item in items) {
    final at = item.playedAt;
    (days[DateTime(at.year, at.month, at.day)] ??= []).add(item.value);
  }
  final ordered = days.keys.toList()..sort();
  return [for (final day in ordered) Daily(day, compute(days[day]!))];
}
