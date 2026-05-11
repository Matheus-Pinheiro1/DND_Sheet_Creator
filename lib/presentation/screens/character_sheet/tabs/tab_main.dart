import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dice_calculator.dart';
import '../../../../data/models/character_model.dart';
import '../../../../data/services/bard_choice_service.dart';
import '../../../../data/services/druid_choice_service.dart';
import '../../../../data/services/ranger_choice_service.dart';
import '../../../../providers/character_providers.dart';
import '../../shared/dialogs/dice_roller_sheet.dart';
import '../../shared/widgets/character_avatar.dart';
import '../../shared/widgets/skill_row.dart';
import '../../shared/widgets/stat_box.dart';
part 'widgets/tab_main_widgets.dart';

class TabMain extends ConsumerWidget {
  final CharacterModel character;
  const TabMain({super.key, required this.character});

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

  int _getScore(String ability) {
    switch (ability) {
      case 'str':
        return character.strength;
      case 'dex':
        return character.dexterity;
      case 'con':
        return character.constitution;
      case 'int':
        return character.intelligence;
      case 'wis':
        return character.wisdom;
      case 'cha':
        return character.charisma;
      default:
        return 10;
    }
  }

  bool _isProficient(String skillIndex) =>
      character.allProficientSkills.contains(skillIndex);

  bool _hasExpertise(String skillIndex) {
    final label = skillIndex
        .split('-')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
    return character.proficiencies.contains('Expertise: $label');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profBonus = DiceCalculator.getProficiencyBonus(character.level);
    final auraOfProtectionBonus = character.className.trim().toLowerCase() ==
                'paladin' &&
            character.level >= 6
        ? DiceCalculator.getModifier(character.charisma).clamp(1, 99).toInt()
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CharacterHeader(
              character: character, profBonus: profBonus, ref: ref),
          const SizedBox(height: 16),
          _QuickStatsCard(character: character, profBonus: profBonus),
          const SizedBox(height: 16),
          const _SectionTitle('Ability Scores'),
          _AbilityScoresGrid(character: character),
          const SizedBox(height: 16),
          const _SectionTitle('Saving Throws'),
          _SectionCard(children: [
            if (auraOfProtectionBonus > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Aura of Protection: +$auraOfProtectionBonus to your saving throws.',
                  style: AppTextStyles.lato(
                    color: AppTheme.gold,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),
            ...[
              ('Strength', 'str'),
              ('Dexterity', 'dex'),
              ('Constitution', 'con'),
              ('Intelligence', 'int'),
              ('Wisdom', 'wis'),
              ('Charisma', 'cha'),
            ].map((pair) {
              final score = _getScore(pair.$2);
              final mod = DiceCalculator.getModifier(score);
              final isSaveProficient =
                  character.savingThrowProfs.contains(pair.$2);
              final exhaustionPenalty = character.exhaustionLevel * 2;
              final total = (isSaveProficient ? mod + profBonus : mod) -
                  exhaustionPenalty +
                  auraOfProtectionBonus;
              return _ProficiencyRow(
                name: pair.$1,
                badge: pair.$2.toUpperCase(),
                value: total,
                proficient: isSaveProficient,
                onTap: () => showDiceRollerSheet(
                  context,
                  title: '${pair.$1} Save',
                  initialSides: 20,
                  initialModifier: total,
                ),
              );
            }),
          ]),
          const SizedBox(height: 16),
          const _SectionTitle('Skills'),
          _SectionCard(children: [
            ..._skillAbility.entries.map((e) {
              final score = _getScore(e.value);
              final mod = DiceCalculator.getModifier(score);
              final proficient = _isProficient(e.key);
              final expertise = _hasExpertise(e.key);
              final jackOfAllTrades = BardChoiceService.hasJackOfAllTrades(
                className: character.className,
                level: character.level,
              );
              final exhaustionPenalty = character.exhaustionLevel * 2;
              final druidMagicianBonus = DruidChoiceService.magicianSkillBonus(
                className: character.className,
                level: character.level,
                entries: character.levelAdvancements,
                wisdom: character.wisdom,
                skillIndex: e.key,
              );
              final rangerGlamourBonus =
                  RangerChoiceService.otherworldlyGlamourSkillBonus(
                className: character.className,
                subclass: character.subclass,
                level: character.level,
                wisdom: character.wisdom,
                ability: e.value,
              );
              final proficiencyBonus = expertise
                  ? profBonus * 2
                  : proficient
                      ? profBonus
                      : jackOfAllTrades
                          ? profBonus ~/ 2
                          : 0;
              final total = mod +
                  proficiencyBonus +
                  druidMagicianBonus -
                  exhaustionPenalty +
                  rangerGlamourBonus;
              final isFromBG = character.backgroundSkillProfs.contains(e.key);
              final label = e.key
                  .split('-')
                  .map((w) => w[0].toUpperCase() + w.substring(1))
                  .join(' ');
              return _ProficiencyRow(
                name: label,
                badge: e.value.toUpperCase(),
                value: total,
                proficient: proficient,
                fromBackground: isFromBG,
                onTap: () => showDiceRollerSheet(
                  context,
                  title: '$label Check',
                  initialSides: 20,
                  initialModifier: total,
                ),
              );
            }),
          ]),
          const SizedBox(height: 16),
          if (_hasPersonality) ...[
            const _SectionTitle('Personality'),
            _SectionCard(children: [
              if (character.personalityTraits.isNotEmpty)
                _PersonalityBlock('Traits', character.personalityTraits),
              if (character.ideals.isNotEmpty)
                _PersonalityBlock('Ideals', character.ideals),
              if (character.bonds.isNotEmpty)
                _PersonalityBlock('Bonds', character.bonds),
              if (character.flaws.isNotEmpty)
                _PersonalityBlock('Flaws', character.flaws),
            ]),
            const SizedBox(height: 16),
          ],
          if (character.backstory.isNotEmpty) ...[
            const _SectionTitle('Backstory'),
            _SectionCard(children: [
              Text(
                character.backstory,
                style: AppTextStyles.lato(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ]),
            const SizedBox(height: 16),
          ],
          if (character.languages.isNotEmpty) ...[
            const _SectionTitle('Languages'),
            _SectionCard(children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: character.languages
                    .map((l) => _Chip(l, AppTheme.gold.withValues(alpha: 0.16),
                        AppTheme.gold))
                    .toList(),
              ),
            ]),
            const SizedBox(height: 16),
          ],
          if (character.proficiencies.isNotEmpty) ...[
            const _SectionTitle('Other Proficiencies'),
            _SectionCard(children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: character.proficiencies
                    .map((p) => _Chip(p, Colors.white10, Colors.white60))
                    .toList(),
              ),
            ]),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  bool get _hasPersonality =>
      character.personalityTraits.isNotEmpty ||
      character.ideals.isNotEmpty ||
      character.bonds.isNotEmpty ||
      character.flaws.isNotEmpty;
}
