import 'package:hive/hive.dart';
import '../../core/constants/hive_constants.dart';

part 'custom_background_model.g.dart';

@HiveType(typeId: HiveConstants.customBgTypeId)
class CustomBackgroundModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> skillProficiencyIndices;

  @HiveField(3)
  final String featureName;

  @HiveField(4)
  final String featureDescription;

  @HiveField(5)
  final String description;

  CustomBackgroundModel({
    required this.id,
    required this.name,
    List<String>? skillProficiencyIndices,
    this.featureName = '',
    this.featureDescription = '',
    this.description = '',
  }) : skillProficiencyIndices = skillProficiencyIndices ?? [];

  CustomBackgroundModel copyWith({
    String? id,
    String? name,
    List<String>? skillProficiencyIndices,
    String? featureName,
    String? featureDescription,
    String? description,
  }) {
    return CustomBackgroundModel(
      id: id ?? this.id,
      name: name ?? this.name,
      skillProficiencyIndices:
          skillProficiencyIndices ?? List.from(this.skillProficiencyIndices),
      featureName: featureName ?? this.featureName,
      featureDescription: featureDescription ?? this.featureDescription,
      description: description ?? this.description,
    );
  }
}
