import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/settings_screen.dart';
import 'package:fluttergran/app/theme.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    // No platform behind shared_preferences under the test binding, so both
    // toggles start on their in-memory default - which is on.
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: buildTheme(), home: const SettingsScreen()),
      ),
    );
  }

  /// The two switches, in the order they appear: sound first, then speech.
  (Switch, Switch) switches(WidgetTester tester) {
    final found = tester.widgetList<Switch>(find.byType(Switch)).toList();
    return (found[0], found[1]);
  }

  testWidgets('the sound switch reflects the provider and flips it on tap', (
    tester,
  ) async {
    await pump(tester);

    var (sound, _) = switches(tester);
    expect(sound.value, isTrue);
    expect(container.read(soundEnabledProvider), isTrue);

    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    expect(container.read(soundEnabledProvider), isFalse);
    (sound, _) = switches(tester);
    expect(sound.value, isFalse);
  });

  testWidgets('the speech switch reflects the provider and flips it on tap', (
    tester,
  ) async {
    await pump(tester);

    var (_, speech) = switches(tester);
    expect(speech.value, isTrue);
    expect(container.read(speechEnabledProvider), isTrue);

    await tester.tap(find.byType(Switch).last);
    await tester.pump();

    expect(container.read(speechEnabledProvider), isFalse);
    (_, speech) = switches(tester);
    expect(speech.value, isFalse);
  });

  testWidgets('the speech switch is disabled while sound is off', (
    tester,
  ) async {
    await pump(tester);

    final (_, enabledSpeech) = switches(tester);
    expect(enabledSpeech.onChanged, isNotNull);

    // Fire-and-forget, matching the switch's own onChanged: `set` writes its
    // state synchronously before it ever reaches shared_preferences, and
    // awaiting the write itself would mean waiting on a real plugin call that
    // never resolves under testWidgets' fake time - the same reason nothing
    // here awaits a tap either.
    unawaited(container.read(soundEnabledProvider.notifier).set(false));
    await tester.pump();

    final (_, disabledSpeech) = switches(tester);
    expect(disabledSpeech.onChanged, isNull);
  });

  testWidgets('the speech switch is enabled again once sound comes back on', (
    tester,
  ) async {
    unawaited(container.read(soundEnabledProvider.notifier).set(false));
    await pump(tester);

    var (_, speech) = switches(tester);
    expect(speech.onChanged, isNull);

    unawaited(container.read(soundEnabledProvider.notifier).set(true));
    await tester.pump();

    (_, speech) = switches(tester);
    expect(speech.onChanged, isNotNull);
  });
}
