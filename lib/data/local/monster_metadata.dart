import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

const List<String> kMonsterTypes = [
  'aberration',
  'beast',
  'celestial',
  'construct',
  'dragon',
  'elemental',
  'fey',
  'fiend',
  'giant',
  'humanoid',
  'monstrosity',
  'ooze',
  'plant',
  'undead',
];

const List<String> kMonsterSizes = [
  'tiny',
  'small',
  'medium',
  'large',
  'huge',
  'gargantuan',
];

Map<String, MonsterMeta> get kMonsterMetadata =>
    MonsterMetadataData._metadata ?? const {};

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
        if (top != null && bottom != null && bottom != 0) return top / bottom;
      }
    }
    return double.tryParse(text) ?? 0;
  }

  static String _string(dynamic value) => value?.toString() ?? '';
}

class MonsterMetadataData {
  MonsterMetadataData._();

  static Map<String, MonsterMeta>? _metadata;

  static Future<void> load() async {
    if (_metadata != null) return;
    try {
      final raw =
          await rootBundle.loadString('assets/data/2024/monster_metadata.json');
      final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final monsters = data['monsters'] as List<dynamic>? ?? const [];
      _metadata = {
        for (final entry in monsters.whereType<Map>())
          (entry['index'] ?? '').toString():
              MonsterMeta.fromJson(Map<String, dynamic>.from(entry)),
      }..remove('');
    } catch (_) {
      _metadata = {};
    }
  }
}
