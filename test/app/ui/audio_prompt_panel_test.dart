import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/audio_prompt_panel.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/toy_button.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';

void main() {
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

Future<void> _pumpAudioPromptPanel(
  WidgetTester tester, {
  required bool compact,
  VoidCallback? onReplay,
  double? width,
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
      theme: buildKidTheme(),
      home: Scaffold(
        body: Center(
          child: width == null ? panel : SizedBox(width: width, child: panel),
        ),
      ),
    ),
  );
}
