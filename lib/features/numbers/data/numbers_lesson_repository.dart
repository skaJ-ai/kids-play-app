import 'dart:convert';

import 'package:flutter/services.dart';

class NumbersLessonRepository {
  NumbersLessonRepository({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  static const manifestPath = 'assets/generated/manifest/numbers_lessons.json';

  final AssetBundle _assetBundle;

  Future<NumbersLesson> loadLesson(String lessonId) async {
    final jsonString = await _assetBundle.loadString(manifestPath);
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    final lessons = (jsonMap['lessons'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    final lessonJson = lessons.firstWhere(
      (lesson) => lesson['id'] == lessonId,
      orElse: () => throw StateError('Missing numbers lesson: $lessonId'),
    );

    return NumbersLesson.fromJson(lessonJson);
  }
}

class NumbersLesson {
  const NumbersLesson({
    required this.id,
    required this.title,
    required this.cards,
  });

  factory NumbersLesson.fromJson(Map<String, dynamic> json) {
    final cards = (json['cards'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    return NumbersLesson(
      id: json['id'] as String,
      title: json['title'] as String,
      cards: cards.map(NumbersCard.fromJson).toList(growable: false),
    );
  }

  final String id;
  final String title;
  final List<NumbersCard> cards;
}

class NumbersCard {
  const NumbersCard({
    required this.symbol,
    required this.label,
    required this.hint,
  });

  factory NumbersCard.fromJson(Map<String, dynamic> json) {
    return NumbersCard(
      symbol: json['symbol'] as String,
      label: json['label'] as String,
      hint: json['hint'] as String,
    );
  }

  final String symbol;
  final String label;
  final String hint;
}
