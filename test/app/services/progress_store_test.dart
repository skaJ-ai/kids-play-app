import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('memory progress store records lesson and quiz progress', () async {
    final store = MemoryProgressStore();
    final earnedAt = DateTime.utc(2026, 4, 17, 12, 0);

    await store.recordLessonIndex(
      lessonId: 'hangul:basic_consonants_1',
      lastViewedIndex: 3,
    );
    await store.recordQuizResult(
      lessonId: 'hangul:basic_consonants_1',
      correctCount: 4,
      totalQuestions: 5,
      recentMistakes: const ['ㄴ', 'ㄷ', 'ㄴ'],
    );
    await store.setLessonUnlocked('hangul:basic_consonants_2', true);
    await store.addStickers(2);
    await store.recordRewardEarned(
      kind: 'sticker',
      amount: 2,
      lessonId: 'hangul:basic_consonants_1',
      earnedAt: earnedAt,
    );
    await store.setVoicePromptsEnabled(false);

    final snapshot = await store.loadSnapshot();

    expect(snapshot.stickerCount, 2);
    expect(snapshot.voicePromptsEnabled, isFalse);
    expect(snapshot.lastEarnedReward, isNotNull);
    expect(snapshot.lastEarnedReward?.kind, 'sticker');
    expect(snapshot.lastEarnedReward?.amount, 2);
    expect(snapshot.lastEarnedReward?.lessonId, 'hangul:basic_consonants_1');
    expect(snapshot.lastEarnedReward?.earnedAt, earnedAt);
    expect(
      snapshot.progressFor('hangul:basic_consonants_1').lastViewedIndex,
      3,
    );
    expect(snapshot.progressFor('hangul:basic_consonants_1').bestScore, 4);
    expect(snapshot.unlockedLessonIds, contains('hangul:basic_consonants_2'));
    expect(
      snapshot.progressFor('hangul:basic_consonants_1').recentMistakes,
      const ['ㄴ', 'ㄷ'],
    );
  });

  test(
    'memory progress store records completed quiz progress and reward in one atomic operation',
    () async {
      final store = MemoryProgressStore(
        AppProgressSnapshot(
          stickerCount: 2,
          lastEarnedReward: RecentReward(
            kind: 'sticker',
            amount: 1,
            lessonId: 'alphabet:alphabet_letters_1',
            earnedAt: DateTime.utc(2026, 4, 17, 11, 45),
          ),
        ),
      );
      final rewardEarnedAt = DateTime.utc(2026, 4, 17, 13, 0);

      await store.recordCompletedQuiz(
        lessonId: 'numbers:numbers_count_1',
        correctCount: 4,
        totalQuestions: 5,
        recentMistakes: const ['2', '4', '2'],
        stickersEarned: 1,
        rewardEarnedAt: rewardEarnedAt,
      );

      final snapshot = await store.loadSnapshot();

      expect(snapshot.stickerCount, 3);
      expect(snapshot.lastEarnedReward, isNotNull);
      expect(snapshot.lastEarnedReward?.kind, 'sticker');
      expect(snapshot.lastEarnedReward?.amount, 1);
      expect(snapshot.lastEarnedReward?.lessonId, 'numbers:numbers_count_1');
      expect(snapshot.lastEarnedReward?.earnedAt, rewardEarnedAt);
      expect(snapshot.progressFor('numbers:numbers_count_1').bestScore, 4);
      expect(snapshot.progressFor('numbers:numbers_count_1').totalQuestions, 5);
      expect(
        snapshot.progressFor('numbers:numbers_count_1').recentMistakes,
        const ['2', '4'],
      );
    },
  );

  test('shared preferences progress store persists and resets state', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesProgressStore(preferences);
    final earnedAt = DateTime.utc(2026, 4, 17, 12, 30);

    await store.recordLessonIndex(
      lessonId: 'alphabet:a_to_e',
      lastViewedIndex: 1,
    );
    await store.recordQuizResult(
      lessonId: 'alphabet:a_to_e',
      correctCount: 5,
      totalQuestions: 5,
      recentMistakes: const ['B'],
    );
    await store.setLessonUnlocked('alphabet:f_to_j', true);
    await store.addStickers(1);
    await store.recordRewardEarned(
      kind: 'sticker',
      amount: 1,
      lessonId: 'alphabet:a_to_e',
      earnedAt: earnedAt,
    );
    await store.setEffectsEnabled(false);

    final snapshot = await store.loadSnapshot();
    expect(snapshot.stickerCount, 1);
    expect(snapshot.effectsEnabled, isFalse);
    expect(snapshot.lastEarnedReward, isNotNull);
    expect(snapshot.lastEarnedReward?.kind, 'sticker');
    expect(snapshot.lastEarnedReward?.amount, 1);
    expect(snapshot.lastEarnedReward?.lessonId, 'alphabet:a_to_e');
    expect(snapshot.lastEarnedReward?.earnedAt, earnedAt);
    expect(snapshot.unlockedLessonIds, contains('alphabet:f_to_j'));
    expect(snapshot.progressFor('alphabet:a_to_e').bestScore, 5);
    expect(snapshot.progressFor('alphabet:a_to_e').recentMistakes, const ['B']);

    await store.reset();
    final resetSnapshot = await store.loadSnapshot();
    expect(resetSnapshot.stickerCount, 0);
    expect(resetSnapshot.lessons, isEmpty);
    expect(resetSnapshot.unlockedLessonIds, isEmpty);
    expect(resetSnapshot.lastEarnedReward, isNull);
    expect(resetSnapshot.voicePromptsEnabled, isTrue);
  });

  test(
    'shared preferences progress store keeps the recent reward when completed quiz persistence earns no sticker',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final store = SharedPreferencesProgressStore(preferences);
      final rewardEarnedAt = DateTime.utc(2026, 4, 17, 13, 30);

      await store.recordCompletedQuiz(
        lessonId: 'alphabet:alphabet_letters_1',
        correctCount: 5,
        totalQuestions: 5,
        recentMistakes: const <String>[],
        stickersEarned: 1,
        rewardEarnedAt: rewardEarnedAt,
      );
      await store.recordCompletedQuiz(
        lessonId: 'alphabet:alphabet_letters_1',
        correctCount: 4,
        totalQuestions: 5,
        recentMistakes: const <String>['B b'],
      );

      final snapshot = await store.loadSnapshot();

      expect(snapshot.stickerCount, 1);
      expect(snapshot.lastEarnedReward, isNotNull);
      expect(snapshot.lastEarnedReward?.kind, 'sticker');
      expect(snapshot.lastEarnedReward?.amount, 1);
      expect(
        snapshot.lastEarnedReward?.lessonId,
        'alphabet:alphabet_letters_1',
      );
      expect(snapshot.lastEarnedReward?.earnedAt, rewardEarnedAt);
      expect(snapshot.progressFor('alphabet:alphabet_letters_1').bestScore, 5);
      expect(
        snapshot.progressFor('alphabet:alphabet_letters_1').totalQuestions,
        5,
      );
      expect(
        snapshot.progressFor('alphabet:alphabet_letters_1').recentMistakes,
        const ['B b'],
      );
    },
  );

  test('snapshot ignores incomplete persisted lastEarnedReward payloads', () {
    final snapshot = AppProgressSnapshot.fromJson({
      'stickerCount': 3,
      'lastEarnedReward': {
        'kind': 'sticker',
        'amount': 2,
        'lessonId': 'alphabet:a_to_e',
      },
      'voicePromptsEnabled': false,
      'effectsEnabled': false,
      'unlockedLessonIds': ['alphabet:f_to_j'],
      'lessons': {
        'alphabet:a_to_e': {
          'bestScore': 4,
          'totalQuestions': 5,
          'lastViewedIndex': 1,
          'recentMistakes': ['B'],
        },
      },
    });

    expect(snapshot.stickerCount, 3);
    expect(snapshot.lastEarnedReward, isNull);
    expect(snapshot.voicePromptsEnabled, isFalse);
    expect(snapshot.effectsEnabled, isFalse);
    expect(snapshot.unlockedLessonIds, ['alphabet:f_to_j']);
    expect(snapshot.progressFor('alphabet:a_to_e').bestScore, 4);
    expect(snapshot.progressFor('alphabet:a_to_e').lastViewedIndex, 1);
  });

  test(
    'shared preferences store ignores malformed persisted reward payloads without losing snapshot data',
    () async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        SharedPreferencesProgressStore.storageKey,
        '{"stickerCount":4,"lastEarnedReward":{"kind":"sticker","amount":"two","lessonId":"alphabet:a_to_e","earnedAt":"2026-04-17T12:30:00Z"},"voicePromptsEnabled":false,"effectsEnabled":false,"unlockedLessonIds":["alphabet:f_to_j"],"lessons":{"alphabet:a_to_e":{"bestScore":5,"totalQuestions":5,"lastViewedIndex":1,"recentMistakes":["B"]}}}',
      );

      final store = SharedPreferencesProgressStore(preferences);
      final snapshot = await store.loadSnapshot();

      expect(snapshot.stickerCount, 4);
      expect(snapshot.lastEarnedReward, isNull);
      expect(snapshot.voicePromptsEnabled, isFalse);
      expect(snapshot.effectsEnabled, isFalse);
      expect(snapshot.unlockedLessonIds, ['alphabet:f_to_j']);
      expect(snapshot.progressFor('alphabet:a_to_e').bestScore, 5);
      expect(snapshot.progressFor('alphabet:a_to_e').lastViewedIndex, 1);
      expect(snapshot.progressFor('alphabet:a_to_e').recentMistakes, const [
        'B',
      ]);
    },
  );
}
