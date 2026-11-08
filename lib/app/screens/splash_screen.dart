/// [SplashScreen], the opening screen that holds the main menu back until the
/// database knows whether there is a leg to resume.
///
/// {@category App}
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n_extensions.dart';
import '../providers.dart';
import '../theme.dart';
import '../update/update_controller.dart';
import '../widgets/chalk_mark.dart';
import 'main_menu_screen.dart';

/// The brand moment the app opens on, and the thing that buys the database
/// time to answer before the main menu has to decide whether to show a
/// RESUME card.
///
/// [resumableLegProvider] is a `StreamProvider` backed by a database query -
/// its first value is not available on the very first frame. Without this
/// screen, the main menu would render once with no RESUME card and then pop
/// one in a frame later once the query resolves, which reads as a glitch
/// rather than as "nothing to resume". Waiting here instead means the menu
/// is only ever shown once it already knows the answer.
///
/// While it waits the tally mark chalks itself in, then flies up into the
/// menu's header as the menu fades in over it.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  /// The shortest the splash stays up: long enough to draw the mark and let
  /// it rest a beat, so the brand moment is not a flash on a fast device.
  static const minimumHold = Duration(milliseconds: 1000);

  /// How long the mark takes to draw itself in.
  static const drawDuration = Duration(milliseconds: 800);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _draw = AnimationController(
    vsync: this,
    duration: SplashScreen.drawDuration,
    // Reduced motion gets the finished mark straight away.
    value: Motion.reduced ? 1 : 0,
  );

  /// The wordmark arrives once most of the mark is down.
  late final CurvedAnimation _wordmark = CurvedAnimation(
    parent: _draw,
    curve: const Interval(0.65, 1, curve: Motion.enter),
  );

  @override
  void initState() {
    super.initState();
    if (!Motion.reduced) _draw.forward();
    _proceed();
  }

  @override
  void dispose() {
    _wordmark.dispose();
    _draw.dispose();
    super.dispose();
  }

  Future<void> _proceed() async {
    // A `StreamProvider.future` never resolves for a bare `ref.read` with
    // nothing else keeping the provider alive - nothing else watches
    // `resumableLegProvider` until `MainMenuScreen` builds, which is exactly
    // what this screen is waiting to do, so without a listener of its own the
    // wait below hangs forever. `listenManual` is Riverpod's mechanism for
    // "listen outside of build"; it is closed the moment the wait is over.
    final subscription = ref.listenManual(resumableLegProvider, (_, _) {});

    // At least [SplashScreen.minimumHold], and at least as long as the
    // resumable-leg query takes, whichever is longer. The query is read
    // rather than watched for its value: this screen navigates away as soon
    // as it has the answer, it never needs to react to a later change.
    await Future.wait([
      Future<void>.delayed(SplashScreen.minimumHold),
      // A leg failing to load is not a reason to strand the splash screen -
      // the main menu will simply open with no RESUME card, same as if
      // nothing were in progress.
      ref.read(resumableLegProvider.future).catchError((_) => null),
    ]);
    subscription.close();
    if (!mounted) return;

    final duration = Motion.scale(Motion.slow);
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        pageBuilder: (context, _, _) => const MainMenuScreen(),
        transitionsBuilder: (context, animation, _, child) => FadeTransition(
          opacity: animation.drive(CurveTween(curve: Motion.enter)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final version = ref.watch(appVersionProvider).value;

    return Scaffold(
      backgroundColor: Palette.ground,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: chalkMarkHeroTag,
                    child: AnimatedBuilder(
                      animation: _draw,
                      builder: (context, _) => ChalkMark(progress: _draw.value),
                    ),
                  ),
                  const SizedBox(height: Gap.lg),
                  FadeTransition(
                    opacity: _wordmark,
                    child: const ChalkWordmark(),
                  ),
                ],
              ),
            ),
            if (version != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: Gap.xl),
                  child: Text(
                    key: const Key('splash-version'),
                    context.l10n.updateCurrentVersion(version),
                    style: Type.eyebrow.copyWith(color: Palette.chalkDim),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
