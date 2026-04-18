import 'package:flutter/foundation.dart';

/// A single card within a lesson.
///
/// Four semantic fields keep identity, visuals, audio, and parent-facing
/// context distinct so a pre-reading child hears the right single word
/// ("에이") rather than the whole card label ("에이, A a").
@immutable
class LessonItem {
  const LessonItem({
    required this.symbol,
    required this.display,
    required this.spoken,
    required this.hint,
  });

  /// Accepts both the new schema (`display` + `spoken`) and legacy manifests
  /// that still use a single `label` field. New manifests omit `label`.
  factory LessonItem.fromJson(Map<String, dynamic> json) {
    final symbol = json['symbol'] as String;
    final legacyLabel = json['label'] as String?;
    return LessonItem(
      symbol: symbol,
      display: (json['display'] as String?) ?? symbol,
      spoken: (json['spoken'] as String?) ?? legacyLabel ?? symbol,
      hint: json['hint'] as String,
    );
  }

  /// Stable identity. Used for quiz matching, progress keys, and logs.
  final String symbol;

  /// Glyph(s) rendered on the learn card and quiz tiles.
  final String display;

  /// Single word passed to TTS. Never a concatenated multi-variant string.
  final String spoken;

  /// Parent-facing context. Not rendered in the child-facing UI.
  final String hint;

  @override
  bool operator ==(Object other) =>
      other is LessonItem &&
      other.symbol == symbol &&
      other.display == display &&
      other.spoken == spoken &&
      other.hint == hint;

  @override
  int get hashCode => Object.hash(symbol, display, spoken, hint);
}

@immutable
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.items,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final items = (json['cards'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      items: items.map(LessonItem.fromJson).toList(growable: false),
    );
  }

  final String id;
  final String title;
  final List<LessonItem> items;
}
