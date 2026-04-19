import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/features/avatar/data/local_avatar_photo_repository.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_expression.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory tempDir;
  late Directory rootDir;
  late LocalAvatarPhotoRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('avatar-photo-repository');
    rootDir = Directory(path.join(tempDir.path, 'root'));
    await rootDir.create(recursive: true);
    repository = LocalAvatarPhotoRepository(() async => rootDir);
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

      final savedFile = File(path.join(rootDir.path, 'avatar_photos', 'smile.png'));
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

  test(
    'rejects absolute and escaping paths without touching files outside the root',
    () async {
      final outsideFile = File(path.join(tempDir.path, 'outside.png'));
      await outsideFile.writeAsBytes(const [9, 8, 7]);

      expect(await repository.resolveFile('../outside.png'), isNull);
      expect(await repository.resolveFile(outsideFile.path), isNull);

      await repository.deletePhoto('../outside.png');
      await repository.deletePhoto(outsideFile.path);

      expect(outsideFile.existsSync(), isTrue);
      expect(await outsideFile.readAsBytes(), orderedEquals(const [9, 8, 7]));
    },
  );
}
