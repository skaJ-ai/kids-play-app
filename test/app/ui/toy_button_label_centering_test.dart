import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/toy_button.dart';

void main() {
  testWidgets('keeps icon button labels optically centered in the full width', (
    WidgetTester tester,
  ) async {
    const buttonWidth = 240.0;
    const label = '놀이 시작';
    const icon = Icons.arrow_forward_rounded;
    const hostKey = Key('toy-button-host');
    final theme = buildKidTheme();

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              key: hostKey,
              width: buttonWidth,
              child: ToyButton(label: label, icon: icon, onPressed: () {}),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final buttonRect = tester.getRect(find.byKey(hostKey));
    final labelRect = tester.getRect(find.text(label));
    final iconChipRect = tester.getRect(_buttonIconChipFinder(icon));

    expect(labelRect.center.dx, closeTo(buttonRect.center.dx, 1.0));
    expect(labelRect.left, greaterThan(iconChipRect.right));
    expect(labelRect.right, lessThanOrEqualTo(buttonRect.right));
  });

  testWidgets(
    'widens narrow icon labels beyond symmetric reservation without crossing the chip',
    (WidgetTester tester) async {
      const buttonWidth = 190.0;
      const label = 'Continue';
      const icon = Icons.check_circle_rounded;
      final theme = buildKidTheme();
      final densityTokens = theme.kidLayout.button.regular;
      final iconFootprint = densityTokens.iconChipSize + densityTokens.iconGap;
      final symmetricLabelWidth =
          buttonWidth -
          (densityTokens.horizontalPadding * 2) -
          (iconFootprint * 2);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: buttonWidth,
                child: ToyButton(label: label, icon: icon, onPressed: () {}),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text(label));
      final fullLabelWidth = _measureSingleLineLabelWidth(
        label: label,
        labelStyle: textWidget.style!,
      );
      final labelRect = tester.getRect(find.text(label));
      final iconChipRect = tester.getRect(_buttonIconChipFinder(icon));

      expect(fullLabelWidth, greaterThan(symmetricLabelWidth));
      expect(labelRect.width, greaterThan(symmetricLabelWidth));
      expect(labelRect.left, greaterThan(iconChipRect.right));
    },
  );
}

Finder _buttonIconChipFinder(IconData icon) {
  return find.ancestor(
    of: find.byIcon(icon),
    matching: find.byWidgetPredicate(
      (Widget widget) => widget is Container && widget.child is Icon,
    ),
  );
}

double _measureSingleLineLabelWidth({
  required String label,
  required TextStyle labelStyle,
}) {
  final textPainter = TextPainter(
    text: TextSpan(text: label, style: labelStyle),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: double.infinity);

  return textPainter.width;
}
