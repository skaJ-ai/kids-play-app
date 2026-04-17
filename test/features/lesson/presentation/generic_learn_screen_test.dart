import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';
import 'package:kids_play_app/features/lesson/data/lesson_content_loader.dart';
import 'package:kids_play_app/features/lesson/domain/lesson.dart';
import 'package:kids_play_app/features/lesson/domain/lesson_category.dart';
import 'package:kids_play_app/features/lesson/presentation/generic_learn_screen.dart';

void main() {
  testWidgets('uses the lilac toy panel tone for the hint callout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithServices(
        child: GenericLearnScreen(
          loader: _FakeLessonLoader(_lesson),
          category: alphabetLessonCategory,
          lessonId: _lesson.id,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final hintPanel = find.ancestor(
      of: find.text('천천히 해봐!'),
      matching: find.byWidgetPredicate(
        (widget) => widget is ToyPanel && widget.tone == ToyPanelTone.lilac,
      ),
    );

    expect(hintPanel, findsOneWidget);
    expect(find.text('A를 보고 에이 하고 말해봐요.'), findsOneWidget);
  });
}

const _lesson = Lesson(
  id: 'alphabet_letters_1',
  title: '알파벳 A',
  items: [
    LessonItem(
      symbol: 'A',
      label: '알파벳 A',
      hint: 'A를 보고 에이 하고 말해봐요.',
    ),
  ],
);

class _FakeLessonLoader implements LessonContentLoader {
  const _FakeLessonLoader(this.lesson);

  final Lesson lesson;

  @override
  Future<Lesson> loadLesson(String lessonId) async => lesson;

  @override
  Future<List<Lesson>> loadLessons() async => [lesson];
}

Widget _wrapWithServices({required Widget child}) {
  return MaterialApp(
    theme: buildKidTheme(),
    home: AppServicesScope(
      services: AppServices(
        progressStore: MemoryProgressStore(),
        speechCueService: NoopSpeechCueService(),
      ),
      child: child,
    ),
  );
}
