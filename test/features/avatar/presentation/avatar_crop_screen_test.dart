import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_expression.dart';
import 'package:kids_play_app/features/avatar/presentation/avatar_crop_screen.dart';

void main() {
  final sourceBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGD4DwABBAEAX+XDSwAAAABJRU5ErkJggg==',
  );

  testWidgets('shows retry message when crop result is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AvatarCropScreen(
          expression: AvatarExpression.smile,
          sourceBytes: sourceBytes,
          onPerformCrop: (_) async => Uint8List(0),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('avatar-crop-save')));
    await tester.pumpAndSettle();

    expect(find.text('사진을 다시 잘라주세요.'), findsOneWidget);
  });

  testWidgets('pops with cropped bytes when save succeeds', (
    WidgetTester tester,
  ) async {
    final resultCompleter = Completer<Uint8List?>();
    Uint8List? receivedSourceBytes;
    final croppedBytes = Uint8List.fromList(const [1, 2, 3, 4]);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    resultCompleter.complete(
                      await Navigator.of(context).push<Uint8List>(
                        MaterialPageRoute(
                          builder: (_) => AvatarCropScreen(
                            expression: AvatarExpression.neutral,
                            sourceBytes: sourceBytes,
                            onPerformCrop: (bytes) async {
                              receivedSourceBytes = bytes;
                              return croppedBytes;
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('open crop'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open crop'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('avatar-crop-save')));
    await tester.pumpAndSettle();

    expect(receivedSourceBytes, orderedEquals(sourceBytes));
    expect(resultCompleter.isCompleted, isTrue);
    expect(await resultCompleter.future, orderedEquals(croppedBytes));
  });
}
