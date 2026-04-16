import 'package:flutter/material.dart';

import '../features/hero/presentation/hero_screen.dart';
import 'ui/kid_theme.dart';

class KidsPlayApp extends StatelessWidget {
  const KidsPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '승원이의 빵빵 놀이터',
      debugShowCheckedModeBanner: false,
      theme: buildKidTheme(),
      home: const HeroScreen(),
    );
  }
}
