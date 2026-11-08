/// The screens the layout is checked on, and putting a test on one.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A Pixel 9a held upright, in logical pixels.
const phonePortrait = Size(411, 923);

/// The same phone, turned.
const phoneLandscape = Size(923, 411);

/// A 10-inch tablet, upright.
const tablet = Size(834, 1194);

/// The Samsung Galaxy Tab S6 Lite (SM-P610) connected during development,
/// landscape - measured with `adb shell wm size`/`wm density` (1200x2000
/// physical, 240dpi default density: 1200/1.5 x 2000/1.5 logical, then
/// swapped for landscape) rather than guessed. This is the shape the hero
/// treatment has to reliably trigger for, at the display-size setting most
/// people never touch.
const tabS6Lite = Size(1333, 800);

/// A 1080p laptop at 150% scaling, maximised, as Flutter measures it on
/// Windows: the screen in logical pixels less the taskbar and the title bar.
const laptop = Size(1280, 641);

/// A 1080p monitor at 100%, maximised, measured the same way.
const monitor = Size(1920, 1009);

/// The smallest window the Windows runner allows.
const smallestWindow = Size(960, 600);

/// Runs a test as the Windows build would see it.
final windows = TargetPlatformVariant.only(TargetPlatform.windows);

/// Sizes the test's view to exactly [size] logical pixels, put back when the
/// test ends.
void setViewSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
