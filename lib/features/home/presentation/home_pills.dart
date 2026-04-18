import 'package:flutter/material.dart';

import '../../../app/ui/kid_theme.dart';

class HomeHeaderPill extends StatelessWidget {
  const HomeHeaderPill({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).kidTypography;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: KidPalette.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: KidPalette.stroke),
        boxShadow: KidShadows.panel,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 8 : 10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: compact ? 18 : 22),
            SizedBox(width: compact ? 6 : 8),
            Text(
              label,
              style: typography.titleSmall.copyWith(
                color: KidPalette.navy,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeAccentPill extends StatelessWidget {
  const HomeAccentPill({
    super.key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    this.compact = false,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).kidTypography;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: typography.labelLarge.copyWith(
          color: textColor,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
