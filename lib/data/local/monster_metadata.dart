import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class MonsterMeta {
  final double cr;
  final String type;
  final String size;

  const MonsterMeta(this.cr, this.type, this.size);

  factory MonsterMeta.fromJson(Map<String, dynamic> json) => MonsterMeta(
        _double(json['cr']),
        _string(json['type']),
        _string(json['size']),
      );

  String get crLabel {
    if (cr == 0) return '0';
    if (cr == 0.125) return '1/8';
    if (cr == 0.25) return '1/4';
    if (cr == 0.5) return '1/2';
    return cr.toInt().toString();
  }

  static double _double(dynamic value) {
    if (value is num) return value.toDouble();

    final text = value?.toString().trim() ?? '';
    if (text.contains('/')) {
      final parts = text.split('/');
      if (parts.length == 2) {
        final top = double.tryParse(parts[0].trim());
        final bottom = double.tryParse(parts[1].trim());
        if (top != null && bottom != null && bottom != 0) {
          return top / bottom;
        }
      }
    }
    return double.tryParse(text) ?? 0;
  }

  static String _string(dynamic value) => value?.toString() ?? '';
}

class MonsterMetadataData {
  MonsterMetadataData._();

  static const assetPath = 'assets/data/2024/monster_metadata.json';
  static Map<String, MonsterMeta>? _metadata;
  static List<String>? _types;
  static List<String>? _sizes;

  static Map<String, MonsterMeta> get metadata {
    final loaded = _metadata;
    if (loaded == null) {
      throw StateError(
        'MonsterMetadataData.load() must run before reading monster metadata.',
      );
    }
    return loaded;
  }

  static List<String> get types {
    final loaded = _types;
    if (loaded == null) {
      throw StateError(
        'MonsterMetadataData.load() must run before reading monster types.',
      );
    }
    return loaded;
  }

  static List<String> get sizes {
    final loaded = _sizes;
    if (loaded == null) {
      throw StateError(
        'MonsterMetadataData.load() must run before reading monster sizes.',
      );
    }
    return loaded;
  }

  static Future<void> load() async {
    if (_metadata != null) return;

    final raw = await rootBundle.loadString(assetPath);
    final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final monsters = data['monsters'] as List<dynamic>? ?? const [];

    _types = _stringList(data['types']);
    _sizes = _stringList(data['sizes']);
    _metadata = {
      for (final entry in monsters.whereType<Map>())
        (entry['index'] ?? '').toString():
            MonsterMeta.fromJson(Map<String, dynamic>.from(entry)),
    }..remove('');
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((entry) => entry.toString()).toList(growable: false);
  }
}

Map<String, MonsterMeta> get kMonsterMetadata => MonsterMetadataData.metadata;
List<String> get kMonsterTypes => MonsterMetadataData.types;
List<String> get kMonsterSizes => MonsterMetadataData.sizes;
