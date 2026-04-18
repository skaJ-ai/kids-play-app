import 'package:flutter/material.dart';

export 'kid_theme.dart' show ToyPanelDensity;

import 'kid_theme.dart';

enum ToyPanelTone { surface, airy, warm, lilac }

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
    final resolvedShadows = _panelShadowsFor(resolvedTone, shadowTokens);
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
              toneColors.shellGradientWhiteBlendAmount,
            )!,
            resolvedBackgroundColor,
          ],
        ),
        borderRadius: borderRadius,
        border: Border.all(color: resolvedBorder, width: resolvedBorderWidth),
        boxShadow: resolvedShadows,
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
                          alpha: toneColors.highlightAlpha,
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

List<BoxShadow> _panelShadowsFor(
  ToyPanelTone tone,
  KidShadowTokens shadowTokens,
) {
  return switch (tone) {
    ToyPanelTone.surface => shadowTokens.surfacePanel,
    ToyPanelTone.airy => shadowTokens.airyPanel,
    ToyPanelTone.warm => shadowTokens.warmPanel,
    ToyPanelTone.lilac => shadowTokens.lilacPanel,
  };
}

class _ToyPanelToneColors {
  const _ToyPanelToneColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.shellGradientWhiteBlendAmount,
    required this.highlightAlpha,
  });

  final Color backgroundColor;
  final Color borderColor;
  final double shellGradientWhiteBlendAmount;
  final double highlightAlpha;
}

_ToyPanelToneColors _toneColorsFor(
  ToyPanelTone tone,
  KidPanelChromeTokens chromeTokens,
) {
  return switch (tone) {
    ToyPanelTone.surface => _ToyPanelToneColors(
      backgroundColor: KidPalette.cream,
      borderColor: KidPalette.stroke,
      shellGradientWhiteBlendAmount:
          chromeTokens.surfaceShellGradientWhiteBlendAmount,
      highlightAlpha: chromeTokens.surfaceHighlightAlpha,
    ),
    ToyPanelTone.airy => _ToyPanelToneColors(
      backgroundColor: KidPalette.white.withValues(
        alpha: chromeTokens.airyBackgroundAlpha,
      ),
      borderColor: KidPalette.stroke,
      shellGradientWhiteBlendAmount:
          chromeTokens.airyShellGradientWhiteBlendAmount,
      highlightAlpha: chromeTokens.airyHighlightAlpha,
    ),
    ToyPanelTone.warm => _ToyPanelToneColors(
      backgroundColor: KidPalette.creamWarm,
      borderColor: KidPalette.stroke,
      shellGradientWhiteBlendAmount:
          chromeTokens.warmShellGradientWhiteBlendAmount,
      highlightAlpha: chromeTokens.warmHighlightAlpha,
    ),
    ToyPanelTone.lilac => _ToyPanelToneColors(
      backgroundColor: KidPalette.lilac.withValues(
        alpha: chromeTokens.lilacBackgroundAlpha,
      ),
      borderColor: KidPalette.stroke,
      shellGradientWhiteBlendAmount:
          chromeTokens.lilacShellGradientWhiteBlendAmount,
      highlightAlpha: chromeTokens.lilacHighlightAlpha,
    ),
  };
}
