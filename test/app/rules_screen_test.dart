import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/rules_topic.dart';
import 'package:fluttergran/app/screens/rules_detail_screen.dart';
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

  testWidgets('shows one short row per game mode, nothing more', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('RULES'), findsOneWidget);

    expect(
      find.text('Race down to zero and check out on a double'),
      findsOneWidget,
    );
    expect(
      find.text('Clear every number in order, then both bulls'),
      findsOneWidget,
    );
    expect(
      find.text('First to the target by hitting bulls wins'),
      findsOneWidget,
    );
    expect(
      find.text('Free practice or checkout drills, solo'),
      findsOneWidget,
    );

    // The overview is a picker, not a reference - none of the detailed
    // rule copy that used to live here belongs on this screen any more.
    expect(find.textContaining('Race to exactly zero'), findsNothing);
    expect(find.textContaining('Clear 22 stops in order'), findsNothing);
  });

  testWidgets('tapping a row opens that mode\'s detail, scoped to it alone', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('rules-overview-x01')));
    await tester.pumpAndSettle();

    final detail = tester.widget<RulesDetailScreen>(
      find.byType(RulesDetailScreen),
    );
    expect(detail.topic, RulesTopic.x01);
    expect(find.text('X01 RULES'), findsOneWidget);
  });
}
