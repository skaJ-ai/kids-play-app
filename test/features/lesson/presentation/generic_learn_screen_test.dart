import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/audio/audio_cue.dart';
import 'package:kids_play_app/app/audio/audio_service.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';
import 'package:kids_play_app/features/lesson/data/lesson_content_loader.dart';
import 'package:kids_play_app/features/lesson/domain/lesson.dart';
import 'package:kids_play_app/features/lesson/domain/lesson_category.dart';
import 'package:kids_play_app/features/lesson/presentation/generic_learn_screen.dart';

void main() {
  testWidgets(
    'queued prompt playback uses AudioService with stable alphabet prompt metadata',
    (WidgetTester tester) async {
      final audioService = _RecordingAudioService();
      final speechCueService = _RecordingSpeechCueService();

      await tester.pumpWidget(
        _wrapWithServices(
          audioService: audioService,
          speechCueService: speechCueService,
          child: GenericLearnScreen(
            loader: _FakeLessonLoader(_lesson),
            category: alphabetLessonCategory,
            lessonId: _lesson.id,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final hintPanel = find.ancestor(
        of: find.text('천천히 해봐!'),
        matching: find.byWidgetPredicate(
          (widget) => widget is ToyPanel && widget.tone == ToyPanelTone.lilac,
        ),
      );

      expect(hintPanel, findsOneWidget);
      expect(find.text('A a'), findsOneWidget);
      expect(find.text('에이, A a'), findsOneWidget);
      expect(find.text('에이를 크게 보고 소리를 따라 말해봐요'), findsOneWidget);
      expect(speechCueService.spoken, isEmpty);
      expect(audioService.played, hasLength(1));
      expect(
        audioService.played.single,
        isA<PromptCue>()
            .having(
              (cue) => cue.ref.assetPath,
              'assetPath',
              'assets/generated/audio/voice/prompts/alphabet/alphabet_letters_1_a_a.mp3',
            )
            .having(
              (cue) => cue.ref.fallbackText,
              'fallbackText',
              '에이, A a',
            ),
      );
    },
  );

  testWidgets('replay prompt stays suppressed after voice prompts are disabled', (
    WidgetTester tester,
  ) async {
    final progressStore = MemoryProgressStore();
    final audioService = _RecordingAudioService();
    final speechCueService = _RecordingSpeechCueService();

    await tester.pumpWidget(
      _wrapWithServices(
        progressStore: progressStore,
        audioService: audioService,
        speechCueService: speechCueService,
        child: GenericLearnScreen(
          loader: _FakeLessonLoader(_lesson),
          category: alphabetLessonCategory,
          lessonId: _lesson.id,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(audioService.played, hasLength(1));

    await progressStore.setVoicePromptsEnabled(false);
    await tester.tap(find.text('다시'));
    await tester.pumpAndSettle();

    expect(audioService.played, hasLength(1));
    expect(speechCueService.spoken, isEmpty);
  });

  testWidgets('initially disabled voice prompts suppress queued playback', (
    WidgetTester tester,
  ) async {
    final audioService = _RecordingAudioService();
    final speechCueService = _RecordingSpeechCueService();

    await tester.pumpWidget(
      _wrapWithServices(
        progressStore: MemoryProgressStore(
          const AppProgressSnapshot(voicePromptsEnabled: false),
        ),
        audioService: audioService,
        speechCueService: speechCueService,
        child: GenericLearnScreen(
          loader: _FakeLessonLoader(_lesson),
          category: alphabetLessonCategory,
          lessonId: _lesson.id,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(audioService.played, isEmpty);
    expect(speechCueService.spoken, isEmpty);
  });
}

const _lesson = Lesson(
  id: 'alphabet_letters_1',
  title: '알파벳 1',
  items: [
    LessonItem(
      symbol: 'A a',
      label: '에이, A a',
      hint: '에이를 크게 보고 소리를 따라 말해봐요',
    ),
  ],
);

class _FakeLessonLoader implements LessonContentLoader {
  const _FakeLessonLoader(this.lesson);

  final Lesson lesson;

  @override
  Future<Lesson> loadLesson(String lessonId) async => lesson;

  @override
  Future<List<Lesson>> loadLessons() async => [lesson];
}

class _RecordingAudioService implements AudioService {
  final List<AudioCue> played = <AudioCue>[];
  int stopCalls = 0;
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
  Future<void> stop() async {
    stopCalls += 1;
  }
}

class _RecordingSpeechCueService implements SpeechCueService {
  final List<String> spoken = <String>[];
  int stopCalls = 0;

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
  Future<void> stop() async {
    stopCalls += 1;
  }
}

Widget _wrapWithServices({
  ProgressStore? progressStore,
  AudioService? audioService,
  SpeechCueService? speechCueService,
  required Widget child,
}) {
  return MaterialApp(
    theme: buildKidTheme(),
    home: AppServicesScope(
      services: AppServices(
        progressStore: progressStore ?? MemoryProgressStore(),
        speechCueService: speechCueService ?? NoopSpeechCueService(),
        audioService: audioService ?? NoopAudioService(),
      ),
      child: child,
    ),
  );
}
