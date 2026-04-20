import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/mascot_view.dart';

void main() {
  Image findMascotImage(WidgetTester tester) {
    final image = tester.widget<Image>(
      find.descendant(
        of: find.byType(MascotView),
        matching: find.byType(Image),
      ),
    );
    return image;
  }

  testWidgets('idle state renders the default face asset', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MascotView(state: MascotState.idle)),
      ),
    );

    final assetImage = findMascotImage(tester).image as AssetImage;
    expect(assetImage.assetName, 'assets/mascot/faces/idle.png');
  });

  testWidgets('correct state renders the winking-smile face asset',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MascotView(state: MascotState.correct)),
      ),
    );

    final assetImage = findMascotImage(tester).image as AssetImage;
    expect(assetImage.assetName, 'assets/mascot/faces/correct.jpg');
  });

  testWidgets(
      'wrong state renders the playful belly-laugh face asset (not shame)',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MascotView(state: MascotState.wrong)),
      ),
    );

    final assetImage = findMascotImage(tester).image as AssetImage;
    expect(assetImage.assetName, 'assets/mascot/faces/wrong.jpg');
  });

  testWidgets('missionClear state renders the sunglasses face asset',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MascotView(state: MascotState.missionClear)),
      ),
    );

    final assetImage = findMascotImage(tester).image as AssetImage;
    expect(assetImage.assetName, 'assets/mascot/faces/mission_clear.jpg');
  });

  testWidgets('respects the supplied size on both axes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: MascotView(state: MascotState.idle, size: 200),
          ),
        ),
      ),
    );

    final rect = tester.getRect(find.byType(MascotView));
    expect(rect.width, 200);
    expect(rect.height, 200);
  });
}
