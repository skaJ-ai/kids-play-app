import 'package:flutter/material.dart';

import 'kid_theme.dart';

class ToyPanel extends StatelessWidget {
  const ToyPanel({
    super.key,
    required this.child,
    this.density = ToyPanelDensity.regular,
    this.padding,
    this.backgroundColor = KidPalette.cream,
    this.borderColor = KidPalette.stroke,
    this.radius,
  });

  final Widget child;
  final ToyPanelDensity density;
  final EdgeInsetsGeometry? padding;
  final Color backgroundColor;
  final Color borderColor;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final densityTokens = KidPanelTokens.forDensity(density);
    final resolvedPadding = padding ?? densityTokens.padding;
    final resolvedRadius = radius ?? densityTokens.radius;
    final resolvedBorder = borderColor.withValues(
      alpha: borderColor == KidPalette.stroke ? 0.88 : 0.72,
    );

    final borderRadius = BorderRadius.circular(resolvedRadius);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(backgroundColor, KidPalette.white, 0.34)!,
            backgroundColor,
          ],
        ),
        borderRadius: borderRadius,
        border: Border.all(color: resolvedBorder, width: 1.5),
        boxShadow: KidShadows.panel,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 20,
              right: 20,
              child: IgnorePointer(
                child: Container(
                  height: 18,
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
