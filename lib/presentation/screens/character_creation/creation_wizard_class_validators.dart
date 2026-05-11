part of 'creation_wizard_screen.dart';

extension _CreationWizardClassValidation on _CreationWizardScreenState {
  bool _hasCompletedClericKnowledgeChoices(CreationState state) {
    if (!ClericChoiceService.needsKnowledgeChoices(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return true;
    }

    final skills = ClericChoiceService.selectedKnowledgeSkills(
      state.levelAdvancements,
    );
    if (skills.length != ClericChoiceService.knowledgeSkillCount) {
      return false;
    }
    if (skills.any((skill) =>
        !ClericChoiceService.knowledgeSkillOptions.contains(skill))) {
      return false;
    }

    final tool = ClericChoiceService.selectedKnowledgeTool(
      state.levelAdvancements,
    );
    return tool != null &&
        ClericChoiceService.artisanToolOptions.contains(tool);
  }

  bool _hasCompletedBardLoreBonusSkills(CreationState state) {
    if (!BardChoiceService.needsLoreBonusSkills(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return true;
    }

    final baseSkills = _baseSkillProficiencies(state);
    final availableSkills = BardChoiceService.loreSkillOptions
        .where((skill) => !baseSkills.contains(skill))
        .toSet();
    final required =
        availableSkills.length < BardChoiceService.loreBonusSkillCount
            ? availableSkills.length
            : BardChoiceService.loreBonusSkillCount;
    final selected =
        BardChoiceService.selectedLoreBonusSkills(state.levelAdvancements);
    if (selected.length != required) return false;

    final unique = <String>{};
    for (final skill in selected) {
      if (!availableSkills.contains(skill) || !unique.add(skill)) {
        return false;
      }
    }

    return true;
  }

  bool _hasCompletedRangerClassChoices(CreationState state) {
    if (state.className != 'ranger') return true;

    final masteries = RangerChoiceService.selectedWeaponMasteries(
      state.levelAdvancements,
    );
    if (state.level >= 1 &&
        masteries.length != RangerChoiceService.weaponMasterySelectionCount) {
      return false;
    }

    if (state.level >= 2 &&
        RangerChoiceService.selectedFightingStyle(state.levelAdvancements) ==
            null) {
      return false;
    }

    return true;
  }

  bool _hasCompletedPaladinClassChoices(CreationState state) {
    if (state.className != 'paladin') return true;

    final masteries = PaladinChoiceService.selectedWeaponMasteries(
      state.levelAdvancements,
    );
    if (state.level >= 1 &&
        masteries.length != PaladinChoiceService.weaponMasterySelectionCount) {
      return false;
    }

    if (state.level >= 2 &&
        PaladinChoiceService.selectedFightingStyle(state.levelAdvancements) ==
            null) {
      return false;
    }

    return true;
  }

  bool _hasCompletedDruidClassChoices(CreationState state) {
    if (state.className != 'druid') return true;

    if (state.level >= 1 &&
        DruidChoiceService.selectedPrimalOrder(state.levelAdvancements) ==
            null) {
      return false;
    }

    if (state.level >= 7 &&
        DruidChoiceService.selectedElementalFury(state.levelAdvancements) ==
            null) {
      return false;
    }

    if (DruidChoiceService.isLand(
          className: state.className,
          subclass: state.subclass,
          level: state.level,
        ) &&
        DruidChoiceService.selectedLandType(state.levelAdvancements) == null) {
      return false;
    }

    return true;
  }

  bool _hasCompletedSorcererClassChoices(CreationState state) {
    if (state.className != 'sorcerer') return true;

    final selectedOptions = <String>{};
    for (final sorcererLevel
        in SorcererChoiceService.unlockedMetamagicLevels(state.level)) {
      final selected = SorcererChoiceService.selectedMetamagicOptions(
        state.levelAdvancements,
        sorcererLevel: sorcererLevel,
      );
      if (selected.length !=
          SorcererChoiceService.requiredMetamagicSelectionsForLevel(
            sorcererLevel,
          )) {
        return false;
      }
      for (final optionId in selected) {
        if (!selectedOptions.add(optionId)) return false;
      }
    }

    if (SorcererChoiceService.needsDraconicAffinity(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      final selected = SorcererChoiceService.selectedDraconicAffinity(
        state.levelAdvancements,
      );
      if (selected == null ||
          !SorcererChoiceService.draconicAffinityOptions
              .containsKey(selected)) {
        return false;
      }
    }

    return true;
  }

  bool _hasCompletedWarlockClassChoices(CreationState state) {
    if (state.className != 'warlock') return true;

    final selected = WarlockChoiceService.selectedInvocations(
      state.levelAdvancements,
    );
    if (selected.length !=
        WarlockChoiceService.invocationCountForLevel(state.level)) {
      return false;
    }

    for (final invocationId in selected) {
      if (!WarlockChoiceService.qualifiesForInvocation(
        invocationId: invocationId,
        level: state.level,
        selectedInvocationIds: selected,
      )) {
        return false;
      }
    }

    return true;
  }

  bool _hasCompletedRogueSubclassClassChoices(CreationState state) {
    if (!RogueChoiceService.needsScionDreadAllegiance(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return true;
    }

    final selected = RogueChoiceService.selectedScionDreadAllegiance(
      state.levelAdvancements,
    );
    return selected != null && RogueChoiceService.isScionAllegianceId(selected);
  }

  bool _hasCompletedBarbarianClassChoices(CreationState state) {
    if (state.className != 'barbarian') return true;

    final masteries = BarbarianChoiceService.selectedWeaponMasteries(
      state.levelAdvancements,
      characterLevel: state.level,
    );
    final requiredMasteries =
        BarbarianChoiceService.weaponMasterySelectionCountForLevel(
      state.level,
    );
    if (state.level >= 1 && masteries.length != requiredMasteries) {
      return false;
    }

    return true;
  }

  bool _hasCompletedFighterClassChoices(CreationState state) {
    if (state.className != 'fighter') return true;

    final masteries = FighterChoiceService.selectedWeaponMasteries(
      state.levelAdvancements,
      characterLevel: state.level,
    );
    final requiredMasteries =
        FighterChoiceService.weaponMasterySelectionCountForLevel(
      state.level,
    );
    if (state.level >= 1 && masteries.length != requiredMasteries) {
      return false;
    }

    return true;
  }

  bool _hasCompletedFighterSubclassClassChoices(CreationState state) {
    if (!FighterChoiceService.isBattleMaster(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return true;
    }

    return FighterChoiceService.selectedBattleMasterManeuvers(
          state.levelAdvancements,
          characterLevel: state.level,
        ).length ==
        FighterChoiceService.battleMasterManeuverCountForLevel(state.level);
  }

  bool _hasCompletedBarbarianPrimalKnowledge(CreationState state) {
    if (!BarbarianChoiceService.needsPrimalKnowledge(
      className: state.className,
      level: state.level,
    )) {
      return true;
    }

    final baseSkills = _baseSkillProficiencies(state);
    final hasNoEligibleSkill = BarbarianChoiceService.skillOptions.every(
      baseSkills.contains,
    );
    if (hasNoEligibleSkill) {
      return true;
    }

    final selected = BarbarianChoiceService.selectedPrimalKnowledgeSkill(
      state.levelAdvancements,
    );
    if (selected == null ||
        !BarbarianChoiceService.skillOptions.contains(selected)) {
      return false;
    }

    return !baseSkills.contains(selected);
  }

  bool _hasCompletedFighterBattleMasterStudentOfWar(CreationState state) {
    if (!FighterChoiceService.isBattleMaster(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return true;
    }

    final skill = FighterChoiceService.selectedBattleMasterStudentSkill(
      state.levelAdvancements,
    );
    final tool = FighterChoiceService.selectedBattleMasterStudentTool(
      state.levelAdvancements,
    );

    return skill != null &&
        FighterChoiceService.studentOfWarSkillOptions.contains(skill) &&
        tool != null &&
        FighterChoiceService.artisanToolOptions.contains(tool);
  }

  bool _hasCompletedPaladinGenieSplendor(CreationState state) {
    if (!PaladinChoiceService.isNobleGenies(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return true;
    }

    final selected = PaladinChoiceService.selectedGenieSplendorSkill(
      state.levelAdvancements,
    );
    return selected != null &&
        PaladinChoiceService.genieSplendorSkillOptions.contains(selected);
  }

  bool _hasCompletedRangerExplorationChoices(CreationState state) {
    if (state.className != 'ranger') return true;
    if (state.level < 2) return true;

    final languages = RangerChoiceService.selectedLanguages(
      state.levelAdvancements,
    );
    if (languages.length != RangerChoiceService.deftExplorerLanguageCount) {
      return false;
    }

    final proficientSkills = _currentSkillProficiencies(state);
    final allSelected = <String>{};
    for (final rangerLevel
        in RangerChoiceService.unlockedExpertiseLevels(state.level)) {
      final selected = RangerChoiceService.selectedExpertiseSkills(
        state.levelAdvancements,
        rangerLevel: rangerLevel,
      );
      if (selected.length !=
          RangerChoiceService.requiredExpertiseSelectionsForLevel(
              rangerLevel)) {
        return false;
      }
      for (final skill in selected) {
        if (!proficientSkills.contains(skill)) {
          return false;
        }
        if (!allSelected.add(skill)) {
          return false;
        }
      }
    }

    if (RangerChoiceService.needsFeyGlamourSkill(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      final selected = RangerChoiceService.selectedFeyGlamourSkill(
        state.levelAdvancements,
      );
      if (selected == null ||
          !RangerChoiceService.feyGlamourSkillOptions.contains(selected)) {
        return false;
      }
    }

    return true;
  }
}
