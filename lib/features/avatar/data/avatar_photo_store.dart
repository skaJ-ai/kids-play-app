import 'dart:convert';

import 'package:kids_play_app/features/avatar/domain/avatar_photo_snapshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarPhotoStore {
  AvatarPhotoStore(this._preferences);

  static const storageKey = 'avatar_photos_v1';

  final SharedPreferences _preferences;

  Future<AvatarPhotoSnapshot> loadSnapshot() async {
    final raw = _preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const AvatarPhotoSnapshot();
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const AvatarPhotoSnapshot();
      }

      return AvatarPhotoSnapshot.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return const AvatarPhotoSnapshot();
    }
  }

  Future<void> saveSnapshot(AvatarPhotoSnapshot snapshot) async {
    final encodedSnapshot = jsonEncode(snapshot.toJson());

    bool didSave;
    try {
      didSave = await _preferences.setString(storageKey, encodedSnapshot);
    } catch (error, stackTrace) {
      await _preferences.reload();
      Error.throwWithStackTrace(error, stackTrace);
    }

    if (!didSave) {
      await _preferences.reload();
      throw StateError('Failed to save avatar photo snapshot.');
    }
  }
}
