class ClassDto {
  final String index;
  final String name;
  final int hitDie;
  final List<String> savingThrows;
  final String? spellcastingAbility;
  final List<ProficiencyChoiceDto> proficiencyChoices;
  final List<String> proficiencies;
  final String source;
  final int subclassLevel;
  final String description;

  const ClassDto({
    required this.index,
    required this.name,
    required this.hitDie,
    required this.savingThrows,
    this.spellcastingAbility,
    required this.proficiencyChoices,
    required this.proficiencies,
    this.source = 'unknown',
    this.subclassLevel = 3,
    this.description = '',
  });

  factory ClassDto.fromJson(Map<String, dynamic> json) {
    String? spellAbility;
    if (json['spellcasting'] != null) {
      spellAbility =
          json['spellcasting']['spellcasting_ability']?['index'] as String?;
    }

    return ClassDto(
      index: json['index'] ?? '',
      name: json['name'] ?? '',
      hitDie: json['hit_die'] ?? 8,
      savingThrows: (json['saving_throws'] as List<dynamic>? ?? [])
          .map((e) => e['index'] as String)
          .toList(),
      spellcastingAbility: spellAbility,
      proficiencyChoices: (json['proficiency_choices'] as List<dynamic>? ?? [])
          .map((e) => ProficiencyChoiceDto.fromJson(e))
          .toList(),
      proficiencies: (json['proficiencies'] as List<dynamic>? ?? [])
          .map((e) => (e['name'] ?? '').toString())
          .where((e) => e.trim().isNotEmpty)
          .toList(),
      source: (json['source'] ?? 'unknown').toString(),
      subclassLevel: json['subclass_level'] is int
          ? json['subclass_level'] as int
          : int.tryParse('${json['subclass_level'] ?? 3}') ?? 3,
      description: (json['description'] ?? '').toString(),
    );
  }

  bool get isSpellcaster => spellcastingAbility != null;
  bool get isUnearthedArcana => source.toLowerCase().startsWith('ua');
}

class ProficiencyChoiceDto {
  final String desc;
  final int choose;
  final List<String> from;

  const ProficiencyChoiceDto({
    required this.desc,
    required this.choose,
    required this.from,
  });

  factory ProficiencyChoiceDto.fromJson(Map<String, dynamic> json) {
    final fromList = <String>[];
    final fromData = json['from'];
    if (fromData is Map && fromData['options'] != null) {
      for (final opt in fromData['options'] as List<dynamic>) {
        if (opt['item'] != null) {
          fromList.add(opt['item']['name'] ?? '');
        }
      }
    }
    return ProficiencyChoiceDto(
      desc: json['desc'] ?? '',
      choose: json['choose'] ?? 1,
      from: fromList,
    );
  }
}
