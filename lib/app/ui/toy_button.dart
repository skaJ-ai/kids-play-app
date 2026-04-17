import 'package:flutter/material.dart';

import 'kid_theme.dart';
import 'tap_cooldown.dart';

enum ToyButtonTone { primary, secondary }

enum ToyButtonDensity { regular, compact }

extension on ToyButtonDensity {
  double get height => switch (this) {
    ToyButtonDensity.regular => 64,
    ToyButtonDensity.compact => 56,
  };
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
    final effectiveHeight = height ?? density.height;
    final compact = effectiveHeight <= ToyButtonDensity.compact.height;
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
    final chipSize = compact ? 32.0 : 36.0;
    final iconSize = compact ? 18.0 : 20.0;
    final labelStyle =
        (Theme.of(context).textTheme.titleLarge ??
                const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))
            .copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w800,
              fontSize: compact ? 20 : null,
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
          border: Border.all(
            color: borderColor,
            width: primaryTone ? 1.3 : 1.2,
          ),
          boxShadow: boxShadow,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 1,
              left: 16,
              right: 16,
              child: IgnorePointer(
                child: Container(
                  height: 12,
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
                      horizontal: compact ? 16 : 18,
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
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: chipBorderColor),
                            ),
                            child: Icon(
                              icon,
                              color: foregroundColor,
                              size: iconSize,
                            ),
                          ),
                          SizedBox(width: compact ? 10 : 12),
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
