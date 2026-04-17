import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/features/alphabet/data/alphabet_lesson_repository.dart';
import 'package:kids_play_app/features/avatar/presentation/avatar_setup_screen.dart';
import 'package:kids_play_app/features/hangul/data/hangul_lesson_repository.dart';
import 'package:kids_play_app/features/home/data/home_catalog_repository.dart';
import 'package:kids_play_app/features/home/presentation/home_category_config.dart';
import 'package:kids_play_app/features/home/presentation/category_hub_screen.dart';
import 'package:kids_play_app/features/home/presentation/home_screen.dart';
import 'package:kids_play_app/features/numbers/data/numbers_lesson_repository.dart';
import 'package:kids_play_app/main.dart';

void main() {
  testWidgets(
    'shows hero screen with premium drive-room copy and primary cta',
    (WidgetTester tester) async {
      await tester.pumpWidget(KidsPlayApp());

      expect(find.byKey(const Key('playground-background')), findsOneWidget);
      expect(find.byKey(const Key('hero-face-image')), findsOneWidget);
      expect(find.text('승원이의 빵빵 놀이터'), findsOneWidget);
      expect(find.text('오늘의 드라이브'), findsOneWidget);
      expect(find.text('차 타고 출발!'), findsOneWidget);
      expect(find.text('놀이 시작'), findsOneWidget);
    },
  );

  testWidgets('keeps the hero screen stable on a compact landscape phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(780, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(KidsPlayApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('놀이 시작'), findsOneWidget);
  });

  testWidgets(
    'opens the avatar setup screen after five taps on the hero face',
    (WidgetTester tester) async {
      await tester.pumpWidget(KidsPlayApp());

      final heroEntry = find.byKey(const Key('hero-face-parent-entry'));
      expect(heroEntry, findsOneWidget);

      for (var i = 0; i < 4; i++) {
        await tester.tap(heroEntry);
        await tester.pump();
      }

      expect(find.byType(AvatarSetupScreen), findsNothing);

      await tester.tap(heroEntry);
      await tester.pumpAndSettle();

      expect(find.byType(AvatarSetupScreen), findsOneWidget);
      expect(find.text('표정 카드 만들기'), findsOneWidget);
    },
  );

  testWidgets(
    'moves from hero screen to the shorter premium category garage menu',
    (WidgetTester tester) async {
      await tester.pumpWidget(KidsPlayApp());

      await tester.tap(find.text('놀이 시작'));
      await tester.pumpAndSettle();

      expect(find.text('어떤 차고로 갈까?'), findsOneWidget);
      expect(find.text('좋아하는 차고를 콕 눌러요.'), findsOneWidget);
      expect(find.text('한글'), findsOneWidget);
      expect(find.text('알파벳'), findsOneWidget);
      expect(find.text('숫자'), findsOneWidget);
      expect(find.text('자모 소리'), findsOneWidget);
      expect(find.text('A a B b'), findsOneWidget);
      expect(find.text('세고 맞혀요'), findsOneWidget);
    },
  );

  testWidgets('shows the hangul garage hub with shorter mode labels', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildHangulCategoryHub());

    expect(find.text('한글 차고'), findsOneWidget);
    expect(find.text('어떻게 놀까?'), findsOneWidget);
    expect(find.text('배우기'), findsOneWidget);
    expect(find.text('퀴즈'), findsOneWidget);
  });

  testWidgets('keeps the category hub stable on a compact landscape phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(780, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildHangulCategoryHub());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('배우기'), findsOneWidget);
    expect(find.text('퀴즈'), findsOneWidget);
  });

  testWidgets('opens the first hangul learning card from the category hub', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildHangulCategoryHub(
        categoryDependencies: HomeCategoryDependencies(
          hangulLessonRepository: _fakeHangulRepository(),
        ),
      ),
    );

    await tester.tap(find.text('배우기'));
    await tester.pumpAndSettle();

    expect(find.text('한글 학습'), findsOneWidget);
    expect(find.text('기역, ㄱ'), findsOneWidget);
    expect(find.text('다음'), findsOneWidget);
  });

  testWidgets('opens the first hangul quiz from the category hub', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildHangulCategoryHub(
        categoryDependencies: HomeCategoryDependencies(
          hangulLessonRepository: _fakeHangulRepository(),
        ),
      ),
    );

    await tester.tap(find.text('퀴즈'));
    await tester.pumpAndSettle();

    expect(find.text('한글 게임'), findsOneWidget);
    expect(find.text("'ㄱ' 글자를 찾아봐!"), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);
  });

  testWidgets('opens the first hangul learning card from the home flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildHomeScreen(
        categoryDependencies: HomeCategoryDependencies(
          hangulLessonRepository: _fakeHangulRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('한글'));
    await tester.pumpAndSettle();

    expect(find.text('한글 차고'), findsOneWidget);
    expect(find.text('준비 중'), findsNothing);

    await tester.tap(find.text('배우기'));
    await tester.pumpAndSettle();

    expect(find.text('한글 학습'), findsOneWidget);
    expect(find.text('기역, ㄱ'), findsOneWidget);
    expect(find.text('다음'), findsOneWidget);
  });

  testWidgets('opens the alphabet learn screen from the home flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildHomeScreen(
        categoryDependencies: HomeCategoryDependencies(
          alphabetLessonRepository: _fakeAlphabetRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('알파벳'));
    await tester.pumpAndSettle();

    expect(find.text('알파벳 차고'), findsOneWidget);
    expect(find.text('준비 중'), findsNothing);

    await tester.tap(find.text('배우기'));
    await tester.pumpAndSettle();

    expect(find.text('알파벳 학습'), findsOneWidget);
    expect(find.text('에이, A a'), findsOneWidget);
    expect(find.text('다음'), findsOneWidget);
  });

  testWidgets('opens the alphabet quiz from the category hub', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildAlphabetCategoryHub(
        categoryDependencies: HomeCategoryDependencies(
          alphabetLessonRepository: _fakeAlphabetRepository(),
        ),
      ),
    );

    expect(find.text('준비 중'), findsNothing);

    await tester.tap(find.text('퀴즈'));
    await tester.pumpAndSettle();

    expect(find.text('알파벳 게임'), findsOneWidget);
    expect(find.text("'A a' 글자를 찾아봐!"), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);
  });

  testWidgets('opens the numbers learn screen from the category hub', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildNumbersCategoryHub(
        categoryDependencies: HomeCategoryDependencies(
          numbersLessonRepository: _fakeNumbersRepository(),
        ),
      ),
    );

    expect(find.text('준비 중'), findsNothing);

    await tester.tap(find.text('배우기'));
    await tester.pumpAndSettle();

    expect(find.text('숫자 학습'), findsOneWidget);
    expect(find.text('하나, 1'), findsOneWidget);
    expect(find.text('다음'), findsOneWidget);
  });

  testWidgets('opens the numbers quiz screen from the home flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildHomeScreen(
        categoryDependencies: HomeCategoryDependencies(
          numbersLessonRepository: _fakeNumbersRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('숫자'));
    await tester.pumpAndSettle();

    expect(find.text('숫자 차고'), findsOneWidget);
    expect(find.text('준비 중'), findsNothing);

    await tester.tap(find.text('퀴즈'));
    await tester.pumpAndSettle();

    expect(find.text('숫자 게임'), findsOneWidget);
    expect(find.text("'1' 숫자를 찾아봐!"), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);
  });

  testWidgets('shows an error state when home categories fail to load', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: _FailingAssetBundle(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('차고를 불러오지 못했어요.'), findsOneWidget);
    expect(find.text('다시 보기'), findsOneWidget);
  });

  testWidgets('keeps the home screen stable on a compact landscape phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(780, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: _FakeAssetBundle({
          HomeCatalogRepository.manifestPath: jsonEncode({
            'categories': [
              {
                'id': 'hangul',
                'label': '한글',
                'description': '자음과 모음을 만나요',
                'backgroundColor': '#FFE699',
                'icon': 'text_fields_rounded',
              },
              {
                'id': 'alphabet',
                'label': '알파벳',
                'description': '대문자와 소문자를 만나요',
                'backgroundColor': '#B9F4D0',
                'icon': 'abc_rounded',
              },
              {
                'id': 'numbers',
                'label': '숫자',
                'description': '숫자 놀이를 시작해요',
                'backgroundColor': '#FFC6D9',
                'icon': 'looks_one_rounded',
              },
            ],
          }),
        }),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('어떤 차고로 갈까?'), findsOneWidget);
  });
}

