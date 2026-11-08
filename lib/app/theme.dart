/// The design system: palette, motion, spacing and type tokens, the breakpoints
/// that choose between the phone, hero and desktop layouts, and [buildTheme].
///
/// {@category App}
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Visual language for the app.
///
/// The reference is the pub chalk scoreboard, not a dashboard: a deep forest
/// ground, chalk-white numerals, a hairline dividing the players. Everything is
/// sized to be read from the oche - about two and a half metres away, holding
/// darts - which is why the numerals are enormous and everything else is
/// deliberately small and quiet.
///
/// The app is green throughout, so the greens are told apart by how light they
/// are rather than by hue. Darkest to lightest: the [ground] it sits on,
/// [brand] for the controls you press, [trebleBed] for a treble, and [live] -
/// pale enough to read as lit from across a room - for state, and only state:
/// whose throw it is, the checkout that is on, the segment a suggestion points
/// at. Red is the one colour that is not green, because [doubleBed] means a
/// double, and a bust.
abstract final class Palette {
  /// Ground. Deep forest, dark enough that chalk numerals carry across a room.
  static const Color ground = Color(0xFF0E1611);

  /// Raised surfaces: cards, keys, the keypad.
  static const Color raised = Color(0xFF16211A);

  /// Pressed or recessed surfaces.
  static const Color sunk = Color(0xFF0A110C);

  /// Hairlines and dividers.
  static const Color edge = Color(0xFF24332B);

  /// Primary text. Warm off-white, like chalk dust, never pure white.
  static const Color chalk = Color(0xFFF0EDE4);

  /// Secondary text and the player who is not throwing. Warmed towards the
  /// ground so it recedes into it rather than sitting on top of it.
  static const Color chalkDim = Color(0xFF8A9A8E);

  /// The treble bed. Brighter than the ground, or a treble key would
  /// disappear into the background.
  static const Color trebleBed = Color(0xFF3D9C64);

  /// The double bed. Also a bust.
  static const Color doubleBed = Color(0xFFBF3B30);

  /// Controls: the buttons you press. Green, because the app is green - but
  /// lighter than the ground so a filled button reads as raised.
  static const Color brand = Color(0xFF2F8F5B);

  /// Live state, and only ever state: whose turn it is, the checkout that is
  /// on, the segment a suggestion is pointing at. Never a control, which is
  /// what keeps it rare enough to mean something.
  ///
  /// Pale rather than saturated: with every accent green, lightness is the only
  /// axis left to separate them on, and this has to out-read both [brand] and
  /// [trebleBed] at a glance.
  static const Color live = Color(0xFF7BE8AA);

  /// The board connection light's in-between states. Deliberately off-palette:
  /// a Bluetooth light reads by a convention older than this app - blue while
  /// it looks, amber while it waits to try again - and green for connected and
  /// red for trouble come from [trebleBed] and [doubleBed].
  static const Color bluetoothBlue = Color(0xFF3B82F6);
  static const Color bluetoothAmber = Color(0xFFE0A030);
}

/// Motion tokens. Every animation in the app pulls its duration and curve
/// from here, the same way every color comes from [Palette] and every gap
/// from [Gap] - a shared rhythm instead of a `Duration(milliseconds: 173)`
/// invented fresh at each call site.
abstract final class Motion {
  /// A key press, a color flip - felt rather than watched.
  static const Duration fast = Duration(milliseconds: 120);

  /// A card lighting up, a crossfade - the default for most state changes.
  static const Duration base = Duration(milliseconds: 200);

  /// A leg or match ending. Rare enough on screen to earn the extra time.
  static const Duration slow = Duration(milliseconds: 320);

  /// One cycle of a looping pulse - a checkout suggestion, a board still
  /// connecting. Slow enough to read as "still true" rather than a blink.
  static const Duration pulse = Duration(milliseconds: 900);

  /// Arriving: something new settling onto the screen.
  static const Curve enter = Curves.easeOutCubic;

  /// Leaving: quicker than [enter], so a dismissal never feels like it is
  /// keeping the player waiting.
  static const Curve exit = Curves.easeInCubic;

  /// The one or two moments that are actually worth a flourish - a leg won,
  /// a match won. A small overshoot, not a bounce.
  static const Curve pop = Curves.easeOutBack;

  /// Delay between one list item's entrance and the next's.
  static const Duration stagger = Duration(milliseconds: 40);

