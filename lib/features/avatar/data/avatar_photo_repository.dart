import 'dart:io';
import 'dart:typed_data';

import 'package:kids_play_app/features/avatar/domain/avatar_expression.dart';

String avatarPhotoRelativePathFor(AvatarExpression expression) {
  return 'avatar_photos/${expression.name}.png';
}

abstract class AvatarPhotoRepository {
  Future<String> saveExpressionPhoto({
    required AvatarExpression expression,
    required Uint8List bytes,
  });

  Future<File?> resolveFile(String relativePath);

  Future<void> deletePhoto(String relativePath);
}

class NoopAvatarPhotoRepository implements AvatarPhotoRepository {
  const NoopAvatarPhotoRepository();

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
