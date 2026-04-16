import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/features/home/data/home_catalog_repository.dart';

void main() {
  test('loads home categories from manifest json', () async {
    final repository = HomeCatalogRepository(
      assetBundle: _FakeAssetBundle({
        'assets/generated/manifest/home_categories.json': jsonEncode({
          'categories': [
            {
              'id': 'hangul',
              'label': '한글',
              'description': '자음과 모음을 만나요',
              'backgroundColor': '#FFE699',
              'icon': 'text_fields_rounded',
            },
            {
              'id': 'alphabet',
              'label': '알파벳',
              'description': '대문자와 소문자를 만나요',
              'backgroundColor': '#B9F4D0',
              'icon': 'abc_rounded',
            },
            {
              'id': 'numbers',
              'label': '숫자',
              'description': '숫자 놀이를 시작해요',
              'backgroundColor': '#FFC6D9',
              'icon': 'looks_one_rounded',
            },
          ],
        }),
      }),
    );

    final categories = await repository.loadCategories();

    expect(categories, hasLength(3));
    expect(categories.first.id, 'hangul');
    expect(categories.first.label, '한글');
    expect(categories.first.description, '자음과 모음을 만나요');
    expect(categories.first.backgroundColorHex, '#FFE699');
    expect(categories.first.iconName, 'text_fields_rounded');
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
