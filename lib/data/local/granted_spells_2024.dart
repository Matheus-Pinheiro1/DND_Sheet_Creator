import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class GrantedSpellEntry {
  final String spellIndex;
  final int unlockLevel;
  final String sourceKey;
  final String sourceLabel;
  final bool alwaysPrepared;
  final bool countsAgainstPreparedLimit;

  const GrantedSpellEntry({
    required this.spellIndex,
    required this.unlockLevel,
    required this.sourceKey,
    required this.sourceLabel,
    this.alwaysPrepared = true,
    this.countsAgainstPreparedLimit = false,
  });
}

class GrantedSpells2024Data {
  GrantedSpells2024Data._();

  static const assetPath = 'assets/data/2024/granted_spells.json';
  static Map<String, Map<int, List<String>>>? _subclassGrantedSpells;
  static Map<String, Map<int, List<String>>>? _speciesGrantedSpells;
  static Map<String, String>? _spellIndexAliases;

  static Map<String, Map<int, List<String>>> get subclassGrantedSpells {
    final loaded = _subclassGrantedSpells;
    if (loaded == null) {
      throw StateError(
        'GrantedSpells2024Data.load() must run before reading subclass spells.',
      );
    }
    return loaded;
  }

  static Map<String, Map<int, List<String>>> get speciesGrantedSpells {
    final loaded = _speciesGrantedSpells;
    if (loaded == null) {
      throw StateError(
        'GrantedSpells2024Data.load() must run before reading species spells.',
      );
    }
    return loaded;
  }

  static Map<String, String> get spellIndexAliases {
    final loaded = _spellIndexAliases;
    if (loaded == null) {
      throw StateError(
        'GrantedSpells2024Data.load() must run before reading spell aliases.',
      );
    }
    return loaded;
  }

  static Future<void> load() async {
    if (_subclassGrantedSpells != null &&
        _speciesGrantedSpells != null &&
        _spellIndexAliases != null) {
      return;
    }

    final raw = await rootBundle.loadString(assetPath);
    final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    _subclassGrantedSpells = _levelMap(data['subclass_granted_spells']);
    _speciesGrantedSpells = _levelMap(data['species_granted_spells']);
    _spellIndexAliases = _stringMap(data['spell_index_aliases']);
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

  static Map<String, String> _stringMap(dynamic value) {
    if (value is! Map) return const {};
    return {
      for (final entry in value.entries)
        entry.key.toString(): entry.value?.toString() ?? '',
    };
  }
}

Map<String, Map<int, List<String>>> get kSubclassGrantedSpells2024 =>
    GrantedSpells2024Data.subclassGrantedSpells;
Map<String, Map<int, List<String>>> get kSpeciesGrantedSpells2024 =>
    GrantedSpells2024Data.speciesGrantedSpells;

Map<String, String> get _spellIndexAliases =>
    GrantedSpells2024Data.spellIndexAliases;

String _normalizeSpellKey(String value) {
  final lowered = value
      .toLowerCase()
      .replaceAll('â€™', "'")
      .replaceAll('â€œ', '"')
      .replaceAll('â€', '"')
      .replaceAll('â€“', '-')
      .replaceAll('â€”', '-')
      .replaceAll(RegExp(r"[^a-z0-9'+ ]"), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return lowered;
}

Map<String, String> buildSpellNameIndexMap(Iterable<dynamic> spells) {
  final map = <String, String>{};
  for (final spell in spells) {
    final key = _normalizeSpellKey(spell.name as String);
    if (key.isNotEmpty) {
      map.putIfAbsent(key, () => spell.index as String);
    }
  }
  return map;
}

List<GrantedSpellEntry> buildGrantedSpellEntries({
  required String className,
  required String subclass,
  required String raceValue,
  required int level,
  Map<String, String> spellNameToIndex = const {},
}) {
  final entries = <GrantedSpellEntry>[];

  void addFromMap(
      Map<int, List<String>>? config, String sourceKey, String sourceLabel) {
    if (config == null) return;
    final levels = config.keys.toList()..sort();
    for (final unlock in levels) {
      if (unlock > level) continue;
      for (final name in config[unlock] ?? const <String>[]) {
        final normalizedName = _normalizeSpellKey(name);
        final index = spellNameToIndex[normalizedName] ??
            _spellIndexAliases[normalizedName] ??
            _slugifySpellName(name);
        if (index.isEmpty) continue;
        entries.add(
          GrantedSpellEntry(
            spellIndex: index,
            unlockLevel: unlock,
            sourceKey: sourceKey,
            sourceLabel: sourceLabel,
          ),
        );
      }
    }
  }

  final normalizedSubclass = subclass.trim().toLowerCase();
  final normalizedRace = raceValue.trim().toLowerCase();

  if (normalizedSubclass.isNotEmpty) {
    final subclassMap = kSubclassGrantedSpells2024[normalizedSubclass];
    if (subclassMap != null) {
      addFromMap(
        subclassMap,
        'subclass:$normalizedSubclass',
        'Subclass',
      );
    }
  }

  if (normalizedRace.isNotEmpty) {
    addFromMap(
      kSpeciesGrantedSpells2024[normalizedRace],
      'species:$normalizedRace',
      'Species',
    );
  }

  if (normalizedRace == 'elf') {
    addFromMap(
      kSpeciesGrantedSpells2024['elf::lineage::high-elf'],
      'species:elf',
      'Species',
    );
  }

  return _dedupeGrantedEntries(entries);
}

String _slugifySpellName(String value) {
  return value
      .toLowerCase()
      .replaceAll('â€™', '')
      .replaceAll("'", '')
      .replaceAll('â€œ', '')
      .replaceAll('â€', '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

List<GrantedSpellEntry> _dedupeGrantedEntries(List<GrantedSpellEntry> entries) {
  final bySpell = <String, GrantedSpellEntry>{};
  for (final entry in entries) {
    final previous = bySpell[entry.spellIndex];
    if (previous == null || entry.unlockLevel < previous.unlockLevel) {
      bySpell[entry.spellIndex] = entry;
    }
  }
  final result = bySpell.values.toList()
    ..sort((a, b) {
      final levelCompare = a.unlockLevel.compareTo(b.unlockLevel);
      if (levelCompare != 0) return levelCompare;
      return a.spellIndex.compareTo(b.spellIndex);
    });
  return result;
}
