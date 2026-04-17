import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';

void main() {
  test('buildKidTheme exposes the kid layout tokens extension defaults', () {
    final theme = buildKidTheme();
    final layout = theme.extension<KidLayoutTheme>();

    expect(layout, isNotNull);
    expect(layout!.button.regular.height, 64);
    expect(layout.button.regular.horizontalPadding, 18);
    expect(layout.button.regular.iconGap, 12);
    expect(layout.button.regular.iconChipSize, 36);
    expect(layout.button.regular.iconSize, 20);
    expect(layout.button.regular.labelFontSize, 22);
    expect(layout.button.regular.primaryBorderWidth, 1.3);
    expect(layout.button.regular.secondaryBorderWidth, 1.2);
    expect(layout.button.regular.highlightHorizontalInset, 16);
    expect(layout.button.regular.highlightHeight, 12);
    expect(layout.button.regular.iconChipRadius, 14);
    expect(layout.button.compact.height, 56);
    expect(layout.button.compact.horizontalPadding, 16);
    expect(layout.button.compact.iconGap, 10);
    expect(layout.button.compact.iconChipSize, 32);
    expect(layout.button.compact.iconSize, 18);
    expect(layout.button.compact.labelFontSize, 20);
    expect(layout.button.compact.primaryBorderWidth, 1.2);
    expect(layout.button.compact.secondaryBorderWidth, 1.1);
    expect(layout.button.compact.highlightHorizontalInset, 14);
    expect(layout.button.compact.highlightHeight, 10);
    expect(layout.button.compact.iconChipRadius, 12);
    expect(layout.panel.regular.padding, const EdgeInsets.all(24));
    expect(layout.panel.regular.radius, 32);
    expect(layout.panel.regular.borderWidth, 1.5);
    expect(layout.panel.regular.highlightHeight, 18);
    expect(layout.panel.regular.highlightHorizontalInset, 20);
    expect(layout.panel.regular.insetRadius, 24);
    expect(layout.panel.compact.padding, const EdgeInsets.all(14));
    expect(layout.panel.compact.radius, 32);
    expect(layout.panel.compact.borderWidth, 1.4);
    expect(layout.panel.compact.highlightHeight, 16);
    expect(layout.panel.compact.highlightHorizontalInset, 18);
    expect(layout.panel.compact.insetRadius, 18);
    expect(layout.panel.tight.padding, const EdgeInsets.all(12));
    expect(layout.panel.tight.radius, 24);
    expect(layout.panel.tight.borderWidth, 1.3);
    expect(layout.panel.tight.highlightHeight, 14);
    expect(layout.panel.tight.highlightHorizontalInset, 16);
    expect(layout.panel.tight.insetRadius, 16);
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
