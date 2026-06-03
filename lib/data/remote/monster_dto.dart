class MonsterSummaryDto {
  final String index;
  final String name;
  final num challengeRating;
  final String crLabel;
  final String type;
  final String size;

  const MonsterSummaryDto({
    required this.index,
    required this.name,
    this.challengeRating = 0,
    this.crLabel = '0',
    this.type = '',
    this.size = '',
  });

  factory MonsterSummaryDto.fromJson(Map<String, dynamic> json) {
    final cr = _parseCr(json['challenge_rating'] ?? json['cr']);
    return MonsterSummaryDto(
      index: (json['slug'] ?? json['index'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      challengeRating: cr,
      crLabel: (json['cr_label'] ?? _buildCrLabel(cr)).toString(),
      type: (json['type'] ?? '').toString().toLowerCase(),
      size: (json['size'] ?? '').toString().toLowerCase(),
    );
  }

  static num _parseCr(dynamic v) {
    if (v is num) return v;
    final s = v?.toString().trim() ?? '';
    if (s.isEmpty) return 0;
    if (s.contains('/')) {
      final p = s.split('/');
      if (p.length == 2) {
        final a = num.tryParse(p[0].trim());
        final b = num.tryParse(p[1].trim());
        if (a != null && b != null && b != 0) return a / b;
      }
    }
    return num.tryParse(s) ?? 0;
  }

  static String _buildCrLabel(num cr) {
    if (cr == 0.125) return '1/8';
    if (cr == 0.25) return '1/4';
    if (cr == 0.5) return '1/2';
    return cr % 1 == 0 ? cr.toInt().toString() : cr.toString();
  }
}

class MonsterDetailDto {
  final String index;
  final String name;
  final String size;
  final String type;
  final String alignment;
  final int armorClass;
  final int hitPoints;
  final String hitDice;
  final Map<String, dynamic> speed;
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;
  final num challengeRating;
  final int? xp;
  final List<String> proficiencies;
  final List<String> damageVulnerabilities;
  final List<String> damageResistances;
  final List<String> damageImmunities;
  final List<String> conditionImmunities;
  final Map<String, dynamic> senses;
  final List<String> languages;
  final List<Map<String, dynamic>> specialAbilities;
  final List<Map<String, dynamic>> actions;
  final List<Map<String, dynamic>> bonusActions;
  final List<Map<String, dynamic>> reactions;
  final List<Map<String, dynamic>> legendaryActions;

  const MonsterDetailDto({
    required this.index,
    required this.name,
    required this.size,
    required this.type,
    required this.alignment,
    required this.armorClass,
    required this.hitPoints,
    required this.hitDice,
    required this.speed,
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
    required this.challengeRating,
    required this.xp,
    required this.proficiencies,
    required this.damageVulnerabilities,
    required this.damageResistances,
    required this.damageImmunities,
    required this.conditionImmunities,
    required this.senses,
    required this.languages,
    required this.specialAbilities,
    required this.actions,
    required this.bonusActions,
    required this.reactions,
    required this.legendaryActions,
  });

  String get challengeRatingLabel {
    final value = challengeRating;
    if (value == 0.125) return '1/8';
    if (value == 0.25) return '1/4';
    if (value == 0.5) return '1/2';
    if (value % 1 == 0) return value.toInt().toString();
    return value.toString();
  }

  Map<String, int> get savingThrowBonuses {
    final result = <String, int>{};
    final pattern = RegExp(
      r'Saving Throw:\s*([A-Za-z]{3})\s*([+-]?\d+)',
      caseSensitive: false,
    );
    for (final p in proficiencies) {
      final m = pattern.firstMatch(p);
      if (m == null) continue;
      final ability = m.group(1)?.toUpperCase();
      final value = int.tryParse(m.group(2) ?? '');
      if (ability != null && value != null) result[ability] = value;
    }
    return result;
  }

  int abilityScoreFor(String ability) => switch (ability.toUpperCase()) {
        'STR' => strength,
        'DEX' => dexterity,
        'CON' => constitution,
        'INT' => intelligence,
        'WIS' => wisdom,
        'CHA' => charisma,
        _ => 10,
      };

  int abilityModifierFor(String ability) =>
      ((abilityScoreFor(ability) - 10) / 2).floor();

  int savingThrowFor(String ability) {
    final label = ability.toUpperCase();
    return abilityModifierFor(label) + (savingThrowBonuses[label] ?? 0);
  }

  factory MonsterDetailDto.fromJson(Map<String, dynamic> json) {
    final proficienciesFromJson = _parseProficiencies(json);

    final speedRaw = json['speed'];
    final Map<String, dynamic> speedMap = speedRaw is Map
        ? Map<String, dynamic>.from(speedRaw)
        : speedRaw is String
            ? {'walk': speedRaw}
            : _map(json['speed']);

    final sensesRaw = json['senses'];
    final Map<String, dynamic> sensesMap;
    if (sensesRaw is Map) {
      sensesMap = Map<String, dynamic>.from(sensesRaw);
    } else if (sensesRaw is String && sensesRaw.isNotEmpty) {
      sensesMap = {};
      for (final part in sensesRaw.split(',')) {
        final t = part.trim();
        final i = t.lastIndexOf(' ');
        if (i > 0)
          sensesMap[t.substring(0, i).trim()] = t.substring(i + 1).trim();
      }
    } else {
      sensesMap = {};
    }

    return MonsterDetailDto(
      index: (json['slug'] ?? json['index'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      size: (json['size'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      alignment: (json['alignment'] ?? '').toString(),
      armorClass: _parseArmorClass(json['armor_class']),
      hitPoints: _parseInt(json['hit_points']),
      hitDice: (json['hit_dice'] ?? '').toString(),
      speed: speedMap,
      strength: _parseInt(json['strength'], fallback: 10),
      dexterity: _parseInt(json['dexterity'], fallback: 10),
      constitution: _parseInt(json['constitution'], fallback: 10),
      intelligence: _parseInt(json['intelligence'], fallback: 10),
      wisdom: _parseInt(json['wisdom'], fallback: 10),
      charisma: _parseInt(json['charisma'], fallback: 10),
      challengeRating:
          _parseChallengeRating(json['challenge_rating'] ?? json['cr']),
      xp: _parseNullableInt(json['xp']),
      proficiencies: proficienciesFromJson,
      damageVulnerabilities: _parseDefensesList(json['damage_vulnerabilities']),
      damageResistances: _parseDefensesList(json['damage_resistances']),
      damageImmunities: _parseDefensesList(json['damage_immunities']),
      conditionImmunities: _parseDefensesList(json['condition_immunities']),
      senses: sensesMap,
      languages: (json['languages'] ?? '')
          .toString()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      specialAbilities: _mapList(json['special_abilities']),
      actions: _mapList(json['actions']),
      bonusActions: _mapList(json['bonus_actions']),
      reactions: _mapList(json['reactions']),
      legendaryActions: _mapList(json['legendary_actions']),
    );
  }

  static List<String> _parseProficiencies(Map<String, dynamic> json) {
    final hasSavingThrowsMap = json['saving_throws'] is Map;
    final hasSkillsMap = json['skills'] is Map;

    if (hasSavingThrowsMap || hasSkillsMap) {
      final result = <String>[];
      if (hasSavingThrowsMap) {
        const abilityMap = {
          'str_save': 'STR',
          'dex_save': 'DEX',
          'con_save': 'CON',
          'int_save': 'INT',
          'wis_save': 'WIS',
          'cha_save': 'CHA',
        };
        for (final entry in (json['saving_throws'] as Map).entries) {
          final label = abilityMap[entry.key];
          if (label != null && entry.value != null) {
            final bonus = _parseInt(entry.value);
            result.add('Saving Throw: $label ${bonus >= 0 ? '+' : ''}$bonus');
          }
        }
      }
      if (hasSkillsMap) {
        for (final entry in (json['skills'] as Map).entries) {
          if (entry.value != null) {
            final bonus = _parseInt(entry.value);
            final name = _toTitleCase(entry.key.toString());
            result.add('$name +$bonus');
          }
        }
      }
      return result;
    }

    return (json['proficiencies'] as List? ?? const [])
        .map((e) {
          if (e is Map) {
            final prof = e['proficiency'];
            final name = prof is Map
                ? ((prof['name'] ?? prof['index'])?.toString() ?? '')
                : '';
            final value = e['value'];
            return value == null ? name : '$name +$value';
          }
          return e.toString();
        })
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'name': name,
        'size': size,
        'type': type,
        'alignment': alignment,
        'armor_class': armorClass,
        'hit_points': hitPoints,
        'hit_dice': hitDice,
        'speed': speed,
        'strength': strength,
        'dexterity': dexterity,
        'constitution': constitution,
        'intelligence': intelligence,
        'wisdom': wisdom,
        'charisma': charisma,
        'challenge_rating': challengeRating,
        'xp': xp,
        'proficiencies': proficiencies,
        'damage_vulnerabilities': damageVulnerabilities,
        'damage_resistances': damageResistances,
        'damage_immunities': damageImmunities,
        'condition_immunities': conditionImmunities,
        'senses': senses,
        'languages': languages.join(', '),
        'special_abilities': specialAbilities,
        'actions': actions,
        'bonus_actions': bonusActions,
        'reactions': reactions,
        'legendary_actions': legendaryActions,
      };

  static num _parseChallengeRating(dynamic value) {
    if (value is num) return value;
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return 0;
    if (text.contains('/')) {
      final parts = text.split('/');
      if (parts.length == 2) {
        final top = num.tryParse(parts[0].trim());
        final bottom = num.tryParse(parts[1].trim());
        if (top != null && bottom != null && bottom != 0) return top / bottom;
      }
    }
    return num.tryParse(text) ?? 0;
  }

  static int _parseArmorClass(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map) {
        final parsed = _parseNullableInt(first['value']);
        if (parsed != null) return parsed;
      }
    }
    return 10;
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};

  static List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static List<String> _parseDefensesList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    final str = value.toString().trim();
    if (str.isEmpty) return const [];
    return str
        .split(RegExp(r'[;,]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static String _toTitleCase(String s) => s
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
