import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class SpellCatalogData {
  SpellCatalogData._();

  static const assetPath = 'assets/data/2024/spells.json';
  static Map<String, int>? _levelsByIndex;

  static Future<void> load() async {
    if (_levelsByIndex != null) return;

    final raw = await rootBundle.loadString(assetPath);
    _levelsByIndex = _parseLevels(jsonDecode(raw));
  }

  static int? levelFor(String spellIndex) {
    final loaded = _levelsByIndex;
    if (loaded == null) return null;
    return loaded[spellIndex.trim().toLowerCase()];
  }

  static Map<String, int> _parseLevels(dynamic value) {
    if (value is! List) return const {};

    final result = <String, int>{};
    for (final entry in value) {
      if (entry is! Map) continue;
      final index = entry['index']?.toString().trim().toLowerCase() ?? '';
      if (index.isEmpty) continue;
      result[index] = _int(entry['level']);
    }
    return Map.unmodifiable(result);
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
