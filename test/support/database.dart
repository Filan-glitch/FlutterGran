/// A throwaway database for tests.
library;

import 'package:drift/native.dart';
import 'package:fluttergran/data/db/database.dart';

/// A fresh, empty [AppDatabase] held in memory.
///
/// Close it in `tearDown`, after disposing any container that reads it.
AppDatabase memoryDatabase() => AppDatabase(NativeDatabase.memory());
