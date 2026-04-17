import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/features/home/data/home_catalog_repository.dart';
import 'package:kids_play_app/features/home/presentation/home_category_config.dart';

void main() {
  test('resolve centralizes accent metadata for built-in categories', () {
    const hangulCategory = HomeCategory(
      id: 'hangul',
      label: '한글',
      description: '자음과 모음을 만나요',
      backgroundColorHex: '#FFE699',
      iconName: 'text_fields_rounded',
    );
    const alphabetCategory = HomeCategory(
      id: 'alphabet',
      label: '알파벳',
      description: '대문자와 소문자를 만나요',
      backgroundColorHex: '#B9F4D0',
      iconName: 'abc_rounded',
    );
    const numbersCategory = HomeCategory(
      id: 'numbers',
      label: '숫자',
      description: '숫자 놀이를 시작해요',
      backgroundColorHex: '#FFC6D9',
      iconName: 'looks_one_rounded',
    );

    expect(
      HomeCategoryConfig.resolve(hangulCategory).accentColor,
      KidPalette.yellowDark,
    );
    expect(
      HomeCategoryConfig.resolve(alphabetCategory).accentColor,
      KidPalette.blue,
    );
    expect(
      HomeCategoryConfig.resolve(numbersCategory).accentColor,
      KidPalette.coralDark,
    );
  });

  test(
    'uses Korean fallback copy and accent metadata for unknown categories',
    () {
      const customCategory = HomeCategory(
        id: 'vehicles',
        label: '자동차',
        description: '차를 골라요',
        backgroundColorHex: '#CCE2FF',
        iconName: 'extension_rounded',
      );

      final config = HomeCategoryConfig.resolve(customCategory);

      expect(config.badgeText, '놀이');
      expect(config.stickerText, '놀이');
      expect(config.accentColor, KidPalette.navy);
    },
  );
}
