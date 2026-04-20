import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/features/rewards/application/reward_coordinator.dart';

void main() {
  group('RewardCoordinator.evaluate', () {
    test('records an event and returns the reward on a perfect score', () async {
      final progressStore = MemoryProgressStore();
      final fixedNow = DateTime.utc(2026, 4, 20, 10);
      final coordinator = RewardCoordinator(
        progressStore: progressStore,
        now: () => fixedNow,
      );

      final reward = await coordinator.evaluate(
        categoryId: 'alphabet',
        lessonId: 'alphabet_letters_1',
        correctCount: 5,
        totalQuestions: 5,
      );

      expect(reward, isNotNull);
      expect(reward!.id, 'alphabet:alphabet_letters_1');

      final snapshot = await progressStore.loadSnapshot();
      expect(snapshot.rewardEvents, hasLength(1));
      expect(snapshot.rewardEvents.first.at, fixedNow);
      expect(snapshot.rewardEvents.first.reward.id, reward.id);
    });

    test('returns null and writes nothing below the perfect threshold',
        () async {
      final progressStore = MemoryProgressStore();
      final coordinator = RewardCoordinator(progressStore: progressStore);

      final reward = await coordinator.evaluate(
        categoryId: 'alphabet',
        lessonId: 'alphabet_letters_1',
        correctCount: 3,
        totalQuestions: 5,
      );

      expect(reward, isNull);
      final snapshot = await progressStore.loadSnapshot();
      expect(snapshot.rewardEvents, isEmpty);
    });

    test('returns null when the catalog has no entry for the lesson',
        () async {
      final progressStore = MemoryProgressStore();
      final coordinator = RewardCoordinator(
        progressStore: progressStore,
        rewardLookup: ({required categoryId, required lessonId}) => null,
      );

      final reward = await coordinator.evaluate(
        categoryId: 'alphabet',
        lessonId: 'missing_lesson',
        correctCount: 5,
        totalQuestions: 5,
      );

      expect(reward, isNull);
      final snapshot = await progressStore.loadSnapshot();
      expect(snapshot.rewardEvents, isEmpty);
    });

    test('re-earning the same reward stays deduped in the event log',
        () async {
      final progressStore = MemoryProgressStore();
      final coordinator = RewardCoordinator(progressStore: progressStore);

      await coordinator.evaluate(
        categoryId: 'hangul',
        lessonId: 'basic_consonants_1',
        correctCount: 5,
        totalQuestions: 5,
      );
      final secondEarn = await coordinator.evaluate(
        categoryId: 'hangul',
        lessonId: 'basic_consonants_1',
        correctCount: 5,
        totalQuestions: 5,
      );

      expect(secondEarn, isNotNull);
      final snapshot = await progressStore.loadSnapshot();
      expect(snapshot.rewardEvents, hasLength(1));
    });
  });
}
