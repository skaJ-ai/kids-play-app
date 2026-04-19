import 'dart:io';
import 'dart:typed_data';

import 'package:kids_play_app/features/avatar/data/avatar_photo_repository.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_expression.dart';
import 'package:path/path.dart' as path;

class LocalAvatarPhotoRepository implements AvatarPhotoRepository {
  LocalAvatarPhotoRepository(this._rootDirectory);

  final Future<Directory> Function() _rootDirectory;

  @override
  Future<String> saveExpressionPhoto({
    required AvatarExpression expression,
    required Uint8List bytes,
  }) async {
    final relativePath = avatarPhotoRelativePathFor(expression);
    final file = await _fileFor(relativePath);
    if (file == null) {
      throw StateError('Generated avatar photo path escaped the root directory.');
    }

    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    return relativePath;
  }

  @override
  Future<File?> resolveFile(String relativePath) async {
    final file = await _fileFor(relativePath);
    if (file == null) {
      return null;
    }
    if (await file.exists()) {
      return file;
    }

    return null;
  }

  @override
  Future<void> deletePhoto(String relativePath) async {
    final file = await _fileFor(relativePath);
    if (file == null) {
      return;
    }
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File?> _fileFor(String relativePath) async {
    if (path.isAbsolute(relativePath)) {
      return null;
    }

    final root = await _rootDirectory();
    final rootPath = path.normalize(root.path);
    final resolvedPath = path.normalize(path.join(rootPath, relativePath));
    if (!path.isWithin(rootPath, resolvedPath)) {
      return null;
    }

    return File(resolvedPath);
  }
}
