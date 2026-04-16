import 'package:flutter/material.dart';

import '../features/hero/presentation/hero_screen.dart';

class KidsPlayApp extends StatelessWidget {
  const KidsPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '승원이의 빵빵 놀이터',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF67C5FF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3FBFF),
        useMaterial3: true,
      ),
      home: const HeroScreen(),
    );
  }
}
