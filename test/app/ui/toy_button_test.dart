import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/toy_button.dart';

void main() {
  testWidgets('fires callback and shows icon and label', (
    WidgetTester tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ToyButton(
              label: '플레이하기',
              icon: Icons.play_arrow_rounded,
              onPressed: () => taps += 1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('플레이하기'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    await tester.tap(find.byType(ToyButton));
    await tester.pumpAndSettle();

    expect(taps, 1);
  });

  testWidgets('ignores rapid repeated taps during cooldown', (
    WidgetTester tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ToyButton(
              label: '플레이하기',
              icon: Icons.play_arrow_rounded,
              cooldown: const Duration(milliseconds: 350),
              onPressed: () => taps += 1,
            ),
          ),
        ),
      ),
    );

    final button = find.byType(ToyButton);
    await tester.tap(button);
    await tester.pump();
    await tester.tap(button);
    await tester.pump();

    expect(taps, 1);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(button);
    await tester.pump();

    expect(taps, 2);
  });

  testWidgets(
    'reads regular and compact layout metrics from kid theme tokens',
    (WidgetTester tester) async {
      final customLayout = KidLayoutTheme(
        button: KidButtonTokens(
          regular: KidButtonDensityTokens(
            height: 72,
            horizontalPadding: 26,
            iconGap: 14,
            iconChipSize: 40,
            iconSize: 24,
            labelFontSize: 28,
            primaryBorderWidth: 1.7,
            secondaryBorderWidth: 1.1,
            highlightHeight: 14,
            highlightHorizontalInset: 22,
            iconChipRadius: 18,
          ),
          compact: KidButtonDensityTokens(
            height: 48,
            horizontalPadding: 12,
            iconGap: 6,
            iconChipSize: 28,
            iconSize: 16,
            labelFontSize: 18,
            primaryBorderWidth: 0.9,
            secondaryBorderWidth: 0.7,
            highlightHeight: 8,
            highlightHorizontalInset: 10,
            iconChipRadius: 9,
          ),
        ),
        panel: KidLayoutTheme.defaults.panel,
      );

      await tester.pumpWidget(
        _buildTestApp(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ToyButton(
                key: const Key('regular-button'),
                label: '기본 버튼',
                icon: Icons.play_arrow_rounded,
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              ToyButton(
                key: const Key('compact-button'),
                label: '조밀한 버튼',
                icon: Icons.star_rounded,
                density: ToyButtonDensity.compact,
                onPressed: () {},
              ),
            ],
          ),
          theme: buildKidTheme().copyWith(extensions: [customLayout]),
        ),
      );

      expect(
        _buttonHeight(tester, find.byKey(const Key('regular-button'))),
        customLayout.button.regular.height,
      );
      expect(
        _buttonPadding(tester, find.byKey(const Key('regular-button'))),
        const EdgeInsets.symmetric(horizontal: 26),
      );
      expect(
        _buttonIconChipSize(
          tester,
          find.byKey(const Key('regular-button')),
          Icons.play_arrow_rounded,
        ),
        customLayout.button.regular.iconChipSize,
      );
      expect(
        _buttonIconGapWidth(tester, find.byKey(const Key('regular-button'))),
        customLayout.button.regular.iconGap,
      );
      expect(
        _buttonIconSize(
          tester,
          find.byKey(const Key('regular-button')),
          Icons.play_arrow_rounded,
        ),
        customLayout.button.regular.iconSize,
      );
      expect(
        _buttonLabelFontSize(
          tester,
          find.byKey(const Key('regular-button')),
          '기본 버튼',
        ),
        customLayout.button.regular.labelFontSize,
      );
      expect(
        _buttonBorderWidth(tester, find.byKey(const Key('regular-button'))),
        customLayout.button.regular.primaryBorderWidth,
      );
      expect(
        _buttonHighlightHeight(tester, find.byKey(const Key('regular-button'))),
        customLayout.button.regular.highlightHeight,
      );
      expect(
        _buttonHighlightHorizontalInset(
          tester,
          find.byKey(const Key('regular-button')),
        ),
        customLayout.button.regular.highlightHorizontalInset,
      );
      expect(
        _buttonIconChipRadius(
          tester,
          find.byKey(const Key('regular-button')),
          Icons.play_arrow_rounded,
        ),
        customLayout.button.regular.iconChipRadius,
      );
      expect(
        _buttonHeight(tester, find.byKey(const Key('compact-button'))),
        customLayout.button.compact.height,
      );
      expect(
        _buttonPadding(tester, find.byKey(const Key('compact-button'))),
        const EdgeInsets.symmetric(horizontal: 12),
      );
      expect(
        _buttonIconChipSize(
          tester,
          find.byKey(const Key('compact-button')),
          Icons.star_rounded,
        ),
        customLayout.button.compact.iconChipSize,
      );
      expect(
        _buttonIconGapWidth(tester, find.byKey(const Key('compact-button'))),
        customLayout.button.compact.iconGap,
      );
      expect(
        _buttonIconSize(
          tester,
          find.byKey(const Key('compact-button')),
          Icons.star_rounded,
        ),
        customLayout.button.compact.iconSize,
      );
      expect(
        _buttonLabelFontSize(
          tester,
          find.byKey(const Key('compact-button')),
          '조밀한 버튼',
        ),
        customLayout.button.compact.labelFontSize,
      );
      expect(
        _buttonBorderWidth(tester, find.byKey(const Key('compact-button'))),
        customLayout.button.compact.primaryBorderWidth,
      );
      expect(
        _buttonHighlightHeight(tester, find.byKey(const Key('compact-button'))),
        customLayout.button.compact.highlightHeight,
      );
      expect(
        _buttonHighlightHorizontalInset(
          tester,
          find.byKey(const Key('compact-button')),
        ),
        customLayout.button.compact.highlightHorizontalInset,
      );
      expect(
        _buttonIconChipRadius(
          tester,
          find.byKey(const Key('compact-button')),
          Icons.star_rounded,
        ),
        customLayout.button.compact.iconChipRadius,
      );
    },
  );

  testWidgets('keeps explicit height overrides ahead of density presets', (
    WidgetTester tester,
  ) async {
    final customLayout = KidLayoutTheme(
      button: KidButtonTokens(
        regular: KidButtonDensityTokens(
          height: 64,
          horizontalPadding: 18,
          iconGap: 12,
          iconChipSize: 36,
          iconSize: 20,
          labelFontSize: 22,
        ),
        compact: KidButtonDensityTokens(
          height: 56,
          horizontalPadding: 9,
          iconGap: 5,
          iconChipSize: 24,
          iconSize: 14,
          labelFontSize: 17,
        ),
      ),
      panel: KidLayoutTheme.defaults.panel,
    );

    await tester.pumpWidget(
      _buildTestApp(
        ToyButton(
          key: const Key('override-button'),
          label: '직접 높이',
          icon: Icons.check_circle_rounded,
          density: ToyButtonDensity.compact,
          height: 70,
          onPressed: () {},
        ),
        theme: buildKidTheme().copyWith(extensions: [customLayout]),
      ),
    );

    expect(_buttonHeight(tester, find.byKey(const Key('override-button'))), 70);
    expect(
      _buttonPadding(tester, find.byKey(const Key('override-button'))),
      const EdgeInsets.symmetric(horizontal: 9),
    );
    expect(
      _buttonIconChipSize(
        tester,
        find.byKey(const Key('override-button')),
        Icons.check_circle_rounded,
      ),
      customLayout.button.compact.iconChipSize,
    );
    expect(
      _buttonIconGapWidth(tester, find.byKey(const Key('override-button'))),
      customLayout.button.compact.iconGap,
    );
    expect(
      _buttonIconSize(
        tester,
        find.byKey(const Key('override-button')),
        Icons.check_circle_rounded,
      ),
      customLayout.button.compact.iconSize,
    );
    expect(
      _buttonLabelFontSize(
        tester,
        find.byKey(const Key('override-button')),
        '직접 높이',
      ),
      customLayout.button.compact.labelFontSize,
    );
  });

  testWidgets('renders a calmer secondary tone with surface styling', (
    WidgetTester tester,
  ) async {
    final customLayout = KidLayoutTheme(
      button: KidButtonTokens(
        regular: KidButtonDensityTokens(
          height: 64,
          horizontalPadding: 18,
          iconGap: 12,
          iconChipSize: 36,
          iconSize: 20,
          labelFontSize: 22,
          secondaryBorderWidth: 1.6,
        ),
        compact: KidLayoutTheme.defaults.button.compact,
      ),
      panel: KidLayoutTheme.defaults.panel,
    );

    await tester.pumpWidget(
      _buildTestApp(
        ToyButton(
          label: '보호자 메뉴',
          icon: Icons.settings_rounded,
          tone: ToyButtonTone.secondary,
          onPressed: () {},
        ),
        theme: buildKidTheme().copyWith(extensions: [customLayout]),
      ),
    );

    final decoration = _buttonDecoration(tester, find.byType(ToyButton));
    final gradient = decoration.gradient! as LinearGradient;
    final border = decoration.border! as Border;
    final label = tester.widget<Text>(find.text('보호자 메뉴'));
    final icon = tester.widget<Icon>(find.byIcon(Icons.settings_rounded));

    expect(gradient.colors, const [KidPalette.cream, KidPalette.creamWarm]);
    expect(border.top.color, KidPalette.stroke);
    expect(border.top.width, customLayout.button.regular.secondaryBorderWidth);
    expect(decoration.boxShadow, KidShadows.buttonSoft);
    expect(label.style?.color, KidPalette.navy);
    expect(icon.color, KidPalette.navy);
  });

  testWidgets('stays stable with a longer label in a narrow width', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 240,
              child: ToyButton(
                label: '나중에 이어서 하기',
                icon: Icons.check_circle_rounded,
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('나중에 이어서 하기'), findsOneWidget);
  });

  test('asserts when gradient colors has fewer than two stops', () {
    expect(
      () => ToyButton(label: '플레이하기', colors: const <Color>[Colors.blue]),
      throwsAssertionError,
    );
  });
}

