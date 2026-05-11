part of 'character_creation_provider.dart';

class CreationState {
  final int currentStep;
  final String? editingId;
  final CharacterModel? originalCharacter;

  final String name;
  final String alignment;
  final int level;

  final String race;
  final String raceName;
  final int speed;
  final List<String> languages;

  final String className;
  final String classDisplayName;
  final String subclass;
  final String subclassName;
  final int hitDie;
  final String spellcastingAbility;
  final List<String> savingThrowProfs;
  final List<String> proficiencies;

  final String background;
  final String backgroundName;
  final List<String> backgroundAbilityOptions;
  final String backgroundFeatId;
  final String backgroundFeatName;
  final List<String> backgroundToolProficiencies;
  final List<dynamic> backgroundEquipmentOptions;
  final String classEquipmentChoiceId;
  final String backgroundEquipmentChoiceId;
  final String backgroundBonusMode;
  final List<String> backgroundBonusChoices;

  final List<String> proficientSkills;
  final List<String> backgroundSkillProfs;

  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  final List<String> selectedSpells;
  final String originFeatSpellAbility;
  final List<String> originFeatCantrips;
  final String originFeatSpell;
  final List<String> originFeatChoices;
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

  final String personalityTraits;
  final String ideals;
  final String bonds;
  final String flaws;
  final String backstory;

  final List<String> levelAdvancements;
  final int? preservedCurrentHP;

  const CreationState({
    this.currentStep = 0,
    this.editingId,
    this.originalCharacter,
    this.name = '',
    this.alignment = 'True Neutral',
    this.level = 1,
    this.race = '',
    this.raceName = '',
    this.speed = 30,
    this.languages = const [],
    this.className = '',
    this.classDisplayName = '',
    this.subclass = '',
    this.subclassName = '',
    this.hitDie = 8,
    this.spellcastingAbility = '',
    this.savingThrowProfs = const [],
    this.proficiencies = const [],
    this.background = '',
    this.backgroundName = '',
    this.backgroundAbilityOptions = const [],
    this.backgroundFeatId = '',
    this.backgroundFeatName = '',
    this.backgroundToolProficiencies = const [],
    this.backgroundEquipmentOptions = const [],
    this.classEquipmentChoiceId = '',
    this.backgroundEquipmentChoiceId = '',
    this.backgroundBonusMode = 'plus2plus1',
    this.backgroundBonusChoices = const [],
    this.proficientSkills = const [],
    this.backgroundSkillProfs = const [],
    this.strength = 10,
    this.dexterity = 10,
    this.constitution = 10,
    this.intelligence = 10,
    this.wisdom = 10,
    this.charisma = 10,
    this.selectedSpells = const [],
    this.originFeatSpellAbility = '',
    this.originFeatCantrips = const [],
    this.originFeatSpell = '',
    this.originFeatChoices = const [],
    this.speciesSkillChoice = '',
    this.speciesOriginFeatId = '',
    this.speciesOriginFeatSpellAbility = '',
    this.speciesOriginFeatCantrips = const [],
    this.speciesOriginFeatSpell = '',
    this.speciesOriginFeatChoices = const [],
    this.speciesSpellAbility = '',
    this.speciesGrantedCantrip = '',
    this.clericDivineOrder = '',
    this.clericThaumaturgeCantrip = '',
    this.personalityTraits = '',
    this.ideals = '',
    this.bonds = '',
    this.flaws = '',
    this.backstory = '',
    this.levelAdvancements = const [],
    this.preservedCurrentHP,
  });

