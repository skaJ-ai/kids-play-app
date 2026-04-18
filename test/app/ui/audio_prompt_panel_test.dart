import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/audio_prompt_panel.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';

void main() {
  testWidgets('uses the warm compact panel shell when compact is true', (
    WidgetTester tester,
  ) async {
    await _pumpAudioPromptPanel(tester, compact: true);

    final panel = tester.widget<ToyPanel>(find.byType(ToyPanel));

    expect(panel.tone, ToyPanelTone.warm);
    expect(panel.density, ToyPanelDensity.compact);
  });

  testWidgets('uses the warm regular panel shell when compact is false', (
    WidgetTester tester,
  ) async {
    await _pumpAudioPromptPanel(tester, compact: false);

    final panel = tester.widget<ToyPanel>(find.byType(ToyPanel));

    expect(panel.tone, ToyPanelTone.warm);
    expect(panel.density, ToyPanelDensity.regular);
  });
}

Future<void> _pumpAudioPromptPanel(
  WidgetTester tester, {
  required bool compact,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildKidTheme(),
      home: Scaffold(
        body: AudioPromptPanel(
          badge: '문제 듣기',
          title: '하나',
          subtitle: '스피커를 눌러 다시 들어봐요.',
          onReplay: () {},
          compact: compact,
        ),
      ),
    ),
  );
}
