import 'dart:io';

import 'package:test/test.dart';

/// The domain layer is deliberately framework-free: it holds the scoring rules
/// and the checkout search, which are the parts worth testing hardest and the
/// parts that must stay runnable without a widget binding.
///
/// If this fails, move the Flutter-dependent code out of `lib/domain` rather
/// than relaxing the test.
void main() {
  test('lib/domain does not import Flutter', () {
    final domain = Directory('lib/domain');
    expect(
      domain.existsSync(),
      isTrue,
      reason: 'run this from the package root',
    );

    final offenders = <String>[];
    for (final entity in domain.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      if (source.contains('package:flutter/') ||
          source.contains('dart:ui') ||
          source.contains('package:drift/')) {
        offenders.add(entity.path);
      }
    }

    expect(offenders, isEmpty);
  });
}
