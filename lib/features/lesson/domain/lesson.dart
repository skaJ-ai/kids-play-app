import 'package:flutter/foundation.dart';

@immutable
class LessonItem {
  const LessonItem({
    required this.symbol,
    required this.label,
    required this.hint,
  });

  factory LessonItem.fromJson(Map<String, dynamic> json) {
    return LessonItem(
      symbol: json['symbol'] as String,
      label: json['label'] as String,
      hint: json['hint'] as String,
    );
  }

  final String symbol;
  final String label;
  final String hint;

  @override
  bool operator ==(Object other) =>
      other is LessonItem &&
      other.symbol == symbol &&
      other.label == label &&
      other.hint == hint;

  @override
  int get hashCode => Object.hash(symbol, label, hint);
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
