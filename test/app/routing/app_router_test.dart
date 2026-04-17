import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/routing/app_router.dart';
import 'package:kids_play_app/app/routing/routes.dart';

/// Pump a tiny app that exposes a valid [BuildContext] to the test body.
Future<BuildContext> _pumpContext(WidgetTester tester) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (ctx) {
          captured = ctx;
          return const SizedBox();
        },
      ),
    ),
  );
  return captured;
}

void main() {
  tearDown(AppRouter.resetForTest);

  testWidgets('isRegistered reports whether a logical route exists',
      (tester) async {
    AppRouter.install({AppRoutes.learn: (_, _) => const SizedBox()});

    final ctx = await _pumpContext(tester);
    final router = AppRouter.of(ctx);

    expect(router.isRegistered(AppRoutes.learn), isTrue);
    expect(router.isRegistered(AppRoutes.quiz), isFalse);
  });

  testWidgets('of() throws before install()', (tester) async {
    final ctx = await _pumpContext(tester);
    expect(() => AppRouter.of(ctx), throwsA(isA<StateError>()));
  });

  testWidgets('pushLearn routes to the registered builder with args',
      (tester) async {
    AppRouter.install({
      AppRoutes.learn: (_, args) => _ArgsProbe(args: args! as LessonRouteArgs),
    });

    final ctx = await _pumpContext(tester);

    unawaited(
      AppRouter.of(ctx).pushLearn<void>(
        ctx,
        categoryId: 'alphabet',
        lessonId: 'alphabet_letters_1',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(_ArgsProbe), findsOneWidget);
    final probe = tester.widget<_ArgsProbe>(find.byType(_ArgsProbe));
    expect(probe.args.categoryId, 'alphabet');
    expect(probe.args.lessonId, 'alphabet_letters_1');
  });

  testWidgets('unknown route throws StateError', (tester) async {
    AppRouter.install(const {});

    final ctx = await _pumpContext(tester);

    expect(
      () => AppRouter.of(ctx).pushLearn<void>(
        ctx,
        categoryId: 'x',
        lessonId: 'y',
      ),
      throwsA(isA<StateError>()),
    );
  });
}

class _ArgsProbe extends StatelessWidget {
  const _ArgsProbe({required this.args});
  final LessonRouteArgs args;
  @override
  Widget build(BuildContext context) => const SizedBox();
}
