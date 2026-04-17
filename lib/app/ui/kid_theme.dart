import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class KidPalette {
  static const skyTop = Color(0xFFF7F5EF);
  static const skyBottom = Color(0xFFE3EDF8);
  static const cream = Color(0xFFFFFCF8);
  static const creamWarm = Color(0xFFF4EBDD);
  static const navy = Color(0xFF202937);
  static const body = Color(0xFF5E6B79);
  static const coral = Color(0xFFFF8E76);
  static const coralDark = Color(0xFFE06A56);
  static const blue = Color(0xFF2F6EDC);
  static const blueDark = Color(0xFF1B4FA7);
  static const blueSoft = Color(0xFFDCEAFF);
  static const mint = Color(0xFFDCEEDF);
  static const mintDark = Color(0xFF4F7E63);
  static const yellow = Color(0xFFF4D489);
  static const yellowDark = Color(0xFFC09135);
  static const lilac = Color(0xFFE4E0FF);
  static const stroke = Color(0xFFE4E8EF);
  static const white = Colors.white;
}

class KidShadows {
  static const panel = [
    BoxShadow(color: Color(0x17182230), blurRadius: 28, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x0D182230), blurRadius: 10, offset: Offset(0, 4)),
  ];

  static const button = [
    BoxShadow(color: Color(0x241B4FA7), blurRadius: 24, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x14182230), blurRadius: 10, offset: Offset(0, 4)),
  ];

  static const buttonSoft = [
    BoxShadow(color: Color(0x12182230), blurRadius: 18, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x08182230), blurRadius: 6, offset: Offset(0, 2)),
  ];
}

enum ToyButtonDensity { regular, compact }

enum ToyPanelDensity { regular, compact, tight }

@immutable
class KidButtonDensityTokens {
  const KidButtonDensityTokens({
    required this.height,
    required this.horizontalPadding,
    required this.iconGap,
    required this.iconChipSize,
    required this.iconSize,
    required this.labelFontSize,
    this.labelFontWeight,
    this.labelLetterSpacing,
    this.labelHeight,
    this.primaryBorderWidth = 1.3,
    this.secondaryBorderWidth = 1.2,
    this.radius,
    this.highlightTopInset = 1,
    this.highlightHeight = 12,
    this.highlightHorizontalInset = 16,
    this.iconChipRadius = 14,
  });

  final double height;
  final double horizontalPadding;
  final double iconGap;
  final double iconChipSize;
  final double iconSize;
  final double labelFontSize;
  final FontWeight? labelFontWeight;
  final double? labelLetterSpacing;
  final double? labelHeight;
  final double primaryBorderWidth;
  final double secondaryBorderWidth;
  final double? radius;
  final double highlightTopInset;
  final double highlightHeight;
  final double highlightHorizontalInset;
  final double iconChipRadius;

  KidButtonDensityTokens copyWith({
    double? height,
    double? horizontalPadding,
    double? iconGap,
    double? iconChipSize,
    double? iconSize,
    double? labelFontSize,
    FontWeight? labelFontWeight,
    bool clearLabelFontWeight = false,
    double? labelLetterSpacing,
    bool clearLabelLetterSpacing = false,
    double? labelHeight,
    bool clearLabelHeight = false,
    double? primaryBorderWidth,
    double? secondaryBorderWidth,
    double? radius,
    bool clearRadius = false,
    double? highlightTopInset,
    double? highlightHeight,
    double? highlightHorizontalInset,
    double? iconChipRadius,
  }) {
    assert(!clearRadius || radius == null);
    assert(!clearLabelFontWeight || labelFontWeight == null);
    assert(!clearLabelLetterSpacing || labelLetterSpacing == null);
    assert(!clearLabelHeight || labelHeight == null);

    return KidButtonDensityTokens(
      height: height ?? this.height,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      iconGap: iconGap ?? this.iconGap,
      iconChipSize: iconChipSize ?? this.iconChipSize,
      iconSize: iconSize ?? this.iconSize,
      labelFontSize: labelFontSize ?? this.labelFontSize,
      labelFontWeight: clearLabelFontWeight
          ? null
          : labelFontWeight ?? this.labelFontWeight,
      labelLetterSpacing: clearLabelLetterSpacing
          ? null
          : labelLetterSpacing ?? this.labelLetterSpacing,
      labelHeight: clearLabelHeight ? null : labelHeight ?? this.labelHeight,
      primaryBorderWidth: primaryBorderWidth ?? this.primaryBorderWidth,
      secondaryBorderWidth: secondaryBorderWidth ?? this.secondaryBorderWidth,
      radius: clearRadius ? null : radius ?? this.radius,
      highlightTopInset: highlightTopInset ?? this.highlightTopInset,
      highlightHeight: highlightHeight ?? this.highlightHeight,
      highlightHorizontalInset:
          highlightHorizontalInset ?? this.highlightHorizontalInset,
      iconChipRadius: iconChipRadius ?? this.iconChipRadius,
    );
  }

