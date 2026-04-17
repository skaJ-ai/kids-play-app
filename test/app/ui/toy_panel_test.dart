import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';

const _panelChildKey = ValueKey<String>('toy-panel-child');

void main() {
  group('ToyPanel density', () {
    testWidgets(
      'reads regular compact and tight defaults from kid theme tokens',
      (WidgetTester tester) async {
        final customLayout = KidLayoutTheme(
          button: KidLayoutTheme.defaults.button,
          panel: KidPanelThemeTokens(
            regular: KidPanelDensityTokens(
              padding: EdgeInsets.all(30),
              radius: 40,
            ),
            compact: KidPanelDensityTokens(
              padding: EdgeInsets.all(18),
              radius: 36,
            ),
            tight: KidPanelDensityTokens(
              padding: EdgeInsets.all(8),
              radius: 20,
            ),
          ),
        );
        final theme = buildKidTheme().copyWith(extensions: [customLayout]);

        await _pumpToyPanel(tester, theme: theme);
        _expectResolvedShell(
          tester,
          expectedPadding: customLayout.panel.regular.padding,
          expectedRadius: customLayout.panel.regular.radius,
        );

        await _pumpToyPanel(
          tester,
          density: ToyPanelDensity.compact,
          theme: theme,
        );
        _expectResolvedShell(
          tester,
          expectedPadding: customLayout.panel.compact.padding,
          expectedRadius: customLayout.panel.compact.radius,
        );

        await _pumpToyPanel(
          tester,
          density: ToyPanelDensity.tight,
          theme: theme,
        );
        _expectResolvedShell(
          tester,
          expectedPadding: customLayout.panel.tight.padding,
          expectedRadius: customLayout.panel.tight.radius,
        );
      },
    );

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
      MaterialApp(
        theme: buildKidTheme(),
        home: const Scaffold(
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
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? buildKidTheme(),
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
