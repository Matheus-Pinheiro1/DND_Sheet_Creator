class FeatModel {
  final String id;
  final String name;
  final String description;
  final List<String> tags;
  final List<String> optionalAbilityBonuses;
  final int minimumLevel;
  final String prerequisite;

  const FeatModel({
    required this.id,
    required this.name,
    required this.description,
    this.tags = const [],
    this.optionalAbilityBonuses = const [],
    this.minimumLevel = 1,
    this.prerequisite = '',
  });

  factory FeatModel.fromJson(Map<String, dynamic> json) => FeatModel(
        id: _string(json['id']),
        name: _string(json['name']),
        description: _string(json['description']),
        tags: _stringList(json['tags']),
        optionalAbilityBonuses: _stringList(json['optional_ability_bonuses']),
        minimumLevel: _int(json['minimum_level'], fallback: 1),
        prerequisite: _string(json['prerequisite']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'tags': tags,
        'optional_ability_bonuses': optionalAbilityBonuses,
        'minimum_level': minimumLevel,
        'prerequisite': prerequisite,
      };

  static String _string(dynamic value) => value?.toString() ?? '';

  static int _int(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((entry) => entry.toString()).toList();
  }
}