  CreationState copyWith({
    int? currentStep,
    String? editingId,
    CharacterModel? originalCharacter,
    String? name,
    String? alignment,
    int? level,
    String? race,
    String? raceName,
    int? speed,
    List<String>? languages,
    String? className,
    String? classDisplayName,
    String? subclass,
    String? subclassName,
    int? hitDie,
    String? spellcastingAbility,
    List<String>? savingThrowProfs,
    List<String>? proficiencies,
    String? background,
    String? backgroundName,
    List<String>? backgroundAbilityOptions,
    String? backgroundFeatId,
    String? backgroundFeatName,
    List<String>? backgroundToolProficiencies,
    List<dynamic>? backgroundEquipmentOptions,
    String? classEquipmentChoiceId,
    String? backgroundEquipmentChoiceId,
    String? backgroundBonusMode,
    List<String>? backgroundBonusChoices,
    List<String>? proficientSkills,
    List<String>? backgroundSkillProfs,
    int? strength,
    int? dexterity,
    int? constitution,
    int? intelligence,
    int? wisdom,
    int? charisma,
    List<String>? selectedSpells,
    String? originFeatSpellAbility,
    List<String>? originFeatCantrips,
    String? originFeatSpell,
    List<String>? originFeatChoices,
    String? speciesSkillChoice,
    String? speciesOriginFeatId,
    String? speciesOriginFeatSpellAbility,
    List<String>? speciesOriginFeatCantrips,
    String? speciesOriginFeatSpell,
    List<String>? speciesOriginFeatChoices,
    String? speciesSpellAbility,
    String? speciesGrantedCantrip,
    String? clericDivineOrder,
    String? clericThaumaturgeCantrip,
    String? personalityTraits,
    String? ideals,
    String? bonds,
    String? flaws,
    String? backstory,
    List<String>? levelAdvancements,
    int? preservedCurrentHP,
  }) {
    return CreationState(
      currentStep: currentStep ?? this.currentStep,
      editingId: editingId ?? this.editingId,
      originalCharacter: originalCharacter ?? this.originalCharacter,
      name: name ?? this.name,
      alignment: alignment ?? this.alignment,
      level: level ?? this.level,
      race: race ?? this.race,
      raceName: raceName ?? this.raceName,
      speed: speed ?? this.speed,
      languages: languages ?? this.languages,
      className: className ?? this.className,
      classDisplayName: classDisplayName ?? this.classDisplayName,
      subclass: subclass ?? this.subclass,
      subclassName: subclassName ?? this.subclassName,
      hitDie: hitDie ?? this.hitDie,
      spellcastingAbility: spellcastingAbility ?? this.spellcastingAbility,
      savingThrowProfs: savingThrowProfs ?? this.savingThrowProfs,
      proficiencies: proficiencies ?? this.proficiencies,
      background: background ?? this.background,
      backgroundName: backgroundName ?? this.backgroundName,
      backgroundAbilityOptions:
          backgroundAbilityOptions ?? this.backgroundAbilityOptions,
      backgroundFeatId: backgroundFeatId ?? this.backgroundFeatId,
      backgroundFeatName: backgroundFeatName ?? this.backgroundFeatName,
      backgroundToolProficiencies:
          backgroundToolProficiencies ?? this.backgroundToolProficiencies,
      backgroundEquipmentOptions:
          backgroundEquipmentOptions ?? this.backgroundEquipmentOptions,
      classEquipmentChoiceId:
          (classEquipmentChoiceId ?? this.classEquipmentChoiceId).toUpperCase(),
      backgroundEquipmentChoiceId:
          (backgroundEquipmentChoiceId ?? this.backgroundEquipmentChoiceId)
              .toUpperCase(),
      backgroundBonusMode: backgroundBonusMode ?? this.backgroundBonusMode,
      backgroundBonusChoices:
          backgroundBonusChoices ?? this.backgroundBonusChoices,
      proficientSkills: proficientSkills ?? this.proficientSkills,
      backgroundSkillProfs: backgroundSkillProfs ?? this.backgroundSkillProfs,
      strength: strength ?? this.strength,
      dexterity: dexterity ?? this.dexterity,
      constitution: constitution ?? this.constitution,
      intelligence: intelligence ?? this.intelligence,
      wisdom: wisdom ?? this.wisdom,
      charisma: charisma ?? this.charisma,
      selectedSpells: selectedSpells ?? this.selectedSpells,
      originFeatSpellAbility:
          originFeatSpellAbility ?? this.originFeatSpellAbility,
      originFeatCantrips: originFeatCantrips ?? this.originFeatCantrips,
      originFeatSpell: originFeatSpell ?? this.originFeatSpell,
      originFeatChoices: originFeatChoices ?? this.originFeatChoices,
      speciesSkillChoice: speciesSkillChoice ?? this.speciesSkillChoice,
      speciesOriginFeatId: speciesOriginFeatId ?? this.speciesOriginFeatId,
      speciesOriginFeatSpellAbility:
          speciesOriginFeatSpellAbility ?? this.speciesOriginFeatSpellAbility,
      speciesOriginFeatCantrips:
          speciesOriginFeatCantrips ?? this.speciesOriginFeatCantrips,
      speciesOriginFeatSpell:
          speciesOriginFeatSpell ?? this.speciesOriginFeatSpell,
      speciesOriginFeatChoices:
          speciesOriginFeatChoices ?? this.speciesOriginFeatChoices,
      speciesSpellAbility: speciesSpellAbility ?? this.speciesSpellAbility,
      speciesGrantedCantrip:
          speciesGrantedCantrip ?? this.speciesGrantedCantrip,
      clericDivineOrder: clericDivineOrder ?? this.clericDivineOrder,
      clericThaumaturgeCantrip:
          clericThaumaturgeCantrip ?? this.clericThaumaturgeCantrip,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      ideals: ideals ?? this.ideals,
      bonds: bonds ?? this.bonds,
      flaws: flaws ?? this.flaws,
      backstory: backstory ?? this.backstory,
      levelAdvancements: levelAdvancements ?? this.levelAdvancements,
      preservedCurrentHP: preservedCurrentHP ?? this.preservedCurrentHP,
    );
  }
}
