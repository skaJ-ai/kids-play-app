import 'package:flutter/material.dart';

class KidPalette {
  static const skyTop = Color(0xFFBFE8FF);
  static const skyBottom = Color(0xFFFDF5DA);
  static const cream = Color(0xFFFFFAEE);
  static const creamWarm = Color(0xFFFFF1C7);
  static const navy = Color(0xFF184A78);
  static const body = Color(0xFF35658F);
  static const coral = Color(0xFFF56B7F);
  static const coralDark = Color(0xFFE8566B);
  static const blue = Color(0xFF4B98FF);
  static const blueDark = Color(0xFF2F78DB);
  static const mint = Color(0xFF8BE7B7);
  static const mintDark = Color(0xFF4DB783);
  static const yellow = Color(0xFFFFE699);
  static const yellowDark = Color(0xFFF0C85A);
  static const lilac = Color(0xFFD9CCFF);
  static const white = Colors.white;
}

class KidShadows {
  static List<BoxShadow> get panel => const [
    BoxShadow(
      color: Color(0x1F184A78),
      blurRadius: 22,
      offset: Offset(0, 12),
    ),
  ];

  static List<BoxShadow> get button => const [
    BoxShadow(
      color: Color(0x33184A78),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
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

  return base.copyWith(
    scaffoldBackgroundColor: KidPalette.skyTop,
    textTheme: base.textTheme.copyWith(
      headlineLarge: const TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.w900,
        color: KidPalette.navy,
        height: 1.08,
      ),
      headlineMedium: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: KidPalette.navy,
        height: 1.1,
      ),
      headlineSmall: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: KidPalette.navy,
        height: 1.15,
      ),
      titleLarge: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: KidPalette.navy,
        height: 1.15,
      ),
      titleMedium: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: KidPalette.body,
        height: 1.2,
      ),
      titleSmall: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: KidPalette.body,
        height: 1.2,
      ),
      bodyMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: KidPalette.body,
        height: 1.35,
      ),
    ),
  );
}