Widget _buildTestApp(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? buildKidTheme(),
    home: Scaffold(body: Center(child: child)),
  );
}

double _buttonHeight(WidgetTester tester, Finder finder) {
  final sizedBox = tester.widget<SizedBox>(_buttonBodyFinder(finder));

  return sizedBox.height!;
}

BoxDecoration _buttonDecoration(WidgetTester tester, Finder finder) {
  final decoratedBox = tester.widget<DecoratedBox>(
    _buttonDecorationFinder(finder),
  );

  return decoratedBox.decoration as BoxDecoration;
}

EdgeInsetsGeometry _buttonPadding(WidgetTester tester, Finder finder) {
  final paddingWidget = _buttonContentPadding(tester, finder);

  return paddingWidget.padding;
}

double _buttonBorderWidth(WidgetTester tester, Finder finder) {
  final border = _buttonDecoration(tester, finder).border! as Border;

  return border.top.width;
}

double _buttonHighlightHeight(WidgetTester tester, Finder finder) {
  return tester.getSize(_buttonHighlightFinder(finder)).height;
}

double _buttonHighlightHorizontalInset(WidgetTester tester, Finder finder) {
  final buttonRect = tester.getRect(_buttonDecorationFinder(finder));
  final highlightRect = tester.getRect(_buttonHighlightFinder(finder));

  return highlightRect.left - buttonRect.left;
}

