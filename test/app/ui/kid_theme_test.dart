import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';

void main() {
  test('buildKidTheme exposes the kid layout tokens extension defaults', () {
    final theme = buildKidTheme();
    final layout = theme.extension<KidLayoutTheme>();

    expect(layout, isNotNull);
    expect(layout!.button.regular.height, 56);
    expect(layout.button.regular.horizontalPadding, 16);
    expect(layout.button.regular.iconGap, 10);
    expect(layout.button.regular.iconChipSize, 34);
    expect(layout.button.regular.iconSize, 18);
    expect(layout.button.regular.labelFontSize, 18);
    expect(layout.button.regular.labelFontWeight, FontWeight.w600);
    expect(layout.button.regular.labelLetterSpacing, -0.15);
    expect(layout.button.regular.labelHeight, 1.16);
    expect(layout.button.regular.primaryBorderWidth, 1.2);
    expect(layout.button.regular.secondaryBorderWidth, 1.1);
    expect(layout.button.regular.iconChipBorderWidth, 1.0);
    expect(layout.button.regular.radius, 24);
    expect(layout.button.regular.highlightTopInset, 1);
    expect(layout.button.regular.highlightHorizontalInset, 14);
    expect(layout.button.regular.highlightHeight, 10);
    expect(layout.button.regular.highlightRadius, 4);
    expect(layout.button.regular.iconChipRadius, 13);
    expect(layout.button.compact.height, 48);
    expect(layout.button.compact.horizontalPadding, 14);
    expect(layout.button.compact.iconGap, 8);
    expect(layout.button.compact.iconChipSize, 30);
    expect(layout.button.compact.iconSize, 16);
    expect(layout.button.compact.labelFontSize, 16);
    expect(layout.button.compact.labelFontWeight, FontWeight.w600);
    expect(layout.button.compact.labelLetterSpacing, -0.05);
    expect(layout.button.compact.labelHeight, 1.18);
    expect(layout.button.compact.primaryBorderWidth, 1.1);
    expect(layout.button.compact.secondaryBorderWidth, 1.0);
    expect(layout.button.compact.iconChipBorderWidth, 0.9);
    expect(layout.button.compact.radius, 22);
    expect(layout.button.compact.highlightTopInset, 1);
    expect(layout.button.compact.highlightHorizontalInset, 12);
    expect(layout.button.compact.highlightHeight, 8);
    expect(layout.button.compact.highlightRadius, 3);
    expect(layout.button.compact.iconChipRadius, 11);
    expect(layout.button.tight.labelFontSize, 14);
    expect(layout.button.tight.labelFontWeight, isNull);
    expect(layout.button.tight.labelLetterSpacing, isNull);
    expect(layout.button.tight.labelHeight, isNull);
    expect(layout.button.tight.iconChipBorderWidth, 0.8);
    expect(layout.button.tight.highlightRadius, 2.5);
    expect(layout.panel.regular.padding, const EdgeInsets.all(20));
    expect(layout.panel.regular.radius, 30);
    expect(layout.panel.regular.borderWidth, 1.4);
    expect(layout.panel.regular.highlightTopInset, 0);
    expect(layout.panel.regular.highlightHeight, 16);
    expect(layout.panel.regular.highlightHorizontalInset, 18);
    expect(layout.panel.regular.insetRadius, 22);
    expect(layout.panel.compact.padding, const EdgeInsets.all(10));
    expect(layout.panel.compact.radius, 26);
    expect(layout.panel.compact.borderWidth, 1.2);
    expect(layout.panel.compact.highlightTopInset, 0);
    expect(layout.panel.compact.highlightHeight, 12);
    expect(layout.panel.compact.highlightHorizontalInset, 14);
    expect(layout.panel.compact.insetRadius, 14);
    expect(layout.panel.tight.padding, const EdgeInsets.all(8));
    expect(layout.panel.tight.radius, 20);
    expect(layout.panel.tight.borderWidth, 1.1);
    expect(layout.panel.tight.highlightTopInset, 0);
    expect(layout.panel.tight.highlightHeight, 10);
    expect(layout.panel.tight.highlightHorizontalInset, 12);
    expect(layout.panel.tight.insetRadius, 12);
  });

  test('buildKidTheme exposes the kid typography token defaults', () {
    final theme = buildKidTheme();
    final typography = theme.extension<KidTypographyTheme>();

    expect(typography, isNotNull);
    expect(typography!.headlineLarge, theme.textTheme.headlineLarge);
    expect(typography.headlineMedium, theme.textTheme.headlineMedium);
    expect(typography.headlineSmall, theme.textTheme.headlineSmall);
    expect(typography.titleLarge, theme.textTheme.titleLarge);
    expect(typography.titleMedium, theme.textTheme.titleMedium);
    expect(typography.titleSmall, theme.textTheme.titleSmall);
    expect(typography.bodyLarge, theme.textTheme.bodyLarge);
    expect(typography.bodyMedium, theme.textTheme.bodyMedium);
    expect(typography.bodySmall, theme.textTheme.bodySmall);
    expect(typography.labelLarge, theme.textTheme.labelLarge);
    expect(typography.labelMedium, theme.textTheme.labelMedium);
    expect(typography.labelSmall, theme.textTheme.labelSmall);
  });

  test('KidTypographyTheme copyWith and lerp preserve and override styles', () {
    final customized = KidTypographyTheme.defaults.copyWith(
      titleLarge: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: Colors.deepPurple,
        height: 1.4,
        fontStyle: FontStyle.italic,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.teal,
        height: 1.6,
      ),
    );

    expect(customized.titleLarge.fontSize, 30);
    expect(customized.titleLarge.letterSpacing, 1.5);
    expect(customized.titleLarge.height, 1.4);
    expect(customized.titleLarge.fontStyle, FontStyle.italic);
    expect(customized.bodySmall.fontSize, 12);
    expect(customized.headlineLarge, KidTypographyTheme.defaults.headlineLarge);
    expect(customized.labelMedium, KidTypographyTheme.defaults.labelMedium);

    final lerped = KidTypographyTheme.defaults.lerp(customized, 0.5);

    expect(lerped.titleLarge.fontSize, closeTo(25, 0.001));
    expect(lerped.titleLarge.letterSpacing, closeTo(0.65, 0.001));
    expect(lerped.titleLarge.height, closeTo(1.34, 0.001));
    expect(lerped.titleLarge.fontStyle, FontStyle.italic);
    expect(lerped.bodySmall.fontSize, closeTo(12.5, 0.001));
    expect(lerped.bodySmall.height, closeTo(1.52, 0.001));
    expect(lerped.headlineLarge, KidTypographyTheme.defaults.headlineLarge);
    expect(lerped.labelMedium, KidTypographyTheme.defaults.labelMedium);
  });

  test(
    'KidPanelChromeTokens exposes tone-aware chrome defaults and keeps them through copyWith and lerp',
    () {
      final layout = buildKidTheme().extension<KidLayoutTheme>();

      expect(layout, isNotNull);
      expect(layout!.chrome.panel.surfaceBackgroundColor, KidPalette.cream);
      expect(layout.chrome.panel.surfaceBorderColor, KidPalette.stroke);
      expect(layout.chrome.panel.airyBackgroundColor, KidPalette.white);
      expect(layout.chrome.panel.airyBorderColor, KidPalette.stroke);
      expect(layout.chrome.panel.warmBackgroundColor, KidPalette.creamWarm);
      expect(layout.chrome.panel.warmBorderColor, KidPalette.stroke);
      expect(layout.chrome.panel.lilacBackgroundColor, KidPalette.lilac);
      expect(layout.chrome.panel.lilacBorderColor, KidPalette.stroke);
      expect(layout.chrome.panel.surfaceHighlightAlpha, 0.28);
      expect(layout.chrome.panel.airyHighlightAlpha, 0.34);
      expect(layout.chrome.panel.warmHighlightAlpha, 0.2);
      expect(layout.chrome.panel.lilacHighlightAlpha, 0.24);
      expect(layout.chrome.panel.surfaceShellGradientWhiteBlendAmount, 0.34);
      expect(layout.chrome.panel.airyShellGradientWhiteBlendAmount, 0.46);
      expect(layout.chrome.panel.warmShellGradientWhiteBlendAmount, 0.18);
      expect(layout.chrome.panel.lilacShellGradientWhiteBlendAmount, 0.3);
      expect(layout.chrome.panel.lilacBackgroundAlpha, 0.75);

      final copied = layout.chrome.panel.copyWith(
        surfaceBackgroundColor: const Color(0xFFFFE7C2),
        airyBorderColor: const Color(0xFF3A8D82),
        airyHighlightAlpha: 0.39,
        lilacShellGradientWhiteBlendAmount: 0.27,
      );
      const updated = KidPanelChromeTokens(
        warmBackgroundColor: Color(0xFFFFD1A0),
        warmBorderColor: Color(0xFFB06B3B),
        surfaceHighlightAlpha: 0.31,
        airyShellGradientWhiteBlendAmount: 0.5,
        warmHighlightAlpha: 0.16,
        lilacBackgroundAlpha: 0.52,
      );
      final lerped = layout.chrome.panel.lerp(updated, 1);

      expect(copied.surfaceBackgroundColor, const Color(0xFFFFE7C2));
      expect(copied.airyBorderColor, const Color(0xFF3A8D82));
      expect(copied.airyHighlightAlpha, 0.39);
      expect(copied.lilacShellGradientWhiteBlendAmount, 0.27);
      expect(copied.lilacBackgroundAlpha, 0.75);
      expect(lerped.warmBackgroundColor, const Color(0xFFFFD1A0));
      expect(lerped.warmBorderColor, const Color(0xFFB06B3B));
      expect(lerped.surfaceHighlightAlpha, 0.31);
      expect(lerped.airyShellGradientWhiteBlendAmount, 0.5);
      expect(lerped.warmHighlightAlpha, 0.16);
      expect(lerped.lilacBackgroundAlpha, 0.52);
    },
  );

  test(
    'KidButtonChromeTokens exposes shell and disabled gradient defaults and keeps them through copyWith and lerp',
    () {
      final layout = buildKidTheme().extension<KidLayoutTheme>();

      expect(layout, isNotNull);
      expect(layout!.chrome.button.primaryShellGradientStart, KidPalette.blue);
      expect(layout.chrome.button.primaryShellGradientEnd, KidPalette.blueDark);
      expect(
        layout.chrome.button.primaryDisabledGradientBlendTargetColor,
        KidPalette.body,
      );
      expect(
        layout.chrome.button.secondaryDisabledGradientBlendTargetColor,
        KidPalette.body,
      );

      const copiedStart = Color(0xFF4B7BFF);
      const copiedEnd = Color(0xFF2443BE);
      const copiedPrimaryDisabledTarget = Color(0xFF7A8A9B);
      const copiedSecondaryDisabledTarget = Color(0xFFB29D84);
      final copied = layout.chrome.button.copyWith(
        primaryShellGradientStart: copiedStart,
        primaryShellGradientEnd: copiedEnd,
        primaryDisabledGradientBlendTargetColor: copiedPrimaryDisabledTarget,
        secondaryDisabledGradientBlendTargetColor:
            copiedSecondaryDisabledTarget,
      );
      const updated = KidButtonChromeTokens(
        primaryShellGradientStart: Color(0xFF6E9DFF),
        primaryShellGradientEnd: Color(0xFF3157D8),
        primaryDisabledGradientBlendTargetColor: Color(0xFF8B9CAD),
        secondaryDisabledGradientBlendTargetColor: Color(0xFFC4B39A),
      );
      final lerped = layout.chrome.button.lerp(updated, 1);

      expect(copied.primaryShellGradientStart, copiedStart);
      expect(copied.primaryShellGradientEnd, copiedEnd);
      expect(
        copied.primaryDisabledGradientBlendTargetColor,
        copiedPrimaryDisabledTarget,
      );
      expect(
        copied.secondaryDisabledGradientBlendTargetColor,
        copiedSecondaryDisabledTarget,
      );
      expect(copied.secondaryShellGradientStart, KidPalette.cream);
      expect(copied.secondaryShellGradientEnd, KidPalette.creamWarm);
      expect(
        lerped.primaryShellGradientStart,
        updated.primaryShellGradientStart,
      );
      expect(lerped.primaryShellGradientEnd, updated.primaryShellGradientEnd);
      expect(
        lerped.primaryDisabledGradientBlendTargetColor,
        updated.primaryDisabledGradientBlendTargetColor,
      );
      expect(
        lerped.secondaryDisabledGradientBlendTargetColor,
        updated.secondaryDisabledGradientBlendTargetColor,
      );
    },
  );

  test(
    'KidPanelDensityTokens keeps highlightTopInset in copyWith and lerp',
    () {
      const base = KidPanelDensityTokens(
        padding: EdgeInsets.all(20),
        radius: 30,
        borderWidth: 1.4,
        highlightTopInset: 0,
        highlightHeight: 16,
        highlightHorizontalInset: 18,
        insetRadius: 22,
      );
      const other = KidPanelDensityTokens(
        padding: EdgeInsets.all(12),
        radius: 28,
        borderWidth: 1.3,
        highlightTopInset: 6,
        highlightHeight: 14,
        highlightHorizontalInset: 16,
        insetRadius: 16,
      );

      final updated = base.copyWith(highlightTopInset: 3);
      final lerped = base.lerp(other, 1);

      expect(updated.highlightTopInset, 3);
      expect(lerped.highlightTopInset, other.highlightTopInset);
    },
  );

  test(
    'KidButtonDensityTokens keeps highlight, highlight radius, and label tokens in copyWith and lerp',
    () {
      const base = KidButtonDensityTokens(
        height: 60,
        horizontalPadding: 16,
        iconGap: 10,
        iconChipSize: 34,
        iconChipBorderWidth: 1.4,
        iconSize: 18,
        labelFontSize: 19,
        labelFontWeight: FontWeight.w700,
        labelLetterSpacing: 0,
        labelHeight: 1.1,
        highlightTopInset: 1,
        highlightRadius: 4,
      );
      const other = KidButtonDensityTokens(
        height: 52,
        horizontalPadding: 14,
        iconGap: 8,
        iconChipSize: 30,
        iconChipBorderWidth: 0.8,
        iconSize: 16,
        labelFontSize: 17,
        labelFontWeight: FontWeight.w500,
        labelLetterSpacing: 0.4,
        labelHeight: 1.3,
        highlightTopInset: 3,
        highlightRadius: 2.5,
      );

      final updated = base.copyWith(
        iconChipBorderWidth: 1.1,
        labelFontWeight: FontWeight.w600,
        labelLetterSpacing: 0.2,
        labelHeight: 1.2,
        highlightTopInset: 2,
        highlightRadius: 3.5,
      );
      final lerped = base.lerp(other, 1);

      expect(updated.iconChipBorderWidth, 1.1);
      expect(updated.labelFontWeight, FontWeight.w600);
      expect(updated.labelLetterSpacing, 0.2);
      expect(updated.labelHeight, 1.2);
      expect(updated.highlightTopInset, 2);
      expect(updated.highlightRadius, 3.5);
      expect(lerped.iconChipBorderWidth, other.iconChipBorderWidth);
      expect(lerped.labelFontWeight, other.labelFontWeight);
      expect(lerped.labelLetterSpacing, other.labelLetterSpacing);
      expect(lerped.labelHeight, other.labelHeight);
      expect(lerped.highlightTopInset, other.highlightTopInset);
      expect(lerped.highlightRadius, other.highlightRadius);
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

  test(
    'KidButtonDensityTokens copyWith can clear typography overrides back to inherited fallback',
    () {
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

      final cleared = explicit.copyWith(
        clearLabelFontWeight: true,
        clearLabelLetterSpacing: true,
        clearLabelHeight: true,
      );

      expect(cleared.labelFontWeight, isNull);
      expect(cleared.labelLetterSpacing, isNull);
      expect(cleared.labelHeight, isNull);
    },
  );

  test(
    'button radius tokens expose defaults and keep nullable fallback discrete during lerp',
    () {
      final layout = buildKidTheme().extension<KidLayoutTheme>();
      expect(layout, isNotNull);
      expect(layout!.button.regular.radius, 24);
      expect(layout.button.compact.radius, 22);

      const inherited = KidButtonDensityTokens(
        height: 60,
        horizontalPadding: 16,
        iconGap: 10,
        iconChipSize: 34,
        iconSize: 18,
        labelFontSize: 19,
      );
      const explicit = KidButtonDensityTokens(
        height: 52,
        horizontalPadding: 14,
        iconGap: 8,
        iconChipSize: 30,
        iconSize: 16,
        labelFontSize: 17,
        radius: 22,
      );

      final beforeSwitch = inherited.lerp(explicit, 0.49);
      final afterSwitch = inherited.lerp(explicit, 0.5);
      final beforeDrop = explicit.lerp(inherited, 0.49);
      final afterDrop = explicit.lerp(inherited, 0.5);

      expect(beforeSwitch.radius, isNull);
      expect(afterSwitch.radius, explicit.radius);
      expect(beforeDrop.radius, explicit.radius);
      expect(afterDrop.radius, isNull);

      final preservedRadius = KidLayoutTheme.defaults.button.regular.copyWith(
        height: 88,
      );
      final clearedRadius = KidLayoutTheme.defaults.button.regular.copyWith(
        height: 88,
        clearRadius: true,
      );
      expect(preservedRadius.radius, 24);
      expect(clearedRadius.radius, isNull);
    },
  );

  test('KidShadowTokens snapshots caller-owned lists as unmodifiable', () {
    final buttonPrimary = <BoxShadow>[
      const BoxShadow(
        color: Color(0x11182230),
        blurRadius: 18,
        offset: Offset(0, 8),
      ),
    ];
    final buttonSecondary = <BoxShadow>[
      const BoxShadow(
        color: Color(0x22182230),
        blurRadius: 12,
        offset: Offset(0, 6),
      ),
    ];
    final panel = <BoxShadow>[
      const BoxShadow(
        color: Color(0x33182230),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ];

    final tokens = KidShadowTokens(
      buttonPrimary: buttonPrimary,
      buttonSecondary: buttonSecondary,
      panel: panel,
    );

    buttonPrimary.add(
      const BoxShadow(
        color: Color(0x44182230),
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
    );
    buttonSecondary.clear();
    panel[0] = const BoxShadow(
      color: Color(0x55182230),
      blurRadius: 8,
      offset: Offset(0, 3),
    );

    expect(tokens.buttonPrimary, hasLength(1));
    expect(tokens.buttonSecondary, hasLength(1));
    expect(tokens.panel.single.color, const Color(0x33182230));
    expect(
      () => tokens.buttonPrimary.add(
        const BoxShadow(
          color: Color(0x66182230),
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ),
      throwsUnsupportedError,
    );
  });

  test(
    'KidShadowTokens keeps calm inset defaults while inheriting legacy panel overrides when inset surface is unset',
    () {
      const genericPanelOverride = [
        BoxShadow(
          color: Color(0x28112233),
          blurRadius: 24,
          offset: Offset(0, 14),
        ),
        BoxShadow(
          color: Color(0x10000000),
          blurRadius: 5,
          offset: Offset(1, 2),
        ),
      ];

      expect(KidShadowTokens.defaults.panel, KidShadows.panel);
      expect(KidShadowTokens.defaults.surfacePanel, KidShadows.panel);
      expect(KidShadowTokens.defaults.airyPanel, KidShadows.panelAiry);
      expect(KidShadowTokens.defaults.warmPanel, KidShadows.panel);
      expect(KidShadowTokens.defaults.lilacPanel, KidShadows.panel);
      expect(KidShadowTokens.defaults.insetSurface, KidShadows.insetSurface);
      expect(KidShadows.insetSurface, hasLength(KidShadows.panel.length));
      for (var i = 0; i < KidShadows.insetSurface.length; i += 1) {
        expect(
          KidShadows.insetSurface[i].blurRadius,
          lessThan(KidShadows.panel[i].blurRadius),
        );
        expect(
          KidShadows.insetSurface[i].offset.dy,
          lessThan(KidShadows.panel[i].offset.dy),
        );
      }

      final constructed = KidShadowTokens(panel: genericPanelOverride);
      final copied = KidShadowTokens.defaults.copyWith(
        panel: genericPanelOverride,
      );
      final lerped = KidShadowTokens.defaults.lerp(constructed, 1);

      expect(constructed.panel, genericPanelOverride);
      expect(constructed.surfacePanel, genericPanelOverride);
      expect(constructed.airyPanel, genericPanelOverride);
      expect(constructed.warmPanel, genericPanelOverride);
      expect(constructed.lilacPanel, genericPanelOverride);
      expect(constructed.insetSurface, genericPanelOverride);
      expect(copied.insetSurface, genericPanelOverride);
      expect(lerped.insetSurface, genericPanelOverride);
    },
  );

  test(
    'KidShadowTokens keeps panel alias synced with surfacePanel updates',
    () {
      const surfaceOverride = [
        BoxShadow(
          color: Color(0x22102030),
          blurRadius: 19,
          offset: Offset(0, 9),
        ),
      ];

      final constructed = KidShadowTokens(surfacePanel: surfaceOverride);
      final copied = KidShadowTokens.defaults.copyWith(
        surfacePanel: surfaceOverride,
      );
      final lerped = KidShadowTokens.defaults.lerp(constructed, 1);

      expect(constructed.panel, surfaceOverride);
      expect(constructed.surfacePanel, surfaceOverride);
      expect(constructed.insetSurface, surfaceOverride);
      expect(copied.panel, surfaceOverride);
      expect(copied.surfacePanel, surfaceOverride);
      expect(copied.insetSurface, surfaceOverride);
      expect(lerped.panel, lerped.surfacePanel);
      expect(lerped.surfacePanel.first, surfaceOverride.first);
      expect(lerped.insetSurface.first, surfaceOverride.first);
    },
  );

  test(
    'KidShadowTokens keeps an explicit inset surface shadow taking precedence over panel fallbacks',
    () {
      const surfaceOverride = [
        BoxShadow(
          color: Color(0x22102030),
          blurRadius: 19,
          offset: Offset(0, 9),
        ),
      ];
      const insetSurfaceOverride = [
        BoxShadow(
          color: Color(0x16102030),
          blurRadius: 14,
          offset: Offset(0, 6),
        ),
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ];

      final constructed = KidShadowTokens(
        surfacePanel: surfaceOverride,
        insetSurface: insetSurfaceOverride,
      );
      final copied = KidShadowTokens.defaults.copyWith(
        surfacePanel: surfaceOverride,
        insetSurface: insetSurfaceOverride,
      );
      final lerped = KidShadowTokens.defaults.lerp(constructed, 1);

      expect(constructed.insetSurface, insetSurfaceOverride);
      expect(copied.insetSurface, insetSurfaceOverride);
      expect(lerped.insetSurface, insetSurfaceOverride);
      expect(constructed.panel, surfaceOverride);
      expect(constructed.surfacePanel, surfaceOverride);
      expect(copied.panel, surfaceOverride);
      expect(copied.surfacePanel, surfaceOverride);
      expect(lerped.panel.first, surfaceOverride.first);
      expect(lerped.surfacePanel.first, surfaceOverride.first);
    },
  );

  test('KidShadowTokens copyWith and lerp keep frozen shadow snapshots', () {
    final replacementPrimary = <BoxShadow>[
      const BoxShadow(
        color: Color(0x111B4FA7),
        blurRadius: 22,
        offset: Offset(0, 10),
      ),
    ];
    final replacementPanel = <BoxShadow>[
      const BoxShadow(
        color: Color(0x11182230),
        blurRadius: 20,
        offset: Offset(0, 11),
      ),
    ];
    final replacementAiryPanel = <BoxShadow>[
      const BoxShadow(
        color: Color(0x16182230),
        blurRadius: 16,
        offset: Offset(0, 9),
      ),
    ];
    final replacementInsetSurface = <BoxShadow>[
      const BoxShadow(
        color: Color(0x12182230),
        blurRadius: 12,
        offset: Offset(0, 5),
      ),
    ];
    final copied = KidShadowTokens.defaults.copyWith(
      buttonPrimary: replacementPrimary,
      panel: replacementPanel,
      airyPanel: replacementAiryPanel,
      insetSurface: replacementInsetSurface,
    );

    replacementPrimary.add(
      const BoxShadow(
        color: Color(0x221B4FA7),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    );
    replacementPanel.add(
      const BoxShadow(
        color: Color(0x22182230),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    );
    replacementAiryPanel.add(
      const BoxShadow(
        color: Color(0x26182230),
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    );
    replacementInsetSurface.add(
      const BoxShadow(
        color: Color(0x22182230),
        blurRadius: 5,
        offset: Offset(0, 2),
      ),
    );

    final lerped =
        KidShadowTokens(
          airyPanel: <BoxShadow>[
            const BoxShadow(
              color: Color(0x14182230),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ).lerp(
          KidShadowTokens(
            airyPanel: <BoxShadow>[
              const BoxShadow(
                color: Color(0x24182230),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          0.5,
        );

    expect(copied.buttonPrimary, hasLength(1));
    expect(copied.panel, replacementPanel.take(1).toList());
    expect(copied.surfacePanel, replacementPanel.take(1).toList());
    expect(copied.airyPanel, replacementAiryPanel.take(1).toList());
    expect(copied.warmPanel, replacementPanel.take(1).toList());
    expect(copied.lilacPanel, replacementPanel.take(1).toList());
    expect(copied.insetSurface, replacementInsetSurface.take(1).toList());
    expect(
      () => copied.buttonPrimary.add(
        const BoxShadow(
          color: Color(0x331B4FA7),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ),
      throwsUnsupportedError,
    );
    expect(
      () => copied.insetSurface.add(
        const BoxShadow(
          color: Color(0x32182230),
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ),
      throwsUnsupportedError,
    );
    expect(
      () => copied.airyPanel.add(
        const BoxShadow(
          color: Color(0x34182230),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ),
      throwsUnsupportedError,
    );
    expect(
      () => lerped.airyPanel.add(
        const BoxShadow(
          color: Color(0x44182230),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ),
      throwsUnsupportedError,
    );
  });

  test('buildKidTheme exposes the kid chrome token defaults', () {
    final theme = buildKidTheme();
    final layout = theme.extension<KidLayoutTheme>();

    expect(layout, isNotNull);
    expect(KidShadows.button, const [
      BoxShadow(
        color: Color(0x241B4FA7),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
      BoxShadow(color: Color(0x14182230), blurRadius: 10, offset: Offset(0, 4)),
    ]);
    expect(KidShadows.buttonSoft, const [
      BoxShadow(color: Color(0x12182230), blurRadius: 18, offset: Offset(0, 8)),
      BoxShadow(color: Color(0x08182230), blurRadius: 6, offset: Offset(0, 2)),
    ]);
    expect(layout!.chrome.button.primaryBorderAlpha, 0.12);
    expect(layout.chrome.button.primaryIconChipAlpha, 0.14);
    expect(layout.chrome.button.primaryIconChipBorderAlpha, 0.08);
    expect(layout.chrome.button.primaryHighlightAlpha, 0.14);
    expect(layout.chrome.button.secondaryShellGradientStart, KidPalette.cream);
    expect(
      layout.chrome.button.secondaryShellGradientEnd,
      KidPalette.creamWarm,
    );
    expect(layout.chrome.button.secondaryBorderAlpha, 0.56);
    expect(layout.chrome.button.secondaryIconChipAlpha, 0.68);
    expect(layout.chrome.button.secondaryIconChipBorderAlpha, 0.44);
    expect(layout.chrome.button.secondaryHighlightAlpha, 0.05);
    expect(layout.chrome.shadows.buttonPrimary, const [
      BoxShadow(color: Color(0x161B4FA7), blurRadius: 18, offset: Offset(0, 8)),
      BoxShadow(color: Color(0x10182230), blurRadius: 6, offset: Offset(0, 2)),
    ]);
    expect(
      layout.chrome.shadows.buttonPrimary,
      isNot(equals(KidShadows.button)),
    );
    expect(layout.chrome.shadows.buttonSecondary, const [
      BoxShadow(color: Color(0x0E182230), blurRadius: 14, offset: Offset(0, 6)),
      BoxShadow(color: Color(0x06182230), blurRadius: 4, offset: Offset(0, 1)),
    ]);
    expect(
      layout.chrome.shadows.buttonSecondary,
      isNot(equals(KidShadows.buttonSoft)),
    );
    expect(layout.chrome.button.primaryDisabledGradientBlendAmount, 0.36);
    expect(layout.chrome.button.secondaryDisabledGradientBlendAmount, 0.16);
    expect(layout.chrome.button.disabledOpacity, 0.58);
    expect(layout.chrome.panel.strokeBorderAlpha, 0.88);
    expect(layout.chrome.panel.customBorderAlpha, 0.72);
    expect(layout.chrome.panel.highlightAlpha, 0.28);
    expect(layout.chrome.panel.surfaceHighlightAlpha, 0.28);
    expect(layout.chrome.panel.airyHighlightAlpha, 0.34);
    expect(layout.chrome.panel.warmHighlightAlpha, 0.2);
    expect(layout.chrome.panel.lilacHighlightAlpha, 0.24);
    expect(layout.chrome.panel.airyBackgroundAlpha, 0.94);
    expect(layout.chrome.panel.lilacBackgroundAlpha, 0.75);
    expect(layout.chrome.panel.shellGradientWhiteBlendAmount, 0.34);
    expect(layout.chrome.panel.surfaceShellGradientWhiteBlendAmount, 0.34);
    expect(layout.chrome.panel.airyShellGradientWhiteBlendAmount, 0.46);
    expect(layout.chrome.panel.warmShellGradientWhiteBlendAmount, 0.18);
    expect(layout.chrome.panel.lilacShellGradientWhiteBlendAmount, 0.3);
  });

  test('KidButtonChromeTokens exposes secondary shell and border tokens', () {
    final layout = buildKidTheme().extension<KidLayoutTheme>();
    const updatedStart = Color(0xFFF8F1E4);
    const updatedEnd = Color(0xFFEAD9BE);

    expect(layout, isNotNull);
    expect(layout!.chrome.button.secondaryShellGradientStart, KidPalette.cream);
    expect(
      layout.chrome.button.secondaryShellGradientEnd,
      KidPalette.creamWarm,
    );
    expect(layout.chrome.button.secondaryBorderAlpha, 0.56);
    expect(layout.chrome.button.secondaryIconChipBorderAlpha, 0.44);

    final preserved = layout.chrome.button.copyWith(primaryBorderAlpha: 0.44);
    const updated = KidButtonChromeTokens(
      secondaryShellGradientStart: updatedStart,
      secondaryShellGradientEnd: updatedEnd,
      secondaryBorderAlpha: 0.64,
      secondaryIconChipBorderAlpha: 0.48,
    );

    expect(preserved.secondaryShellGradientStart, KidPalette.cream);
    expect(preserved.secondaryShellGradientEnd, KidPalette.creamWarm);
    expect(preserved.secondaryBorderAlpha, 0.56);
    expect(preserved.secondaryIconChipBorderAlpha, 0.44);
    expect(
      layout.chrome.button.lerp(updated, 1).secondaryShellGradientStart,
      updatedStart,
    );
    expect(
      layout.chrome.button.lerp(updated, 1).secondaryShellGradientEnd,
      updatedEnd,
    );
    expect(layout.chrome.button.lerp(updated, 1).secondaryBorderAlpha, 0.64);
    expect(
      layout.chrome.button.lerp(updated, 1).secondaryIconChipBorderAlpha,
      0.48,
    );
  });

  test(
    'KidButtonChromeTokens keeps disabled blend amounts in copyWith and lerp',
    () {
      const base = KidButtonChromeTokens(
        primaryDisabledGradientBlendAmount: 0.36,
        secondaryDisabledGradientBlendAmount: 0.16,
      );
      const other = KidButtonChromeTokens(
        primaryDisabledGradientBlendAmount: 0.64,
        secondaryDisabledGradientBlendAmount: 0.28,
      );

      final updated = base.copyWith(
        primaryDisabledGradientBlendAmount: 0.52,
        secondaryDisabledGradientBlendAmount: 0.22,
      );
      final lerped = base.lerp(other, 1);

      expect(updated.primaryDisabledGradientBlendAmount, 0.52);
      expect(updated.secondaryDisabledGradientBlendAmount, 0.22);
      expect(
        lerped.primaryDisabledGradientBlendAmount,
        other.primaryDisabledGradientBlendAmount,
      );
      expect(
        lerped.secondaryDisabledGradientBlendAmount,
        other.secondaryDisabledGradientBlendAmount,
      );
    },
  );

  test(
    'KidButtonChromeTokens exposes foreground colors and keeps them through copyWith and lerp',
    () {
      final layout = buildKidTheme().extension<KidLayoutTheme>();
      const updatedPrimaryForeground = Color(0xFFF9FAFB);
      const updatedSecondaryForeground = Color(0xFF234567);

      expect(layout, isNotNull);
      expect(layout!.chrome.button.primaryForegroundColor, KidPalette.white);
      expect(layout.chrome.button.secondaryForegroundColor, KidPalette.navy);

      final updated = layout.chrome.button.copyWith(
        primaryForegroundColor: updatedPrimaryForeground,
        secondaryForegroundColor: updatedSecondaryForeground,
      );
      final preserved = layout.chrome.button.copyWith(primaryBorderAlpha: 0.44);
      const lerpTarget = KidButtonChromeTokens(
        primaryForegroundColor: updatedPrimaryForeground,
        secondaryForegroundColor: updatedSecondaryForeground,
      );

      expect(updated.primaryForegroundColor, updatedPrimaryForeground);
      expect(updated.secondaryForegroundColor, updatedSecondaryForeground);
      expect(preserved.primaryForegroundColor, KidPalette.white);
      expect(preserved.secondaryForegroundColor, KidPalette.navy);
      expect(
        layout.chrome.button.lerp(lerpTarget, 1).primaryForegroundColor,
        updatedPrimaryForeground,
      );
      expect(
        layout.chrome.button.lerp(lerpTarget, 1).secondaryForegroundColor,
        updatedSecondaryForeground,
      );
    },
  );

  test('buildKidTheme defines a calmer supporting label hierarchy', () {
    final theme = buildKidTheme();
    final textTheme = theme.textTheme;

    expect(textTheme.labelLarge?.fontFamily, 'SUIT');
    expect(textTheme.labelLarge?.fontSize, 13);
    expect(textTheme.labelLarge?.fontWeight, FontWeight.w600);
    expect(textTheme.labelLarge?.letterSpacing, 0.02);
    expect(textTheme.labelLarge?.color, KidPalette.navy);
    expect(textTheme.labelLarge?.height, 1.22);

    expect(textTheme.labelMedium?.fontFamily, 'SUIT');
    expect(textTheme.labelMedium?.fontSize, 12);
    expect(textTheme.labelMedium?.fontWeight, FontWeight.w600);
    expect(textTheme.labelMedium?.letterSpacing, 0.02);
    expect(textTheme.labelMedium?.color, KidPalette.body);
    expect(textTheme.labelMedium?.height, 1.22);

    expect(textTheme.labelSmall?.fontFamily, 'SUIT');
    expect(textTheme.labelSmall?.fontSize, 11);
    expect(textTheme.labelSmall?.fontWeight, FontWeight.w600);
    expect(textTheme.labelSmall?.letterSpacing, 0.02);
    expect(textTheme.labelSmall?.color, KidPalette.body);
    expect(textTheme.labelSmall?.height, 1.2);

    expect(textTheme.bodyMedium?.fontWeight, FontWeight.w500);
    expect(textTheme.bodySmall?.fontWeight, FontWeight.w400);

    expect(theme.chipTheme.labelStyle, textTheme.labelLarge);
  });
}
