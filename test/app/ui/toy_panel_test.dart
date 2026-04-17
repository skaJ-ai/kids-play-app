import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';

const _panelChildKey = ValueKey<String>('toy-panel-child');

void main() {
  group('ToyPanel density', () {
    testWidgets('keeps regular density defaults by default', (
      WidgetTester tester,
    ) async {
      await _pumpToyPanel(tester);

      _expectResolvedShell(
        tester,
        expectedPadding: const EdgeInsets.all(24),
        expectedRadius: 32,
      );
    });

    testWidgets('uses compact density defaults', (WidgetTester tester) async {
      await _pumpToyPanel(tester, density: ToyPanelDensity.compact);

      _expectResolvedShell(
        tester,
        expectedPadding: const EdgeInsets.all(14),
        expectedRadius: 32,
      );
    });

    testWidgets('uses tight density defaults', (WidgetTester tester) async {
      await _pumpToyPanel(tester, density: ToyPanelDensity.tight);

      _expectResolvedShell(
        tester,
        expectedPadding: const EdgeInsets.all(12),
        expectedRadius: 24,
      );
    });

    testWidgets('lets explicit padding and radius override density', (
      WidgetTester tester,
    ) async {
      const customPadding = EdgeInsets.symmetric(horizontal: 10, vertical: 8);
      const customRadius = 40.0;

      await _pumpToyPanel(
        tester,
        density: ToyPanelDensity.tight,
        padding: customPadding,
        radius: customRadius,
      );

      _expectResolvedShell(
        tester,
        expectedPadding: customPadding,
        expectedRadius: customRadius,
      );
    });
  });

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

Future<void> _pumpToyPanel(
  WidgetTester tester, {
  ToyPanelDensity density = ToyPanelDensity.regular,
  EdgeInsetsGeometry? padding,
  double? radius,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: ToyPanel(
            density: density,
            padding: padding,
            radius: radius,
            child: const SizedBox(key: _panelChildKey, width: 120, height: 80),
          ),
        ),
      ),
    ),
  );
}

void _expectResolvedShell(
  WidgetTester tester, {
  required EdgeInsetsGeometry expectedPadding,
  required double expectedRadius,
}) {
  final panelFinder = find.byType(ToyPanel);
  final paddingFinder = find.ancestor(
    of: find.byKey(_panelChildKey),
    matching: find.byType(Padding),
  );
  final clipFinder = find.descendant(
    of: panelFinder,
    matching: find.byType(ClipRRect),
  );

  expect(paddingFinder, findsOneWidget);
  expect(clipFinder, findsOneWidget);

  final paddingWidget = tester.widget<Padding>(paddingFinder);
  final clipWidget = tester.widget<ClipRRect>(clipFinder);

  expect(paddingWidget.padding, expectedPadding);
  expect(clipWidget.borderRadius, BorderRadius.circular(expectedRadius));
}
