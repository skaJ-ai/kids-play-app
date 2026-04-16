import 'dart:convert';

import 'package:flutter/services.dart';

class HangulLessonRepository {
  HangulLessonRepository({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  static const manifestPath = 'assets/generated/manifest/hangul_lessons.json';

  final AssetBundle _assetBundle;

  Future<HangulLesson> loadLesson(String lessonId) async {
    final jsonString = await _assetBundle.loadString(manifestPath);
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    final lessons = (jsonMap['lessons'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    final lessonJson = lessons.firstWhere(
      (lesson) => lesson['id'] == lessonId,
      orElse: () => throw StateError('Missing hangul lesson: $lessonId'),
    );

    return HangulLesson.fromJson(lessonJson);
  }
}

class HangulLesson {
  const HangulLesson({
    required this.id,
    required this.title,
    required this.cards,
  });

  factory HangulLesson.fromJson(Map<String, dynamic> json) {
    final cards = (json['cards'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    return HangulLesson(
      id: json['id'] as String,
      title: json['title'] as String,
      cards: cards.map(HangulCard.fromJson).toList(growable: false),
    );
  }

  final String id;
  final String title;
  final List<HangulCard> cards;
}

class HangulCard {
  const HangulCard({
    required this.symbol,
    required this.label,
    required this.hint,
  });

  factory HangulCard.fromJson(Map<String, dynamic> json) {
    return HangulCard(
      symbol: json['symbol'] as String,
      label: json['label'] as String,
      hint: json['hint'] as String,
    );
  }

  final String symbol;
  final String label;
  final String hint;
}
