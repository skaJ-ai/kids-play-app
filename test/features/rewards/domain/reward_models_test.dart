import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/features/rewards/domain/reward_catalog.dart';
import 'package:kids_play_app/features/rewards/domain/reward_models.dart';

void main() {
  group('Reward JSON', () {
    test('round-trips through toJson/fromJson', () {
      const reward = Reward(
        id: 'alphabet:alphabet_letters_1',
        packId: 'alphabet_sticker_v1',
        categoryId: 'alphabet',
        lessonId: 'alphabet_letters_1',
        label: '알파벳 1 자동차',
        emoji: '🚗',
      );

      final roundTripped = Reward.fromJson(reward.toJson());

      expect(roundTripped, reward);
      expect(roundTripped.emoji, '🚗');
    });

    test('fromJson throws on missing fields', () {
      expect(
        () => Reward.fromJson(<String, dynamic>{'id': 'only-id'}),
        throwsFormatException,
      );
    });
  });

  group('RewardEvent JSON', () {
    test('round-trips including nested reward', () {
      final event = RewardEvent(
        at: DateTime.utc(2026, 4, 20, 10, 30),
        lessonId: 'alphabet_letters_1',
        reward: const Reward(
          id: 'alphabet:alphabet_letters_1',
          packId: 'alphabet_sticker_v1',
          categoryId: 'alphabet',
          lessonId: 'alphabet_letters_1',
          label: '알파벳 1 자동차',
          emoji: '🚗',
        ),
      );

      final roundTripped = RewardEvent.fromJson(event.toJson());

      expect(roundTripped.at, event.at);
      expect(roundTripped.lessonId, event.lessonId);
      expect(roundTripped.reward, event.reward);
    });

    test('fromJson throws when at is not parseable', () {
      expect(
        () => RewardEvent.fromJson(<String, dynamic>{
          'at': 'not-a-date',
          'lessonId': 'x',
          'reward': {},
        }),
        throwsFormatException,
      );
    });
  });

  group('reward catalog', () {
    test('has a pack per category with unique reward ids', () {
      final categoryIds = rewardCatalog.map((p) => p.categoryId).toList();
      expect(categoryIds, containsAll(['alphabet', 'hangul', 'numbers']));

      final allIds = <String>[
        for (final pack in rewardCatalog)
          for (final reward in pack.rewards) reward.id,
      ];
      expect(allIds.toSet().length, allIds.length);
    });

    test('rewardForLesson returns the expected reward', () {
      final reward = rewardForLesson(
        categoryId: 'hangul',
        lessonId: 'basic_consonants_1',
      );
      expect(reward, isNotNull);
      expect(reward!.emoji, isNotEmpty);
      expect(reward.packId, 'hangul_sticker_v1');
    });

    test('rewardForLesson returns null for unknown ids', () {
      expect(
        rewardForLesson(categoryId: 'missing', lessonId: 'x'),
        isNull,
      );
      expect(
        rewardForLesson(categoryId: 'alphabet', lessonId: 'missing'),
        isNull,
      );
    });
  });
}
