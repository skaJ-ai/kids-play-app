import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
