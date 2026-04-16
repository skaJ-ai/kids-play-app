import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/features/alphabet/data/alphabet_lesson_repository.dart';

void main() {
  test('loads an alphabet lesson and its cards from manifest json', () async {
    final repository = AlphabetLessonRepository(
      assetBundle: _FakeAssetBundle({
        AlphabetLessonRepository.manifestPath: jsonEncode({
          'lessons': [
            {
              'id': 'alphabet_letters_1',
              'title': '알파벳 1',
              'cards': [
                {
                  'symbol': 'A a',
                  'label': '에이, A a',
                  'hint': '에이를 크게 보고 소리를 따라 말해봐요',
                },
                {
                  'symbol': 'B b',
                  'label': '비, B b',
                  'hint': '비를 보며 입으로 비 하고 말해봐요',
                },
              ],
            },
          ],
        }),
      }),
    );

    final lesson = await repository.loadLesson('alphabet_letters_1');

    expect(lesson.id, 'alphabet_letters_1');
    expect(lesson.title, '알파벳 1');
    expect(lesson.cards, hasLength(2));
    expect(lesson.cards.first.symbol, 'A a');
    expect(lesson.cards.first.label, '에이, A a');
    expect(lesson.cards.last.symbol, 'B b');
  });
}

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this._assets);

  final Map<String, String> _assets;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = _assets[key];
    if (value == null) {
      throw Exception('Missing fake asset for $key');
    }
    return value;
  }

  @override
  Future<ByteData> load(String key) async {
    final string = await loadString(key);
    final bytes = Uint8List.fromList(utf8.encode(string));
    return ByteData.view(bytes.buffer);
  }
}
