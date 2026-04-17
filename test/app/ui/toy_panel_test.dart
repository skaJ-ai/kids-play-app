import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';

void main() {
  testWidgets('keeps the shadowed shell outside the clipped inner layer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ToyPanel(child: SizedBox(width: 120, height: 80)),
          ),
        ),
      ),
    );

    final shadowedShell = find.byWidgetPredicate((widget) {
      if (widget is! DecoratedBox) {
        return false;
      }

      final decoration = widget.decoration;
      return decoration is BoxDecoration &&
          decoration.boxShadow?.isNotEmpty == true;
    }, description: 'shadowed toy panel shell');

    expect(shadowedShell, findsOneWidget);
    expect(
      find.ancestor(of: shadowedShell, matching: find.byType(ClipRRect)),
      findsNothing,
    );
    expect(
      find.descendant(of: shadowedShell, matching: find.byType(ClipRRect)),
      findsOneWidget,
    );
  });
}
