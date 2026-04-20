import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/play_prompt_panel.dart';
import 'package:kids_play_app/app/ui/toy_button.dart';

void main() {
  testWidgets(
    'uses kid typography overrides for the regular target badge and display name without forced extra-heavy weight',
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

      expect(theme.textTheme.labelLarge, baseTheme.textTheme.labelLarge);
      expect(theme.textTheme.titleMedium, baseTheme.textTheme.titleMedium);

      await _pumpPlayPromptPanel(
        tester,
        theme: theme,
        compact: false,
        tight: false,
        width: 360,
        height: 360,
        prompt: '다섯',
        displayName: '숫자 다섯',
        symbol: '5',
        targetLabel: '찾아볼 숫자',
      );

      final badgeText = tester.widget<Text>(find.text('찾아볼 숫자'));
      final displayNameText = tester.widget<Text>(find.text('숫자 다섯'));

      expect(
        badgeText.style,
        customTypography.labelLarge.copyWith(color: KidPalette.coralDark),
      );
      expect(
        displayNameText.style,
        customTypography.titleMedium.copyWith(color: KidPalette.coralDark),
      );
    },
  );

  testWidgets(
    'uses kid typography overrides for the compact target display name without forced extra-heavy weight',
    (WidgetTester tester) async {
      final baseTheme = buildKidTheme();
      final customTypography = KidTypographyTheme.defaults.copyWith(
        titleSmall: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w300,
          letterSpacing: 1.8,
          height: 1.5,
          fontStyle: FontStyle.italic,
          color: Colors.deepPurple,
        ),
      );
      final theme = baseTheme.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          baseTheme.kidLayout,
          customTypography,
        ],
      );

      expect(theme.textTheme.titleSmall, baseTheme.textTheme.titleSmall);

      await _pumpPlayPromptPanel(
        tester,
        theme: theme,
        compact: true,
        tight: false,
        prompt: '기역',
        displayName: '한글 기역',
        symbol: 'ㄱ',
        targetLabel: '찾아볼 글자',
      );

      final displayNameText = tester.widget<Text>(find.text('한글 기역'));

      expect(
        displayNameText.style,
        customTypography.titleSmall.copyWith(color: KidPalette.coralDark),
      );
    },
  );

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

      await _pumpPlayPromptPanel(
        tester,
        compact: false,
        tight: false,
        prompt: '다섯',
        displayName: '숫자 다섯',
        symbol: '5',
        targetLabel: '찾아볼 숫자',
        onReplay: () => replayCount += 1,
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

      await _pumpPlayPromptPanel(
        tester,
        compact: true,
        tight: true,
        width: 280,
        height: 180,
        prompt: '기역',
        displayName: '한글 기역',
        symbol: 'ㄱ',
        targetLabel: '찾아볼 글자',
        onReplay: () => replayCount += 1,
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

Future<void> _pumpPlayPromptPanel(
  WidgetTester tester, {
  ThemeData? theme,
  required bool compact,
  required bool tight,
  required String prompt,
  required String displayName,
  required String symbol,
  required String targetLabel,
  VoidCallback? onReplay,
  double width = 320,
  double height = 280,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? buildKidTheme(),
      home: Scaffold(
        body: SizedBox(
          width: width,
          height: height,
          child: PlayPromptPanel(
            key: const Key('quiz-prompt-panel'),
            prompt: prompt,
            displayName: displayName,
            symbol: symbol,
            targetLabel: targetLabel,
            compact: compact,
            tight: tight,
            onReplay: onReplay ?? () {},
          ),
        ),
      ),
    ),
  );
}
