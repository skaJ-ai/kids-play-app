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

    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    return relativePath;
  }

  @override
  Future<File?> resolveFile(String relativePath) async {
    final file = await _fileFor(relativePath);
    if (await file.exists()) {
      return file;
    }

    return null;
  }

  @override
  Future<void> deletePhoto(String relativePath) async {
    final file = await _fileFor(relativePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> _fileFor(String relativePath) async {
    final root = await _rootDirectory();
    return File(path.normalize(path.join(root.path, relativePath)));
  }
}
