import 'package:flutter/material.dart';

import 'answer_feedback_overlay.dart';

class PlayFeedbackLayer extends StatelessWidget {
  const PlayFeedbackLayer({
    super.key,
    required this.child,
    required this.visible,
    required this.correct,
    required this.compact,
  });

  final Widget child;
  final bool visible;
  final bool correct;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        AnswerFeedbackOverlay(
          visible: visible,
          correct: correct,
          compact: compact,
        ),
      ],
    );
  }
}
