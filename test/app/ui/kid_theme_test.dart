import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';

void main() {
  test('buildKidTheme exposes the kid layout tokens extension defaults', () {
    final theme = buildKidTheme();
    final layout = theme.extension<KidLayoutTheme>();

    expect(layout, isNotNull);
    expect(layout!.button.regular.height, 60);
    expect(layout.button.regular.horizontalPadding, 16);
    expect(layout.button.regular.iconGap, 10);
    expect(layout.button.regular.iconChipSize, 34);
    expect(layout.button.regular.iconSize, 18);
    expect(layout.button.regular.labelFontSize, 19);
    expect(layout.button.regular.labelFontWeight, FontWeight.w700);
    expect(layout.button.regular.labelLetterSpacing, 0);
    expect(layout.button.regular.labelHeight, 1.1);
    expect(layout.button.regular.primaryBorderWidth, 1.2);
    expect(layout.button.regular.secondaryBorderWidth, 1.1);
    expect(layout.button.regular.highlightHorizontalInset, 14);
    expect(layout.button.regular.highlightHeight, 10);
    expect(layout.button.regular.iconChipRadius, 13);
    expect(layout.button.compact.height, 52);
    expect(layout.button.compact.horizontalPadding, 14);
    expect(layout.button.compact.iconGap, 8);
    expect(layout.button.compact.iconChipSize, 30);
    expect(layout.button.compact.iconSize, 16);
    expect(layout.button.compact.labelFontSize, 17);
    expect(layout.button.compact.labelFontWeight, FontWeight.w700);
    expect(layout.button.compact.labelLetterSpacing, 0);
    expect(layout.button.compact.labelHeight, 1.1);
    expect(layout.button.compact.primaryBorderWidth, 1.1);
    expect(layout.button.compact.secondaryBorderWidth, 1.0);
    expect(layout.button.compact.highlightHorizontalInset, 12);
    expect(layout.button.compact.highlightHeight, 8);
    expect(layout.button.compact.iconChipRadius, 11);
    expect(layout.panel.regular.padding, const EdgeInsets.all(20));
    expect(layout.panel.regular.radius, 30);
    expect(layout.panel.regular.borderWidth, 1.4);
    expect(layout.panel.regular.highlightHeight, 16);
    expect(layout.panel.regular.highlightHorizontalInset, 18);
    expect(layout.panel.regular.insetRadius, 22);
    expect(layout.panel.compact.padding, const EdgeInsets.all(12));
    expect(layout.panel.compact.radius, 28);
    expect(layout.panel.compact.borderWidth, 1.3);
    expect(layout.panel.compact.highlightHeight, 14);
    expect(layout.panel.compact.highlightHorizontalInset, 16);
    expect(layout.panel.compact.insetRadius, 16);
    expect(layout.panel.tight.padding, const EdgeInsets.all(10));
    expect(layout.panel.tight.radius, 22);
    expect(layout.panel.tight.borderWidth, 1.2);
    expect(layout.panel.tight.highlightHeight, 12);
    expect(layout.panel.tight.highlightHorizontalInset, 14);
    expect(layout.panel.tight.insetRadius, 14);
  });

  test(
    'KidButtonDensityTokens keeps label typography tokens in copyWith and lerp',
    () {
      const base = KidButtonDensityTokens(
        height: 60,
        horizontalPadding: 16,
        iconGap: 10,
        iconChipSize: 34,
        iconSize: 18,
        labelFontSize: 19,
        labelFontWeight: FontWeight.w700,
        labelLetterSpacing: 0,
        labelHeight: 1.1,
      );
      const other = KidButtonDensityTokens(
        height: 52,
        horizontalPadding: 14,
        iconGap: 8,
        iconChipSize: 30,
        iconSize: 16,
        labelFontSize: 17,
        labelFontWeight: FontWeight.w500,
        labelLetterSpacing: 0.4,
        labelHeight: 1.3,
      );

      final updated = base.copyWith(
        labelFontWeight: FontWeight.w600,
        labelLetterSpacing: 0.2,
        labelHeight: 1.2,
      );
      final lerped = base.lerp(other, 1);

      expect(updated.labelFontWeight, FontWeight.w600);
      expect(updated.labelLetterSpacing, 0.2);
      expect(updated.labelHeight, 1.2);
      expect(lerped.labelFontWeight, other.labelFontWeight);
      expect(lerped.labelLetterSpacing, other.labelLetterSpacing);
      expect(lerped.labelHeight, other.labelHeight);
    },
  );

  test(
    'KidButtonDensityTokens keeps nullable typography fallback discrete during lerp',
    () {
      const inherited = KidButtonDensityTokens(
        height: 60,
        horizontalPadding: 16,
        iconGap: 10,
        iconChipSize: 34,
        iconSize: 18,
        labelFontSize: 19,
      );
      const explicit = KidButtonDensityTokens(
        height: 60,
        horizontalPadding: 16,
        iconGap: 10,
        iconChipSize: 34,
        iconSize: 18,
        labelFontSize: 19,
        labelFontWeight: FontWeight.w700,
        labelLetterSpacing: 0,
        labelHeight: 1.1,
      );

      final beforeSwitch = inherited.lerp(explicit, 0.49);
      final afterSwitch = inherited.lerp(explicit, 0.5);

      expect(beforeSwitch.labelFontWeight, isNull);
      expect(beforeSwitch.labelLetterSpacing, isNull);
      expect(beforeSwitch.labelHeight, isNull);
      expect(afterSwitch.labelFontWeight, explicit.labelFontWeight);
      expect(afterSwitch.labelLetterSpacing, explicit.labelLetterSpacing);
      expect(afterSwitch.labelHeight, explicit.labelHeight);
    },
  );

  test('buildKidTheme exposes the kid chrome token defaults', () {
    final theme = buildKidTheme();
    final layout = theme.extension<KidLayoutTheme>();

    expect(layout, isNotNull);
    expect(layout!.chrome.button.primaryBorderAlpha, 0.16);
    expect(layout.chrome.button.primaryIconChipAlpha, 0.18);
    expect(layout.chrome.button.primaryIconChipBorderAlpha, 0.12);
    expect(layout.chrome.button.primaryHighlightAlpha, 0.22);
    expect(layout.chrome.button.secondaryIconChipAlpha, 0.88);
    expect(layout.chrome.button.secondaryHighlightAlpha, 0.14);
    expect(layout.chrome.panel.strokeBorderAlpha, 0.88);
    expect(layout.chrome.panel.customBorderAlpha, 0.72);
    expect(layout.chrome.panel.highlightAlpha, 0.28);
    expect(layout.chrome.panel.airyBackgroundAlpha, 0.94);
  });

  test('buildKidTheme defines a calmer supporting label hierarchy', () {
    final theme = buildKidTheme();
    final textTheme = theme.textTheme;

    expect(textTheme.labelLarge?.fontSize, 14);
    expect(textTheme.labelLarge?.fontWeight, FontWeight.w700);
    expect(textTheme.labelLarge?.letterSpacing, -0.1);
    expect(textTheme.labelLarge?.color, KidPalette.navy);
    expect(textTheme.labelLarge?.height, 1.15);

    expect(textTheme.labelMedium?.fontSize, 12);
    expect(textTheme.labelMedium?.fontWeight, FontWeight.w600);
    expect(textTheme.labelMedium?.letterSpacing, 0);
    expect(textTheme.labelMedium?.color, KidPalette.body);
    expect(textTheme.labelMedium?.height, 1.2);

    expect(textTheme.labelSmall?.fontSize, 11);
    expect(textTheme.labelSmall?.fontWeight, FontWeight.w600);
    expect(textTheme.labelSmall?.letterSpacing, 0);
    expect(textTheme.labelSmall?.color, KidPalette.body);
    expect(textTheme.labelSmall?.height, 1.18);

    expect(textTheme.bodyMedium?.fontWeight, FontWeight.w500);
    expect(textTheme.bodySmall?.fontWeight, FontWeight.w500);

    expect(theme.chipTheme.labelStyle, textTheme.labelLarge);
  });
}
