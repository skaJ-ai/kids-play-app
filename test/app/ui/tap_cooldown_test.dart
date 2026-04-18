import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/tap_cooldown.dart';

void main() {
  group('TapCooldownGate', () {
    test('unlocks immediately when cooldown is zero', () async {
      final gate = TapCooldownGate(cooldown: Duration.zero);
      var taps = 0;

      await gate.trigger(() {
        taps += 1;
      });
      expect(taps, 1);
      expect(gate.isLocked, isFalse);

      await gate.trigger(() {
        taps += 1;
      });
      expect(taps, 2);
      expect(gate.isLocked, isFalse);
    });

    test('swallows zero-cooldown action errors and unlocks immediately', () async {
      final gate = TapCooldownGate(cooldown: Duration.zero);

      await expectLater(
        gate.trigger(() {
          throw StateError('boom');
        }),
        completes,
      );
      expect(gate.isLocked, isFalse);
    });

    test('rethrows non-zero cooldown action errors after scheduling unlock', () async {
      final gate = TapCooldownGate(cooldown: const Duration(milliseconds: 10));

      await expectLater(
        gate.trigger(() {
          throw StateError('boom');
        }),
        throwsA(isA<StateError>()),
      );
      expect(gate.isLocked, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(gate.isLocked, isFalse);
    });

    test('stays locked until cooldown expires', () async {
      final gate = TapCooldownGate(cooldown: const Duration(milliseconds: 10));
      var taps = 0;

      await gate.trigger(() {
        taps += 1;
      });
      expect(taps, 1);
      expect(gate.isLocked, isTrue);

      await gate.trigger(() {
        taps += 1;
      });
      expect(taps, 1);

      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(gate.isLocked, isFalse);

      await gate.trigger(() {
        taps += 1;
      });
      expect(taps, 2);
    });
  });

  group('CooldownInkWell', () {
    testWidgets('unlocks immediately when cooldown is zero', (
      WidgetTester tester,
    ) async {
      var taps = 0;

      await tester.pumpWidget(
        _buildTestApp(
          CooldownInkWell(
            cooldown: Duration.zero,
            onTap: () {
              taps += 1;
            },
            child: const SizedBox(
              width: 120,
              height: 48,
              child: Center(child: Text('Tap target')),
            ),
          ),
        ),
      );

      final target = find.text('Tap target');

      await tester.tap(target);
      await tester.pump();
      await tester.tap(target);
      await tester.pump();

      expect(taps, 2);
    });

    testWidgets('swallows zero-cooldown tap errors while unlocking immediately', (
      WidgetTester tester,
    ) async {
      var taps = 0;

      await tester.pumpWidget(
        _buildTestApp(
          CooldownInkWell(
            cooldown: Duration.zero,
            onTap: () {
              taps += 1;
              throw StateError('boom');
            },
            child: const SizedBox(
              width: 120,
              height: 48,
              child: Center(child: Text('Tap target')),
            ),
          ),
        ),
      );

      final target = find.text('Tap target');

      await tester.tap(target);
      await tester.pump();
      expect(taps, 1);
      expect(tester.takeException(), isNull);

      await tester.tap(target);
      await tester.pump();
      expect(taps, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ignores rapid repeated taps until cooldown expires', (
      WidgetTester tester,
    ) async {
      var taps = 0;

      await tester.pumpWidget(
        _buildTestApp(
          CooldownInkWell(
            cooldown: const Duration(milliseconds: 200),
            onTap: () {
              taps += 1;
            },
            child: const SizedBox(
              width: 120,
              height: 48,
              child: Center(child: Text('Tap target')),
            ),
          ),
        ),
      );

      final target = find.text('Tap target');

      await tester.tap(target);
      await tester.pump();
      await tester.tap(target);
      await tester.pump();

      expect(taps, 1);

      await tester.pump(const Duration(milliseconds: 250));
      await tester.tap(target);
      await tester.pump();

      expect(taps, 2);
    });

    testWidgets(
      'uses mounted checks when zero-cooldown taps finish after unmount',
      (WidgetTester tester) async {
        final completer = Completer<void>();

        await tester.pumpWidget(
          _buildTestApp(
            CooldownInkWell(
              cooldown: Duration.zero,
              onTap: () => completer.future,
              child: const SizedBox(
                width: 120,
                height: 48,
                child: Center(child: Text('Tap target')),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Tap target'));
        await tester.pump();
        await tester.pumpWidget(_buildTestApp(const SizedBox.shrink()));

        completer.complete();
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('uses mounted checks when delayed taps finish after unmount', (
      WidgetTester tester,
    ) async {
      final completer = Completer<void>();

      await tester.pumpWidget(
        _buildTestApp(
          CooldownInkWell(
            cooldown: const Duration(milliseconds: 200),
            onTap: () => completer.future,
            child: const SizedBox(
              width: 120,
              height: 48,
              child: Center(child: Text('Tap target')),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap target'));
      await tester.pump();
      await tester.pumpWidget(_buildTestApp(const SizedBox.shrink()));

      completer.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(tester.takeException(), isNull);
    });
  });
}

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}
