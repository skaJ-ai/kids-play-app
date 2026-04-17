import 'dart:convert';
import 'dart:io';

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
  test('loads all hangul lessons from manifest json in order', () async {
    final repository = HangulLessonRepository(
      assetBundle: _FakeAssetBundle({
        HangulLessonRepository.manifestPath: jsonEncode({
          'lessons': [
            {
              'id': 'basic_consonants_1',
              'title': '기본 자음 1',
              'cards': [
                {'symbol': 'ㄱ', 'label': '기역, ㄱ', 'hint': '기역을 천천히 봐요'},
                {'symbol': 'ㄴ', 'label': '니은, ㄴ', 'hint': '니은을 천천히 봐요'},
                {'symbol': 'ㄷ', 'label': '디귿, ㄷ', 'hint': '디귿을 천천히 봐요'},
                {'symbol': 'ㄹ', 'label': '리을, ㄹ', 'hint': '리을을 천천히 봐요'},
              ],
            },
            {
              'id': 'basic_consonants_2',
              'title': '기본 자음 2',
              'cards': [
                {'symbol': 'ㅂ', 'label': '비읍, ㅂ', 'hint': '비읍을 천천히 봐요'},
                {'symbol': 'ㅅ', 'label': '시옷, ㅅ', 'hint': '시옷을 천천히 봐요'},
                {'symbol': 'ㅇ', 'label': '이응, ㅇ', 'hint': '이응을 천천히 봐요'},
                {'symbol': 'ㅈ', 'label': '지읒, ㅈ', 'hint': '지읒을 천천히 봐요'},
              ],
            },
          ],
        }),
      }),
    );

    final lessons = await repository.loadLessons();

    expect(lessons.map((lesson) => lesson.id).toList(growable: false), [
      'basic_consonants_1',
      'basic_consonants_2',
    ]);
    expect(lessons[1].cards.first.symbol, 'ㅂ');
  });

  test('ships matching public and generated hangul manifests with multiple playable lessons', () async {
    final publicManifest = File('assets/public/manifest/hangul_lessons.json');
    final generatedManifest = File('assets/generated/manifest/hangul_lessons.json');

    expect(await publicManifest.exists(), isTrue);
    expect(await generatedManifest.exists(), isTrue);

    final publicJson = jsonDecode(await publicManifest.readAsString()) as Map<String, dynamic>;
    final generatedJson = jsonDecode(await generatedManifest.readAsString()) as Map<String, dynamic>;

    expect(generatedJson, publicJson);

    final lessons = (generatedJson['lessons'] as List<dynamic>).cast<Map<String, dynamic>>();
    expect(lessons.length, greaterThanOrEqualTo(5));
    expect(
      lessons.take(3).map((lesson) => lesson['id']).toList(growable: false),
      ['basic_consonants_1', 'basic_consonants_2', 'basic_consonants_3'],
    );
    for (final lesson in lessons) {
      final cards = (lesson['cards'] as List<dynamic>).cast<Map<String, dynamic>>();
      expect(cards.length, greaterThanOrEqualTo(4));
    }
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
