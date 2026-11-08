/// Waiting for work a test has kicked off but not awaited.
///
/// Pure Dart, so `test/data` can use it under `dart test`.
library;

/// Lets queued microtasks and zero-delay timers run - a board event reaching
/// its controller, say - before the test looks at the result.
Future<void> settle() => Future<void>.delayed(Duration.zero);
