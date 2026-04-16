import 'package:flutter/material.dart';

import '../features/hero/presentation/hero_screen.dart';
import 'services/app_services.dart';
import 'ui/kid_theme.dart';

class KidsPlayApp extends StatelessWidget {
  KidsPlayApp({super.key, AppServices? services})
    : services = services ?? AppServices.fallback();

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return AppServicesScope(
      services: services,
      child: MaterialApp(
        title: '승원이의 빵빵 놀이터',
        debugShowCheckedModeBanner: false,
        theme: buildKidTheme(),
        home: const HeroScreen(),
      ),
    );
  }
}
