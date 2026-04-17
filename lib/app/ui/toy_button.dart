import 'package:flutter/material.dart';

import 'kid_theme.dart';
import 'tap_cooldown.dart';

class ToyButton extends StatelessWidget {
  const ToyButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.height = 72,
    this.colors = const [KidPalette.blue, KidPalette.blueDark],
    this.cooldown = const Duration(milliseconds: 350),
  }) : assert(
         colors.length >= 2,
         'ToyButton.colors must include at least two colors.',
       );

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;
  final List<Color> colors;
  final Duration cooldown;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final borderRadius = BorderRadius.circular(30);
    final buttonColors = enabled
        ? colors
        : colors
              .map((color) => Color.lerp(color, KidPalette.body, 0.36)!)
              .toList(growable: false);

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
            color: KidPalette.white.withValues(alpha: 0.18),
            width: 1.4,
          ),
          boxShadow: KidShadows.button,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 1,
              left: 18,
              right: 18,
              child: IgnorePointer(
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        KidPalette.white.withValues(alpha: 0.24),
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
                  height: height,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: KidPalette.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: KidPalette.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: KidPalette.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style:
                                (Theme.of(context).textTheme.titleLarge ??
                                        const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                        ))
                                    .copyWith(
                                      color: KidPalette.white,
                                      fontWeight: FontWeight.w800,
                                    ),
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
