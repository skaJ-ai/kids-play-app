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
    expect(textTheme.labelLarge!.fontSize, 14);
    expect(textTheme.labelLarge!.fontWeight, FontWeight.w700);
    expect(textTheme.labelLarge!.letterSpacing, -0.1);
    expect(textTheme.labelLarge!.height, 1.15);
    expect(textTheme.labelLarge!.color, KidPalette.navy);
  });
}
