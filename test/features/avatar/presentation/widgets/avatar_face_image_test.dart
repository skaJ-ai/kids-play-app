import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/features/avatar/application/avatar_photo_service.dart';
import 'package:kids_play_app/features/avatar/data/avatar_photo_repository.dart';
import 'package:kids_play_app/features/avatar/data/avatar_photo_store.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_expression.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_photo_entry.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_photo_snapshot.dart';
import 'package:kids_play_app/features/avatar/presentation/widgets/avatar_face_image.dart';

void main() {
  testWidgets('resolves a saved avatar photo file when one exists', (
    WidgetTester tester,
  ) async {
    final repository = _TestAvatarPhotoRepository();
    final relativePath = await repository.saveExpressionPhoto(
      expression: AvatarExpression.smile,
      bytes: _heroFacePngBytes,
    );
    final avatarPhotoService = AvatarPhotoService(
      photoStore: _TestAvatarPhotoStore(
        AvatarPhotoSnapshot(
          entries: {
            AvatarExpression.smile: AvatarPhotoEntry(
              expression: AvatarExpression.smile,
              relativePath: relativePath,
              updatedAt: DateTime.utc(2026, 4, 19, 8),
            ),
          },
        ),
      ),
      repository: repository,
    );
    late BuildContext capturedContext;

    await tester.pumpWidget(
      _wrapWithServices(
        avatarPhotoService: avatarPhotoService,
        child: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final resolvedFile = await resolveAvatarFaceFile(
      capturedContext,
      const [AvatarExpression.smile],
    );

    expect(resolvedFile, isNotNull);
    expect(resolvedFile!.path, endsWith('avatar_photos/smile.png'));
  });

  testWidgets('falls back to Image.asset when no saved file exists', (
    WidgetTester tester,
  ) async {
    final avatarPhotoService = AvatarPhotoService(
      photoStore: _TestAvatarPhotoStore(),
      repository: _TestAvatarPhotoRepository(),
    );

    await tester.pumpWidget(
      _wrapWithServices(
        avatarPhotoService: avatarPhotoService,
        child: const AvatarFaceImage(expressions: [AvatarExpression.smile]),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
    expect(
      (image.image as AssetImage).assetName,
      AvatarFaceImage.placeholderAssetPath,
    );
  });
}

Widget _wrapWithServices({
  required AvatarPhotoService avatarPhotoService,
  required Widget child,
}) {
  return AppServicesScope(
    services: AppServices(
      progressStore: MemoryProgressStore(),
      speechCueService: NoopSpeechCueService(),
      avatarPhotoService: avatarPhotoService,
    ),
    child: DefaultAssetBundle(
      bundle: _AvatarTestAssetBundle(),
      child: MaterialApp(
        home: Scaffold(
          body: Center(child: SizedBox(width: 96, height: 96, child: child)),
        ),
      ),
    ),
  );
}

class _AvatarTestAssetBundle extends CachingAssetBundle {
  static const heroFacePath = 'assets/generated/images/hero/hero_face.png';

  @override
  Future<ByteData> load(String key) async {
    if (key == heroFacePath) {
      return ByteData.view(
        _heroFacePngBytes.buffer,
        _heroFacePngBytes.offsetInBytes,
        _heroFacePngBytes.lengthInBytes,
      );
    }
    return rootBundle.load(key);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    return rootBundle.loadString(key, cache: cache);
  }
}

class _TestAvatarPhotoStore implements AvatarPhotoStore {
  _TestAvatarPhotoStore([AvatarPhotoSnapshot? snapshot])
    : snapshot = snapshot ?? const AvatarPhotoSnapshot();

  AvatarPhotoSnapshot snapshot;

  @override
  Future<AvatarPhotoSnapshot> loadSnapshot() async => snapshot;

  @override
  Future<void> saveSnapshot(AvatarPhotoSnapshot snapshot) async {
    this.snapshot = snapshot;
  }
}

class _TestAvatarPhotoRepository implements AvatarPhotoRepository {
  _TestAvatarPhotoRepository();

  @override
  Future<void> deletePhoto(String relativePath) async {}

  @override
  Future<File?> resolveFile(String relativePath) async {
    return File('/virtual/$relativePath');
  }

  @override
  Future<String> saveExpressionPhoto({
    required AvatarExpression expression,
    required Uint8List bytes,
  }) async {
    return avatarPhotoRelativePathFor(expression);
  }
}

final Uint8List _heroFacePngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==',
);
