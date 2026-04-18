import '../data/numbers_lesson_repository.dart';

class NumbersQuizAnswerResult {
  const NumbersQuizAnswerResult({
    required this.isCorrect,
    required this.session,
  });

  final bool isCorrect;
  final NumbersQuizSession session;
}

class NumbersQuizCompletionRecord {
  const NumbersQuizCompletionRecord({
    required this.lessonId,
    required this.correctCount,
    required this.totalQuestions,
    required this.recentMistakes,
    required this.stickersEarned,
    required this.rewardEarnedAt,
  });

  final String lessonId;
  final int correctCount;
  final int totalQuestions;
  final List<String> recentMistakes;
  final int stickersEarned;
  final DateTime? rewardEarnedAt;
}

class NumbersQuizSession {
  NumbersQuizSession._({
    required this.cards,
    required this.quizCards,
    this.questionIndex = 0,
    this.correctCount = 0,
    this.isComplete = false,
    this.recentMistakes = const [],
  });

  factory NumbersQuizSession.start({
    required List<NumbersCard> cards,
    List<String>? mistakeSymbols,
  }) {
    final quizCards = _resolvedQuizCards(cards, mistakeSymbols);
    return NumbersQuizSession._(
      cards: List<NumbersCard>.unmodifiable(cards),
      quizCards: List<NumbersCard>.unmodifiable(quizCards),
    );
  }

  final List<NumbersCard> cards;
  final List<NumbersCard> quizCards;
  final int questionIndex;
  final int correctCount;
  final bool isComplete;
  final List<String> recentMistakes;

  int get totalQuestions => quizCards.length;

  NumbersCard get currentQuestion => quizCards[questionIndex];

  bool get earnedSticker =>
      totalQuestions > 0 && correctCount >= (totalQuestions * 0.8).ceil();

  NumbersQuizSession restart() {
    return NumbersQuizSession._(cards: cards, quizCards: quizCards);
  }

  NumbersQuizCompletionRecord? completedQuizRecord({
    required String lessonId,
    required DateTime completedAt,
  }) {
    if (!isComplete) {
      return null;
    }

    return NumbersQuizCompletionRecord(
      lessonId: 'numbers:$lessonId',
      correctCount: correctCount,
      totalQuestions: totalQuestions,
      recentMistakes: recentMistakes,
      stickersEarned: earnedSticker ? 1 : 0,
      rewardEarnedAt: earnedSticker ? completedAt : null,
    );
  }

  List<NumbersCard> currentChoices() {
    final answer = currentQuestion;
    final distractors = cards
        .where((card) => card.symbol != answer.symbol)
        .toList(growable: false);
    final startIndex = distractors.isEmpty
        ? 0
        : questionIndex % distractors.length;
    final rotatedDistractors = [
      ...distractors.skip(startIndex),
      ...distractors.take(startIndex),
    ];
    final choices = rotatedDistractors.take(3).toList(growable: true);
    choices.insert(questionIndex % 4, answer);
    return List<NumbersCard>.unmodifiable(choices);
  }

  NumbersQuizAnswerResult answer(NumbersCard choice) {
    final isCorrect = choice.symbol == currentQuestion.symbol;
    final nextCorrectCount = isCorrect ? correctCount + 1 : correctCount;
    final nextMistakes = isCorrect
        ? recentMistakes
        : List<String>.unmodifiable([
            ...recentMistakes,
            currentQuestion.symbol,
          ]);
    final isLastQuestion = questionIndex == totalQuestions - 1;

    return NumbersQuizAnswerResult(
      isCorrect: isCorrect,
      session: _copyWith(
        questionIndex: isLastQuestion ? 0 : questionIndex + 1,
        correctCount: nextCorrectCount,
        isComplete: isLastQuestion,
        recentMistakes: nextMistakes,
      ),
    );
  }

  NumbersQuizSession _copyWith({
    int? questionIndex,
    int? correctCount,
    bool? isComplete,
    List<String>? recentMistakes,
  }) {
    return NumbersQuizSession._(
      cards: cards,
      quizCards: quizCards,
      questionIndex: questionIndex ?? this.questionIndex,
      correctCount: correctCount ?? this.correctCount,
      isComplete: isComplete ?? this.isComplete,
      recentMistakes: recentMistakes ?? this.recentMistakes,
    );
  }

  static List<NumbersCard> _resolvedQuizCards(
    List<NumbersCard> cards,
    List<String>? mistakeSymbols,
  ) {
    if (mistakeSymbols == null || mistakeSymbols.isEmpty) {
      return cards;
    }

    return cards
        .where((card) => mistakeSymbols.contains(card.symbol))
        .toList(growable: false);
  }
}
