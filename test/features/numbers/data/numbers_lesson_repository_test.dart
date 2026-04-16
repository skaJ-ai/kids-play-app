import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/features/numbers/data/numbers_lesson_repository.dart';

void main() {
  test('loads a numbers lesson and its cards from manifest json', () async {
    final repository = NumbersLessonRepository(
      assetBundle: _FakeAssetBundle({
        NumbersLessonRepository.manifestPath: jsonEncode({
          'lessons': [
            {
              'id': 'numbers_count_1',
              'title': '숫자 1',
              'cards': [
                {
                  'symbol': '1',
                  'label': '하나, 1',
                  'hint': '자동차 한 대를 보며 하나를 말해봐요',
                },
                {'symbol': '2', 'label': '둘, 2', 'hint': '자동차 두 대를 세며 둘을 말해봐요'},
              ],
            },
          ],
        }),
      }),
    );

    final lesson = await repository.loadLesson('numbers_count_1');

    expect(lesson.id, 'numbers_count_1');
    expect(lesson.title, '숫자 1');
    expect(lesson.cards, hasLength(2));
    expect(lesson.cards.first.symbol, '1');
    expect(lesson.cards.first.label, '하나, 1');
    expect(lesson.cards.last.symbol, '2');
  });

  test(
    'ships matching public and generated numbers manifests with a playable first lesson',
    () async {
      final publicManifest = File(
        'assets/public/manifest/numbers_lessons.json',
      );
      final generatedManifest = File(
        'assets/generated/manifest/numbers_lessons.json',
      );

      expect(await publicManifest.exists(), isTrue);
      expect(await generatedManifest.exists(), isTrue);

      final publicJson =
          jsonDecode(await publicManifest.readAsString())
              as Map<String, dynamic>;
      final generatedJson =
          jsonDecode(await generatedManifest.readAsString())
              as Map<String, dynamic>;

      expect(generatedJson, publicJson);

      final lessons = (generatedJson['lessons'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final firstLesson = lessons.firstWhere(
        (lesson) => lesson['id'] == 'numbers_count_1',
      );
      final cards = (firstLesson['cards'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      expect(cards, hasLength(greaterThanOrEqualTo(5)));
      expect(
        cards.take(5).map((card) => card['symbol']).toList(growable: false),
        ['1', '2', '3', '4', '5'],
      );
    },
  );
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
