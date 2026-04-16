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
    required this.compactDescription,
    this.learnScreenBuilder,
    this.gameScreenBuilder,
  });

  final String id;
  final String badgeText;
  final String stickerText;
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
          compactDescription: category.description,
        );
  }
}

final Map<String, HomeCategoryConfig> _knownConfigs = {
  'hangul': HomeCategoryConfig(
    id: 'hangul',
    badgeText: '가장 먼저',
    stickerText: '또박또박',
    compactDescription: '자음과 모음',
    learnScreenBuilder: _buildHangulLearnScreen,
    gameScreenBuilder: _buildHangulQuizScreen,
  ),
  'alphabet': HomeCategoryConfig(
    id: 'alphabet',
    badgeText: 'ABC',
    stickerText: 'ABC 놀이',
    compactDescription: '대문자와 소문자',
    learnScreenBuilder: _buildAlphabetLearnScreen,
    gameScreenBuilder: _buildAlphabetQuizScreen,
  ),
  'numbers': HomeCategoryConfig(
    id: 'numbers',
    badgeText: '1 2 3',
    stickerText: '숫자놀이',
    compactDescription: '숫자 개념 놀이',
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
