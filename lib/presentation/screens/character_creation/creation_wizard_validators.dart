part of 'creation_wizard_screen.dart';

extension _CreationWizardValidation on _CreationWizardScreenState {
  bool _hasAdvancements(CreationState state) {
    return LevelAdvancementService.availableLevels(
      state.className,
      state.level,
    ).isNotEmpty;
  }

  String get _screenTitle {
    if (widget.levelUpMode) return 'Level Up Character';
    return _isEditMode ? 'Edit Character' : 'New Character';
  }

  bool _hasCompletedOriginFeatChoices(CreationState state) {
    final featId = state.backgroundFeatId;
    if (featId == 'skilled' || featId == 'crafter' || featId == 'musician') {
      return state.originFeatChoices.length == 3;
    }
    return true;
  }

  bool _hasCompletedOriginMagic(CreationState state) {
    final featId = state.backgroundFeatId;
    if (!featId.startsWith('magic-initiate-')) return true;

    return state.originFeatSpellAbility.isNotEmpty &&
        state.originFeatCantrips.length == 2 &&
        state.originFeatSpell.isNotEmpty;
  }

  bool _isHumanSpecies(CreationState state) {
    final raceValue = state.race;
    if (!raceValue.contains('::')) return raceValue == 'human';
    return raceValue.split('::').first == 'human';
  }

  bool _hasSpeciesLanguageChoice(CreationState state) {
    for (final language in state.languages) {
      final normalized = language.trim().toLowerCase();
      if (normalized.isEmpty) continue;
      if (normalized.contains('extra language')) return false;
      if (normalized.contains('language of your choice')) return false;
    }
    return true;
  }

  bool _hasCompletedHumanSpeciesChoices(CreationState state) {
    if (!_isHumanSpecies(state)) return true;
    if (state.speciesSkillChoice.isEmpty) return false;
    if (state.speciesOriginFeatId.isEmpty) return false;

    final featId = state.speciesOriginFeatId;
    if (featId == 'skilled' || featId == 'crafter' || featId == 'musician') {
      return state.speciesOriginFeatChoices.length == 3;
    }

    return true;
  }

  bool _hasCompletedLevelAdvancements(CreationState state) {
    final levels = LevelAdvancementService.availableLevels(
      state.className,
      state.level,
    );
    if (levels.isEmpty) return true;

    final character = state.toCharacterModel();
    final used = LevelAdvancementService.usedClassLevels(character);
    return levels.every(used.contains);
  }

  bool _requiresSubclassChoice(CreationState state) {
    if (state.className.startsWith('custom_class_')) return false;
    if (state.level < 3) return false;
    return Subclasses2024Data.hasOptionsFor(state.className);
  }

  bool _hasCompletedSpeciesOriginMagic(CreationState state) {
    if (!_isHumanSpecies(state)) return true;

    final featId = state.speciesOriginFeatId;
    if (!featId.startsWith('magic-initiate-')) return true;

    return state.speciesOriginFeatSpellAbility.isNotEmpty &&
        state.speciesOriginFeatCantrips.length == 2 &&
        state.speciesOriginFeatSpell.isNotEmpty;
  }

  bool _hasCompletedSpeciesSpellChoices(CreationState state) {
    final race = state.race;
    final needsSpellAbility = race.startsWith('elf::') ||
        race.startsWith('tiefling::') ||
        race.startsWith('gnome::');
    if (needsSpellAbility && state.speciesSpellAbility.isEmpty) {
      return false;
    }

    final needsHighElfCantrip = race == 'elf::lineage::high-elf';
    if (needsHighElfCantrip && state.speciesGrantedCantrip.isEmpty) {
      return false;
    }

    return true;
  }

  bool _hasCompletedWizardScholar(CreationState state) {
    if (!WizardChoiceService.needsScholar(
      className: state.className,
      level: state.level,
    )) {
      return true;
    }

    return WizardChoiceService.selectedScholarSkill(
          state.levelAdvancements,
        ) !=
        null;
  }

  bool _hasCompletedArtificerClassChoices(CreationState state) {
    if (!ArtificerChoiceService.needsBaseChoices(
      className: state.className,
      level: state.level,
    )) {
      return true;
    }

    final selectedSkills = ArtificerChoiceService.selectedSkillProficiencies(
      state.levelAdvancements,
    );
    if (selectedSkills.length != ArtificerChoiceService.skillSelectionCount) {
      return false;
    }
    if (selectedSkills.toSet().length != selectedSkills.length) {
      return false;
    }
    if (selectedSkills.any(
      (skill) => !ArtificerChoiceService.skillOptions.contains(skill),
    )) {
      return false;
    }

    final selectedTool =
        ArtificerChoiceService.selectedArtisanTool(state.levelAdvancements);
    return selectedTool != null &&
        ArtificerChoiceService.selectableArtisanToolOptions.contains(
          selectedTool,
        );
  }

