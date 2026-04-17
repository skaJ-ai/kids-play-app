import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LessonProgress {
  const LessonProgress({
    this.bestScore = 0,
    this.totalQuestions = 0,
    this.lastViewedIndex = 0,
    this.recentMistakes = const [],
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      bestScore: json['bestScore'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      lastViewedIndex: json['lastViewedIndex'] as int? ?? 0,
      recentMistakes: (json['recentMistakes'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }

  final int bestScore;
  final int totalQuestions;
  final int lastViewedIndex;
  final List<String> recentMistakes;

  LessonProgress copyWith({
    int? bestScore,
    int? totalQuestions,
    int? lastViewedIndex,
    List<String>? recentMistakes,
  }) {
    return LessonProgress(
      bestScore: bestScore ?? this.bestScore,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      lastViewedIndex: lastViewedIndex ?? this.lastViewedIndex,
      recentMistakes: recentMistakes ?? this.recentMistakes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bestScore': bestScore,
      'totalQuestions': totalQuestions,
      'lastViewedIndex': lastViewedIndex,
      'recentMistakes': recentMistakes,
    };
  }
}

class AppProgressSnapshot {
  const AppProgressSnapshot({
    this.stickerCount = 0,
    this.voicePromptsEnabled = true,
    this.effectsEnabled = true,
    this.unlockedLessonIds = const [],
    this.lessons = const {},
  });

  factory AppProgressSnapshot.fromJson(Map<String, dynamic> json) {
    final lessonJson = (json['lessons'] as Map<String, dynamic>? ?? const {});
    return AppProgressSnapshot(
      stickerCount: json['stickerCount'] as int? ?? 0,
      voicePromptsEnabled: json['voicePromptsEnabled'] as bool? ?? true,
      effectsEnabled: json['effectsEnabled'] as bool? ?? true,
      unlockedLessonIds:
          (json['unlockedLessonIds'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(growable: false),
      lessons: lessonJson.map(
        (key, value) => MapEntry(
          key,
          LessonProgress.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  final int stickerCount;
  final bool voicePromptsEnabled;
  final bool effectsEnabled;
  final List<String> unlockedLessonIds;
  final Map<String, LessonProgress> lessons;

  LessonProgress progressFor(String lessonId) {
    return lessons[lessonId] ?? const LessonProgress();
  }

  AppProgressSnapshot copyWith({
    int? stickerCount,
    bool? voicePromptsEnabled,
    bool? effectsEnabled,
    List<String>? unlockedLessonIds,
    Map<String, LessonProgress>? lessons,
  }) {
    return AppProgressSnapshot(
      stickerCount: stickerCount ?? this.stickerCount,
      voicePromptsEnabled: voicePromptsEnabled ?? this.voicePromptsEnabled,
      effectsEnabled: effectsEnabled ?? this.effectsEnabled,
      unlockedLessonIds: unlockedLessonIds ?? this.unlockedLessonIds,
      lessons: lessons ?? this.lessons,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': 1,
      'stickerCount': stickerCount,
      'voicePromptsEnabled': voicePromptsEnabled,
      'effectsEnabled': effectsEnabled,
      'unlockedLessonIds': unlockedLessonIds,
      'lessons': lessons.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

abstract class ProgressStore {
  Future<AppProgressSnapshot> loadSnapshot();

  Future<void> addStickers(int count);

  Future<void> recordLessonIndex({
    required String lessonId,
    required int lastViewedIndex,
  });

  Future<void> recordQuizResult({
    required String lessonId,
    required int correctCount,
    required int totalQuestions,
    required List<String> recentMistakes,
  });

  Future<void> setVoicePromptsEnabled(bool enabled);

  Future<void> setEffectsEnabled(bool enabled);

  Future<void> setLessonUnlocked(String lessonId, bool unlocked);

  Future<void> reset();
}

class MemoryProgressStore implements ProgressStore {
  MemoryProgressStore([AppProgressSnapshot? snapshot])
    : _snapshot = snapshot ?? const AppProgressSnapshot();

  AppProgressSnapshot _snapshot;

  @override
  Future<void> addStickers(int count) async {
    _snapshot = _snapshot.copyWith(
      stickerCount: _snapshot.stickerCount + count,
    );
  }

  @override
  Future<AppProgressSnapshot> loadSnapshot() async => _snapshot;

  @override
  Future<void> recordLessonIndex({
    required String lessonId,
    required int lastViewedIndex,
  }) async {
    final current = _snapshot.progressFor(lessonId);
    _snapshot = _snapshot.copyWith(
      lessons: {
        ..._snapshot.lessons,
        lessonId: current.copyWith(lastViewedIndex: lastViewedIndex),
      },
    );
  }

  @override
  Future<void> recordQuizResult({
    required String lessonId,
    required int correctCount,
    required int totalQuestions,
    required List<String> recentMistakes,
  }) async {
    final current = _snapshot.progressFor(lessonId);
    _snapshot = _snapshot.copyWith(
      lessons: {
        ..._snapshot.lessons,
        lessonId: current.copyWith(
          bestScore: correctCount > current.bestScore
              ? correctCount
              : current.bestScore,
          totalQuestions: totalQuestions,
          recentMistakes: _normalizedMistakes(recentMistakes),
        ),
      },
    );
  }

  @override
  Future<void> reset() async {
    _snapshot = const AppProgressSnapshot();
  }

  @override
  Future<void> setEffectsEnabled(bool enabled) async {
    _snapshot = _snapshot.copyWith(effectsEnabled: enabled);
  }

  @override
  Future<void> setLessonUnlocked(String lessonId, bool unlocked) async {
    final nextIds = _normalizedLessonIds(
      unlocked
          ? <String>[..._snapshot.unlockedLessonIds, lessonId]
          : _snapshot.unlockedLessonIds
                .where((candidate) => candidate != lessonId)
                .toList(growable: false),
    );
    _snapshot = _snapshot.copyWith(unlockedLessonIds: nextIds);
  }

  @override
  Future<void> setVoicePromptsEnabled(bool enabled) async {
    _snapshot = _snapshot.copyWith(voicePromptsEnabled: enabled);
  }
}

class SharedPreferencesProgressStore implements ProgressStore {
  SharedPreferencesProgressStore(this._preferences);

  static const storageKey = 'app_progress_v1';

  final SharedPreferences _preferences;

  @override
  Future<void> addStickers(int count) async {
    await _mutate((snapshot) {
      return snapshot.copyWith(stickerCount: snapshot.stickerCount + count);
    });
  }

  @override
  Future<AppProgressSnapshot> loadSnapshot() async {
    final raw = _preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const AppProgressSnapshot();
    }

    try {
      return AppProgressSnapshot.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const AppProgressSnapshot();
    }
  }

  @override
  Future<void> recordLessonIndex({
    required String lessonId,
    required int lastViewedIndex,
  }) async {
    await _mutate((snapshot) {
      final current = snapshot.progressFor(lessonId);
      return snapshot.copyWith(
        lessons: {
          ...snapshot.lessons,
          lessonId: current.copyWith(lastViewedIndex: lastViewedIndex),
        },
      );
    });
  }

  @override
  Future<void> recordQuizResult({
    required String lessonId,
    required int correctCount,
    required int totalQuestions,
    required List<String> recentMistakes,
  }) async {
    await _mutate((snapshot) {
      final current = snapshot.progressFor(lessonId);
      return snapshot.copyWith(
        lessons: {
          ...snapshot.lessons,
          lessonId: current.copyWith(
            bestScore: correctCount > current.bestScore
                ? correctCount
                : current.bestScore,
            totalQuestions: totalQuestions,
            recentMistakes: _normalizedMistakes(recentMistakes),
          ),
        },
      );
    });
  }

  @override
  Future<void> reset() async {
    await _preferences.remove(storageKey);
  }

  @override
  Future<void> setEffectsEnabled(bool enabled) async {
    await _mutate((snapshot) {
      return snapshot.copyWith(effectsEnabled: enabled);
    });
  }

  @override
  Future<void> setLessonUnlocked(String lessonId, bool unlocked) async {
    await _mutate((snapshot) {
      final nextIds = _normalizedLessonIds(
        unlocked
            ? <String>[...snapshot.unlockedLessonIds, lessonId]
            : snapshot.unlockedLessonIds
                  .where((candidate) => candidate != lessonId)
                  .toList(growable: false),
      );
      return snapshot.copyWith(unlockedLessonIds: nextIds);
    });
  }

  @override
  Future<void> setVoicePromptsEnabled(bool enabled) async {
    await _mutate((snapshot) {
      return snapshot.copyWith(voicePromptsEnabled: enabled);
    });
  }

  Future<void> _mutate(
    AppProgressSnapshot Function(AppProgressSnapshot snapshot) transform,
  ) async {
    final snapshot = await loadSnapshot();
    final next = transform(snapshot);
    await _preferences.setString(storageKey, jsonEncode(next.toJson()));
  }
}

List<String> _normalizedMistakes(List<String> mistakes) {
  final unique = <String>[];
  for (final item in mistakes) {
    final normalized = item.trim();
    if (normalized.isEmpty || unique.contains(normalized)) {
      continue;
    }
    unique.add(normalized);
    if (unique.length >= 5) {
      break;
    }
  }
  return unique;
}

List<String> _normalizedLessonIds(List<String> lessonIds) {
  final unique = <String>[];
  for (final item in lessonIds) {
    final normalized = item.trim();
    if (normalized.isEmpty || unique.contains(normalized)) {
      continue;
    }
    unique.add(normalized);
  }
  return unique;
}
