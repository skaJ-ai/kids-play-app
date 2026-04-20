import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/play_prompt_panel.dart';
import 'package:kids_play_app/app/ui/toy_button.dart';

void main() {
  testWidgets(
    'renders the regular prompt layout with replay copy and target badge',
    (WidgetTester tester) async {
      final previousHitTestWarningShouldBeFatal =
          WidgetController.hitTestWarningShouldBeFatal;
      addTearDown(() {
        WidgetController.hitTestWarningShouldBeFatal =
            previousHitTestWarningShouldBeFatal;
      });
      WidgetController.hitTestWarningShouldBeFatal = true;

      var replayCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 280,
              child: PlayPromptPanel(
                key: const Key('quiz-prompt-panel'),
                prompt: '다섯',
                displayName: '숫자 다섯',
                symbol: '5',
                targetLabel: '찾아볼 숫자',
                compact: false,
                tight: false,
                onReplay: () => replayCount += 1,
              ),
            ),
          ),
        ),
      );

      expect(find.text('문제 듣기'), findsOneWidget);
      expect(find.text('스피커를 누르면 문제를 다시 들을 수 있어요.'), findsOneWidget);
      expect(find.text('찾아볼 숫자'), findsOneWidget);
      expect(find.text('숫자 다섯'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      await tester.tap(find.byType(ToyButton));
      await tester.pump();

      expect(replayCount, 1);
    },
  );

  testWidgets(
    'renders the tight prompt layout without the separate replay badge',
    (WidgetTester tester) async {
      var replayCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 280,
              height: 180,
              child: PlayPromptPanel(
                key: const Key('quiz-prompt-panel'),
                prompt: '기역',
                displayName: '한글 기역',
                symbol: 'ㄱ',
                targetLabel: '찾아볼 글자',
                compact: true,
                tight: true,
                onReplay: () => replayCount += 1,
              ),
            ),
          ),
        ),
      );

      expect(find.text('문제 듣기'), findsNothing);
      expect(find.text('기역'), findsOneWidget);
      expect(find.text('한글 기역'), findsOneWidget);
      expect(find.text('ㄱ'), findsOneWidget);
      expect(find.text('찾아볼 글자'), findsNothing);

      await tester.tap(find.byIcon(Icons.volume_up_rounded));
      await tester.pump();

      expect(replayCount, 1);
    },
  );
}
