import 'package:flutter/material.dart';

export 'kid_theme.dart' show ToyButtonDensity;

import 'kid_theme.dart';
import 'tap_cooldown.dart';

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
    this.colors = const [KidPalette.blue, KidPalette.blueDark],
    this.cooldown = const Duration(milliseconds: 350),
  }) : assert(
         colors.length >= 2,
         'ToyButton.colors must include at least two colors.',
       );

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double? height;
  final ToyButtonDensity density;
  final ToyButtonTone tone;
  final List<Color> colors;
  final Duration cooldown;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final layout = Theme.of(context).kidLayout;
    final densityTokens = density.resolve(layout);
    final effectiveHeight = height ?? densityTokens.height;
    final borderRadius = BorderRadius.circular(effectiveHeight / 2);
    final primaryTone = tone == ToyButtonTone.primary;
    final baseColors = primaryTone
        ? colors
        : const [KidPalette.cream, KidPalette.creamWarm];
    final buttonColors = enabled
        ? baseColors
        : baseColors
              .map(
                (color) => Color.lerp(
                  color,
                  KidPalette.body,
                  primaryTone ? 0.36 : 0.16,
                )!,
              )
              .toList(growable: false);
    final foregroundColor = primaryTone ? KidPalette.white : KidPalette.navy;
    final borderColor = primaryTone
        ? KidPalette.white.withValues(alpha: 0.16)
        : KidPalette.stroke;
    final boxShadow = primaryTone ? KidShadows.button : KidShadows.buttonSoft;
    final chipColor = primaryTone
        ? KidPalette.white.withValues(alpha: 0.18)
        : KidPalette.white.withValues(alpha: 0.88);
    final chipBorderColor = primaryTone
        ? KidPalette.white.withValues(alpha: 0.12)
        : KidPalette.stroke;
    final chipSize = densityTokens.iconChipSize;
    final iconSize = densityTokens.iconSize;
    final borderWidth = primaryTone
        ? densityTokens.primaryBorderWidth
        : densityTokens.secondaryBorderWidth;
    final highlightInset = densityTokens.highlightInset;
    final highlightHeight = densityTokens.highlightHeight;
    final chipRadius = densityTokens.iconChipRadius;
    final labelStyle =
        (Theme.of(context).textTheme.titleLarge ??
                const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))
            .copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w800,
              fontSize: densityTokens.labelFontSize,
            );

    return Opacity(
      opacity: enabled ? 1 : 0.58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: buttonColors,
          ),
          borderRadius: borderRadius,
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: boxShadow,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 1,
              left: highlightInset,
              right: highlightInset,
              child: IgnorePointer(
                child: Container(
                  height: highlightHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        KidPalette.white.withValues(
                          alpha: primaryTone ? 0.22 : 0.14,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Container(
                            width: chipSize,
                            height: chipSize,
                            decoration: BoxDecoration(
                              color: chipColor,
                              borderRadius: BorderRadius.circular(chipRadius),
                              border: Border.all(color: chipBorderColor),
                            ),
                            child: Icon(
                              icon,
                              color: foregroundColor,
                              size: iconSize,
                            ),
                          ),
                          SizedBox(width: densityTokens.iconGap),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: labelStyle,
                          ),
                        ),
                      ],
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
