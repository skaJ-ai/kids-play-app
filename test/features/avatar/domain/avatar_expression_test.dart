import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_expression.dart';

void main() {
  test('defines the five avatar expressions in the expected order', () {
    expect(AvatarExpression.values, const [
      AvatarExpression.neutral,
      AvatarExpression.smile,
      AvatarExpression.sad,
      AvatarExpression.angry,
      AvatarExpression.surprised,
    ]);

    expect(
      AvatarExpression.values.map((expression) => expression.label).toList(),
      const ['보통', '웃음', '슬픔', '화남', '놀람'],
    );

    expect(
      AvatarExpression.values.map((expression) => expression.shortPrompt).toList(),
      const [
        '편안한 얼굴',
        '활짝 웃는 얼굴',
        '조금 슬픈 얼굴',
        '화난 얼굴',
        '깜짝 놀란 얼굴',
      ],
    );
  });
}
