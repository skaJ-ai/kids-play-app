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
  test('loads all alphabet lessons from manifest json in order', () async {
    final repository = AlphabetLessonRepository(
      assetBundle: _FakeAssetBundle({
        AlphabetLessonRepository.manifestPath: jsonEncode({
          'lessons': [
            {
              'id': 'alphabet_letters_1',
              'title': '알파벳 1',
              'cards': [
                {'symbol': 'A a', 'label': '에이, A a', 'hint': 'A를 말해봐요'},
                {'symbol': 'B b', 'label': '비, B b', 'hint': 'B를 말해봐요'},
                {'symbol': 'C c', 'label': '씨, C c', 'hint': 'C를 말해봐요'},
                {'symbol': 'D d', 'label': '디, D d', 'hint': 'D를 말해봐요'},
              ],
            },
            {
              'id': 'alphabet_letters_2',
              'title': '알파벳 2',
              'cards': [
                {'symbol': 'F f', 'label': '에프, F f', 'hint': 'F를 말해봐요'},
                {'symbol': 'G g', 'label': '지, G g', 'hint': 'G를 말해봐요'},
                {'symbol': 'H h', 'label': '에이치, H h', 'hint': 'H를 말해봐요'},
                {'symbol': 'I i', 'label': '아이, I i', 'hint': 'I를 말해봐요'},
              ],
            },
          ],
        }),
      }),
    );

    final lessons = await repository.loadLessons();

    expect(lessons.map((lesson) => lesson.id).toList(growable: false), [
      'alphabet_letters_1',
      'alphabet_letters_2',
    ]);
    expect(lessons[1].cards.first.symbol, 'F f');
  });

  test(
    'ships matching public and generated alphabet manifests with multiple playable lessons',
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
      expect(lessons.length, greaterThanOrEqualTo(5));
      expect(
        lessons.take(3).map((lesson) => lesson['id']).toList(growable: false),
        ['alphabet_letters_1', 'alphabet_letters_2', 'alphabet_letters_3'],
      );
      for (final lesson in lessons) {
        final cards = (lesson['cards'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        expect(cards.length, greaterThanOrEqualTo(4));
      }
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
