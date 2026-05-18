part of 'character_creation_provider.dart';

class CreationNotifier extends StateNotifier<CreationState> {
  CreationNotifier() : super(const CreationState());

  CreationState get _notifierState => state;
  set _notifierState(CreationState value) => state = value;

  void setStep(int step) {
    state = state.copyWith(currentStep: step.clamp(0, 99).toInt());
  }

  void nextStep() => setStep(state.currentStep + 1);
  void prevStep() => setStep(state.currentStep - 1);

  void setBasicInfo({
    required String name,
    required String alignment,
    required int level,
  }) {
    state = state.copyWith(name: name, alignment: alignment, level: level);
  }

  void setRace({
    required String race,
    required String raceName,
    required int speed,
    required List<String> languages,
  }) {
    state = state.copyWith(
      race: race,
      raceName: raceName,
      speed: speed,
      languages: languages,
      speciesSkillChoice: '',
      speciesOriginFeatId: '',
      speciesOriginFeatSpellAbility: '',
      speciesOriginFeatCantrips: const [],
      speciesOriginFeatSpell: '',
      speciesOriginFeatChoices: const [],
      speciesSpellAbility: '',
      speciesGrantedCantrip: '',
    );
  }

  void setSpeciesOption({
    required String baseRace,
    required String baseRaceName,
    required String optionGroupId,
    required String optionId,
    required String optionName,
    required int speed,
    required List<String> languages,
  }) {
    final raceValue = '$baseRace::$optionGroupId::$optionId';
    state = state.copyWith(
      race: raceValue,
      raceName: '$baseRaceName ($optionName)',
      speed: speed,
      languages: languages,
      speciesSkillChoice: '',
      speciesOriginFeatId: '',
      speciesOriginFeatSpellAbility: '',
      speciesOriginFeatCantrips: const [],
      speciesOriginFeatSpell: '',
      speciesOriginFeatChoices: const [],
      speciesSpellAbility: '',
      speciesGrantedCantrip: '',
    );
  }

  void setSpeciesExtraLanguage(String language) {
    final clean = language.trim();
    if (clean.isEmpty) return;

    final baseRace =
        state.race.contains('::') ? state.race.split('::').first : state.race;

    if (baseRace == 'human') {
      state = state.copyWith(languages: ['Common', clean]);
      return;
    }

    final next = <String>[];
    var inserted = false;
    for (final item in state.languages) {
      if (_isSpeciesLanguagePlaceholder(item)) {
        if (!inserted) {
          next.add(clean);
          inserted = true;
        }
      } else {
        next.add(item);
      }
    }
    if (!inserted) next.add(clean);

    state = state.copyWith(languages: _uniqueStrings(next));
  }

  bool _isSpeciesLanguagePlaceholder(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.contains('extra language') ||
        normalized.contains('language of your choice');
  }

  List<String> _uniqueStrings(Iterable<String> values) {
    final seen = <String>{};
    final result = <String>[];
    for (final value in values) {
      final clean = value.trim();
      if (clean.isEmpty) continue;
      final key = clean.toLowerCase();
      if (seen.add(key)) result.add(clean);
    }
    return result;
  }

