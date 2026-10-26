import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/rules_topic.dart';
import 'package:fluttergran/app/screens/rules_detail_screen.dart';
import 'package:fluttergran/app/screens/rules_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/app/widgets/rules/rules_body.dart';
import 'package:fluttergran/l10n/app_localizations.dart';

/// The shapes the rules section is laid out for, as
/// `responsive_layout_test.dart` measures them.
const phonePortrait = Size(411, 923);
const phoneLandscape = Size(923, 411);
const tabletPortrait = Size(834, 1194);
const tabS6Lite = Size(1333, 800);
const laptop = Size(1280, 641);
const monitor = Size(1920, 1009);
const smallestWindow = Size(960, 600);

final windows = TargetPlatformVariant.only(TargetPlatform.windows);

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());

  tearDown(() => container.dispose());

  Future<void> pump(
    WidgetTester tester,
    Size size,
    Widget home, {
    Locale? locale,
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
          locale: locale,
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
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectEveryMode() {
    for (final name in ['X01', 'AROUND THE CLOCK', 'BULLING', 'TRAINING']) {
      expect(find.text(name), findsWidgets);
    }
    for (final tagline in [
      'Race down to zero and check out on a double',
      'Clear every number in order, then both bulls',
      'First to the target by hitting bulls wins',
      'Free practice or checkout drills, solo',
    ]) {
      expect(find.text(tagline), findsOneWidget);
    }
  }

  testWidgets('a phone lists every mode and opens one on a tap', (
    tester,
  ) async {
    await pump(tester, phonePortrait, const RulesScreen());

    expect(find.text('RULES'), findsOneWidget);
    expectEveryMode();
    // A picker, not a reference: no rules are on this screen yet.
    expect(find.byType(RulesBody), findsNothing);

    await tester.tap(find.byKey(const Key('rules-overview-x01')));
    await tester.pumpAndSettle();

    final detail = tester.widget<RulesDetailScreen>(
      find.byType(RulesDetailScreen),
    );
    expect(detail.topic, RulesTopic.x01);
    expect(find.text('X01 RULES'), findsOneWidget);
  });

  testWidgets('a tablet shows the modes as posters side by side', (
    tester,
  ) async {
    await pump(tester, tabS6Lite, const RulesScreen());

    expectEveryMode();
    final x01 = tester.getRect(find.byKey(const Key('rules-overview-x01')));
    final training = tester.getRect(
      find.byKey(const Key('rules-overview-training')),
    );
    expect(training.top, x01.top);
    expect(training.left, greaterThan(x01.right));

    await tester.tap(find.byKey(const Key('rules-overview-bulling')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<RulesDetailScreen>(find.byType(RulesDetailScreen)).topic,
      RulesTopic.bulling,
    );
  });

  testWidgets(
    'a desktop window shows the rules beside the modes and switches in place',
    (tester) async {
      await pump(tester, laptop, const RulesScreen());

      expectEveryMode();
      expect(
        tester.widget<RulesBody>(find.byType(RulesBody)).topic,
        RulesTopic.x01,
      );

      await tester.tap(find.byKey(const Key('rules-overview-aroundTheClock')));
      await tester.pumpAndSettle();

      expect(find.byType(RulesDetailScreen), findsNothing);
      expect(
        tester.widget<RulesBody>(find.byType(RulesBody)).topic,
        RulesTopic.aroundTheClock,
      );
      expect(find.text('THE ROUTE'), findsOneWidget);
    },
    variant: windows,
  );

  testWidgets(
    'a desktop window too small for the hero layout falls back to the list',
    (tester) async {
      await pump(tester, const Size(800, 560), const RulesScreen());

      expect(find.byType(RulesBody), findsNothing);
      await tester.tap(find.byKey(const Key('rules-overview-training')));
      await tester.pumpAndSettle();
      expect(find.byType(RulesDetailScreen), findsOneWidget);
    },
    variant: windows,
  );

  /// Scrolls every scrollable on screen to its end, so each section of a
  /// lazily built page gets laid out at least once.
  Future<void> scrollThrough(WidgetTester tester) async {
    for (final scrollable in find.byType(Scrollable).evaluate().toList()) {
      final finder = find.byWidget(scrollable.widget);
      for (var i = 0; i < 30; i++) {
        final position = tester.state<ScrollableState>(finder).position;
        if (position.pixels >= position.maxScrollExtent) break;
        await tester.drag(finder, const Offset(0, -400));
        await tester.pumpAndSettle();
      }
    }
  }

  group('nothing overflows', () {
    for (final (name, size) in [
      ('phone', phonePortrait),
      ('phone landscape', phoneLandscape),
      ('tablet portrait', tabletPortrait),
      ('tablet landscape', tabS6Lite),
    ]) {
      testWidgets('on a $name', (tester) async {
        await pump(tester, size, const RulesScreen());
        await scrollThrough(tester);
        for (final topic in RulesTopic.values) {
          await pump(tester, size, RulesDetailScreen(topic: topic));
          await scrollThrough(tester);
        }
      });
    }

    for (final (name, size) in [
      ('smallest window', smallestWindow),
      ('laptop', laptop),
      ('monitor', monitor),
    ]) {
      testWidgets('in a $name', (tester) async {
        await pump(tester, size, const RulesScreen());
        for (final topic in RulesTopic.values) {
          await tester.tap(find.byKey(Key('rules-overview-${topic.name}')));
          await tester.pumpAndSettle();
          await scrollThrough(tester);
        }
        for (final topic in RulesTopic.values) {
          await pump(tester, size, RulesDetailScreen(topic: topic));
          await scrollThrough(tester);
        }
      }, variant: windows);
    }

    // German runs longest: "LEUCHTENDE FELDER BEENDEN EIN LEG".
    for (final (name, size) in [
      ('phone', phonePortrait),
      ('tablet landscape', tabS6Lite),
    ]) {
      testWidgets('in German on a $name', (tester) async {
        const german = Locale('de');
        await pump(tester, size, const RulesScreen(), locale: german);
        await scrollThrough(tester);
        for (final topic in RulesTopic.values) {
          await pump(
            tester,
            size,
            RulesDetailScreen(topic: topic),
            locale: german,
          );
          await scrollThrough(tester);
        }
      });
    }
  });
}
