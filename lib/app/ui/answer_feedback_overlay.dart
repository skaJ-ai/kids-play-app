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
    return IgnorePointer(
      ignoring: true,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: AnimatedScale(
          scale: visible ? 1 : 0.92,
          duration: const Duration(milliseconds: 180),
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 20 : 28,
                vertical: compact ? 18 : 24,
              ),
              decoration: BoxDecoration(
                color: (correct ? KidPalette.mint : KidPalette.coral).withValues(
                  alpha: 0.95,
                ),
                borderRadius: BorderRadius.circular(compact ? 24 : 32),
                boxShadow: KidShadows.button,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    correct ? Icons.check_circle_rounded : Icons.close_rounded,
                    color: KidPalette.white,
                    size: compact ? 42 : 54,
                  ),
                  SizedBox(width: compact ? 10 : 14),
                  Text(
                    correct ? '딩동댕!' : '다시 해보자!',
                    style: (compact
                            ? Theme.of(context).textTheme.titleLarge
                            : Theme.of(context).textTheme.headlineSmall)
                        ?.copyWith(
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
    );
  }
}
