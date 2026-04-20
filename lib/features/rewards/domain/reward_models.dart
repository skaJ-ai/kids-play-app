import 'package:flutter/foundation.dart';

@immutable
class Reward {
  const Reward({
    required this.id,
    required this.packId,
    required this.categoryId,
    required this.lessonId,
    required this.label,
    required this.emoji,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final packId = json['packId'];
    final categoryId = json['categoryId'];
    final lessonId = json['lessonId'];
    final label = json['label'];
    final emoji = json['emoji'];
    if (id is! String ||
        packId is! String ||
        categoryId is! String ||
        lessonId is! String ||
        label is! String ||
        emoji is! String) {
      throw const FormatException('Invalid reward payload.');
    }
    return Reward(
      id: id,
      packId: packId,
      categoryId: categoryId,
      lessonId: lessonId,
      label: label,
      emoji: emoji,
    );
  }

  final String id;
  final String packId;
  final String categoryId;
  final String lessonId;
  final String label;
  final String emoji;

  Map<String, dynamic> toJson() => {
    'id': id,
    'packId': packId,
    'categoryId': categoryId,
    'lessonId': lessonId,
    'label': label,
    'emoji': emoji,
  };

  @override
  bool operator ==(Object other) => other is Reward && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class RewardPack {
  const RewardPack({
    required this.id,
    required this.categoryId,
    required this.label,
    required this.rewards,
  });

  final String id;
  final String categoryId;
  final String label;
  final List<Reward> rewards;

  Reward? rewardFor(String lessonId) {
    for (final reward in rewards) {
      if (reward.lessonId == lessonId) return reward;
    }
    return null;
  }
}

@immutable
class RewardEvent {
  const RewardEvent({
    required this.at,
    required this.reward,
    required this.lessonId,
  });

  factory RewardEvent.fromJson(Map<String, dynamic> json) {
    final at = json['at'];
    final lessonId = json['lessonId'];
    final rewardJson = json['reward'];
    if (at is! String || lessonId is! String || rewardJson is! Map) {
      throw const FormatException('Invalid reward event payload.');
    }
    final parsedAt = DateTime.tryParse(at);
    if (parsedAt == null) {
      throw const FormatException('Invalid reward event payload.');
    }
    return RewardEvent(
      at: parsedAt,
      lessonId: lessonId,
      reward: Reward.fromJson(Map<String, dynamic>.from(rewardJson)),
    );
  }

  final DateTime at;
  final Reward reward;
  final String lessonId;

  Map<String, dynamic> toJson() => {
    'at': at.toIso8601String(),
    'lessonId': lessonId,
    'reward': reward.toJson(),
  };
}
