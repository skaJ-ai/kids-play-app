/// Centralised navigation facade.
///
/// Screens call `AppRouter.of(context).pushLearn(...)` instead of reaching
/// into [Navigator] directly. The implementation currently delegates to
/// [Navigator.push] with [MaterialPageRoute]; upgrading to go_router later
/// only touches this file.
///
/// During the overhaul, legacy screens may still use `Navigator.push`
/// directly — routes added via [AppRouter] coexist with them. Migration of
/// those call sites is deferred to the phase that rewrites each screen.
library;

import 'package:flutter/material.dart';

import 'routes.dart';

typedef RouteBuilder = Widget Function(BuildContext context, Object? args);

/// The registry of screen builders. Populated by the feature modules as
/// they migrate onto the router. Unknown routes throw so a typo surfaces
/// immediately during development instead of silently no-op'ing.
class AppRouter {
  AppRouter._(this._builders);

  static AppRouter? _instance;

  static AppRouter of(BuildContext _) {
    final router = _instance;
    if (router == null) {
      throw StateError(
        'AppRouter.install() must be called from main() before any '
        'screen calls AppRouter.of(context).',
      );
    }
    return router;
  }

  /// Installs the router with the given route table. Call once at startup.
  static void install(Map<String, RouteBuilder> builders) {
    _instance = AppRouter._(Map.unmodifiable(builders));
  }

  /// Test-only helper. Clears the installed router so successive tests
  /// start from a known state.
  @visibleForTesting
  static void resetForTest() {
    _instance = null;
  }

  final Map<String, RouteBuilder> _builders;

  // ── typed push helpers ────────────────────────────────────────────────

  Future<T?> pushLearn<T>(
    BuildContext context, {
    required String categoryId,
    required String lessonId,
  }) {
    return _push<T>(
      context,
      AppRoutes.learn,
      LessonRouteArgs(categoryId: categoryId, lessonId: lessonId),
    );
  }

  Future<T?> pushQuiz<T>(
    BuildContext context, {
    required String categoryId,
    required String lessonId,
  }) {
    return _push<T>(
      context,
      AppRoutes.quiz,
      LessonRouteArgs(categoryId: categoryId, lessonId: lessonId),
    );
  }

  Future<T?> pushReward<T>(
    BuildContext context, {
    required String categoryId,
    required String lessonId,
  }) {
    return _push<T>(
      context,
      AppRoutes.reward,
      LessonRouteArgs(categoryId: categoryId, lessonId: lessonId),
    );
  }

  Future<T?> pushParentSection<T>(
    BuildContext context, {
    required String section,
  }) {
    return _push<T>(
      context,
      'parent.$section',
      ParentSectionRouteArgs(section: section),
    );
  }

  Future<T?> _push<T>(BuildContext context, String name, Object? args) {
    final builder = _builders[name];
    if (builder == null) {
      throw StateError('No route registered for "$name"');
    }
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        settings: RouteSettings(name: name, arguments: args),
        builder: (ctx) => builder(ctx, args),
      ),
    );
  }

  /// True when the given logical route is registered. Lets legacy screens
  /// prefer the new router when a migration has happened, and fall back to
  /// direct `Navigator.push` otherwise.
  bool isRegistered(String name) => _builders.containsKey(name);
}
