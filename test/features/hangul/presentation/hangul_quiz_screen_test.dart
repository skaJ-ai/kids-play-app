import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/features/hangul/data/hangul_lesson_repository.dart';
import 'package:kids_play_app/features/hangul/presentation/hangul_quiz_screen.dart';

void main() {
  testWidgets('renders the quiz inside the playful playground shell', (
    WidgetTester tester,
  ) async {
    final repository = HangulLessonRepository(
      assetBundle: _FakeAssetBundle({
        HangulLessonRepository.manifestPath: jsonEncode({
          'lessons': [_basicConsonantsLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HangulQuizScreen(
          repository: repository,
          lessonId: 'basic_consonants_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('playground-background')), findsOneWidget);
    expect(find.byKey(const Key('quiz-prompt-panel')), findsOneWidget);
  });

  testWidgets('shows the first hangul quiz question with four choices', (
    WidgetTester tester,
  ) async {
    final repository = HangulLessonRepository(
      assetBundle: _FakeAssetBundle({
        HangulLessonRepository.manifestPath: jsonEncode({
          'lessons': [_basicConsonantsLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HangulQuizScreen(
          repository: repository,
          lessonId: 'basic_consonants_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('한글 게임'), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);
    expect(find.text("'ㄱ' 글자를 찾아봐!"), findsOneWidget);
    expect(find.byKey(const Key('quiz-choice-ㄱ')), findsOneWidget);
    expect(find.byKey(const Key('quiz-choice-ㄴ')), findsOneWidget);
    expect(find.byKey(const Key('quiz-choice-ㄷ')), findsOneWidget);
    expect(find.byKey(const Key('quiz-choice-ㄹ')), findsOneWidget);
  });

  testWidgets('keeps all four answer choices fully visible on a compact landscape screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(780, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = HangulLessonRepository(
      assetBundle: _FakeAssetBundle({
        HangulLessonRepository.manifestPath: jsonEncode({
          'lessons': [_basicConsonantsLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HangulQuizScreen(
          repository: repository,
          lessonId: 'basic_consonants_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final screenBottom = tester.view.physicalSize.height;
    for (final symbol in ['ㄱ', 'ㄴ', 'ㄷ', 'ㄹ']) {
      final rect = tester.getRect(find.byKey(Key('quiz-choice-$symbol')));
      expect(rect.bottom <= screenBottom, isTrue, reason: '$symbol choice should stay on screen');
    }
  });

  testWidgets('shows a clearer target prompt without combining a standalone consonant with the particle', (
    WidgetTester tester,
  ) async {
    final repository = HangulLessonRepository(
      assetBundle: _FakeAssetBundle({
        HangulLessonRepository.manifestPath: jsonEncode({
          'lessons': [_basicConsonantsLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HangulQuizScreen(
          repository: repository,
          lessonId: 'basic_consonants_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("'ㄱ' 글자를 찾아봐!"), findsOneWidget);
  });

  testWidgets('shows a sticker reward summary after finishing the quiz', (
    WidgetTester tester,
  ) async {
    final repository = HangulLessonRepository(
      assetBundle: _FakeAssetBundle({
        HangulLessonRepository.manifestPath: jsonEncode({
          'lessons': [_basicConsonantsLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HangulQuizScreen(
          repository: repository,
          lessonId: 'basic_consonants_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('quiz-choice-ㄱ')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quiz-choice-ㄴ')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quiz-choice-ㄷ')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quiz-choice-ㄹ')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quiz-choice-ㅁ')));
    await tester.pumpAndSettle();

    expect(find.text('5문제 중 5문제 맞았어요!'), findsOneWidget);
    expect(find.text('자동차 스티커 1개 획득!'), findsOneWidget);
    expect(find.text('다시하기'), findsOneWidget);
  });

  testWidgets('shows an error message when the hangul quiz fails to load', (
    WidgetTester tester,
  ) async {
    final repository = HangulLessonRepository(assetBundle: _FakeAssetBundle({}));

    await tester.pumpWidget(
      MaterialApp(
        home: HangulQuizScreen(
          repository: repository,
          lessonId: 'basic_consonants_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('한글 게임을 불러오지 못했어요.'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });
}

const Map<String, dynamic> _basicConsonantsLesson = {
  'id': 'basic_consonants_1',
  'title': '기본 자음 1',
  'cards': [
    {
      'symbol': 'ㄱ',
      'label': '기역, ㄱ',
      'hint': '큰 카드로 기역을 천천히 보고 눌러봐요',
    },
    {
      'symbol': 'ㄴ',
      'label': '니은, ㄴ',
      'hint': '니은을 만나고 입으로 따라 말해봐요',
    },
    {
      'symbol': 'ㄷ',
      'label': '디귿, ㄷ',
      'hint': '디귿을 보고 손가락으로 콕 눌러봐요',
    },
    {
      'symbol': 'ㄹ',
      'label': '리을, ㄹ',
      'hint': '리을 모양을 천천히 눈으로 따라가봐요',
    },
    {
      'symbol': 'ㅁ',
      'label': '미음, ㅁ',
      'hint': '미음을 보며 입모양을 떠올려봐요',
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
