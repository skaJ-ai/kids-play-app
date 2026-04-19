import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/features/avatar/application/avatar_photo_service.dart';
import 'package:kids_play_app/features/avatar/data/avatar_photo_repository.dart';
import 'package:kids_play_app/features/avatar/data/avatar_photo_store.dart';
import 'package:kids_play_app/features/avatar/data/local_avatar_photo_repository.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_expression.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_photo_entry.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_photo_snapshot.dart';

void main() {
  late Directory tempDir;
  late LocalAvatarPhotoRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('avatar-photo-service');
    repository = LocalAvatarPhotoRepository(() async => tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'resolveBestPhoto returns the first available file in priority order',
    () async {
      final neutralPath = await repository.saveExpressionPhoto(
        expression: AvatarExpression.neutral,
        bytes: Uint8List.fromList(const [4, 5, 6]),
      );
      final photoStore = FakeAvatarPhotoStore(
        AvatarPhotoSnapshot(
          entries: {
            AvatarExpression.smile: AvatarPhotoEntry(
              expression: AvatarExpression.smile,
              relativePath: 'avatar_photos/smile.png',
              updatedAt: DateTime.utc(2026, 4, 19, 9),
            ),
            AvatarExpression.neutral: AvatarPhotoEntry(
              expression: AvatarExpression.neutral,
              relativePath: neutralPath,
              updatedAt: DateTime.utc(2026, 4, 19, 10),
            ),
          },
        ),
      );
      final service = AvatarPhotoService(
        photoStore: photoStore,
        repository: repository,
      );

      final resolvedFile = await service.resolveBestPhoto([
        AvatarExpression.smile,
        AvatarExpression.neutral,
      ]);

      expect(resolvedFile, isNotNull);
      expect(await resolvedFile!.readAsBytes(), orderedEquals(const [4, 5, 6]));
      expect(resolvedFile.path, endsWith('avatar_photos/neutral.png'));
    },
  );

  test(
    'saveExpressionPhoto persists the repository path into AvatarPhotoStore metadata',
    () async {
      final photoStore = FakeAvatarPhotoStore();
      final savedAt = DateTime.utc(2026, 4, 19, 11, 45, 0);
      final service = AvatarPhotoService(
        photoStore: photoStore,
        repository: repository,
        now: () => savedAt,
      );

      await service.saveExpressionPhoto(
        expression: AvatarExpression.surprised,
        bytes: Uint8List.fromList(const [7, 8, 9]),
      );

      final entry = photoStore.snapshot.entryFor(AvatarExpression.surprised);
      final savedFile = File('${tempDir.path}/avatar_photos/surprised.png');

      expect(entry, isNotNull);
      expect(entry!.relativePath, 'avatar_photos/surprised.png');
      expect(entry.updatedAt, savedAt);
      expect(savedFile.existsSync(), isTrue);
      expect(await savedFile.readAsBytes(), orderedEquals(const [7, 8, 9]));
    },
  );

  test(
    'clearExpression removes metadata and deletes the stored file',
    () async {
      final angryPath = await repository.saveExpressionPhoto(
        expression: AvatarExpression.angry,
        bytes: Uint8List.fromList(const [1, 3, 5]),
      );
      final photoStore = FakeAvatarPhotoStore(
        AvatarPhotoSnapshot(
          entries: {
            AvatarExpression.angry: AvatarPhotoEntry(
              expression: AvatarExpression.angry,
              relativePath: angryPath,
              updatedAt: DateTime.utc(2026, 4, 19, 12),
            ),
          },
        ),
      );
      final service = AvatarPhotoService(
        photoStore: photoStore,
        repository: repository,
      );

      await service.clearExpression(AvatarExpression.angry);

      expect(photoStore.snapshot.entryFor(AvatarExpression.angry), isNull);
      expect(File('${tempDir.path}/$angryPath').existsSync(), isFalse);
    },
  );

  test('clearAll clears metadata and deletes all referenced files', () async {
    final smilePath = await repository.saveExpressionPhoto(
      expression: AvatarExpression.smile,
      bytes: Uint8List.fromList(const [2, 4, 6]),
    );
    final sadPath = await repository.saveExpressionPhoto(
      expression: AvatarExpression.sad,
      bytes: Uint8List.fromList(const [8, 10, 12]),
    );
    final photoStore = FakeAvatarPhotoStore(
      AvatarPhotoSnapshot(
        entries: {
          AvatarExpression.smile: AvatarPhotoEntry(
            expression: AvatarExpression.smile,
            relativePath: smilePath,
            updatedAt: DateTime.utc(2026, 4, 19, 13),
          ),
          AvatarExpression.sad: AvatarPhotoEntry(
            expression: AvatarExpression.sad,
            relativePath: sadPath,
            updatedAt: DateTime.utc(2026, 4, 19, 14),
          ),
        },
      ),
    );
    final service = AvatarPhotoService(
      photoStore: photoStore,
      repository: repository,
    );

    await service.clearAll();

    expect(photoStore.snapshot.entries, isEmpty);
    expect(File('${tempDir.path}/$smilePath').existsSync(), isFalse);
    expect(File('${tempDir.path}/$sadPath').existsSync(), isFalse);
  });

  test(
    'concurrent saves preserve both entries by serializing snapshot mutations',
    () async {
      final photoStore = DelayedFirstSaveAvatarPhotoStore();
      final service = AvatarPhotoService(
        photoStore: photoStore,
        repository: FakeAvatarPhotoRepository(),
        now: () => DateTime.utc(2026, 4, 19, 15),
      );

      final smileSave = service.saveExpressionPhoto(
        expression: AvatarExpression.smile,
        bytes: Uint8List.fromList(const [1]),
      );
      await photoStore.firstSaveStarted.future;

      final sadSave = service.saveExpressionPhoto(
        expression: AvatarExpression.sad,
        bytes: Uint8List.fromList(const [2]),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      photoStore.releaseFirstSave();

      await Future.wait([smileSave, sadSave]);

      expect(photoStore.snapshot.entries.length, 2);
      expect(photoStore.snapshot.entryFor(AvatarExpression.smile), isNotNull);
      expect(photoStore.snapshot.entryFor(AvatarExpression.sad), isNotNull);
    },
  );
}

class FakeAvatarPhotoStore implements AvatarPhotoStore {
  FakeAvatarPhotoStore([AvatarPhotoSnapshot? snapshot])
    : snapshot = snapshot ?? const AvatarPhotoSnapshot();

  AvatarPhotoSnapshot snapshot;

  @override
  Future<AvatarPhotoSnapshot> loadSnapshot() async => snapshot;

  @override
  Future<void> saveSnapshot(AvatarPhotoSnapshot snapshot) async {
    this.snapshot = snapshot;
  }
}

class DelayedFirstSaveAvatarPhotoStore implements AvatarPhotoStore {
  AvatarPhotoSnapshot snapshot = const AvatarPhotoSnapshot();
  final Completer<void> firstSaveStarted = Completer<void>();
  final Completer<void> _allowFirstSaveToComplete = Completer<void>();
  int _saveCount = 0;

  void releaseFirstSave() {
    if (!_allowFirstSaveToComplete.isCompleted) {
      _allowFirstSaveToComplete.complete();
    }
  }

  @override
  Future<AvatarPhotoSnapshot> loadSnapshot() async => snapshot;

  @override
  Future<void> saveSnapshot(AvatarPhotoSnapshot snapshot) async {
    _saveCount += 1;
    if (_saveCount == 1) {
      firstSaveStarted.complete();
      await _allowFirstSaveToComplete.future;
    }

    this.snapshot = snapshot;
  }
}

class FakeAvatarPhotoRepository implements AvatarPhotoRepository {
  @override
  Future<void> deletePhoto(String relativePath) async {}

  @override
  Future<File?> resolveFile(String relativePath) async => null;

  @override
  Future<String> saveExpressionPhoto({
    required AvatarExpression expression,
    required Uint8List bytes,
  }) async {
    return avatarPhotoRelativePathFor(expression);
  }
}
