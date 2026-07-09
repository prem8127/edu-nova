import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// EduNova design language — reworked into a dark, gradient-based system
/// inspired by the reference UI: deep navy→purple backgrounds, card
/// surfaces slightly lighter than the background with soft rounded corners
/// and hairline borders, and purple→blue stadium (pill) CTAs.
///
/// Screens read from [AppBrand] tokens, so re-theming happens here in one
/// place. [GradientButton] and [GlassCard] in lib/shared/widgets/ui.dart
/// build directly on these tokens.
class AppBrand {
  AppBrand._();

  // ---- Brand: "Aditya Globals" — navy + orange, light surfaces ----
  // Kept the historic token *names* (purple/blue/etc.) so every existing
  // call-site across the app keeps compiling, but every value now points at
  // the Aditya Globals palette (navy #0F2A4A / orange #F5810C) from the
  // reference platform prototype.
  static const purple = Color(0xFFF5810C); // primary brand / accent -> orange
  static const purpleDark = Color(0xFF0F2A4A); // navy
  static const purpleSoft = Color(0xFFFFF1E0); // light chip / avatar surface

  static const navy = Color(0xFF0F2A4A);
  static const navy2 = Color(0xFF16385E);
  static const orange = Color(0xFFF5810C);
  static const orange2 = Color(0xFFFFA84D);

  static const blue = Color(0xFF16385E); // secondary accent -> navy-2
  static const green = Color(0xFF16A34A); // progress / success accent
  static const greenSoft = Color(0xFFE7F7ED); // light success surface
  static const red = Color(0xFFE24545);

  // ---- Light surfaces & text ----
  static const bgTop = Color(0xFFF5F7FA);
  static const bgBottom = Color(0xFFF5F7FA);
  static const bg = Color(0xFFF5F7FA); // solid scaffold base
  static const card = Color(0xFFFFFFFF); // card surface
  static const cardAlt = Color(0xFFF5F7FA); // raised / nested surface

  static const ink = Color(0xFF1D2939); // primary text
  static const inkSoft = Color(0xFF64748B); // muted text
  static const line = Color(0xFFE6EAF0); // hairline borders

  static const amber = Color(0xFFF0B429); // highlight / warning

  static const subjectColors = [
    Color(0xFFF5810C), // orange
    Color(0xFF0F2A4A), // navy
    Color(0xFF16A34A), // green
    Color(0xFFF0B429), // amber
  ];

  /// Full-screen background — flat, light (kept as a gradient type so
  /// existing call-sites that expect a [Gradient] keep working).
  static const bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgBottom],
  );

  /// Primary CTA / hero fill — navy to navy-2, orange radial accent lives on
  /// top of it per-screen (see the "liveCard" style banners).
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy, navy2],
  );

  static const radiusCard = 14.0;
  static const radiusPill = 100.0;
}

/// Backwards-compatible palette used by the older `features/*` prototype
/// screens and `shared/widgets/ui.dart`. Kept so the whole project keeps
/// compiling, and mapped onto the Aditya Globals tokens for visual
/// consistency.
class AppColors {
  AppColors._();

  static const navy = AppBrand.navy;
  static const heading = AppBrand.ink;
  static const ink = AppBrand.ink;
  static const muted = AppBrand.inkSoft;
  static const line = AppBrand.line;
  static const orange = AppBrand.orange;
  static const orangeSoft = Color(0x33F5810C);
  static const green = AppBrand.green;
  static const blue = AppBrand.blue;
  static const white = Colors.white;
  static const chipBg = AppBrand.cardAlt;
  static const cream = AppBrand.card;
}

class AppTheme {
  static const seed = AppBrand.purple;

  /// The app's single base theme. Named [dark] to reflect the redesign;
  /// [light] is kept as an alias so any older references keep working.
  static ThemeData get light => dark;

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: GoogleFonts.inter().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
          primary: AppBrand.purple,
          secondary: AppBrand.blue,
          tertiary: AppBrand.green,
          surface: AppBrand.card,
          onSurface: AppBrand.ink,
        ),
        scaffoldBackgroundColor: AppBrand.bg,
        canvasColor: AppBrand.bg,
        // Big page titles use a classic serif (à la Udemy's onboarding
        // headings); everything else uses a clean sans for legibility.
        textTheme: TextTheme(
          displaySmall: GoogleFonts.sora(
              fontWeight: FontWeight.w700, color: AppBrand.ink, letterSpacing: -.2),
          headlineLarge: GoogleFonts.sora(
              fontWeight: FontWeight.w700, color: AppBrand.ink, letterSpacing: -.2),
          headlineMedium: GoogleFonts.sora(
              fontWeight: FontWeight.w700, color: AppBrand.ink, letterSpacing: -.2),
          headlineSmall: GoogleFonts.sora(
              fontWeight: FontWeight.w700, color: AppBrand.ink),
          titleLarge: const TextStyle(fontWeight: FontWeight.w800, color: AppBrand.ink),
          titleMedium: const TextStyle(fontWeight: FontWeight.w700, color: AppBrand.ink),
          bodyMedium: const TextStyle(color: AppBrand.inkSoft, height: 1.5),
          bodyLarge: const TextStyle(color: AppBrand.ink, height: 1.5),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppBrand.ink,
          titleTextStyle: TextStyle(
            color: AppBrand.ink,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
          iconTheme: IconThemeData(color: AppBrand.ink),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppBrand.card,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBrand.radiusCard),
            side: const BorderSide(color: AppBrand.line),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: AppBrand.purple,
          textColor: AppBrand.ink,
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.w700, color: AppBrand.ink, fontSize: 15),
          subtitleTextStyle: TextStyle(color: AppBrand.inkSoft, fontSize: 12.5),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppBrand.purple,
            foregroundColor: Colors.white,
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: .2),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBrand.radiusPill),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppBrand.ink,
            side: const BorderSide(color: AppBrand.line, width: 1.4),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBrand.radiusPill),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppBrand.purple,
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppBrand.cardAlt,
          hintStyle: const TextStyle(color: AppBrand.inkSoft),
          labelStyle: const TextStyle(color: AppBrand.inkSoft),
          floatingLabelStyle: const TextStyle(color: AppBrand.purple),
          prefixIconColor: AppBrand.inkSoft,
          suffixIconColor: AppBrand.inkSoft,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppBrand.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppBrand.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppBrand.purple, width: 1.6),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppBrand.cardAlt,
          selectedColor: AppBrand.purple,
          side: const BorderSide(color: AppBrand.line),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, color: AppBrand.ink),
          secondaryLabelStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: AppBrand.ink,
          unselectedLabelColor: AppBrand.inkSoft,
          indicatorColor: AppBrand.purple,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: TextStyle(fontWeight: FontWeight.w800),
          dividerColor: Colors.transparent,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppBrand.card,
          indicatorColor: AppBrand.purple.withValues(alpha: .22),
          elevation: 0,
          height: 66,
          labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
                fontSize: 11,
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w800
                    : FontWeight.w600,
                color: states.contains(WidgetState.selected)
                    ? AppBrand.purple
                    : AppBrand.inkSoft,
              )),
          iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
                color: states.contains(WidgetState.selected)
                    ? AppBrand.purple
                    : AppBrand.inkSoft,
              )),
        ),
        dialogTheme: const DialogThemeData(backgroundColor: AppBrand.card),
        bottomSheetTheme: const BottomSheetThemeData(backgroundColor: AppBrand.card),
        dividerTheme: const DividerThemeData(color: AppBrand.line, thickness: 1),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppBrand.green,
          linearTrackColor: AppBrand.line,
        ),
      );
}
