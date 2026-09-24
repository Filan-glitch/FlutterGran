/// Where the last board connected to is remembered between launches.
///
/// Holds a platform device id. Remembering it lets the next launch connect
/// straight to that board without a scan - faster, and clear of Android's scan
/// throttle. An interface so the data layer need not know how it is stored;
/// the app backs it with shared_preferences.
abstract interface class KnownBoardStore {
  Future<String?> read();

  /// Stores [deviceId], or forgets the board when it is null.
  Future<void> write(String? deviceId);
}

/// Remembers nothing. For tests, and for a source built without a store.
class NoKnownBoardStore implements KnownBoardStore {
  const NoKnownBoardStore();

  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String? deviceId) async {}
}

/// Remembers in memory only, for tests that need to see what was stored.
class MemoryKnownBoardStore implements KnownBoardStore {
  MemoryKnownBoardStore([this.deviceId]);

  String? deviceId;

  @override
  Future<String?> read() async => deviceId;

  @override
  Future<void> write(String? deviceId) async => this.deviceId = deviceId;
}
