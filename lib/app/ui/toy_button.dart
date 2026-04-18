import 'package:flutter/material.dart';

import 'kid_theme.dart';
import 'tap_cooldown.dart';

export 'kid_theme.dart' show ToyButtonDensity;

enum ToyButtonTone { primary, secondary }

extension on ToyButtonDensity {
  KidButtonDensityTokens resolve(KidLayoutTheme layout) {
    return layout.button.forDensity(this);
  }
}

class ToyButton extends StatelessWidget {
  const ToyButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.height,
    this.density = ToyButtonDensity.regular,
    this.tone = ToyButtonTone.primary,
    this.colors,
    this.cooldown = const Duration(milliseconds: 350),
  }) : assert(
         colors == null || colors.length >= 2,
         'ToyButton.colors must include at least two colors.',
       );

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double? height;
  final ToyButtonDensity density;
  final ToyButtonTone tone;
  final List<Color>? colors;
  final Duration cooldown;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final layout = Theme.of(context).kidLayout;
    final densityTokens = density.resolve(layout);
    final chromeTokens = layout.chrome.button;
    final shadowTokens = layout.chrome.shadows;
    final effectiveHeight = height ?? densityTokens.height;
    final borderRadius = BorderRadius.circular(
      densityTokens.radius ?? (effectiveHeight / 2),
    );
    final primaryTone = tone == ToyButtonTone.primary;
    final baseColors = primaryTone
        ? (colors ??
              [
                chromeTokens.primaryShellGradientStart,
                chromeTokens.primaryShellGradientEnd,
              ])
        : [
            chromeTokens.secondaryShellGradientStart,
            chromeTokens.secondaryShellGradientEnd,
          ];
    final buttonColors = enabled
        ? baseColors
        : baseColors
              .map(
                (color) => Color.lerp(
                  color,
                  primaryTone
                      ? chromeTokens.primaryDisabledGradientBlendTargetColor
                      : chromeTokens.secondaryDisabledGradientBlendTargetColor,
                  primaryTone
                      ? chromeTokens.primaryDisabledGradientBlendAmount
                      : chromeTokens.secondaryDisabledGradientBlendAmount,
                )!,
              )
              .toList(growable: false);
    final foregroundColor = primaryTone
        ? chromeTokens.primaryForegroundColor
        : chromeTokens.secondaryForegroundColor;
    final borderColor = primaryTone
        ? chromeTokens.primaryBorderColor.withValues(
            alpha: chromeTokens.primaryBorderAlpha,
          )
        : chromeTokens.secondaryBorderColor.withValues(
            alpha: chromeTokens.secondaryBorderAlpha,
          );
    final boxShadow = primaryTone
        ? shadowTokens.buttonPrimary
        : shadowTokens.buttonSecondary;
    final chipColor = primaryTone
        ? chromeTokens.primaryIconChipColor.withValues(
            alpha: chromeTokens.primaryIconChipAlpha,
          )
        : chromeTokens.secondaryIconChipColor.withValues(
            alpha: chromeTokens.secondaryIconChipAlpha,
          );
    final chipBorderColor = primaryTone
        ? chromeTokens.primaryIconChipBorderColor.withValues(
            alpha: chromeTokens.primaryIconChipBorderAlpha,
          )
        : chromeTokens.secondaryIconChipBorderColor.withValues(
            alpha: chromeTokens.secondaryIconChipBorderAlpha,
          );
    final chipSize = densityTokens.iconChipSize;
    final iconSize = densityTokens.iconSize;
    final baseLabelStyle = switch (density) {
      ToyButtonDensity.regular => Theme.of(context).kidTypography.titleLarge,
      ToyButtonDensity.compact ||
      ToyButtonDensity.tight => Theme.of(context).kidTypography.titleMedium,
    };
    final labelStyle = baseLabelStyle.copyWith(
      color: foregroundColor,
      fontSize: densityTokens.labelFontSize,
      fontWeight: densityTokens.labelFontWeight ?? baseLabelStyle.fontWeight,
      letterSpacing:
          densityTokens.labelLetterSpacing ?? baseLabelStyle.letterSpacing,
      height: densityTokens.labelHeight ?? baseLabelStyle.height,
    );
    final iconFootprint = icon == null ? 0.0 : chipSize + densityTokens.iconGap;

    return Opacity(
      opacity: enabled ? 1 : chromeTokens.disabledOpacity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: buttonColors,
          ),
          borderRadius: borderRadius,
          border: Border.all(
            color: borderColor,
            width: primaryTone
                ? densityTokens.primaryBorderWidth
                : densityTokens.secondaryBorderWidth,
          ),
          boxShadow: boxShadow,
        ),
        child: Stack(
          children: [
            Positioned(
              top: densityTokens.highlightTopInset,
              left: densityTokens.highlightHorizontalInset,
              right: densityTokens.highlightHorizontalInset,
              child: IgnorePointer(
                child: Container(
                  height: densityTokens.highlightHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      densityTokens.highlightRadius,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        KidPalette.white.withValues(
                          alpha: primaryTone
                              ? chromeTokens.primaryHighlightAlpha
                              : chromeTokens.secondaryHighlightAlpha,
                        ),
                        KidPalette.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: CooldownInkWell(
                borderRadius: borderRadius,
                cooldown: cooldown,
                onTap: onPressed,
                child: SizedBox(
                  height: effectiveHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: densityTokens.horizontalPadding,
                    ),
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            final trailingLabelReservation =
                                _resolveTrailingLabelReservation(
                                  context: context,
                                  constraints: constraints,
                                  iconFootprint: iconFootprint,
                                  label: label,
                                  labelStyle: labelStyle,
                                );

                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                if (icon != null)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: chipSize,
                                          height: chipSize,
                                          decoration: BoxDecoration(
                                            color: chipColor,
                                            borderRadius: BorderRadius.circular(
                                              densityTokens.iconChipRadius,
                                            ),
                                            border: Border.all(
                                              color: chipBorderColor,
                                              width: densityTokens
                                                  .iconChipBorderWidth,
                                            ),
                                          ),
                                          child: Icon(
                                            icon,
                                            color: foregroundColor,
                                            size: iconSize,
                                          ),
                                        ),
                                        SizedBox(width: densityTokens.iconGap),
                                      ],
                                    ),
                                  ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: iconFootprint,
                                    right: trailingLabelReservation,
                                  ),
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: labelStyle,
                                  ),
                                ),
                              ],
                            );
                          },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double _resolveTrailingLabelReservation({
  required BuildContext context,
  required BoxConstraints constraints,
  required double iconFootprint,
  required String label,
  required TextStyle labelStyle,
}) {
  if (iconFootprint == 0 || !constraints.hasBoundedWidth) {
    return iconFootprint;
  }

  final symmetricLabelWidth = (constraints.maxWidth - (iconFootprint * 2))
      .clamp(0.0, double.infinity)
      .toDouble();
  final fullLabelWidth = _measureSingleLineLabelWidth(
    context: context,
    label: label,
    labelStyle: labelStyle,
  );

  if (fullLabelWidth <= symmetricLabelWidth) {
    return iconFootprint;
  }

  return (constraints.maxWidth - iconFootprint - fullLabelWidth)
      .clamp(0.0, iconFootprint)
      .toDouble();
}

double _measureSingleLineLabelWidth({
  required BuildContext context,
  required String label,
  required TextStyle labelStyle,
}) {
  final textPainter = TextPainter(
    text: TextSpan(text: label, style: labelStyle),
    maxLines: 1,
    textDirection: Directionality.of(context),
    locale: Localizations.maybeLocaleOf(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout(maxWidth: double.infinity);

  return textPainter.width;
}
