import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/rules_topic.dart';
import 'package:fluttergran/app/screens/rules_detail_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/app/widgets/rules/rule_board.dart';
import 'package:fluttergran/domain/atc/atc_stop.dart';
import 'package:fluttergran/domain/atc/atc_variant.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/x01_rules.dart';
import 'package:fluttergran/l10n/app_localizations.dart';

/// A phone, upright - the narrow layout, options in a row above the board.
const phone = Size(411, 923);

/// A tablet on its stand - options beside the board.
const tabletLandscape = Size(1333, 800);

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());

  tearDown(() => container.dispose());

  Future<void> pump(
    WidgetTester tester,
    RulesTopic topic, {
    Size size = phone,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(),
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(typeScaleFor(media.size)),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: RulesDetailScreen(topic: topic),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Scrolls the page until [finder] is built and on screen.
  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  /// The segments lit on the board inside explorer [id].
  Set<Segment> litIn(WidgetTester tester, String id) => tester
      .widget<RuleBoard>(
        find.descendant(
          of: find.byKey(Key('rule-explorer-$id')),
          matching: find.byType(RuleBoard),
        ),
      )
      .lit;

  Future<void> choose(WidgetTester tester, String id, String option) async {
    final tile = find.byKey(Key('rule-option-$id-$option'));
    await reveal(tester, tile);
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }

  testWidgets('X01 shows only its own rules', (tester) async {
    await pump(tester, RulesTopic.x01);

    expect(find.text('X01 RULES'), findsOneWidget);
    expect(find.textContaining('race to exactly zero'), findsOneWidget);
    expect(find.text('IN RULE'), findsOneWidget);

    await reveal(tester, find.text('MATCH FORMAT'));
    expect(find.text('A TURN BUSTS WHEN'), findsOneWidget);

    expect(find.text('THE ROUTE'), findsNothing);
    expect(find.textContaining('Only bulls score'), findsNothing);
  });

  for (final size in [phone, tabletLandscape]) {
    testWidgets('the board lights exactly what each X01 rule allows '
        '(${size.width.toInt()} wide)', (tester) async {
      await pump(tester, RulesTopic.x01, size: size);

      Set<Segment> opening(X01InRule rule) =>
          Segment.all.where(rule.opens).toSet();
      Set<Segment> finishing(X01OutRule rule) =>
          Segment.all.where(rule.checksOut).toSet();

      expect(litIn(tester, 'in'), opening(X01InRule.double));
      await choose(tester, 'in', 'master');
      expect(litIn(tester, 'in'), opening(X01InRule.master));

      await reveal(tester, find.byKey(const Key('rule-explorer-out')));
      expect(litIn(tester, 'out'), finishing(X01OutRule.double));
      await choose(tester, 'out', 'straight');
      expect(litIn(tester, 'out'), Segment.all.toSet());
      expect(
        find.text('Any dart that lands you on exactly zero wins the leg.'),
        findsOneWidget,
      );
    });
  }

  testWidgets('the match format counts legs to win from best of', (
    tester,
  ) async {
    await pump(tester, RulesTopic.x01);
    await reveal(tester, find.byKey(const Key('rules-format-first-to')));

    expect(find.text('First to 3 legs'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('rules-format-legs')),
        matching: find.text('7'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('First to 4 legs'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('rules-format-legs')),
        matching: find.text('1'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('First to 1 leg'), findsOneWidget);
  });

  testWidgets('Around the Clock shows its route and variant', (tester) async {
    await pump(tester, RulesTopic.aroundTheClock);

    expect(find.text('AROUND THE CLOCK RULES'), findsOneWidget);
    expect(find.text('THE ROUTE'), findsOneWidget);
    for (final stop in AtcStop.track) {
      expect(
        find.descendant(
          of: find.byKey(const Key('rules-atc-route')),
          matching: find.text(stop.label),
        ),
        findsOneWidget,
      );
    }

    final twenty = AtcStop.track[19];
    await reveal(tester, find.byKey(const Key('rule-explorer-atc')));
    expect(
      litIn(tester, 'atc'),
      Segment.all.where((s) => twenty.clears(s, AtcVariant.masters)).toSet(),
    );
    await choose(tester, 'atc', 'doublesOnly');
    expect(litIn(tester, 'atc'), {const Segment(20, Ring.doubleRing)});

    expect(find.text('IN RULE'), findsNothing);
    expect(find.textContaining('Only bulls score'), findsNothing);
  });

  testWidgets('Bulling scores the bullseye at the value picked', (
    tester,
  ) async {
    await pump(tester, RulesTopic.bulling);

    expect(find.text('BULLING RULES'), findsOneWidget);
    expect(find.textContaining('Only bulls score'), findsOneWidget);
    expect(litIn(tester, 'bullseye'), {Segment.outerBull, Segment.innerBull});

    final bullseyePoints = find.byKey(const Key('rules-points-DB'));
    await reveal(tester, bullseyePoints);
    expect(
      find.descendant(of: bullseyePoints, matching: find.text('3')),
      findsOneWidget,
    );

    await choose(tester, 'bullseye', 'two');
    await reveal(tester, bullseyePoints);
    expect(
      find.descendant(of: bullseyePoints, matching: find.text('2')),
      findsOneWidget,
    );

    expect(find.text('IN RULE'), findsNothing);
    expect(find.text('THE ROUTE'), findsNothing);
  });

  testWidgets('Training shows both drills', (tester) async {
    await pump(tester, RulesTopic.training);

    expect(find.text('TRAINING RULES'), findsOneWidget);
    await reveal(tester, find.byKey(const Key('rules-drill-checkoutPractice')));
    expect(find.byKey(const Key('rules-drill-freePractice')), findsOneWidget);

    expect(find.text('IN RULE'), findsNothing);
    expect(find.text('THE ROUTE'), findsNothing);
  });
}
