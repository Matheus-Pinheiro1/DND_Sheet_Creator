import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/utils/dice_calculator.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/data/local/feats_data.dart';
import 'package:dnd_character_sheet/data/models/character_model.dart';
import 'package:dnd_character_sheet/data/models/class_feature_model.dart';
import 'package:dnd_character_sheet/data/models/feat_model.dart';
import 'package:dnd_character_sheet/data/remote/spell_dto.dart';
import 'package:dnd_character_sheet/data/remote/race_dto.dart';
import 'package:dnd_character_sheet/data/services/barbarian_choice_service.dart';
import 'package:dnd_character_sheet/data/services/bard_choice_service.dart';
import 'package:dnd_character_sheet/data/services/cleric_choice_service.dart';
import 'package:dnd_character_sheet/data/services/class_features_service.dart';
import 'package:dnd_character_sheet/data/services/druid_choice_service.dart';
import 'package:dnd_character_sheet/data/services/fighter_choice_service.dart';
import 'package:dnd_character_sheet/data/services/level_advancement_service.dart';
import 'package:dnd_character_sheet/data/services/monk_choice_service.dart';
import 'package:dnd_character_sheet/data/services/paladin_choice_service.dart';
import 'package:dnd_character_sheet/data/services/progression_service.dart';
import 'package:dnd_character_sheet/data/services/ranger_choice_service.dart';
import 'package:dnd_character_sheet/data/services/rogue_choice_service.dart';
import 'package:dnd_character_sheet/data/services/sorcerer_choice_service.dart';
import 'package:dnd_character_sheet/data/services/warlock_choice_service.dart';
import 'package:dnd_character_sheet/data/services/wizard_choice_service.dart';
import 'package:dnd_character_sheet/presentation/screens/shared/dialogs/feature_detail_dialog.dart';
import 'package:dnd_character_sheet/providers/character_providers.dart';
import 'package:dnd_character_sheet/providers/custom_options_providers.dart';
import 'package:dnd_character_sheet/providers/dnd_api_providers.dart';
import 'package:dnd_character_sheet/presentation/screens/shared/widgets/loading_dragon.dart';
part 'widgets/tab_features_basic_widgets.dart';
part 'widgets/tab_features_advancement_section.dart';
part 'widgets/tab_features_advancement_picker.dart';
part 'widgets/tab_features_advancement_feat_choices.dart';
part 'widgets/tab_features_advancement_save.dart';
part 'widgets/tab_features_choice_sections.dart';
part 'helpers/tab_features_decorators.dart';
part 'helpers/tab_features_class_choice_decorators.dart';
part 'helpers/tab_features_barbarian_wizard_bard_decorators.dart';
part 'helpers/tab_features_druid_monk_decorators.dart';
part 'helpers/tab_features_rogue_cleric_fighter_decorators.dart';
part 'helpers/tab_features_paladin_sorcerer_warlock_ranger_decorators.dart';

class TabFeatures extends ConsumerWidget {
  final CharacterModel character;

