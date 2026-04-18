import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/features/lesson/domain/lesson.dart';
import 'package:kids_play_app/features/lesson/domain/quiz_rules.dart';

void main() {
  group('earnedSticker', () {
    test('returns false when total is zero', () {
      expect(earnedSticker(0, 0), isFalse);
    });

    test('requires ceil(total * 0.8) correct answers', () {
      // ceil(5 * 0.8) = 4
      expect(earnedSticker(3, 5), isFalse);
      expect(earnedSticker(4, 5), isTrue);
      // ceil(4 * 0.8) = 4 → perfect run required
      expect(earnedSticker(3, 4), isFalse);
      expect(earnedSticker(4, 4), isTrue);
    });
  });

  group('resolveQuizQuestions', () {
    final items = [
      const LessonItem(symbol: 'A', label: '', hint: ''),
      const LessonItem(symbol: 'B', label: '', hint: ''),
      const LessonItem(symbol: 'C', label: '', hint: ''),
    ];

    test('returns the full deck when no mistake symbols are supplied', () {
      expect(resolveQuizQuestions(items), items);
      expect(resolveQuizQuestions(items, mistakeSymbols: const []), items);
    });

    test('keeps only items whose symbol is in the mistake list', () {
      final filtered = resolveQuizQuestions(
        items,
        mistakeSymbols: const ['B', 'C'],
      );
      expect(filtered.map((item) => item.symbol), ['B', 'C']);
    });

    test('preserves the provided mistake symbol order', () {
      final filtered = resolveQuizQuestions(
        items,
        mistakeSymbols: const ['C', 'A'],
      );
      expect(filtered.map((item) => item.symbol), ['C', 'A']);
    });

    test(
      'ignores missing and duplicate mistake symbols without reordering',
      () {
        final filtered = resolveQuizQuestions(
          items,
          mistakeSymbols: const ['C', 'Z', 'A', 'C'],
        );
        expect(filtered.map((item) => item.symbol), ['C', 'A']);
      },
    );

    test('returns an empty list when no symbols match', () {
      final filtered = resolveQuizQuestions(items, mistakeSymbols: const ['Z']);
      expect(filtered, isEmpty);
    });
  });

  group('buildChoices', () {
    final items = [
      const LessonItem(symbol: 'A', label: '', hint: ''),
      const LessonItem(symbol: 'B', label: '', hint: ''),
      const LessonItem(symbol: 'C', label: '', hint: ''),
      const LessonItem(symbol: 'D', label: '', hint: ''),
      const LessonItem(symbol: 'E', label: '', hint: ''),
    ];

    test('returns exactly four choices including the answer', () {
      for (var i = 0; i < 4; i++) {
        final choices = buildChoices(items, items[0], i);
        expect(choices, hasLength(4));
        expect(choices.where((c) => c.symbol == 'A'), hasLength(1));
      }
    });

    test('places the answer in a rotating slot by question index', () {
      expect(buildChoices(items, items[0], 0).first.symbol, 'A');
      expect(buildChoices(items, items[0], 1)[1].symbol, 'A');
      expect(buildChoices(items, items[0], 2)[2].symbol, 'A');
      expect(buildChoices(items, items[0], 3)[3].symbol, 'A');
    });

    test('returns only the answer when no distractors exist', () {
      final single = [const LessonItem(symbol: 'X', label: '', hint: '')];
      final choices = buildChoices(single, single.first, 0);
      expect(choices.map((c) => c.symbol), ['X']);
    });
  });
}
