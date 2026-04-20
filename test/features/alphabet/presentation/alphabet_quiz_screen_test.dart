import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/mascot_view.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';
import 'package:kids_play_app/features/alphabet/data/alphabet_lesson_repository.dart';
import 'package:kids_play_app/features/alphabet/presentation/alphabet_quiz_screen.dart';

void main() {
  testWidgets('shows the first alphabet quiz question with four choices', (
    WidgetTester tester,
  ) async {
    final repository = AlphabetLessonRepository(
      assetBundle: _FakeAssetBundle({
        AlphabetLessonRepository.manifestPath: jsonEncode({
          'lessons': [_alphabetLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AlphabetQuizScreen(
          repository: repository,
          lessonId: 'alphabet_letters_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('알파벳 게임'), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);
    expect(find.text('에이 글자를 찾아봐!'), findsOneWidget);
    expect(find.byKey(const Key('quiz-choice-A')), findsOneWidget);
    expect(find.byKey(const Key('quiz-choice-B')), findsOneWidget);
    expect(find.byKey(const Key('quiz-choice-C')), findsOneWidget);
    expect(find.byKey(const Key('quiz-choice-D')), findsOneWidget);
  });

  testWidgets('renders the cream-warm mascot panel with signal light on a compact screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(780, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = AlphabetLessonRepository(
      assetBundle: _FakeAssetBundle({
        AlphabetLessonRepository.manifestPath: jsonEncode({
          'lessons': [_alphabetLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AlphabetQuizScreen(
          repository: repository,
          lessonId: 'alphabet_letters_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final mascotPanel = tester.widget<ToyPanel>(
      find.byKey(const Key('quiz-mascot-panel')),
    );
    expect(mascotPanel.backgroundColor, KidPalette.creamWarm);
    expect(find.byKey(const Key('quiz-signal-light')), findsOneWidget);
    expect(find.byKey(const Key('quiz-mascot')), findsOneWidget);
  });

  testWidgets('keeps all alphabet answer choices fully visible on a compact landscape screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(780, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = AlphabetLessonRepository(
      assetBundle: _FakeAssetBundle({
        AlphabetLessonRepository.manifestPath: jsonEncode({
          'lessons': [_alphabetLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AlphabetQuizScreen(
          repository: repository,
          lessonId: 'alphabet_letters_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final screenBottom = tester.view.physicalSize.height;
    for (final symbol in ['A', 'B', 'C', 'D']) {
      final rect = tester.getRect(find.byKey(Key('quiz-choice-$symbol')));
      expect(rect.bottom <= screenBottom, isTrue, reason: '$symbol choice should stay on screen');
    }
  });

  testWidgets('can replay only recent alphabet mistake questions when mistake symbols are provided', (
    WidgetTester tester,
  ) async {
    final repository = AlphabetLessonRepository(
      assetBundle: _FakeAssetBundle({
        AlphabetLessonRepository.manifestPath: jsonEncode({
          'lessons': [_alphabetLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AlphabetQuizScreen(
          repository: repository,
          lessonId: 'alphabet_letters_1',
          mistakeSymbols: const ['B', 'D'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('비 글자를 찾아봐!'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quiz-choice-B')));
    await tester.pumpAndSettle();

    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('디 글자를 찾아봐!'), findsOneWidget);
  });

  testWidgets('shows a sticker reward summary after finishing the alphabet quiz', (
    WidgetTester tester,
  ) async {
    final repository = AlphabetLessonRepository(
      assetBundle: _FakeAssetBundle({
        AlphabetLessonRepository.manifestPath: jsonEncode({
          'lessons': [_alphabetLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AlphabetQuizScreen(
          repository: repository,
          lessonId: 'alphabet_letters_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('quiz-choice-A')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quiz-choice-B')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quiz-choice-C')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quiz-choice-D')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quiz-choice-E')));
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
      tester.widget<ToyPanel>(summaryPanelFinder).backgroundColor,
      KidPalette.creamWarm,
    );
    final summaryMascot = tester.widget<MascotView>(
      find.byKey(const Key('quiz-summary-mascot')),
    );
    expect(summaryMascot.state, MascotState.missionClear);
  });

  testWidgets('shows an error message when the alphabet quiz fails to load', (
    WidgetTester tester,
  ) async {
    final repository = AlphabetLessonRepository(assetBundle: _FakeAssetBundle({}));

    await tester.pumpWidget(
      MaterialApp(
        home: AlphabetQuizScreen(
          repository: repository,
          lessonId: 'alphabet_letters_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('알파벳 게임을 불러오지 못했어요.'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });
}

const Map<String, dynamic> _alphabetLesson = {
  'id': 'alphabet_letters_1',
  'title': '알파벳 1',
  'cards': [
    {
      'symbol': 'A',
      'display': 'A',
      'spoken': '에이',
      'hint': '에이를 크게 보고 소리를 따라 말해봐요',
    },
    {
      'symbol': 'B',
      'display': 'B',
      'spoken': '비',
      'hint': '비를 보며 입으로 비 하고 말해봐요',
    },
    {
      'symbol': 'C',
      'display': 'C',
      'spoken': '씨',
      'hint': '씨를 보고 입모양을 동그랗게 해봐요',
    },
    {
      'symbol': 'D',
      'display': 'D',
      'spoken': '디',
      'hint': '디를 보며 손가락으로 천천히 짚어봐요',
    },
    {
      'symbol': 'E',
      'display': 'E',
      'spoken': '이',
      'hint': '이를 보고 환하게 따라 말해봐요',
    },
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