  KidButtonDensityTokens lerp(KidButtonDensityTokens other, double t) {
    return KidButtonDensityTokens(
      height: ui.lerpDouble(height, other.height, t) ?? height,
      horizontalPadding:
          ui.lerpDouble(horizontalPadding, other.horizontalPadding, t) ??
          horizontalPadding,
      iconGap: ui.lerpDouble(iconGap, other.iconGap, t) ?? iconGap,
      iconChipSize:
          ui.lerpDouble(iconChipSize, other.iconChipSize, t) ?? iconChipSize,
      iconSize: ui.lerpDouble(iconSize, other.iconSize, t) ?? iconSize,
      labelFontSize:
          ui.lerpDouble(labelFontSize, other.labelFontSize, t) ?? labelFontSize,
      labelFontWeight: labelFontWeight == null || other.labelFontWeight == null
          ? (t < 0.5 ? labelFontWeight : other.labelFontWeight)
          : FontWeight.lerp(labelFontWeight, other.labelFontWeight, t) ??
                (t < 0.5 ? labelFontWeight : other.labelFontWeight),
      labelLetterSpacing:
          labelLetterSpacing == null || other.labelLetterSpacing == null
          ? (t < 0.5 ? labelLetterSpacing : other.labelLetterSpacing)
          : ui.lerpDouble(labelLetterSpacing, other.labelLetterSpacing, t) ??
                (t < 0.5 ? labelLetterSpacing : other.labelLetterSpacing),
      labelHeight: labelHeight == null || other.labelHeight == null
          ? (t < 0.5 ? labelHeight : other.labelHeight)
          : ui.lerpDouble(labelHeight, other.labelHeight, t) ??
                (t < 0.5 ? labelHeight : other.labelHeight),
      primaryBorderWidth:
          ui.lerpDouble(primaryBorderWidth, other.primaryBorderWidth, t) ??
          primaryBorderWidth,
      secondaryBorderWidth:
          ui.lerpDouble(secondaryBorderWidth, other.secondaryBorderWidth, t) ??
          secondaryBorderWidth,
      radius: radius == null || other.radius == null
          ? (t < 0.5 ? radius : other.radius)
          : ui.lerpDouble(radius, other.radius, t) ??
                (t < 0.5 ? radius : other.radius),
      highlightTopInset:
          ui.lerpDouble(highlightTopInset, other.highlightTopInset, t) ??
          highlightTopInset,
      highlightHeight:
          ui.lerpDouble(highlightHeight, other.highlightHeight, t) ??
          highlightHeight,
      highlightHorizontalInset:
          ui.lerpDouble(
            highlightHorizontalInset,
            other.highlightHorizontalInset,
            t,
          ) ??
          highlightHorizontalInset,
      iconChipRadius:
          ui.lerpDouble(iconChipRadius, other.iconChipRadius, t) ??
          iconChipRadius,
    );
  }
}

@immutable
class KidButtonTokens {
  const KidButtonTokens({required this.regular, required this.compact});

  final KidButtonDensityTokens regular;
  final KidButtonDensityTokens compact;

  KidButtonDensityTokens forDensity(ToyButtonDensity density) {
    return switch (density) {
      ToyButtonDensity.regular => regular,
      ToyButtonDensity.compact => compact,
    };
  }

