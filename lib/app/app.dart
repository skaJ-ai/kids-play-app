import 'package:flutter/material.dart';

import '../features/hero/presentation/hero_screen.dart';
import 'ui/app_colors.dart';

class KidsPlayApp extends StatelessWidget {
  const KidsPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '승원이의 빵빵 놀이터',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const HeroScreen(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.alphabetBottom,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.cream,
      useMaterial3: true,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'sans-serif',
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
        ),
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontWeight: FontWeight.w700),
        titleSmall: TextStyle(fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
