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
    final densityTokens = Theme.of(context).kidLayout.panel.forDensity(density);
    final resolvedPadding = padding ?? densityTokens.padding;
    final resolvedRadius = radius ?? densityTokens.radius;
    final resolvedBorderWidth = densityTokens.borderWidth;
    final highlightHeight = densityTokens.highlightHeight;
    final highlightHorizontalInset = densityTokens.highlightHorizontalInset;
    final resolvedTone = tone ?? ToyPanelTone.surface;
    final toneColors = _toneColorsFor(resolvedTone);
    final resolvedBackgroundColor =
        backgroundColor ?? toneColors.backgroundColor;
    final resolvedBorderColor = borderColor ?? toneColors.borderColor;
    final resolvedBorder = resolvedBorderColor.withValues(
      alpha: resolvedBorderColor == KidPalette.stroke ? 0.88 : 0.72,
    );

    final borderRadius = BorderRadius.circular(resolvedRadius);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(resolvedBackgroundColor, KidPalette.white, 0.34)!,
            resolvedBackgroundColor,
          ],
        ),
        borderRadius: borderRadius,
        border: Border.all(color: resolvedBorder, width: resolvedBorderWidth),
        boxShadow: KidShadows.panel,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: highlightHorizontalInset,
              right: highlightHorizontalInset,
              child: IgnorePointer(
                child: Container(
                  height: highlightHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        KidPalette.white.withValues(alpha: 0.28),
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

_ToyPanelToneColors _toneColorsFor(ToyPanelTone tone) {
  return switch (tone) {
    ToyPanelTone.surface => const _ToyPanelToneColors(
      backgroundColor: KidPalette.cream,
      borderColor: KidPalette.stroke,
    ),
    ToyPanelTone.airy => _ToyPanelToneColors(
      backgroundColor: KidPalette.white.withValues(alpha: 0.94),
      borderColor: KidPalette.stroke,
    ),
    ToyPanelTone.warm => const _ToyPanelToneColors(
      backgroundColor: KidPalette.creamWarm,
      borderColor: KidPalette.stroke,
    ),
  };
}
