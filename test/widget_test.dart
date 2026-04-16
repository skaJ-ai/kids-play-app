import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/features/home/data/home_catalog_repository.dart';
import 'package:kids_play_app/features/home/presentation/category_hub_screen.dart';
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

  testWidgets('shows hangul category hub with learn and game buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CategoryHubScreen(
          category: const HomeCategory(
            id: 'hangul',
            label: '한글',
            description: '자음과 모음을 만나요',
            backgroundColorHex: '#FFE699',
            iconName: 'text_fields_rounded',
          ),
        ),
      ),
    );

    expect(find.text('한글 놀이터'), findsOneWidget);
    expect(find.text('학습하기'), findsOneWidget);
    expect(find.text('게임하기'), findsOneWidget);
  });

  testWidgets('opens the first hangul learning card from the category hub', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CategoryHubScreen(
          category: const HomeCategory(
            id: 'hangul',
            label: '한글',
            description: '자음과 모음을 만나요',
            backgroundColorHex: '#FFE699',
            iconName: 'text_fields_rounded',
          ),
        ),
      ),
    );

    await tester.tap(find.text('학습하기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('한글 학습'), findsOneWidget);
    expect(find.text('기역, ㄱ'), findsOneWidget);
    expect(find.text('다음'), findsOneWidget);
  });
}
