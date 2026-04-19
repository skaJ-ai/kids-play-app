import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/features/lesson/application/quiz_controller.dart';
import 'package:kids_play_app/features/lesson/domain/lesson.dart';
import 'package:kids_play_app/features/lesson/domain/lesson_category.dart';

class _RecordingSpeech implements SpeechCueService {
  final List<String> spoken = [];

  @override
  Future<void> speak(
    String text, {
    String locale = 'ko-KR',
    double rate = 0.42,
    double pitch = 1.0,
  }) async {
    spoken.add(text);
  }

  @override
  Future<void> stop() async {}
}

const _category = alphabetLessonCategory;

final _items = [
  const LessonItem(symbol: 'A', label: 'A', hint: ''),
  const LessonItem(symbol: 'B', label: 'B', hint: ''),
  const LessonItem(symbol: 'C', label: 'C', hint: ''),
  const LessonItem(symbol: 'D', label: 'D', hint: ''),
];

QuizController _buildController({
  AppProgressSnapshot? initialSnapshot,
  _RecordingSpeech? speech,
  List<LessonItem>? questions,
}) {
  final store = MemoryProgressStore(initialSnapshot);
  final services = AppServices(
    progressStore: store,
    speechCueService: speech ?? _RecordingSpeech(),
  );
  return QuizController(
    services: services,
    category: _category,
    lessonId: 'alphabet_letters_1',
    questions: questions ?? _items,
    pool: _items,
  );
}

void main() {
  test(
    'advances question index after a wrong answer and tracks the mistake',
    () async {
      final controller = _buildController();
      final wrongChoice = _items[1]; // first question answer is A

      expect(controller.isResolvingChoice, isFalse);
      await controller.selectChoice(wrongChoice);

      expect(controller.questionIndex, 1);
      expect(controller.correctCount, 0);
      expect(controller.recentMistakes, ['A']);
      expect(controller.isResolvingChoice, isFalse);
      expect(controller.feedbackVisible, isFalse);
    },
  );

  test('increments correctCount on right answer', () async {
    final controller = _buildController();
    await controller.selectChoice(controller.currentQuestion);
    expect(controller.correctCount, 1);
    expect(controller.recentMistakes, isEmpty);
    expect(controller.questionIndex, 1);
  });

  test(
    'marks the quiz complete on the last question, awards a sticker, and persists the recent reward snapshot',
    () async {
      final store = MemoryProgressStore(
        const AppProgressSnapshot(
          voicePromptsEnabled: false,
          effectsEnabled: false,
        ),
      );
      final services = AppServices(
        progressStore: store,
        speechCueService: _RecordingSpeech(),
      );
      final controller = QuizController(
        services: services,
        category: _category,
        lessonId: 'alphabet_letters_1',
        questions: _items,
        pool: _items,
      );

      for (var i = 0; i < _items.length - 1; i++) {
        await controller.selectChoice(controller.currentQuestion);
      }
      final completionStartedAt = DateTime.now();
      await controller.selectChoice(controller.currentQuestion);
      final completionFinishedAt = DateTime.now();

      expect(controller.isComplete, isTrue);
      expect(controller.correctCount, 4);
      expect(controller.earnedLessonSticker, isTrue);

      final snapshot = await store.loadSnapshot();
      expect(snapshot.stickerCount, 1);
      expect(
        snapshot
            .progressFor(_category.progressIdFor('alphabet_letters_1'))
            .bestScore,
        4,
      );
      expect(snapshot.lastEarnedReward, isNotNull);
      expect(snapshot.lastEarnedReward!.kind, 'sticker');
      expect(snapshot.lastEarnedReward!.amount, 1);
      expect(snapshot.lastEarnedReward!.earnedAt.isUtc, isTrue);
      expect(
        snapshot.lastEarnedReward!.lessonId,
        _category.progressIdFor('alphabet_letters_1'),
      );
      expect(
        snapshot.lastEarnedReward!.earnedAt.isBefore(
          completionStartedAt.toUtc(),
        ),
        isFalse,
      );
      expect(
        snapshot.lastEarnedReward!.earnedAt.isAfter(completionFinishedAt),
        isFalse,
      );
    },
  );

  test(
    'mistake replay completion preserves full-lesson stats, increments replay count, and records a replay reward kind',
    () async {
      final progressLessonId = _category.progressIdFor('alphabet_letters_1');
      final store = MemoryProgressStore(
        AppProgressSnapshot(
          voicePromptsEnabled: false,
          effectsEnabled: false,
          lessons: {
            progressLessonId: const LessonProgress(
              bestScore: 4,
              totalQuestions: 5,
              lastViewedIndex: 4,
              recentMistakes: ['A'],
              mistakeReplayCount: 1,
            ),
          },
        ),
      );
      final services = AppServices(
        progressStore: store,
        speechCueService: _RecordingSpeech(),
      );
      final controller = QuizController(
        services: services,
        category: _category,
        lessonId: 'alphabet_letters_1',
        questions: [_items.first],
        pool: _items,
        isMistakeReplay: true,
      );

      await controller.selectChoice(controller.currentQuestion);

      final snapshot = await store.loadSnapshot();
      final progress = snapshot.progressFor(progressLessonId);
      expect(progress.bestScore, 4);
      expect(progress.totalQuestions, 5);
      expect(progress.recentMistakes, isEmpty);
      expect(progress.mistakeReplayCount, 2);
      expect(snapshot.stickerCount, 1);
      expect(snapshot.replayRewardStickerCount, 1);
      expect(snapshot.replayRewardStickerCountTracked, isTrue);
      expect(snapshot.lastEarnedReward, isNotNull);
      expect(snapshot.lastEarnedReward!.kind, 'mistakeReplaySticker');
    },
  );

  test('skips speech when voice prompts are disabled', () async {
    final speech = _RecordingSpeech();
    final controller = _buildController(
      initialSnapshot: const AppProgressSnapshot(voicePromptsEnabled: false),
      speech: speech,
    );

    await controller.selectChoice(controller.currentQuestion);
    expect(speech.spoken, isEmpty);
  });

  test(
    'selectChoice is reentrancy-safe while one choice is still resolving',
    () async {
      final controller = _buildController();
      final first = controller.selectChoice(controller.currentQuestion);
      // Immediately fire another tap — this one must be dropped.
      await controller.selectChoice(_items[1]);
      await first;

      expect(controller.questionIndex, 1);
      expect(controller.correctCount, 1);
    },
  );

  test('restart resets state', () async {
    final controller = _buildController();
    await controller.selectChoice(_items[1]); // wrong
    expect(controller.recentMistakes, ['A']);

    controller.restart();
    expect(controller.questionIndex, 0);
    expect(controller.correctCount, 0);
    expect(controller.recentMistakes, isEmpty);
    expect(controller.isComplete, isFalse);
  });

  test(
    'replayPrompt routes category-formatted text to the speech service',
    () async {
      final speech = _RecordingSpeech();
      final controller = _buildController(speech: speech);
      await controller.replayPrompt();
      expect(speech.spoken.single, contains("'A'"));
    },
  );
}
