import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class Subclasses2024Data {
  Subclasses2024Data._();

  static const assetPath = 'assets/data/2024/subclasses.json';
  static Map<String, List<Map<String, String>>>? _options;
  static Map<String, Map<String, List<Map<String, String>>>>? _features;

  static Map<String, List<Map<String, String>>> get options {
    final loaded = _options;
    if (loaded == null) {
      throw StateError(
        'Subclasses2024Data.load() must run before reading subclass options.',
      );
    }
    return loaded;
  }

  static Map<String, Map<String, List<Map<String, String>>>> get features {
    final loaded = _features;
    if (loaded == null) {
      throw StateError(
        'Subclasses2024Data.load() must run before reading subclass features.',
      );
    }
    return loaded;
  }

  static bool hasOptionsFor(String classIndex) {
    final normalized = classIndex.trim().toLowerCase();
    return options[normalized]?.isNotEmpty ?? false;
  }

  static Future<void> load() async {
    if (_options != null && _features != null) return;

    final raw = await rootBundle.loadString(assetPath);
    final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    _options = _optionsMap(data['options']);
    _features = _featuresMap(data['features']);
  }

  static Map<String, List<Map<String, String>>> _optionsMap(dynamic value) {
    if (value is! Map) return const {};

    final result = <String, List<Map<String, String>>>{};
    for (final entry in value.entries) {
      result[entry.key.toString()] = _stringMapList(entry.value);
    }
    return result;
  }

  static Map<String, Map<String, List<Map<String, String>>>> _featuresMap(
    dynamic value,
  ) {
    if (value is! Map) return const {};

    final result = <String, Map<String, List<Map<String, String>>>>{};
    for (final subclass in value.entries) {
      final levels = subclass.value;
      if (levels is! Map) {
        result[subclass.key.toString()] = const {};
        continue;
      }

      result[subclass.key.toString()] = {
        for (final level in levels.entries)
          level.key.toString(): _stringMapList(level.value),
      };
    }
    return result;
  }

  static List<Map<String, String>> _stringMapList(dynamic value) {
    if (value is! List) return const [];

    return value.whereType<Map>().map((entry) {
      return {
        for (final item in entry.entries)
          item.key.toString(): item.value?.toString() ?? '',
      };
    }).toList(growable: false);
  }
}

Map<String, List<Map<String, String>>> get kLocal2024SubclassOptions =>
    Subclasses2024Data.options;
Map<String, Map<String, List<Map<String, String>>>>
    get kLocal2024SubclassFeatures => Subclasses2024Data.features;
