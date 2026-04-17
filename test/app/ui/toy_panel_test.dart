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
          panel: KidPanelTokens(
            regular: KidPanelDensityTokens(
              padding: EdgeInsets.all(30),
              radius: 40,
              borderWidth: 2,
              highlightHeight: 22,
              highlightHorizontalInset: 26,
            ),
            compact: KidPanelDensityTokens(
              padding: EdgeInsets.all(18),
              radius: 36,
              borderWidth: 1.25,
              highlightHeight: 14,
              highlightHorizontalInset: 12,
            ),
            tight: KidPanelDensityTokens(
              padding: EdgeInsets.all(8),
              radius: 20,
              borderWidth: 0.75,
              highlightHeight: 10,
              highlightHorizontalInset: 6,
            ),
          ),
        );
        final theme = buildKidTheme().copyWith(extensions: [customLayout]);

        await _pumpToyPanel(tester, theme: theme);
        _expectResolvedShell(
          tester,
          expectedPadding: customLayout.panel.regular.padding,
          expectedRadius: customLayout.panel.regular.radius,
          expectedBorderWidth: customLayout.panel.regular.borderWidth,
          expectedHighlightHeight: customLayout.panel.regular.highlightHeight,
          expectedHighlightHorizontalInset:
              customLayout.panel.regular.highlightHorizontalInset,
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
          expectedBorderWidth: customLayout.panel.compact.borderWidth,
          expectedHighlightHeight: customLayout.panel.compact.highlightHeight,
          expectedHighlightHorizontalInset:
              customLayout.panel.compact.highlightHorizontalInset,
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
          expectedBorderWidth: customLayout.panel.tight.borderWidth,
          expectedHighlightHeight: customLayout.panel.tight.highlightHeight,
          expectedHighlightHorizontalInset:
              customLayout.panel.tight.highlightHorizontalInset,
        );
      },
    );

    testWidgets('lets explicit padding and radius override density', (
      WidgetTester tester,
    ) async {
      const customPadding = EdgeInsets.symmetric(horizontal: 10, vertical: 8);
      const customRadius = 40.0;
      final defaults = KidLayoutTheme.defaults.panel.tight;

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
        expectedBorderWidth: defaults.borderWidth,
        expectedHighlightHeight: defaults.highlightHeight,
        expectedHighlightHorizontalInset: defaults.highlightHorizontalInset,
      );
    });
  });

  group('ToyPanel tone', () {
    testWidgets('keeps the cream shell by default', (
      WidgetTester tester,
    ) async {
      await _pumpToyPanel(tester);

      _expectResolvedColors(
        tester,
        expectedBackgroundColor: KidPalette.cream,
        expectedBorderColor: KidPalette.stroke,
      );
    });

    testWidgets('uses named tone defaults', (WidgetTester tester) async {
      await _pumpToyPanel(tester, tone: ToyPanelTone.airy);

      _expectResolvedColors(
        tester,
        expectedBackgroundColor: KidPalette.white.withValues(alpha: 0.94),
        expectedBorderColor: KidPalette.stroke,
      );

      await _pumpToyPanel(tester, tone: ToyPanelTone.warm);

      _expectResolvedColors(
        tester,
        expectedBackgroundColor: KidPalette.creamWarm,
        expectedBorderColor: KidPalette.stroke,
      );
    });

    testWidgets('lets explicit colors override tone defaults', (
      WidgetTester tester,
    ) async {
      const customBackgroundColor = Color(0xFFFEDCBA);
      const customBorderColor = Color(0xFF345678);

      await _pumpToyPanel(
        tester,
        tone: ToyPanelTone.airy,
        backgroundColor: customBackgroundColor,
        borderColor: customBorderColor,
      );

      _expectResolvedColors(
        tester,
        expectedBackgroundColor: customBackgroundColor,
        expectedBorderColor: customBorderColor,
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
  ToyPanelTone? tone,
  EdgeInsetsGeometry? padding,
  Color? backgroundColor,
  Color? borderColor,
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
            tone: tone,
            padding: padding,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
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
  required double expectedBorderWidth,
  required double expectedHighlightHeight,
  required double expectedHighlightHorizontalInset,
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
  final decoration = _panelDecoration(tester, panelFinder);
  final border = decoration.border! as Border;
  final highlightFinder = find.descendant(
    of: panelFinder,
    matching: find.byWidgetPredicate(
      (Widget widget) =>
          widget is Container && widget.decoration is BoxDecoration,
    ),
  );
  final highlightPositionedFinder = find.ancestor(
    of: highlightFinder,
    matching: find.byType(Positioned),
  );

  expect(paddingFinder, findsOneWidget);
  expect(clipFinder, findsOneWidget);
  expect(highlightFinder, findsOneWidget);
  expect(highlightPositionedFinder, findsOneWidget);

  final paddingWidget = tester.widget<Padding>(paddingFinder);
  final clipWidget = tester.widget<ClipRRect>(clipFinder);
  final highlightPositioned = tester.widget<Positioned>(
    highlightPositionedFinder,
  );

  expect(paddingWidget.padding, expectedPadding);
  expect(clipWidget.borderRadius, BorderRadius.circular(expectedRadius));
  expect(border.top.width, expectedBorderWidth);
  expect(tester.getSize(highlightFinder).height, expectedHighlightHeight);
  expect(highlightPositioned.left, expectedHighlightHorizontalInset);
  expect(highlightPositioned.right, expectedHighlightHorizontalInset);
}

void _expectResolvedColors(
  WidgetTester tester, {
  required Color expectedBackgroundColor,
  required Color expectedBorderColor,
}) {
  final decoration = _panelDecoration(tester, find.byType(ToyPanel));
  final gradient = decoration.gradient! as LinearGradient;
  final border = decoration.border! as Border;
  final expectedGradientColors = [
    Color.lerp(expectedBackgroundColor, KidPalette.white, 0.34)!,
    expectedBackgroundColor,
  ];
  final expectedResolvedBorderColor = expectedBorderColor.withValues(
    alpha: expectedBorderColor == KidPalette.stroke ? 0.88 : 0.72,
  );

  expect(gradient.colors, expectedGradientColors);
  expect(border.top.color, expectedResolvedBorderColor);
  expect(border.right.color, expectedResolvedBorderColor);
  expect(border.bottom.color, expectedResolvedBorderColor);
  expect(border.left.color, expectedResolvedBorderColor);
}

BoxDecoration _panelDecoration(WidgetTester tester, Finder finder) {
  final decoratedBox = tester.widget<DecoratedBox>(
    find.descendant(
      of: finder,
      matching: find.byWidgetPredicate((Widget widget) {
        if (widget is! DecoratedBox) {
          return false;
        }

        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.border != null &&
            decoration.boxShadow?.isNotEmpty == true;
      }),
    ),
  );

  return decoratedBox.decoration as BoxDecoration;
}
