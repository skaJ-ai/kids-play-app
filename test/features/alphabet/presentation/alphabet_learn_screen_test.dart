import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/app/ui/mascot_view.dart';
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
    expect(find.byKey(const Key('learn-spoken-caption')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('learn-spoken-caption'))).data,
      '에이',
    );
    expect(find.text('1 / 5'), findsOneWidget);
    expect(find.byType(MascotView), findsOneWidget);

    await tester.tap(find.byKey(const Key('learn-next-button')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const Key('learn-spoken-caption'))).data,
      '비',
    );
    expect(find.text('2 / 5'), findsOneWidget);
  });

  testWidgets('tapping the glyph card switches the mascot to correct pose',
      (WidgetTester tester) async {
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

    final initial =
        tester.widget<MascotView>(find.byKey(const Key('learn-mascot')));
    expect(initial.state, MascotState.idle);

    await tester.tap(find.byKey(const Key('learn-glyph-card')));
    await tester.pump();

    final after =
        tester.widget<MascotView>(find.byKey(const Key('learn-mascot')));
    expect(after.state, MascotState.correct);

    // Let the reset timer fire so the state falls back to idle.
    await tester.pump(const Duration(milliseconds: 950));
    final reset =
        tester.widget<MascotView>(find.byKey(const Key('learn-mascot')));
    expect(reset.state, MascotState.idle);
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

    expect(
      tester.widget<Text>(find.byKey(const Key('learn-spoken-caption'))).data,
      '씨',
    );
    expect(find.text('3 / 5'), findsOneWidget);
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
      expect(find.byKey(const Key('learn-spoken-caption')), findsOneWidget);
      expect(find.byKey(const Key('learn-next-button')), findsOneWidget);
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
    {'symbol': 'A', 'display': 'A', 'spoken': '에이', 'hint': '에이를 크게 보고 소리를 따라 말해봐요'},
    {'symbol': 'B', 'display': 'B', 'spoken': '비', 'hint': '비를 보며 입으로 비 하고 말해봐요'},
    {'symbol': 'C', 'display': 'C', 'spoken': '씨', 'hint': '씨를 보고 입모양을 동그랗게 해봐요'},
    {'symbol': 'D', 'display': 'D', 'spoken': '디', 'hint': '디를 보며 손가락으로 천천히 짚어봐요'},
    {'symbol': 'E', 'display': 'E', 'spoken': '이', 'hint': '이를 보고 환하게 따라 말해봐요'},
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
