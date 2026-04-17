import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/lesson.dart';

/// Loads category-agnostic lesson content from a bundled manifest.
abstract class LessonContentLoader {
  Future<Lesson> loadLesson(String lessonId);
  Future<List<Lesson>> loadLessons();
}

/// Default implementation backed by a bundle manifest JSON file.
///
/// Each manifest is shaped as:
/// ```json
/// { "lessons": [ { "id": "...", "title": "...", "cards": [...] } ] }
/// ```
class ManifestLessonContentLoader implements LessonContentLoader {
  ManifestLessonContentLoader({
    required this.manifestPath,
    AssetBundle? assetBundle,
  }) : _assetBundle = assetBundle ?? rootBundle;

  final String manifestPath;
  final AssetBundle _assetBundle;

  @override
  Future<Lesson> loadLesson(String lessonId) async {
    final lessons = await loadLessons();
    return lessons.firstWhere(
      (lesson) => lesson.id == lessonId,
      orElse: () => throw StateError('Missing lesson: $lessonId'),
    );
  }

  @override
  Future<List<Lesson>> loadLessons() async {
    final jsonString = await _assetBundle.loadString(manifestPath);
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    final lessons = (jsonMap['lessons'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return lessons.map(Lesson.fromJson).toList(growable: false);
  }
}
