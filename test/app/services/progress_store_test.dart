import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('memory progress store records lesson and quiz progress', () async {
    final store = MemoryProgressStore();

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
    await store.addStickers(2);
    await store.setVoicePromptsEnabled(false);

    final snapshot = await store.loadSnapshot();

    expect(snapshot.stickerCount, 2);
    expect(snapshot.voicePromptsEnabled, isFalse);
    expect(snapshot.progressFor('hangul:basic_consonants_1').lastViewedIndex, 3);
    expect(snapshot.progressFor('hangul:basic_consonants_1').bestScore, 4);
    expect(
      snapshot.progressFor('hangul:basic_consonants_1').recentMistakes,
      const ['ㄴ', 'ㄷ'],
    );
  });

  test('shared preferences progress store persists and resets state', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesProgressStore(preferences);

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
    await store.addStickers(1);
    await store.setEffectsEnabled(false);

    final snapshot = await store.loadSnapshot();
    expect(snapshot.stickerCount, 1);
    expect(snapshot.effectsEnabled, isFalse);
    expect(snapshot.progressFor('alphabet:a_to_e').bestScore, 5);
    expect(snapshot.progressFor('alphabet:a_to_e').recentMistakes, const ['B']);

    await store.reset();
    final resetSnapshot = await store.loadSnapshot();
    expect(resetSnapshot.stickerCount, 0);
    expect(resetSnapshot.lessons, isEmpty);
    expect(resetSnapshot.voicePromptsEnabled, isTrue);
  });
}
