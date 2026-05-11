import 'package:hive/hive.dart';
import '../../core/constants/hive_constants.dart';

part 'custom_race_model.g.dart';

@HiveType(typeId: HiveConstants.customRaceTypeId)
class CustomRaceModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int speed;

  @HiveField(3)
  final String size;

  @HiveField(4)
  final List<String> traits;

  @HiveField(5)
  final String abilityBonuses;

  @HiveField(6)
  final List<String> languages;

  @HiveField(7)
  final String description;

  CustomRaceModel({
    required this.id,
    required this.name,
    this.speed = 30,
    this.size = 'Medium',
    List<String>? traits,
    this.abilityBonuses = '',
    List<String>? languages,
    this.description = '',
  })  : traits = traits ?? [],
        languages = languages ?? [];

  CustomRaceModel copyWith({
    String? id,
    String? name,
    int? speed,
    String? size,
    List<String>? traits,
    String? abilityBonuses,
    List<String>? languages,
    String? description,
  }) {
    return CustomRaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      speed: speed ?? this.speed,
      size: size ?? this.size,
      traits: traits ?? List.from(this.traits),
      abilityBonuses: abilityBonuses ?? this.abilityBonuses,
      languages: languages ?? List.from(this.languages),
      description: description ?? this.description,
    );
  }
}
