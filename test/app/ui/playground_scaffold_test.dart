import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/playground_scaffold.dart';

void main() {
  testWidgets('renders the playful background and road strip behind content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlaygroundScaffold(
          showRoad: true,
          child: Text('놀이터 내용'),
        ),
      ),
    );

    expect(find.byKey(const Key('playground-background')), findsOneWidget);
    expect(find.byKey(const Key('playground-road')), findsOneWidget);
    expect(find.text('놀이터 내용'), findsOneWidget);
  });
}
