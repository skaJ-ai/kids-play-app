import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/features/avatar/data/local_avatar_photo_repository.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_expression.dart';

void main() {
  late Directory tempDir;
  late LocalAvatarPhotoRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('avatar-photo-repository');
    repository = LocalAvatarPhotoRepository(() async => tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'saves bytes to a deterministic expression filename and resolves/deletes it',
    () async {
      final relativePath = await repository.saveExpressionPhoto(
        expression: AvatarExpression.smile,
        bytes: Uint8List.fromList(const [1, 2, 3, 4]),
      );

      final savedFile = File('${tempDir.path}/avatar_photos/smile.png');
      final resolvedFile = await repository.resolveFile(relativePath);

      expect(relativePath, 'avatar_photos/smile.png');
      expect(savedFile.existsSync(), isTrue);
      expect(await savedFile.readAsBytes(), orderedEquals(const [1, 2, 3, 4]));
      expect(resolvedFile, isNotNull);
      expect(
        await resolvedFile!.readAsBytes(),
        orderedEquals(const [1, 2, 3, 4]),
      );

      await repository.deletePhoto(relativePath);

      expect(savedFile.existsSync(), isFalse);
      expect(await repository.resolveFile(relativePath), isNull);
    },
  );
}
