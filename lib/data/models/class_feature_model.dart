class ClassFeatureModel {
  final String id;
  final String name;
  final String description;
  final int availableAtLevel;
  final List<String> tags;
  final String? actionType;
  final String? usage;
  final String? resourceCost;
  final String? recharge;
  final String? mechanicalEffect;
  final String? summary;
  final bool showInCombat;
  final String source;

  const ClassFeatureModel({
    required this.id,
    required this.name,
    required this.description,
    required this.availableAtLevel,
    this.tags = const [],
    this.actionType,
    this.usage,
    this.resourceCost,
    this.recharge,
    this.mechanicalEffect,
    this.summary,
    this.showInCombat = false,
    this.source = 'class',
  });
}

class ClassLevelFeatures {
  final int level;
  final List<ClassFeatureModel> features;

  const ClassLevelFeatures({
    required this.level,
    required this.features,
  });
}