  void setClass({
    required String className,
    required String classDisplayName,
    required int hitDie,
    required String spellcastingAbility,
    required List<String> savingThrows,
    required List<String> proficiencies,
  }) {
    final classChanged = state.className != className;
    final nextAdvancements = List<String>.from(state.levelAdvancements);
    if (classChanged || className != 'wizard') {
      nextAdvancements.removeWhere((entry) =>
          entry.startsWith(WizardChoiceService.scholarEntryPrefix) ||
          entry.startsWith(WizardChoiceService.savantEntryPrefix) ||
          entry.startsWith(WizardChoiceService.illusionistCantripPrefix));
    }
    if (classChanged || className != 'rogue') {
      nextAdvancements.removeWhere(RogueChoiceService.isRogueChoiceEntry);
    }
    if (classChanged || className != 'cleric') {
      nextAdvancements.removeWhere(ClericChoiceService.isClericChoiceEntry);
    }
    if (classChanged || className != 'bard') {
      nextAdvancements.removeWhere(BardChoiceService.isBardChoiceEntry);
    }
    if (classChanged || className != 'druid') {
      nextAdvancements.removeWhere(DruidChoiceService.isDruidChoiceEntry);
    }
    if (classChanged || className != 'sorcerer') {
      nextAdvancements.removeWhere(SorcererChoiceService.isSorcererChoiceEntry);
    }
    if (classChanged || className != 'warlock') {
      nextAdvancements.removeWhere(WarlockChoiceService.isWarlockChoiceEntry);
    }
    if (classChanged || className != 'ranger') {
      nextAdvancements.removeWhere(RangerChoiceService.isRangerChoiceEntry);
    }
    if (classChanged || className != 'barbarian') {
      nextAdvancements.removeWhere(
        BarbarianChoiceService.isBarbarianChoiceEntry,
      );
    }
    if (classChanged || className != 'fighter') {
      nextAdvancements.removeWhere(FighterChoiceService.isFighterChoiceEntry);
    }
    if (classChanged || className != 'paladin') {
      nextAdvancements.removeWhere(PaladinChoiceService.isPaladinChoiceEntry);
    }
    if (classChanged || className != 'artificer') {
      nextAdvancements.removeWhere(
        ArtificerChoiceService.isArtificerChoiceEntry,
      );
    }
    state = state.copyWith(
      className: className,
      classDisplayName: classDisplayName,
      hitDie: hitDie,
      spellcastingAbility: spellcastingAbility,
      savingThrowProfs: savingThrows,
      proficiencies: proficiencies,
      subclass: classChanged ? '' : state.subclass,
      subclassName: classChanged ? '' : state.subclassName,
      selectedSpells: classChanged ? [] : state.selectedSpells,
      classEquipmentChoiceId: classChanged ? '' : state.classEquipmentChoiceId,
      clericDivineOrder:
          classChanged || className != 'cleric' ? '' : state.clericDivineOrder,
      clericThaumaturgeCantrip: classChanged || className != 'cleric'
          ? ''
          : state.clericThaumaturgeCantrip,
      levelAdvancements: nextAdvancements,
    );
  }

  void setSubclass({
    required String subclass,
    required String subclassName,
  }) {
    final subclassChanged = state.subclass != subclass;
    final nextAdvancements = List<String>.from(state.levelAdvancements);
    if (state.className == 'wizard' && subclassChanged) {
      nextAdvancements.removeWhere(
        (entry) =>
            entry.startsWith(WizardChoiceService.savantEntryPrefix) ||
            entry.startsWith(WizardChoiceService.illusionistCantripPrefix),
      );
    }
    if (state.className == 'rogue' && subclassChanged) {
      nextAdvancements.removeWhere(
        RogueChoiceService.isRogueSubclassChoiceEntry,
      );
    }
    if (state.className == 'fighter' && subclassChanged) {
      nextAdvancements.removeWhere(
        FighterChoiceService.isFighterSubclassChoiceEntry,
      );
    }
    if (state.className == 'cleric' && subclassChanged) {
      nextAdvancements.removeWhere(ClericChoiceService.isClericChoiceEntry);
    }
    if (state.className == 'bard' && subclassChanged) {
      nextAdvancements.removeWhere(BardChoiceService.isBardSubclassChoiceEntry);
    }
    if (state.className == 'druid' && subclassChanged) {
      nextAdvancements
          .removeWhere(DruidChoiceService.isDruidSubclassChoiceEntry);
    }
    if (subclass != 'wizard-illusionist') {
      nextAdvancements.removeWhere(
        (entry) =>
            entry.startsWith(WizardChoiceService.illusionistCantripPrefix),
      );
    }
    if (subclass != RogueChoiceService.arcaneTricksterSubclass) {
      nextAdvancements.removeWhere(
        (entry) =>
            entry.startsWith(
              RogueChoiceService.arcaneTricksterCantripEntryPrefix,
            ) ||
            entry.startsWith(
              RogueChoiceService.arcaneTricksterSpellEntryPrefix,
            ),
      );
    }
    if (subclass != RogueChoiceService.scionSubclass) {
      nextAdvancements.removeWhere(
        (entry) => entry.startsWith(
          RogueChoiceService.scionDreadAllegianceEntryPrefix,
        ),
      );
    }
    if (subclass != 'cleric-knowledge') {
      nextAdvancements.removeWhere(ClericChoiceService.isClericChoiceEntry);
    }
    if (subclass != BardChoiceService.loreSubclass) {
      nextAdvancements.removeWhere(
        (entry) =>
            entry.startsWith(BardChoiceService.loreBonusSkillEntryPrefix) ||
            entry.startsWith(BardChoiceService.loreDiscoverySpellEntryPrefix),
      );
    }
    if (subclass != BardChoiceService.moonSubclass) {
      nextAdvancements.removeWhere(
        (entry) =>
            entry.startsWith(BardChoiceService.moonSkillEntryPrefix) ||
            entry.startsWith(BardChoiceService.moonCantripEntryPrefix),
      );
    }
    if (subclass != DruidChoiceService.landSubclass) {
      nextAdvancements.removeWhere(
        (entry) => entry.startsWith(DruidChoiceService.landTypeEntryPrefix),
      );
    }
    if (subclass != FighterChoiceService.eldritchKnightSubclass) {
      nextAdvancements.removeWhere(
        (entry) =>
            entry.startsWith(
              FighterChoiceService.eldritchKnightCantripEntryPrefix,
            ) ||
            entry.startsWith(
              FighterChoiceService.eldritchKnightSpellEntryPrefix,
            ),
      );
    }
    if (subclass != FighterChoiceService.battleMasterSubclass) {
      nextAdvancements.removeWhere(
        (entry) =>
            entry.startsWith(
              FighterChoiceService.battleMasterManeuverEntryPrefix,
            ) ||
            entry.startsWith(
              FighterChoiceService.battleMasterStudentSkillEntryPrefix,
            ) ||
            entry.startsWith(
              FighterChoiceService.battleMasterStudentToolEntryPrefix,
            ),
      );
    }
    state = state.copyWith(
      subclass: subclass,
      subclassName: subclassName,
      spellcastingAbility: state.className == 'rogue' &&
                  subclass != RogueChoiceService.arcaneTricksterSubclass ||
              state.className == 'fighter' &&
                  subclass != FighterChoiceService.eldritchKnightSubclass
          ? ''
          : state.spellcastingAbility,
      levelAdvancements: nextAdvancements,
    );
  }