  bool _hasCompletedStartingEquipmentChoices(CreationState state) {
    if (state.originalCharacter != null) return true;

    final classOptions = StartingEquipmentService.parseOptions(
      StartingEquipmentService.classOptionTexts(state.className),
    );
    final backgroundOptions = StartingEquipmentService.parseOptions(
      state.backgroundEquipmentOptions,
    );

    if (classOptions.isNotEmpty &&
        StartingEquipmentService.optionById(
              classOptions,
              state.classEquipmentChoiceId,
            ) ==
            null) {
      return false;
    }

    if (backgroundOptions.isNotEmpty &&
        StartingEquipmentService.optionById(
              backgroundOptions,
              state.backgroundEquipmentChoiceId,
            ) ==
            null) {
      return false;
    }

    return true;
  }

  Set<String> _baseSkillProficiencies(CreationState state) {
    return {
      ...state.backgroundSkillProfs,
      ...state.proficientSkills,
      ...state.originFeatChoices
          .where((choice) => choice.startsWith('skill:'))
          .map((choice) => choice.replaceFirst('skill:', '')),
      if (state.speciesSkillChoice.isNotEmpty) state.speciesSkillChoice,
      ...state.speciesOriginFeatChoices
          .where((choice) => choice.startsWith('skill:'))
          .map((choice) => choice.replaceFirst('skill:', '')),
    };
  }

  Set<String> _currentSkillProficiencies(CreationState state) {
    final barbarianPrimalSkill = BarbarianChoiceService.needsPrimalKnowledge(
      className: state.className,
      level: state.level,
    )
        ? BarbarianChoiceService.selectedPrimalKnowledgeSkill(
            state.levelAdvancements,
          )
        : null;
    final clericKnowledgeSkills = ClericChoiceService.needsKnowledgeChoices(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )
        ? ClericChoiceService.selectedKnowledgeSkills(state.levelAdvancements)
        : const <String>[];
    final battleMasterStudentSkill = FighterChoiceService.isBattleMaster(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )
        ? FighterChoiceService.selectedBattleMasterStudentSkill(
            state.levelAdvancements,
          )
        : null;
    final paladinGenieSkill = PaladinChoiceService.isNobleGenies(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )
        ? PaladinChoiceService.selectedGenieSplendorSkill(
            state.levelAdvancements,
          )
        : null;
    final rangerFeyGlamourSkill = RangerChoiceService.needsFeyGlamourSkill(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )
        ? RangerChoiceService.selectedFeyGlamourSkill(state.levelAdvancements)
        : null;
    final bardLoreSkills = BardChoiceService.needsLoreBonusSkills(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )
        ? BardChoiceService.selectedLoreBonusSkills(state.levelAdvancements)
        : const <String>[];
    final bardMoonSkill = BardChoiceService.isMoon(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )
        ? BardChoiceService.selectedMoonSkill(state.levelAdvancements)
        : null;
    final monkSubclassSkills = MonkChoiceService.subclassSkillProficiencies(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    );
    final artificerSkills = ArtificerChoiceService.needsBaseChoices(
      className: state.className,
      level: state.level,
    )
        ? ArtificerChoiceService.selectedSkillProficiencies(
            state.levelAdvancements,
          )
        : const <String>[];

    return {
      ..._baseSkillProficiencies(state),
      ...artificerSkills,
      ...bardLoreSkills,
      if (bardMoonSkill != null) bardMoonSkill,
      if (barbarianPrimalSkill != null) barbarianPrimalSkill,
      ...clericKnowledgeSkills,
      if (battleMasterStudentSkill != null) battleMasterStudentSkill,
      if (paladinGenieSkill != null) paladinGenieSkill,
      if (rangerFeyGlamourSkill != null) rangerFeyGlamourSkill,
      ...monkSubclassSkills,
    };
  }

  List<String> _stepLabels(CreationState state) {
    final base = [
      'Basic Info',
      'Species',
      'Class',
      'Background',
      'Equipment',
      'Ability Scores',
      'Skills',
      'Spells',
    ];
    if (_hasAdvancements(state)) base.add('Advancements');
    return base;
  }

