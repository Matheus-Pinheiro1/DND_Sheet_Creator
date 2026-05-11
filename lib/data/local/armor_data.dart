import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

enum ArmorDexMode { full, maxTwo, none }

class DndArmor {
  final String id;
  final String name;
  final String category;
  final int baseAc;
  final int acBonus;
  final ArmorDexMode dexMode;
  final List<String> aliases;

  const DndArmor({
    required this.id,
    required this.name,
    required this.category,
    required this.baseAc,
    required this.acBonus,
    required this.dexMode,
    required this.aliases,
  });

  bool get isShield => category == 'shield';

  int dexBonus(int dexMod) {
    return switch (dexMode) {
      ArmorDexMode.full => dexMod,
      ArmorDexMode.maxTwo => dexMod.clamp(-999, 2).toInt(),
      ArmorDexMode.none => 0,
    };
  }

  factory DndArmor.fromJson(Map<String, dynamic> json) {
    return DndArmor(
      id: _string(json['id']),
      name: _string(json['name']),
      category: _string(json['category'], fallback: 'armor'),
      baseAc: _int(json['base_ac']),
      acBonus: _int(json['ac_bonus']),
      dexMode: _dexMode(json['dex_mode']),
      aliases: (json['aliases'] as List<dynamic>? ?? const [])
          .map((alias) => alias.toString().trim())
          .where((alias) => alias.isNotEmpty)
          .toList(growable: false),
    );
  }

  static String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static ArmorDexMode _dexMode(dynamic value) {
    return switch (_string(value).toLowerCase()) {
      'full' => ArmorDexMode.full,
      'max_two' || 'max-two' || 'max2' => ArmorDexMode.maxTwo,
      _ => ArmorDexMode.none,
    };
  }
}

class ArmorData {
  ArmorData._();

  static const assetPath = 'assets/data/2024/armor.json';
  static List<DndArmor>? _armor;

  static List<DndArmor> get armor {
    final loaded = _armor;
    if (loaded == null) {
      throw StateError('ArmorData.load() must run before reading armor.');
    }
    return loaded;
  }

  static Future<void> load() async {
    if (_armor != null) return;

    final raw = await rootBundle.loadString(assetPath);
    final list = jsonDecode(raw) as List<dynamic>;
    _armor = list
        .whereType<Map>()
        .map((entry) => DndArmor.fromJson(Map<String, dynamic>.from(entry)))
        .toList(growable: false);
  }
}

List<DndArmor> get kDndArmors => ArmorData.armor;
