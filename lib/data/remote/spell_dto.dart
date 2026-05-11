class SpellDto {
  final String index;
  final String name;
  final int level;
  final String school;
  final String castingTime;
  final String range;
  final String duration;
  final bool ritual;
  final bool concentration;
  final List<String> components;
  final String desc;
  final String? higherLevel;
  final String? damageType;
  final List<String> classIndices;

  const SpellDto({
    required this.index,
    required this.name,
    required this.level,
    required this.school,
    required this.castingTime,
    required this.range,
    required this.duration,
    required this.ritual,
    required this.concentration,
    required this.components,
    required this.desc,
    this.higherLevel,
    this.damageType,
    this.classIndices = const [],
  });

  factory SpellDto.fromJson(Map<String, dynamic> json) {
    final higherLevel = _stringList(json['higher_level']).join('\n').trim();

    return SpellDto(
      index: _string(json['index']),
      name: _string(json['name']),
      level: _int(json['level']),
      school: _schoolName(json['school']),
      castingTime: _string(json['casting_time']),
      range: _string(json['range']),
      duration: _string(json['duration']),
      ritual: _bool(json['ritual']),
      concentration: _bool(json['concentration']),
      components: _stringList(json['components']),
      desc: _stringList(json['desc']).join('\n'),
      higherLevel: higherLevel.isEmpty ? null : higherLevel,
      damageType: _damageType(json['damage']),
      classIndices: _stringList(json['class_indices'])
          .map((e) => e.toLowerCase())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'name': name,
        'level': level,
        'school': {'name': school},
        'casting_time': castingTime,
        'range': range,
        'duration': duration,
        'ritual': ritual,
        'concentration': concentration,
        'components': components,
        'desc': [desc],
        'higher_level': higherLevel != null ? [higherLevel!] : [],
        'damage': damageType != null
            ? {
                'damage_type': {'name': damageType}
              }
            : null,
        'class_indices': classIndices,
      };

  static String _string(dynamic value) => value?.toString() ?? '';

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _bool(dynamic value) {
    if (value is bool) return value;
    return value?.toString().toLowerCase() == 'true';
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((entry) => entry.toString()).toList();
  }

  static String _schoolName(dynamic value) {
    if (value is Map) return _string(value['name']);
    return _string(value);
  }

  static String? _damageType(dynamic value) {
    if (value is! Map) return null;
    final damageType = value['damage_type'];
    if (damageType is Map) return _string(damageType['name']);
    return null;
  }
}
