import 'package:flutter/material.dart';

/// Design tokens for the Class 6 "Adventure Learning World" dashboard.
///
/// Palette is deliberately restricted to four hero hues — Electric Blue,
/// Lime Green, Orange and Yellow — so every screen in the adventure reads
/// as one consistent world. Depth comes from tints/shades of those four,
/// never from introducing new hues.
abstract final class AdventureColors {
  // Electric Blue family — Math realm, primary UI chrome.
  static const blue = Color(0xFF2E6BFF);
  static const blueDeep = Color(0xFF163C9E);
  static const blueLight = Color(0xFF7FA6FF);

  // Lime Green family — Science realm, growth & success states.
  static const lime = Color(0xFF63D642);
  static const limeDeep = Color(0xFF299B33);
  static const limeLight = Color(0xFFB4F58C);

  // Orange family — Social realm, energy, streaks, quests.
  static const orange = Color(0xFFFF8A3D);
  static const orangeDeep = Color(0xFFE85D1F);
  static const orangeLight = Color(0xFFFFC299);

  // Yellow family — English realm, XP & treasure gold.
  static const yellow = Color(0xFFFFD23F);
  static const yellowDeep = Color(0xFFF2A400);
  static const yellowLight = Color(0xFFFFEBA8);

  // Neutrals that hold the world together.
  static const ink = Color(0xFF122250);
  static const inkSoft = Color(0xFF4A5686);
  static const skyTop = Color(0xFFE7F3FF);
  static const skyMid = Color(0xFFEFFCF3);
  static const skyBottom = Color(0xFFFFF8E9);
  static const cloud = Colors.white;
}

/// Reusable gradients, all mixed from the four hero hues.
abstract final class AdventureGradients {
  static const sky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AdventureColors.skyTop, AdventureColors.skyMid, AdventureColors.skyBottom],
  );

  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AdventureColors.blue, AdventureColors.blueDeep],
  );

  static const energy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AdventureColors.orange, AdventureColors.yellow],
  );

  static const growth = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AdventureColors.lime, AdventureColors.limeDeep],
  );

  static const gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AdventureColors.yellow, AdventureColors.orangeDeep],
  );

  static const oceanForest = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AdventureColors.blue, AdventureColors.lime],
  );
}

/// One learning "realm" (subject) with its own hue and mascot icon.
class Realm {
  const Realm({required this.name, required this.emoji, required this.icon, required this.color, required this.deep, required this.progress});
  final String name;
  final String emoji;
  final IconData icon;
  final Color color;
  final Color deep;
  final double progress; // 0..1

  static const all = [
    Realm(name: 'Math', emoji: '🧮', icon: Icons.calculate_rounded, color: AdventureColors.blue, deep: AdventureColors.blueDeep, progress: .68),
    Realm(name: 'Science', emoji: '🔬', icon: Icons.science_rounded, color: AdventureColors.lime, deep: AdventureColors.limeDeep, progress: .42),
    Realm(name: 'English', emoji: '📖', icon: Icons.menu_book_rounded, color: AdventureColors.yellow, deep: AdventureColors.yellowDeep, progress: .81),
    Realm(name: 'Social', emoji: '🌍', icon: Icons.public_rounded, color: AdventureColors.orange, deep: AdventureColors.orangeDeep, progress: .35),
    Realm(name: 'Computer', emoji: '🖥️', icon: Icons.memory_rounded, color: AdventureColors.blueDeep, deep: AdventureColors.ink, progress: .55),
  ];
}

abstract final class AdventureText {
  static const eyebrow = TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, letterSpacing: 1.4, color: AdventureColors.inkSoft);
  static const h1 = TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AdventureColors.ink, letterSpacing: -.4);
  static const h2 = TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AdventureColors.ink, letterSpacing: -.2);
  static const body = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AdventureColors.inkSoft, height: 1.35);
  static const stat = TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white);
}
