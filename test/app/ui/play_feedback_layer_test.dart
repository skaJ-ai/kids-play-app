import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/answer_feedback_overlay.dart';
import 'package:kids_play_app/app/ui/play_feedback_layer.dart';

void main() {
  testWidgets('layers answer feedback overlay above play content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PlayFeedbackLayer(
            visible: true,
            correct: false,
            compact: true,
            child: Text('놀이 내용'),
          ),
        ),
      ),
    );

    expect(find.text('놀이 내용'), findsOneWidget);
    expect(find.byType(AnswerFeedbackOverlay), findsOneWidget);

    final overlay = tester.widget<AnswerFeedbackOverlay>(
      find.byType(AnswerFeedbackOverlay),
    );
    final stack = tester.widget<Stack>(find.byType(Stack).first);

    expect(overlay.visible, isTrue);
    expect(overlay.correct, isFalse);
    expect(overlay.compact, isTrue);
    expect(stack.children.length, 2);
    expect(stack.children.last, isA<AnswerFeedbackOverlay>());
  });
}
