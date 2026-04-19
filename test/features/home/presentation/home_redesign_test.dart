import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/features/hangul/data/hangul_lesson_repository.dart';
import 'package:kids_play_app/features/home/data/home_catalog_repository.dart';
import 'package:kids_play_app/features/home/presentation/category_hub_screen.dart';
import 'package:kids_play_app/features/home/presentation/home_category_config.dart';
import 'package:kids_play_app/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('compact home hides roomy helper copy and uses compact labels', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(780, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(catalogRepository: _fakeHomeCatalogRepository()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('오늘의 차고'), findsOneWidget);
    expect(find.text('천천히 고르고 출발'), findsNothing);
    expect(find.text('차고 열기'), findsNothing);
    expect(find.text('자모 소리'), findsOneWidget);
    expect(find.text('A a B b'), findsOneWidget);
    expect(find.text('세고 맞혀요'), findsOneWidget);
    expect(find.text('자음과 모음을 만나요'), findsNothing);
    expect(find.text('대문자와 소문자를 만나요'), findsNothing);
    expect(find.text('숫자 놀이를 시작해요'), findsNothing);
  });

  testWidgets(
    'compact hub keeps condensed tags visible and hides wide helper copy',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(780, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: CategoryHubScreen(
            category: HomeCategory(
              id: 'hangul',
              label: '한글',
              description: '자음과 모음을 만나요',
              backgroundColorHex: '#FFE699',
              iconName: 'text_fields_rounded',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('한글 차고'), findsOneWidget);
      expect(find.text('배우고 바로 출발!'), findsNothing);
      expect(find.text('천천히'), findsOneWidget);
      expect(find.text('도전'), findsOneWidget);
      expect(find.text('배우기'), findsOneWidget);
      expect(find.text('퀴즈'), findsOneWidget);
      expect(find.text('큰 카드로 천천히'), findsOneWidget);
      expect(find.text('듣고 바로 맞혀요'), findsOneWidget);
      expect(find.text('바로 시작'), findsNWidgets(2));
      expect(find.byIcon(Icons.arrow_outward_rounded), findsNothing);
    },
  );

  testWidgets('category hub shows the recent reward summary for its category', (
    WidgetTester tester,
  ) async {
    final progressStore = MemoryProgressStore(
      AppProgressSnapshot(
        lastEarnedReward: RecentReward(
          kind: 'sticker',
          amount: 2,
          lessonId: 'hangul:basic_consonants_1',
          earnedAt: DateTime.utc(2026, 4, 19, 9, 0),
        ),
      ),
    );

    await tester.pumpWidget(
      _wrapWithServices(
        progressStore: progressStore,
        child: const CategoryHubScreen(
          category: HomeCategory(
            id: 'hangul',
            label: '한글',
            description: '자음과 모음을 만나요',
            backgroundColorHex: '#FFE699',
            iconName: 'text_fields_rounded',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('최근 보상'), findsOneWidget);
    expect(find.text('스티커 2개'), findsOneWidget);
  });

  testWidgets(
    'category hub refreshes the recent reward summary after returning from a child route',
    (WidgetTester tester) async {
      final progressStore = MemoryProgressStore();
      final repository = HangulLessonRepository(
        assetBundle: _FakeAssetBundle({
          HangulLessonRepository.manifestPath: jsonEncode({
            'lessons': [_hangulLessonOne],
          }),
        }),
      );

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

      expect(find.text('최근 보상'), findsNothing);

      await tester.tap(find.text('배우기'));
      await tester.pumpAndSettle();
      expect(find.text('기본 자음 1'), findsOneWidget);

      await progressStore.recordRewardEarned(
        kind: 'sticker',
        amount: 1,
        lessonId: 'hangul:basic_consonants_1',
        earnedAt: DateTime.utc(2026, 4, 19, 9, 30),
      );
      Navigator.of(tester.element(find.text('기본 자음 1'))).pop();
      await tester.pumpAndSettle();

      expect(find.text('최근 보상'), findsOneWidget);
      expect(find.text('스티커 1개'), findsOneWidget);
    },
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

const Map<String, dynamic> _hangulLessonOne = {
  'id': 'basic_consonants_1',
  'title': '기본 자음 1',
  'cards': [
    {'symbol': 'ㄱ', 'label': '기역, ㄱ', 'hint': '기역을 천천히 봐요'},
    {'symbol': 'ㄴ', 'label': '니은, ㄴ', 'hint': '니은을 천천히 봐요'},
    {'symbol': 'ㄷ', 'label': '디귿, ㄷ', 'hint': '디귿을 천천히 봐요'},
    {'symbol': 'ㄹ', 'label': '리을, ㄹ', 'hint': '리을을 천천히 봐요'},
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
