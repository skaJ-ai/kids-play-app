import 'package:flutter/material.dart';

import '../../alphabet/data/alphabet_lesson_repository.dart';
import '../../alphabet/presentation/alphabet_learn_screen.dart';
import '../../alphabet/presentation/alphabet_quiz_screen.dart';
import '../../hangul/data/hangul_lesson_repository.dart';
import '../../hangul/presentation/hangul_learn_screen.dart';
import '../../hangul/presentation/hangul_quiz_screen.dart';
import '../../numbers/data/numbers_lesson_repository.dart';
import '../../numbers/presentation/numbers_learn_screen.dart';
import '../../numbers/presentation/numbers_quiz_screen.dart';
import '../data/home_catalog_repository.dart';

typedef HomeCategoryScreenBuilder =
    Widget Function(HomeCategoryDependencies dependencies);

class HomeCategoryDependencies {
  const HomeCategoryDependencies({
    this.hangulLessonRepository,
    this.alphabetLessonRepository,
    this.numbersLessonRepository,
  });

  final HangulLessonRepository? hangulLessonRepository;
  final AlphabetLessonRepository? alphabetLessonRepository;
  final NumbersLessonRepository? numbersLessonRepository;
}

class HomeCategoryConfig {
  const HomeCategoryConfig({
    required this.id,
    required this.badgeText,
    required this.stickerText,
    required this.homeDescription,
    required this.hubDescription,
    required this.compactDescription,
    this.learnScreenBuilder,
    this.gameScreenBuilder,
  });

  final String id;
  final String badgeText;
  final String stickerText;
  final String homeDescription;
  final String hubDescription;
  final String compactDescription;
  final HomeCategoryScreenBuilder? learnScreenBuilder;
  final HomeCategoryScreenBuilder? gameScreenBuilder;

  bool get supportsLearnMode => learnScreenBuilder != null;

  bool get supportsGameMode => gameScreenBuilder != null;

  static HomeCategoryConfig resolve(HomeCategory category) {
    return _knownConfigs[category.id] ??
        HomeCategoryConfig(
          id: category.id,
          badgeText: '놀이',
          stickerText: 'PLAY',
          homeDescription: category.description,
          hubDescription: category.description,
          compactDescription: category.description,
        );
  }
}

final Map<String, HomeCategoryConfig> _knownConfigs = {
  'hangul': HomeCategoryConfig(
    id: 'hangul',
    badgeText: '자모',
    stickerText: '또박',
    homeDescription: '자모 소리',
    hubDescription: '자모 소리를 또박또박 익혀요.',
    compactDescription: '자모 소리',
    learnScreenBuilder: _buildHangulLearnScreen,
    gameScreenBuilder: _buildHangulQuizScreen,
  ),
  'alphabet': HomeCategoryConfig(
    id: 'alphabet',
    badgeText: 'ABC',
    stickerText: 'A a',
    homeDescription: 'A a B b',
    hubDescription: 'A부터 차분하게 읽어봐요.',
    compactDescription: 'A a B b',
    learnScreenBuilder: _buildAlphabetLearnScreen,
    gameScreenBuilder: _buildAlphabetQuizScreen,
  ),
  'numbers': HomeCategoryConfig(
    id: 'numbers',
    badgeText: '1 2 3',
    stickerText: '하나둘',
    homeDescription: '세고 맞혀요',
    hubDescription: '숫자를 세고 바로 맞혀요.',
    compactDescription: '세고 맞혀요',
    learnScreenBuilder: _buildNumbersLearnScreen,
    gameScreenBuilder: _buildNumbersQuizScreen,
  ),
};

Widget _buildHangulLearnScreen(HomeCategoryDependencies dependencies) {
  return HangulLearnScreen(repository: dependencies.hangulLessonRepository);
}

Widget _buildHangulQuizScreen(HomeCategoryDependencies dependencies) {
  return HangulQuizScreen(repository: dependencies.hangulLessonRepository);
}

Widget _buildAlphabetLearnScreen(HomeCategoryDependencies dependencies) {
  return AlphabetLearnScreen(repository: dependencies.alphabetLessonRepository);
}

Widget _buildAlphabetQuizScreen(HomeCategoryDependencies dependencies) {
  return AlphabetQuizScreen(repository: dependencies.alphabetLessonRepository);
}

Widget _buildNumbersLearnScreen(HomeCategoryDependencies dependencies) {
  return NumbersLearnScreen(repository: dependencies.numbersLessonRepository);
}

Widget _buildNumbersQuizScreen(HomeCategoryDependencies dependencies) {
  return NumbersQuizScreen(repository: dependencies.numbersLessonRepository);
}