  /// Whether the platform is asking for reduced motion. Read straight off the
  /// platform dispatcher rather than `MediaQuery`, so it is available in
  /// `initState` - before a widget has anything to inherit a `MediaQuery`
  /// from - as well as in `build`.
  static bool get reduced => WidgetsBinding
      .instance
      .platformDispatcher
      .accessibilityFeatures
      .disableAnimations;

  /// [duration], or zero when [reduced] - the state change still happens,
  /// it just stops announcing itself.
  static Duration scale(Duration duration) =>
      reduced ? Duration.zero : duration;
}

/// Loops its child's opacity between [min] and fully opaque, for state that
/// stays lit rather than announces once: a checkout suggestion, a board
/// still connecting, a leg left in progress.
///
/// Decoration only - the state this sits on is always shown some other way
/// too (a border, a color, a label), so [Motion.reduced] can drop straight to
/// a plain, unanimated child without losing any information.
class Pulse extends StatefulWidget {
  const Pulse({super.key, required this.child, this.min = 0.55});

  final Widget child;
  final double min;

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.pulse,
  );

  /// Built once, not per build: a [CurvedAnimation] registers itself on its
  /// parent when it is made and only lets go when disposed, so one per
  /// rebuild left a listener behind on every dart.
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    if (!Motion.reduced) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced) return widget.child;
    return FadeTransition(
      opacity: Tween(begin: widget.min, end: 1.0).animate(_curve),
      child: widget.child,
    );
  }
}

