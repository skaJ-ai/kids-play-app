import 'package:flutter/foundation.dart';

import '../../../app/audio/audio_cue.dart';
import '../../../app/services/app_services.dart';
import '../../../app/services/progress_store.dart';
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
    this.isMistakeReplay = false,
  }) : _services = services,
       _questions = questions,
       _pool = pool;

  final AppServices _services;
  final LessonCategoryConfig category;
  final String lessonId;
  final bool isMistakeReplay;
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

  PromptCue _promptCueFor(LessonItem question, int questionIndex) {
    final slug = _promptSlugFor(question.symbol, questionIndex);
    return PromptCue(
      AudioCueRef(
        assetPath:
            'assets/generated/audio/voice/prompts/${category.id}/${lessonId}_quiz_$slug.mp3',
        fallbackText: category.promptFor(question.symbol),
      ),
    );
  }

  String _promptSlugFor(String symbol, int questionIndex) {
    final slug = symbol
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_-]'), '');
    if (slug.isEmpty) {
      return 'item_${questionIndex + 1}';
    }
    return slug;
  }

  Future<void> replayPrompt() async {
    final snapshot = await _services.progressStore.loadSnapshot();
    if (!snapshot.voicePromptsEnabled) {
      return;
    }
    await _services.audioService.play(
      _promptCueFor(currentQuestion, _questionIndex),
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

    if (settings.effectsEnabled) {
      await _services.audioService.play(
        isCorrect ? const SuccessCue() : const ErrorCue(),
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
      final progressLessonId = category.progressIdFor(lessonId);
      final completedAt = DateTime.now().toUtc();
      final stickersEarned = earnedSticker(nextCorrectCount, totalQuestions)
          ? 1
          : 0;

      await _services.progressStore.recordCompletedQuiz(
        lessonId: progressLessonId,
        correctCount: nextCorrectCount,
        totalQuestions: totalQuestions,
        recentMistakes: nextMistakes,
        stickersEarned: stickersEarned,
        rewardEarnedAt: stickersEarned > 0 ? completedAt : null,
        rewardKind: isMistakeReplay
            ? rewardKindMistakeReplaySticker
            : rewardKindSticker,
        isMistakeReplay: isMistakeReplay,
      );
      if (_disposed) {
        return;
      }
      if (settings.effectsEnabled && stickersEarned > 0) {
        await _services.audioService.play(RewardCue(AudioPackId(category.id)));
        if (_disposed) {
          return;
        }
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
