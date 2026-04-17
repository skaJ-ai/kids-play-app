import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/features/home/data/home_catalog_repository.dart';
import 'package:kids_play_app/features/home/presentation/category_hub_screen.dart';
import 'package:kids_play_app/features/home/presentation/home_screen.dart';

void main() {
  testWidgets(
    'roomy home and category hub icon tiles follow the regular inset radius token',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(960, 540);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final theme = _themeWithPanelInsetRadii(regular: 30);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: HomeScreen(catalogRepository: _fakeHomeCatalogRepository()),
        ),
      );
      await tester.pumpAndSettle();

      _expectIconTileRadiusForIcon(
        tester,
        icon: Icons.text_fields_rounded,
        expectedRadius: 30,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const CategoryHubScreen(category: _hangulCategory),
        ),
      );
      await tester.pumpAndSettle();

      _expectIconTileRadiusForIcon(
        tester,
        icon: Icons.menu_book_rounded,
        expectedRadius: 30,
      );
      _expectIconTileRadiusForIcon(
        tester,
        icon: Icons.videogame_asset_rounded,
        expectedRadius: 30,
      );
    },
  );

  testWidgets(
    'compact home and category hub icon tiles follow compact and tight inset radius tokens',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(780, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final theme = _themeWithPanelInsetRadii(compact: 13, tight: 11);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: HomeScreen(catalogRepository: _fakeHomeCatalogRepository()),
        ),
      );
      await tester.pumpAndSettle();

      _expectIconTileRadiusForIcon(
        tester,
        icon: Icons.text_fields_rounded,
        expectedRadius: 13,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const CategoryHubScreen(category: _hangulCategory),
        ),
      );
      await tester.pumpAndSettle();

      _expectIconTileRadiusForIcon(
        tester,
        icon: Icons.menu_book_rounded,
        expectedRadius: 11,
      );
      _expectIconTileRadiusForIcon(
        tester,
        icon: Icons.videogame_asset_rounded,
        expectedRadius: 11,
      );
    },
  );
}

void _expectIconTileRadiusForIcon(
  WidgetTester tester, {
  required IconData icon,
  required double expectedRadius,
}) {
  final tileFinder = find.ancestor(
    of: find.byIcon(icon),
    matching: find.byWidgetPredicate((widget) {
      if (widget is! Container || widget.child is! Icon) {
        return false;
      }

      final decoration = widget.decoration;
      return decoration is BoxDecoration && decoration.borderRadius != null;
    }),
  );

  expect(tileFinder, findsOneWidget);

  final tile = tester.widget<Container>(tileFinder);
  final decoration = tile.decoration! as BoxDecoration;

  expect(decoration.borderRadius, BorderRadius.circular(expectedRadius));
}

ThemeData _themeWithPanelInsetRadii({
  double? regular,
  double? compact,
  double? tight,
}) {
  const defaults = KidLayoutTheme.defaults;

  return buildKidTheme().copyWith(
    extensions: <ThemeExtension<dynamic>>[
      defaults.copyWith(
        panel: defaults.panel.copyWith(
          regular: regular == null
              ? null
              : defaults.panel.regular.copyWith(insetRadius: regular),
          compact: compact == null
              ? null
              : defaults.panel.compact.copyWith(insetRadius: compact),
          tight: tight == null
              ? null
              : defaults.panel.tight.copyWith(insetRadius: tight),
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

const _hangulCategory = HomeCategory(
  id: 'hangul',
  label: '한글',
  description: '자음과 모음을 만나요',
  backgroundColorHex: '#FFE699',
  iconName: 'text_fields_rounded',
);

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
