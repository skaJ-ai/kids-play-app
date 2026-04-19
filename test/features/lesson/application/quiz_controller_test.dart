import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/audio/audio_cue.dart';
import 'package:kids_play_app/app/audio/audio_service.dart';
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

class _RecordingAudioService implements AudioService {
  final List<AudioCue> played = <AudioCue>[];
  bool _isMuted = false;

  @override
  bool get isMuted => _isMuted;

  @override
  set isMuted(bool value) => _isMuted = value;

  @override
  Future<void> play(AudioCue cue) async {
    played.add(cue);
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
  _RecordingAudioService? audioService,
  List<LessonItem>? questions,
}) {
  final store = MemoryProgressStore(initialSnapshot);
  final services = AppServices(
    progressStore: store,
    speechCueService: speech ?? _RecordingSpeech(),
    audioService: audioService,
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
    'marks the quiz complete on the last question and awards a sticker',
    () async {
      final store = MemoryProgressStore();
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

      for (var i = 0; i < _items.length; i++) {
        await controller.selectChoice(controller.currentQuestion);
      }

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

  test('replayPrompt routes prompt playback through AudioService', () async {
    final speech = _RecordingSpeech();
    final audioService = _RecordingAudioService();
    final controller = _buildController(
      speech: speech,
      audioService: audioService,
    );

    await controller.replayPrompt();

    expect(speech.spoken, isEmpty);
    expect(audioService.played, hasLength(1));
  });

  test(
    'replayPrompt builds stable prompt metadata for the current question',
    () async {
      final speech = _RecordingSpeech();
      final audioService = _RecordingAudioService();
      final controller = _buildController(
        speech: speech,
        audioService: audioService,
      );

      await controller.replayPrompt();

      expect(
        audioService.played.single,
        isA<PromptCue>()
            .having(
              (cue) => cue.ref.assetPath,
              'assetPath',
              'assets/generated/audio/voice/prompts/alphabet/alphabet_letters_1_quiz_a.mp3',
            )
            .having(
              (cue) => cue.ref.fallbackText,
              'fallbackText',
              _category.promptFor('A'),
            ),
      );
      expect(speech.spoken, isEmpty);
    },
  );

  test(
    'replayPrompt falls back to item_<index> when slug normalization is empty',
    () async {
      final speech = _RecordingSpeech();
      final audioService = _RecordingAudioService();
      final controller = _buildController(
        speech: speech,
        audioService: audioService,
        questions: const [LessonItem(symbol: '!!!', label: '!!!', hint: '')],
      );

      await controller.replayPrompt();

      expect(
        audioService.played.single,
        isA<PromptCue>()
            .having(
              (cue) => cue.ref.assetPath,
              'assetPath',
              'assets/generated/audio/voice/prompts/alphabet/alphabet_letters_1_quiz_item_1.mp3',
            )
            .having(
              (cue) => cue.ref.fallbackText,
              'fallbackText',
              _category.promptFor('!!!'),
            ),
      );
      expect(speech.spoken, isEmpty);
    },
  );
}
