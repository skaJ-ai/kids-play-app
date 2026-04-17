/// Canonical names for the routes the child and parent flows can take.
///
/// Keep these as the single source of truth. Never hard-code a name at a
/// call site — the router facade (`AppRouter`) exposes one typed helper per
/// route so screens don't need to know the underlying navigation mechanism.
library;

abstract final class AppRoutes {
  // Child flow
  static const hero = 'hero';
  static const home = 'home';
  static const category = 'category';
  static const lessonPicker = 'category.lessons';
  static const learn = 'category.lesson.learn';
  static const quiz = 'category.lesson.quiz';
  static const reward = 'category.lesson.reward';

  // Parent flow (hidden entry).
  static const parent = 'parent';
  static const parentProgress = 'parent.progress';
  static const parentUnlock = 'parent.unlock';
  static const parentMistakes = 'parent.mistakes';
  static const parentAssets = 'parent.assets';
  static const parentSettings = 'parent.settings';
}

/// Arguments passed to [AppRoutes.learn] / [AppRoutes.quiz] / [AppRoutes.reward].
///
/// Kept as a plain value class instead of a Map so the compiler catches
/// missing fields.
class LessonRouteArgs {
  const LessonRouteArgs({required this.categoryId, required this.lessonId});

  final String categoryId;
  final String lessonId;
}

class CategoryRouteArgs {
  const CategoryRouteArgs({required this.categoryId});

  final String categoryId;
}

class ParentSectionRouteArgs {
  const ParentSectionRouteArgs({required this.section});

  final String section;
}
