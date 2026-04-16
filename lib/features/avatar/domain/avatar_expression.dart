enum AvatarExpression {
  neutral,
  smile,
  sad,
  angry,
  surprised;

  String get label {
    switch (this) {
      case AvatarExpression.neutral:
        return '보통';
      case AvatarExpression.smile:
        return '웃음';
      case AvatarExpression.sad:
        return '슬픔';
      case AvatarExpression.angry:
        return '화남';
      case AvatarExpression.surprised:
        return '놀람';
    }
  }

  String get shortPrompt {
    switch (this) {
      case AvatarExpression.neutral:
        return '편안한 얼굴';
      case AvatarExpression.smile:
        return '활짝 웃는 얼굴';
      case AvatarExpression.sad:
        return '조금 슬픈 얼굴';
      case AvatarExpression.angry:
        return '화난 얼굴';
      case AvatarExpression.surprised:
        return '깜짝 놀란 얼굴';
    }
  }
}