  void setBackground({
    required String background,
    required String backgroundName,
    required List<String> skillIndices,
    List<String>? abilityOptions,
    String? featId,
    String? featName,
    List<String>? toolProficiencies,
    List<dynamic>? equipmentOptions,
  }) {
    final changed = state.background != background;
    final abilityPool = abilityOptions ?? const <String>[];
    state = state.copyWith(
      background: background,
      backgroundName: backgroundName,
      backgroundSkillProfs: skillIndices,
      backgroundAbilityOptions: abilityPool,
      backgroundFeatId: featId ?? '',
      backgroundFeatName: featName ?? '',
      backgroundToolProficiencies: toolProficiencies ?? const [],
      backgroundEquipmentOptions: equipmentOptions ?? const [],
      backgroundEquipmentChoiceId:
          changed ? '' : state.backgroundEquipmentChoiceId,
      backgroundBonusMode: 'plus2plus1',
      backgroundBonusChoices:
          changed ? abilityPool.take(2).toList() : state.backgroundBonusChoices,
      originFeatSpellAbility: changed ? '' : state.originFeatSpellAbility,
      originFeatCantrips: changed ? const [] : state.originFeatCantrips,
      originFeatSpell: changed ? '' : state.originFeatSpell,
      originFeatChoices: changed ? const [] : state.originFeatChoices,
    );
  }

  void setBackgroundBonusMode(String mode) {
    state = state.copyWith(backgroundBonusMode: mode);
  }

  void setBackgroundBonusChoices(List<String> abilities) {
    state = state.copyWith(backgroundBonusChoices: abilities);
  }

  void setClassEquipmentChoice(String optionId) {
    state = state.copyWith(classEquipmentChoiceId: optionId);
  }

  void setBackgroundEquipmentChoice(String optionId) {
    state = state.copyWith(backgroundEquipmentChoiceId: optionId);
  }

  void setAbilityScores({
    required int str,
    required int dex,
    required int con,
    required int int_,
    required int wis,
    required int cha,
  }) {
    state = state.copyWith(
      strength: str,
      dexterity: dex,
      constitution: con,
      intelligence: int_,
      wisdom: wis,
      charisma: cha,
    );
  }

  void toggleSkillProficiency(String skillIndex) {
    if (state.backgroundSkillProfs.contains(skillIndex)) return;
    if (state.originFeatChoices.contains('skill:$skillIndex')) return;
    if (state.speciesSkillChoice == skillIndex) return;
    if (state.speciesOriginFeatChoices.contains('skill:$skillIndex')) return;
    if (ArtificerChoiceService.needsBaseChoices(
          className: state.className,
          level: state.level,
        ) &&
        ArtificerChoiceService.selectedSkillProficiencies(
          state.levelAdvancements,
        ).contains(skillIndex)) {
      return;
    }
    if (BarbarianChoiceService.needsPrimalKnowledge(
          className: state.className,
          level: state.level,
        ) &&
        BarbarianChoiceService.selectedPrimalKnowledgeSkill(
              state.levelAdvancements,
            ) ==
            skillIndex) {
      return;
    }

    final current = List<String>.from(state.proficientSkills);
    final nextAdvancements = List<String>.from(state.levelAdvancements);

    if (current.contains(skillIndex)) {
      current.remove(skillIndex);
      nextAdvancements.removeWhere(
        (entry) =>
            (entry.startsWith(RogueChoiceService.expertiseEntryPrefix) ||
                entry.startsWith(BardChoiceService.expertiseEntryPrefix) ||
                entry.startsWith(RangerChoiceService.expertiseEntryPrefix)) &&
            entry.endsWith(':$skillIndex'),
      );
    } else {
      current.add(skillIndex);
    }

    state = state.copyWith(
      proficientSkills: current,
      levelAdvancements: nextAdvancements,
    );
  }

