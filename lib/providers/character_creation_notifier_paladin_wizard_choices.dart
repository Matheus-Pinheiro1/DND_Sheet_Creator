part of 'character_creation_provider.dart';

extension CreationNotifierPaladinWizardChoices on CreationNotifier {
  void setPaladinFightingStyle(String style) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) =>
          entry.startsWith(PaladinChoiceService.fightingStyleEntryPrefix),
    );
    if (style.trim().isNotEmpty) {
      current.add('${PaladinChoiceService.fightingStyleEntryPrefix}$style');
    }
    if (style != 'Blessed Warrior') {
      current.removeWhere(
        (entry) =>
            entry.startsWith(PaladinChoiceService.blessedWarriorCantripPrefix),
      );
    }
    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setPaladinWeaponMasteries(List<String> weapons) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) =>
          entry.startsWith(PaladinChoiceService.weaponMasteryEntryPrefix),
    );

    final uniqueWeapons = <String>[];
    for (final weapon in weapons) {
      final normalized = weapon.trim();
      if (normalized.isEmpty || uniqueWeapons.contains(normalized)) {
        continue;
      }
      uniqueWeapons.add(normalized);
      if (uniqueWeapons.length >=
          PaladinChoiceService.weaponMasterySelectionCount) {
        break;
      }
    }

    for (final weapon in uniqueWeapons) {
      current.add('${PaladinChoiceService.weaponMasteryEntryPrefix}$weapon');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setPaladinBlessedWarriorCantrips(List<String> spellIndices) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) =>
          entry.startsWith(PaladinChoiceService.blessedWarriorCantripPrefix),
    );

    final uniqueSpells = <String>[];
    for (final spell in spellIndices) {
      final normalized = spell.trim();
      if (normalized.isEmpty || uniqueSpells.contains(normalized)) {
        continue;
      }
      uniqueSpells.add(normalized);
      if (uniqueSpells.length >=
          PaladinChoiceService.blessedWarriorCantripCount) {
        break;
      }
    }

    for (final spell in uniqueSpells) {
      current.add(
        '${PaladinChoiceService.blessedWarriorCantripPrefix}$spell',
      );
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setPaladinGenieSplendorSkill(String skillIndex) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) =>
          entry.startsWith(PaladinChoiceService.genieSplendorSkillEntryPrefix),
    );

    final normalized = skillIndex.trim();
    if (PaladinChoiceService.genieSplendorSkillOptions.contains(normalized)) {
      current.add(
          '${PaladinChoiceService.genieSplendorSkillEntryPrefix}$normalized');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setWizardScholarSkill(String skillIndex) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(WizardChoiceService.scholarEntryPrefix),
    );
    if (skillIndex.trim().isNotEmpty) {
      current.add('${WizardChoiceService.scholarEntryPrefix}$skillIndex');
    }
    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void toggleWizardSavantSpell({
    required int wizardLevel,
    required String spellIndex,
    required int maxSelections,
  }) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    final prefix = '${WizardChoiceService.savantEntryPrefix}$wizardLevel:';
    final selected = current
        .where((entry) => entry.startsWith(prefix))
        .map((entry) => entry.substring(prefix.length))
        .where((entry) => entry.isNotEmpty)
        .toList();

    if (selected.contains(spellIndex)) {
      current.removeWhere((entry) => entry == '$prefix$spellIndex');
    } else {
      if (selected.length >= maxSelections) return;
      current.add('$prefix$spellIndex');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setIllusionistBonusCantrip(String spellIndex) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(WizardChoiceService.illusionistCantripPrefix),
    );
    if (spellIndex.trim().isNotEmpty) {
      current.add('${WizardChoiceService.illusionistCantripPrefix}$spellIndex');
    }
    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }
}
