import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/features/avatar/data/avatar_photo_store.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_expression.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_photo_entry.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_photo_snapshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'stores avatar photo metadata and reloads it from the dedicated avatar key',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final store = AvatarPhotoStore(preferences);
      final smileUpdatedAt = DateTime.utc(2026, 4, 19, 11, 30, 45);
      final sadUpdatedAt = DateTime.utc(2026, 4, 19, 11, 32, 10);

      await store.saveSnapshot(
        AvatarPhotoSnapshot(
          entries: {
            AvatarExpression.smile: AvatarPhotoEntry(
              expression: AvatarExpression.smile,
              relativePath: 'avatars/smile.png',
              updatedAt: smileUpdatedAt,
            ),
            AvatarExpression.sad: AvatarPhotoEntry(
              expression: AvatarExpression.sad,
              relativePath: 'avatars/sad.png',
              updatedAt: sadUpdatedAt,
            ),
          },
        ),
      );

      final raw = preferences.getString(AvatarPhotoStore.storageKey);
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      final reloaded = await store.loadSnapshot();

      expect(preferences.containsKey(AvatarPhotoStore.storageKey), isTrue);
      expect(
        preferences.containsKey(SharedPreferencesProgressStore.storageKey),
        isFalse,
      );
      expect(decoded['entries'], hasLength(2));

      final smileEntry = reloaded.entryFor(AvatarExpression.smile);
      final sadEntry = reloaded.entryFor(AvatarExpression.sad);

      expect(smileEntry?.relativePath, 'avatars/smile.png');
      expect(smileEntry?.updatedAt, smileUpdatedAt);
      expect(sadEntry?.relativePath, 'avatars/sad.png');
      expect(sadEntry?.updatedAt, sadUpdatedAt);
    },
  );

  test(
    'ignores malformed avatar photo payloads without dropping other saved entries',
    () async {
      final validSmileUpdatedAt = DateTime.utc(2026, 4, 19, 8, 10, 0);
      final validSurprisedUpdatedAt = DateTime.utc(2026, 4, 19, 8, 11, 0);

      SharedPreferences.setMockInitialValues({
        AvatarPhotoStore.storageKey: jsonEncode({
          'entries': [
            {
              'expression': 'smile',
              'relativePath': 'avatars/smile.png',
              'updatedAt': validSmileUpdatedAt.toIso8601String(),
            },
            {
              'expression': 'sad',
              'relativePath': 123,
              'updatedAt': validSmileUpdatedAt.toIso8601String(),
            },
            {
              'expression': 'neutral',
              'relativePath': '   ',
              'updatedAt': validSmileUpdatedAt.toIso8601String(),
            },
            {
              'expression': 'angry',
              'relativePath': 'avatars/angry.png',
              'updatedAt': 'not-a-date',
            },
            {
              'expression': 'not-real',
              'relativePath': 'avatars/ghost.png',
              'updatedAt': validSmileUpdatedAt.toIso8601String(),
            },
            'broken-entry',
            {
              'expression': 'surprised',
              'relativePath': 'avatars/surprised.png',
              'updatedAt': validSurprisedUpdatedAt.toIso8601String(),
            },
          ],
        }),
      });

      final preferences = await SharedPreferences.getInstance();
      final store = AvatarPhotoStore(preferences);

      final snapshot = await store.loadSnapshot();

      expect(snapshot.entries.keys.toSet(), {
        AvatarExpression.smile,
        AvatarExpression.surprised,
      });
      expect(
        snapshot.entryFor(AvatarExpression.smile)?.relativePath,
        'avatars/smile.png',
      );
      expect(
        snapshot.entryFor(AvatarExpression.smile)?.updatedAt,
        validSmileUpdatedAt,
      );
      expect(snapshot.entryFor(AvatarExpression.sad), isNull);
      expect(snapshot.entryFor(AvatarExpression.neutral), isNull);
      expect(snapshot.entryFor(AvatarExpression.angry), isNull);
      expect(
        snapshot.entryFor(AvatarExpression.surprised)?.relativePath,
        'avatars/surprised.png',
      );
      expect(
        snapshot.entryFor(AvatarExpression.surprised)?.updatedAt,
        validSurprisedUpdatedAt,
      );
    },
  );

  test(
    'progress reset leaves avatar photo metadata intact because it uses a separate key',
    () async {
      SharedPreferences.setMockInitialValues({
        SharedPreferencesProgressStore.storageKey: jsonEncode({
          'stickerCount': 3,
        }),
      });

      final preferences = await SharedPreferences.getInstance();
      final avatarStore = AvatarPhotoStore(preferences);
      final progressStore = SharedPreferencesProgressStore(preferences);
      final updatedAt = DateTime.utc(2026, 4, 19, 9, 0, 0);

      await avatarStore.saveSnapshot(
        AvatarPhotoSnapshot(
          entries: {
            AvatarExpression.neutral: AvatarPhotoEntry(
              expression: AvatarExpression.neutral,
              relativePath: 'avatars/neutral.png',
              updatedAt: updatedAt,
            ),
          },
        ),
      );

      await progressStore.reset();

      final avatarSnapshot = await avatarStore.loadSnapshot();

      expect(
        preferences.containsKey(SharedPreferencesProgressStore.storageKey),
        isFalse,
      );
      expect(preferences.containsKey(AvatarPhotoStore.storageKey), isTrue);
      expect(
        avatarSnapshot.entryFor(AvatarExpression.neutral)?.relativePath,
        'avatars/neutral.png',
      );
      expect(
        avatarSnapshot.entryFor(AvatarExpression.neutral)?.updatedAt,
        updatedAt,
      );
    },
  );
}