/// Fades and rises into place a beat after the last one, so a list of things
/// arrives as a sequence rather than all at once - a small, one-shot cousin
/// of [Pulse].
///
/// [index] positions it in that sequence; the actual gap between entries is
/// [Motion.stagger].
class StaggeredEntry extends StatefulWidget {
  const StaggeredEntry({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<StaggeredEntry> createState() => _StaggeredEntryState();
}

class _StaggeredEntryState extends State<StaggeredEntry> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    final delay = Motion.scale(Motion.stagger * widget.index);
    if (delay == Duration.zero) {
      _shown = true;
    } else {
      Future.delayed(delay, () {
        if (mounted) setState(() => _shown = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = Motion.scale(Motion.base);
    return AnimatedSlide(
      offset: _shown ? Offset.zero : const Offset(0, 0.06),
      duration: duration,
      curve: Motion.enter,
      child: AnimatedOpacity(
        opacity: _shown ? 1 : 0,
        duration: duration,
        curve: Motion.enter,
        child: widget.child,
      ),
    );
  }
}

/// Plays a fade-and-scale entrance once, the moment it is first built - the
/// idiom used for a turn result, a leg won, a match won: something that
/// appears fully formed rather than growing into place gradually.
class EntrancePop extends StatelessWidget {
  const EntrancePop({super.key, required this.child, this.minScale = 0.94});

  final Widget child;

  /// Starting scale; it settles to 1.0.
  final double minScale;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Motion.scale(Motion.slow),
      curve: Motion.pop,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.scale(
          scale: minScale + (1 - minScale) * t,
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Counts between its old and new value whenever [value] changes, rather
/// than swapping the digits outright - a remaining score ticking down reads
/// as an event happening, not a jump cut to a new number.
///
/// `begin: value, end: value` on every build looks redundant, but is the
/// whole trick: [TweenAnimationBuilder] only re-animates when the tween's
/// *end* differs from the one it already has in flight, always starting
/// from wherever it currently is rather than `begin` - so the first frame
/// renders [value] outright (nothing to animate from yet) and every frame
/// after animates from the previous figure shown, not from `begin`.
class AnimatedFigure extends StatelessWidget {
  const AnimatedFigure({super.key, required this.value, required this.style});

  final int value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: value, end: value),
      duration: Motion.scale(Motion.base),
      curve: Motion.enter,
      builder: (context, animated, _) => Text('$animated', style: style),
    );
  }
}

/// Spacing scale. Every gap in the app is one of these.
abstract final class Gap {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Numerals must not jitter as they change, and a score that ticks from 501 to
/// 441 should not reflow the layout around it.
const List<FontFeature> _figures = [
  FontFeature.tabularFigures(),
  FontFeature.slashedZero(),
];

/// Width axis of the variable font.
///
/// Condensed for numerals, because that is the scoreboard idiom and because it
/// buys size: a condensed 64px score fits where a normal-width one would not.
abstract final class Width {
  static const double condensed = 75;
  static const double semiCondensed = 87;
  static const double normal = 100;
}

/// Width at which the game screen stops stacking and puts the keypad beside
/// the scoreboard: a phone on its side lands above it, a tablet always does.
const double wideLayout = 600;

/// Shortest side at which a device gets the hero treatment: per-player score
/// cards, the turn result as a full-screen takeover, checkout as its own
/// panel, and the top [typeScaleFor] tier.
///
/// Must stay below the 800dp shortest side of a Galaxy Tab S6 Lite, the
/// tablet the layout is built for (see `docs/DEVELOPMENT.md`).
const double heroLayout = 780;

/// Whether the app is running in a desktop window. A desktop is sized by its
/// window, not its screen - see [isHeroSize] and [typeScaleFor].
bool get isDesktop => switch (defaultTargetPlatform) {
  TargetPlatform.windows ||
  TargetPlatform.linux ||
  TargetPlatform.macOS => true,
  TargetPlatform.android ||
  TargetPlatform.iOS ||
  TargetPlatform.fuchsia => false,
};

/// The smallest desktop window that gets the hero treatment, since a laptop
/// window rarely reaches [heroLayout] on its shortest side.
///
/// Kept just under the 960x600 client-area floor in
/// `windows/runner/flutter_window.cpp`, so the smallest window the runner
/// allows always qualifies. Change one, check the other.
const Size desktopHeroLayout = Size(900, 580);

/// Whether a viewport of [size] earns the hero treatment. See [heroLayout].
///
/// [desktop] defaults to [isDesktop]; tests pass it to ask about a platform
/// they are not running on.
bool isHeroSize(Size size, {bool? desktop}) {
  if (size.shortestSide >= heroLayout) return true;
  return (desktop ?? isDesktop) &&
      size.width >= desktopHeroLayout.width &&
      size.height >= desktopHeroLayout.height;
}

/// Whether this device earns the hero treatment. See [isHeroSize].
///
/// Asks about the whole viewport, not the local width a `LayoutBuilder` would
/// give, so it moves together with [typeScaleFor]. Call sites use this rather
/// than comparing against [heroLayout] directly, or a desktop window falls
/// back to the phone layout.
bool isHeroDevice(BuildContext context) =>
    isHeroSize(MediaQuery.sizeOf(context));

/// How much larger type should be on a viewport of [size].
///
/// The sizes in [Type] are for a phone at arm's length; a tablet or desktop
/// is read from further away. Keyed to the shortest side, so the tier does
/// not change with orientation; the top tier lines up with [heroLayout].
/// Desktop has its own tiers: one at [desktopHeroLayout]'s height for a
/// laptop window, and one at 1000 for a full-height monitor window.
double typeScaleFor(Size size, {bool? desktop}) {
  final short = size.shortestSide;
  if (desktop ?? isDesktop) {
    if (short >= 1000) return 1.75;
    if (short >= heroLayout) return 1.5;
    if (short >= desktopHeroLayout.height) return 1.25;
    return 1;
  }
  if (short >= heroLayout) return 1.5;
  if (short >= 700) return 1.25;
  return 1;
}

/// How wide a form-shaped screen's content is allowed to get.
///
/// Setup and statistics screens are one column of controls sized for a
/// phone; past 640 it only gets sparser, so the rest becomes margin. On a
/// desktop [CenteredContent] multiplies it by [typeScaleFor], so larger type
/// still gets as many words per line.
const double formContentWidth = 640;

/// Wraps a form-shaped screen's body so it caps at [formContentWidth] and
/// centers it in what is left over. Below the cap it does nothing, so it is
/// invisible on a phone.
class CenteredContent extends StatelessWidget {
  const CenteredContent({
    super.key,
    required this.child,
    this.maxWidth = formContentWidth,
  });

  final Widget child;

  /// The cap, for a screen that is not form-shaped and has a use for more
  /// room on a big screen - a rules page laying a board beside its options.
  /// Scaled on a desktop the same way [formContentWidth] is.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    // A measured `Padding` rather than `Align`/`Center`/`Row`: `Scaffold`
    // dry-layouts `bottomNavigationBar` to reserve its height, and
    // `RenderPositionedBox` (what `Align`/`Center` build on) reports a bogus
    // zero-height result under that probe, which zeroes the body along with
    // it - a `Flex` sidesteps that but then cannot shrink itself below
    // [formContentWidth] on a screen narrower than it, and overflows. Reading
    // the real available width and turning it directly into inset padding
    // avoids both: no positioning render object in the way of the probe, and
    // a width that is never asked to exceed what is actually there.
    final cap = isDesktop
        ? maxWidth * typeScaleFor(MediaQuery.sizeOf(context))
        : maxWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final bounded = constraints.hasBoundedWidth;
        final width = bounded && available < cap ? available : cap;
        final inset = bounded ? (available - width) / 2 : 0.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: inset),
          child: SizedBox(width: width, child: child),
        );
      },
    );
  }
}

