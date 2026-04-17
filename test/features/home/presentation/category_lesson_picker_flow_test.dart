import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/features/alphabet/data/alphabet_lesson_repository.dart';
import 'package:kids_play_app/features/alphabet/presentation/alphabet_learn_screen.dart';
import 'package:kids_play_app/features/hangul/data/hangul_lesson_repository.dart';
import 'package:kids_play_app/features/home/data/home_catalog_repository.dart';
import 'package:kids_play_app/features/home/presentation/category_hub_screen.dart';
import 'package:kids_play_app/features/home/presentation/home_category_config.dart';
import 'package:kids_play_app/features/numbers/data/numbers_lesson_repository.dart';
import 'package:kids_play_app/features/numbers/presentation/numbers_learn_screen.dart';

void main() {
  testWidgets(
    'shows a lesson picker before opening hangul learn when multiple sets exist',
    (WidgetTester tester) async {
      final repository = HangulLessonRepository(
        assetBundle: _FakeAssetBundle({
          HangulLessonRepository.manifestPath: jsonEncode({
            'lessons': [_hangulLessonOne, _hangulLessonTwo],
          }),
        }),
      );
      final progressStore = MemoryProgressStore();
      await progressStore.setLessonUnlocked('hangul:basic_consonants_2', true);

      await tester.pumpWidget(
        _wrapWithServices(
          progressStore: progressStore,
          child: CategoryHubScreen(
            category: const HomeCategory(
              id: 'hangul',
              label: '한글',
              description: '자음과 모음을 만나요',
              backgroundColorHex: '#FFE699',
              iconName: 'text_fields_rounded',
            ),
            categoryDependencies: HomeCategoryDependencies(
              hangulLessonRepository: repository,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('배우기'));
      await tester.pumpAndSettle();

      expect(find.text('기본 자음 1'), findsOneWidget);
      expect(find.text('기본 자음 2'), findsOneWidget);

      await tester.tap(find.text('기본 자음 2'));
      await tester.pumpAndSettle();

      expect(find.text('한글 학습'), findsOneWidget);
      expect(find.text('비읍, ㅂ'), findsOneWidget);
    },
  );

  testWidgets('shows later hangul sets as locked until a parent unlocks them', (
    WidgetTester tester,
  ) async {
    final repository = HangulLessonRepository(
      assetBundle: _FakeAssetBundle({
        HangulLessonRepository.manifestPath: jsonEncode({
          'lessons': [_hangulLessonOne, _hangulLessonTwo],
        }),
      }),
    );
    final progressStore = MemoryProgressStore();

    await tester.pumpWidget(
      _wrapWithServices(
        progressStore: progressStore,
        child: CategoryHubScreen(
          category: const HomeCategory(
            id: 'hangul',
            label: '한글',
            description: '자음과 모음을 만나요',
            backgroundColorHex: '#FFE699',
            iconName: 'text_fields_rounded',
          ),
          categoryDependencies: HomeCategoryDependencies(
            hangulLessonRepository: repository,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('배우기'));
    await tester.pumpAndSettle();

    expect(find.text('잠겨 있어요'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('lesson-picker-item-basic_consonants_2')),
    );
    await tester.pumpAndSettle();

    expect(find.text('한글 학습'), findsNothing);
    expect(find.text('비읍, ㅂ'), findsNothing);
  });

  testWidgets('opens later hangul sets after a parent unlocks them', (
    WidgetTester tester,
  ) async {
    final repository = HangulLessonRepository(
      assetBundle: _FakeAssetBundle({
        HangulLessonRepository.manifestPath: jsonEncode({
          'lessons': [_hangulLessonOne, _hangulLessonTwo],
        }),
      }),
    );
    final progressStore = MemoryProgressStore();
    await progressStore.setLessonUnlocked('hangul:basic_consonants_2', true);

    await tester.pumpWidget(
      _wrapWithServices(
        progressStore: progressStore,
        child: CategoryHubScreen(
          category: const HomeCategory(
            id: 'hangul',
            label: '한글',
            description: '자음과 모음을 만나요',
            backgroundColorHex: '#FFE699',
            iconName: 'text_fields_rounded',
          ),
          categoryDependencies: HomeCategoryDependencies(
            hangulLessonRepository: repository,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('배우기'));
    await tester.pumpAndSettle();

    expect(find.text('잠겨 있어요'), findsNothing);

    await tester.tap(
      find.byKey(const Key('lesson-picker-item-basic_consonants_2')),
    );
    await tester.pumpAndSettle();

    expect(find.text('한글 학습'), findsOneWidget);
    expect(find.text('비읍, ㅂ'), findsOneWidget);
  });

  testWidgets(
    'shows a lesson picker before opening numbers learn when multiple sets exist',
    (WidgetTester tester) async {
      final repository = NumbersLessonRepository(
        assetBundle: _FakeAssetBundle({
          NumbersLessonRepository.manifestPath: jsonEncode({
            'lessons': [_numbersLessonOne, _numbersLessonTwo],
          }),
        }),
      );
      final progressStore = MemoryProgressStore();
      await progressStore.setLessonUnlocked('numbers:numbers_count_2', true);

      await tester.pumpWidget(
        _wrapWithServices(
          progressStore: progressStore,
          child: CategoryHubScreen(
            category: const HomeCategory(
              id: 'numbers',
              label: '숫자',
              description: '숫자 놀이를 시작해요',
              backgroundColorHex: '#FFC6D9',
              iconName: 'looks_one_rounded',
            ),
            categoryDependencies: HomeCategoryDependencies(
              numbersLessonRepository: repository,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('배우기'));
      await tester.pumpAndSettle();

      expect(find.text('숫자 학습'), findsNothing);
      expect(find.text('숫자 1부터 5까지'), findsOneWidget);
      expect(find.text('숫자 6부터 10까지'), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('lesson-picker-item-numbers_count_2')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NumbersLearnScreen), findsOneWidget);
      expect(find.text('숫자 학습'), findsOneWidget);
      expect(find.text('여섯, 6'), findsOneWidget);
    },
  );

  testWidgets(
    'shows a lesson picker before opening numbers quiz when multiple sets exist',
    (WidgetTester tester) async {
      final repository = NumbersLessonRepository(
        assetBundle: _FakeAssetBundle({
          NumbersLessonRepository.manifestPath: jsonEncode({
            'lessons': [_numbersLessonOne, _numbersLessonTwo],
          }),
        }),
      );
      final progressStore = MemoryProgressStore();
      await progressStore.setLessonUnlocked('numbers:numbers_count_2', true);

      await tester.pumpWidget(
        _wrapWithServices(
          progressStore: progressStore,
          child: CategoryHubScreen(
            category: const HomeCategory(
              id: 'numbers',
              label: '숫자',
              description: '숫자 놀이를 시작해요',
              backgroundColorHex: '#FFC6D9',
              iconName: 'looks_one_rounded',
            ),
            categoryDependencies: HomeCategoryDependencies(
              numbersLessonRepository: repository,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('퀴즈'));
      await tester.pumpAndSettle();

      expect(find.text('숫자 1부터 5까지'), findsOneWidget);
      expect(find.text('숫자 6부터 10까지'), findsOneWidget);

      await tester.tap(find.text('숫자 6부터 10까지'));
      await tester.pumpAndSettle();

      expect(find.text('숫자 게임'), findsOneWidget);
      expect(find.text("'6' 숫자를 찾아봐!"), findsOneWidget);
    },
  );

  testWidgets(
    'shows a lesson picker before opening alphabet learn when multiple sets exist',
    (WidgetTester tester) async {
      final repository = AlphabetLessonRepository(
        assetBundle: _FakeAssetBundle({
          AlphabetLessonRepository.manifestPath: jsonEncode({
            'lessons': [_alphabetLessonOne, _alphabetLessonTwo],
          }),
        }),
      );
      final progressStore = MemoryProgressStore();
      await progressStore.setLessonUnlocked(
        'alphabet:alphabet_letters_2',
        true,
      );

      await tester.pumpWidget(
        _wrapWithServices(
          progressStore: progressStore,
          child: CategoryHubScreen(
            category: const HomeCategory(
              id: 'alphabet',
              label: '알파벳',
              description: '대문자와 소문자를 만나요',
              backgroundColorHex: '#B9F4D0',
              iconName: 'abc_rounded',
            ),
            categoryDependencies: HomeCategoryDependencies(
              alphabetLessonRepository: repository,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('배우기'));
      await tester.pumpAndSettle();

      expect(find.text('알파벳 학습'), findsNothing);
      expect(find.text('알파벳 1'), findsOneWidget);
      expect(find.text('알파벳 2'), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('lesson-picker-item-alphabet_letters_2')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AlphabetLearnScreen), findsOneWidget);
      expect(find.text('알파벳 학습'), findsOneWidget);
      expect(find.text('에프, F f'), findsOneWidget);
    },
  );

  testWidgets(
    'shows a lesson picker before opening alphabet quiz when multiple sets exist',
    (WidgetTester tester) async {
      final repository = AlphabetLessonRepository(
        assetBundle: _FakeAssetBundle({
          AlphabetLessonRepository.manifestPath: jsonEncode({
            'lessons': [_alphabetLessonOne, _alphabetLessonTwo],
          }),
        }),
      );
      final progressStore = MemoryProgressStore();
      await progressStore.setLessonUnlocked(
        'alphabet:alphabet_letters_2',
        true,
      );

      await tester.pumpWidget(
        _wrapWithServices(
          progressStore: progressStore,
          child: CategoryHubScreen(
            category: const HomeCategory(
              id: 'alphabet',
              label: '알파벳',
              description: '대문자와 소문자를 만나요',
              backgroundColorHex: '#B9F4D0',
              iconName: 'abc_rounded',
            ),
            categoryDependencies: HomeCategoryDependencies(
              alphabetLessonRepository: repository,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('퀴즈'));
      await tester.pumpAndSettle();

      expect(find.text('알파벳 1'), findsOneWidget);
      expect(find.text('알파벳 2'), findsOneWidget);

      await tester.tap(find.text('알파벳 2'));
      await tester.pumpAndSettle();

      expect(find.text('알파벳 게임'), findsOneWidget);
      expect(find.text("'F f' 글자를 찾아봐!"), findsOneWidget);
    },
  );
}

const Map<String, dynamic> _hangulLessonOne = {
  'id': 'basic_consonants_1',
  'title': '기본 자음 1',
  'cards': [
    {'symbol': 'ㄱ', 'label': '기역, ㄱ', 'hint': '기역을 천천히 봐요'},
    {'symbol': 'ㄴ', 'label': '니은, ㄴ', 'hint': '니은을 천천히 봐요'},
    {'symbol': 'ㄷ', 'label': '디귿, ㄷ', 'hint': '디귿을 천천히 봐요'},
    {'symbol': 'ㄹ', 'label': '리을, ㄹ', 'hint': '리을을 천천히 봐요'},
    {'symbol': 'ㅁ', 'label': '미음, ㅁ', 'hint': '미음을 천천히 봐요'},
  ],
};

const Map<String, dynamic> _hangulLessonTwo = {
  'id': 'basic_consonants_2',
  'title': '기본 자음 2',
  'cards': [
    {'symbol': 'ㅂ', 'label': '비읍, ㅂ', 'hint': '비읍을 천천히 봐요'},
    {'symbol': 'ㅅ', 'label': '시옷, ㅅ', 'hint': '시옷을 천천히 봐요'},
    {'symbol': 'ㅇ', 'label': '이응, ㅇ', 'hint': '이응을 천천히 봐요'},
    {'symbol': 'ㅈ', 'label': '지읒, ㅈ', 'hint': '지읒을 천천히 봐요'},
    {'symbol': 'ㅊ', 'label': '치읓, ㅊ', 'hint': '치읓을 천천히 봐요'},
  ],
};

const Map<String, dynamic> _alphabetLessonOne = {
  'id': 'alphabet_letters_1',
  'title': '알파벳 1',
  'cards': [
    {'symbol': 'A a', 'label': '에이, A a', 'hint': 'A를 천천히 말해봐요'},
    {'symbol': 'B b', 'label': '비, B b', 'hint': 'B를 천천히 말해봐요'},
    {'symbol': 'C c', 'label': '씨, C c', 'hint': 'C를 천천히 말해봐요'},
    {'symbol': 'D d', 'label': '디, D d', 'hint': 'D를 천천히 말해봐요'},
    {'symbol': 'E e', 'label': '이, E e', 'hint': 'E를 천천히 말해봐요'},
  ],
};

const Map<String, dynamic> _alphabetLessonTwo = {
  'id': 'alphabet_letters_2',
  'title': '알파벳 2',
  'cards': [
    {'symbol': 'F f', 'label': '에프, F f', 'hint': 'F를 천천히 말해봐요'},
    {'symbol': 'G g', 'label': '지, G g', 'hint': 'G를 천천히 말해봐요'},
    {'symbol': 'H h', 'label': '에이치, H h', 'hint': 'H를 천천히 말해봐요'},
    {'symbol': 'I i', 'label': '아이, I i', 'hint': 'I를 천천히 말해봐요'},
    {'symbol': 'J j', 'label': '제이, J j', 'hint': 'J를 천천히 말해봐요'},
  ],
};

const Map<String, dynamic> _numbersLessonOne = {
  'id': 'numbers_count_1',
  'title': '숫자 1부터 5까지',
  'cards': [
    {'symbol': '1', 'label': '하나, 1', 'hint': '하나를 세어봐요'},
    {'symbol': '2', 'label': '둘, 2', 'hint': '둘을 세어봐요'},
    {'symbol': '3', 'label': '셋, 3', 'hint': '셋을 세어봐요'},
    {'symbol': '4', 'label': '넷, 4', 'hint': '넷을 세어봐요'},
    {'symbol': '5', 'label': '다섯, 5', 'hint': '다섯을 세어봐요'},
  ],
};

const Map<String, dynamic> _numbersLessonTwo = {
  'id': 'numbers_count_2',
  'title': '숫자 6부터 10까지',
  'cards': [
    {'symbol': '6', 'label': '여섯, 6', 'hint': '여섯을 세어봐요'},
    {'symbol': '7', 'label': '일곱, 7', 'hint': '일곱을 세어봐요'},
    {'symbol': '8', 'label': '여덟, 8', 'hint': '여덟을 세어봐요'},
    {'symbol': '9', 'label': '아홉, 9', 'hint': '아홉을 세어봐요'},
    {'symbol': '10', 'label': '열, 10', 'hint': '열을 세어봐요'},
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
  return AppServicesScope(
    services: AppServices(
      progressStore: progressStore,
      speechCueService: NoopSpeechCueService(),
    ),
    child: MaterialApp(home: child),
  );
}
