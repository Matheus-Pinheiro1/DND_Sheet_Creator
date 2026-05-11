import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class ProgressionData {
  ProgressionData._();

  static const assetPath = 'assets/data/2024/progression.json';
  static ProgressionRules? _rules;

  static ProgressionRules get rules {
    final loaded = _rules;
    if (loaded == null) {
      throw StateError(
        'ProgressionData.load() must run before reading progression rules.',
      );
    }
    return loaded;
  }

  static Future<void> load() async {
    if (_rules != null) return;

    final raw = await rootBundle.loadString(assetPath);
    _rules = ProgressionRules.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }
}

class ProgressionRules {
  final List<int> defaultAdvancementLevels;
  final Map<String, List<int>> advancementLevelsByClass;
  final Map<String, CantripProgression> cantripsKnown;
  final Map<String, String> preparedProgressionByClass;
  final Map<String, Map<int, int>> preparedSpells;
  final Map<String, String> spellSlotProgressionByClass;
  final Map<String, Map<int, Map<int, int>>> spellSlots;
  final ClassBonusProgressions classBonuses;

  const ProgressionRules({
    required this.defaultAdvancementLevels,
    required this.advancementLevelsByClass,
    required this.cantripsKnown,
    required this.preparedProgressionByClass,
    required this.preparedSpells,
    required this.spellSlotProgressionByClass,
    required this.spellSlots,
    required this.classBonuses,
  });

  factory ProgressionRules.fromJson(Map<String, dynamic> json) {
    final advancementLevels = _listMap(json['advancement_levels']);
    final defaultLevels =
        advancementLevels['default'] ?? const <int>[4, 8, 12, 16, 19];

    return ProgressionRules(
      defaultAdvancementLevels: List.unmodifiable(defaultLevels),
      advancementLevelsByClass: Map.unmodifiable(
        advancementLevels.map(
          (key, value) => MapEntry(key, List<int>.unmodifiable(value)),
        )..remove('default'),
      ),
      cantripsKnown: Map.unmodifiable(
        _map(json['cantrips_known']).map(
          (key, value) => MapEntry(
            key,
            CantripProgression.fromJson(_asMap(value)),
          ),
        ),
      ),
      preparedProgressionByClass:
          Map.unmodifiable(_stringMap(json['prepared_progression_by_class'])),
      preparedSpells: Map.unmodifiable(
        _map(json['prepared_spells']).map(
          (key, value) => MapEntry(key, _intMap(value)),
        ),
      ),
      spellSlotProgressionByClass:
          Map.unmodifiable(_stringMap(json['spell_slot_progression_by_class'])),
      spellSlots: Map.unmodifiable(
        _map(json['spell_slots']).map(
          (key, value) => MapEntry(key, _spellSlotLevels(value)),
        ),
      ),
      classBonuses: ClassBonusProgressions.fromJson(
        _asMap(json['class_bonuses']),
      ),
    );
  }

  List<int> advancementLevelsFor(String className) {
    return advancementLevelsByClass[className] ?? defaultAdvancementLevels;
  }

  CantripProgression? cantripsFor(String className) {
    return cantripsKnown[className];
  }

  Map<int, int> preparedSpellsFor(String className) {
    final progression = preparedProgressionByClass[className];
    if (progression == null) return const {};
    return preparedSpells[progression] ?? const {};
  }

  Map<int, Map<int, int>> spellSlotsFor(String className) {
    final progression = spellSlotProgressionByClass[className];
    if (progression == null) return const {};
    return spellSlots[progression] ?? const {};
  }
}

class CantripProgression {
  final int fallback;
  final Map<int, int> levels;

  const CantripProgression({
    required this.fallback,
    required this.levels,
  });

  factory CantripProgression.fromJson(Map<String, dynamic> json) {
    return CantripProgression(
      fallback: _int(json['fallback']),
      levels: _intMap(json['levels']),
    );
  }
}

class ClassBonusProgressions {
  final Map<int, int> barbarianFastMovementBonus;
  final Map<int, String> monkMartialArtsDie;
  final Map<int, int> monkUnarmoredMovementBonus;
  final Map<int, int> rangerRovingSpeedBonus;

  const ClassBonusProgressions({
    required this.barbarianFastMovementBonus,
    required this.monkMartialArtsDie,
    required this.monkUnarmoredMovementBonus,
    required this.rangerRovingSpeedBonus,
  });

  factory ClassBonusProgressions.fromJson(Map<String, dynamic> json) {
    final barbarian = _asMap(json['barbarian']);
    final monk = _asMap(json['monk']);
    final ranger = _asMap(json['ranger']);

    return ClassBonusProgressions(
      barbarianFastMovementBonus: _intMap(barbarian['fast_movement_bonus']),
      monkMartialArtsDie: _intStringMap(monk['martial_arts_die']),
      monkUnarmoredMovementBonus: _intMap(monk['unarmored_movement_bonus']),
      rangerRovingSpeedBonus: _intMap(ranger['roving_speed_bonus']),
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is! Map) return const {};
  return value.map(
    (key, current) => MapEntry(key.toString(), current),
  );
}

Map<String, dynamic> _asMap(dynamic value) {
  return Map<String, dynamic>.from(_map(value));
}

Map<String, String> _stringMap(dynamic value) {
  return Map.unmodifiable(
    _map(value).map(
      (key, current) => MapEntry(key, current.toString()),
    ),
  );
}

Map<String, List<int>> _listMap(dynamic value) {
  return Map.unmodifiable(
    _map(value).map(
      (key, current) => MapEntry(key, _intList(current)),
    ),
  );
}

List<int> _intList(dynamic value) {
  if (value is! List) return const [];
  return value.map(_int).toList(growable: false);
}

Map<int, int> _intMap(dynamic value) {
  return Map.unmodifiable(
    _map(value).map(
      (key, current) => MapEntry(_levelKey(key), _int(current)),
    )..removeWhere((key, _) => key < 0),
  );
}

Map<int, String> _intStringMap(dynamic value) {
  return Map.unmodifiable(
    _map(value).map(
      (key, current) => MapEntry(_levelKey(key), current.toString()),
    )..removeWhere((key, _) => key < 0),
  );
}

Map<int, Map<int, int>> _spellSlotLevels(dynamic value) {
  return Map.unmodifiable(
    _map(value).map(
      (key, current) => MapEntry(_levelKey(key), _intMap(current)),
    )..removeWhere((key, _) => key < 0),
  );
}

int _levelKey(String value) {
  return int.tryParse(value) ?? -1;
}

int _int(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

ProgressionRules get kProgressionRules => ProgressionData.rules;
