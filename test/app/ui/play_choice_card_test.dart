import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/play_choice_card.dart';

void main() {
  testWidgets(
    'shows the symbol with the requested accent palette and handles taps',
    (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 220,
              height: 180,
              child: PlayChoiceCard(
                symbol: 'ㄱ',
                accentIndex: 1,
                compact: false,
                disabled: false,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('콕!'), findsOneWidget);
      expect(find.text('ㄱ'), findsOneWidget);

      expect(
        find.byWidgetPredicate((widget) {
          if (widget is! DecoratedBox) {
            return false;
          }
          final decoration = widget.decoration;
          if (decoration is! BoxDecoration) {
            return false;
          }
          final gradient = decoration.gradient;
          final borderRadius = decoration.borderRadius;
          return gradient is LinearGradient &&
              borderRadius is BorderRadius &&
              listEquals(gradient.colors, const [
                KidPalette.coral,
                KidPalette.coralDark,
              ]) &&
              borderRadius.topLeft.x == 32;
        }),
        findsOneWidget,
      );

      await tester.tap(find.text('ㄱ'));
      await tester.pump();

      expect(tapped, isTrue);
    },
  );

  testWidgets(
    'uses injected calmer badge and symbol typography overrides from the shared theme',
    (WidgetTester tester) async {
      final baseTheme = buildKidTheme();
      const badgeTypography = TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.4,
      );
      const badgeSizeTypography = TextStyle(fontSize: 19);
      const symbolTypography = TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.6,
      );
      final customTypography = baseTheme.kidTypography.copyWith(
        labelLarge: badgeTypography,
        titleSmall: badgeSizeTypography,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: baseTheme.copyWith(
            textTheme: baseTheme.textTheme.copyWith(displayLarge: symbolTypography),
            extensions: [baseTheme.kidLayout, customTypography],
          ),
          home: Scaffold(
            body: SizedBox(
              width: 220,
              height: 180,
              child: PlayChoiceCard(
                symbol: '8',
                accentIndex: 2,
                compact: false,
                disabled: false,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      final badge = tester.widget<Text>(find.text('콕!'));
      final symbol = tester.widget<Text>(find.text('8'));

      expect(badge.style?.fontWeight, badgeTypography.fontWeight);
      expect(badge.style?.letterSpacing, badgeTypography.letterSpacing);
      expect(badge.style?.fontSize, badgeSizeTypography.fontSize);
      expect(symbol.style?.fontWeight, symbolTypography.fontWeight);
      expect(symbol.style?.letterSpacing, symbolTypography.letterSpacing);
    },
  );

  testWidgets('dims the card and ignores taps when disabled in compact mode', (
    WidgetTester tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            height: 180,
            child: PlayChoiceCard(
              symbol: '5',
              accentIndex: 3,
              compact: true,
              disabled: true,
              onTap: () => tapCount += 1,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Opacity && widget.opacity == 0.88,
      ),
      findsOneWidget,
    );

    expect(
      find.byWidgetPredicate((widget) {
        if (widget is! DecoratedBox) {
          return false;
        }
        final decoration = widget.decoration;
        if (decoration is! BoxDecoration) {
          return false;
        }
        final gradient = decoration.gradient;
        final borderRadius = decoration.borderRadius;
        return gradient is LinearGradient &&
            borderRadius is BorderRadius &&
            listEquals(gradient.colors, const [
              KidPalette.lilac,
              Color(0xFFA28CF5),
            ]) &&
            borderRadius.topLeft.x == 26;
      }),
      findsOneWidget,
    );

    await tester.tap(find.text('5'));
    await tester.pump();

    expect(tapCount, 0);
  });
}