  const TabFeatures({super.key, required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(classFeaturesServiceProvider);

    if (character.className.startsWith('custom_class_')) {
      final customId = character.className.replaceFirst('custom_class_', '');
      final customClasses = ref.watch(customClassesProvider);
      dynamic customClass;
      for (final item in customClasses) {
        if (item.id == customId) {
          customClass = item;
          break;
        }
      }
      final homebrewFeatures = (customClass?.features ?? const <String>[])
          .map((name) => service.buildHomebrewFeature(name))
          .toList();

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(level: character.level),
            const SizedBox(height: 16),
            ..._buildSpeciesSection(ref),
            if (homebrewFeatures.isNotEmpty)
              _LevelFeatureCard(
                title: 'Homebrew Class Features',
                subtitle: customClass?.description.isNotEmpty == true
                    ? customClass!.description
                    : 'Features configured in your custom class.',
                features: homebrewFeatures,
              )
            else
              const _EmptyFeaturesState(
                title: 'No homebrew features yet',
                subtitle:
                    'Open the custom class editor and add a few features to show them here.',
              ),
            const SizedBox(height: 16),
            _AdvancementSection(character: character),
          ],
        ),
      );
    }

    final classAsync = ref.watch(
      classFeatureProgressionProvider(
          (className: character.className, level: character.level)),
    );
    final subclassAsync = ref.watch(
      subclassFeatureProgressionProvider(
          (subclass: character.subclass, level: character.level)),
    );
    return classAsync.when(
      loading: () =>
          const Center(child: LoadingDragon(label: 'Loading features...')),
      error: (_, __) => _buildFallback(ref),
      data: (classProgression) {
        return subclassAsync.when(
          loading: () => _buildContent(
            ref: ref,
            baseFeatures: classProgression,
            subclassFeatures: const [],
          ),
          error: (_, __) => _buildContent(
            ref: ref,
            baseFeatures: classProgression,
            subclassFeatures: const [],
          ),
          data: (subclassProgression) => _buildContent(
            ref: ref,
            baseFeatures: classProgression,
            subclassFeatures: subclassProgression,
          ),
        );
      },
    );
  }

  List<Widget> _buildSpeciesSection(WidgetRef ref) {
    final speciesWidgets = <Widget>[];

    if (character.race.trim().isEmpty) return const [];

    if (character.race.startsWith('custom_')) {
      final customId = character.race.replaceFirst('custom_', '');
      final customRaces = ref.watch(customRacesProvider);
      dynamic customRace;
      for (final race in customRaces) {
        if (race.id == customId) {
          customRace = race;
          break;
        }
      }
      if (customRace != null) {
        final features = (customRace.traits as List<String>)
            .where((trait) => trait.trim().isNotEmpty)
            .map(
              (trait) => ClassFeatureModel(
                id: 'species_${customRace.id}_${trait.toLowerCase().replaceAll(' ', '_')}',
                name: trait,
                description:
                    (customRace.description as String).trim().isNotEmpty
                        ? customRace.description as String
                        : trait,
                availableAtLevel: 1,
                tags: const ['Species'],
                source: 'species',
              ),
            )
            .toList();
        if (features.isNotEmpty) {
          speciesWidgets.add(
            _LevelFeatureCard(
              title:
                  '${character.raceName.isNotEmpty ? character.raceName : customRace.name} Traits',
              subtitle: 'Species features chosen at character creation.',
              features: features,
            ),
          );
          speciesWidgets.add(const SizedBox(height: 16));
        }
      }
      return speciesWidgets;
    }

    final racesAsync = ref.watch(racesProvider);
    return racesAsync.when(
      loading: () => const [],
      error: (_, __) => const [],
      data: (races) {
        final race = _findOfficialRace(races);
        if (race == null) return const [];
        final features = _buildSpeciesFeatures(race);
        if (features.isEmpty) return const [];
        return [
          _LevelFeatureCard(
            title:
                '${character.raceName.isNotEmpty ? character.raceName : race.name} Traits',
            subtitle: _speciesSubtitle(race),
            features: features,
          ),
          const SizedBox(height: 16),
        ];
      },
    );
  }

  RaceDto? _findOfficialRace(List<RaceDto> races) {
    final baseRaceId = _selectedBaseRaceId(character.race);
    for (final race in races) {
      if (race.index == baseRaceId) return race;
    }
    return null;
  }

  List<ClassFeatureModel> _buildSpeciesFeatures(RaceDto race) {
    final features = <ClassFeatureModel>[];
    for (final trait in race.traits) {
      final detail = (race.traitDetails[trait.index] ?? '').trim();
      if (detail.isEmpty) continue;
      features.add(
        ClassFeatureModel(
          id: 'species_${race.index}_${trait.index}',
          name: trait.name,
          description: detail,
          availableAtLevel: 1,
          tags: const ['Species'],
          source: 'species',
        ),
      );
    }

    final optionIds = _selectedOptionIds(character.race);
    if (optionIds.length >= 2) {
      final optionGroup = race.optionGroups
              .where((group) => group.id == optionIds[0])
              .isEmpty
          ? null
          : race.optionGroups.firstWhere((group) => group.id == optionIds[0]);
      if (optionGroup != null) {
        final option = optionGroup.options
                .where((item) => item.id == optionIds[1])
                .isEmpty
            ? null
            : optionGroup.options.firstWhere((item) => item.id == optionIds[1]);
        if (option != null && option.details.trim().isNotEmpty) {
          features.insert(
            0,
            ClassFeatureModel(
              id: 'species_option_${race.index}_${optionGroup.id}_${option.id}',
              name: '${optionGroup.label}: ${option.name}',
              description: option.details,
              availableAtLevel: 1,
              tags: const ['Species Option'],
              summary: option.summary,
              source: 'species',
            ),
          );
        }
      }
    }

    final grantedCantrip =
        _selectedChoiceValue('species_choice:granted_cantrip:');
    if (grantedCantrip.isNotEmpty) {
      features.insert(
        0,
        ClassFeatureModel(
          id: 'species_choice_cantrip',
          name: 'Granted Cantrip',
          description: 'Chosen spell: ${grantedCantrip.replaceAll('-', ' ')}.',
          availableAtLevel: 1,
          tags: const ['Species Choice'],
          source: 'species',
        ),
      );
    }

    final humanSkill = _selectedChoiceValue('species_choice:skillful:');
    if (humanSkill.isNotEmpty) {
      features.insert(
        0,
        ClassFeatureModel(
          id: 'species_choice_skillful',
          name: 'Skillful Choice',
          description: 'Chosen skill proficiency: ${_skillName(humanSkill)}.',
          availableAtLevel: 1,
          tags: const ['Species Choice'],
          source: 'species',
        ),
      );
    }

    final humanFeat = _selectedChoiceValue('species_choice:versatile_feat:');
    if (humanFeat.isNotEmpty) {
      final feat = _findFeat(humanFeat);
      features.insert(
        0,
        ClassFeatureModel(
          id: 'species_choice_versatile_feat',
          name: 'Versatile Choice',
          description: feat == null
              ? 'Chosen Origin Feat: ${humanFeat.replaceAll('-', ' ')}.'
              : 'Chosen Origin Feat: ${feat.name}.\n${feat.description}',
          availableAtLevel: 1,
          tags: const ['Species Choice'],
          source: 'species',
        ),
      );
    }

    return features;
  }

  String _selectedChoiceValue(String prefix) {
    for (final entry in character.levelAdvancements.reversed) {
      if (entry.startsWith(prefix)) {
        return entry.replaceFirst(prefix, '');
      }
    }
    return '';
  }

  FeatModel? _findFeat(String id) {
    for (final feat in kFeatCatalog) {
      if (feat.id == id) return feat;
    }
    return null;
  }

  String _skillName(String index) {
    const labels = {
      'acrobatics': 'Acrobatics',
      'animal-handling': 'Animal Handling',
      'arcana': 'Arcana',
      'athletics': 'Athletics',
      'deception': 'Deception',
      'history': 'History',
      'insight': 'Insight',
      'intimidation': 'Intimidation',
      'investigation': 'Investigation',
      'medicine': 'Medicine',
      'nature': 'Nature',
      'perception': 'Perception',
      'performance': 'Performance',
      'persuasion': 'Persuasion',
      'religion': 'Religion',
      'sleight-of-hand': 'Sleight of Hand',
      'stealth': 'Stealth',
      'survival': 'Survival',
    };
    return labels[index] ?? index;
  }

  String _speciesSubtitle(RaceDto race) {
    final optionIds = _selectedOptionIds(character.race);
    if (optionIds.length >= 2) {
      final optionGroup = race.optionGroups
              .where((group) => group.id == optionIds[0])
              .isEmpty
          ? null
          : race.optionGroups.firstWhere((group) => group.id == optionIds[0]);
      if (optionGroup != null) {
        final option = optionGroup.options
                .where((item) => item.id == optionIds[1])
                .isEmpty
            ? null
            : optionGroup.options.firstWhere((item) => item.id == optionIds[1]);
        if (option != null && option.summary.trim().isNotEmpty) {
          return '${optionGroup.label}: ${option.summary}';
        }
        if (option != null) {
          return '${optionGroup.label}: ${option.name}';
        }
      }
    }
    return race.description.isNotEmpty
        ? race.description
        : 'Species features chosen at character creation.';
  }

  String _selectedBaseRaceId(String raceValue) {
    if (!raceValue.contains('::')) return raceValue;
    return raceValue.split('::').first;
  }

  List<String> _selectedOptionIds(String raceValue) {
    final parts = raceValue.split('::');
    if (parts.length < 3) return const [];
    return parts.skip(1).toList();
  }

  Widget _buildFallback(WidgetRef ref) {
    final service = ref.read(classFeaturesServiceProvider);
    final progression = service.getFeatureProgressionUpToLevel(
        character.className, character.level);
    return _buildContent(
      ref: ref,
      baseFeatures: progression,
      subclassFeatures: const [],
    );
  }

  Widget _buildContent({
    required WidgetRef ref,
    required List<ClassLevelFeatures> baseFeatures,
    required List<ClassLevelFeatures> subclassFeatures,
  }) {
    final featureDecorator = _TabFeaturesDecorator(character);
    final decoratedBaseFeatures =
        featureDecorator._decorateClassChoiceFeatures(baseFeatures);
    final decoratedSubclassFeatures =
        featureDecorator._decorateRogueSubclassFeatures(
      featureDecorator._decorateWizardSubclassFeatures(
        featureDecorator._decorateClericSubclassFeatures(
          featureDecorator._decorateDruidSubclassFeatures(
            featureDecorator._decorateMonkSubclassFeatures(
              featureDecorator._decorateBardSubclassFeatures(
                featureDecorator._decorateSorcererSubclassFeatures(
                  featureDecorator._decorateWarlockSubclassFeatures(
                    featureDecorator._decorateRangerSubclassFeatures(
                      featureDecorator._decoratePaladinSubclassFeatures(
                        featureDecorator._decorateFighterSubclassFeatures(
                          featureDecorator._decorateBarbarianSubclassFeatures(
                            subclassFeatures,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderCard(level: character.level),
          const SizedBox(height: 16),
          ..._buildSpeciesSection(ref),
          if (decoratedBaseFeatures.isEmpty &&
              decoratedSubclassFeatures.isEmpty)
            const _EmptyFeaturesState(
              title: 'No class features found',
              subtitle:
                  'No local or API feature progression was available for this class yet.',
            )
          else ...[
            if (decoratedBaseFeatures.isNotEmpty) ...[
              Text(
                'Class Progression',
                style: AppTextStyles.cinzel(
                  color: AppTheme.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...decoratedBaseFeatures.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LevelFeatureCard(
                    title: 'Level ${entry.level}',
                    subtitle: entry.features.map((f) => f.name).join(' • '),
                    features: entry.features,
                  ),
                ),
              ),
            ],
            if (character.level >= 3 && character.subclass.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Text(
                  'This character is high enough level to have a subclass. Open Edit Character → Class and choose one to unlock subclass features here.',
                  style: AppTextStyles.lato(
                    color: Colors.orange.shade200,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ] else if (decoratedSubclassFeatures.isNotEmpty ||
                character.subclass.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                character.subclassName.isNotEmpty
                    ? '${character.subclassName} Features'
                    : 'Subclass Features',
                style: AppTextStyles.cinzel(
                  color: AppTheme.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Unlocked subclass features for this character level.',
                style: AppTextStyles.lato(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              if (decoratedSubclassFeatures.isNotEmpty)
                ...decoratedSubclassFeatures.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LevelFeatureCard(
                      title: 'Unlocked at level ${entry.level}',
                      subtitle: entry.features.map((f) => f.name).join(' • '),
                      features: entry.features,
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    'This subclass can be selected now, but its local feature text has not been filled yet. Add the detailed entries in assets/data/2024/subclasses.json and they will show here automatically.',
                    style: AppTextStyles.lato(
                      color: Colors.orange.shade200,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          ],
          const SizedBox(height: 12),
          _AdvancementSection(character: character),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