  void toggleSpell(String spellIndex) {
    final current = List<String>.from(state.selectedSpells);
    if (current.contains(spellIndex)) {
      current.remove(spellIndex);
    } else {
      current.add(spellIndex);
    }
    state = state.copyWith(selectedSpells: current);
  }

  void setOriginFeatSpellAbility(String ability) {
    state = state.copyWith(originFeatSpellAbility: ability);
  }

  void toggleOriginFeatCantrip(String spellIndex) {
    final current = List<String>.from(state.originFeatCantrips);
    if (current.contains(spellIndex)) {
      current.remove(spellIndex);
    } else {
      if (current.length >= 2) return;
      current.add(spellIndex);
    }
    state = state.copyWith(originFeatCantrips: current);
  }

  void setOriginFeatSpell(String spellIndex) {
    state = state.copyWith(originFeatSpell: spellIndex);
  }

  void setOriginFeatChoices(List<String> choices) {
    state = state.copyWith(originFeatChoices: choices);
  }

  void setSpeciesSkillChoice(String skillIndex) {
    state = state.copyWith(speciesSkillChoice: skillIndex);
  }

  void setSpeciesOriginFeatId(String featId) {
    state = state.copyWith(
      speciesOriginFeatId: featId,
      speciesOriginFeatSpellAbility: '',
      speciesOriginFeatCantrips: const [],
      speciesOriginFeatSpell: '',
      speciesOriginFeatChoices: const [],
    );
  }

  void setSpeciesOriginFeatSpellAbility(String ability) {
    state = state.copyWith(speciesOriginFeatSpellAbility: ability);
  }

  void toggleSpeciesOriginFeatCantrip(String spellIndex) {
    final current = List<String>.from(state.speciesOriginFeatCantrips);
    if (current.contains(spellIndex)) {
      current.remove(spellIndex);
    } else {
      if (current.length >= 2) return;
      current.add(spellIndex);
    }
    state = state.copyWith(speciesOriginFeatCantrips: current);
  }

  void setSpeciesOriginFeatSpell(String spellIndex) {
    state = state.copyWith(speciesOriginFeatSpell: spellIndex);
  }

  void setSpeciesOriginFeatChoices(List<String> choices) {
    state = state.copyWith(speciesOriginFeatChoices: choices);
  }

  void setSpeciesSpellAbility(String ability) {
    state = state.copyWith(speciesSpellAbility: ability);
  }

  void setSpeciesGrantedCantrip(String spellIndex) {
    state = state.copyWith(speciesGrantedCantrip: spellIndex);
  }

  void setClericDivineOrder(String choice) {
    state = state.copyWith(
      clericDivineOrder: choice,
      clericThaumaturgeCantrip:
          choice == 'thaumaturge' ? state.clericThaumaturgeCantrip : '',
    );
  }

  void setClericThaumaturgeCantrip(String spellIndex) {
    state = state.copyWith(clericThaumaturgeCantrip: spellIndex);
  }

  void setLevelAdvancement(String entry) {
    if (!entry.startsWith('level:')) return;
    final parts = entry.split(':');
    if (parts.length < 4) return;
    final entryLevel = int.tryParse(parts[1]);
    if (entryLevel == null) return;

    final current = List<String>.from(state.levelAdvancements);

    current.removeWhere((e) {
      if (e.startsWith('origin_') ||
          e.startsWith('class_choice:') ||
          e.startsWith('species_choice:')) {
        return false;
      }
      if (!e.startsWith('level:')) {
        return false;
      }
      final eParts = e.split(':');
      return eParts.length >= 2 && int.tryParse(eParts[1]) == entryLevel;
    });
    current.add(entry);
    state = state.copyWith(levelAdvancements: current);
  }

  void clearLevelAdvancement(int level) {
    final current = List<String>.from(state.levelAdvancements);
    current.removeWhere((e) {
      if (e.startsWith('origin_') ||
          e.startsWith('class_choice:') ||
          e.startsWith('species_choice:')) {
        return false;
      }
      if (!e.startsWith('level:')) {
        return false;
      }
      final eParts = e.split(':');
      return eParts.length >= 2 && int.tryParse(eParts[1]) == level;
    });
    state = state.copyWith(levelAdvancements: current);
  }

  void reset() => state = const CreationState();
}