Widget _buildHangulCategoryHub({
  HomeCategoryDependencies? categoryDependencies,
}) {
  return MaterialApp(
    home: CategoryHubScreen(
      category: const HomeCategory(
        id: 'hangul',
        label: '한글',
        description: '자음과 모음을 만나요',
        backgroundColorHex: '#FFE699',
        iconName: 'text_fields_rounded',
      ),
      categoryDependencies:
          categoryDependencies ?? const HomeCategoryDependencies(),
    ),
  );
}

Widget _buildAlphabetCategoryHub({
  HomeCategoryDependencies? categoryDependencies,
}) {
  return MaterialApp(
    home: CategoryHubScreen(
      category: const HomeCategory(
        id: 'alphabet',
        label: '알파벳',
        description: '대문자와 소문자를 만나요',
        backgroundColorHex: '#B9F4D0',
        iconName: 'abc_rounded',
      ),
      categoryDependencies:
          categoryDependencies ?? const HomeCategoryDependencies(),
    ),
  );
}

Widget _buildNumbersCategoryHub({
  HomeCategoryDependencies? categoryDependencies,
}) {
  return MaterialApp(
    home: CategoryHubScreen(
      category: const HomeCategory(
        id: 'numbers',
        label: '숫자',
        description: '숫자 놀이를 시작해요',
        backgroundColorHex: '#FFC6D9',
        iconName: 'looks_one_rounded',
      ),
      categoryDependencies:
          categoryDependencies ?? const HomeCategoryDependencies(),
    ),
  );
}

