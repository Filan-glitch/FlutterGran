import 'package:flutter/material.dart';

/// Visual language for the app.
///
/// The reference is the pub chalk scoreboard, not a dashboard: a deep forest
/// ground, chalk-white numerals, a hairline dividing the players. Everything is
/// sized to be read from the oche - about two and a half metres away, holding
/// darts - which is why the numerals are enormous and everything else is
/// deliberately small and quiet.
///
/// Green runs through the whole app: the ground it sits on, and [brand], the
/// colour of every control you press. Amber is reserved for state and never
/// used for a control - whose throw it is, the checkout that is on, the segment
/// a suggestion points at - which is what keeps it rare enough to mean
/// something. The board's own colours keep their meaning throughout:
/// [trebleBed] is a treble, [doubleBed] a double.
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

  /// The treble bed. Brighter than the ground it now sits on, or a treble key
  /// would disappear into the background.
  static const Color trebleBed = Color(0xFF3D9C64);

  /// The double bed. Also a bust.
  static const Color doubleBed = Color(0xFFBF3B30);

  /// Controls: the buttons you press. Green, because the app is green - but
  /// lighter than the ground so a filled button reads as raised.
  static const Color brand = Color(0xFF2F8F5B);

  /// Live state, and only ever state: whose turn it is, the checkout that is
  /// on, the segment a suggestion is pointing at. Never a control, which is
  /// what keeps it rare enough to mean something.
  static const Color oche = Color(0xFFE5B23C);
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

  static const TextStyle body = TextStyle(
    fontFamily: 'UbuntuSans',
    fontSize: 14,
    height: 1.35,
    fontVariations: [
      FontVariation('wdth', Width.normal),
      FontVariation('wght', 400),
    ],
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'UbuntuSans',
    fontSize: 13,
    height: 1.2,
    fontVariations: [
      FontVariation('wdth', Width.normal),
      FontVariation('wght', 500),
    ],
  );

  /// Raw board data - frame codes - where digits must line up between rows.
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
  primary: Palette.oche,
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

ThemeData buildTheme() {
  final base = ThemeData(colorScheme: _scheme, useMaterial3: true);

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
        borderSide: const BorderSide(color: Palette.oche),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      titleTextStyle: Type.body,
      textColor: Palette.chalk,
      iconColor: Palette.chalkDim,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Palette.oche,
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
