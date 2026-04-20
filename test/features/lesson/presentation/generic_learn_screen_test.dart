import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/audio/audio_cue.dart';
import 'package:kids_play_app/app/audio/audio_service.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/mascot_view.dart';
import 'package:kids_play_app/features/lesson/data/lesson_content_loader.dart';
import 'package:kids_play_app/features/lesson/domain/lesson.dart';
import 'package:kids_play_app/features/lesson/domain/lesson_category.dart';
import 'package:kids_play_app/features/lesson/presentation/generic_learn_screen.dart';

void main() {
  testWidgets(
    'tapping the glyph card plays prompt audio with stable metadata',
    (WidgetTester tester) async {
      final audio = _RecordingAudioService();
      final speech = _RecordingSpeechCueService();

      await tester.pumpWidget(
        _wrapWithServices(
          audioService: audio,
          speechCueService: speech,
          child: GenericLearnScreen(
            loader: _FakeLessonLoader(_lesson),
            category: alphabetLessonCategory,
            lessonId: _lesson.id,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(audio.played, isEmpty);

      await tester.tap(find.byKey(const Key('learn-glyph-card')));
      await tester.pumpAndSettle();

      expect(audio.played, hasLength(1));
      final cue = audio.played.single as PromptCue;
      expect(
        cue.ref.assetPath,
        'assets/generated/audio/voice/prompts/alphabet/alphabet_letters_1_a_a.mp3',
      );
      expect(cue.ref.fallbackText, '에이, A a');
      expect(speech.spoken, isEmpty);
    },
  );

  testWidgets(
    'falls back to item index metadata when a symbol normalizes to an empty slug',
    (WidgetTester tester) async {
      final audio = _RecordingAudioService();

      await tester.pumpWidget(
        _wrapWithServices(
          audioService: audio,
          child: GenericLearnScreen(
            loader: _FakeLessonLoader(_nonAsciiLesson),
            category: alphabetLessonCategory,
            lessonId: _nonAsciiLesson.id,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('learn-glyph-card')));
      await tester.pumpAndSettle();

      final cue = audio.played.single as PromptCue;
      expect(
        cue.ref.assetPath,
        'assets/generated/audio/voice/prompts/alphabet/alphabet_symbols_1_item_1.mp3',
      );
      expect(cue.ref.fallbackText, '기역, ㄱ');
    },
  );

  testWidgets(
    'suppresses prompt playback when voice prompts are disabled',
    (WidgetTester tester) async {
      final audio = _RecordingAudioService();

      await tester.pumpWidget(
        _wrapWithServices(
          progressStore: MemoryProgressStore(
            const AppProgressSnapshot(voicePromptsEnabled: false),
          ),
          audioService: audio,
          child: GenericLearnScreen(
            loader: _FakeLessonLoader(_lesson),
            category: alphabetLessonCategory,
            lessonId: _lesson.id,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('learn-glyph-card')));
      await tester.pumpAndSettle();

      expect(audio.played, isEmpty);
    },
  );

  testWidgets(
    'tapping the glyph card switches the mascot to correct pose',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithServices(
          child: GenericLearnScreen(
            loader: _FakeLessonLoader(_lesson),
            category: alphabetLessonCategory,
            lessonId: _lesson.id,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final initial = tester
          .widget<MascotView>(find.byKey(const Key('learn-mascot')));
      expect(initial.state, MascotState.idle);

      await tester.tap(find.byKey(const Key('learn-glyph-card')));
      await tester.pump();

      final after = tester
          .widget<MascotView>(find.byKey(const Key('learn-mascot')));
      expect(after.state, MascotState.correct);

      await tester.pump(const Duration(milliseconds: 950));
      final reset = tester
          .widget<MascotView>(find.byKey(const Key('learn-mascot')));
      expect(reset.state, MascotState.idle);
    },
  );
}

const _lesson = Lesson(
  id: 'alphabet_letters_1',
  title: '알파벳 1',
  items: [
    LessonItem(
      symbol: 'A a',
      display: 'A a',
      spoken: '에이, A a',
      hint: '에이를 크게 보고 소리를 따라 말해봐요',
    ),
  ],
);

const _nonAsciiLesson = Lesson(
  id: 'alphabet_symbols_1',
  title: '기호 1',
  items: [
    LessonItem(
      symbol: 'ㄱ',
      display: 'ㄱ',
      spoken: '기역, ㄱ',
      hint: '기역 모양을 보고 이름을 따라 말해봐요',
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
  final List<AudioCue> played = [];
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

class _RecordingSpeechCueService implements SpeechCueService {
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

Widget _wrapWithServices({
  required Widget child,
  ProgressStore? progressStore,
  SpeechCueService? speechCueService,
  AudioService? audioService,
}) {
  return MaterialApp(
    theme: buildKidTheme(),
    home: AppServicesScope(
      services: AppServices(
        progressStore: progressStore ?? MemoryProgressStore(),
        speechCueService: speechCueService ?? NoopSpeechCueService(),
        audioService: audioService,
      ),
      child: child,
    ),
  );
}
