import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/audio_prompt_panel.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/toy_button.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';

void main() {
  testWidgets(
    'uses kid typography overrides from theme extensions for badge title and subtitle',
    (WidgetTester tester) async {
      final baseTheme = buildKidTheme();
      final customTypography = KidTypographyTheme.defaults.copyWith(
        labelLarge: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w300,
          letterSpacing: 3.1,
          height: 1.6,
          fontStyle: FontStyle.italic,
          color: Colors.pink,
        ),
        bodyMedium: const TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w300,
          letterSpacing: 3.5,
          height: 1.8,
          fontStyle: FontStyle.italic,
          color: Colors.teal,
        ),
        titleLarge: const TextStyle(
          fontSize: 31,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.7,
          height: 1.4,
          fontStyle: FontStyle.italic,
          color: Colors.purple,
        ),
      );

      final theme = baseTheme.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          baseTheme.kidLayout,
          customTypography,
        ],
      );

      expect(theme.textTheme.labelLarge, baseTheme.textTheme.labelLarge);
      expect(theme.textTheme.titleLarge, baseTheme.textTheme.titleLarge);
      expect(theme.textTheme.bodyMedium, baseTheme.textTheme.bodyMedium);

      await _pumpAudioPromptPanel(tester, compact: false, theme: theme);

      final badgeText = tester.widget<Text>(find.text('문제 듣기'));
      final titleText = _autoSizeTextWithData(tester, '하나');
      final subtitleText = _autoSizeTextWithData(tester, '스피커를 눌러 다시 들어봐요.');

      expect(
        badgeText.style,
        customTypography.labelLarge.copyWith(color: KidPalette.coralDark),
      );
      expect(
        titleText.style,
        customTypography.titleLarge.copyWith(color: KidPalette.navy),
      );
      expect(
        subtitleText.style,
        customTypography.bodyMedium.copyWith(color: KidPalette.body),
      );
    },
  );

  testWidgets(
    'uses kid typography titleMedium overrides for the compact title without extra heavy weight',
    (WidgetTester tester) async {
      final baseTheme = buildKidTheme();
      final customTypography = KidTypographyTheme.defaults.copyWith(
        titleMedium: const TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w300,
          letterSpacing: 2.4,
          height: 1.6,
          fontStyle: FontStyle.italic,
          color: Colors.orange,
        ),
      );
      final theme = baseTheme.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          baseTheme.kidLayout,
          customTypography,
        ],
      );

      expect(theme.textTheme.titleMedium, baseTheme.textTheme.titleMedium);

      await _pumpAudioPromptPanel(tester, compact: true, theme: theme);

      final titleText = _autoSizeTextWithData(tester, '하나');

      expect(
        titleText.style,
        customTypography.titleMedium.copyWith(color: KidPalette.navy),
      );
    },
  );

  testWidgets(
    'uses the warm compact panel shell and a tight secondary replay button when compact is true',
    (WidgetTester tester) async {
      var replayCount = 0;

      await _pumpAudioPromptPanel(
        tester,
        compact: true,
        onReplay: () => replayCount += 1,
      );

      final panel = tester.widget<ToyPanel>(find.byType(ToyPanel));
      final replayButton = tester.widget<ToyButton>(find.byType(ToyButton));

      expect(panel.tone, ToyPanelTone.warm);
      expect(panel.density, ToyPanelDensity.compact);
      expect(replayButton.label, '다시');
      expect(replayButton.icon, Icons.volume_up_rounded);
      expect(replayButton.density, ToyButtonDensity.tight);
      expect(replayButton.tone, ToyButtonTone.secondary);
      expect(replayButton.cooldown, Duration.zero);

      await tester.tap(find.byType(ToyButton));
      await tester.pump();
      await tester.tap(find.byType(ToyButton));
      await tester.pump();

      expect(replayCount, 2);
    },
  );

  testWidgets(
    'uses the warm regular panel shell and the same tight replay button when compact is false',
    (WidgetTester tester) async {
      await _pumpAudioPromptPanel(tester, compact: false);

      final panel = tester.widget<ToyPanel>(find.byType(ToyPanel));
      final replayButton = tester.widget<ToyButton>(find.byType(ToyButton));

      expect(panel.tone, ToyPanelTone.warm);
      expect(panel.density, ToyPanelDensity.regular);
      expect(replayButton.label, '다시');
      expect(replayButton.density, ToyButtonDensity.tight);
      expect(replayButton.tone, ToyButtonTone.secondary);
    },
  );

  testWidgets('keeps compact audio prompt copy visible in a narrow layout', (
    WidgetTester tester,
  ) async {
    await _pumpAudioPromptPanel(tester, compact: true, width: 240);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('다시'), findsOneWidget);
    expect(find.text('문제 듣기'), findsOneWidget);
    expect(find.text('하나'), findsOneWidget);
  });
}

AutoSizeText _autoSizeTextWithData(WidgetTester tester, String data) {
  return tester.widget<AutoSizeText>(
    find.byWidgetPredicate((widget) => widget is AutoSizeText && widget.data == data),
  );
}

Future<void> _pumpAudioPromptPanel(
  WidgetTester tester, {
  required bool compact,
  VoidCallback? onReplay,
  double? width,
  ThemeData? theme,
}) async {
  final panel = AudioPromptPanel(
    badge: '문제 듣기',
    title: '하나',
    subtitle: '스피커를 눌러 다시 들어봐요.',
    onReplay: onReplay ?? () {},
    compact: compact,
  );

  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? buildKidTheme(),
      home: Scaffold(
        body: Center(
          child: width == null ? panel : SizedBox(width: width, child: panel),
        ),
      ),
    ),
  );
}
