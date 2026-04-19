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
                  horizontal: compact ? 14 : 18,
                  vertical: compact ? 8 : 10,
                ),
                decoration: BoxDecoration(
                  color: (correct ? KidPalette.mint : KidPalette.coral)
                      .withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: KidShadows.buttonSoft,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      correct
                          ? Icons.check_circle_rounded
                          : Icons.close_rounded,
                      color: KidPalette.white,
                      size: compact ? 22 : 26,
                    ),
                    SizedBox(width: compact ? 6 : 8),
                    Text(
                      correct ? '딩동댕!' : '다시 해보자!',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
