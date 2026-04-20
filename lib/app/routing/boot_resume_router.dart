import 'package:flutter/material.dart';

import '../../features/hero/presentation/hero_screen.dart';
import '../../features/home/presentation/home_category_config.dart';

/// Entry-point widget that will eventually resume the last-played lesson.
///
/// The resume feature (progress-snapshot `lastLesson` + learn-screen factory)
/// ships with later work — for now this renders the hero screen so a fresh
/// install opens without a flash.
class BootResumeRouter extends StatelessWidget {
  const BootResumeRouter({
    super.key,
    this.categoryDependencies = const HomeCategoryDependencies(),
  });

  final HomeCategoryDependencies categoryDependencies;

  @override
  Widget build(BuildContext context) => const HeroScreen();
}
