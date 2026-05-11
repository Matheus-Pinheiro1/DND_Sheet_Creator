import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/class_feature_details_data.dart';
import '../local/class_features_data.dart';
import '../models/class_feature_model.dart';

part 'class_features_action_rules.dart';
part 'class_features_combat_rules.dart';
part 'class_features_description_rules.dart';
part 'class_features_resource_rules.dart';
part 'class_features_tag_rules.dart';

final classFeaturesServiceProvider = Provider<ClassFeaturesService>((ref) {
  return const ClassFeaturesService();
});

class ClassFeaturesService {
  const ClassFeaturesService();

  List<ClassLevelFeatures> getFeatureProgressionUpToLevel(
    String className,
    int level,
  ) {
    final normalizedClassName = _normalize(className);
    final progression = kClassFeatureProgression[normalizedClassName];
    if (progression == null) return const [];

    final levels = progression.keys.toList()..sort();
    return levels
        .where((entryLevel) => entryLevel <= level)
        .map(
          (entryLevel) => ClassLevelFeatures(
            level: entryLevel,
            features: (progression[entryLevel] ?? const <String>[])
                .map(
                  (name) => buildFeature(
                    name: name,
                    level: entryLevel,
                    className: normalizedClassName,
                  ),
                )
                .toList(),
          ),
        )
        .where((entry) => entry.features.isNotEmpty)
        .toList();
  }

  ClassFeatureModel buildFeature({
    required String name,
    required int level,
    String? className,
    String? description,
    String source = 'class',
  }) {
    final normalized = _normalize(name);
    final normalizedClassName =
        className == null ? null : _normalize(className);
    final details = ClassFeatureDetailsData.byName(
      name: name,
      className: normalizedClassName,
    );

    return ClassFeatureModel(
      id: normalized,
      name: name,
      description: description ??
          details?.description ??
          _descriptionFor(name, className: normalizedClassName),
      availableAtLevel: level,
      tags: details?.tags ?? _tagsFor(name),
      actionType: details?.actionType ??
          _actionTypeFor(name, className: normalizedClassName),
      usage: details?.usage ?? _usageFor(name, className: normalizedClassName),
      resourceCost: details?.resourceCost ??
          _resourceCostFor(name, className: normalizedClassName),
      recharge: details?.recharge ??
          _rechargeFor(name, className: normalizedClassName),
      mechanicalEffect: details?.mechanicalEffect ??
          _mechanicalEffectFor(
            name,
            className: normalizedClassName,
          ),
      summary:
          details?.summary ?? _summaryFor(name, className: normalizedClassName),
      showInCombat: details?.showInCombat ??
          _showInCombat(name, className: normalizedClassName),
      source: source,
    );
  }

  ClassFeatureModel buildHomebrewFeature(
    String name, {
    int level = 1,
    String description = '',
  }) {
    return buildFeature(
      name: name,
      level: level,
      description: description.isNotEmpty
          ? description
          : 'No detailed description was added for this homebrew feature yet.',
      source: 'homebrew',
    );
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(' ', '-').replaceAll('_', '-');
  }
}
