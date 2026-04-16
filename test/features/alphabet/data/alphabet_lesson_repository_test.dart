import 'dart:convert';
import 'dart:io';

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

  test(
    'ships matching public and generated alphabet manifests with a playable first lesson',
    () async {
      final publicManifest = File(
        'assets/public/manifest/alphabet_lessons.json',
      );
      final generatedManifest = File(
        'assets/generated/manifest/alphabet_lessons.json',
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
        (lesson) => lesson['id'] == 'alphabet_letters_1',
      );
      final cards = (firstLesson['cards'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      expect(cards, hasLength(greaterThanOrEqualTo(5)));
      expect(
        cards.take(5).map((card) => card['symbol']).toList(growable: false),
        ['A a', 'B b', 'C c', 'D d', 'E e'],
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
