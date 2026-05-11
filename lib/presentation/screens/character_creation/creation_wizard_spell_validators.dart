part of 'creation_wizard_screen.dart';

extension _CreationWizardSpellValidation on _CreationWizardScreenState {
  bool _hasCompletedRangerDruidicWarrior(CreationState state) {
    if (!RangerChoiceService.needsDruidicWarriorCantrips(
      className: state.className,
      level: state.level,
      entries: state.levelAdvancements,
    )) {
      return true;
    }

    return RangerChoiceService.selectedDruidicWarriorCantrips(
          state.levelAdvancements,
        ).length ==
        RangerChoiceService.druidicWarriorCantripCount;
  }

  bool _hasCompletedPaladinBlessedWarrior(CreationState state) {
    if (!PaladinChoiceService.needsBlessedWarriorCantrips(
      className: state.className,
      level: state.level,
      entries: state.levelAdvancements,
    )) {
      return true;
    }

    return PaladinChoiceService.selectedBlessedWarriorCantrips(
          state.levelAdvancements,
        ).length ==
        PaladinChoiceService.blessedWarriorCantripCount;
  }

  bool _hasCompletedDruidMagicianCantrip(CreationState state) {
    if (!DruidChoiceService.needsMagicianCantrip(
      className: state.className,
      level: state.level,
      entries: state.levelAdvancements,
    )) {
      return true;
    }

    return DruidChoiceService.selectedMagicianCantrip(
          state.levelAdvancements,
        ) !=
        null;
  }

