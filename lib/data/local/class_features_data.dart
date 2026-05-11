import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class ClassFeaturesData {
  ClassFeaturesData._();

  static const assetPath = 'assets/data/2024/class_features.json';
  static Map<String, Map<int, List<String>>>? _progression;

  static Map<String, Map<int, List<String>>> get progression {
    final loaded = _progression;
    if (loaded == null) {
      throw StateError(
        'ClassFeaturesData.load() must run before reading class features.',
      );
    }
    return loaded;
  }

  static Future<void> load() async {
    if (_progression != null) return;

    final raw = await rootBundle.loadString(assetPath);
    _progression = _levelMap(jsonDecode(raw));
  }

  static Map<String, Map<int, List<String>>> _levelMap(dynamic value) {
    if (value is! Map) return const {};

    final result = <String, Map<int, List<String>>>{};
    for (final source in value.entries) {
      result[source.key.toString()] = _levelEntries(source.value);
    }
    return result;
  }

  static Map<int, List<String>> _levelEntries(dynamic value) {
    if (value is! Map) return const {};

    final result = <int, List<String>>{};
    for (final entry in value.entries) {
      final level = int.tryParse(entry.key.toString());
      if (level == null) continue;
      result[level] = _stringList(entry.value);
    }
    return result;
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((entry) => entry.toString()).toList(growable: false);
  }
}

Map<String, Map<int, List<String>>> get kClassFeatureProgression =>
    ClassFeaturesData.progression;
