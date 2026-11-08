/// One-letter darts, so a test reads like a scoresheet: `t(20)`, `d(16)`.
///
/// Pure Dart, so `test/domain` and `test/data` can use it under `dart test`.
library;

import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

/// A single [n], the outer single bed.
ThrownDart s(int n) => ThrownDart(Segment(n, Ring.outerSingle));

/// A double [n].
ThrownDart d(int n) => ThrownDart(Segment(n, Ring.doubleRing));

/// A treble [n].
ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));

/// A dart that hit nothing that scores.
const miss = ThrownDart.miss();
