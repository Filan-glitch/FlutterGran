/// Putting widgets, screens and the whole app on screen in a widget test.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/splash_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/l10n/app_localizations.dart';
import 'package:fluttergran/main.dart';

/// Pumps [count] frames 20 ms apart, to let a route transition or a database
/// query land.
///
/// Not `pumpAndSettle`: a focused text field blinks its cursor forever, so
/// there is no settled state to wait for once a form is on screen. The
/// default of 25 covers a route transition, which is around 300 ms.
Future<void> pumpFrames(WidgetTester tester, {int count = 25}) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

/// Pumps [home] inside a localized [MaterialApp].
///
/// With a [container], the app reads its providers from it. [themed] applies
/// the app's theme; [typeScaled] applies the app's own text scaling for the
/// view size, as `FlutterGranApp` does, for tests of layout. Pumps once and
/// leaves waiting to the caller.
Future<void> pumpApp(
  WidgetTester tester,
  Widget home, {
  ProviderContainer? container,
  Locale? locale,
  bool themed = true,
  bool typeScaled = false,
}) {
  final Widget app = MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    theme: themed ? buildTheme() : null,
    builder: typeScaled ? _scaleType : null,
    home: home,
  );
  return tester.pumpWidget(
    container == null
        ? app
        : UncontrolledProviderScope(container: container, child: app),
  );
}

Widget _scaleType(BuildContext context, Widget? child) {
  final media = MediaQuery.of(context);
  return MediaQuery(
    data: media.copyWith(
      textScaler: TextScaler.linear(typeScaleFor(media.size)),
    ),
    child: child ?? const SizedBox.shrink(),
  );
}

/// Launches the whole app on [database] and clears the splash screen,
/// landing on the main menu.
///
/// Not `pumpAndSettle`: it stops as soon as one pump fails to schedule a new
/// frame, which the splash screen's bare [SplashScreen.minimumHold] `Timer`
/// never does on its own while it is idling. An explicit pump past that floor, with margin for the
/// route transition to the main menu, is what actually drives it forward.
Future<void> launchApp(WidgetTester tester, AppDatabase database) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const FlutterGranApp(),
    ),
  );
  await tester.pump(SplashScreen.minimumHold);
  await tester.pump(const Duration(milliseconds: 500));
}

/// Pops the route that [onScreen] sits on via its own [ModalRoute].
///
/// `Navigator.maybePop` needs no widget to tap, which matters once a screen
/// (like the main menu) has no back button of its own to find.
Future<void> popRoute(WidgetTester tester, Finder onScreen) async {
  final route = ModalRoute.of(tester.element(onScreen))!;
  unawaited(route.navigator!.maybePop());
  await pumpFrames(tester);
}

/// Tears the tree down inside the test rather than at teardown.
///
/// Cancelling a watched drift query schedules a zero-duration timer, and a
/// timer still pending when the test ends is reported as a failure. Unmounting
/// here gives that timer a frame to fire in.
Future<void> closeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 10));
  await tester.pump(const Duration(milliseconds: 10));
}
