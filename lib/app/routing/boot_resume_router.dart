import 'package:flutter/material.dart';

import '../../features/hero/presentation/hero_screen.dart';
import '../../features/home/presentation/home_category_config.dart';
import '../services/app_services.dart';

/// Boot-time route resolution: if the progress store has a `lastLesson`,
/// open that learn screen directly; otherwise fall back to the hero screen.
///
/// Renders the hero screen while the snapshot is resolving so a fresh
/// install never flashes a spinner.
class BootResumeRouter extends StatefulWidget {
  const BootResumeRouter({
    super.key,
    this.categoryDependencies = const HomeCategoryDependencies(),
  });

  final HomeCategoryDependencies categoryDependencies;

  @override
  State<BootResumeRouter> createState() => _BootResumeRouterState();
}

class _BootResumeRouterState extends State<BootResumeRouter> {
  Widget? _resume;
  bool _resolved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_resolved) {
      _resolved = true;
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final services = AppServicesScope.of(context);
    final snapshot = await services.progressStore.loadSnapshot();
    if (!mounted) return;
    final lastLesson = snapshot.lastLesson;
    if (lastLesson == null) return;
    final destination = buildResumeLearnScreen(
      categoryId: lastLesson.categoryId,
      lessonId: lastLesson.lessonId,
      dependencies: widget.categoryDependencies,
    );
    if (destination == null || !mounted) return;
    setState(() => _resume = destination);
  }

  @override
  Widget build(BuildContext context) {
    return _resume ?? const HeroScreen();
  }
}
