import 'package:flutter/foundation.dart';

import '../../../app/services/app_services.dart';
import '../domain/lesson.dart';
import '../domain/lesson_category.dart';
import '../domain/quiz_rules.dart';

/// Drives the lesson quiz state machine.
///
/// Pure answer bookkeeping lives in [QuizController], so the generic quiz
/// screen renders whatever the controller exposes and the controller can be
/// tested with a fake [AppServices].
class QuizController extends ChangeNotifier {
  QuizController({
    required AppServices services,
    required this.category,
    required this.lessonId,
    required List<LessonItem> questions,
    required List<LessonItem> pool,
  }) : _services = services,
       _questions = questions,
       _pool = pool;

  final AppServices _services;
  final LessonCategoryConfig category;
  final String lessonId;
  final List<LessonItem> _questions;
  final List<LessonItem> _pool;

  int _questionIndex = 0;
  int _correctCount = 0;
  bool _isComplete = false;
  bool _feedbackVisible = false;
  bool _feedbackCorrect = false;
  bool _isResolvingChoice = false;
  List<String> _recentMistakes = const [];
  bool _disposed = false;

  List<LessonItem> get questions => _questions;
  List<LessonItem> get pool => _pool;
  int get questionIndex => _questionIndex;
  int get correctCount => _correctCount;
  int get totalQuestions => _questions.length;
  bool get isComplete => _isComplete;
  bool get feedbackVisible => _feedbackVisible;
  bool get feedbackCorrect => _feedbackCorrect;
  bool get isResolvingChoice => _isResolvingChoice;
  List<String> get recentMistakes => _recentMistakes;

  LessonItem get currentQuestion => _questions[_questionIndex];
  List<LessonItem> get currentChoices =>
      buildChoices(_pool, currentQuestion, _questionIndex);
  bool get earnedLessonSticker => earnedSticker(_correctCount, totalQuestions);

  String promptKeyFor(LessonItem question) =>
      '$lessonId:${question.symbol}:$_questionIndex';

  Future<void> replayPrompt() async {
    final snapshot = await _services.progressStore.loadSnapshot();
    if (!snapshot.voicePromptsEnabled) {
      return;
    }
    await _services.speechCueService.speak(
      category.promptFor(currentQuestion.symbol),
      locale: 'ko-KR',
    );
  }

  Future<void> selectChoice(LessonItem choice) async {
    if (_isResolvingChoice || _isComplete) {
      return;
    }
    _isResolvingChoice = true;

    final settings = await _services.progressStore.loadSnapshot();
    final answer = currentQuestion;
    final isCorrect = choice.symbol == answer.symbol;
    final nextCorrectCount = isCorrect ? _correctCount + 1 : _correctCount;
    final nextMistakes = isCorrect
        ? _recentMistakes
        : <String>[..._recentMistakes, answer.symbol];

    _correctCount = nextCorrectCount;
    _recentMistakes = nextMistakes;
    _feedbackCorrect = isCorrect;
    _feedbackVisible = settings.effectsEnabled;
    _notify();

    if (settings.voicePromptsEnabled) {
      await _services.speechCueService.speak(
        isCorrect ? '딩동댕' : '다시 해보자',
        locale: 'ko-KR',
        rate: 0.46,
        pitch: isCorrect ? 1.08 : 0.94,
      );
    }

    await Future<void>.delayed(
      Duration(milliseconds: settings.effectsEnabled ? 650 : 220),
    );
    if (_disposed) {
      return;
    }

    final isLastQuestion = _questionIndex == totalQuestions - 1;
    if (isLastQuestion) {
      if (earnedSticker(nextCorrectCount, totalQuestions)) {
        await _services.progressStore.addStickers(1);
      }
      await _services.progressStore.recordQuizResult(
        lessonId: category.progressIdFor(lessonId),
        correctCount: nextCorrectCount,
        totalQuestions: totalQuestions,
        recentMistakes: nextMistakes,
      );
      if (_disposed) {
        return;
      }
      _feedbackVisible = false;
      _isResolvingChoice = false;
      _isComplete = true;
      _notify();
      return;
    }

    _questionIndex += 1;
    _feedbackVisible = false;
    _isResolvingChoice = false;
    _notify();
  }

  void restart() {
    _questionIndex = 0;
    _correctCount = 0;
    _isComplete = false;
    _feedbackVisible = false;
    _feedbackCorrect = false;
    _isResolvingChoice = false;
    _recentMistakes = const [];
    _notify();
  }

  void _notify() {
    if (_disposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
