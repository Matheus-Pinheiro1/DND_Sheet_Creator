class MonsterSummaryDto {
  final String index;
  final String name;
  final String url;

  const MonsterSummaryDto({
    required this.index,
    required this.name,
    required this.url,
  });

  factory MonsterSummaryDto.fromJson(Map<String, dynamic> json) =>
      MonsterSummaryDto(
        index: (json['index'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        url: (json['url'] ?? '').toString(),
      );
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

    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  Map<String, int> get savingThrowBonuses {
    final result = <String, int>{};
    final pattern = RegExp(
      r'Saving Throw:\s*([A-Za-z]{3})\s*([+-]?\d+)',
      caseSensitive: false,
    );

    for (final proficiency in proficiencies) {
      final match = pattern.firstMatch(proficiency);
      if (match == null) continue;

      final ability = match.group(1)?.toUpperCase();
      final value = int.tryParse(match.group(2) ?? '');
      if (ability == null || value == null) continue;

      result[ability] = value;
    }

    return result;
  }

  int abilityScoreFor(String ability) {
    return switch (ability.toUpperCase()) {
      'STR' => strength,
      'DEX' => dexterity,
      'CON' => constitution,
      'INT' => intelligence,
      'WIS' => wisdom,
      'CHA' => charisma,
      _ => 10,
    };
  }

  int abilityModifierFor(String ability) {
    return ((abilityScoreFor(ability) - 10) / 2).floor();
  }

  int savingThrowFor(String ability) {
    final label = ability.toUpperCase();
    return abilityModifierFor(label) + (savingThrowBonuses[label] ?? 0);
  }

  factory MonsterDetailDto.fromJson(Map<String, dynamic> json) =>
      MonsterDetailDto(
        index: (json['index'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        size: (json['size'] ?? '').toString(),
        type: (json['type'] ?? '').toString(),
        alignment: (json['alignment'] ?? '').toString(),
        armorClass: _parseArmorClass(json['armor_class']),
        hitPoints: _parseInt(json['hit_points']),
        hitDice: (json['hit_dice'] ?? '').toString(),
        speed: _map(json['speed']),
        strength: _parseInt(json['strength'], fallback: 10),
        dexterity: _parseInt(json['dexterity'], fallback: 10),
        constitution: _parseInt(json['constitution'], fallback: 10),
        intelligence: _parseInt(json['intelligence'], fallback: 10),
        wisdom: _parseInt(json['wisdom'], fallback: 10),
        charisma: _parseInt(json['charisma'], fallback: 10),
        challengeRating: _parseChallengeRating(json['challenge_rating']),
        xp: _parseNullableInt(json['xp']),
        proficiencies: (json['proficiencies'] as List? ?? const [])
            .map((e) {
              if (e is Map) {
                final proficiency = e['proficiency'];
                final name = (proficiency is Map)
                    ? ((e['proficiency']['name'] ?? e['proficiency']['index'])
                            ?.toString() ??
                        '')
                    : '';
                final value = e['value'];
                return value == null ? name : '$name +$value';
              }
              return e.toString();
            })
            .where((e) => e.trim().isNotEmpty)
            .toList(),
        damageResistances: (json['damage_resistances'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        damageImmunities: (json['damage_immunities'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        conditionImmunities:
            (json['condition_immunities'] as List? ?? const []).map((e) {
          if (e is Map<String, dynamic>) return (e['name'] ?? '').toString();
          return e.toString();
        }).toList(),
        senses: _map(json['senses']),
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

        if (top != null && bottom != null && bottom != 0) {
          return top / bottom;
        }
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
        final ac = first['value'];
        final parsed = _parseNullableInt(ac);
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

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }
}
