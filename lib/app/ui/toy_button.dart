import 'package:flutter/material.dart';

import 'kid_theme.dart';

class ToyButton extends StatelessWidget {
  const ToyButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.height = 76,
    this.colors = const [KidPalette.blue, KidPalette.blueDark],
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(28),
          boxShadow: KidShadows.button,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onPressed,
            child: SizedBox(
              height: height,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: KidPalette.white, size: 30),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      label,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: KidPalette.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
