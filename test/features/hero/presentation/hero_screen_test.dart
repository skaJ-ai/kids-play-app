import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/toy_button.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';
import 'package:kids_play_app/features/avatar/presentation/avatar_setup_screen.dart';
import 'package:kids_play_app/features/hero/presentation/hero_screen.dart';
import 'package:kids_play_app/features/home/data/home_catalog_repository.dart';

void main() {
  testWidgets('shows branded hero copy and clearer primary cta', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildHeroScreen());
    await tester.pumpAndSettle();

    expect(find.text('승원이의 빵빵 놀이터'), findsOneWidget);
    expect(find.text('한글 · 알파벳 · 숫자 놀이를 골라요.'), findsOneWidget);
    expect(find.text('놀이 시작'), findsOneWidget);
  });

  testWidgets(
    'compact landscape hero keeps branded copy visible without layout exceptions',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(780, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildHeroScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('승원이의 빵빵 놀이터'), findsOneWidget);
      expect(find.text('한글 · 알파벳 · 숫자 놀이를 골라요.'), findsOneWidget);
      expect(find.text('놀이 시작'), findsOneWidget);
    },
  );

  testWidgets(
    'uses themed toy panel density tokens in roomy and compact hero layouts',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final theme = _buildHeroThemeWithPanelTokens();

      await tester.pumpWidget(_buildHeroScreen(theme: theme));
      await tester.pumpAndSettle();

      _expectPanelGeometryForText(
        tester,
        text: '혼자 톡 눌러요',
        expectedDensity: ToyPanelDensity.regular,
        expectedPadding: const EdgeInsets.all(20),
        expectedRadius: 35,
      );
      _expectPanelGeometryForText(
        tester,
        text: '오늘의 드라이버',
        expectedDensity: ToyPanelDensity.regular,
        expectedPadding: const EdgeInsets.all(20),
        expectedRadius: 35,
      );

      tester.view.physicalSize = const Size(780, 360);
      await tester.pumpWidget(_buildHeroScreen(theme: theme));
      await tester.pumpAndSettle();

      _expectPanelGeometryForText(
        tester,
        text: '혼자 톡 눌러요',
        expectedDensity: ToyPanelDensity.compact,
        expectedPadding: const EdgeInsets.all(12),
        expectedRadius: 27,
      );
      _expectPanelGeometryForText(
        tester,
        text: '오늘의 드라이버',
        expectedDensity: ToyPanelDensity.compact,
        expectedPadding: const EdgeInsets.all(12),
        expectedRadius: 27,
      );
    },
  );

  testWidgets(
    'uses themed toy button density tokens for the hero cta in roomy and compact layouts',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildHeroScreen());
      await tester.pumpAndSettle();

      expect(_heroStartButton(tester).density, ToyButtonDensity.regular);
      expect(_heroStartButton(tester).height, isNull);

      tester.view.physicalSize = const Size(780, 360);
      await tester.pumpWidget(_buildHeroScreen());
      await tester.pumpAndSettle();

      expect(_heroStartButton(tester).density, ToyButtonDensity.compact);
      expect(_heroStartButton(tester).height, isNull);
    },
  );

  testWidgets(
    'resets hidden parent-entry taps after leaving for the home screen without disabling the secret entry',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildHeroScreen());
      await tester.pumpAndSettle();

      for (var i = 0; i < 4; i += 1) {
        await tester.tap(find.byKey(const Key('hero-face-parent-entry')));
        await tester.pump();
      }

      expect(find.byType(AvatarSetupScreen), findsNothing);

      await tester.tap(find.text('놀이 시작'));
      await tester.pumpAndSettle();

      expect(find.text('오늘은 어디로 달릴까?'), findsOneWidget);

      Navigator.of(tester.element(find.text('오늘은 어디로 달릴까?'))).pop();
      await tester.pumpAndSettle();

      expect(find.text('승원이의 빵빵 놀이터'), findsOneWidget);

      await tester.tap(find.byKey(const Key('hero-face-parent-entry')));
      await tester.pumpAndSettle();

      expect(find.byType(AvatarSetupScreen), findsNothing);
      expect(find.text('승원이의 빵빵 놀이터'), findsOneWidget);

      for (var i = 0; i < 4; i += 1) {
        await tester.tap(find.byKey(const Key('hero-face-parent-entry')));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(find.byType(AvatarSetupScreen), findsOneWidget);
    },
  );

  testWidgets('uses named toy panel tones for the two main panels', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildHeroScreen());
    await tester.pumpAndSettle();

    final panels = tester.widgetList<ToyPanel>(find.byType(ToyPanel)).toList();

    expect(panels, hasLength(2));
    expect(panels.first.tone, ToyPanelTone.airy);
    expect(panels.last.tone, ToyPanelTone.warm);
  });
}

