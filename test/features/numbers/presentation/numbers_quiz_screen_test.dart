import 'dart:async';
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
import 'package:kids_play_app/features/numbers/presentation/numbers_quiz_screen.dart';

void main() {
  test('uses numbers_count_1 as the default lesson id', () {
    expect(const NumbersQuizScreen().lessonId, 'numbers_count_1');
  });

  testWidgets(
    'replays the current numbers prompt through the injected audio service',
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
        AppServicesScope(
          services: AppServices(
            progressStore: MemoryProgressStore(),
            speechCueService: NoopSpeechCueService(),
            audioService: audioService,
          ),
          child: MaterialApp(
            home: NumbersQuizScreen(
              repository: repository,
              lessonId: 'numbers_count_1',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(audioService.promptCalls, hasLength(1));
      expect(audioService.promptCalls.single.categoryId, 'numbers');
      expect(audioService.promptCalls.single.lessonId, 'numbers_count_1');
      expect(audioService.promptCalls.single.symbol, '1');
      expect(audioService.promptCalls.single.fallbackText, "'1' 숫자를 찾아봐!");
    },
  );

  testWidgets(
    'plays the success feedback cue through the injected audio service',
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
        AppServicesScope(
          services: AppServices(
            progressStore: MemoryProgressStore(),
            speechCueService: NoopSpeechCueService(),
            audioService: audioService,
          ),
          child: MaterialApp(
            home: NumbersQuizScreen(
              repository: repository,
              lessonId: 'numbers_count_1',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      audioService.promptCalls.clear();

      await tester.tap(find.byKey(const Key('quiz-choice-1')));
      await tester.pump();

      expect(audioService.cueCalls, hasLength(1));
      expect(audioService.cueCalls.single.type, AudioCueType.success);
      expect(audioService.cueCalls.single.assetKey, 'audio/sfx/success.ogg');
      expect(audioService.cueCalls.single.fallbackText, '딩동댕');

      await tester.pump(const Duration(milliseconds: 650));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'plays the success feedback cue when voice prompts are off but feedback effects stay on',
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
        AppServicesScope(
          services: AppServices(
            progressStore: MemoryProgressStore(
              const AppProgressSnapshot(
                voicePromptsEnabled: false,
                effectsEnabled: true,
              ),
            ),
            speechCueService: NoopSpeechCueService(),
            audioService: audioService,
          ),
          child: MaterialApp(
            home: NumbersQuizScreen(
              repository: repository,
              lessonId: 'numbers_count_1',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(audioService.promptCalls, isEmpty);

      await tester.tap(find.byKey(const Key('quiz-choice-1')));
      await tester.pump();

      expect(audioService.cueCalls, hasLength(1));
      expect(audioService.cueCalls.single.type, AudioCueType.success);

      await tester.pump(const Duration(milliseconds: 650));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'does not play the success feedback cue when feedback effects are off',
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
        AppServicesScope(
          services: AppServices(
            progressStore: MemoryProgressStore(
              const AppProgressSnapshot(
                voicePromptsEnabled: true,
                effectsEnabled: false,
              ),
            ),
            speechCueService: NoopSpeechCueService(),
            audioService: audioService,
          ),
          child: MaterialApp(
            home: NumbersQuizScreen(
              repository: repository,
              lessonId: 'numbers_count_1',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      audioService.promptCalls.clear();

      await tester.tap(find.byKey(const Key('quiz-choice-1')));
      await tester.pump();

      expect(audioService.cueCalls, isEmpty);

      await tester.pump(const Duration(milliseconds: 220));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('shows the first numbers quiz question with four choices', (
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
        home: NumbersQuizScreen(
          repository: repository,
          lessonId: 'numbers_count_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('숫자 게임'), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);
    expect(find.text("'1' 숫자를 찾아봐!"), findsOneWidget);
    expect(find.byKey(const Key('quiz-choice-1')), findsOneWidget);
    expect(find.byKey(const Key('quiz-choice-2')), findsOneWidget);
    expect(find.byKey(const Key('quiz-choice-3')), findsOneWidget);
    expect(find.byKey(const Key('quiz-choice-4')), findsOneWidget);
  });

  testWidgets(
    'keeps all numbers answer choices fully visible on a compact landscape screen',
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
          home: NumbersQuizScreen(
            repository: repository,
            lessonId: 'numbers_count_1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final screenBottom = tester.view.physicalSize.height;
      for (final symbol in ['1', '2', '3', '4']) {
        final rect = tester.getRect(find.byKey(Key('quiz-choice-$symbol')));
        expect(
          rect.bottom <= screenBottom,
          isTrue,
          reason: '$symbol choice should stay on screen',
        );
      }
    },
  );

  testWidgets(
    'can replay only recent number mistake questions when mistake symbols are provided',
    (WidgetTester tester) async {
      final repository = NumbersLessonRepository(
        assetBundle: _FakeAssetBundle({
          NumbersLessonRepository.manifestPath: jsonEncode({
            'lessons': [_numbersLesson],
          }),
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: NumbersQuizScreen(
            repository: repository,
            lessonId: 'numbers_count_1',
            mistakeSymbols: const ['2', '5'],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.text("'2' 숫자를 찾아봐!"), findsOneWidget);

      await tester.tap(find.byKey(const Key('quiz-choice-2')));
      await tester.pumpAndSettle();

      expect(find.text('2 / 2'), findsOneWidget);
      expect(find.text("'5' 숫자를 찾아봐!"), findsOneWidget);
    },
  );

  testWidgets(
    'waits for feedback timing before advancing to the next numbers question',
    (WidgetTester tester) async {
      final repository = NumbersLessonRepository(
        assetBundle: _FakeAssetBundle({
          NumbersLessonRepository.manifestPath: jsonEncode({
            'lessons': [_numbersLesson],
          }),
        }),
      );
      final progressStore = MemoryProgressStore(
        const AppProgressSnapshot(
          voicePromptsEnabled: false,
          effectsEnabled: false,
        ),
      );

      await tester.pumpWidget(
        AppServicesScope(
          services: AppServices(
            progressStore: progressStore,
            speechCueService: NoopSpeechCueService(),
          ),
          child: MaterialApp(
            home: NumbersQuizScreen(
              repository: repository,
              lessonId: 'numbers_count_1',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('quiz-choice-1')));
      await tester.pump();

      expect(find.text('1 / 5'), findsOneWidget);
      expect(find.text("'1' 숫자를 찾아봐!"), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 220));
      await tester.pumpAndSettle();

      expect(find.text('2 / 5'), findsOneWidget);
      expect(find.text("'2' 숫자를 찾아봐!"), findsOneWidget);
    },
  );

  testWidgets('rebuilds the quiz session when recent mistake symbols change', (
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
        home: NumbersQuizScreen(
          repository: repository,
          lessonId: 'numbers_count_1',
          mistakeSymbols: const ['2', '5'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text("'2' 숫자를 찾아봐!"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: NumbersQuizScreen(
          repository: repository,
          lessonId: 'numbers_count_1',
          mistakeSymbols: const ['5'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.text("'5' 숫자를 찾아봐!"), findsOneWidget);
  });

  testWidgets(
    'ignores a stale answer resolution when recent mistake symbols change mid-feedback',
    (WidgetTester tester) async {
      final repository = NumbersLessonRepository(
        assetBundle: _FakeAssetBundle({
          NumbersLessonRepository.manifestPath: jsonEncode({
            'lessons': [_numbersLesson],
          }),
        }),
      );
      final progressStore = MemoryProgressStore(
        const AppProgressSnapshot(
          voicePromptsEnabled: false,
          effectsEnabled: false,
        ),
      );

      Widget buildQuiz(List<String> mistakeSymbols) {
        return AppServicesScope(
          services: AppServices(
            progressStore: progressStore,
            speechCueService: NoopSpeechCueService(),
          ),
          child: MaterialApp(
            home: NumbersQuizScreen(
              repository: repository,
              lessonId: 'numbers_count_1',
              mistakeSymbols: mistakeSymbols,
            ),
          ),
        );
      }

      await tester.pumpWidget(buildQuiz(const ['2', '5']));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('quiz-choice-2')));
      await tester.pump();

      await tester.pumpWidget(buildQuiz(const ['5']));
      await tester.pumpAndSettle();

      expect(find.text('1 / 1'), findsOneWidget);
      expect(find.text("'5' 숫자를 찾아봐!"), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 220));
      await tester.pumpAndSettle();

      expect(find.text('1 / 1'), findsOneWidget);
      expect(find.text("'5' 숫자를 찾아봐!"), findsOneWidget);
    },
  );

  testWidgets(
    'ignores a stale answer start when recent mistake symbols change before settings load',
    (WidgetTester tester) async {
      final repository = NumbersLessonRepository(
        assetBundle: _FakeAssetBundle({
          NumbersLessonRepository.manifestPath: jsonEncode({
            'lessons': [_numbersLesson],
          }),
        }),
      );
      final loadSnapshotCompleter = Completer<void>();
      final progressStore = _ControlledProgressStore(
        MemoryProgressStore(
          const AppProgressSnapshot(
            voicePromptsEnabled: false,
            effectsEnabled: false,
          ),
        ),
        loadSnapshotCompleter: loadSnapshotCompleter,
      );

      Widget buildQuiz(List<String> mistakeSymbols) {
        return AppServicesScope(
          services: AppServices(
            progressStore: progressStore,
            speechCueService: NoopSpeechCueService(),
          ),
          child: MaterialApp(
            home: NumbersQuizScreen(
              repository: repository,
              lessonId: 'numbers_count_1',
              mistakeSymbols: mistakeSymbols,
            ),
          ),
        );
      }

      await tester.pumpWidget(buildQuiz(const ['2', '5']));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('quiz-choice-2')));
      await tester.pump();

      await tester.pumpWidget(buildQuiz(const ['5']));
      await tester.pumpAndSettle();

      expect(find.text('1 / 1'), findsOneWidget);
      expect(find.text("'5' 숫자를 찾아봐!"), findsOneWidget);

      loadSnapshotCompleter.complete();
      await tester.pump();

      await tester.tap(find.byKey(const Key('quiz-choice-5')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pumpAndSettle();

      expect(find.text('1문제 중 1문제 맞았어요!'), findsOneWidget);
      expect(find.text('자동차 스티커 1개 획득!'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 350));
    },
  );

  testWidgets(
    'ignores a stale completion when recent mistake symbols change during atomic completion persistence',
    (WidgetTester tester) async {
      final repository = NumbersLessonRepository(
        assetBundle: _FakeAssetBundle({
          NumbersLessonRepository.manifestPath: jsonEncode({
            'lessons': [_numbersLesson],
          }),
        }),
      );
      final recordCompletedQuizCompleter = Completer<void>();
      final progressStore = _ControlledProgressStore(
        MemoryProgressStore(
          const AppProgressSnapshot(
            voicePromptsEnabled: false,
            effectsEnabled: false,
          ),
        ),
        recordCompletedQuizCompleter: recordCompletedQuizCompleter,
      );

      Widget buildQuiz(List<String> mistakeSymbols) {
        return AppServicesScope(
          services: AppServices(
            progressStore: progressStore,
            speechCueService: NoopSpeechCueService(),
          ),
          child: MaterialApp(
            home: NumbersQuizScreen(
              repository: repository,
              lessonId: 'numbers_count_1',
              mistakeSymbols: mistakeSymbols,
            ),
          ),
        );
      }

      await tester.pumpWidget(buildQuiz(const ['5']));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('quiz-choice-5')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump();

      expect(progressStore.recordCompletedQuizCallCount, 1);
      expect(progressStore.addStickersCallCount, 0);
      expect(progressStore.recordRewardEarnedCallCount, 0);

      await tester.pumpWidget(buildQuiz(const ['2', '5']));
      await tester.pumpAndSettle();

      final rebuiltTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((widget) {
            return widget.data ?? widget.textSpan?.toPlainText() ?? '';
          })
          .toList(growable: false);

      expect(rebuiltTexts, contains('1 / 2'));
      expect(rebuiltTexts, contains("'2' 숫자를 찾아봐!"));

      recordCompletedQuizCompleter.complete();
      await tester.pumpAndSettle();

      final settledTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((widget) {
            return widget.data ?? widget.textSpan?.toPlainText() ?? '';
          })
          .toList(growable: false);

      expect(settledTexts, contains('1 / 2'));
      expect(settledTexts, contains("'2' 숫자를 찾아봐!"));

      await tester.pump(const Duration(milliseconds: 350));
    },
  );

  testWidgets(
    'records the completed quiz result when recent mistake symbols change during atomic completion persistence',
    (WidgetTester tester) async {
      final repository = NumbersLessonRepository(
        assetBundle: _FakeAssetBundle({
          NumbersLessonRepository.manifestPath: jsonEncode({
            'lessons': [_numbersLesson],
          }),
        }),
      );
      final recordCompletedQuizCompleter = Completer<void>();
      final progressStore = _ControlledProgressStore(
        MemoryProgressStore(
          const AppProgressSnapshot(
            voicePromptsEnabled: false,
            effectsEnabled: false,
          ),
        ),
        recordCompletedQuizCompleter: recordCompletedQuizCompleter,
      );

      Widget buildQuiz(List<String> mistakeSymbols) {
        return AppServicesScope(
          services: AppServices(
            progressStore: progressStore,
            speechCueService: NoopSpeechCueService(),
          ),
          child: MaterialApp(
            home: NumbersQuizScreen(
              repository: repository,
              lessonId: 'numbers_count_1',
              mistakeSymbols: mistakeSymbols,
            ),
          ),
        );
      }

      await tester.pumpWidget(buildQuiz(const ['5']));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('quiz-choice-5')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump();

      expect(progressStore.recordCompletedQuizCallCount, 1);
      expect(progressStore.addStickersCallCount, 0);
      expect(progressStore.recordRewardEarnedCallCount, 0);

      await tester.pumpWidget(buildQuiz(const ['2', '5']));
      await tester.pumpAndSettle();

      final rebuiltTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((widget) {
            return widget.data ?? widget.textSpan?.toPlainText() ?? '';
          })
          .toList(growable: false);

      expect(rebuiltTexts, contains('1 / 2'));
      expect(rebuiltTexts, contains("'2' 숫자를 찾아봐!"));

      recordCompletedQuizCompleter.complete();
      await tester.pumpAndSettle();

      final snapshot = await progressStore.loadSnapshot();

      expect(snapshot.stickerCount, 1);
      expect(snapshot.lastEarnedReward?.kind, 'sticker');
      expect(snapshot.lastEarnedReward?.lessonId, 'numbers:numbers_count_1');
      expect(snapshot.progressFor('numbers:numbers_count_1').bestScore, 1);
      expect(snapshot.progressFor('numbers:numbers_count_1').totalQuestions, 1);
      expect(
        snapshot.progressFor('numbers:numbers_count_1').recentMistakes,
        isEmpty,
      );

      await tester.pump(const Duration(milliseconds: 350));
    },
  );

  testWidgets(
    'shows a sticker reward summary after finishing the numbers quiz',
    (WidgetTester tester) async {
      final repository = NumbersLessonRepository(
        assetBundle: _FakeAssetBundle({
          NumbersLessonRepository.manifestPath: jsonEncode({
            'lessons': [_numbersLesson],
          }),
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: NumbersQuizScreen(
            repository: repository,
            lessonId: 'numbers_count_1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('quiz-choice-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('quiz-choice-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('quiz-choice-3')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('quiz-choice-4')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('quiz-choice-5')));
      await tester.pumpAndSettle();

      expect(find.text('5문제 중 5문제 맞았어요!'), findsOneWidget);
      expect(find.text('자동차 스티커 1개 획득!'), findsOneWidget);
      expect(find.text('다시하기'), findsOneWidget);
    },
  );

  testWidgets(
    'stores numbers quiz progress and the recent sticker reward with a numbers lesson key',
    (WidgetTester tester) async {
      final repository = NumbersLessonRepository(
        assetBundle: _FakeAssetBundle({
          NumbersLessonRepository.manifestPath: jsonEncode({
            'lessons': [_numbersLesson],
          }),
        }),
      );
      final progressStore = MemoryProgressStore(
        const AppProgressSnapshot(
          voicePromptsEnabled: false,
          effectsEnabled: false,
        ),
      );

      await tester.pumpWidget(
        AppServicesScope(
          services: AppServices(
            progressStore: progressStore,
            speechCueService: NoopSpeechCueService(),
          ),
          child: MaterialApp(
            home: NumbersQuizScreen(
              repository: repository,
              lessonId: 'numbers_count_1',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('quiz-choice-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('quiz-choice-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('quiz-choice-3')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('quiz-choice-4')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('quiz-choice-5')));
      await tester.pumpAndSettle();

      final snapshot = await progressStore.loadSnapshot();

      expect(snapshot.lessons.containsKey('numbers:numbers_count_1'), isTrue);
      expect(snapshot.lessons.containsKey('alphabet:numbers_count_1'), isFalse);
      expect(snapshot.progressFor('numbers:numbers_count_1').bestScore, 5);
      expect(snapshot.lastEarnedReward, isNotNull);
      expect(snapshot.lastEarnedReward?.kind, 'sticker');
      expect(snapshot.lastEarnedReward?.amount, 1);
      expect(snapshot.lastEarnedReward?.lessonId, 'numbers:numbers_count_1');
    },
  );

  testWidgets('shows an error message when the numbers quiz fails to load', (
    WidgetTester tester,
  ) async {
    final repository = NumbersLessonRepository(
      assetBundle: _FakeAssetBundle({}),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NumbersQuizScreen(
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

class _ControlledProgressStore implements ProgressStore {
  _ControlledProgressStore(
    this._delegate, {
    this.loadSnapshotCompleter,
    this.recordCompletedQuizCompleter,
  });

  final ProgressStore _delegate;
  final Completer<void>? loadSnapshotCompleter;
  final Completer<void>? recordCompletedQuizCompleter;
  int addStickersCallCount = 0;
  int recordCompletedQuizCallCount = 0;
  int recordRewardEarnedCallCount = 0;

  @override
  Future<void> addStickers(int count) async {
    addStickersCallCount += 1;
    await _delegate.addStickers(count);
  }

  @override
  Future<AppProgressSnapshot> loadSnapshot() async {
    final completer = loadSnapshotCompleter;
    if (completer != null) {
      await completer.future;
    }
    return _delegate.loadSnapshot();
  }

  @override
  Future<void> recordLessonIndex({
    required String lessonId,
    required int lastViewedIndex,
  }) {
    return _delegate.recordLessonIndex(
      lessonId: lessonId,
      lastViewedIndex: lastViewedIndex,
    );
  }

  @override
  Future<void> recordQuizResult({
    required String lessonId,
    required int correctCount,
    required int totalQuestions,
    required List<String> recentMistakes,
  }) {
    return _delegate.recordQuizResult(
      lessonId: lessonId,
      correctCount: correctCount,
      totalQuestions: totalQuestions,
      recentMistakes: recentMistakes,
    );
  }

  @override
  Future<void> recordCompletedQuiz({
    required String lessonId,
    required int correctCount,
    required int totalQuestions,
    required List<String> recentMistakes,
    int stickersEarned = 0,
    DateTime? rewardEarnedAt,
  }) async {
    recordCompletedQuizCallCount += 1;
    final completer = recordCompletedQuizCompleter;
    if (completer != null) {
      await completer.future;
    }
    await _delegate.recordCompletedQuiz(
      lessonId: lessonId,
      correctCount: correctCount,
      totalQuestions: totalQuestions,
      recentMistakes: recentMistakes,
      stickersEarned: stickersEarned,
      rewardEarnedAt: rewardEarnedAt,
    );
  }

  @override
  Future<void> recordRewardEarned({
    required String kind,
    required int amount,
    required String lessonId,
    required DateTime earnedAt,
  }) async {
    recordRewardEarnedCallCount += 1;
    await _delegate.recordRewardEarned(
      kind: kind,
      amount: amount,
      lessonId: lessonId,
      earnedAt: earnedAt,
    );
  }

  @override
  Future<void> reset() {
    return _delegate.reset();
  }

  @override
  Future<void> setEffectsEnabled(bool enabled) {
    return _delegate.setEffectsEnabled(enabled);
  }

  @override
  Future<void> setLessonUnlocked(String lessonId, bool unlocked) {
    return _delegate.setLessonUnlocked(lessonId, unlocked);
  }

  @override
  Future<void> setVoicePromptsEnabled(bool enabled) {
    return _delegate.setVoicePromptsEnabled(enabled);
  }
}

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

class _FakeAudioService implements AudioService {
  final List<AudioPromptRequest> promptCalls = [];
  final List<AudioCue> cueCalls = [];
  int stopCount = 0;

  @override
  Future<void> playCue(AudioCue cue) async {
    cueCalls.add(cue);
  }

  @override
  Future<void> playPrompt(AudioPromptRequest request) async {
    promptCalls.add(request);
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }
}
