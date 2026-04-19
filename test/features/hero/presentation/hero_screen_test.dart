import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/toy_button.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';
import 'package:kids_play_app/features/avatar/application/avatar_photo_service.dart';
import 'package:kids_play_app/features/avatar/data/avatar_photo_repository.dart';
import 'package:kids_play_app/features/avatar/data/avatar_photo_store.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_expression.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_photo_snapshot.dart';
import 'package:kids_play_app/features/avatar/presentation/avatar_setup_screen.dart';
import 'package:kids_play_app/features/hero/presentation/hero_screen.dart';
import 'package:kids_play_app/features/home/data/home_catalog_repository.dart';
import 'package:kids_play_app/features/home/presentation/home_screen.dart';

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
    'describes the hero face as decoration instead of telling the child to tap it',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildHeroScreen());
      await tester.pumpAndSettle();

      expect(find.text('웃는 얼굴로 오늘 놀이를 준비했어요.'), findsOneWidget);
      expect(find.text('얼굴을 누르고 차고를 골라요.'), findsNothing);

      tester.view.physicalSize = const Size(780, 360);
      await tester.pumpWidget(_buildHeroScreen());
      await tester.pumpAndSettle();

      expect(find.text('웃으며 출발 준비!'), findsOneWidget);
      expect(find.text('얼굴 누르고 출발!'), findsNothing);
    },
  );

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
    'switches the hero cta density and rendered height between roomy and compact layouts',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final theme = buildKidTheme();
      final layout = theme.extension<KidLayoutTheme>();

      expect(layout, isNotNull);
      expect(layout!.button.regular.height, 56);
      expect(layout.button.compact.height, 48);

      await tester.pumpWidget(_buildHeroScreen(theme: theme));
      await tester.pumpAndSettle();

      expect(_heroStartButton(tester).density, ToyButtonDensity.regular);
      expect(_heroStartButton(tester).height, isNull);
      expect(_heroStartButtonHeight(tester), layout.button.regular.height);

      tester.view.physicalSize = const Size(780, 360);
      await tester.pumpWidget(_buildHeroScreen(theme: theme));
      await tester.pumpAndSettle();

      expect(_heroStartButton(tester).density, ToyButtonDensity.compact);
      expect(_heroStartButton(tester).height, isNull);
      expect(_heroStartButtonHeight(tester), layout.button.compact.height);
    },
  );

  testWidgets('expires hidden parent-entry taps after a short idle gap', (
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

    for (var i = 0; i < 4; i += 1) {
      await tester.tap(find.byKey(const Key('hero-face-parent-entry')));
      await tester.pump();
    }

    expect(find.byType(AvatarSetupScreen), findsNothing);

    await tester.pump(const Duration(seconds: 3));
    await tester.tap(find.byKey(const Key('hero-face-parent-entry')));
    await tester.pumpAndSettle();

    expect(find.byType(AvatarSetupScreen), findsNothing);

    for (var i = 0; i < 4; i += 1) {
      await tester.tap(find.byKey(const Key('hero-face-parent-entry')));
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(find.byType(AvatarSetupScreen), findsOneWidget);
  });

  testWidgets(
    'does not stack the parent screen when the hero face is over-tapped during entry',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildHeroScreen());
      await tester.pumpAndSettle();

      final heroFaceDetector = _heroFaceDetector(tester);
      for (var i = 0; i < 10; i += 1) {
        heroFaceDetector.onTap?.call();
      }
      await tester.pumpAndSettle();

      expect(find.byType(AvatarSetupScreen), findsOneWidget);

      Navigator.of(tester.element(find.byType(AvatarSetupScreen))).pop();
      await tester.pumpAndSettle();

      expect(find.byType(AvatarSetupScreen), findsNothing);
      expect(find.text('승원이의 빵빵 놀이터'), findsOneWidget);
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

      expect(find.byType(HomeScreen), findsOneWidget);

      Navigator.of(tester.element(find.byType(HomeScreen))).pop();
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

  testWidgets(
    'uses saved avatar photo before falling back to bundled hero asset',
    (WidgetTester tester) async {
      final avatarPhotoHarness = await _createAvatarPhotoHarness();
      addTearDown(avatarPhotoHarness.dispose);
      await avatarPhotoHarness.service.saveExpressionPhoto(
        expression: AvatarExpression.neutral,
        bytes: _neutralPhotoPngBytes,
      );
      await avatarPhotoHarness.service.saveExpressionPhoto(
        expression: AvatarExpression.smile,
        bytes: _smilePhotoPngBytes,
      );

      tester.view.physicalSize = const Size(1200, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildHeroScreen(avatarPhotoService: avatarPhotoHarness.service),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final heroFaceImage = _heroFaceImage(tester);

      expect(heroFaceImage.key, const Key('hero-face-image'));
      expect(heroFaceImage.excludeFromSemantics, isTrue);
      expect(heroFaceImage.fit, BoxFit.contain);
      expect(heroFaceImage.image, isA<MemoryImage>());
      expect(
        (heroFaceImage.image as MemoryImage).bytes,
        orderedEquals(_smilePhotoPngBytes),
      );
    },
  );

  testWidgets(
    'refreshes the hero face after returning from the parent setup screen',
    (WidgetTester tester) async {
      final avatarPhotoHarness = await _createAvatarPhotoHarness();
      addTearDown(avatarPhotoHarness.dispose);

      tester.view.physicalSize = const Size(1200, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildHeroScreen(avatarPhotoService: avatarPhotoHarness.service),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(_heroFaceImage(tester).image, isA<AssetImage>());

      await _openHiddenParentEntry(tester);

      expect(find.byType(AvatarSetupScreen), findsOneWidget);

      await avatarPhotoHarness.service.saveExpressionPhoto(
        expression: AvatarExpression.neutral,
        bytes: _neutralPhotoPngBytes,
      );

      Navigator.of(tester.element(find.byType(AvatarSetupScreen))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 100));

      final heroFaceImage = _heroFaceImage(tester);
      expect(heroFaceImage.image, isA<MemoryImage>());
      expect(
        (heroFaceImage.image as MemoryImage).bytes,
        orderedEquals(_neutralPhotoPngBytes),
      );
    },
  );

  testWidgets(
    'keeps the hidden parent-entry face out of accessibility semantics',
    (WidgetTester tester) async {
      final semantics = tester.ensureSemantics();
      tester.view.physicalSize = const Size(1200, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildHeroScreen());
      await tester.pumpAndSettle();

      final heroFaceImageSemantics = tester.getSemantics(
        find.byKey(const Key('hero-face-image')),
      );

      expect(
        heroFaceImageSemantics.getSemanticsData().flagsCollection.isImage,
        isFalse,
      );
      expect(
        heroFaceImageSemantics.getSemanticsData().hasAction(
          SemanticsAction.tap,
        ),
        isFalse,
      );
      semantics.dispose();
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
  return tester.widget<ToyButton>(_heroStartButtonFinder());
}

double _heroStartButtonHeight(WidgetTester tester) {
  final sizedBox = tester.widget<SizedBox>(
    find.descendant(
      of: _heroStartButtonFinder(),
      matching: find.byWidgetPredicate(
        (Widget widget) =>
            widget is SizedBox && widget.height != null && widget.width == null,
      ),
    ),
  );

  return sizedBox.height!;
}

Finder _heroStartButtonFinder() {
  return find.widgetWithText(ToyButton, '놀이 시작');
}

GestureDetector _heroFaceDetector(WidgetTester tester) {
  return tester.widget<GestureDetector>(
    find.byKey(const Key('hero-face-parent-entry')),
  );
}

ThemeData _buildHeroThemeWithPanelTokens() {
  const panelTokens = KidPanelTokens(
    regular: KidPanelDensityTokens(
      padding: EdgeInsets.all(20),
      radius: 35,
      borderWidth: 1.5,
      highlightHeight: 18,
      highlightHorizontalInset: 20,
      insetRadius: 24,
    ),
    compact: KidPanelDensityTokens(
      padding: EdgeInsets.all(12),
      radius: 27,
      borderWidth: 1.4,
      highlightHeight: 16,
      highlightHorizontalInset: 18,
      insetRadius: 18,
    ),
    tight: KidPanelDensityTokens(
      padding: EdgeInsets.all(11),
      radius: 23,
      borderWidth: 1.3,
      highlightHeight: 14,
      highlightHorizontalInset: 16,
      insetRadius: 16,
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

Widget _buildHeroScreen({
  ThemeData? theme,
  AvatarPhotoService? avatarPhotoService,
}) {
  return DefaultAssetBundle(
    bundle: _FakeHeroAssetBundle(),
    child: AppServicesScope(
      services: AppServices(
        progressStore: MemoryProgressStore(),
        speechCueService: NoopSpeechCueService(),
        avatarPhotoService: avatarPhotoService,
      ),
      child: MaterialApp(
        theme: theme ?? buildKidTheme(),
        home: const HeroScreen(),
      ),
    ),
  );
}

Future<void> _openHiddenParentEntry(WidgetTester tester) async {
  for (var i = 0; i < 5; i += 1) {
    await tester.tap(find.byKey(const Key('hero-face-parent-entry')));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

Image _heroFaceImage(WidgetTester tester) {
  return tester.widget<Image>(find.byKey(const Key('hero-face-image')));
}

Future<_AvatarPhotoHarness> _createAvatarPhotoHarness() async {
  final repository = _TestAvatarPhotoRepository();
  final store = _TestAvatarPhotoStore();

  return _AvatarPhotoHarness(
    service: AvatarPhotoService(photoStore: store, repository: repository),
    repository: repository,
  );
}

class _AvatarPhotoHarness {
  _AvatarPhotoHarness({required this.service, required this.repository});

  final AvatarPhotoService service;
  final _TestAvatarPhotoRepository repository;

  Future<void> dispose() async {}
}

class _TestAvatarPhotoStore implements AvatarPhotoStore {
  AvatarPhotoSnapshot snapshot = const AvatarPhotoSnapshot();

  @override
  Future<AvatarPhotoSnapshot> loadSnapshot() async => snapshot;

  @override
  Future<void> saveSnapshot(AvatarPhotoSnapshot snapshot) async {
    this.snapshot = snapshot;
  }
}

class _TestAvatarPhotoRepository implements AvatarPhotoRepository {
  final Map<String, Uint8List> _savedBytesByPath = <String, Uint8List>{};

  @override
  Future<void> deletePhoto(String relativePath) async {
    _savedBytesByPath.remove(relativePath);
  }

  @override
  Future<File?> resolveFile(String relativePath) async {
    final bytes = _savedBytesByPath[relativePath];
    if (bytes == null) {
      return null;
    }

    return _FakeAvatarFile(path: relativePath, bytes: bytes);
  }

  @override
  Future<String> saveExpressionPhoto({
    required AvatarExpression expression,
    required Uint8List bytes,
  }) async {
    final relativePath = avatarPhotoRelativePathFor(expression);
    _savedBytesByPath[relativePath] = Uint8List.fromList(bytes);
    return relativePath;
  }
}

class _FakeAvatarFile implements File {
  _FakeAvatarFile({required this.path, required Uint8List bytes})
    : _bytes = Uint8List.fromList(bytes);

  final Uint8List _bytes;

  @override
  final String path;

  @override
  Future<Uint8List> readAsBytes() async => Uint8List.fromList(_bytes);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

final Uint8List _smilePhotoPngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==',
);

final Uint8List _neutralPhotoPngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGD4DwABBAEAX+XDSwAAAABJRU5ErkJggg==',
);