double _buttonIconChipSize(WidgetTester tester, Finder finder, IconData icon) {
  final chipFinder = _buttonIconChipFinder(finder, icon);

  return tester.getSize(chipFinder).width;
}

double _buttonIconChipRadius(
  WidgetTester tester,
  Finder finder,
  IconData icon,
) {
  final chip = tester.widget<Container>(_buttonIconChipFinder(finder, icon));
  final decoration = chip.decoration! as BoxDecoration;
  final borderRadius = decoration.borderRadius! as BorderRadius;

  return borderRadius.topLeft.x;
}

double _buttonIconGapWidth(WidgetTester tester, Finder finder) {
  final sizedBox = tester.widget<SizedBox>(
    find.descendant(
      of: finder,
      matching: find.byWidgetPredicate(
        (Widget widget) =>
            widget is SizedBox && widget.width != null && widget.height == null,
      ),
    ),
  );

  return sizedBox.width!;
}

double _buttonIconSize(WidgetTester tester, Finder finder, IconData icon) {
  final iconWidget = tester.widget<Icon>(
    find.descendant(of: finder, matching: find.byIcon(icon)),
  );

  return iconWidget.size!;
}

double _buttonLabelFontSize(WidgetTester tester, Finder finder, String label) {
  final textWidget = tester.widget<Text>(
    find.descendant(of: finder, matching: find.text(label)),
  );

  return textWidget.style!.fontSize!;
}

Finder _buttonBodyFinder(Finder finder) {
  return find.descendant(
    of: finder,
    matching: find.byWidgetPredicate(
      (Widget widget) =>
          widget is SizedBox && widget.height != null && widget.width == null,
    ),
  );
}

Finder _buttonDecorationFinder(Finder finder) {
  return find.descendant(
    of: finder,
    matching: find.byWidgetPredicate((Widget widget) {
      if (widget is! DecoratedBox) {
        return false;
      }

      final decoration = widget.decoration;
      return decoration is BoxDecoration &&
          decoration.gradient != null &&
          decoration.border != null &&
          decoration.boxShadow != null;
    }),
  );
}

Padding _buttonContentPadding(WidgetTester tester, Finder finder) {
  final sizedBoxElement = tester.element(_buttonBodyFinder(finder));
  Padding? paddingWidget;

  sizedBoxElement.visitChildElements((Element child) {
    final widget = child.widget;
    if (widget is Padding) {
      paddingWidget = widget;
    }
  });

  if (paddingWidget == null) {
    throw StateError('ToyButton content Padding not found.');
  }

  return paddingWidget!;
}

Finder _buttonHighlightFinder(Finder finder) {
  return find.descendant(
    of: finder,
    matching: find.byWidgetPredicate((Widget widget) {
      if (widget is! Container) {
        return false;
      }

      final decoration = widget.decoration;
      return decoration is BoxDecoration &&
          decoration.gradient != null &&
          decoration.border == null;
    }),
  );
}

Finder _buttonIconChipFinder(Finder finder, IconData icon) {
  return find.ancestor(
    of: find.descendant(of: finder, matching: find.byIcon(icon)),
    matching: find.byWidgetPredicate(
      (Widget widget) => widget is Container && widget.child is Icon,
    ),
  );
}
