part of 'character_creation_provider.dart';

class _AdjustedAbilities {
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  const _AdjustedAbilities({
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
  });
}

class _ParsedOriginChoices {
  final String backgroundFeatId;
  final String backgroundFeatName;
  final String originFeatSpellAbility;
  final List<String> originCantrips;
  final String originSpell;
  final List<String> originFeatChoices;
  final List<String> backgroundBonusChoices;
  final String speciesSkillChoice;
  final String speciesOriginFeatId;
  final String speciesOriginFeatSpellAbility;
  final List<String> speciesOriginFeatCantrips;
  final String speciesOriginFeatSpell;
  final List<String> speciesOriginFeatChoices;
  final String speciesSpellAbility;
  final String speciesGrantedCantrip;
  final String clericDivineOrder;
  final String clericThaumaturgeCantrip;

  const _ParsedOriginChoices({
    required this.backgroundFeatId,
    required this.backgroundFeatName,
    required this.originFeatSpellAbility,
    required this.originCantrips,
    required this.originSpell,
    required this.originFeatChoices,
    required this.backgroundBonusChoices,
    required this.speciesSkillChoice,
    required this.speciesOriginFeatId,
    required this.speciesOriginFeatSpellAbility,
    required this.speciesOriginFeatCantrips,
    required this.speciesOriginFeatSpell,
    required this.speciesOriginFeatChoices,
    required this.speciesSpellAbility,
    required this.speciesGrantedCantrip,
    required this.clericDivineOrder,
    required this.clericThaumaturgeCantrip,
  });
}
