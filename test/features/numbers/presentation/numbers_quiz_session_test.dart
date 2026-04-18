import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/features/numbers/data/numbers_lesson_repository.dart';
import 'package:kids_play_app/features/numbers/presentation/numbers_quiz_session.dart';

void main() {
  test(
    'starts a mistake replay session with only the requested quiz cards',
    () {
      final session = NumbersQuizSession.start(
        cards: _cards,
        mistakeSymbols: const ['2', '5'],
      );

      expect(session.totalQuestions, 2);
      expect(
        session.quizCards.map((card) => card.symbol).toList(growable: false),
        ['2', '5'],
      );
      expect(session.currentQuestion.symbol, '2');
      expect(session.isComplete, isFalse);
    },
  );

  test('records a correct answer and advances to the next question', () {
    final session = NumbersQuizSession.start(cards: _cards);

    final result = session.answer(_cards.first);

    expect(result.isCorrect, isTrue);
    expect(result.session.correctCount, 1);
    expect(result.session.questionIndex, 1);
    expect(result.session.currentQuestion.symbol, '2');
    expect(result.session.recentMistakes, isEmpty);
    expect(result.session.isComplete, isFalse);
  });

  test('builds deterministic choices from the current question index', () {
    final session = NumbersQuizSession.start(cards: _cards);

    final advancedSession = session.answer(_cards.first).session;

    expect(
      advancedSession.currentChoices().map((card) => card.symbol).toList(),
      ['3', '2', '4', '5'],
    );
  });

  test('marks the session complete after five correct answers', () {
    var session = NumbersQuizSession.start(cards: _cards);

    for (final choice in _cards) {
      session = session.answer(choice).session;
    }

    expect(session.isComplete, isTrue);
    expect(session.correctCount, 5);
    expect(session.totalQuestions, 5);
    expect(session.earnedSticker, isTrue);
  });

  test('restart clears progress while keeping the same quiz cards', () {
    final session = NumbersQuizSession.start(
      cards: _cards,
      mistakeSymbols: const ['2', '5'],
    );
    final advancedSession = session.answer(_cards[1]).session;

    final restartedSession = advancedSession.restart();

    expect(restartedSession.questionIndex, 0);
    expect(restartedSession.correctCount, 0);
    expect(restartedSession.recentMistakes, isEmpty);
    expect(
      restartedSession.quizCards
          .map((card) => card.symbol)
          .toList(growable: false),
      ['2', '5'],
    );
  });

  test('completes a one-question replay and records the missed symbol', () {
    final session = NumbersQuizSession.start(
      cards: _cards,
      mistakeSymbols: const ['5'],
    );

    final result = session.answer(_cards.first);

    expect(result.isCorrect, isFalse);
    expect(result.session.isComplete, isTrue);
    expect(result.session.questionIndex, 0);
    expect(result.session.correctCount, 0);
    expect(result.session.recentMistakes, ['5']);
    expect(result.session.earnedSticker, isFalse);
  });
}

const _cards = [
  NumbersCard(symbol: '1', label: '하나, 1', hint: '하나'),
  NumbersCard(symbol: '2', label: '둘, 2', hint: '둘'),
  NumbersCard(symbol: '3', label: '셋, 3', hint: '셋'),
  NumbersCard(symbol: '4', label: '넷, 4', hint: '넷'),
  NumbersCard(symbol: '5', label: '다섯, 5', hint: '다섯'),
];
