import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/main.dart';

void main() {
  testWidgets('shows hero screen with app title, hero face, and play button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KidsPlayApp());

    expect(find.byKey(const Key('hero-face-image')), findsOneWidget);
    expect(find.text('승원이의 빵빵 놀이터'), findsOneWidget);
    expect(find.text('플레이하기'), findsOneWidget);
    expect(find.text('빵빵 출발!'), findsOneWidget);
  });

  testWidgets('moves from hero screen to category menu when play is tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KidsPlayApp());

    await tester.tap(find.text('플레이하기'));
    await tester.pumpAndSettle();

    expect(find.text('어떤 놀이터로 갈까?'), findsOneWidget);
    expect(find.text('한글'), findsOneWidget);
    expect(find.text('알파벳'), findsOneWidget);
    expect(find.text('숫자'), findsOneWidget);
  });
}