  bool _hasCompletedBardLoreMagicalDiscoveries(CreationState state) {
    if (!BardChoiceService.needsLoreMagicalDiscoveries(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return true;
    }

    final selected =
        BardChoiceService.selectedLoreDiscoverySpells(state.levelAdvancements);
    return selected.length == BardChoiceService.loreDiscoverySpellCount &&
        selected.toSet().length == selected.length;
  }

  bool _hasCompletedBardMoonSkill(CreationState state) {
    if (!BardChoiceService.isMoon(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return true;
    }

    final baseSkills = _baseSkillProficiencies(state);
    final availableSkills = BardChoiceService.moonSkillOptions
        .where((skill) => !baseSkills.contains(skill))
        .toSet();
    final selectedSkill =
        BardChoiceService.selectedMoonSkill(state.levelAdvancements);
    return availableSkills.isEmpty || availableSkills.contains(selectedSkill);
  }

  bool _hasCompletedBardMoonCantrip(CreationState state) {
    if (!BardChoiceService.isMoon(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return true;
    }

    return BardChoiceService.selectedMoonCantrip(state.levelAdvancements) !=
        null;
  }

  bool _hasCompletedWarlockSpellChoices(CreationState state) {
    if (state.className != 'warlock') return true;

    for (final spellLevel
        in WarlockChoiceService.mysticArcanumSpellLevels(state.level)) {
      if (WarlockChoiceService.selectedMysticArcanumSpell(
            state.levelAdvancements,
            spellLevel: spellLevel,
          ) ==
          null) {
        return false;
      }
    }

    if (WarlockChoiceService.needsPactTomeChoices(
      className: state.className,
      level: state.level,
      entries: state.levelAdvancements,
    )) {
      if (WarlockChoiceService.selectedPactTomeCantrips(
            state.levelAdvancements,
          ).length !=
          WarlockChoiceService.pactTomeCantripCount) {
        return false;
      }
      if (WarlockChoiceService.selectedPactTomeRituals(
            state.levelAdvancements,
          ).length !=
          WarlockChoiceService.pactTomeRitualCount) {
        return false;
      }
    }

    return true;
  }

  bool _hasCompletedClassSpellSelection(CreationState state) {
    if (RogueChoiceService.isArcaneTrickster(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return true;
    }
    if (FighterChoiceService.isEldritchKnight(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return true;
    }

    return ProgressionService.hasCompletedSpellSelectionFor(
      className: state.className,
      level: state.level,
      selectedSpellIds: state.selectedSpells,
      spellcastingModifier: 0,
    );
  }

  bool _hasCompletedRogueArcaneTricksterSpellChoices(CreationState state) {
    if (!RogueChoiceService.isArcaneTrickster(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return true;
    }

    final selectedCantrips = RogueChoiceService.selectedArcaneTricksterCantrips(
      state.levelAdvancements,
    );
    if (selectedCantrips.length !=
        RogueChoiceService.arcaneTricksterCantripCount(state.level)) {
      return false;
    }

    final selectedSpells = RogueChoiceService.selectedArcaneTricksterSpells(
      state.levelAdvancements,
    );
    return selectedSpells.length ==
        RogueChoiceService.arcaneTricksterPreparedSpellCount(state.level);
  }

  bool _hasCompletedFighterEldritchKnightSpellChoices(CreationState state) {
    if (!FighterChoiceService.isEldritchKnight(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return true;
    }

    final selectedCantrips =
        FighterChoiceService.selectedEldritchKnightCantrips(
      state.levelAdvancements,
    );
    if (selectedCantrips.length !=
        FighterChoiceService.eldritchKnightCantripCount(state.level)) {
      return false;
    }

    final selectedSpells = FighterChoiceService.selectedEldritchKnightSpells(
      state.levelAdvancements,
    );
    return selectedSpells.length ==
        FighterChoiceService.eldritchKnightPreparedSpellCount(state.level);
  }

  bool _hasCompletedRogueExpertise(CreationState state) {
    if (state.className != 'rogue') {
      return true;
    }

    final proficientSkills = _currentSkillProficiencies(state);

    final allSelected = <String>{};
    for (final rogueLevel
        in RogueChoiceService.unlockedExpertiseLevels(state.level)) {
      final selected = RogueChoiceService.selectedExpertiseSkills(
        state.levelAdvancements,
        rogueLevel: rogueLevel,
      );

      if (selected.length !=
          RogueChoiceService.requiredSelectionsForLevel(rogueLevel)) {
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

    return true;
  }

  bool _hasCompletedBardExpertise(CreationState state) {
    if (state.className != 'bard') {
      return true;
    }

    final proficientSkills = _currentSkillProficiencies(state);

    final allSelected = <String>{};
    for (final bardLevel
        in BardChoiceService.unlockedExpertiseLevels(state.level)) {
      final selected = BardChoiceService.selectedExpertiseSkills(
        state.levelAdvancements,
        bardLevel: bardLevel,
      );

      if (selected.length !=
          BardChoiceService.requiredExpertiseSelectionsForLevel(bardLevel)) {
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

    return true;
  }

  bool _hasCompletedWizardSavant(CreationState state) {
    if (!WizardChoiceService.needsSavant(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return true;
    }

    for (final milestone
        in WizardChoiceService.savantMilestonesForLevel(state.level)) {
      final selected = WizardChoiceService.selectedSavantSpells(
        state.levelAdvancements,
        wizardLevel: milestone.wizardLevel,
      );
      if (selected.length != milestone.selections) {
        return false;
      }
    }

    final knownSpellIds = <String>{
      ...state.selectedSpells,
      ...state.originFeatCantrips,
      if (state.originFeatSpell.isNotEmpty) state.originFeatSpell,
      if (state.speciesGrantedCantrip.isNotEmpty) state.speciesGrantedCantrip,
      if (state.clericThaumaturgeCantrip.isNotEmpty)
        state.clericThaumaturgeCantrip,
      ...WizardChoiceService.selectedSavantSpells(state.levelAdvancements),
    };

    final needsIllusionistBonus =
        WizardChoiceService.needsIllusionistBonusCantrip(
      subclass: state.subclass,
      level: state.level,
      knownSpellIds: knownSpellIds,
    );

    if (!needsIllusionistBonus) {
      return true;
    }

    return WizardChoiceService.selectedIllusionistBonusCantrip(
          state.levelAdvancements,
        ) !=
        null;
  }
}
