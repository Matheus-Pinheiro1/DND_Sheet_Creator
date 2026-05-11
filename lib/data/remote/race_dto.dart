class RaceDto {
  final String index;
  final String name;
  final int speed;
  final List<AbilityBonusDto> abilityBonuses;
  final String size;
  final List<String> languages;
  final List<TraitDto> traits;
  final String description;
  final Map<String, String> traitDetails;
  final List<SpeciesOptionGroupDto> optionGroups;

  const RaceDto({
    required this.index,
    required this.name,
    required this.speed,
    required this.abilityBonuses,
    required this.size,
    required this.languages,
    required this.traits,
    this.description = '',
    this.traitDetails = const {},
    this.optionGroups = const [],
  });

  factory RaceDto.fromJson(Map<String, dynamic> json) => RaceDto(
        index: json['index'] ?? '',
        name: json['name'] ?? '',
        speed: json['speed'] ?? 30,
        abilityBonuses: (json['ability_bonuses'] as List<dynamic>? ?? [])
            .map((e) => AbilityBonusDto.fromJson(e))
            .toList(),
        size: json['size'] ?? 'Medium',
        languages: (json['languages'] as List<dynamic>? ?? [])
            .map((e) => e['name'] as String)
            .toList(),
        traits: (json['traits'] as List<dynamic>? ?? [])
            .map((e) => TraitDto(index: e['index'], name: e['name']))
            .toList(),
        description: (json['description'] ?? '').toString(),
        traitDetails:
            (json['trait_details'] as Map<String, dynamic>? ?? const {})
                .map((key, value) => MapEntry(key, value.toString())),
        optionGroups:
            (json['option_groups'] as List<dynamic>? ?? const <dynamic>[])
                .map((e) => SpeciesOptionGroupDto.fromJson(
                    Map<String, dynamic>.from(e as Map)))
                .toList(),
      );
}

class AbilityBonusDto {
  final String abilityScore;
  final int bonus;
  AbilityBonusDto({required this.abilityScore, required this.bonus});
  factory AbilityBonusDto.fromJson(Map<String, dynamic> json) =>
      AbilityBonusDto(
        abilityScore: json['ability_score']['index'] ?? '',
        bonus: json['bonus'] ?? 0,
      );
}

class TraitDto {
  final String index;
  final String name;
  const TraitDto({required this.index, required this.name});
}

class SpeciesOptionGroupDto {
  final String id;
  final String label;
  final String helpText;
  final List<SpeciesOptionDto> options;

  const SpeciesOptionGroupDto({
    required this.id,
    required this.label,
    this.helpText = '',
    this.options = const [],
  });

  factory SpeciesOptionGroupDto.fromJson(Map<String, dynamic> json) {
    return SpeciesOptionGroupDto(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      helpText: (json['help_text'] ?? '').toString(),
      options: (json['options'] as List<dynamic>? ?? const <dynamic>[])
          .map((e) =>
              SpeciesOptionDto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class SpeciesOptionDto {
  final String id;
  final String name;
  final String summary;
  final String details;

  const SpeciesOptionDto({
    required this.id,
    required this.name,
    this.summary = '',
    this.details = '',
  });

  factory SpeciesOptionDto.fromJson(Map<String, dynamic> json) {
    return SpeciesOptionDto(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      details: (json['details'] ?? '').toString(),
    );
  }
}

extension RaceDtoJson on RaceDto {
  Map<String, dynamic> toJson() => {
        'index': index,
        'name': name,
        'speed': speed,
        'ability_bonuses': abilityBonuses
            .map((e) => {
                  'ability_score': {'index': e.abilityScore},
                  'bonus': e.bonus,
                })
            .toList(),
        'size': size,
        'languages': languages.map((e) => {'name': e}).toList(),
        'traits':
            traits.map((e) => {'index': e.index, 'name': e.name}).toList(),
        'description': description,
        'trait_details': traitDetails,
        'option_groups': optionGroups
            .map(
              (group) => {
                'id': group.id,
                'label': group.label,
                'help_text': group.helpText,
                'options': group.options
                    .map(
                      (option) => {
                        'id': option.id,
                        'name': option.name,
                        'summary': option.summary,
                        'details': option.details,
                      },
                    )
                    .toList(),
              },
            )
            .toList(),
      };
}
