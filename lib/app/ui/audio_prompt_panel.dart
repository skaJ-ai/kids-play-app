import 'package:flutter/material.dart';

import 'kid_theme.dart';
import 'toy_button.dart';
import 'toy_panel.dart';

class AudioPromptPanel extends StatelessWidget {
  const AudioPromptPanel({
    super.key,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.onReplay,
    this.compact = false,
  });

  final String badge;
  final String title;
  final String subtitle;
  final VoidCallback onReplay;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).kidTypography;

    return ToyPanel(
      tone: ToyPanelTone.warm,
      density: compact ? ToyPanelDensity.compact : ToyPanelDensity.regular,
      child: Row(
        children: [
          ToyButton(
            label: '다시',
            icon: Icons.volume_up_rounded,
            density: ToyButtonDensity.tight,
            tone: ToyButtonTone.secondary,
            cooldown: Duration.zero,
            onPressed: onReplay,
          ),
          SizedBox(width: compact ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 8 : 10,
                    vertical: compact ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: KidPalette.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.bodyMedium.copyWith(
                      color: KidPalette.coralDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 6 : 8),
                Text(
                  title,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (compact ? typography.titleMedium : typography.titleLarge)
                          .copyWith(
                            color: KidPalette.navy,
                            fontWeight: FontWeight.w900,
                          ),
                ),
                SizedBox(height: compact ? 2 : 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.bodyMedium.copyWith(
                    color: KidPalette.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
