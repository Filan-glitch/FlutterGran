import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/rules_topic.dart';
import 'package:fluttergran/app/screens/rules_detail_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/l10n/app_localizations.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());

  tearDown(() => container.dispose());

  Future<void> pump(WidgetTester tester, RulesTopic topic) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(),
          home: RulesDetailScreen(topic: topic),
        ),
      ),
    );
  }

  testWidgets('X01 shows only its own rules', (tester) async {
    await pump(tester, RulesTopic.x01);

    expect(find.text('X01 RULES'), findsOneWidget);
    expect(find.textContaining('Race to exactly zero'), findsOneWidget);
    expect(
      find.textContaining('a double or a triple opens it'),
      findsOneWidget,
    );

    expect(find.textContaining('Clear 22 stops in order'), findsNothing);
    expect(find.textContaining('hitting bulls wins'), findsNothing);
    expect(find.textContaining('Free practice'), findsNothing);
  });

  testWidgets('Around the Clock shows only its own rules', (tester) async {
    await pump(tester, RulesTopic.aroundTheClock);

    expect(find.text('AROUND THE CLOCK RULES'), findsOneWidget);
    expect(find.textContaining('Clear 22 stops in order'), findsOneWidget);

    expect(find.textContaining('Race to exactly zero'), findsNothing);
    expect(find.textContaining('hitting bulls wins'), findsNothing);
  });

  testWidgets('Bulling shows only its own rules', (tester) async {
    await pump(tester, RulesTopic.bulling);

    expect(find.text('BULLING RULES'), findsOneWidget);
    expect(find.textContaining('hitting bulls wins'), findsOneWidget);

    expect(find.textContaining('Race to exactly zero'), findsNothing);
    expect(find.textContaining('Clear 22 stops in order'), findsNothing);
  });

  testWidgets('Training shows only its own rules', (tester) async {
    await pump(tester, RulesTopic.training);

    expect(find.text('TRAINING RULES'), findsOneWidget);
    expect(find.textContaining('Free practice'), findsOneWidget);
    expect(find.textContaining('Checkout practice'), findsOneWidget);

    expect(find.textContaining('Race to exactly zero'), findsNothing);
    expect(find.textContaining('Clear 22 stops in order'), findsNothing);
    expect(find.textContaining('hitting bulls wins'), findsNothing);
  });
}
