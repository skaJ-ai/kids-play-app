import 'package:flutter/material.dart';

import 'kid_theme.dart';

class ToyPanel extends StatelessWidget {
  const ToyPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.backgroundColor = KidPalette.cream,
    this.borderColor = KidPalette.white,
    this.radius = 32,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: KidShadows.panel,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
