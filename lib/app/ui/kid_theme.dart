import 'package:flutter/material.dart';

class KidPalette {
  static const skyTop = Color(0xFFF7F5EF);
  static const skyBottom = Color(0xFFE3EDF8);
  static const cream = Color(0xFFFFFCF8);
  static const creamWarm = Color(0xFFF4EBDD);
  static const navy = Color(0xFF202937);
  static const body = Color(0xFF5E6B79);
  static const coral = Color(0xFFFF8E76);
  static const coralDark = Color(0xFFE06A56);
  static const blue = Color(0xFF2F6EDC);
  static const blueDark = Color(0xFF1B4FA7);
  static const blueSoft = Color(0xFFDCEAFF);
  static const mint = Color(0xFFDCEEDF);
  static const mintDark = Color(0xFF4F7E63);
  static const yellow = Color(0xFFF4D489);
  static const yellowDark = Color(0xFFC09135);
  static const lilac = Color(0xFFE4E0FF);
  static const stroke = Color(0xFFE4E8EF);
  static const white = Colors.white;
}

class KidShadows {
  static List<BoxShadow> get panel => const [
    BoxShadow(color: Color(0x17182230), blurRadius: 28, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x0D182230), blurRadius: 10, offset: Offset(0, 4)),
  ];

  static List<BoxShadow> get button => const [
    BoxShadow(color: Color(0x241B4FA7), blurRadius: 24, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x14182230), blurRadius: 10, offset: Offset(0, 4)),
  ];
}

ThemeData buildKidTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: KidPalette.blue,
      brightness: Brightness.light,
    ),
  );

  final colorScheme = base.colorScheme.copyWith(
    primary: KidPalette.blue,
    secondary: KidPalette.coral,
    surface: KidPalette.cream,
    onSurface: KidPalette.navy,
    outline: KidPalette.stroke,
    shadow: const Color(0x24182230),
  );

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: KidPalette.skyTop,
    dividerColor: KidPalette.stroke,
    splashColor: KidPalette.white.withValues(alpha: 0.14),
    highlightColor: Colors.transparent,
    textTheme: base.textTheme.copyWith(
      displayLarge: const TextStyle(
        fontSize: 60,
        fontWeight: FontWeight.w900,
        letterSpacing: -2.2,
        color: KidPalette.navy,
        height: 0.92,
      ),
      headlineLarge: const TextStyle(
        fontSize: 44,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
        color: KidPalette.navy,
        height: 1.0,
      ),
      headlineMedium: const TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.0,
        color: KidPalette.navy,
        height: 1.04,
      ),
      headlineSmall: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.7,
        color: KidPalette.navy,
        height: 1.08,
      ),
      titleLarge: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: KidPalette.navy,
        height: 1.12,
      ),
      titleMedium: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: KidPalette.body,
        height: 1.24,
      ),
      titleSmall: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: KidPalette.body,
        height: 1.2,
      ),
      bodyLarge: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: KidPalette.body,
        height: 1.35,
      ),
      bodyMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: KidPalette.body,
        height: 1.35,
      ),
      bodySmall: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: KidPalette.body,
        height: 1.3,
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: const StadiumBorder(),
      side: BorderSide.none,
      backgroundColor: KidPalette.white.withValues(alpha: 0.88),
      labelStyle: const TextStyle(
        color: KidPalette.navy,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
