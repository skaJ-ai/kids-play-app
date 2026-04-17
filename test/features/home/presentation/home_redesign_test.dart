import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';
import 'package:kids_play_app/features/home/data/home_catalog_repository.dart';
import 'package:kids_play_app/features/home/presentation/category_hub_screen.dart';
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
    _expectPanelGeometryForText(
      tester,
      text: '한글',
      expectedPadding: const EdgeInsets.all(14),
      expectedRadius: 32,
    );
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
      _expectPanelGeometryForText(
        tester,
        text: '배우기',
        expectedPadding: const EdgeInsets.all(12),
        expectedRadius: 32,
      );
      _expectPanelGeometryForText(
        tester,
        text: '퀴즈',
        expectedPadding: const EdgeInsets.all(12),
        expectedRadius: 32,
      );
    },
  );
}

void _expectPanelGeometryForText(
  WidgetTester tester, {
  required String text,
  required EdgeInsetsGeometry expectedPadding,
  required double expectedRadius,
}) {
  final panelFinder = find.ancestor(
    of: find.text(text),
    matching: find.byType(ToyPanel),
  );
  expect(panelFinder, findsOneWidget);

  final panelPaddingWidgets = tester
      .widgetList<Padding>(
        find.descendant(of: panelFinder, matching: find.byType(Padding)),
      )
      .where((widget) => widget.child is Flex)
      .toList();
  final clipFinder = find.descendant(
    of: panelFinder,
    matching: find.byType(ClipRRect),
  );

  expect(panelPaddingWidgets, hasLength(1));
  expect(clipFinder, findsOneWidget);

  final paddingWidget = panelPaddingWidgets.single;
  final clipWidget = tester.widget<ClipRRect>(clipFinder);

  expect(paddingWidget.padding, expectedPadding);
  expect(clipWidget.borderRadius, BorderRadius.circular(expectedRadius));
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
