import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme.dart';
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
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _proceed();
  }

  Future<void> _proceed() async {
    // A `StreamProvider.future` never resolves for a bare `ref.read` with
    // nothing else keeping the provider alive - nothing else watches
    // `resumableLegProvider` until `MainMenuScreen` builds, which is exactly
    // what this screen is waiting to do, so without a listener of its own the
    // wait below hangs forever. `listenManual` is Riverpod's mechanism for
    // "listen outside of build"; it is closed the moment the wait is over.
    final subscription = ref.listenManual(resumableLegProvider, (_, _) {});

    // At least 700ms so the brand moment is not a flash on a fast device, and
    // at least as long as the resumable-leg query takes, whichever is longer.
    // The query is read rather than watched for its value: this screen
    // navigates away as soon as it has the answer, it never needs to react to
    // a later change.
    await Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 700)),
      // A leg failing to load is not a reason to strand the splash screen -
      // the main menu will simply open with no RESUME card, same as if
      // nothing were in progress.
      ref.read(resumableLegProvider.future).catchError((_) => null),
    ]);
    subscription.close();
    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (context) => const MainMenuScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Palette.ground,
      body: Center(child: _ChalkMark()),
    );
  }
}

/// The tally mark from the launcher icon (`tool/make_icon.py`), redrawn in
/// widgets rather than shared as an asset - the icon is a rasterised PNG with
/// hand-drawn chalk texture, and none of that is worth reproducing for a
/// widget seen for well under a second. The idea is what has to carry: four
/// strokes struck through by a fifth.
class _ChalkMark extends StatelessWidget {
  const _ChalkMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 120,
          height: 96,
          child: CustomPaint(painter: _TallyPainter()),
        ),
        const SizedBox(height: Gap.lg),
        Text(
          'C H A L K',
          style: Type.eyebrow.copyWith(color: Palette.chalkDim, fontSize: 13),
        ),
      ],
    );
  }
}

class _TallyPainter extends CustomPainter {
  const _TallyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Palette.chalk
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Four uprights, evenly spaced across the width.
    final top = size.height * 0.08;
    final bottom = size.height * 0.92;
    for (var i = 0; i < 4; i++) {
      final x = size.width * (0.14 + i * 0.24);
      canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
    }

    // The fifth stroke, on the diagonal through the middle of the other four.
    canvas.drawLine(
      Offset(size.width * 0.04, size.height * 0.72),
      Offset(size.width * 0.96, size.height * 0.18),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _TallyPainter oldDelegate) => false;
}
