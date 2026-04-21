import 'package:flutter/material.dart';

import 'kid_theme.dart';

class AnswerFeedbackOverlay extends StatelessWidget {
  const AnswerFeedbackOverlay({
    super.key,
    required this.visible,
    required this.correct,
    required this.compact,
  });

  final bool visible;
  final bool correct;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color background = correct ? KidPalette.mint : KidPalette.yellow;
    final Color foreground =
        correct ? KidPalette.mintDark : KidPalette.yellowDark;
    final IconData icon = correct
        ? Icons.emoji_events_rounded
        : Icons.sentiment_satisfied_rounded;
    final String copy = correct ? '딩동댕!' : '어? 다시 해볼까?';

    // Asymmetry inverted: correct gets bolder chrome, wrong stays light/soft.
    final double horizontalPad = correct
        ? (compact ? 18 : 24)
        : (compact ? 12 : 16);
    final double verticalPad = correct
        ? (compact ? 10 : 14)
        : (compact ? 7 : 9);
    final double iconSize = correct
        ? (compact ? 24 : 30)
        : (compact ? 20 : 24);
    final double alpha = correct ? 0.94 : 0.72;

    return IgnorePointer(
      ignoring: true,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0, 0.4),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: Padding(
              padding: EdgeInsets.only(bottom: compact ? 10 : 18),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPad,
                  vertical: verticalPad,
                ),
                decoration: BoxDecoration(
                  color: background.withValues(alpha: alpha),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow:
                      correct ? KidShadows.button : KidShadows.buttonSoft,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: foreground, size: iconSize),
                    SizedBox(width: compact ? 6 : 8),
                    Text(
                      copy,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: foreground,
                            fontWeight:
                                correct ? FontWeight.w900 : FontWeight.w700,
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
