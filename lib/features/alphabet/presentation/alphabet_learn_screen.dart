import 'package:flutter/material.dart';

import '../../lesson/domain/lesson_category.dart';
import '../../lesson/presentation/generic_learn_screen.dart';
import '../data/alphabet_lesson_repository.dart';

class AlphabetLearnScreen extends StatelessWidget {
  const AlphabetLearnScreen({
    super.key,
    this.repository,
    this.lessonId = 'alphabet_letters_1',
  });

  final AlphabetLessonRepository? repository;
  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? AlphabetLessonRepository();
    return GenericLearnScreen(
      loader: repo.contentLoader,
      category: alphabetLessonCategory,
      lessonId: lessonId,
      errorMessage: '알파벳 카드를 불러오지 못했어요.',
      emptyMessage: '준비 중인 알파벳 카드예요.',
    );
  }
}
