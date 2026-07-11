import 'package:flutter/material.dart';

import '../constants/app_enums.dart';
import 'app_theme.dart';

/// ── EduNova per-class design system ─────────────────────────────────────
/// Every grade from Class 6 → Intermediate 2nd Year gets its OWN complete
/// visual identity: distinct palette, background, corner radius, button
/// language and typography weight. This is the "each class has its own
/// design" requirement made concrete.
///
/// Two things live here:
///   • A `ClassNTheme` per grade returning a full [ThemeData].
///   • [GradePalette] — a lightweight token bundle (accent colours +
///     background gradient) so individual screens can paint per-grade
///     highlights without reaching into [ThemeData] every time.
/// ------------------------------------------------------------------------

/// Class 6 (10–11): Sunrise — bright, chunky, playful, super rounded.
abstract final class Class6Theme {
  static const blue = Color(0xFF2F80ED);
  static const green = Color(0xFF27AE60);
  static const orange = Color(0xFFFF9F1C);
  static const bg = Color(0xFFF3FAFF);

  static ThemeData get theme => _buildLight(
        seed: blue,
        primary: blue,
        secondary: orange,
        tertiary: green,
        bg: bg,
        radius: 28,
        headingSize: 26,
        headingWeight: FontWeight.w900,
        buttonColor: orange,
        buttonHeight: 62,
        buttonRadius: 24,
        headingColor: blue,
      );
}

/// Class 7 (11–12): Reef — teal + coral, playful but a step more grown-up.
abstract final class Class7Theme {
  static const teal = Color(0xFF12A5A5);
  static const coral = Color(0xFFFF6B6B);
  static const amber = Color(0xFFFFB020);
  static const bg = Color(0xFFF1FBFB);

  static ThemeData get theme => _buildLight(
        seed: teal,
        primary: teal,
        secondary: coral,
        tertiary: amber,
        bg: bg,
        radius: 22,
        headingSize: 24,
        headingWeight: FontWeight.w800,
        buttonColor: teal,
        buttonHeight: 54,
        buttonRadius: 16,
        headingColor: const Color(0xFF0E3B3B),
      );
}

/// Class 8 (12–13): Studio — modern indigo + mint, soft cards, clean.
abstract final class Class8Theme {
  static const indigo = Color(0xFF5B6BF5);
  static const mint = Color(0xFF2FBFA0);
  static const bg = Color(0xFFF6F7FC);

  static ThemeData get theme => _buildLight(
        seed: indigo,
        primary: indigo,
        secondary: mint,
        tertiary: mint,
        bg: bg,
        radius: 20,
        headingSize: 23,
        headingWeight: FontWeight.w800,
        buttonColor: indigo,
        buttonHeight: 52,
        buttonRadius: 16,
        headingColor: const Color(0xFF20233A),
      );
}

/// Class 9 (13–14): Scholar — academic navy + gold. Light & dark variants.
abstract final class Class9Theme {
  static const navy = Color(0xFF1B2A4A);
  static const gold = Color(0xFFE0A93E);

  static ThemeData get light => _buildLight(
        seed: navy,
        primary: navy,
        secondary: gold,
        tertiary: gold,
        bg: const Color(0xFFF4F6FB),
        radius: 16,
        headingSize: 22,
        headingWeight: FontWeight.w800,
        buttonColor: navy,
        buttonHeight: 52,
        buttonRadius: 14,
        headingColor: navy,
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: navy, primary: gold, secondary: gold, brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF10162A),
        fontFamily: 'Roboto',
        cardTheme: CardThemeData(
            color: const Color(0xFF1B2340),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      );
}

/// Class 10 (14–16): Focus — minimal, exam-prep, ink + urgent crimson.
abstract final class Class10Theme {
  static const ink = Color(0xFF15181D);
  static const crimson = Color(0xFFE0403E);
  static const bg = Color(0xFFFAFAFA);

  static ThemeData get theme {
    final base = _buildLight(
      seed: ink,
      primary: ink,
      secondary: crimson,
      tertiary: crimson,
      bg: bg,
      radius: 14,
      headingSize: 22,
      headingWeight: FontWeight.w900,
      buttonColor: crimson,
      buttonHeight: 52,
      buttonRadius: 12,
      headingColor: ink,
    );
    // Hairline-bordered cards give Class 10 its stricter, exam-prep feel.
    return base.copyWith(
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE7E7E7)),
        ),
      ),
    );
  }
}

