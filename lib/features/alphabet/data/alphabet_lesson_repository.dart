import 'package:flutter/services.dart';

import '../../lesson/data/lesson_content_loader.dart';
import '../../lesson/domain/lesson.dart';

/// Category-aware facade kept for existing callers while the generic
/// [LessonContentLoader] serves as the real data layer. See Phase 2 of the
/// product-overhaul master plan; this shim will be removed in Phase 5.
class AlphabetLessonRepository {
  AlphabetLessonRepository({AssetBundle? assetBundle})
    : contentLoader = ManifestLessonContentLoader(
        manifestPath: manifestPath,
        assetBundle: assetBundle,
      );

  static const manifestPath = 'assets/generated/manifest/alphabet_lessons.json';

  final ManifestLessonContentLoader contentLoader;

  Future<AlphabetLesson> loadLesson(String lessonId) async {
    final lesson = await contentLoader.loadLesson(lessonId);
    return AlphabetLesson._fromLesson(lesson);
  }

  Future<List<AlphabetLesson>> loadLessons() async {
    final lessons = await contentLoader.loadLessons();
    return lessons.map(AlphabetLesson._fromLesson).toList(growable: false);
  }
}

typedef AlphabetCard = LessonItem;

class AlphabetLesson {
  const AlphabetLesson({
    required this.id,
    required this.title,
    required this.cards,
  });

  factory AlphabetLesson._fromLesson(Lesson lesson) {
    return AlphabetLesson(
      id: lesson.id,
      title: lesson.title,
      cards: lesson.items,
    );
  }

  final String id;
  final String title;
  final List<AlphabetCard> cards;
}
