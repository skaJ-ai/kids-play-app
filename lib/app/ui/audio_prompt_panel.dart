import 'package:flutter/material.dart';

import 'kid_theme.dart';
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
    return ToyPanel(
      padding: EdgeInsets.all(compact ? 12 : 16),
      backgroundColor: KidPalette.creamWarm,
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(compact ? 18 : 24),
              onTap: onReplay,
              child: Container(
                width: compact ? 60 : 78,
                height: compact ? 60 : 78,
                decoration: BoxDecoration(
                  color: KidPalette.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(compact ? 18 : 24),
                  boxShadow: KidShadows.button,
                ),
                child: Icon(
                  Icons.volume_up_rounded,
                  color: KidPalette.coralDark,
                  size: compact ? 30 : 36,
                ),
              ),
            ),
          ),
          SizedBox(width: compact ? 10 : 14),
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                  style: (compact
                          ? Theme.of(context).textTheme.titleMedium
                          : Theme.of(context).textTheme.titleLarge)
                      ?.copyWith(
                        color: KidPalette.navy,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                SizedBox(height: compact ? 2 : 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