  KidButtonTokens copyWith({
    KidButtonDensityTokens? regular,
    KidButtonDensityTokens? compact,
  }) {
    return KidButtonTokens(
      regular: regular ?? this.regular,
      compact: compact ?? this.compact,
    );
  }

  KidButtonTokens lerp(KidButtonTokens other, double t) {
    return KidButtonTokens(
      regular: regular.lerp(other.regular, t),
      compact: compact.lerp(other.compact, t),
    );
  }
}

@immutable
class KidPanelDensityTokens {
  const KidPanelDensityTokens({
    required this.padding,
    required this.radius,
    required this.borderWidth,
    this.highlightTopInset = 0,
    required this.highlightHeight,
    required this.highlightHorizontalInset,
    required this.insetRadius,
  });

  final EdgeInsets padding;
  final double radius;
  final double borderWidth;
  final double highlightTopInset;
  final double highlightHeight;
  final double highlightHorizontalInset;
  final double insetRadius;

  KidPanelDensityTokens copyWith({
    EdgeInsets? padding,
    double? radius,
    double? borderWidth,
    double? highlightTopInset,
    double? highlightHeight,
    double? highlightHorizontalInset,
    double? insetRadius,
  }) {
    return KidPanelDensityTokens(
      padding: padding ?? this.padding,
      radius: radius ?? this.radius,
      borderWidth: borderWidth ?? this.borderWidth,
      highlightTopInset: highlightTopInset ?? this.highlightTopInset,
      highlightHeight: highlightHeight ?? this.highlightHeight,
      highlightHorizontalInset:
          highlightHorizontalInset ?? this.highlightHorizontalInset,
      insetRadius: insetRadius ?? this.insetRadius,
    );
  }

  KidPanelDensityTokens lerp(KidPanelDensityTokens other, double t) {
    return KidPanelDensityTokens(
      padding: EdgeInsets.lerp(padding, other.padding, t) ?? padding,
      radius: ui.lerpDouble(radius, other.radius, t) ?? radius,
      borderWidth:
          ui.lerpDouble(borderWidth, other.borderWidth, t) ?? borderWidth,
      highlightTopInset:
          ui.lerpDouble(highlightTopInset, other.highlightTopInset, t) ??
          highlightTopInset,
      highlightHeight:
          ui.lerpDouble(highlightHeight, other.highlightHeight, t) ??
          highlightHeight,
      highlightHorizontalInset:
          ui.lerpDouble(
            highlightHorizontalInset,
            other.highlightHorizontalInset,
            t,
          ) ??
          highlightHorizontalInset,
      insetRadius:
          ui.lerpDouble(insetRadius, other.insetRadius, t) ?? insetRadius,
    );
  }
}

@immutable
class KidPanelTokens {
  const KidPanelTokens({
    required this.regular,
    required this.compact,
    required this.tight,
  });

  final KidPanelDensityTokens regular;
  final KidPanelDensityTokens compact;
  final KidPanelDensityTokens tight;

  KidPanelDensityTokens forDensity(ToyPanelDensity density) {
    return switch (density) {
      ToyPanelDensity.regular => regular,
      ToyPanelDensity.compact => compact,
      ToyPanelDensity.tight => tight,
    };
  }

  KidPanelTokens copyWith({
    KidPanelDensityTokens? regular,
    KidPanelDensityTokens? compact,
    KidPanelDensityTokens? tight,
  }) {
    return KidPanelTokens(
      regular: regular ?? this.regular,
      compact: compact ?? this.compact,
      tight: tight ?? this.tight,
    );
  }

  KidPanelTokens lerp(KidPanelTokens other, double t) {
    return KidPanelTokens(
      regular: regular.lerp(other.regular, t),
      compact: compact.lerp(other.compact, t),
      tight: tight.lerp(other.tight, t),
    );
  }
}

