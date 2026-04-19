import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const rewardKindSticker = 'sticker';
const rewardKindMistakeReplaySticker = 'mistakeReplaySticker';

class _RecentRewardUnchanged {
  const _RecentRewardUnchanged();
}

const _noRecentRewardChange = _RecentRewardUnchanged();

class RecentReward {
  const RecentReward({
    required this.kind,
    required this.amount,
    required this.lessonId,
    required this.earnedAt,
  });

  factory RecentReward.fromJson(Map<String, dynamic> json) {
    final kind = json['kind'];
    final amount = json['amount'];
    final lessonId = json['lessonId'];
    final earnedAt = json['earnedAt'];

    if (kind is! String || lessonId is! String || earnedAt is! String) {
      throw const FormatException('Invalid recent reward payload.');
    }

    final parsedEarnedAt = DateTime.tryParse(earnedAt);
    if (parsedEarnedAt == null) {
      throw const FormatException('Invalid recent reward payload.');
    }

    final parsedAmount = switch (amount) {
      int value => value,
      num value when value == value.roundToDouble() => value.toInt(),
      _ => throw const FormatException('Invalid recent reward payload.'),
    };

    return RecentReward(
      kind: kind,
      amount: parsedAmount,
      lessonId: lessonId,
      earnedAt: parsedEarnedAt,
    );
  }

  final String kind;
  final int amount;
  final String lessonId;
  final DateTime earnedAt;

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'amount': amount,
      'lessonId': lessonId,
      'earnedAt': earnedAt.toIso8601String(),
    };
  }
}

RecentReward? _recentRewardFromJson(Object? json) {
  if (json is! Map) {
    return null;
  }

  try {
    return RecentReward.fromJson(Map<String, dynamic>.from(json));
  } catch (_) {
    return null;
  }
}