  List<IconData> _stepIcons(CreationState state) {
    final base = [
      Icons.badge_outlined,
      Icons.diversity_3_outlined,
      Icons.auto_fix_high_outlined,
      Icons.history_edu_outlined,
      Icons.inventory_2_outlined,
      Icons.fitness_center_outlined,
      Icons.checklist_outlined,
      Icons.auto_awesome_outlined,
    ];
    if (_hasAdvancements(state)) base.add(Icons.military_tech_outlined);
    return base;
  }

  Widget _buildStepContent(int step, CreationState state) {
    switch (step) {
      case 0:
        return StepBasicInfo(
            key: ValueKey('basic-${state.editingId ?? 'new'}'));
      case 1:
        return StepRace(key: ValueKey('race-${state.editingId ?? 'new'}'));
      case 2:
        return StepClass(key: ValueKey('class-${state.editingId ?? 'new'}'));
      case 3:
        return StepBackground(
            key: ValueKey('background-${state.editingId ?? 'new'}'));
      case 4:
        return StepEquipment(
            key: ValueKey('equipment-${state.editingId ?? 'new'}'));
      case 5:
        return StepAbilityScores(
            key: ValueKey('abilities-${state.editingId ?? 'new'}'));
      case 6:
        return StepSkills(key: ValueKey('skills-${state.editingId ?? 'new'}'));
      case 7:
        return StepSpells(key: ValueKey('spells-${state.editingId ?? 'new'}'));
      case 8:
        return StepAdvancements(
            key: ValueKey('advancements-${state.editingId ?? 'new'}'));
      default:
        return const SizedBox.shrink();
    }
  }

  bool _canAdvance(int step, CreationState state) {
    switch (step) {
      case 0:
        return state.name.trim().isNotEmpty;
      case 1:
        return state.race.isNotEmpty && _hasSpeciesLanguageChoice(state);
      case 2:
        if (state.className.isEmpty) return false;
        if (_requiresSubclassChoice(state) && state.subclass.isEmpty) {
          return false;
        }
        return _hasCompletedRangerClassChoices(state) &&
            _hasCompletedPaladinClassChoices(state) &&
            _hasCompletedArtificerClassChoices(state) &&
            _hasCompletedDruidClassChoices(state) &&
            _hasCompletedSorcererClassChoices(state) &&
            _hasCompletedWarlockClassChoices(state) &&
            _hasCompletedRogueSubclassClassChoices(state) &&
            _hasCompletedBarbarianClassChoices(state) &&
            _hasCompletedFighterClassChoices(state) &&
            _hasCompletedFighterSubclassClassChoices(state);
      case 3:
        return state.background.isNotEmpty;
      case 4:
        return _hasCompletedStartingEquipmentChoices(state);
      case 6:
        return _hasCompletedOriginFeatChoices(state) &&
            _hasCompletedHumanSpeciesChoices(state) &&
            _hasCompletedWizardScholar(state) &&
            _hasCompletedClericKnowledgeChoices(state) &&
            _hasCompletedBardLoreBonusSkills(state) &&
            _hasCompletedBardMoonSkill(state) &&
            _hasCompletedFighterBattleMasterStudentOfWar(state) &&
            _hasCompletedPaladinGenieSplendor(state) &&
            _hasCompletedRogueExpertise(state) &&
            _hasCompletedBardExpertise(state) &&
            _hasCompletedRangerExplorationChoices(state) &&
            _hasCompletedBarbarianPrimalKnowledge(state);
      case 7:
        return _hasCompletedOriginMagic(state) &&
            _hasCompletedSpeciesOriginMagic(state) &&
            _hasCompletedSpeciesSpellChoices(state) &&
            _hasCompletedWizardSavant(state) &&
            _hasCompletedRangerDruidicWarrior(state) &&
            _hasCompletedBardLoreMagicalDiscoveries(state) &&
            _hasCompletedBardMoonCantrip(state) &&
            _hasCompletedDruidMagicianCantrip(state) &&
            _hasCompletedPaladinBlessedWarrior(state) &&
            _hasCompletedClassSpellSelection(state) &&
            _hasCompletedRogueArcaneTricksterSpellChoices(state) &&
            _hasCompletedFighterEldritchKnightSpellChoices(state) &&
            _hasCompletedWarlockSpellChoices(state);
      case 8:
        return _hasCompletedLevelAdvancements(state);
      default:
        return true;
    }
  }
}
