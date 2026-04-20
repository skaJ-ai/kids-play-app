import 'package:flutter/material.dart';

import 'audio_prompt_panel.dart';
import 'kid_theme.dart';
import 'toy_panel.dart';

class PlayPromptPanel extends StatelessWidget {
  const PlayPromptPanel({
    super.key,
    required this.prompt,
    required this.displayName,
    required this.symbol,
    required this.targetLabel,
    required this.onReplay,
    this.compact = false,
    this.tight = false,
    this.promptPanelKey,
    this.targetPanelKey,
  });

  final String prompt;
  final String displayName;
  final String symbol;
  final String targetLabel;
  final VoidCallback onReplay;
  final bool compact;
  final bool tight;
  final Key? promptPanelKey;
  final Key? targetPanelKey;

  @override
  Widget build(BuildContext context) {
    if (tight) {
      return ToyPanel(
        key: promptPanelKey,
        tone: ToyPanelTone.warm,
        padding: const EdgeInsets.all(12),
        backgroundColor: KidPalette.creamWarm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    prompt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: KidPalette.navy,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: onReplay,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: KidPalette.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: KidShadows.button,
                      ),
                      child: const Icon(
                        Icons.volume_up_rounded,
                        color: KidPalette.coralDark,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: KidPalette.coralDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    symbol,
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: KidPalette.navy,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AudioPromptPanel(
          panelKey: promptPanelKey,
          badge: '문제 듣기',
          title: prompt,
          subtitle: compact ? '스피커를 눌러 다시 들어봐요.' : '스피커를 누르면 문제를 다시 들을 수 있어요.',
          onReplay: onReplay,
          compact: compact,
        ),
        SizedBox(height: compact ? 10 : 14),
        Expanded(
          child: ToyPanel(
            key: targetPanelKey,
            tone: ToyPanelTone.airy,
            density: ToyPanelDensity.compact,
            padding: EdgeInsets.all(compact ? 14 : 24),
            backgroundColor: KidPalette.white.withValues(alpha: 0.94),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 12 : 14,
                    vertical: compact ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: KidPalette.creamWarm,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    targetLabel,
                    style: Theme.of(context).kidTypography.labelLarge.copyWith(
                      color: KidPalette.coralDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 8 : 12),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (compact
                              ? Theme.of(context).textTheme.titleSmall
                              : Theme.of(context).textTheme.titleMedium)
                          ?.copyWith(
                            color: KidPalette.coralDark,
                            fontWeight: FontWeight.w900,
                          ),
                ),
                SizedBox(height: compact ? 6 : 10),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        symbol,
                        style: TextStyle(
                          fontSize: compact ? 86 : 118,
                          fontWeight: FontWeight.w900,
                          color: KidPalette.navy,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