class LessonProgress {
  const LessonProgress({
    this.bestScore = 0,
    this.totalQuestions = 0,
    this.lastViewedIndex = 0,
    this.recentMistakes = const [],
    this.mistakeReplayCount = 0,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      bestScore: json['bestScore'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      lastViewedIndex: json['lastViewedIndex'] as int? ?? 0,
      recentMistakes: (json['recentMistakes'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      mistakeReplayCount: _jsonIntOrZero(json['mistakeReplayCount']),
    );
  }

  final int bestScore;
  final int totalQuestions;
  final int lastViewedIndex;
  final List<String> recentMistakes;
  final int mistakeReplayCount;

  LessonProgress copyWith({
    int? bestScore,
    int? totalQuestions,
    int? lastViewedIndex,
    List<String>? recentMistakes,
    int? mistakeReplayCount,
  }) {
    return LessonProgress(
      bestScore: bestScore ?? this.bestScore,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      lastViewedIndex: lastViewedIndex ?? this.lastViewedIndex,
      recentMistakes: recentMistakes ?? this.recentMistakes,
      mistakeReplayCount: mistakeReplayCount ?? this.mistakeReplayCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bestScore': bestScore,
      'totalQuestions': totalQuestions,
      'lastViewedIndex': lastViewedIndex,
      'recentMistakes': recentMistakes,
      'mistakeReplayCount': mistakeReplayCount,
    };
  }
}

class AppProgressSnapshot {
  const AppProgressSnapshot({
    this.stickerCount = 0,
    this.replayRewardStickerCount = 0,
    this.replayRewardStickerCountTracked = true,
    this.lastEarnedReward,
    this.voicePromptsEnabled = true,
    this.effectsEnabled = true,
    this.unlockedLessonIds = const [],
    this.lessons = const {},
  });

  factory AppProgressSnapshot.fromJson(Map<String, dynamic> json) {
    final lessonJson = (json['lessons'] as Map<String, dynamic>? ?? const {});
    final rewardJson = json['lastEarnedReward'];
    final replayRewardStickerCountTracked =
        json.containsKey('replayRewardStickerCountTracked')
        ? _jsonBoolOrFalse(json['replayRewardStickerCountTracked'])
        : json.containsKey('replayRewardStickerCount');
    return AppProgressSnapshot(
      stickerCount: json['stickerCount'] as int? ?? 0,
      replayRewardStickerCount: _jsonIntOrZero(
        json['replayRewardStickerCount'],
      ),
      replayRewardStickerCountTracked: replayRewardStickerCountTracked,
      lastEarnedReward: _recentRewardFromJson(rewardJson),
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
  final int replayRewardStickerCount;
  final bool replayRewardStickerCountTracked;
  final RecentReward? lastEarnedReward;
  final bool voicePromptsEnabled;
  final bool effectsEnabled;
  final List<String> unlockedLessonIds;
  final Map<String, LessonProgress> lessons;

  LessonProgress progressFor(String lessonId) {
    return lessons[lessonId] ?? const LessonProgress();
  }

  AppProgressSnapshot copyWith({
    int? stickerCount,
    int? replayRewardStickerCount,
    bool? replayRewardStickerCountTracked,
    Object? lastEarnedReward = _noRecentRewardChange,
    bool? voicePromptsEnabled,
    bool? effectsEnabled,
    List<String>? unlockedLessonIds,
    Map<String, LessonProgress>? lessons,
  }) {
    return AppProgressSnapshot(
      stickerCount: stickerCount ?? this.stickerCount,
      replayRewardStickerCount:
          replayRewardStickerCount ?? this.replayRewardStickerCount,
      replayRewardStickerCountTracked:
          replayRewardStickerCountTracked ??
          this.replayRewardStickerCountTracked,
      lastEarnedReward: identical(lastEarnedReward, _noRecentRewardChange)
          ? this.lastEarnedReward
          : lastEarnedReward as RecentReward?,
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
      'replayRewardStickerCount': replayRewardStickerCount,
      'replayRewardStickerCountTracked': replayRewardStickerCountTracked,
      'lastEarnedReward': lastEarnedReward?.toJson(),
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

  Future<void> recordRewardEarned({
    required String kind,
    required int amount,
    required String lessonId,
    required DateTime earnedAt,
  });

  Future<void> recordLessonIndex({
    required String lessonId,
    required int lastViewedIndex,
  });

  Future<void> recordQuizResult({
    required String lessonId,
    required int correctCount,
    required int totalQuestions,
    required List<String> recentMistakes,
    bool isMistakeReplay = false,
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
  Future<void> recordRewardEarned({
    required String kind,
    required int amount,
    required String lessonId,
    required DateTime earnedAt,
  }) async {
    final isReplayReward = kind == rewardKindMistakeReplaySticker;
    _snapshot = _snapshot.copyWith(
      replayRewardStickerCount: isReplayReward
          ? _snapshot.replayRewardStickerCount + amount
          : _snapshot.replayRewardStickerCount,
      replayRewardStickerCountTracked: isReplayReward
          ? true
          : _snapshot.replayRewardStickerCountTracked,
      lastEarnedReward: RecentReward(
        kind: kind,
        amount: amount,
        lessonId: lessonId,
        earnedAt: earnedAt,
      ),
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
    bool isMistakeReplay = false,
  }) async {
    final current = _snapshot.progressFor(lessonId);
    _snapshot = _snapshot.copyWith(
      lessons: {
        ..._snapshot.lessons,
        lessonId: current.copyWith(
          bestScore: isMistakeReplay
              ? current.bestScore
              : correctCount > current.bestScore
              ? correctCount
              : current.bestScore,
          totalQuestions: isMistakeReplay
              ? current.totalQuestions
              : totalQuestions,
          recentMistakes: _normalizedMistakes(recentMistakes),
          mistakeReplayCount: isMistakeReplay
              ? current.mistakeReplayCount + 1
              : current.mistakeReplayCount,
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
  Future<void> recordRewardEarned({
    required String kind,
    required int amount,
    required String lessonId,
    required DateTime earnedAt,
  }) async {
    final isReplayReward = kind == rewardKindMistakeReplaySticker;
    await _mutate((snapshot) {
      return snapshot.copyWith(
        replayRewardStickerCount: isReplayReward
            ? snapshot.replayRewardStickerCount + amount
            : snapshot.replayRewardStickerCount,
        replayRewardStickerCountTracked: isReplayReward
            ? true
            : snapshot.replayRewardStickerCountTracked,
        lastEarnedReward: RecentReward(
          kind: kind,
          amount: amount,
          lessonId: lessonId,
          earnedAt: earnedAt,
        ),
      );
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
    bool isMistakeReplay = false,
  }) async {
    await _mutate((snapshot) {
      final current = snapshot.progressFor(lessonId);
      return snapshot.copyWith(
        lessons: {
          ...snapshot.lessons,
          lessonId: current.copyWith(
            bestScore: isMistakeReplay
                ? current.bestScore
                : correctCount > current.bestScore
                ? correctCount
                : current.bestScore,
            totalQuestions: isMistakeReplay
                ? current.totalQuestions
                : totalQuestions,
            recentMistakes: _normalizedMistakes(recentMistakes),
            mistakeReplayCount: isMistakeReplay
                ? current.mistakeReplayCount + 1
                : current.mistakeReplayCount,
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

int _jsonIntOrZero(Object? value) {
  return switch (value) {
    int parsed => parsed,
    num parsed when parsed == parsed.roundToDouble() => parsed.toInt(),
    _ => 0,
  };
}

bool _jsonBoolOrFalse(Object? value) {
  return switch (value) {
    bool parsed => parsed,
    _ => false,
  };
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
