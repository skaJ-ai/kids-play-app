import 'dart:io';
import 'dart:typed_data';

import 'package:kids_play_app/features/avatar/data/avatar_photo_repository.dart';
import 'package:kids_play_app/features/avatar/data/avatar_photo_store.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_expression.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_photo_entry.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_photo_snapshot.dart';

class AvatarPhotoService {
  AvatarPhotoService({
    required AvatarPhotoStore photoStore,
    required AvatarPhotoRepository repository,
    DateTime Function()? now,
  }) : _photoStore = photoStore,
       _repository = repository,
       _now = now ?? DateTime.now;

  final AvatarPhotoStore _photoStore;
  final AvatarPhotoRepository _repository;
  final DateTime Function() _now;

  Future<AvatarPhotoSnapshot> loadSnapshot() async {
    return _photoStore.loadSnapshot();
  }

  Future<File?> resolvePhotoFile(AvatarExpression expression) async {
    final snapshot = await _photoStore.loadSnapshot();
    final entry = snapshot.entryFor(expression);
    if (entry == null) {
      return null;
    }

    return _repository.resolveFile(entry.relativePath);
  }

  Future<File?> resolveBestPhoto(Iterable<AvatarExpression> expressions) async {
    final snapshot = await _photoStore.loadSnapshot();

    for (final expression in expressions) {
      final entry = snapshot.entryFor(expression);
      if (entry == null) {
        continue;
      }

      final file = await _repository.resolveFile(entry.relativePath);
      if (file != null) {
        return file;
      }
    }

    return null;
  }

  Future<void> saveExpressionPhoto({
    required AvatarExpression expression,
    required Uint8List bytes,
  }) async {
    final relativePath = await _repository.saveExpressionPhoto(
      expression: expression,
      bytes: bytes,
    );
    final snapshot = await _photoStore.loadSnapshot();
    final nextEntries =
        Map<AvatarExpression, AvatarPhotoEntry>.from(snapshot.entries)
          ..[expression] = AvatarPhotoEntry(
            expression: expression,
            relativePath: relativePath,
            updatedAt: _now(),
          );

    await _photoStore.saveSnapshot(AvatarPhotoSnapshot(entries: nextEntries));
  }

  Future<void> clearExpression(AvatarExpression expression) async {
    final snapshot = await _photoStore.loadSnapshot();
    final entry = snapshot.entryFor(expression);
    if (entry == null) {
      return;
    }

    await _repository.deletePhoto(entry.relativePath);

    final nextEntries = Map<AvatarExpression, AvatarPhotoEntry>.from(
      snapshot.entries,
    )..remove(expression);
    await _photoStore.saveSnapshot(AvatarPhotoSnapshot(entries: nextEntries));
  }

  Future<void> clearAll() async {
    final snapshot = await _photoStore.loadSnapshot();

    for (final entry in snapshot.entries.values) {
      await _repository.deletePhoto(entry.relativePath);
    }

    await _photoStore.saveSnapshot(const AvatarPhotoSnapshot());
  }
}
