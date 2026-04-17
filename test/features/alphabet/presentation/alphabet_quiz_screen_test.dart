import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
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
    expect(find.text("'A a' 글자를 찾아봐!"), findsOneWidget);
    expect(find.byKey(const Key('quiz-choice-A a')), findsOneWidget);
    expect(find.byKey(const Key('quiz-choice-B b')), findsOneWidget);
    expect(find.byKey(const Key('quiz-choice-C c')), findsOneWidget);
    expect(find.byKey(const Key('quiz-choice-D d')), findsOneWidget);
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
    for (final symbol in ['A a', 'B b', 'C c', 'D d']) {
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
          mistakeSymbols: const ['B b', 'D d'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text("'B b' 글자를 찾아봐!"), findsOneWidget);

    await tester.tap(find.byKey(const Key('quiz-choice-B b')));
    await tester.pumpAndSettle();

    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text("'D d' 글자를 찾아봐!"), findsOneWidget);
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

    await tester.tap(find.byKey(const Key('quiz-choice-A a')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quiz-choice-B b')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quiz-choice-C c')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quiz-choice-D d')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quiz-choice-E e')));
    await tester.pumpAndSettle();

    expect(find.text('5문제 중 5문제 맞았어요!'), findsOneWidget);
    expect(find.text('자동차 스티커 1개 획득!'), findsOneWidget);
    expect(find.text('다시하기'), findsOneWidget);
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
      'symbol': 'A a',
      'label': '에이, A a',
      'hint': '에이를 크게 보고 소리를 따라 말해봐요',
    },
    {
      'symbol': 'B b',
      'label': '비, B b',
      'hint': '비를 보며 입으로 비 하고 말해봐요',
    },
    {
      'symbol': 'C c',
      'label': '씨, C c',
      'hint': '씨를 보고 입모양을 동그랗게 해봐요',
    },
    {
      'symbol': 'D d',
      'label': '디, D d',
      'hint': '디를 보며 손가락으로 천천히 짚어봐요',
    },
    {
      'symbol': 'E e',
      'label': '이, E e',
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
