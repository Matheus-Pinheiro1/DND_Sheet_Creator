import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class EquipmentOptionsData {
  EquipmentOptionsData._();

  static const assetPath = 'assets/data/2024/class_equipment.json';
  static Map<String, List<dynamic>>? _classEquipmentOptions;

  static Future<void> load() async {
    if (_classEquipmentOptions != null) return;

    final raw = await rootBundle.loadString(assetPath);
    _classEquipmentOptions = _parseClassOptions(jsonDecode(raw));
  }

  static List<dynamic> classOptionsFor(String className) {
    final options = _classEquipmentOptions;
    if (options == null) return const [];
    return options[className.trim().toLowerCase()] ?? const [];
  }

  static Map<String, List<dynamic>> _parseClassOptions(dynamic value) {
    if (value is! Map) return const {};

    return Map.unmodifiable(
      value.map((key, rawOptions) {
        final options = rawOptions is List
            ? rawOptions
                .where((option) => _isNonEmptyOption(option))
                .toList(growable: false)
            : const <String>[];
        return MapEntry(key.toString().trim().toLowerCase(), options);
      }),
    );
  }

  static bool _isNonEmptyOption(dynamic option) {
    if (option is Map) return option.isNotEmpty;
    return option.toString().trim().isNotEmpty;
  }
}
