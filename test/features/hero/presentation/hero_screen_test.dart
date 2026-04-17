import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';
import 'package:kids_play_app/features/hero/presentation/hero_screen.dart';

void main() {
  testWidgets('shows branded hero copy and clearer primary cta', (
    WidgetTester tester,
  ) async {
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

  testWidgets('uses named toy panel tones for the two main panels', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildHeroScreen());
    await tester.pumpAndSettle();

    final panels = tester.widgetList<ToyPanel>(find.byType(ToyPanel)).toList();

    expect(panels, hasLength(2));
    expect(panels.first.tone, ToyPanelTone.airy);
    expect(panels.last.tone, ToyPanelTone.warm);
  });
}

Widget _buildHeroScreen() {
  return MaterialApp(
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