@immutable
class KidButtonChromeTokens {
  const KidButtonChromeTokens({
    this.primaryBorderAlpha = 0.16,
    this.primaryIconChipAlpha = 0.18,
    this.primaryIconChipBorderAlpha = 0.12,
    this.primaryHighlightAlpha = 0.22,
    this.secondaryBorderAlpha = 0.82,
    this.secondaryIconChipAlpha = 0.88,
    this.secondaryIconChipBorderAlpha = 0.72,
    this.secondaryHighlightAlpha = 0.14,
    this.primaryDisabledGradientBlendAmount = 0.36,
    this.secondaryDisabledGradientBlendAmount = 0.16,
    this.disabledOpacity = 0.58,
  });

  final double primaryBorderAlpha;
  final double primaryIconChipAlpha;
  final double primaryIconChipBorderAlpha;
  final double primaryHighlightAlpha;
  final double secondaryBorderAlpha;
  final double secondaryIconChipAlpha;
  final double secondaryIconChipBorderAlpha;
  final double secondaryHighlightAlpha;
  final double primaryDisabledGradientBlendAmount;
  final double secondaryDisabledGradientBlendAmount;
  final double disabledOpacity;

  KidButtonChromeTokens copyWith({
    double? primaryBorderAlpha,
    double? primaryIconChipAlpha,
    double? primaryIconChipBorderAlpha,
    double? primaryHighlightAlpha,
    double? secondaryBorderAlpha,
    double? secondaryIconChipAlpha,
    double? secondaryIconChipBorderAlpha,
    double? secondaryHighlightAlpha,
    double? primaryDisabledGradientBlendAmount,
    double? secondaryDisabledGradientBlendAmount,
    double? disabledOpacity,
  }) {
    return KidButtonChromeTokens(
      primaryBorderAlpha: primaryBorderAlpha ?? this.primaryBorderAlpha,
      primaryIconChipAlpha: primaryIconChipAlpha ?? this.primaryIconChipAlpha,
      primaryIconChipBorderAlpha:
          primaryIconChipBorderAlpha ?? this.primaryIconChipBorderAlpha,
      primaryHighlightAlpha:
          primaryHighlightAlpha ?? this.primaryHighlightAlpha,
      secondaryBorderAlpha: secondaryBorderAlpha ?? this.secondaryBorderAlpha,
      secondaryIconChipAlpha:
          secondaryIconChipAlpha ?? this.secondaryIconChipAlpha,
      secondaryIconChipBorderAlpha:
          secondaryIconChipBorderAlpha ?? this.secondaryIconChipBorderAlpha,
      secondaryHighlightAlpha:
          secondaryHighlightAlpha ?? this.secondaryHighlightAlpha,
      primaryDisabledGradientBlendAmount:
          primaryDisabledGradientBlendAmount ??
          this.primaryDisabledGradientBlendAmount,
      secondaryDisabledGradientBlendAmount:
          secondaryDisabledGradientBlendAmount ??
          this.secondaryDisabledGradientBlendAmount,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
    );
  }

  KidButtonChromeTokens lerp(KidButtonChromeTokens other, double t) {
    return KidButtonChromeTokens(
      primaryBorderAlpha:
          ui.lerpDouble(primaryBorderAlpha, other.primaryBorderAlpha, t) ??
          primaryBorderAlpha,
      primaryIconChipAlpha:
          ui.lerpDouble(primaryIconChipAlpha, other.primaryIconChipAlpha, t) ??
          primaryIconChipAlpha,
      primaryIconChipBorderAlpha:
          ui.lerpDouble(
            primaryIconChipBorderAlpha,
            other.primaryIconChipBorderAlpha,
            t,
          ) ??
          primaryIconChipBorderAlpha,
      primaryHighlightAlpha:
          ui.lerpDouble(
            primaryHighlightAlpha,
            other.primaryHighlightAlpha,
            t,
          ) ??
          primaryHighlightAlpha,
      secondaryBorderAlpha:
          ui.lerpDouble(secondaryBorderAlpha, other.secondaryBorderAlpha, t) ??
          secondaryBorderAlpha,
      secondaryIconChipAlpha:
          ui.lerpDouble(
            secondaryIconChipAlpha,
            other.secondaryIconChipAlpha,
            t,
          ) ??
          secondaryIconChipAlpha,
      secondaryIconChipBorderAlpha:
          ui.lerpDouble(
            secondaryIconChipBorderAlpha,
            other.secondaryIconChipBorderAlpha,
            t,
          ) ??
          secondaryIconChipBorderAlpha,
      secondaryHighlightAlpha:
          ui.lerpDouble(
            secondaryHighlightAlpha,
            other.secondaryHighlightAlpha,
            t,
          ) ??
          secondaryHighlightAlpha,
      primaryDisabledGradientBlendAmount:
          ui.lerpDouble(
            primaryDisabledGradientBlendAmount,
            other.primaryDisabledGradientBlendAmount,
            t,
          ) ??
          primaryDisabledGradientBlendAmount,
      secondaryDisabledGradientBlendAmount:
          ui.lerpDouble(
            secondaryDisabledGradientBlendAmount,
            other.secondaryDisabledGradientBlendAmount,
            t,
          ) ??
          secondaryDisabledGradientBlendAmount,
      disabledOpacity:
          ui.lerpDouble(disabledOpacity, other.disabledOpacity, t) ??
          disabledOpacity,
    );
  }
}

