import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/screens/new_game_screen.dart';
import 'app/theme.dart';

void main() {
  runApp(const ProviderScope(child: FlutterGranApp()));
}

class FlutterGranApp extends StatelessWidget {
  const FlutterGranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chalk',
      // One theme, always dark. A scoreboard read across a room in a garage
      // has no business being white, and a light variant would mean a second
      // set of decisions for a situation that does not arise.
      theme: buildTheme(),
      // The child is the navigator MaterialApp builds around `home`, and is
      // null only for an app that has no routes at all. This one always has
      // one, so the empty case is a placeholder for a state that cannot arise
      // rather than a screen anybody sees.
      builder: (context, child) =>
          _Scaled(child: child ?? const SizedBox.shrink()),
      home: const NewGameScreen(),
    );
  }
}

/// Grows the type with the device, on top of whatever text size the platform
/// itself is set to, and locks the device to landscape once it earns the hero
/// layout.
///
/// Applied once around the whole app rather than per screen: every screen wants
/// the same thing, and a number that changed size between the scoreboard and
/// the statistics that explain it would read as two different numbers. The
/// same reasoning covers orientation - a scoreboard is mounted once, not
/// screen by screen, and a tablet that rotated between them would be a
/// different scoreboard each time.
///
/// The platform's own preference is folded in by measuring what it does to a
/// nominal size and multiplying. That flattens a non-linear curve into a linear
/// one, which is a fair trade for keeping someone's accessibility setting
/// working rather than overwriting it with a constant.
class _Scaled extends StatefulWidget {
  const _Scaled({required this.child});

  final Widget child;

  @override
  State<_Scaled> createState() => _ScaledState();
}

class _ScaledState extends State<_Scaled> {
  /// The orientation lock last asked for, so a rebuild that has not changed
  /// device class does not spam the platform channel every frame.
  bool? _lockedToLandscape;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final platform = media.textScaler.scale(100) / 100;
    final scale = platform * typeScaleFor(media.size);

    // A phone rotates freely; a tablet on a stand does not, because it is
    // mounted for a room to read, not held. Keyed to the same shortestSide
    // threshold as the hero layout - the device that gets the big cards and
    // the full-screen result is the device that stops moving.
    final wantsLandscape = media.size.shortestSide >= heroLayout;
    if (_lockedToLandscape != wantsLandscape) {
      _lockedToLandscape = wantsLandscape;
      // Deferred past this frame: SystemChrome is a platform call, and has no
      // business happening mid-build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SystemChrome.setPreferredOrientations(
          wantsLandscape
              ? const [
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]
              : const [],
        );
      });
    }

    return MediaQuery(
      data: media.copyWith(textScaler: TextScaler.linear(scale)),
      child: widget.child,
    );
  }
}
