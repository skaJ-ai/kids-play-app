import 'package:flutter/material.dart';

import '../../lesson/domain/lesson_category.dart';
import '../../lesson/presentation/generic_quiz_screen.dart';
import '../data/alphabet_lesson_repository.dart';

class AlphabetQuizScreen extends StatelessWidget {
  const AlphabetQuizScreen({
    super.key,
    this.repository,
    this.lessonId = 'alphabet_letters_1',
    this.mistakeSymbols,
  });

  final AlphabetLessonRepository? repository;
  final String lessonId;
  final List<String>? mistakeSymbols;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? AlphabetLessonRepository();
    return GenericQuizScreen(
      loader: repo.contentLoader,
      category: alphabetLessonCategory,
      lessonId: lessonId,
      mistakeSymbols: mistakeSymbols,
      errorMessage: '알파벳 게임을 불러오지 못했어요.',
      notEnoughItemsMessage: '퀴즈 카드가 아직 부족해요.',
      noMistakesMessage: '다시 풀 오답이 없어요.',
    );
  }
}
