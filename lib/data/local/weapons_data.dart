import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

enum WeaponCategory { simple, martial }

class DndWeapon {
  final String name;
  final String damageDice;
  final String damageType;
  final String range;
  final String properties;
  final String mastery;
  final bool isFinesse;
  final bool isThrowing;
  final WeaponCategory category;

  const DndWeapon({
    required this.name,
    required this.damageDice,
    required this.damageType,
    required this.range,
    required this.properties,
    this.mastery = '',
    required this.category,
    this.isFinesse = false,
    this.isThrowing = false,
  });

  factory DndWeapon.fromJson(Map<String, dynamic> json) {
    final properties = _string(json['properties']);
    return DndWeapon(
      name: _string(json['name']),
      damageDice: _string(json['damage_dice']),
      damageType: _string(json['damage_type']),
      range: _string(json['range']),
      properties: properties,
      mastery: _string(json['mastery']),
      category: _category(json['category']),
      isFinesse:
          _bool(json['is_finesse']) || _hasProperty(properties, 'finesse'),
      isThrowing:
          _bool(json['is_throwing']) || _hasProperty(properties, 'thrown'),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'damage_dice': damageDice,
        'damage_type': damageType,
        'range': range,
        'properties': properties,
        'mastery': mastery,
        'category': category.name,
      };

  static String _string(dynamic value) => value?.toString() ?? '';

  static bool _bool(dynamic value) {
    if (value is bool) return value;
    return value?.toString().toLowerCase() == 'true';
  }

  static WeaponCategory _category(dynamic value) {
    return switch (_string(value).trim().toLowerCase()) {
      'martial' => WeaponCategory.martial,
      _ => WeaponCategory.simple,
    };
  }

  static bool _hasProperty(String properties, String property) {
    return properties
        .split(',')
        .map((part) => part.trim().toLowerCase())
        .contains(property);
  }
}

class WeaponsData {
  WeaponsData._();

  static const assetPath = 'assets/data/2024/weapons.json';
  static List<DndWeapon>? _weapons;

  static List<DndWeapon> get weapons {
    final loaded = _weapons;
    if (loaded == null) {
      throw StateError('WeaponsData.load() must run before reading weapons.');
    }
    return loaded;
  }

  static Future<void> load() async {
    if (_weapons != null) return;

    final raw = await rootBundle.loadString(assetPath);
    final list = jsonDecode(raw) as List<dynamic>;
    _weapons = list
        .whereType<Map>()
        .map((entry) => DndWeapon.fromJson(Map<String, dynamic>.from(entry)))
        .toList(growable: false);
  }
}

List<DndWeapon> get kDndWeapons => WeaponsData.weapons;