/// Type roles, named for their job rather than their size.
abstract final class Type {
  /// The remaining score. The largest thing on the screen by a wide margin.
  static const TextStyle score = TextStyle(
    fontFamily: 'UbuntuSans',
    fontSize: 62,
    height: 0.95,
    letterSpacing: -2.5,
    fontFeatures: _figures,
    fontVariations: [
      FontVariation('wdth', Width.condensed),
      FontVariation('wght', 800),
    ],
  );

  /// The number that just came off the board, alone on the whole tablet
  /// screen for a moment - the one place in the app with nothing else to
  /// share the room with, so it takes far more of it than [score] does.
  static const TextStyle scoreHero = TextStyle(
    fontFamily: 'UbuntuSans',
    fontSize: 150,
    height: 0.95,
    letterSpacing: -4,
    fontFeatures: _figures,
    fontVariations: [
      FontVariation('wdth', Width.condensed),
      FontVariation('wght', 800),
    ],
  );

  /// A score in a supporting position: a stat tile, a turn total.
  static const TextStyle scoreSmall = TextStyle(
    fontFamily: 'UbuntuSans',
    fontSize: 32,
    height: 1,
    letterSpacing: -1,
    fontFeatures: _figures,
    fontVariations: [
      FontVariation('wdth', Width.condensed),
      FontVariation('wght', 700),
    ],
  );

  /// Dart notation: T20, D16, MISS.
  static const TextStyle notation = TextStyle(
    fontFamily: 'UbuntuSans',
    fontSize: 19,
    height: 1,
    letterSpacing: -0.2,
    fontFeatures: _figures,
    fontVariations: [
      FontVariation('wdth', Width.semiCondensed),
      FontVariation('wght', 700),
    ],
  );

  /// A keypad key.
  static const TextStyle key = TextStyle(
    fontFamily: 'UbuntuSans',
    fontSize: 22,
    height: 1,
    fontFeatures: _figures,
    fontVariations: [
      FontVariation('wdth', Width.semiCondensed),
      FontVariation('wght', 700),
    ],
  );

  /// Section and screen headings.
  static const TextStyle title = TextStyle(
    fontFamily: 'UbuntuSans',
    fontSize: 17,
    height: 1.2,
    letterSpacing: -0.2,
    fontVariations: [
      FontVariation('wdth', Width.normal),
      FontVariation('wght', 600),
    ],
  );

  /// Small tracked capitals. Labels a thing; never a sentence.
  ///
  /// The wide tracking against the tight numerals is the whole type idea: the
  /// contrast between them is what makes the score read as the headline.
  static const TextStyle eyebrow = TextStyle(
    fontFamily: 'UbuntuSans',
    fontSize: 10.5,
    height: 1.2,
    letterSpacing: 1.8,
    fontVariations: [
      FontVariation('wdth', Width.semiCondensed),
      FontVariation('wght', 700),
    ],
  );

  /// Running text: sentences, list tiles, rules prose.
  static const TextStyle body = TextStyle(
    fontFamily: 'UbuntuSans',
    fontSize: 14,
    height: 1.35,
    fontVariations: [
      FontVariation('wdth', Width.normal),
      FontVariation('wght', 400),
    ],
  );

  /// Short labels on controls and figures; smaller and heavier than [body].
  static const TextStyle label = TextStyle(
    fontFamily: 'UbuntuSans',
    fontSize: 13,
    height: 1.2,
    fontVariations: [
      FontVariation('wdth', Width.normal),
      FontVariation('wght', 500),
    ],
  );