/// Intermediate 1st Year (16–17): Emerald — premium dark, calm & focused.
abstract final class Intermediate1Theme {
  static const bg = Color(0xFF0E1A17);
  static const card = Color(0xFF152622);
  static const emerald = Color(0xFF2ED3A0);
  static const gold = Color(0xFFE6C67A);

  static ThemeData get theme => _buildDark(
        primary: emerald,
        secondary: gold,
        bg: bg,
        card: card,
        line: const Color(0xFF244037),
        radius: 20,
      );
}

/// Intermediate 2nd Year (17–18): Royal — premium dark violet + cyan,
/// deliberately distinct from 1st year so the two years never look alike.
abstract final class Intermediate2Theme {
  static const bg = Color(0xFF0F1230);
  static const card = Color(0xFF1A1E44);
  static const violet = Color(0xFF7C5CFF);
  static const cyan = Color(0xFF38BDF8);

  static ThemeData get theme => _buildDark(
        primary: violet,
        secondary: cyan,
        bg: bg,
        card: card,
        line: const Color(0xFF2A2F5E),
        radius: 20,
      );
}

/// Kept as aliases so any older call-sites keep compiling.
abstract final class IntermediateTheme {
  static const charcoal = Intermediate1Theme.bg;
  static const gold = Intermediate1Theme.gold;
  static const slate = Intermediate1Theme.card;
  static ThemeData get theme => Intermediate1Theme.theme;
}

abstract final class CollegeTheme {
  static ThemeData get theme => AppTheme.dark;
}

// ── Shared theme builders ──────────────────────────────────────────────
ThemeData _buildLight({
  required Color seed,
  required Color primary,
  required Color secondary,
  required Color tertiary,
  required Color bg,
  required double radius,
  required double headingSize,
  required FontWeight headingWeight,
  required Color buttonColor,
  required double buttonHeight,
  required double buttonRadius,
  required Color headingColor,
}) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        brightness: Brightness.light),
    scaffoldBackgroundColor: bg,
    fontFamily: 'Roboto',
  );
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineMedium:
          TextStyle(fontWeight: headingWeight, fontSize: headingSize, color: headingColor),
      titleLarge: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: headingColor),
      bodyLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        minimumSize: Size(0, buttonHeight),
        textStyle: TextStyle(fontWeight: headingWeight, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
        elevation: 0,
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
  );
}

ThemeData _buildDark({
  required Color primary,
  required Color secondary,
  required Color bg,
  required Color card,
  required Color line,
  required double radius,
}) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: card,
        brightness: Brightness.dark),
    scaffoldBackgroundColor: bg,
    fontFamily: 'Roboto',
  );
  return base.copyWith(
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: line),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 54),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
    ),
  );
}

/// Maps a [Grade] to its full [ThemeData]. Every grade is distinct, and the
/// two Intermediate years no longer share a theme.
/// Unified Udemy-style dark identity: every grade now shares the single
/// black + white + purple theme, so the whole app looks consistent
/// regardless of the signed-in student's class.
ThemeData gradeThemeFor(Grade? grade) => AppTheme.dark;

/// Per-grade colour tokens + background gradient. Screens use this to paint
/// grade-specific accents (hero cards, badges, buttons) so each class looks
/// unmistakably its own even inside shared widgets.
class GradePalette {
  const GradePalette({
    required this.grade,
    required this.name,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.isDark,
  });

  final Grade grade;
  final String name;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceMuted;
  final bool isDark;

  LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, secondary],
      );

  LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [background, Color.lerp(background, primary, .10)!]
            : [background, Color.lerp(background, Colors.white, .6)!],
      );

  /// Every grade now shares one unified Udemy-style palette: a black canvas,
  /// white text and a single purple accent. The [grade] field still reflects
  /// the passed grade so call-sites that read it keep working.
  static GradePalette of(Grade? grade) => GradePalette(
        grade: grade ?? Grade.class6,
        name: 'Aditya Globals',
        primary: AppBrand.orange,
        secondary: AppBrand.navy,
        background: AppBrand.bg,
        surface: AppBrand.card,
        onSurface: AppBrand.ink,
        onSurfaceMuted: AppBrand.inkSoft,
        isDark: false,
      );
}
