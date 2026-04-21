import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/tap_cooldown.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';
import 'package:kids_play_app/features/home/data/home_catalog_repository.dart';
import 'package:kids_play_app/features/home/presentation/category_hub_screen.dart';
import 'package:kids_play_app/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('roomy home shows polished driving copy and accurate CTA', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(960, 460);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: buildKidTheme(),
        home: HomeScreen(catalogRepository: _fakeHomeCatalogRepository()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('오늘은 어디로 달릴까?'), findsOneWidget);
    expect(find.text('마음에 드는 차고를 누르고\u00A0놀이를 골라요.'), findsOneWidget);
    expect(find.text('놀이 고르기'), findsNWidgets(3));
    expect(find.text('차고 열기'), findsNothing);
    expect(find.text('바로 출발'), findsNothing);
  });

  testWidgets('roomy home cards follow themed regular panel tokens', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(960, 460);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: _themeWithRegularPanelTokens(padding: 18, radius: 28),
        home: HomeScreen(catalogRepository: _fakeHomeCatalogRepository()),
      ),
    );
    await tester.pumpAndSettle();

    _expectPanelGeometryForText(
      tester,
      text: '한글',
      expectedPadding: const EdgeInsets.all(18),
      expectedRadius: 28,
    );
  });

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
        theme: buildKidTheme(),
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

  testWidgets('compact home cards follow themed compact panel tokens', (
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
        theme: _themeWithCompactPanelTokens(padding: 9, radius: 26),
        home: HomeScreen(catalogRepository: _fakeHomeCatalogRepository()),
      ),
    );
    await tester.pumpAndSettle();

    _expectPanelGeometryForText(
      tester,
      text: '한글',
      expectedPadding: const EdgeInsets.all(9),
      expectedRadius: 26,
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
        MaterialApp(
          theme: buildKidTheme(),
          home: const CategoryHubScreen(
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

  testWidgets('compact hub mode cards follow themed compact panel tokens', (
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
        theme: _themeWithCompactPanelTokens(padding: 9, radius: 26),
        home: const CategoryHubScreen(
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

    _expectPanelGeometryForText(
      tester,
      text: '배우기',
      expectedPadding: const EdgeInsets.all(9),
      expectedRadius: 26,
    );
    _expectPanelGeometryForText(
      tester,
      text: '퀴즈',
      expectedPadding: const EdgeInsets.all(9),
      expectedRadius: 26,
    );
  });

  testWidgets('roomy hub mode cards follow themed regular panel tokens', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(960, 460);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: _themeWithRegularPanelTokens(padding: 18, radius: 28),
        home: const CategoryHubScreen(
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

    _expectPanelGeometryForText(
      tester,
      text: '배우기',
      expectedPadding: const EdgeInsets.all(18),
      expectedRadius: 28,
    );
    _expectPanelGeometryForText(
      tester,
      text: '퀴즈',
      expectedPadding: const EdgeInsets.all(18),
      expectedRadius: 28,
    );
  });
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
  final tapWrapperFinder = find.ancestor(
    of: panelFinder,
    matching: find.byType(CooldownInkWell),
  );

  expect(panelPaddingWidgets, hasLength(1));
  expect(clipFinder, findsOneWidget);
  expect(tapWrapperFinder, findsOneWidget);

  final paddingWidget = panelPaddingWidgets.single;
  final clipWidget = tester.widget<ClipRRect>(clipFinder);
  final tapWrapper = tester.widget<CooldownInkWell>(tapWrapperFinder);

  expect(paddingWidget.padding, expectedPadding);
  expect(clipWidget.borderRadius, BorderRadius.circular(expectedRadius));
  expect(tapWrapper.borderRadius, BorderRadius.circular(expectedRadius));
}

ThemeData _themeWithCompactPanelTokens({
  required double padding,
  required double radius,
}) {
  const defaults = KidLayoutTheme.defaults;
  return buildKidTheme().copyWith(
    extensions: <ThemeExtension<dynamic>>[
      defaults.copyWith(
        panel: defaults.panel.copyWith(
          compact: defaults.panel.compact.copyWith(
            padding: EdgeInsets.all(padding),
            radius: radius,
          ),
        ),
      ),
    ],
  );
}

ThemeData _themeWithRegularPanelTokens({
  required double padding,
  required double radius,
}) {
  const defaults = KidLayoutTheme.defaults;
  return buildKidTheme().copyWith(
    extensions: <ThemeExtension<dynamic>>[
      defaults.copyWith(
        panel: defaults.panel.copyWith(
          regular: defaults.panel.regular.copyWith(
            padding: EdgeInsets.all(padding),
            radius: radius,
          ),
        ),
      ),
    ],
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
