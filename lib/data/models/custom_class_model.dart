import 'package:hive/hive.dart';
import '../../core/constants/hive_constants.dart';

part 'custom_class_model.g.dart';

@HiveType(typeId: HiveConstants.customClassTypeId)
class CustomClassModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int hitDie;
  @HiveField(3)
  final List<String> savingThrows;
  @HiveField(4)
  final String? spellcastingAbility;
  @HiveField(5)
  final String description;
  @HiveField(6)
  final List<String> features;
  @HiveField(7)
  final List<String> proficiencies;

  CustomClassModel({
    required this.id,
    required this.name,
    this.hitDie = 8,
    List<String>? savingThrows,
    this.spellcastingAbility,
    this.description = '',
    List<String>? features,
    List<String>? proficiencies,
  })  : savingThrows = savingThrows ?? const [],
        features = features ?? const [],
        proficiencies = proficiencies ?? const [];
}
