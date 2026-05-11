part of 'character_creation_provider.dart';

extension CreationNotifierRangerBarbarianFighterChoices on CreationNotifier {
  void setRangerExpertiseChoices({
    required int rangerLevel,
    required List<String> skillIndices,
  }) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    final prefix = '${RangerChoiceService.expertiseEntryPrefix}$rangerLevel:';

    current.removeWhere((entry) => entry.startsWith(prefix));

    final uniqueSkills = <String>[];
    for (final skill in skillIndices) {
      final normalized = skill.trim();
      if (normalized.isEmpty || uniqueSkills.contains(normalized)) {
        continue;
      }
      uniqueSkills.add(normalized);
      if (uniqueSkills.length >=
          RangerChoiceService.requiredExpertiseSelectionsForLevel(
              rangerLevel)) {
        break;
      }
    }

    for (final skill in uniqueSkills) {
      current.add('$prefix$skill');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setRangerLanguages(List<String> languages) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(RangerChoiceService.languageEntryPrefix),
    );

    final uniqueLanguages = <String>[];
    for (final language in languages) {
      final normalized = language.trim();
      if (normalized.isEmpty || uniqueLanguages.contains(normalized)) {
        continue;
      }
      uniqueLanguages.add(normalized);
      if (uniqueLanguages.length >=
          RangerChoiceService.deftExplorerLanguageCount) {
        break;
      }
    }

