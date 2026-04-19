import 'package:kids_play_app/features/avatar/domain/avatar_expression.dart';

class AvatarPhotoEntry {
  const AvatarPhotoEntry({
    required this.expression,
    required this.relativePath,
    required this.updatedAt,
  });

  factory AvatarPhotoEntry.fromJson(Map<String, dynamic> json) {
    final expression = json['expression'];
    final relativePath = json['relativePath'];
    final updatedAt = json['updatedAt'];

    if (expression is! String ||
        relativePath is! String ||
        relativePath.trim().isEmpty ||
        updatedAt is! String) {
      throw const FormatException('Invalid avatar photo payload.');
    }

    final parsedUpdatedAt = DateTime.tryParse(updatedAt);
    if (parsedUpdatedAt == null) {
      throw const FormatException('Invalid avatar photo payload.');
    }

    final parsedExpression = _parseExpression(expression);

    return AvatarPhotoEntry(
      expression: parsedExpression,
      relativePath: relativePath.trim(),
      updatedAt: parsedUpdatedAt,
    );
  }

  final AvatarExpression expression;
  final String relativePath;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'expression': expression.name,
      'relativePath': relativePath,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

AvatarExpression _parseExpression(String value) {
  try {
    return AvatarExpression.values.byName(value);
  } on ArgumentError {
    throw const FormatException('Invalid avatar photo payload.');
  }
}
