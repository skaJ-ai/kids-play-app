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
                  'symbol': 'A',
                  'display': 'A',
                  'spoken': '에이',
                  'hint': '에이를 크게 보고 소리를 따라 말해봐요',
                },
                {
                  'symbol': 'B',
                  'display': 'B',
                  'spoken': '비',
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
    expect(lesson.cards.first.symbol, 'A');
    expect(lesson.cards.first.spoken, '에이');
    expect(lesson.cards.first.display, 'A');
    expect(lesson.cards.last.symbol, 'B');
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
        ['A', 'B', 'C', 'D', 'E'],
      );
    },
  );

  test(
    'new manifest carries spoken field with single-word TTS input',
    () async {
      final generatedManifest = File(
        'assets/generated/manifest/alphabet_lessons.json',
      );
      final generatedJson =
          jsonDecode(await generatedManifest.readAsString())
              as Map<String, dynamic>;

      final firstLesson = (generatedJson['lessons'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .firstWhere((lesson) => lesson['id'] == 'alphabet_letters_1');
      final firstCard =
          (firstLesson['cards'] as List<dynamic>).first
              as Map<String, dynamic>;

      // Spoken must be a single word so TTS doesn't read "에이, 에이 에이".
      expect(firstCard['spoken'], '에이');
      expect(firstCard.containsKey('label'), isFalse);
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
                {'symbol': 'A', 'display': 'A', 'spoken': '에이', 'hint': 'A를 말해봐요'},
                {'symbol': 'B', 'display': 'B', 'spoken': '비', 'hint': 'B를 말해봐요'},
                {'symbol': 'C', 'display': 'C', 'spoken': '씨', 'hint': 'C를 말해봐요'},
                {'symbol': 'D', 'display': 'D', 'spoken': '디', 'hint': 'D를 말해봐요'},
              ],
            },
            {
              'id': 'alphabet_letters_2',
              'title': '알파벳 2',
              'cards': [
                {'symbol': 'F', 'display': 'F', 'spoken': '에프', 'hint': 'F를 말해봐요'},
                {'symbol': 'G', 'display': 'G', 'spoken': '지', 'hint': 'G를 말해봐요'},
                {'symbol': 'H', 'display': 'H', 'spoken': '에이치', 'hint': 'H를 말해봐요'},
                {'symbol': 'I', 'display': 'I', 'spoken': '아이', 'hint': 'I를 말해봐요'},
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
    expect(lessons[1].cards.first.symbol, 'F');
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
