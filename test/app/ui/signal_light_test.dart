import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/signal_light.dart';

void main() {
  bool isLampLit(WidgetTester tester, String key) {
    final lamp = tester.widget<SignalLamp>(find.byKey(Key(key)));
    return lamp.lit;
  }

  testWidgets('idle state lights only the yellow lamp', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SignalLight(state: SignalLightState.idle)),
      ),
    );

    expect(isLampLit(tester, 'signal-red'), isFalse);
    expect(isLampLit(tester, 'signal-yellow'), isTrue);
    expect(isLampLit(tester, 'signal-green'), isFalse);
  });

  testWidgets('correct state lights only the green lamp', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SignalLight(state: SignalLightState.correct)),
      ),
    );

    expect(isLampLit(tester, 'signal-red'), isFalse);
    expect(isLampLit(tester, 'signal-yellow'), isFalse);
    expect(isLampLit(tester, 'signal-green'), isTrue);
  });

  testWidgets('wrong state lights only the red lamp', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SignalLight(state: SignalLightState.wrong)),
      ),
    );

    expect(isLampLit(tester, 'signal-red'), isTrue);
    expect(isLampLit(tester, 'signal-yellow'), isFalse);
    expect(isLampLit(tester, 'signal-green'), isFalse);
  });

  testWidgets('stacks red above yellow above green', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SignalLight(state: SignalLightState.idle, size: 200),
          ),
        ),
      ),
    );

    final red = tester.getCenter(find.byKey(const Key('signal-red')));
    final yellow = tester.getCenter(find.byKey(const Key('signal-yellow')));
    final green = tester.getCenter(find.byKey(const Key('signal-green')));

    expect(red.dy < yellow.dy, isTrue);
    expect(yellow.dy < green.dy, isTrue);
  });
}
