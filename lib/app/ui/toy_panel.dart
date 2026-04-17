import 'package:flutter/material.dart';

export 'kid_theme.dart' show ToyPanelDensity;

import 'kid_theme.dart';

enum ToyPanelTone { surface, airy, warm }

class ToyPanel extends StatelessWidget {
  const ToyPanel({
    super.key,
    required this.child,
    this.density = ToyPanelDensity.regular,
    this.tone,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.radius,
  });

  final Widget child;
  final ToyPanelDensity density;
  final ToyPanelTone? tone;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final layout = Theme.of(context).kidLayout;
    final densityTokens = layout.panel.forDensity(density);
    final chromeTokens = layout.chrome.panel;
    final shadowTokens = layout.chrome.shadows;
    final resolvedPadding = padding ?? densityTokens.padding;
    final resolvedRadius = radius ?? densityTokens.radius;
    final resolvedBorderWidth = densityTokens.borderWidth;
    final highlightTopInset = densityTokens.highlightTopInset;
    final highlightHeight = densityTokens.highlightHeight;
    final highlightHorizontalInset = densityTokens.highlightHorizontalInset;
    final resolvedTone = tone ?? ToyPanelTone.surface;
    final toneColors = _toneColorsFor(resolvedTone, chromeTokens);
    final resolvedBackgroundColor =
        backgroundColor ?? toneColors.backgroundColor;
    final resolvedBorderColor = borderColor ?? toneColors.borderColor;
    final resolvedBorder = resolvedBorderColor.withValues(
      alpha: resolvedBorderColor == KidPalette.stroke
          ? chromeTokens.strokeBorderAlpha
          : chromeTokens.customBorderAlpha,
    );

    final borderRadius = BorderRadius.circular(resolvedRadius);
    final highlightBorderRadius = BorderRadius.circular(
      densityTokens.insetRadius,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(
              resolvedBackgroundColor,
              KidPalette.white,
              chromeTokens.shellGradientWhiteBlendAmount,
            )!,
            resolvedBackgroundColor,
          ],
        ),
        borderRadius: borderRadius,
        border: Border.all(color: resolvedBorder, width: resolvedBorderWidth),
        boxShadow: shadowTokens.panel,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Positioned(
              top: highlightTopInset,
              left: highlightHorizontalInset,
              right: highlightHorizontalInset,
              child: IgnorePointer(
                child: Container(
                  height: highlightHeight,
                  decoration: BoxDecoration(
                    borderRadius: highlightBorderRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        KidPalette.white.withValues(
                          alpha: chromeTokens.highlightAlpha,
                        ),
                        KidPalette.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: resolvedPadding, child: child),
          ],
        ),
      ),
    );
  }
}

class _ToyPanelToneColors {
  const _ToyPanelToneColors({
    required this.backgroundColor,
    required this.borderColor,
  });

  final Color backgroundColor;
  final Color borderColor;
}

_ToyPanelToneColors _toneColorsFor(
  ToyPanelTone tone,
  KidPanelChromeTokens chromeTokens,
) {
  return switch (tone) {
    ToyPanelTone.surface => const _ToyPanelToneColors(
      backgroundColor: KidPalette.cream,
      borderColor: KidPalette.stroke,
    ),
    ToyPanelTone.airy => _ToyPanelToneColors(
      backgroundColor: KidPalette.white.withValues(
        alpha: chromeTokens.airyBackgroundAlpha,
      ),
      borderColor: KidPalette.stroke,
    ),
    ToyPanelTone.warm => const _ToyPanelToneColors(
      backgroundColor: KidPalette.creamWarm,
      borderColor: KidPalette.stroke,
    ),
  };
}
