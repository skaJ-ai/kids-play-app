import 'package:flutter/material.dart';

import '../../../app/ui/kid_theme.dart';
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
import 'lesson_picker_screen.dart';

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
    required this.accentColor,
    required this.badgeText,
    required this.stickerText,
    required this.homeDescription,
    required this.hubDescription,
    required this.compactDescription,
    this.learnScreenBuilder,
    this.gameScreenBuilder,
  });

  final String id;
  final Color accentColor;
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
          accentColor: KidPalette.navy,
          badgeText: '놀이',
          stickerText: '놀이',
          homeDescription: category.description,
          hubDescription: category.description,
          compactDescription: category.description,
        );
  }
}

final Map<String, HomeCategoryConfig> _knownConfigs = {
  'hangul': HomeCategoryConfig(
    id: 'hangul',
    accentColor: KidPalette.yellowDark,
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
    accentColor: KidPalette.blue,
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
    accentColor: KidPalette.coralDark,
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
  final repository = dependencies.hangulLessonRepository ?? HangulLessonRepository();
  return AsyncLessonPickerScreen(
    categoryLabel: '한글',
    modeLabel: '배우기',
    errorMessage: '한글 세트를 불러오지 못했어요.',
    emptyMessage: '준비 중인 한글 세트예요.',
    loadItems: () async {
      final lessons = await repository.loadLessons();
      return lessons
          .map(
            (lesson) => LessonPickerItem(
              id: lesson.id,
              title: lesson.title,
              preview: lesson.cards.take(3).map((card) => card.symbol).join(' · '),
              countLabel: '${lesson.cards.length}개',
              color: Colors.amber.shade700,
            ),
          )
          .toList(growable: false);
    },
    buildDestination: (lessonId) {
      return HangulLearnScreen(repository: repository, lessonId: lessonId);
    },
  );
}

Widget _buildHangulQuizScreen(HomeCategoryDependencies dependencies) {
  final repository = dependencies.hangulLessonRepository ?? HangulLessonRepository();
  return AsyncLessonPickerScreen(
    categoryLabel: '한글',
    modeLabel: '퀴즈',
    errorMessage: '한글 퀴즈 세트를 불러오지 못했어요.',
    emptyMessage: '준비 중인 한글 퀴즈 세트예요.',
    loadItems: () async {
      final lessons = await repository.loadLessons();
      return lessons
          .map(
            (lesson) => LessonPickerItem(
              id: lesson.id,
              title: lesson.title,
              preview: lesson.cards.take(3).map((card) => card.symbol).join(' · '),
              countLabel: '${lesson.cards.length}문제',
              color: Colors.amber.shade700,
            ),
          )
          .toList(growable: false);
    },
    buildDestination: (lessonId) {
      return HangulQuizScreen(repository: repository, lessonId: lessonId);
    },
  );
}

Widget _buildAlphabetLearnScreen(HomeCategoryDependencies dependencies) {
  final repository =
      dependencies.alphabetLessonRepository ?? AlphabetLessonRepository();
  return AsyncLessonPickerScreen(
    categoryLabel: '알파벳',
    modeLabel: '배우기',
    errorMessage: '알파벳 세트를 불러오지 못했어요.',
    emptyMessage: '준비 중인 알파벳 세트예요.',
    loadItems: () async {
      final lessons = await repository.loadLessons();
      return lessons
          .map(
            (lesson) => LessonPickerItem(
              id: lesson.id,
              title: lesson.title,
              preview: lesson.cards.take(3).map((card) => card.symbol).join(' · '),
              countLabel: '${lesson.cards.length}개',
              color: Colors.lightBlue.shade700,
            ),
          )
          .toList(growable: false);
    },
    buildDestination: (lessonId) {
      return AlphabetLearnScreen(repository: repository, lessonId: lessonId);
    },
  );
}

Widget _buildAlphabetQuizScreen(HomeCategoryDependencies dependencies) {
  final repository =
      dependencies.alphabetLessonRepository ?? AlphabetLessonRepository();
  return AsyncLessonPickerScreen(
    categoryLabel: '알파벳',
    modeLabel: '퀴즈',
    errorMessage: '알파벳 퀴즈 세트를 불러오지 못했어요.',
    emptyMessage: '준비 중인 알파벳 퀴즈 세트예요.',
    loadItems: () async {
      final lessons = await repository.loadLessons();
      return lessons
          .map(
            (lesson) => LessonPickerItem(
              id: lesson.id,
              title: lesson.title,
              preview: lesson.cards.take(3).map((card) => card.symbol).join(' · '),
              countLabel: '${lesson.cards.length}문제',
              color: Colors.lightBlue.shade700,
            ),
          )
          .toList(growable: false);
    },
    buildDestination: (lessonId) {
      return AlphabetQuizScreen(repository: repository, lessonId: lessonId);
    },
  );
}

Widget _buildNumbersLearnScreen(HomeCategoryDependencies dependencies) {
  final repository =
      dependencies.numbersLessonRepository ?? NumbersLessonRepository();
  return AsyncLessonPickerScreen(
    categoryLabel: '숫자',
    modeLabel: '배우기',
    errorMessage: '숫자 세트를 불러오지 못했어요.',
    emptyMessage: '준비 중인 숫자 세트예요.',
    loadItems: () async {
      final lessons = await repository.loadLessons();
      return lessons
          .map(
            (lesson) => LessonPickerItem(
              id: lesson.id,
              title: lesson.title,
              preview: lesson.cards.take(3).map((card) => card.symbol).join(' · '),
              countLabel: '${lesson.cards.length}개',
              color: Colors.pink.shade600,
            ),
          )
          .toList(growable: false);
    },
    buildDestination: (lessonId) {
      return NumbersLearnScreen(repository: repository, lessonId: lessonId);
    },
  );
}

Widget _buildNumbersQuizScreen(HomeCategoryDependencies dependencies) {
  final repository =
      dependencies.numbersLessonRepository ?? NumbersLessonRepository();
  return AsyncLessonPickerScreen(
    categoryLabel: '숫자',
    modeLabel: '퀴즈',
    errorMessage: '숫자 퀴즈 세트를 불러오지 못했어요.',
    emptyMessage: '준비 중인 숫자 퀴즈 세트예요.',
    loadItems: () async {
      final lessons = await repository.loadLessons();
      return lessons
          .map(
            (lesson) => LessonPickerItem(
              id: lesson.id,
              title: lesson.title,
              preview: lesson.cards.take(3).map((card) => card.symbol).join(' · '),
              countLabel: '${lesson.cards.length}문제',
              color: Colors.pink.shade600,
            ),
          )
          .toList(growable: false);
    },
    buildDestination: (lessonId) {
      return NumbersQuizScreen(repository: repository, lessonId: lessonId);
    },
  );
}
