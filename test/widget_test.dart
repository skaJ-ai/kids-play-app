import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/features/avatar/presentation/avatar_setup_screen.dart';
import 'package:kids_play_app/features/hangul/data/hangul_lesson_repository.dart';
import 'package:kids_play_app/features/home/data/home_catalog_repository.dart';
import 'package:kids_play_app/features/home/presentation/category_hub_screen.dart';
import 'package:kids_play_app/features/home/presentation/home_screen.dart';
import 'package:kids_play_app/main.dart';

void main() {
  testWidgets('shows hero screen with app title, hero face, and play button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KidsPlayApp());

    expect(find.byKey(const Key('playground-background')), findsOneWidget);
    expect(find.byKey(const Key('hero-face-image')), findsOneWidget);
    expect(find.text('승원이의 빵빵 놀이터'), findsOneWidget);
    expect(find.text('플레이하기'), findsOneWidget);
    expect(find.text('빵빵 출발!'), findsOneWidget);
  });

  testWidgets('keeps the hero screen stable on a compact landscape phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(780, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const KidsPlayApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('플레이하기'), findsOneWidget);
  });

  testWidgets('opens the avatar setup screen after five taps on the hero face', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KidsPlayApp());

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
  });

  testWidgets('moves from hero screen to category menu when play is tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KidsPlayApp());

    await tester.tap(find.text('플레이하기'));
    await tester.pumpAndSettle();

    expect(find.text('어떤 놀이터로 갈까?'), findsOneWidget);
    expect(find.text('한글'), findsOneWidget);
    expect(find.text('알파벳'), findsOneWidget);
    expect(find.text('숫자'), findsOneWidget);
  });

  testWidgets('shows hangul category hub with learn and game buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildHangulCategoryHub());

    expect(find.text('한글 놀이터'), findsOneWidget);
    expect(find.text('학습하기'), findsOneWidget);
    expect(find.text('게임하기'), findsOneWidget);
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
    expect(find.text('학습하기'), findsOneWidget);
    expect(find.text('게임하기'), findsOneWidget);
  });

  testWidgets('opens the first hangul learning card from the category hub', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildHangulCategoryHub(repository: _fakeHangulRepository()),
    );

    await tester.tap(find.text('학습하기'));
    await tester.pumpAndSettle();

    expect(find.text('한글 학습'), findsOneWidget);
    expect(find.text('기역, ㄱ'), findsOneWidget);
    expect(find.text('다음'), findsOneWidget);
  });

  testWidgets('opens the first hangul quiz from the category hub', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildHangulCategoryHub(repository: _fakeHangulRepository()),
    );

    await tester.tap(find.text('게임하기'));
    await tester.pumpAndSettle();

    expect(find.text('한글 게임'), findsOneWidget);
    expect(find.text("'ㄱ' 글자를 찾아봐!"), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);
  });

  testWidgets('keeps unsupported alphabet buttons disabled in the category hub', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CategoryHubScreen(
          category: const HomeCategory(
            id: 'alphabet',
            label: '알파벳',
            description: '대문자와 소문자를 만나요',
            backgroundColorHex: '#B9F4D0',
            iconName: 'abc_rounded',
          ),
        ),
      ),
    );

    await tester.tap(find.text('게임하기'));
    await tester.pumpAndSettle();

    expect(find.text('알파벳 놀이터'), findsOneWidget);
    expect(find.text('곧 만나요'), findsNWidgets(2));
    expect(find.text('한글 게임'), findsNothing);
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

    expect(find.text('놀이터를 불러오지 못했어요.'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
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
    expect(find.text('어떤 놀이터로 갈까?'), findsOneWidget);
  });
}

Widget _buildHangulCategoryHub({HangulLessonRepository? repository}) {
  return MaterialApp(
    home: CategoryHubScreen(
      category: const HomeCategory(
        id: 'hangul',
        label: '한글',
        description: '자음과 모음을 만나요',
        backgroundColorHex: '#FFE699',
        iconName: 'text_fields_rounded',
      ),
      hangulLessonRepository: repository,
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
