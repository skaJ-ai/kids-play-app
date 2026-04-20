import '../../../app/services/progress_store.dart';
import '../../lesson/domain/quiz_rules.dart';
import '../domain/reward_catalog.dart';
import '../domain/reward_models.dart';

typedef RewardLookup = Reward? Function({
  required String categoryId,
  required String lessonId,
});

/// Evaluates whether a completed quiz earned a catalog reward and records
/// the resulting event to [ProgressStore]. Returns the earned [Reward] (or
/// null when the score fell short or no catalog entry matches).
class RewardCoordinator {
  RewardCoordinator({
    required ProgressStore progressStore,
    RewardLookup? rewardLookup,
    DateTime Function()? now,
  }) : _progressStore = progressStore,
       _rewardLookup = rewardLookup ?? rewardForLesson,
       _now = now ?? DateTime.now;

  final ProgressStore _progressStore;
  final RewardLookup _rewardLookup;
  final DateTime Function() _now;

  Future<Reward?> evaluate({
    required String categoryId,
    required String lessonId,
    required int correctCount,
    required int totalQuestions,
  }) async {
    if (!earnedSticker(correctCount, totalQuestions)) return null;
    final reward = _rewardLookup(
      categoryId: categoryId,
      lessonId: lessonId,
    );
    if (reward == null) return null;
    await _progressStore.recordRewardEvent(
      RewardEvent(at: _now(), lessonId: lessonId, reward: reward),
    );
    return reward;
  }
}
