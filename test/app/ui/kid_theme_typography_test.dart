import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';

void main() {
  test('buildKidTheme uses calmer supporting typography defaults', () {
    final textTheme = buildKidTheme().textTheme;

    expect(textTheme.titleMedium, isNotNull);
    expect(textTheme.titleMedium!.fontSize, 17);
    expect(textTheme.titleMedium!.fontWeight, FontWeight.w700);
    expect(textTheme.titleMedium!.letterSpacing, -0.1);
    expect(textTheme.titleMedium!.height, 1.20);
    expect(textTheme.titleMedium!.color, KidPalette.body);

    expect(textTheme.titleSmall, isNotNull);
    expect(textTheme.titleSmall!.fontSize, 14);
    expect(textTheme.titleSmall!.fontWeight, FontWeight.w700);
    expect(textTheme.titleSmall!.letterSpacing, 0);
    expect(textTheme.titleSmall!.height, 1.18);
    expect(textTheme.titleSmall!.color, KidPalette.body);

    expect(textTheme.bodyLarge, isNotNull);
    expect(textTheme.bodyLarge!.fontSize, 16);
    expect(textTheme.bodyLarge!.fontWeight, FontWeight.w600);
    expect(textTheme.bodyLarge!.height, 1.30);
    expect(textTheme.bodyLarge!.color, KidPalette.body);

    expect(textTheme.bodyMedium, isNotNull);
    expect(textTheme.bodyMedium!.fontSize, 15);
    expect(textTheme.bodyMedium!.fontWeight, FontWeight.w500);
    expect(textTheme.bodyMedium!.height, 1.30);
    expect(textTheme.bodyMedium!.color, KidPalette.body);

    expect(textTheme.bodySmall, isNotNull);
    expect(textTheme.bodySmall!.fontSize, 13);
    expect(textTheme.bodySmall!.fontWeight, FontWeight.w500);
    expect(textTheme.bodySmall!.height, 1.25);
    expect(textTheme.bodySmall!.color, KidPalette.body);

    expect(textTheme.labelLarge, isNotNull);
    expect(textTheme.labelLarge!.fontSize, 13);
    expect(textTheme.labelLarge!.fontWeight, FontWeight.w700);
    expect(textTheme.labelLarge!.letterSpacing, 0);
    expect(textTheme.labelLarge!.height, 1.12);
    expect(textTheme.labelLarge!.color, KidPalette.navy);
  });
}
