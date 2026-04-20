import 'package:flutter/material.dart';

import 'kid_theme.dart';
import 'tap_cooldown.dart';

class PlayChoiceCard extends StatelessWidget {
  const PlayChoiceCard({
    super.key,
    required this.symbol,
    required this.onTap,
    required this.accentIndex,
    required this.compact,
    required this.disabled,
  });

  final String symbol;
  final VoidCallback onTap;
  final int accentIndex;
  final bool compact;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typography = theme.kidTypography;
    final textTheme = theme.textTheme;
    final palette = _paletteFor(accentIndex);

    return Opacity(
      opacity: disabled ? 0.88 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: palette),
          borderRadius: BorderRadius.circular(compact ? 26 : 32),
          boxShadow: KidShadows.button,
        ),
        child: Material(
          color: Colors.transparent,
          child: CooldownInkWell(
            borderRadius: BorderRadius.circular(compact ? 26 : 32),
            onTap: disabled ? null : onTap,
            child: Stack(
              children: [
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
                    width: compact ? 30 : 38,
                    height: compact ? 30 : 38,
                    decoration: BoxDecoration(
                      color: KidPalette.white.withValues(alpha: 0.24),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 16,
                  child: Text(
                    '콕!',
                    style: typography.labelLarge.copyWith(
                      fontSize: typography.titleSmall.fontSize,
                      color: KidPalette.white.withValues(alpha: 0.92),
                    ),
                  ),
                ),
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      symbol,
                      style:
                          textTheme.displayLarge?.copyWith(
                            fontSize: compact ? 66 : 92,
                            height: 1,
                            color: KidPalette.white,
                          ) ??
                          TextStyle(
                            fontSize: compact ? 66 : 92,
                            height: 1,
                            color: KidPalette.white,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _paletteFor(int index) {
    switch (index % 4) {
      case 0:
        return const [KidPalette.blue, KidPalette.blueDark];
      case 1:
        return const [KidPalette.coral, KidPalette.coralDark];
      case 2:
        return const [KidPalette.mint, KidPalette.mintDark];
      default:
        return const [KidPalette.lilac, Color(0xFFA28CF5)];
    }
  }
}
