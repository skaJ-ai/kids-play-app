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
            labelFontWeight: FontWeight.w600,
            labelLetterSpacing: 0.6,
            labelHeight: 1.3,
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
            labelFontWeight: FontWeight.w500,
            labelLetterSpacing: 0.2,
            labelHeight: 1.15,
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
        _buttonLabelStyle(
          tester,
          find.byKey(const Key('regular-button')),
          '기본 버튼',
        ).fontWeight,
        customLayout.button.regular.labelFontWeight,
      );
      expect(
        _buttonLabelStyle(
          tester,
          find.byKey(const Key('regular-button')),
          '기본 버튼',
        ).letterSpacing,
        customLayout.button.regular.labelLetterSpacing,
      );
      expect(
        _buttonLabelStyle(
          tester,
          find.byKey(const Key('regular-button')),
          '기본 버튼',
        ).height,
        customLayout.button.regular.labelHeight,
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
        _buttonLabelStyle(
          tester,
          find.byKey(const Key('compact-button')),
          '조밀한 버튼',
        ).fontWeight,
        customLayout.button.compact.labelFontWeight,
      );
      expect(
        _buttonLabelStyle(
          tester,
          find.byKey(const Key('compact-button')),
          '조밀한 버튼',
        ).letterSpacing,
        customLayout.button.compact.labelLetterSpacing,
      );
      expect(
        _buttonLabelStyle(
          tester,
          find.byKey(const Key('compact-button')),
          '조밀한 버튼',
        ).height,
        customLayout.button.compact.labelHeight,
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

  testWidgets(
    'keeps inherited titleLarge typography when custom layouts only override geometry',
    (WidgetTester tester) async {
      final baseTheme = buildKidTheme();
      final titleLarge = baseTheme.textTheme.titleLarge!;
      final customLayout = KidLayoutTheme(
        button: KidButtonTokens(
          regular: const KidButtonDensityTokens(
            height: 72,
            horizontalPadding: 26,
            iconGap: 14,
            iconChipSize: 40,
            iconSize: 24,
            labelFontSize: 24,
          ),
          compact: const KidButtonDensityTokens(
            height: 48,
            horizontalPadding: 12,
            iconGap: 6,
            iconChipSize: 28,
            iconSize: 16,
            labelFontSize: 18,
          ),
        ),
        panel: KidLayoutTheme.defaults.panel,
      );

      await tester.pumpWidget(
        _buildTestApp(
          ToyButton(
            key: const Key('fallback-typography-button'),
            label: '타이포 버튼',
            icon: Icons.play_arrow_rounded,
            onPressed: () {},
          ),
          theme: baseTheme.copyWith(extensions: [customLayout]),
        ),
      );

      final labelStyle = _buttonLabelStyle(
        tester,
        find.byKey(const Key('fallback-typography-button')),
        '타이포 버튼',
      );

      expect(labelStyle.fontSize, 24);
      expect(labelStyle.fontWeight, titleLarge.fontWeight);
      expect(labelStyle.letterSpacing, titleLarge.letterSpacing);
      expect(labelStyle.height, titleLarge.height);
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

  testWidgets(
    'uses themed button radius tokens for regular and compact buttons',
    (WidgetTester tester) async {
      final customLayout = KidLayoutTheme(
        button: KidButtonTokens(
          regular: KidLayoutTheme.defaults.button.regular.copyWith(radius: 18),
          compact: KidLayoutTheme.defaults.button.compact.copyWith(radius: 14),
        ),
        panel: KidLayoutTheme.defaults.panel,
      );

      await tester.pumpWidget(
        _buildTestApp(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ToyButton(
                key: const Key('regular-radius-button'),
                label: '둥근 기본 버튼',
                icon: Icons.play_arrow_rounded,
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              ToyButton(
                key: const Key('compact-radius-button'),
                label: '둥근 조밀 버튼',
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
        _buttonBorderRadius(
          tester,
          find.byKey(const Key('regular-radius-button')),
        ),
        18,
      );
      expect(
        _buttonBorderRadius(
          tester,
          find.byKey(const Key('compact-radius-button')),
        ),
        14,
      );
    },
  );

  testWidgets(
    'falls back to pill button radius when taller layouts clear the themed radius',
    (WidgetTester tester) async {
      final customLayout = KidLayoutTheme(
        button: KidButtonTokens(
          regular: KidLayoutTheme.defaults.button.regular.copyWith(
            height: 70,
            clearRadius: true,
          ),
          compact: KidLayoutTheme.defaults.button.compact,
        ),
        panel: KidLayoutTheme.defaults.panel,
      );

      await tester.pumpWidget(
        _buildTestApp(
          ToyButton(
            key: const Key('pill-radius-button'),
            label: '알약 버튼',
            icon: Icons.check_circle_rounded,
            onPressed: () {},
          ),
          theme: buildKidTheme().copyWith(extensions: [customLayout]),
        ),
      );

      expect(
        _buttonHeight(tester, find.byKey(const Key('pill-radius-button'))),
        70,
      );
      expect(
        _buttonBorderRadius(
          tester,
          find.byKey(const Key('pill-radius-button')),
        ),
        35,
      );
    },
  );

  testWidgets('reads chrome alpha overrides from kid theme tokens', (
    WidgetTester tester,
  ) async {
    final customLayout = KidLayoutTheme(
      button: KidLayoutTheme.defaults.button,
      panel: KidLayoutTheme.defaults.panel,
      chrome: const KidChromeTokens(
        button: KidButtonChromeTokens(
          primaryBorderAlpha: 0.41,
          primaryIconChipAlpha: 0.59,
          primaryIconChipBorderAlpha: 0.33,
          primaryHighlightAlpha: 0.67,
          secondaryIconChipAlpha: 0.88,
          secondaryHighlightAlpha: 0.14,
        ),
        panel: KidPanelChromeTokens(),
      ),
    );

    await tester.pumpWidget(
      _buildTestApp(
        ToyButton(
          label: '토큰 버튼',
          icon: Icons.play_arrow_rounded,
          onPressed: () {},
        ),
        theme: buildKidTheme().copyWith(extensions: [customLayout]),
      ),
    );

    final decoration = _buttonDecoration(tester, find.byType(ToyButton));
    final border = decoration.border! as Border;
    final chip = tester.widget<Container>(
      _buttonIconChipFinder(find.byType(ToyButton), Icons.play_arrow_rounded),
    );
    final chipDecoration = chip.decoration! as BoxDecoration;
    final chipBorder = chipDecoration.border! as Border;
    final highlight = tester.widget<Container>(
      _buttonHighlightFinder(find.byType(ToyButton)),
    );
    final highlightGradient =
        (highlight.decoration! as BoxDecoration).gradient! as LinearGradient;

    expect(border.top.color, KidPalette.white.withValues(alpha: 0.41));
    expect(chipDecoration.color, KidPalette.white.withValues(alpha: 0.59));
    expect(chipBorder.top.color, KidPalette.white.withValues(alpha: 0.33));
    expect(
      highlightGradient.colors.first,
      KidPalette.white.withValues(alpha: 0.67),
    );
  });

  testWidgets('reads disabled opacity from kid theme chrome tokens', (
    WidgetTester tester,
  ) async {
    final customLayout = KidLayoutTheme(
      button: KidLayoutTheme.defaults.button,
      panel: KidLayoutTheme.defaults.panel,
      chrome: const KidChromeTokens(
        button: KidButtonChromeTokens(disabledOpacity: 0.23),
        panel: KidPanelChromeTokens(),
      ),
    );

    await tester.pumpWidget(
      _buildTestApp(
        ToyButton(label: '비활성 버튼'),
        theme: buildKidTheme().copyWith(extensions: [customLayout]),
      ),
    );

    expect(_buttonOpacity(tester, find.byType(ToyButton)), 0.23);
  });

  testWidgets('reads primary shadow overrides from kid theme tokens', (
    WidgetTester tester,
  ) async {
    const customPrimaryShadows = [
      BoxShadow(color: Color(0x33123456), blurRadius: 21, offset: Offset(0, 9)),
      BoxShadow(color: Color(0x14112233), blurRadius: 7, offset: Offset(2, 3)),
    ];
    final customLayout = KidLayoutTheme(
      button: KidLayoutTheme.defaults.button,
      panel: KidLayoutTheme.defaults.panel,
      chrome: KidChromeTokens(
        button: KidButtonChromeTokens(),
        panel: KidPanelChromeTokens(),
        shadows: KidShadowTokens(buttonPrimary: customPrimaryShadows),
      ),
    );

    await tester.pumpWidget(
      _buildTestApp(
        ToyButton(
          label: '그림자 기본 버튼',
          icon: Icons.play_arrow_rounded,
          onPressed: () {},
        ),
        theme: buildKidTheme().copyWith(extensions: [customLayout]),
      ),
    );

    expect(
      _buttonDecoration(tester, find.byType(ToyButton)).boxShadow,
      customPrimaryShadows,
    );
  });

  testWidgets('reads secondary shadow overrides from kid theme tokens', (
    WidgetTester tester,
  ) async {
    const customSecondaryShadows = [
      BoxShadow(color: Color(0x22345678), blurRadius: 18, offset: Offset(0, 6)),
      BoxShadow(color: Color(0x11010203), blurRadius: 4, offset: Offset(1, 2)),
    ];
    final customLayout = KidLayoutTheme(
      button: KidLayoutTheme.defaults.button,
      panel: KidLayoutTheme.defaults.panel,
      chrome: KidChromeTokens(
        button: KidButtonChromeTokens(),
        panel: KidPanelChromeTokens(),
        shadows: KidShadowTokens(buttonSecondary: customSecondaryShadows),
      ),
    );

    await tester.pumpWidget(
      _buildTestApp(
        ToyButton(
          label: '그림자 보조 버튼',
          icon: Icons.settings_rounded,
          tone: ToyButtonTone.secondary,
          onPressed: () {},
        ),
        theme: buildKidTheme().copyWith(extensions: [customLayout]),
      ),
    );

    expect(
      _buttonDecoration(tester, find.byType(ToyButton)).boxShadow,
      customSecondaryShadows,
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

double _buttonOpacity(WidgetTester tester, Finder finder) {
  final opacityWidget = tester.widget<Opacity>(
    find.descendant(of: finder, matching: find.byType(Opacity)),
  );

  return opacityWidget.opacity;
}

EdgeInsetsGeometry _buttonPadding(WidgetTester tester, Finder finder) {
  final paddingWidget = _buttonContentPadding(tester, finder);

  return paddingWidget.padding;
}

double _buttonBorderWidth(WidgetTester tester, Finder finder) {
  final border = _buttonDecoration(tester, finder).border! as Border;

  return border.top.width;
}

double _buttonBorderRadius(WidgetTester tester, Finder finder) {
  final borderRadius =
      _buttonDecoration(tester, finder).borderRadius! as BorderRadius;

  return borderRadius.topLeft.x;
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

TextStyle _buttonLabelStyle(WidgetTester tester, Finder finder, String label) {
  final textWidget = tester.widget<Text>(
    find.descendant(of: finder, matching: find.text(label)),
  );

  return textWidget.style!;
}

double _buttonLabelFontSize(WidgetTester tester, Finder finder, String label) {
  return _buttonLabelStyle(tester, finder, label).fontSize!;
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
