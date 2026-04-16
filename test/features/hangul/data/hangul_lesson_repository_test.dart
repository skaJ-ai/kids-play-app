import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/features/hangul/data/hangul_lesson_repository.dart';

void main() {
  test('loads a hangul lesson and its cards from manifest json', () async {
    final repository = HangulLessonRepository(
      assetBundle: _FakeAssetBundle({
        'assets/generated/manifest/hangul_lessons.json': jsonEncode({
          'lessons': [
            {
              'id': 'basic_consonants_1',
              'title': '기본 자음 1',
              'cards': [
                {
                  'symbol': 'ㄱ',
                  'label': '기역, ㄱ',
                  'hint': '큰 카드로 기역을 천천히 봐요',
                },
                {
                  'symbol': 'ㄴ',
                  'label': '니은, ㄴ',
                  'hint': '니은을 손가락으로 콕 눌러봐요',
                },
              ],
            },
          ],
        }),
      }),
    );

    final lesson = await repository.loadLesson('basic_consonants_1');

    expect(lesson.id, 'basic_consonants_1');
    expect(lesson.title, '기본 자음 1');
    expect(lesson.cards, hasLength(2));
    expect(lesson.cards.first.symbol, 'ㄱ');
    expect(lesson.cards.first.label, '기역, ㄱ');
    expect(lesson.cards.last.symbol, 'ㄴ');
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
