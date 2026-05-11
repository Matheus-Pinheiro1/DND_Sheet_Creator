import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class ClassFeatureDetailsData {
  ClassFeatureDetailsData._();

  static const assetPath = 'assets/data/2024/class_feature_details.json';
  static Map<String, Map<String, ClassFeatureDetailsEntry>>? _catalog;

  static Future<void> load() async {
    if (_catalog != null) return;

    final raw = await rootBundle.loadString(assetPath);
    _catalog = _parseCatalog(jsonDecode(raw));
  }

  static ClassFeatureDetailsEntry? byName({
    required String name,
    String? className,
  }) {
    final loaded = _catalog;
    if (loaded == null) return null;

    final featureKey = _normalize(name);
    final classKey = className == null ? null : _normalize(className);
    if (classKey != null) {
      final classMatch = loaded[classKey]?[featureKey];
      if (classMatch != null) return classMatch;
    }
    return loaded['_global']?[featureKey];
  }

  static Map<String, Map<String, ClassFeatureDetailsEntry>> _parseCatalog(
    dynamic value,
  ) {
    if (value is! Map) return const {};

    final catalog = <String, Map<String, ClassFeatureDetailsEntry>>{};
    for (final classEntry in value.entries) {
      final features = classEntry.value;
      if (features is! Map) continue;

      final featureMap = <String, ClassFeatureDetailsEntry>{};
      for (final featureEntry in features.entries) {
        final rawDetails = featureEntry.value;
        if (rawDetails is! Map) continue;
        featureMap[_normalize(featureEntry.key.toString())] =
            ClassFeatureDetailsEntry.fromJson(rawDetails);
      }
      catalog[_normalize(classEntry.key.toString())] = featureMap;
    }
    return catalog;
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(' ', '-').replaceAll('_', '-');
  }
}

class ClassFeatureDetailsEntry {
  final String? description;
  final List<String>? tags;
  final String? actionType;
  final String? usage;
  final String? resourceCost;
  final String? recharge;
  final String? mechanicalEffect;
  final String? summary;
  final bool? showInCombat;

  const ClassFeatureDetailsEntry({
    this.description,
    this.tags,
    this.actionType,
    this.usage,
    this.resourceCost,
    this.recharge,
    this.mechanicalEffect,
    this.summary,
    this.showInCombat,
  });

  factory ClassFeatureDetailsEntry.fromJson(Map<dynamic, dynamic> json) {
    return ClassFeatureDetailsEntry(
      description: _string(json['description']),
      tags: _tags(json['tags']),
      actionType: _string(json['actionType']),
      usage: _string(json['usage']),
      resourceCost: _string(json['resourceCost']),
      recharge: _string(json['recharge']),
      mechanicalEffect: _string(json['mechanicalEffect']),
      summary: _string(json['summary']),
      showInCombat: _bool(json['showInCombat']),
    );
  }

  static String? _string(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static List<String>? _tags(dynamic value) {
    if (value is! List) return null;
    final tags = value
        .map((entry) => entry.toString().trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
    return tags.isEmpty ? null : tags;
  }

  static bool? _bool(dynamic value) {
    return value is bool ? value : null;
  }
}
