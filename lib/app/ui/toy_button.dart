import 'package:flutter/material.dart';

import 'kid_theme.dart';
import 'tap_cooldown.dart';

class ToyButton extends StatelessWidget {
  const ToyButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.height = 76,
    this.colors = const [KidPalette.blue, KidPalette.blueDark],
    this.cooldown = const Duration(milliseconds: 350),
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;
  final List<Color> colors;
  final Duration cooldown;

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
          child: CooldownInkWell(
            borderRadius: BorderRadius.circular(28),
            cooldown: cooldown,
            onTap: onPressed,
            child: SizedBox(
              height: height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: KidPalette.white, size: 28),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: KidPalette.white,
                          fontWeight: FontWeight.w900,
                        ),
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
