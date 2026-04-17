import 'lesson.dart';

/// Share of correct answers that earns a reward sticker.
const double kQuizStickerThreshold = 0.8;

/// Returns the questions the quiz should ask. Defaults to the full lesson,
/// but if [mistakeSymbols] is non-empty the deck is filtered to only the
/// items whose symbol matches a remembered mistake.
List<LessonItem> resolveQuizQuestions(
  List<LessonItem> items, {
  List<String>? mistakeSymbols,
}) {
  if (mistakeSymbols == null || mistakeSymbols.isEmpty) {
    return items;
  }
  return items
      .where((item) => mistakeSymbols.contains(item.symbol))
      .toList(growable: false);
}

/// Builds a 4-way answer set that always contains [answer], spreading the
/// distractors deterministically so tests can predict the layout.
List<LessonItem> buildChoices(
  List<LessonItem> pool,
  LessonItem answer,
  int questionIndex,
) {
  final distractors = pool
      .where((item) => item.symbol != answer.symbol)
      .toList(growable: false);
  if (distractors.isEmpty) {
    return [answer];
  }

  final startIndex = questionIndex % distractors.length;
  final rotated = <LessonItem>[
    ...distractors.skip(startIndex),
    ...distractors.take(startIndex),
  ];
  final choices = rotated.take(3).toList(growable: true);
  choices.insert(questionIndex % 4, answer);
  return choices;
}

/// Whether the given score earns the lesson sticker.
bool earnedSticker(int correctCount, int totalQuestions) {
  if (totalQuestions <= 0) {
    return false;
  }
  final threshold = (totalQuestions * kQuizStickerThreshold).ceil();
  return correctCount >= threshold;
}
