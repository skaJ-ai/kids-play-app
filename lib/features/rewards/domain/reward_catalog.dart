import 'reward_models.dart';

const rewardCatalog = <RewardPack>[
  RewardPack(
    id: 'alphabet_sticker_v1',
    categoryId: 'alphabet',
    label: '알파벳 자동차 스티커',
    rewards: [
      Reward(
        id: 'alphabet:alphabet_letters_1',
        packId: 'alphabet_sticker_v1',
        categoryId: 'alphabet',
        lessonId: 'alphabet_letters_1',
        label: '알파벳 1 자동차',
        emoji: '🚗',
      ),
      Reward(
        id: 'alphabet:alphabet_letters_2',
        packId: 'alphabet_sticker_v1',
        categoryId: 'alphabet',
        lessonId: 'alphabet_letters_2',
        label: '알파벳 2 자동차',
        emoji: '🚙',
      ),
      Reward(
        id: 'alphabet:alphabet_letters_3',
        packId: 'alphabet_sticker_v1',
        categoryId: 'alphabet',
        lessonId: 'alphabet_letters_3',
        label: '알파벳 3 자동차',
        emoji: '🏎️',
      ),
      Reward(
        id: 'alphabet:alphabet_letters_4',
        packId: 'alphabet_sticker_v1',
        categoryId: 'alphabet',
        lessonId: 'alphabet_letters_4',
        label: '알파벳 4 자동차',
        emoji: '🚕',
      ),
      Reward(
        id: 'alphabet:alphabet_letters_5',
        packId: 'alphabet_sticker_v1',
        categoryId: 'alphabet',
        lessonId: 'alphabet_letters_5',
        label: '알파벳 5 자동차',
        emoji: '🚐',
      ),
    ],
  ),
  RewardPack(
    id: 'hangul_sticker_v1',
    categoryId: 'hangul',
    label: '한글 자동차 스티커',
    rewards: [
      Reward(
        id: 'hangul:basic_consonants_1',
        packId: 'hangul_sticker_v1',
        categoryId: 'hangul',
        lessonId: 'basic_consonants_1',
        label: '기본 자음 1 자동차',
        emoji: '🚌',
      ),
      Reward(
        id: 'hangul:basic_consonants_2',
        packId: 'hangul_sticker_v1',
        categoryId: 'hangul',
        lessonId: 'basic_consonants_2',
        label: '기본 자음 2 자동차',
        emoji: '🚎',
      ),
      Reward(
        id: 'hangul:basic_consonants_3',
        packId: 'hangul_sticker_v1',
        categoryId: 'hangul',
        lessonId: 'basic_consonants_3',
        label: '기본 자음 3 자동차',
        emoji: '🚓',
      ),
      Reward(
        id: 'hangul:tense_consonants_1',
        packId: 'hangul_sticker_v1',
        categoryId: 'hangul',
        lessonId: 'tense_consonants_1',
        label: '된소리 1 자동차',
        emoji: '🚑',
      ),
      Reward(
        id: 'hangul:basic_vowels_1',
        packId: 'hangul_sticker_v1',
        categoryId: 'hangul',
        lessonId: 'basic_vowels_1',
        label: '기본 모음 1 자동차',
        emoji: '🚒',
      ),
      Reward(
        id: 'hangul:basic_vowels_2',
        packId: 'hangul_sticker_v1',
        categoryId: 'hangul',
        lessonId: 'basic_vowels_2',
        label: '기본 모음 2 자동차',
        emoji: '🚜',
      ),
    ],
  ),
  RewardPack(
    id: 'numbers_sticker_v1',
    categoryId: 'numbers',
    label: '숫자 자동차 스티커',
    rewards: [
      Reward(
        id: 'numbers:numbers_count_1',
        packId: 'numbers_sticker_v1',
        categoryId: 'numbers',
        lessonId: 'numbers_count_1',
        label: '숫자 1-5 자동차',
        emoji: '🚚',
      ),
      Reward(
        id: 'numbers:numbers_count_2',
        packId: 'numbers_sticker_v1',
        categoryId: 'numbers',
        lessonId: 'numbers_count_2',
        label: '숫자 6-10 자동차',
        emoji: '🚛',
      ),
      Reward(
        id: 'numbers:numbers_count_3',
        packId: 'numbers_sticker_v1',
        categoryId: 'numbers',
        lessonId: 'numbers_count_3',
        label: '숫자 11-15 자동차',
        emoji: '🛻',
      ),
      Reward(
        id: 'numbers:numbers_count_4',
        packId: 'numbers_sticker_v1',
        categoryId: 'numbers',
        lessonId: 'numbers_count_4',
        label: '숫자 16-20 자동차',
        emoji: '🏍️',
      ),
    ],
  ),
];

RewardPack? rewardPackFor(String categoryId) {
  for (final pack in rewardCatalog) {
    if (pack.categoryId == categoryId) return pack;
  }
  return null;
}

Reward? rewardForLesson({
  required String categoryId,
  required String lessonId,
}) {
  return rewardPackFor(categoryId)?.rewardFor(lessonId);
}
