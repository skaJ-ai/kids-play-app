import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/toy_button.dart';

void main() {
  testWidgets('fires callback and shows icon label row', (
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

  testWidgets('uses calmer regular and compact densities by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ToyButton(
              key: const Key('regular-button'),
              label: '기본 버튼',
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            ToyButton(
              key: const Key('compact-button'),
              label: '조밀한 버튼',
              density: ToyButtonDensity.compact,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    expect(_buttonHeight(tester, find.byKey(const Key('regular-button'))), 64);
    expect(_buttonHeight(tester, find.byKey(const Key('compact-button'))), 56);
  });

  testWidgets('keeps explicit height overrides ahead of density presets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        ToyButton(
          key: const Key('override-button'),
          label: '직접 높이',
          density: ToyButtonDensity.compact,
          height: 70,
          onPressed: () {},
        ),
      ),
    );

    expect(_buttonHeight(tester, find.byKey(const Key('override-button'))), 70);
  });

  testWidgets('renders a calmer secondary tone with surface styling', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        ToyButton(
          label: '보호자 메뉴',
          icon: Icons.settings_rounded,
          tone: ToyButtonTone.secondary,
          onPressed: () {},
        ),
      ),
    );

    final decoration = _buttonDecoration(tester, find.byType(ToyButton));
    final gradient = decoration.gradient! as LinearGradient;
    final border = decoration.border! as Border;
    final label = tester.widget<Text>(find.text('보호자 메뉴'));
    final icon = tester.widget<Icon>(find.byIcon(Icons.settings_rounded));

    expect(gradient.colors, const [KidPalette.cream, KidPalette.creamWarm]);
    expect(border.top.color, KidPalette.stroke);
    expect(border.top.width, 1.2);
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

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    theme: buildKidTheme(),
    home: Scaffold(body: Center(child: child)),
  );
}

double _buttonHeight(WidgetTester tester, Finder finder) {
  final sizedBox = tester.widget<SizedBox>(
    find.descendant(
      of: finder,
      matching: find.byWidgetPredicate(
        (Widget widget) =>
            widget is SizedBox && widget.height != null && widget.width == null,
      ),
    ),
  );

  return sizedBox.height!;
}

BoxDecoration _buttonDecoration(WidgetTester tester, Finder finder) {
  final decoratedBox = tester.widget<DecoratedBox>(
    find.descendant(
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
    ),
  );

  return decoratedBox.decoration as BoxDecoration;
}
