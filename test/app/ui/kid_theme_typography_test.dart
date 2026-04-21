import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';

void main() {
  test('buildKidTheme keeps KCC Murukmuruk for the display headline stack', () {
    final textTheme = buildKidTheme().textTheme;

    expect(textTheme.displayLarge, isNotNull);
    expect(textTheme.displayLarge!.fontFamily, 'KCCMurukmuruk');
    expect(textTheme.displayLarge!.fontSize, 56);
    expect(textTheme.displayLarge!.fontWeight, FontWeight.w800);
    expect(textTheme.displayLarge!.letterSpacing, -1.6);
    expect(textTheme.displayLarge!.height, 0.98);
    expect(textTheme.displayLarge!.color, KidPalette.navy);

    expect(textTheme.headlineLarge, isNotNull);
    expect(textTheme.headlineLarge!.fontFamily, 'KCCMurukmuruk');
    expect(textTheme.headlineLarge!.fontSize, 40);
    expect(textTheme.headlineLarge!.fontWeight, FontWeight.w800);
    expect(textTheme.headlineLarge!.letterSpacing, -1.0);
    expect(textTheme.headlineLarge!.height, 1.02);
    expect(textTheme.headlineLarge!.color, KidPalette.navy);

    expect(textTheme.headlineMedium, isNotNull);
    expect(textTheme.headlineMedium!.fontFamily, 'KCCMurukmuruk');
    expect(textTheme.headlineMedium!.fontSize, 32);
    expect(textTheme.headlineMedium!.fontWeight, FontWeight.w800);
    expect(textTheme.headlineMedium!.letterSpacing, -0.6);
    expect(textTheme.headlineMedium!.height, 1.08);
    expect(textTheme.headlineMedium!.color, KidPalette.navy);
  });

  test('buildKidTheme switches the supporting stack to SUIT for readable copy',
      () {
    final textTheme = buildKidTheme().textTheme;

    expect(textTheme.headlineSmall, isNotNull);
    expect(textTheme.headlineSmall!.fontFamily, 'SUIT');
    expect(textTheme.headlineSmall!.fontSize, 24);
    expect(textTheme.headlineSmall!.fontWeight, FontWeight.w700);
    expect(textTheme.headlineSmall!.height, 1.22);
    expect(textTheme.headlineSmall!.color, KidPalette.navy);

    expect(textTheme.titleLarge, isNotNull);
    expect(textTheme.titleLarge!.fontFamily, 'SUIT');
    expect(textTheme.titleLarge!.fontSize, 20);
    expect(textTheme.titleLarge!.fontWeight, FontWeight.w700);
    expect(textTheme.titleLarge!.height, 1.28);
    expect(textTheme.titleLarge!.color, KidPalette.navy);

    expect(textTheme.titleMedium, isNotNull);
    expect(textTheme.titleMedium!.fontFamily, 'SUIT');
    expect(textTheme.titleMedium!.fontSize, 17);
    expect(textTheme.titleMedium!.fontWeight, FontWeight.w600);
    expect(textTheme.titleMedium!.height, 1.32);
    expect(textTheme.titleMedium!.color, KidPalette.navy);

    expect(textTheme.titleSmall, isNotNull);
    expect(textTheme.titleSmall!.fontFamily, 'SUIT');
    expect(textTheme.titleSmall!.fontSize, 14);
    expect(textTheme.titleSmall!.fontWeight, FontWeight.w600);
    expect(textTheme.titleSmall!.height, 1.3);
    expect(textTheme.titleSmall!.color, KidPalette.navy);

    expect(textTheme.bodyLarge, isNotNull);
    expect(textTheme.bodyLarge!.fontFamily, 'SUIT');
    expect(textTheme.bodyLarge!.fontSize, 16);
    expect(textTheme.bodyLarge!.fontWeight, FontWeight.w500);
    expect(textTheme.bodyLarge!.height, 1.5);
    expect(textTheme.bodyLarge!.color, KidPalette.body);

    expect(textTheme.bodyMedium, isNotNull);
    expect(textTheme.bodyMedium!.fontFamily, 'SUIT');
    expect(textTheme.bodyMedium!.fontSize, 15);
    expect(textTheme.bodyMedium!.fontWeight, FontWeight.w500);
    expect(textTheme.bodyMedium!.height, 1.48);
    expect(textTheme.bodyMedium!.color, KidPalette.body);

    expect(textTheme.bodySmall, isNotNull);
    expect(textTheme.bodySmall!.fontFamily, 'SUIT');
    expect(textTheme.bodySmall!.fontSize, 13);
    expect(textTheme.bodySmall!.fontWeight, FontWeight.w400);
    expect(textTheme.bodySmall!.height, 1.44);
    expect(textTheme.bodySmall!.color, KidPalette.body);
  });

  test('buildKidTheme keeps the SUIT-based label hierarchy consistent', () {
    final textTheme = buildKidTheme().textTheme;

    expect(textTheme.labelLarge, isNotNull);
    expect(textTheme.labelLarge!.fontFamily, 'SUIT');
    expect(textTheme.labelLarge!.fontSize, 13);
    expect(textTheme.labelLarge!.fontWeight, FontWeight.w600);
    expect(textTheme.labelLarge!.letterSpacing, 0.02);
    expect(textTheme.labelLarge!.height, 1.22);
    expect(textTheme.labelLarge!.color, KidPalette.navy);

    expect(textTheme.labelMedium, isNotNull);
    expect(textTheme.labelMedium!.fontFamily, 'SUIT');
    expect(textTheme.labelMedium!.fontSize, 12);
    expect(textTheme.labelMedium!.fontWeight, FontWeight.w600);

    expect(textTheme.labelSmall, isNotNull);
    expect(textTheme.labelSmall!.fontFamily, 'SUIT');
    expect(textTheme.labelSmall!.fontSize, 11);
    expect(textTheme.labelSmall!.fontWeight, FontWeight.w600);
  });
}
