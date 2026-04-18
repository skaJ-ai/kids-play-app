import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/features/home/presentation/home_pills.dart';

void main() {
  testWidgets(
    'HomeHeaderPill uses kidTypography titleSmall overrides at runtime',
    (WidgetTester tester) async {
      final baseTheme = buildKidTheme();
      final customTypography = KidTypographyTheme.defaults.copyWith(
        titleSmall: const TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w300,
          letterSpacing: 2.4,
          height: 1.7,
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

      expect(theme.textTheme.titleSmall, baseTheme.textTheme.titleSmall);

      await _pumpPill(
        tester,
        theme: theme,
        child: const HomeHeaderPill(
          icon: Icons.garage_rounded,
          label: '차고',
          iconColor: Colors.teal,
        ),
      );

      final text = tester.widget<Text>(find.text('차고'));

      expect(
        text.style,
        customTypography.titleSmall.copyWith(
          color: KidPalette.navy,
          fontWeight: FontWeight.w900,
        ),
      );
    },
  );

  testWidgets(
    'HomeAccentPill uses kidTypography labelLarge overrides at runtime',
    (WidgetTester tester) async {
      final baseTheme = buildKidTheme();
      final customTypography = KidTypographyTheme.defaults.copyWith(
        titleSmall: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.9,
          height: 1.1,
          fontStyle: FontStyle.normal,
          color: Colors.blue,
        ),
        labelLarge: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w300,
          letterSpacing: 3.1,
          height: 1.6,
          fontStyle: FontStyle.italic,
          color: Colors.pink,
        ),
      );
      final theme = baseTheme.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          baseTheme.kidLayout,
          customTypography,
        ],
      );

      expect(theme.textTheme.labelLarge, baseTheme.textTheme.labelLarge);
      expect(theme.textTheme.titleSmall, baseTheme.textTheme.titleSmall);

      await _pumpPill(
        tester,
        theme: theme,
        child: const HomeAccentPill(
          label: 'NEW',
          textColor: Colors.white,
          backgroundColor: KidPalette.coral,
        ),
      );

      final text = tester.widget<Text>(find.text('NEW'));

      expect(
        text.style,
        customTypography.labelLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      );
    },
  );
}

Future<void> _pumpPill(
  WidgetTester tester, {
  required ThemeData theme,
  required Widget child,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}
