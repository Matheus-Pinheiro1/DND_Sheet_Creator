import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/presentation/screens/shared/widgets/loading_dragon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dice_calculator.dart';
import '../../../../providers/character_creation_provider.dart';
import '../../../../data/services/artificer_choice_service.dart';
import '../../../../data/services/barbarian_choice_service.dart';
import '../../../../data/services/bard_choice_service.dart';
import '../../../../data/services/cleric_choice_service.dart';
import '../../../../data/services/druid_choice_service.dart';
import '../../../../data/services/fighter_choice_service.dart';
import '../../../../data/services/monk_choice_service.dart';
import '../../../../data/services/paladin_choice_service.dart';
import '../../../../data/services/ranger_choice_service.dart';
import '../../../../data/services/rogue_choice_service.dart';
import '../../../../data/services/wizard_choice_service.dart';
import '../../../../data/local/feats_data.dart';
import '../../../../providers/dnd_api_providers.dart';

part 'helpers/step_skills_choice_helpers.dart';
part 'helpers/step_skills_origin_helpers.dart';
part 'helpers/step_skills_bard_rogue_ranger_helpers.dart';
part 'widgets/step_skills_widgets.dart';

class StepSkills extends ConsumerWidget {
  const StepSkills({super.key});

  static const _skillAbility = {
    'acrobatics': 'dex',
    'animal-handling': 'wis',
    'arcana': 'int',
    'athletics': 'str',
    'deception': 'cha',
    'history': 'int',
    'insight': 'wis',
    'intimidation': 'cha',
    'investigation': 'int',
    'medicine': 'wis',
    'nature': 'int',
    'perception': 'wis',
    'performance': 'cha',
    'persuasion': 'cha',
    'religion': 'int',
    'sleight-of-hand': 'dex',
    'stealth': 'dex',
    'survival': 'wis',
  };

  static const _skillLabels = {
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

  static const _artisanTools = [
    "Alchemist's Supplies",
    "Brewer's Supplies",
    "Calligrapher's Supplies",
    "Carpenter's Tools",
    "Cartographer's Tools",
    "Cobbler's Tools",
    "Cook's Utensils",
    "Glassblower's Tools",
    "Jeweler's Tools",
    "Leatherworker's Tools",
    "Mason's Tools",
    "Painter's Supplies",
    "Potter's Tools",
    "Smith's Tools",
    "Tinker's Tools",
    "Weaver's Tools",
    "Woodcarver's Tools",
  ];

  static const _musicalInstruments = [
    'Bagpipes',
    'Drum',
    'Dulcimer',
    'Flute',
    'Horn',
    'Lute',
    'Lyre',
    'Pan Flute',
    'Shawm',
    'Viol',
  ];

  int _getScore(CreationState state, String ability) {
    switch (ability) {
      case 'str':
        return state.strength;
      case 'dex':
        return state.dexterity;
      case 'con':
        return state.constitution;
      case 'int':
        return state.intelligence;
      case 'wis':
        return state.wisdom;
      case 'cha':
        return state.charisma;
      default:
        return 10;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillsAsync = ref.watch(skillsProvider);
    final state = ref.watch(creationProvider);
    final profBonus = DiceCalculator.getProficiencyBonus(state.level);

    return skillsAsync.when(
      loading: () => const Center(child: LoadingDragon(label: 'Loading...')),
      error: (_, __) => Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 8),
            const Text('Failed to load skills.'),
            ElevatedButton(
              onPressed: () => ref.invalidate(skillsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (skills) {
        final originSkillChoices = _originSkillChoices(state);
        final speciesSkillChoices = _speciesSkillChoices(state);
        final classChoiceSkills = _classChoiceSkills(state);
        final chosenCount = state.proficientSkills.length;
        final bgCount = state.backgroundSkillProfs.length;
        final originCount = originSkillChoices.length;
        final hasJackOfAllTrades = BardChoiceService.hasJackOfAllTrades(
          className: state.className,
          level: state.level,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkillSummaryCard(
              proficiencyBonus: profBonus,
              backgroundCount: bgCount,
              chosenCount: chosenCount,
              originCount: originCount,
            ),
            const SizedBox(height: 12),
            _originFeatChoiceCard(state, ref),
            if (_originFeatNeedsChoices(state.backgroundFeatId))
              const SizedBox(height: 12),
            ..._humanSpeciesChoiceCards(state, ref),
            _wizardScholarChoiceCard(state, ref),
            if (WizardChoiceService.needsScholar(
              className: state.className,
              level: state.level,
            ))
              const SizedBox(height: 12),
            ..._bardLoreBonusSkillChoiceCards(state, ref),
            ..._bardMoonPrimalLoreSkillCards(state, ref),
            ..._bardExpertiseChoiceCards(state, ref),
            ..._clericKnowledgeChoiceCards(state, ref),
            ..._fighterBattleMasterStudentChoiceCards(state, ref),
            ..._paladinGenieSplendorChoiceCards(state, ref),
            ..._rangerFeyGlamourChoiceCards(state, ref),
            ..._rogueExpertiseChoiceCards(state, ref),
            ..._rangerChoiceCards(state, ref),
            ..._barbarianChoiceCards(state, ref),
            ...skills.map((skill) {
              final index = skill['index']!;
              final name = skill['name']!;
              final ability = _skillAbility[index] ?? 'str';
              final score = _getScore(state, ability);
              final mod = DiceCalculator.getModifier(score);

              final isFromBackground =
                  state.backgroundSkillProfs.contains(index);
              final isFromOriginFeat = originSkillChoices.contains(index);
              final isFromSpeciesChoice = speciesSkillChoices.contains(index);
              final isFromClassChoice = classChoiceSkills.contains(index);
              final isChosen = state.proficientSkills.contains(index);
              final isProficient = isFromBackground ||
                  isFromOriginFeat ||
                  isFromSpeciesChoice ||
                  isFromClassChoice ||
                  isChosen;
              final druidMagicianBonus = DruidChoiceService.magicianSkillBonus(
                className: state.className,
                level: state.level,
                entries: state.levelAdvancements,
                wisdom: state.wisdom,
                skillIndex: index,
              );
              final total = (isProficient
                      ? mod + profBonus
                      : mod + (hasJackOfAllTrades ? profBonus ~/ 2 : 0)) +
                  druidMagicianBonus;

              return _SkillTile(
                index: index,
                name: name,
                ability: ability.toUpperCase(),
                total: total,
                isProficient: isProficient,
                isFromBackground: isFromBackground,
                isFromOriginFeat: isFromOriginFeat,
                isFromSpeciesChoice: isFromSpeciesChoice,
                isFromClassChoice: isFromClassChoice,
                onToggle: isFromBackground ||
                        isFromOriginFeat ||
                        isFromSpeciesChoice ||
                        isFromClassChoice
                    ? null
                    : () => ref
                        .read(creationProvider.notifier)
                        .toggleSkillProficiency(index),
              );
            }),
          ],
        );
      },
    );
  }
}
