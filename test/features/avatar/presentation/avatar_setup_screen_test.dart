import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/features/avatar/presentation/avatar_setup_screen.dart';

void main() {
  testWidgets('shows the five expression slots and parent helper copy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AvatarSetupScreen()));
    await tester.pumpAndSettle();

    expect(find.text('표정 카드 만들기'), findsOneWidget);
    expect(find.text('보통'), findsOneWidget);
    expect(find.text('웃음'), findsOneWidget);
    expect(find.text('슬픔'), findsOneWidget);
    expect(find.text('화남'), findsOneWidget);
    expect(find.text('놀람'), findsOneWidget);
    expect(find.textContaining('5개 표정'), findsOneWidget);
    expect(find.text('아직 넣지 않았어요'), findsNWidgets(5));
  });

  testWidgets('keeps the avatar setup screen stable on a compact landscape phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(780, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: AvatarSetupScreen()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('표정 카드 만들기'), findsOneWidget);
  });
}
