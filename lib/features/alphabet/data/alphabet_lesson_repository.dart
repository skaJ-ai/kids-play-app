import 'dart:convert';

import 'package:flutter/services.dart';

class AlphabetLessonRepository {
  AlphabetLessonRepository({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  static const manifestPath = 'assets/generated/manifest/alphabet_lessons.json';

  final AssetBundle _assetBundle;

  Future<AlphabetLesson> loadLesson(String lessonId) async {
    final jsonString = await _assetBundle.loadString(manifestPath);
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    final lessons = (jsonMap['lessons'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    final lessonJson = lessons.firstWhere(
      (lesson) => lesson['id'] == lessonId,
      orElse: () => throw StateError('Missing alphabet lesson: $lessonId'),
    );

    return AlphabetLesson.fromJson(lessonJson);
  }
}

class AlphabetLesson {
  const AlphabetLesson({
    required this.id,
    required this.title,
    required this.cards,
  });

  factory AlphabetLesson.fromJson(Map<String, dynamic> json) {
    final cards = (json['cards'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    return AlphabetLesson(
      id: json['id'] as String,
      title: json['title'] as String,
      cards: cards.map(AlphabetCard.fromJson).toList(growable: false),
    );
  }

  final String id;
  final String title;
  final List<AlphabetCard> cards;
}

class AlphabetCard {
  const AlphabetCard({
    required this.symbol,
    required this.label,
    required this.hint,
  });

  factory AlphabetCard.fromJson(Map<String, dynamic> json) {
    return AlphabetCard(
      symbol: json['symbol'] as String,
      label: json['label'] as String,
      hint: json['hint'] as String,
    );
  }

  final String symbol;
  final String label;
  final String hint;
}