  /// Monospaced figures that must line up between rows, such as the
  /// end-of-game figures in `FigureRow`.
  static const TextStyle data = TextStyle(
    fontFamily: 'UbuntuSansMono',
    fontSize: 14,
    height: 1.2,
    fontFeatures: _figures,
    fontVariations: [FontVariation('wght', 500)],
  );
}

/// The colour scheme is written out rather than seeded.
///
/// `ColorScheme.fromSeed` would resolve the board's own red and green into a
/// single tonal palette and lose the distinction between them, which here is
/// information: green is a treble, red is a double.
const ColorScheme _scheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Palette.live,
  onPrimary: Palette.ground,
  primaryContainer: Palette.raised,
  onPrimaryContainer: Palette.chalk,
  secondary: Palette.trebleBed,
  onSecondary: Palette.chalk,
  tertiary: Palette.doubleBed,
  onTertiary: Palette.chalk,
  error: Palette.doubleBed,
  onError: Palette.chalk,
  surface: Palette.ground,
  onSurface: Palette.chalk,
  surfaceContainerHighest: Palette.raised,
  onSurfaceVariant: Palette.chalkDim,
  outline: Palette.edge,
  outlineVariant: Palette.edge,
  scrim: Color(0xFF000000),
);

/// The app's [ThemeData]: Material 3 on the hand-written colour scheme above,
/// with [Type] roles mapped onto the text theme and controls styled from
/// [Palette].
ThemeData buildTheme() {
  final base = ThemeData(
    colorScheme: _scheme,
    useMaterial3: true,
    // Touch-sized controls on every platform. Flutter's defaults shrink both
    // on desktop, for a mouse and a dense window of controls; this app is a
    // scoreboard read from across a room, often on a touchscreen laptop, and
    // a smaller button on the biggest screen it runs on would be backwards.
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
  );

  return base.copyWith(
    scaffoldBackgroundColor: Palette.ground,
    dividerTheme: const DividerThemeData(
      color: Palette.edge,
      thickness: 1,
      space: 1,
    ),
    textTheme: base.textTheme.copyWith(
      displayLarge: Type.score.copyWith(color: Palette.chalk),
      headlineMedium: Type.scoreSmall.copyWith(color: Palette.chalk),
      titleLarge: Type.title.copyWith(color: Palette.chalk),
      titleMedium: Type.title.copyWith(color: Palette.chalk),
      labelLarge: Type.label.copyWith(color: Palette.chalk),
      labelMedium: Type.eyebrow.copyWith(color: Palette.chalkDim),
      labelSmall: Type.eyebrow.copyWith(color: Palette.chalkDim),
      bodyMedium: Type.body.copyWith(color: Palette.chalk),
      bodySmall: Type.body.copyWith(color: Palette.chalkDim),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Palette.ground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'UbuntuSans',
        fontSize: 12,
        letterSpacing: 1.8,
        color: Palette.chalkDim,
        fontVariations: [
          FontVariation('wdth', Width.semiCondensed),
          FontVariation('wght', 700),
        ],
      ),
      iconTheme: IconThemeData(color: Palette.chalkDim, size: 22),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Palette.brand,
        foregroundColor: Palette.chalk,
        disabledBackgroundColor: Palette.raised,
        disabledForegroundColor: Palette.chalkDim,
        padding: const EdgeInsets.symmetric(vertical: Gap.lg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: Type.eyebrow,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Palette.chalkDim,
        side: const BorderSide(color: Palette.edge),
        padding: const EdgeInsets.symmetric(vertical: Gap.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: Type.eyebrow,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Palette.brand,
        textStyle: Type.eyebrow,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        textStyle: const WidgetStatePropertyAll(Type.eyebrow),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        side: const WidgetStatePropertyAll(BorderSide(color: Palette.edge)),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Palette.chalk
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Palette.ground
              : Palette.chalkDim,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Palette.raised,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Gap.md,
        vertical: Gap.md,
      ),
      labelStyle: Type.label.copyWith(color: Palette.chalkDim),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Palette.edge),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Palette.edge),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Palette.live),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      titleTextStyle: Type.body,
      textColor: Palette.chalk,
      iconColor: Palette.chalkDim,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Palette.live,
      linearTrackColor: Palette.raised,
      linearMinHeight: 3,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Palette.raised,
      side: const BorderSide(color: Palette.edge),
      labelStyle: Type.notation.copyWith(color: Palette.chalk),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Palette.raised,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: Type.title.copyWith(color: Palette.chalk),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Palette.raised,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