@immutable
class KidPanelChromeTokens {
  const KidPanelChromeTokens({
    this.strokeBorderAlpha = 0.88,
    this.customBorderAlpha = 0.72,
    this.highlightAlpha = 0.28,
    this.airyBackgroundAlpha = 0.94,
    this.lilacBackgroundAlpha = 0.75,
    this.shellGradientWhiteBlendAmount = 0.34,
  });

  final double strokeBorderAlpha;
  final double customBorderAlpha;
  final double highlightAlpha;
  final double airyBackgroundAlpha;
  final double lilacBackgroundAlpha;
  final double shellGradientWhiteBlendAmount;

  KidPanelChromeTokens copyWith({
    double? strokeBorderAlpha,
    double? customBorderAlpha,
    double? highlightAlpha,
    double? airyBackgroundAlpha,
    double? lilacBackgroundAlpha,
    double? shellGradientWhiteBlendAmount,
  }) {
    return KidPanelChromeTokens(
      strokeBorderAlpha: strokeBorderAlpha ?? this.strokeBorderAlpha,
      customBorderAlpha: customBorderAlpha ?? this.customBorderAlpha,
      highlightAlpha: highlightAlpha ?? this.highlightAlpha,
      airyBackgroundAlpha: airyBackgroundAlpha ?? this.airyBackgroundAlpha,
      lilacBackgroundAlpha: lilacBackgroundAlpha ?? this.lilacBackgroundAlpha,
      shellGradientWhiteBlendAmount:
          shellGradientWhiteBlendAmount ?? this.shellGradientWhiteBlendAmount,
    );
  }

  KidPanelChromeTokens lerp(KidPanelChromeTokens other, double t) {
    return KidPanelChromeTokens(
      strokeBorderAlpha:
          ui.lerpDouble(strokeBorderAlpha, other.strokeBorderAlpha, t) ??
          strokeBorderAlpha,
      customBorderAlpha:
          ui.lerpDouble(customBorderAlpha, other.customBorderAlpha, t) ??
          customBorderAlpha,
      highlightAlpha:
          ui.lerpDouble(highlightAlpha, other.highlightAlpha, t) ??
          highlightAlpha,
      airyBackgroundAlpha:
          ui.lerpDouble(airyBackgroundAlpha, other.airyBackgroundAlpha, t) ??
          airyBackgroundAlpha,
      lilacBackgroundAlpha:
          ui.lerpDouble(lilacBackgroundAlpha, other.lilacBackgroundAlpha, t) ??
          lilacBackgroundAlpha,
      shellGradientWhiteBlendAmount:
          ui.lerpDouble(
            shellGradientWhiteBlendAmount,
            other.shellGradientWhiteBlendAmount,
            t,
          ) ??
          shellGradientWhiteBlendAmount,
    );
  }
}

@immutable
class KidShadowTokens {
  KidShadowTokens({
    List<BoxShadow> buttonPrimary = KidShadows.button,
    List<BoxShadow> buttonSecondary = KidShadows.buttonSoft,
    List<BoxShadow> panel = KidShadows.panel,
  }) : this._(
         buttonPrimary: List<BoxShadow>.unmodifiable(buttonPrimary),
         buttonSecondary: List<BoxShadow>.unmodifiable(buttonSecondary),
         panel: List<BoxShadow>.unmodifiable(panel),
       );

