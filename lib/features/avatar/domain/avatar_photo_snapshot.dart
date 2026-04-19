import 'package:kids_play_app/features/avatar/domain/avatar_expression.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_photo_entry.dart';

class AvatarPhotoSnapshot {
  const AvatarPhotoSnapshot({this.entries = const {}});

  factory AvatarPhotoSnapshot.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'];
    if (rawEntries is! List) {
      return const AvatarPhotoSnapshot();
    }

    final entries = <AvatarExpression, AvatarPhotoEntry>{};
    for (final rawEntry in rawEntries) {
      if (rawEntry is! Map) {
        continue;
      }

      try {
        final entry = AvatarPhotoEntry.fromJson(
          Map<String, dynamic>.from(rawEntry),
        );
        entries[entry.expression] = entry;
      } catch (_) {
        continue;
      }
    }

    return AvatarPhotoSnapshot(entries: entries);
  }

  final Map<AvatarExpression, AvatarPhotoEntry> entries;

  AvatarPhotoEntry? entryFor(AvatarExpression expression) {
    return entries[expression];
  }

  Map<String, dynamic> toJson() {
    return {
      'version': 1,
      'entries': AvatarExpression.values
          .map((expression) => entries[expression]?.toJson())
          .whereType<Map<String, dynamic>>()
          .toList(growable: false),
    };
  }
}
