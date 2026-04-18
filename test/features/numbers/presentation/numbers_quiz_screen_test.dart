import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';
import 'package:kids_play_app/features/numbers/data/numbers_lesson_repository.dart';
import 'package:kids_play_app/features/numbers/presentation/numbers_quiz_screen.dart';

void main() {
  test('uses numbers_count_1 as the default lesson id', () {
    expect(const NumbersQuizScreen().lessonId, 'numbers_count_1');
  });

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

  testWidgets('header pills use calmer chrome with stroke borders', (
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

    _expectHeaderPillChrome(tester, 'numbersQuizModePill');
    _expectHeaderPillChrome(tester, 'numbersQuizProgressPill');
  });

  testWidgets(
    'uses a warm toy panel tone for the compact numbers prompt panel',
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

      final promptPanel = tester.widget<ToyPanel>(
        find.byKey(const Key('quiz-prompt-panel')),
      );

      expect(promptPanel.tone, ToyPanelTone.warm);
    },
  );

  testWidgets(
    'uses shared airy panel tone and compact density for the numbers target card on compact landscape',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(780, 430);
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

      final targetPanel = tester.widget<ToyPanel>(
        find.byKey(const Key('quiz-target-panel')),
      );

      expect(targetPanel.tone, ToyPanelTone.airy);
      expect(targetPanel.density, ToyPanelDensity.compact);
    },
  );

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
    'respects provided numbers retry order for reversed mistake lists',
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
            mistakeSymbols: const ['5', '2'],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.text("'5' 숫자를 찾아봐!"), findsOneWidget);

      await tester.tap(find.byKey(const Key('quiz-choice-5')));
      await tester.pumpAndSettle();

      expect(find.text('2 / 2'), findsOneWidget);
      expect(find.text("'2' 숫자를 찾아봐!"), findsOneWidget);
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

      final summaryPanelFinder = find.ancestor(
        of: find.text('자동차 스티커 1개 획득!'),
        matching: find.byType(ToyPanel),
      );

      expect(summaryPanelFinder, findsOneWidget);
      expect(
        tester.widget<ToyPanel>(summaryPanelFinder).tone,
        ToyPanelTone.warm,
      );
    },
  );

  testWidgets('stores numbers quiz progress with a numbers lesson key', (
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
  });

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

void _expectHeaderPillChrome(WidgetTester tester, String keyValue) {
  final pillFinder = find.byKey(ValueKey<String>(keyValue));

  expect(pillFinder, findsOneWidget);

  final pill = tester.widget<Container>(pillFinder);
  expect(pill.decoration, isA<BoxDecoration>());

  final decoration = pill.decoration! as BoxDecoration;
  expect(decoration.color, KidPalette.white.withValues(alpha: 0.92));

  final border = decoration.border;
  expect(border, isA<Border>());
  expect((border! as Border).top.color, KidPalette.stroke);
}