  const KidShadowTokens._({
    this.buttonPrimary = KidShadows.button,
    this.buttonSecondary = KidShadows.buttonSoft,
    this.panel = KidShadows.panel,
  });

  static const defaults = KidShadowTokens._();

  final List<BoxShadow> buttonPrimary;
  final List<BoxShadow> buttonSecondary;
  final List<BoxShadow> panel;

  KidShadowTokens copyWith({
    List<BoxShadow>? buttonPrimary,
    List<BoxShadow>? buttonSecondary,
    List<BoxShadow>? panel,
  }) {
    return KidShadowTokens(
      buttonPrimary: buttonPrimary ?? this.buttonPrimary,
      buttonSecondary: buttonSecondary ?? this.buttonSecondary,
      panel: panel ?? this.panel,
    );
  }

  KidShadowTokens lerp(KidShadowTokens other, double t) {
    return KidShadowTokens(
      buttonPrimary:
          BoxShadow.lerpList(buttonPrimary, other.buttonPrimary, t) ??
          (t < 0.5 ? buttonPrimary : other.buttonPrimary),
      buttonSecondary:
          BoxShadow.lerpList(buttonSecondary, other.buttonSecondary, t) ??
          (t < 0.5 ? buttonSecondary : other.buttonSecondary),
      panel:
          BoxShadow.lerpList(panel, other.panel, t) ??
          (t < 0.5 ? panel : other.panel),
    );
  }
}

@immutable
class KidChromeTokens {
  const KidChromeTokens({
    this.button = const KidButtonChromeTokens(),
    this.panel = const KidPanelChromeTokens(),
    this.shadows = KidShadowTokens.defaults,
  });

  static const defaults = KidChromeTokens();

  final KidButtonChromeTokens button;
  final KidPanelChromeTokens panel;
  final KidShadowTokens shadows;

  KidChromeTokens copyWith({
    KidButtonChromeTokens? button,
    KidPanelChromeTokens? panel,
    KidShadowTokens? shadows,
  }) {
    return KidChromeTokens(
      button: button ?? this.button,
      panel: panel ?? this.panel,
      shadows: shadows ?? this.shadows,
    );
  }

  KidChromeTokens lerp(KidChromeTokens other, double t) {
    return KidChromeTokens(
      button: button.lerp(other.button, t),
      panel: panel.lerp(other.panel, t),
      shadows: shadows.lerp(other.shadows, t),
    );
  }
}

@immutable
class KidLayoutTheme extends ThemeExtension<KidLayoutTheme> {
  const KidLayoutTheme({
    required this.button,
    required this.panel,
    this.chrome = KidChromeTokens.defaults,
  });

  static const defaults = KidLayoutTheme(
    button: KidButtonTokens(
      regular: KidButtonDensityTokens(
        height: 56,
        horizontalPadding: 16,
        iconGap: 10,
        iconChipSize: 34,
        iconSize: 18,
        labelFontSize: 18,
        labelFontWeight: FontWeight.w700,
        labelLetterSpacing: 0,
        labelHeight: 1.1,
        primaryBorderWidth: 1.2,
        secondaryBorderWidth: 1.1,
        radius: 24,
        highlightTopInset: 1,
        highlightHeight: 10,
        highlightHorizontalInset: 14,
        iconChipRadius: 13,
      ),
      compact: KidButtonDensityTokens(
        height: 48,
        horizontalPadding: 14,
        iconGap: 8,
        iconChipSize: 30,
        iconSize: 16,
        labelFontSize: 16,
        labelFontWeight: FontWeight.w700,
        labelLetterSpacing: 0,
        labelHeight: 1.1,
        primaryBorderWidth: 1.1,
        secondaryBorderWidth: 1.0,
        radius: 22,
        highlightTopInset: 1,
        highlightHeight: 8,
        highlightHorizontalInset: 12,
        iconChipRadius: 11,
      ),
    ),
    panel: KidPanelTokens(
      regular: KidPanelDensityTokens(
        padding: EdgeInsets.all(20),
        radius: 30,
        borderWidth: 1.4,
        highlightTopInset: 0,
        highlightHeight: 16,
        highlightHorizontalInset: 18,
        insetRadius: 22,
      ),
      compact: KidPanelDensityTokens(
        padding: EdgeInsets.all(12),
        radius: 28,
        borderWidth: 1.3,
        highlightTopInset: 0,
        highlightHeight: 14,
        highlightHorizontalInset: 16,
        insetRadius: 16,
      ),
      tight: KidPanelDensityTokens(
        padding: EdgeInsets.all(10),
        radius: 22,
        borderWidth: 1.2,
        highlightTopInset: 0,
        highlightHeight: 12,
        highlightHorizontalInset: 14,
        insetRadius: 14,
      ),
    ),
    chrome: KidChromeTokens.defaults,
  );

