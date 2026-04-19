import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/features/avatar/data/avatar_photo_store.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_expression.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_photo_entry.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_photo_snapshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

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
      final smileUpdatedAt = DateTime.utc(2026, 4, 20, 4, 30, 45);
      final sadUpdatedAt = DateTime.utc(2026, 4, 20, 4, 32, 10);

      await store.saveSnapshot(
        AvatarPhotoSnapshot(
          entries: {
            AvatarExpression.smile: AvatarPhotoEntry(
              expression: AvatarExpression.smile,
              relativePath: 'avatar_photos/smile.png',
              updatedAt: smileUpdatedAt,
            ),
            AvatarExpression.sad: AvatarPhotoEntry(
              expression: AvatarExpression.sad,
              relativePath: 'avatar_photos/sad.png',
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

      expect(smileEntry?.relativePath, 'avatar_photos/smile.png');
      expect(smileEntry?.updatedAt, smileUpdatedAt);
      expect(sadEntry?.relativePath, 'avatar_photos/sad.png');
      expect(sadEntry?.updatedAt, sadUpdatedAt);
    },
  );

  test(
    'throws when SharedPreferences rejects an avatar photo snapshot write',
    () async {
      SharedPreferencesStorePlatform.instance =
          _RejectingSharedPreferencesStore();

      final preferences = await SharedPreferences.getInstance();
      final store = AvatarPhotoStore(preferences);

      await expectLater(
        store.saveSnapshot(
          AvatarPhotoSnapshot(
            entries: {
              AvatarExpression.smile: AvatarPhotoEntry(
                expression: AvatarExpression.smile,
                relativePath: 'avatar_photos/smile.png',
                updatedAt: DateTime.utc(2026, 4, 20, 4, 45, 0),
              ),
            },
          ),
        ),
        throwsA(isA<StateError>()),
      );
    },
  );

  test(
    'rejected avatar photo writes are not visible from loadSnapshot on the same SharedPreferences instance',
    () async {
      SharedPreferencesStorePlatform.instance =
          _RejectingSharedPreferencesStore();

      final preferences = await SharedPreferences.getInstance();
      final store = AvatarPhotoStore(preferences);
      final rejectedSnapshot = AvatarPhotoSnapshot(
        entries: {
          AvatarExpression.smile: AvatarPhotoEntry(
            expression: AvatarExpression.smile,
            relativePath: 'avatar_photos/smile.png',
            updatedAt: DateTime.utc(2026, 4, 20, 4, 45, 0),
          ),
        },
      );

      await expectLater(
        store.saveSnapshot(rejectedSnapshot),
        throwsA(isA<StateError>()),
      );

      final reloaded = await store.loadSnapshot();

      expect(reloaded.entries, isEmpty);
    },
  );

  test(
    'thrown avatar photo writes restore the last persisted snapshot on the same SharedPreferences instance',
    () async {
      final persistedUpdatedAt = DateTime.utc(2026, 4, 20, 4, 44, 0);
      final rejectedUpdatedAt = DateTime.utc(2026, 4, 20, 4, 45, 0);
      final persistedSnapshot = AvatarPhotoSnapshot(
        entries: {
          AvatarExpression.sad: AvatarPhotoEntry(
            expression: AvatarExpression.sad,
            relativePath: 'avatar_photos/persisted-sad.png',
            updatedAt: persistedUpdatedAt,
          ),
        },
      );

      SharedPreferencesStorePlatform.instance =
          _ThrowingSharedPreferencesStore.withData({
            'flutter.${AvatarPhotoStore.storageKey}': jsonEncode(
              persistedSnapshot.toJson(),
            ),
          });

      final preferences = await SharedPreferences.getInstance();
      final store = AvatarPhotoStore(preferences);

      await expectLater(
        store.saveSnapshot(
          AvatarPhotoSnapshot(
            entries: {
              AvatarExpression.smile: AvatarPhotoEntry(
                expression: AvatarExpression.smile,
                relativePath: 'avatar_photos/rejected-smile.png',
                updatedAt: rejectedUpdatedAt,
              ),
            },
          ),
        ),
        throwsA(isA<UnsupportedError>()),
      );

      final reloaded = await store.loadSnapshot();

      expect(reloaded.entries.keys.toSet(), {AvatarExpression.sad});
      expect(
        reloaded.entryFor(AvatarExpression.sad)?.relativePath,
        'avatar_photos/persisted-sad.png',
      );
      expect(
        reloaded.entryFor(AvatarExpression.sad)?.updatedAt,
        persistedUpdatedAt,
      );
      expect(reloaded.entryFor(AvatarExpression.smile), isNull);
    },
  );

  test(
    'ignores malformed avatar photo payloads without dropping other saved entries',
    () async {
      final validSmileUpdatedAt = DateTime.utc(2026, 4, 20, 4, 40, 0);
      final validSurprisedUpdatedAt = DateTime.utc(2026, 4, 20, 4, 41, 0);

      SharedPreferences.setMockInitialValues({
        AvatarPhotoStore.storageKey: jsonEncode({
          'entries': [
            {
              'expression': 'smile',
              'relativePath': 'avatar_photos/smile.png',
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
              'relativePath': 'avatar_photos/angry.png',
              'updatedAt': 'not-a-date',
            },
            {
              'expression': 'not-real',
              'relativePath': 'avatar_photos/ghost.png',
              'updatedAt': validSmileUpdatedAt.toIso8601String(),
            },
            'broken-entry',
            {
              'expression': 'surprised',
              'relativePath': 'avatar_photos/surprised.png',
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
        'avatar_photos/smile.png',
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
        'avatar_photos/surprised.png',
      );
      expect(
        snapshot.entryFor(AvatarExpression.surprised)?.updatedAt,
        validSurprisedUpdatedAt,
      );
    },
  );
}

class _RejectingSharedPreferencesStore extends InMemorySharedPreferencesStore {
  _RejectingSharedPreferencesStore() : super.empty();

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;
}

class _ThrowingSharedPreferencesStore extends InMemorySharedPreferencesStore {
  _ThrowingSharedPreferencesStore.withData(super.data) : super.withData();

  @override
  Future<bool> setValue(String valueType, String key, Object value) =>
      Future<bool>.error(
        UnsupportedError('Simulated avatar photo write failure.'),
      );
}
