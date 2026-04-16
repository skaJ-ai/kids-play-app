import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeCatalogRepository {
  HomeCatalogRepository({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  static const manifestPath = 'assets/generated/manifest/home_categories.json';

  final AssetBundle _assetBundle;

  Future<List<HomeCategory>> loadCategories() async {
    final jsonString = await _assetBundle.loadString(manifestPath);
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    final categories = (jsonMap['categories'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    return categories.map(HomeCategory.fromJson).toList(growable: false);
  }
}

class HomeCategory {
  const HomeCategory({
    required this.id,
    required this.label,
    required this.description,
    required this.backgroundColorHex,
    required this.iconName,
  });

  factory HomeCategory.fromJson(Map<String, dynamic> json) {
    return HomeCategory(
      id: json['id'] as String,
      label: json['label'] as String,
      description: json['description'] as String,
      backgroundColorHex: json['backgroundColor'] as String,
      iconName: json['icon'] as String,
    );
  }

  final String id;
  final String label;
  final String description;
  final String backgroundColorHex;
  final String iconName;

  Color get backgroundColor => _colorFromHex(backgroundColorHex);

  IconData get icon {
    switch (iconName) {
      case 'text_fields_rounded':
        return Icons.text_fields_rounded;
      case 'abc_rounded':
        return Icons.abc_rounded;
      case 'looks_one_rounded':
        return Icons.looks_one_rounded;
      default:
        return Icons.extension_rounded;
    }
  }
}

Color _colorFromHex(String hex) {
  final normalized = hex.replaceFirst('#', '');
  final buffer = StringBuffer();
  if (normalized.length == 6) {
    buffer.write('ff');
  }
  buffer.write(normalized);
  return Color(int.parse(buffer.toString(), radix: 16));
}