void _expectPanelGeometryForText(
  WidgetTester tester, {
  required String text,
  required ToyPanelDensity expectedDensity,
  required EdgeInsetsGeometry expectedPadding,
  required double expectedRadius,
}) {
  final panelFinder = find.ancestor(
    of: find.text(text),
    matching: find.byType(ToyPanel),
  );
  expect(panelFinder, findsOneWidget);

  final panelWidget = tester.widget<ToyPanel>(panelFinder);
  final panelPaddingWidgets = tester
      .widgetList<Padding>(
        find.descendant(of: panelFinder, matching: find.byType(Padding)),
      )
      .where(
        (widget) =>
            widget.padding == expectedPadding &&
            (widget.child is LayoutBuilder || widget.child is Column),
      )
      .toList();
  final clipFinder = find.descendant(
    of: panelFinder,
    matching: find.byType(ClipRRect),
  );

  expect(panelWidget.density, expectedDensity);
  expect(panelPaddingWidgets, hasLength(1));
  expect(clipFinder, findsOneWidget);

  final paddingWidget = panelPaddingWidgets.single;
  final clipWidget = tester.widget<ClipRRect>(clipFinder);

  expect(paddingWidget.padding, expectedPadding);
  expect(clipWidget.borderRadius, BorderRadius.circular(expectedRadius));
}

ToyButton _heroStartButton(WidgetTester tester) {
  return tester.widget<ToyButton>(find.widgetWithText(ToyButton, '놀이 시작'));
}

ThemeData _buildHeroThemeWithPanelTokens() {
  const panelTokens = KidPanelTokens(
    regular: KidPanelDensityTokens(
      padding: EdgeInsets.all(20),
      radius: 35,
      borderWidth: 1.5,
      highlightHeight: 18,
      highlightHorizontalInset: 20,
    ),
    compact: KidPanelDensityTokens(
      padding: EdgeInsets.all(12),
      radius: 27,
      borderWidth: 1.4,
      highlightHeight: 16,
      highlightHorizontalInset: 18,
    ),
    tight: KidPanelDensityTokens(
      padding: EdgeInsets.all(11),
      radius: 23,
      borderWidth: 1.3,
      highlightHeight: 14,
      highlightHorizontalInset: 16,
    ),
  );
  final baseTheme = buildKidTheme();
  final kidLayout =
      baseTheme.extension<KidLayoutTheme>() ?? KidLayoutTheme.defaults;

  return baseTheme.copyWith(
    extensions: <ThemeExtension<dynamic>>[
      kidLayout.copyWith(panel: panelTokens),
    ],
  );
}

Widget _buildHeroScreen({ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? buildKidTheme(),
    home: DefaultAssetBundle(
      bundle: _FakeHeroAssetBundle(),
      child: const HeroScreen(),
    ),
  );
}

class _FakeHeroAssetBundle extends CachingAssetBundle {
  static const String _heroAssetPath =
      'assets/generated/images/hero/hero_face.png';
  static final Uint8List _heroAssetBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==',
  );
  static final ByteData _assetManifestBytes = _encodeAssetManifest();
  static final String _homeCatalogJson = jsonEncode({
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
  });

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == HomeCatalogRepository.manifestPath) {
      return _homeCatalogJson;
    }
    throw FlutterError('Missing fake asset for $key');
  }

  @override
  Future<ByteData> load(String key) async {
    if (key == _heroAssetPath) {
      return ByteData.sublistView(_heroAssetBytes);
    }
    if (key == 'AssetManifest.bin') {
      return _assetManifestBytes;
    }

    throw FlutterError('Missing fake asset for $key');
  }

  static ByteData _encodeAssetManifest() {
    final message = const StandardMessageCodec().encodeMessage({
      _heroAssetPath: [
        {'asset': _heroAssetPath},
      ],
    });
    if (message == null) {
      throw StateError('Failed to encode fake asset manifest');
    }
    return message;
  }
}
