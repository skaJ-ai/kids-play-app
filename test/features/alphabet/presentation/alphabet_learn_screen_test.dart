import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/toy_button.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';
import 'package:kids_play_app/features/alphabet/data/alphabet_lesson_repository.dart';
import 'package:kids_play_app/features/alphabet/presentation/alphabet_learn_screen.dart';

void main() {
  testWidgets('shows the first alphabet card and advances to the next one', (
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
        home: AlphabetLearnScreen(
          repository: repository,
          lessonId: 'alphabet_letters_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('알파벳 1'), findsOneWidget);
    expect(find.text('에이, A a'), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('비, B b'), findsOneWidget);
    expect(find.text('2 / 5'), findsOneWidget);
  });

  testWidgets('resumes from the saved alphabet lesson progress', (
    WidgetTester tester,
  ) async {
    final repository = AlphabetLessonRepository(
      assetBundle: _FakeAssetBundle({
        AlphabetLessonRepository.manifestPath: jsonEncode({
          'lessons': [_alphabetLesson],
        }),
      }),
    );
    final progressStore = MemoryProgressStore(
      const AppProgressSnapshot(
        lessons: {
          'alphabet:alphabet_letters_1': LessonProgress(lastViewedIndex: 2),
        },
      ),
    );

    await tester.pumpWidget(
      _wrapWithServices(
        progressStore: progressStore,
        child: AlphabetLearnScreen(
          repository: repository,
          lessonId: 'alphabet_letters_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('씨, C c'), findsOneWidget);
    expect(find.text('3 / 5'), findsOneWidget);
    expect(find.text('에이, A a'), findsNothing);
  });

  testWidgets('uses themed regular CTA height on roomy alphabet layouts', (
    WidgetTester tester,
  ) async {
    _setSurfaceSize(tester, const Size(1024, 768));
    final customLayout = KidLayoutTheme(
      button: KidButtonTokens(
        regular: KidLayoutTheme.defaults.button.regular.copyWith(height: 88),
        compact: KidLayoutTheme.defaults.button.compact.copyWith(height: 41),
      ),
      panel: KidLayoutTheme.defaults.panel,
    );
    final repository = AlphabetLessonRepository(
      assetBundle: _FakeAssetBundle({
        AlphabetLessonRepository.manifestPath: jsonEncode({
          'lessons': [_alphabetLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildKidTheme().copyWith(extensions: [customLayout]),
        home: AlphabetLearnScreen(
          repository: repository,
          lessonId: 'alphabet_letters_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cta = _ctaButton(tester);

    expect(cta.height, isNull);
    expect(cta.density, ToyButtonDensity.regular);
    expect(
      tester.getSize(find.widgetWithText(ToyButton, '다음')).height,
      customLayout.button.regular.height,
    );
  });

  testWidgets('uses themed compact CTA height on compact alphabet layouts', (
    WidgetTester tester,
  ) async {
    _setSurfaceSize(tester, const Size(780, 360));
    final customLayout = KidLayoutTheme(
      button: KidButtonTokens(
        regular: KidLayoutTheme.defaults.button.regular.copyWith(height: 88),
        compact: KidLayoutTheme.defaults.button.compact.copyWith(height: 41),
      ),
      panel: KidLayoutTheme.defaults.panel,
    );
    final repository = AlphabetLessonRepository(
      assetBundle: _FakeAssetBundle({
        AlphabetLessonRepository.manifestPath: jsonEncode({
          'lessons': [_alphabetLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildKidTheme().copyWith(extensions: [customLayout]),
        home: AlphabetLearnScreen(
          repository: repository,
          lessonId: 'alphabet_letters_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cta = _ctaButton(tester);

    expect(cta.height, isNull);
    expect(cta.density, ToyButtonDensity.compact);
    expect(
      tester.getSize(find.widgetWithText(ToyButton, '다음')).height,
      customLayout.button.compact.height,
    );
  });

  testWidgets('inherits regular ToyPanel density on roomy alphabet layouts', (
    WidgetTester tester,
  ) async {
    _setSurfaceSize(tester, const Size(1024, 768));
    final repository = AlphabetLessonRepository(
      assetBundle: _FakeAssetBundle({
        AlphabetLessonRepository.manifestPath: jsonEncode({
          'lessons': [_alphabetLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AlphabetLearnScreen(
          repository: repository,
          lessonId: 'alphabet_letters_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final symbolPanel = _panelForText(tester, 'A a');
    final hintPanel = _panelForText(tester, '천천히 해봐!');

    expect(symbolPanel.density, ToyPanelDensity.regular);
    expect(symbolPanel.padding, isNull);
    expect(hintPanel.density, ToyPanelDensity.regular);
    expect(hintPanel.padding, isNull);
  });

  testWidgets('inherits compact ToyPanel density on compact alphabet layouts', (
    WidgetTester tester,
  ) async {
    _setSurfaceSize(tester, const Size(780, 360));
    final repository = AlphabetLessonRepository(
      assetBundle: _FakeAssetBundle({
        AlphabetLessonRepository.manifestPath: jsonEncode({
          'lessons': [_alphabetLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AlphabetLearnScreen(
          repository: repository,
          lessonId: 'alphabet_letters_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final symbolPanel = _panelForText(tester, 'A a');
    final hintPanel = _panelForText(tester, '천천히!');

    expect(symbolPanel.density, ToyPanelDensity.compact);
    expect(symbolPanel.padding, isNull);
    expect(hintPanel.density, ToyPanelDensity.compact);
    expect(hintPanel.padding, isNull);
  });

  testWidgets(
    'keeps the alphabet learn screen stable on a compact landscape phone',
    (WidgetTester tester) async {
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
          home: AlphabetLearnScreen(
            repository: repository,
            lessonId: 'alphabet_letters_1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('에이, A a'), findsOneWidget);
    },
  );

  testWidgets('shows an error message when the alphabet lesson fails to load', (
    WidgetTester tester,
  ) async {
    final repository = AlphabetLessonRepository(
      assetBundle: _FakeAssetBundle({}),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AlphabetLearnScreen(
          repository: repository,
          lessonId: 'alphabet_letters_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('알파벳 카드를 불러오지 못했어요.'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });
}

const Map<String, dynamic> _alphabetLesson = {
  'id': 'alphabet_letters_1',
  'title': '알파벳 1',
  'cards': [
    {'symbol': 'A a', 'label': '에이, A a', 'hint': '에이를 크게 보고 소리를 따라 말해봐요'},
    {'symbol': 'B b', 'label': '비, B b', 'hint': '비를 보며 입으로 비 하고 말해봐요'},
    {'symbol': 'C c', 'label': '씨, C c', 'hint': '씨를 보고 입모양을 동그랗게 해봐요'},
    {'symbol': 'D d', 'label': '디, D d', 'hint': '디를 보며 손가락으로 천천히 짚어봐요'},
    {'symbol': 'E e', 'label': '이, E e', 'hint': '이를 보고 환하게 따라 말해봐요'},
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
  required Widget child,
}) {
  return MaterialApp(
    home: AppServicesScope(
      services: AppServices(
        progressStore: progressStore,
        speechCueService: NoopSpeechCueService(),
      ),
      child: child,
    ),
  );
}

void _setSurfaceSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

ToyButton _ctaButton(WidgetTester tester) {
  return tester.widget<ToyButton>(find.widgetWithText(ToyButton, '다음'));
}

ToyPanel _panelForText(WidgetTester tester, String text) {
  final panelFinder = find.ancestor(
    of: find.text(text),
    matching: find.byType(ToyPanel),
  );
  expect(panelFinder, findsOneWidget);
  return tester.widget<ToyPanel>(panelFinder);
}
