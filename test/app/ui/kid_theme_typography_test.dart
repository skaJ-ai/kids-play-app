import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';

void main() {
  test('buildKidTheme uses a calmer headline hierarchy', () {
    final textTheme = buildKidTheme().textTheme;

    expect(textTheme.displayLarge, isNotNull);
    expect(textTheme.displayLarge!.fontSize, 56);
    expect(textTheme.displayLarge!.fontWeight, FontWeight.w800);
    expect(textTheme.displayLarge!.letterSpacing, -1.6);
    expect(textTheme.displayLarge!.height, 0.98);
    expect(textTheme.displayLarge!.color, KidPalette.navy);

    expect(textTheme.headlineLarge, isNotNull);
    expect(textTheme.headlineLarge!.fontSize, 40);
    expect(textTheme.headlineLarge!.fontWeight, FontWeight.w800);
    expect(textTheme.headlineLarge!.letterSpacing, -1.0);
    expect(textTheme.headlineLarge!.height, 1.02);
    expect(textTheme.headlineLarge!.color, KidPalette.navy);

    expect(textTheme.headlineMedium, isNotNull);
    expect(textTheme.headlineMedium!.fontSize, 32);
    expect(textTheme.headlineMedium!.fontWeight, FontWeight.w800);
    expect(textTheme.headlineMedium!.letterSpacing, -0.6);
    expect(textTheme.headlineMedium!.height, 1.08);
    expect(textTheme.headlineMedium!.color, KidPalette.navy);

    expect(textTheme.headlineSmall, isNotNull);
    expect(textTheme.headlineSmall!.fontSize, 24);
    expect(textTheme.headlineSmall!.fontWeight, FontWeight.w700);
    expect(textTheme.headlineSmall!.letterSpacing, -0.3);
    expect(textTheme.headlineSmall!.height, 1.12);
    expect(textTheme.headlineSmall!.color, KidPalette.navy);

    expect(textTheme.titleLarge, isNotNull);
    expect(textTheme.titleLarge!.fontSize, 20);
    expect(textTheme.titleLarge!.fontWeight, FontWeight.w700);
    expect(textTheme.titleLarge!.letterSpacing, -0.2);
    expect(textTheme.titleLarge!.height, 1.18);
    expect(textTheme.titleLarge!.color, KidPalette.navy);
  });

  test('buildKidTheme keeps the calmer supporting label contract', () {
    final textTheme = buildKidTheme().textTheme;

    expect(textTheme.labelLarge, isNotNull);
    expect(textTheme.labelLarge!.fontSize, 13);
    expect(textTheme.labelLarge!.fontWeight, FontWeight.w700);
    expect(textTheme.labelLarge!.letterSpacing, 0.08);
    expect(textTheme.labelLarge!.height, 1.14);
    expect(textTheme.labelLarge!.color, KidPalette.navy);
  });

  test('buildKidTheme softens the supporting copy hierarchy', () {
    final textTheme = buildKidTheme().textTheme;

    expect(textTheme.titleMedium, isNotNull);
    expect(textTheme.titleMedium!.fontSize, 17);
    expect(textTheme.titleMedium!.fontWeight, FontWeight.w700);
    expect(textTheme.titleMedium!.letterSpacing, -0.1);
    expect(textTheme.titleMedium!.height, 1.22);
    expect(textTheme.titleMedium!.color, KidPalette.navy);

    expect(textTheme.titleSmall, isNotNull);
    expect(textTheme.titleSmall!.fontSize, 14);
    expect(textTheme.titleSmall!.fontWeight, FontWeight.w600);
    expect(textTheme.titleSmall!.letterSpacing, 0.02);
    expect(textTheme.titleSmall!.height, 1.22);
    expect(textTheme.titleSmall!.color, KidPalette.navy);

    expect(textTheme.bodyLarge, isNotNull);
    expect(textTheme.bodyLarge!.fontSize, 16);
    expect(textTheme.bodyLarge!.fontWeight, FontWeight.w500);
    expect(textTheme.bodyLarge!.height, 1.38);
    expect(textTheme.bodyLarge!.color, KidPalette.body);

    expect(textTheme.bodyMedium, isNotNull);
    expect(textTheme.bodyMedium!.fontSize, 15);
    expect(textTheme.bodyMedium!.fontWeight, FontWeight.w400);
    expect(textTheme.bodyMedium!.height, 1.36);
    expect(textTheme.bodyMedium!.color, KidPalette.body);

    expect(textTheme.bodySmall, isNotNull);
    expect(textTheme.bodySmall!.fontSize, 13);
    expect(textTheme.bodySmall!.fontWeight, FontWeight.w400);
    expect(textTheme.bodySmall!.height, 1.32);
    expect(textTheme.bodySmall!.color, KidPalette.body);

    expect(textTheme.labelMedium, isNotNull);
    expect(textTheme.labelMedium!.fontSize, 12);
    expect(textTheme.labelMedium!.fontWeight, FontWeight.w600);
    expect(textTheme.labelMedium!.letterSpacing, 0.05);
    expect(textTheme.labelMedium!.height, 1.18);
    expect(textTheme.labelMedium!.color, KidPalette.body);

    expect(textTheme.labelSmall, isNotNull);
    expect(textTheme.labelSmall!.fontSize, 11);
    expect(textTheme.labelSmall!.fontWeight, FontWeight.w600);
    expect(textTheme.labelSmall!.letterSpacing, 0.05);
    expect(textTheme.labelSmall!.height, 1.16);
    expect(textTheme.labelSmall!.color, KidPalette.body);
  });
}
