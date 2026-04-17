import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/theme/design_tokens.dart';

void main() {
  test('spacing scale is monotonically increasing', () {
    expect(Space.xs < Space.s, isTrue);
    expect(Space.s < Space.m, isTrue);
    expect(Space.m < Space.l, isTrue);
    expect(Space.l < Space.xl, isTrue);
    expect(Space.xl < Space.xxl, isTrue);
  });

  test('opacity steps stay within the 0..1 range', () {
    const steps = [Opac.faint, Opac.subtle, Opac.muted, Opac.strong, Opac.solid];
    for (final value in steps) {
      expect(value, greaterThan(0.0));
      expect(value, lessThanOrEqualTo(1.0));
    }
    for (var i = 1; i < steps.length; i++) {
      expect(steps[i - 1] < steps[i], isTrue,
          reason: 'opacity step $i should be strictly larger than ${i - 1}');
    }
  });

  test('motion steps are monotonically increasing', () {
    expect(Motion.instant < Motion.fast, isTrue);
    expect(Motion.fast < Motion.base, isTrue);
    expect(Motion.base < Motion.slow, isTrue);
    expect(Motion.slow < Motion.slower, isTrue);
  });
}
