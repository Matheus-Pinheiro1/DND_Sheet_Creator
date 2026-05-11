class BackgroundDto {
  final String index;
  final String name;
  final List<String> skillProficiencyIndices;
  final String? feature;
  final List<String> abilityOptions;
  final String? featId;
  final String? featName;
  final List<String> toolProficiencies;
  final List<dynamic> equipmentOptions;
  final String description;

  const BackgroundDto({
    required this.index,
    required this.name,
    required this.skillProficiencyIndices,
    this.feature,
    this.abilityOptions = const [],
    this.featId,
    this.featName,
    this.toolProficiencies = const [],
    this.equipmentOptions = const [],
    this.description = '',
  });

  factory BackgroundDto.fromJson(Map<String, dynamic> json) {
    final profs = json['starting_proficiencies'] as List<dynamic>? ?? const [];

    final skillIndices = profs
        .where((e) => (e['index'] as String? ?? '').startsWith('skill-'))
        .map((e) => (e['index'] as String).replaceFirst('skill-', ''))
        .toList();

    final featData = json['feat'] as Map<String, dynamic>?;
    final toolList = (json['tool_proficiencies'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();
    final equipmentList =
        (json['equipment_options'] as List<dynamic>? ?? const [])
            .where(_isNonEmptyOption)
            .toList();
    final abilityOptions =
        (json['ability_options'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();

    return BackgroundDto(
      index: json['index'] ?? '',
      name: json['name'] ?? '',
      skillProficiencyIndices: skillIndices,
      feature: json['feature']?['name'] as String?,
      abilityOptions: abilityOptions,
      featId: featData?['id'] as String?,
      featName: featData?['name'] as String?,
      toolProficiencies: toolList,
      equipmentOptions: equipmentList,
      description: (json['description'] ?? '').toString(),
    );
  }
}

extension BackgroundDtoJson on BackgroundDto {
  Map<String, dynamic> toJson() => {
        'index': index,
        'name': name,
        'starting_proficiencies':
            skillProficiencyIndices.map((e) => {'index': 'skill-$e'}).toList(),
        'feature': feature == null ? null : {'name': feature},
        'ability_options': abilityOptions,
        'feat': featId == null && featName == null
            ? null
            : {'id': featId, 'name': featName},
        'tool_proficiencies': toolProficiencies,
        'equipment_options': equipmentOptions,
        'description': description,
      };
}

bool _isNonEmptyOption(dynamic option) {
  if (option is Map) return option.isNotEmpty;
  return option.toString().trim().isNotEmpty;
}