    for (final language in uniqueLanguages) {
      current.add('${RangerChoiceService.languageEntryPrefix}$language');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setRangerFightingStyle(String style) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(RangerChoiceService.fightingStyleEntryPrefix),
    );
    if (style.trim().isNotEmpty) {
      current.add('${RangerChoiceService.fightingStyleEntryPrefix}$style');
    }
    if (style != 'Druidic Warrior') {
      current.removeWhere(
        (entry) =>
            entry.startsWith(RangerChoiceService.druidicWarriorCantripPrefix),
      );
    }
    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setRangerWeaponMasteries(List<String> weapons) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(RangerChoiceService.weaponMasteryEntryPrefix),
    );

    final uniqueWeapons = <String>[];
    for (final weapon in weapons) {
      final normalized = weapon.trim();
      if (normalized.isEmpty ||
          uniqueWeapons.contains(normalized) ||
          !RangerChoiceService.isWeaponMasteryWeaponName(normalized)) {
        continue;
      }
      uniqueWeapons.add(normalized);
      if (uniqueWeapons.length >=
          RangerChoiceService.weaponMasterySelectionCount) {
        break;
      }
    }

    for (final weapon in uniqueWeapons) {
      current.add('${RangerChoiceService.weaponMasteryEntryPrefix}$weapon');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setRangerDruidicWarriorCantrips(List<String> spellIndices) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) =>
          entry.startsWith(RangerChoiceService.druidicWarriorCantripPrefix),
    );

    final uniqueSpells = <String>[];
    for (final spell in spellIndices) {
      final normalized = spell.trim();
      if (normalized.isEmpty || uniqueSpells.contains(normalized)) {
        continue;
      }
      uniqueSpells.add(normalized);
      if (uniqueSpells.length >=
          RangerChoiceService.druidicWarriorCantripCount) {
        break;
      }
    }

    for (final spell in uniqueSpells) {
      current.add('${RangerChoiceService.druidicWarriorCantripPrefix}$spell');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setRangerFeyGlamourSkill(String skillIndex) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) =>
          entry.startsWith(RangerChoiceService.feyGlamourSkillEntryPrefix),
    );

    final normalized = skillIndex.trim();
    if (RangerChoiceService.feyGlamourSkillOptions.contains(normalized)) {
      current
          .add('${RangerChoiceService.feyGlamourSkillEntryPrefix}$normalized');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setBarbarianWeaponMasteries(List<String> weapons) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) =>
          entry.startsWith(BarbarianChoiceService.weaponMasteryEntryPrefix),
    );

    final uniqueWeapons = <String>[];
    for (final weapon in weapons) {
      final normalized = weapon.trim();
      if (normalized.isEmpty || uniqueWeapons.contains(normalized)) {
        continue;
      }
      uniqueWeapons.add(normalized);
      if (uniqueWeapons.length >=
          BarbarianChoiceService.weaponMasterySelectionCountForLevel(
            _notifierState.level,
          )) {
        break;
      }
    }

    for (final weapon in uniqueWeapons) {
      current.add('${BarbarianChoiceService.weaponMasteryEntryPrefix}$weapon');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setBarbarianPrimalKnowledgeSkill(String skillIndex) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(
        BarbarianChoiceService.primalKnowledgeSkillEntryPrefix,
      ),
    );

    final normalized = skillIndex.trim();
    if (BarbarianChoiceService.skillOptions.contains(normalized)) {
      current.add(
        '${BarbarianChoiceService.primalKnowledgeSkillEntryPrefix}$normalized',
      );
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setFighterWeaponMasteries(List<String> weapons) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) =>
          entry.startsWith(FighterChoiceService.weaponMasteryEntryPrefix),
    );

    final uniqueWeapons = <String>[];
    for (final weapon in weapons) {
      final normalized = weapon.trim();
      if (normalized.isEmpty ||
          uniqueWeapons.contains(normalized) ||
          !FighterChoiceService.isWeaponMasteryWeaponName(normalized)) {
        continue;
      }
      uniqueWeapons.add(normalized);
      if (uniqueWeapons.length >=
          FighterChoiceService.weaponMasterySelectionCountForLevel(
            _notifierState.level,
          )) {
        break;
      }
    }

    for (final weapon in uniqueWeapons) {
      current.add('${FighterChoiceService.weaponMasteryEntryPrefix}$weapon');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setFighterEldritchKnightCantrips(List<String> spellIndices) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(
        FighterChoiceService.eldritchKnightCantripEntryPrefix,
      ),
    );

    final uniqueSpells = <String>[];
    for (final spell in spellIndices) {
      final normalized = spell.trim();
      if (normalized.isEmpty || uniqueSpells.contains(normalized)) {
        continue;
      }
      uniqueSpells.add(normalized);
      if (uniqueSpells.length >=
          FighterChoiceService.eldritchKnightCantripCount(
              _notifierState.level)) {
        break;
      }
    }

    for (final spell in uniqueSpells) {
      current.add(
        '${FighterChoiceService.eldritchKnightCantripEntryPrefix}$spell',
      );
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setFighterEldritchKnightSpells(List<String> spellIndices) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(
        FighterChoiceService.eldritchKnightSpellEntryPrefix,
      ),
    );

    final uniqueSpells = <String>[];
    for (final spell in spellIndices) {
      final normalized = spell.trim();
      if (normalized.isEmpty || uniqueSpells.contains(normalized)) {
        continue;
      }
      uniqueSpells.add(normalized);
      if (uniqueSpells.length >=
          FighterChoiceService.eldritchKnightPreparedSpellCount(
              _notifierState.level)) {
        break;
      }
    }

    for (final spell in uniqueSpells) {
      current.add(
        '${FighterChoiceService.eldritchKnightSpellEntryPrefix}$spell',
      );
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setFighterBattleMasterManeuvers(List<String> maneuverIds) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(
        FighterChoiceService.battleMasterManeuverEntryPrefix,
      ),
    );

    final uniqueManeuvers = <String>[];
    for (final maneuver in maneuverIds) {
      final normalized = maneuver.trim();
      if (!FighterChoiceService.isBattleMasterManeuverId(normalized) ||
          uniqueManeuvers.contains(normalized)) {
        continue;
      }
      uniqueManeuvers.add(normalized);
      if (uniqueManeuvers.length >=
          FighterChoiceService.battleMasterManeuverCountForLevel(
              _notifierState.level)) {
        break;
      }
    }

    for (final maneuver in uniqueManeuvers) {
      current.add(
        '${FighterChoiceService.battleMasterManeuverEntryPrefix}$maneuver',
      );
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setFighterBattleMasterStudentSkill(String skillIndex) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(
        FighterChoiceService.battleMasterStudentSkillEntryPrefix,
      ),
    );

    final normalized = skillIndex.trim();
    if (FighterChoiceService.studentOfWarSkillOptions.contains(normalized)) {
      current.add(
        '${FighterChoiceService.battleMasterStudentSkillEntryPrefix}$normalized',
      );
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setFighterBattleMasterStudentTool(String tool) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(
        FighterChoiceService.battleMasterStudentToolEntryPrefix,
      ),
    );

    final normalized = tool.trim();
    if (FighterChoiceService.artisanToolOptions.contains(normalized)) {
      current.add(
        '${FighterChoiceService.battleMasterStudentToolEntryPrefix}$normalized',
      );
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }
}
