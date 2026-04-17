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
  static List<BoxShadow> get panel => const [
    BoxShadow(color: Color(0x17182230), blurRadius: 28, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x0D182230), blurRadius: 10, offset: Offset(0, 4)),
  ];

  static List<BoxShadow> get button => const [
    BoxShadow(color: Color(0x241B4FA7), blurRadius: 24, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x14182230), blurRadius: 10, offset: Offset(0, 4)),
  ];

  static List<BoxShadow> get buttonSoft => const [
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
    this.primaryBorderWidth = 1.3,
    this.secondaryBorderWidth = 1.2,
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
  final double primaryBorderWidth;
  final double secondaryBorderWidth;
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
    double? primaryBorderWidth,
    double? secondaryBorderWidth,
    double? highlightHeight,
    double? highlightHorizontalInset,
    double? iconChipRadius,
  }) {
    return KidButtonDensityTokens(
      height: height ?? this.height,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      iconGap: iconGap ?? this.iconGap,
      iconChipSize: iconChipSize ?? this.iconChipSize,
      iconSize: iconSize ?? this.iconSize,
      labelFontSize: labelFontSize ?? this.labelFontSize,
      primaryBorderWidth: primaryBorderWidth ?? this.primaryBorderWidth,
      secondaryBorderWidth: secondaryBorderWidth ?? this.secondaryBorderWidth,
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
      primaryBorderWidth:
          ui.lerpDouble(primaryBorderWidth, other.primaryBorderWidth, t) ??
          primaryBorderWidth,
      secondaryBorderWidth:
          ui.lerpDouble(secondaryBorderWidth, other.secondaryBorderWidth, t) ??
          secondaryBorderWidth,
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
    required this.highlightHeight,
    required this.highlightHorizontalInset,
    required this.insetRadius,
  });

  final EdgeInsets padding;
  final double radius;
  final double borderWidth;
  final double highlightHeight;
  final double highlightHorizontalInset;
  final double insetRadius;

  KidPanelDensityTokens copyWith({
    EdgeInsets? padding,
    double? radius,
    double? borderWidth,
    double? highlightHeight,
    double? highlightHorizontalInset,
    double? insetRadius,
  }) {
    return KidPanelDensityTokens(
      padding: padding ?? this.padding,
      radius: radius ?? this.radius,
      borderWidth: borderWidth ?? this.borderWidth,
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
class KidLayoutTheme extends ThemeExtension<KidLayoutTheme> {
  const KidLayoutTheme({required this.button, required this.panel});

  static const defaults = KidLayoutTheme(
    button: KidButtonTokens(
      regular: KidButtonDensityTokens(
        height: 64,
        horizontalPadding: 18,
        iconGap: 12,
        iconChipSize: 36,
        iconSize: 20,
        labelFontSize: 22,
        primaryBorderWidth: 1.3,
        secondaryBorderWidth: 1.2,
        highlightHeight: 12,
        highlightHorizontalInset: 16,
        iconChipRadius: 14,
      ),
      compact: KidButtonDensityTokens(
        height: 56,
        horizontalPadding: 16,
        iconGap: 10,
        iconChipSize: 32,
        iconSize: 18,
        labelFontSize: 20,
        primaryBorderWidth: 1.2,
        secondaryBorderWidth: 1.1,
        highlightHeight: 10,
        highlightHorizontalInset: 14,
        iconChipRadius: 12,
      ),
    ),
    panel: KidPanelTokens(
      regular: KidPanelDensityTokens(
        padding: EdgeInsets.all(24),
        radius: 32,
        borderWidth: 1.5,
        highlightHeight: 18,
        highlightHorizontalInset: 20,
        insetRadius: 24,
      ),
      compact: KidPanelDensityTokens(
        padding: EdgeInsets.all(14),
        radius: 32,
        borderWidth: 1.4,
        highlightHeight: 16,
        highlightHorizontalInset: 18,
        insetRadius: 18,
      ),
      tight: KidPanelDensityTokens(
        padding: EdgeInsets.all(12),
        radius: 24,
        borderWidth: 1.3,
        highlightHeight: 14,
        highlightHorizontalInset: 16,
        insetRadius: 16,
      ),
    ),
  );

  final KidButtonTokens button;
  final KidPanelTokens panel;

  @override
  KidLayoutTheme copyWith({KidButtonTokens? button, KidPanelTokens? panel}) {
    return KidLayoutTheme(
      button: button ?? this.button,
      panel: panel ?? this.panel,
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
      fontSize: 60,
      fontWeight: FontWeight.w900,
      letterSpacing: -2.2,
      color: KidPalette.navy,
      height: 0.92,
    ),
    headlineLarge: const TextStyle(
      fontSize: 44,
      fontWeight: FontWeight.w900,
      letterSpacing: -1.5,
      color: KidPalette.navy,
      height: 1.0,
    ),
    headlineMedium: const TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w900,
      letterSpacing: -1.0,
      color: KidPalette.navy,
      height: 1.04,
    ),
    headlineSmall: const TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.7,
      color: KidPalette.navy,
      height: 1.08,
    ),
    titleLarge: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: KidPalette.navy,
      height: 1.12,
    ),
    titleMedium: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: KidPalette.body,
      height: 1.24,
    ),
    titleSmall: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.1,
      color: KidPalette.body,
      height: 1.2,
    ),
    bodyLarge: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: KidPalette.body,
      height: 1.35,
    ),
    bodyMedium: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: KidPalette.body,
      height: 1.35,
    ),
    bodySmall: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: KidPalette.body,
      height: 1.3,
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
      letterSpacing: 0,
      color: KidPalette.body,
      height: 1.2,
    ),
    labelSmall: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: KidPalette.body,
      height: 1.18,
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