  final KidButtonTokens button;
  final KidPanelTokens panel;
  final KidChromeTokens chrome;

  @override
  KidLayoutTheme copyWith({
    KidButtonTokens? button,
    KidPanelTokens? panel,
    KidChromeTokens? chrome,
  }) {
    return KidLayoutTheme(
      button: button ?? this.button,
      panel: panel ?? this.panel,
      chrome: chrome ?? this.chrome,
    );
  }

  @override
  KidLayoutTheme lerp(ThemeExtension<KidLayoutTheme>? other, double t) {
    if (other is! KidLayoutTheme) {
      return this;
    }

    return KidLayoutTheme(
      button: button.lerp(other.button, t),
      panel: panel.lerp(other.panel, t),
      chrome: chrome.lerp(other.chrome, t),
    );
  }
}

extension KidThemeDataX on ThemeData {
  KidLayoutTheme get kidLayout =>
      extension<KidLayoutTheme>() ?? KidLayoutTheme.defaults;
}

ThemeData buildKidTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: KidPalette.blue,
      brightness: Brightness.light,
    ),
  );

  final colorScheme = base.colorScheme.copyWith(
    primary: KidPalette.blue,
    secondary: KidPalette.coral,
    surface: KidPalette.cream,
    onSurface: KidPalette.navy,
    outline: KidPalette.stroke,
    shadow: const Color(0x24182230),
  );

  final textTheme = base.textTheme.copyWith(
    displayLarge: const TextStyle(
      fontSize: 56,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.6,
      color: KidPalette.navy,
      height: 0.98,
    ),
    headlineLarge: const TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.0,
      color: KidPalette.navy,
      height: 1.02,
    ),
    headlineMedium: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
      color: KidPalette.navy,
      height: 1.08,
    ),
    headlineSmall: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: KidPalette.navy,
      height: 1.12,
    ),
    titleLarge: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: KidPalette.navy,
      height: 1.18,
    ),
    titleMedium: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.1,
      color: KidPalette.navy,
      height: 1.22,
    ),
    titleSmall: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: KidPalette.navy,
      height: 1.20,
    ),
    bodyLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: KidPalette.body,
      height: 1.38,
    ),
    bodyMedium: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: KidPalette.body,
      height: 1.36,
    ),
    bodySmall: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: KidPalette.body,
      height: 1.32,
    ),
    labelLarge: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.1,
      color: KidPalette.navy,
      height: 1.15,
    ),
    labelMedium: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.05,
      color: KidPalette.body,
      height: 1.18,
    ),
    labelSmall: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.05,
      color: KidPalette.body,
      height: 1.16,
    ),
  );

  return base.copyWith(
    colorScheme: colorScheme,
    extensions: const <ThemeExtension<dynamic>>[KidLayoutTheme.defaults],
    scaffoldBackgroundColor: KidPalette.skyTop,
    dividerColor: KidPalette.stroke,
    splashColor: KidPalette.white.withValues(alpha: 0.14),
    highlightColor: Colors.transparent,
    textTheme: textTheme,
    chipTheme: base.chipTheme.copyWith(
      shape: const StadiumBorder(),
      side: BorderSide.none,
      backgroundColor: KidPalette.white.withValues(alpha: 0.88),
      labelStyle: textTheme.labelLarge,
    ),
  );
}
