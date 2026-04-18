import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/audio/audio_cue.dart';
import 'package:kids_play_app/app/audio/audio_service.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/features/numbers/data/numbers_lesson_repository.dart';
import 'package:kids_play_app/features/numbers/presentation/numbers_learn_screen.dart';

void main() {
  test('uses numbers_count_1 as the default lesson id', () {
    expect(const NumbersLearnScreen().lessonId, 'numbers_count_1');
  });

  testWidgets('shows the first numbers card and advances to the next one', (
    WidgetTester tester,
  ) async {
    final repository = NumbersLessonRepository(
      assetBundle: _FakeAssetBundle({
        NumbersLessonRepository.manifestPath: jsonEncode({
          'lessons': [_numbersLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NumbersLearnScreen(
          repository: repository,
          lessonId: 'numbers_count_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('숫자 1'), findsOneWidget);
    expect(find.text('하나, 1'), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('둘, 2'), findsOneWidget);
    expect(find.text('2 / 5'), findsOneWidget);
  });

  testWidgets('resumes from the saved numbers lesson progress', (
    WidgetTester tester,
  ) async {
    final repository = NumbersLessonRepository(
      assetBundle: _FakeAssetBundle({
        NumbersLessonRepository.manifestPath: jsonEncode({
          'lessons': [_numbersLesson],
        }),
      }),
    );
    final progressStore = MemoryProgressStore(
      const AppProgressSnapshot(
        lessons: {
          'numbers:numbers_count_1': LessonProgress(lastViewedIndex: 3),
        },
      ),
    );

    await tester.pumpWidget(
      _wrapWithServices(
        progressStore: progressStore,
        child: NumbersLearnScreen(
          repository: repository,
          lessonId: 'numbers_count_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('넷, 4'), findsOneWidget);
    expect(find.text('4 / 5'), findsOneWidget);
    expect(find.text('하나, 1'), findsNothing);
  });

  testWidgets(
    'replays the current numbers learn prompt through the injected audio service',
    (WidgetTester tester) async {
      final repository = NumbersLessonRepository(
        assetBundle: _FakeAssetBundle({
          NumbersLessonRepository.manifestPath: jsonEncode({
            'lessons': [_numbersLesson],
          }),
        }),
      );
      final audioService = _FakeAudioService();

      await tester.pumpWidget(
        _wrapWithServices(
          progressStore: MemoryProgressStore(),
          audioService: audioService,
          child: NumbersLearnScreen(
            repository: repository,
            lessonId: 'numbers_count_1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(audioService.promptCalls, hasLength(1));
      expect(audioService.promptCalls.single.categoryId, 'numbers');
      expect(audioService.promptCalls.single.lessonId, 'numbers_count_1');
      expect(audioService.promptCalls.single.symbol, '1');
      expect(audioService.promptCalls.single.fallbackText, '하나, 1');
    },
  );

  testWidgets(
    'keeps the numbers learn screen stable on a compact landscape phone',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(780, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = NumbersLessonRepository(
        assetBundle: _FakeAssetBundle({
          NumbersLessonRepository.manifestPath: jsonEncode({
            'lessons': [_numbersLesson],
          }),
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: NumbersLearnScreen(
            repository: repository,
            lessonId: 'numbers_count_1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('하나, 1'), findsOneWidget);
    },
  );

  testWidgets('shows an error message when the numbers lesson fails to load', (
    WidgetTester tester,
  ) async {
    final repository = NumbersLessonRepository(
      assetBundle: _FakeAssetBundle({}),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NumbersLearnScreen(
          repository: repository,
          lessonId: 'numbers_count_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('숫자 게임을 불러오지 못했어요.'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });
}

const Map<String, dynamic> _numbersLesson = {
  'id': 'numbers_count_1',
  'title': '숫자 1',
  'cards': [
    {'symbol': '1', 'label': '하나, 1', 'hint': '자동차 한 대를 보며 하나를 말해봐요'},
    {'symbol': '2', 'label': '둘, 2', 'hint': '자동차 두 대를 세며 둘을 말해봐요'},
    {'symbol': '3', 'label': '셋, 3', 'hint': '자동차 세 대를 세며 셋을 말해봐요'},
    {'symbol': '4', 'label': '넷, 4', 'hint': '자동차 네 대를 세며 넷을 말해봐요'},
    {'symbol': '5', 'label': '다섯, 5', 'hint': '자동차 다섯 대를 보며 다섯을 말해봐요'},
  ],
};

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this._assets);

  final Map<String, String> _assets;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = _assets[key];
    if (value == null) {
      throw Exception('Missing fake asset for $key');
    }
    return value;
  }

  @override
  Future<ByteData> load(String key) async {
    final string = await loadString(key);
    final bytes = Uint8List.fromList(utf8.encode(string));
    return ByteData.view(bytes.buffer);
  }
}

Widget _wrapWithServices({
  required ProgressStore progressStore,
  AudioService? audioService,
  required Widget child,
}) {
  return MaterialApp(
    home: AppServicesScope(
      services: AppServices(
        progressStore: progressStore,
        speechCueService: NoopSpeechCueService(),
        audioService: audioService,
      ),
      child: child,
    ),
  );
}

class _FakeAudioService implements AudioService {
  final List<AudioPromptRequest> promptCalls = <AudioPromptRequest>[];
  final List<AudioCue> cueCalls = <AudioCue>[];
  int stopCount = 0;

  @override
  Future<void> playPrompt(AudioPromptRequest request) async {
    promptCalls.add(request);
  }

  @override
  Future<void> playCue(AudioCue cue) async {
    cueCalls.add(cue);
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }
}