Widget _buildHomeScreen({
  HomeCatalogRepository? catalogRepository,
  HomeCategoryDependencies? categoryDependencies,
}) {
  return MaterialApp(
    home: HomeScreen(
      catalogRepository: catalogRepository ?? _fakeHomeCatalogRepository(),
      categoryDependencies:
          categoryDependencies ?? const HomeCategoryDependencies(),
    ),
  );
}

HangulLessonRepository _fakeHangulRepository() {
  return HangulLessonRepository(
    assetBundle: _FakeAssetBundle({
      HangulLessonRepository.manifestPath: jsonEncode({
        'lessons': [_basicConsonantsLesson],
      }),
    }),
  );
}

AlphabetLessonRepository _fakeAlphabetRepository() {
  return AlphabetLessonRepository(
    assetBundle: _FakeAssetBundle({
      AlphabetLessonRepository.manifestPath: jsonEncode({
        'lessons': [_alphabetLesson],
      }),
    }),
  );
}

NumbersLessonRepository _fakeNumbersRepository() {
  return NumbersLessonRepository(
    assetBundle: _FakeAssetBundle({
      NumbersLessonRepository.manifestPath: jsonEncode({
        'lessons': [_numbersLesson],
      }),
    }),
  );
}

HomeCatalogRepository _fakeHomeCatalogRepository() {
  return HomeCatalogRepository(
    assetBundle: _FakeAssetBundle({
      HomeCatalogRepository.manifestPath: jsonEncode({
        'categories': [
          {
            'id': 'hangul',
            'label': '한글',
            'description': '자음과 모음을 만나요',
            'backgroundColor': '#FFE699',
            'icon': 'text_fields_rounded',
          },
          {
            'id': 'alphabet',
            'label': '알파벳',
            'description': '대문자와 소문자를 만나요',
            'backgroundColor': '#B9F4D0',
            'icon': 'abc_rounded',
          },
          {
            'id': 'numbers',
            'label': '숫자',
            'description': '숫자 놀이를 시작해요',
            'backgroundColor': '#FFC6D9',
            'icon': 'looks_one_rounded',
          },
        ],
      }),
    }),
  );
}

const Map<String, dynamic> _basicConsonantsLesson = {
  'id': 'basic_consonants_1',
  'title': '기본 자음 1',
  'cards': [
    {'symbol': 'ㄱ', 'label': '기역, ㄱ', 'hint': '큰 카드로 기역을 천천히 보고 눌러봐요'},
    {'symbol': 'ㄴ', 'label': '니은, ㄴ', 'hint': '니은을 만나고 입으로 따라 말해봐요'},
    {'symbol': 'ㄷ', 'label': '디귿, ㄷ', 'hint': '디귿을 보고 손가락으로 콕 눌러봐요'},
    {'symbol': 'ㄹ', 'label': '리을, ㄹ', 'hint': '리을 모양을 천천히 눈으로 따라가봐요'},
    {'symbol': 'ㅁ', 'label': '미음, ㅁ', 'hint': '미음을 보며 입모양을 떠올려봐요'},
  ],
};

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

class _FailingAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    throw Exception('boom: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    throw Exception('boom: $key');
  }
}
