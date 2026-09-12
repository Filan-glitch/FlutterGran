import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/screens/rules_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/l10n/app_localizations.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());

  tearDown(() => container.dispose());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(),
          home: const RulesScreen(),
        ),
      ),
    );
  }

  testWidgets('shows a heading and rule copy for every game mode', (
    tester,
  ) async {
    // The rules page is long enough to scroll on a phone-height surface, and
    // the default test surface is phone-sized - without this, paragraphs
    // past the fold never mount and `find.textContaining` on them fails, not
    // because the copy is wrong but because the widget was never built. A
    // tall surface renders the whole `ListView` at once, which is what this
    // test actually wants to assert on.
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;

    await pump(tester);

    expect(find.text('RULES'), findsOneWidget);

    expect(find.text('X01'), findsOneWidget);
    expect(find.textContaining('Race to exactly zero'), findsOneWidget);
    expect(
      find.textContaining('a double or a triple opens it'),
      findsOneWidget,
    );

    expect(find.text('AROUND THE CLOCK'), findsOneWidget);
    expect(find.textContaining('Clear 22 stops in order'), findsOneWidget);

    expect(find.text('BULLING'), findsOneWidget);
    expect(find.textContaining('hitting bulls wins'), findsOneWidget);

    expect(find.text('TRAINING'), findsOneWidget);
    expect(find.textContaining('Free practice'), findsOneWidget);
    expect(find.textContaining('Checkout practice'), findsOneWidget);
  });
}
