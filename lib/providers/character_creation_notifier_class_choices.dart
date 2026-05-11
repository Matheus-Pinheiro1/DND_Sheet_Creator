part of 'character_creation_provider.dart';

extension CreationNotifierClassChoices on CreationNotifier {
  void setRogueExpertiseChoices({
    required int rogueLevel,
    required List<String> skillIndices,
  }) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    final prefix = '${RogueChoiceService.expertiseEntryPrefix}$rogueLevel:';

    current.removeWhere((entry) => entry.startsWith(prefix));

    final uniqueSkills = <String>[];
    for (final skill in skillIndices) {
      final normalized = skill.trim();
      if (normalized.isEmpty || uniqueSkills.contains(normalized)) {
        continue;
      }
      uniqueSkills.add(normalized);
      if (uniqueSkills.length >=
          RogueChoiceService.requiredSelectionsForLevel(rogueLevel)) {
        break;
      }
    }

    for (final skill in uniqueSkills) {
      current.add('$prefix$skill');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setBardExpertiseChoices({
    required int bardLevel,
    required List<String> skillIndices,
  }) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    final prefix = '${BardChoiceService.expertiseEntryPrefix}$bardLevel:';

    current.removeWhere((entry) => entry.startsWith(prefix));

    final uniqueSkills = <String>[];
    for (final skill in skillIndices) {
      final normalized = skill.trim();
      if (normalized.isEmpty || uniqueSkills.contains(normalized)) {
        continue;
      }
      uniqueSkills.add(normalized);
      if (uniqueSkills.length >=
          BardChoiceService.requiredExpertiseSelectionsForLevel(bardLevel)) {
        break;
      }
    }

    for (final skill in uniqueSkills) {
      current.add('$prefix$skill');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setBardLoreBonusSkills(List<String> skillIndices) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(BardChoiceService.loreBonusSkillEntryPrefix),
    );

    final uniqueSkills = <String>[];
    for (final skill in skillIndices) {
      final normalized = skill.trim();
      if (!BardChoiceService.loreSkillOptions.contains(normalized) ||
          uniqueSkills.contains(normalized)) {
        continue;
      }
      uniqueSkills.add(normalized);
      if (uniqueSkills.length >= BardChoiceService.loreBonusSkillCount) break;
    }

    for (final skill in uniqueSkills) {
      current.add('${BardChoiceService.loreBonusSkillEntryPrefix}$skill');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setBardLoreDiscoverySpells(List<String> spellIndices) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) =>
          entry.startsWith(BardChoiceService.loreDiscoverySpellEntryPrefix),
    );

    final uniqueSpells = <String>[];
    for (final spell in spellIndices) {
      final normalized = spell.trim();
      if (normalized.isEmpty || uniqueSpells.contains(normalized)) {
        continue;
      }
      uniqueSpells.add(normalized);
      if (uniqueSpells.length >= BardChoiceService.loreDiscoverySpellCount) {
        break;
      }
    }

    for (final spell in uniqueSpells) {
      current.add('${BardChoiceService.loreDiscoverySpellEntryPrefix}$spell');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setBardMoonSkill(String skillIndex) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(BardChoiceService.moonSkillEntryPrefix),
    );

    final normalized = skillIndex.trim();
    if (BardChoiceService.moonSkillOptions.contains(normalized)) {
      current.add('${BardChoiceService.moonSkillEntryPrefix}$normalized');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setBardMoonCantrip(String spellIndex) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(BardChoiceService.moonCantripEntryPrefix),
    );

    final normalized = spellIndex.trim();
    if (normalized.isNotEmpty) {
      current.add('${BardChoiceService.moonCantripEntryPrefix}$normalized');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setDruidPrimalOrder(String order) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(DruidChoiceService.primalOrderEntryPrefix),
    );

    final normalized = order.trim();
    if (DruidChoiceService.primalOrderOptions.containsKey(normalized)) {
      current.add('${DruidChoiceService.primalOrderEntryPrefix}$normalized');
    }

    if (normalized != DruidChoiceService.magicianOrder) {
      current.removeWhere(
        (entry) =>
            entry.startsWith(DruidChoiceService.magicianCantripEntryPrefix),
      );
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setDruidElementalFury(String option) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(DruidChoiceService.elementalFuryEntryPrefix),
    );

    final normalized = option.trim();
    if (DruidChoiceService.elementalFuryOptions.containsKey(normalized)) {
      current.add('${DruidChoiceService.elementalFuryEntryPrefix}$normalized');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setDruidLandType(String landType) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(DruidChoiceService.landTypeEntryPrefix),
    );

    final normalized = landType.trim();
    if (DruidChoiceService.landTypeOptions.containsKey(normalized)) {
      current.add('${DruidChoiceService.landTypeEntryPrefix}$normalized');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setDruidMagicianCantrip(String spellIndex) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) =>
          entry.startsWith(DruidChoiceService.magicianCantripEntryPrefix),
    );

    final normalized = spellIndex.trim();
    if (normalized.isNotEmpty) {
      current.add(
        '${DruidChoiceService.magicianCantripEntryPrefix}$normalized',
      );
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setSorcererMetamagicChoices({
    required int sorcererLevel,
    required List<String> optionIds,
  }) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    final prefix =
        '${SorcererChoiceService.metamagicEntryPrefix}$sorcererLevel:';

    current.removeWhere((entry) => entry.startsWith(prefix));

    final pickedAtOtherLevels = <String>{};
    for (final otherLevel in SorcererChoiceService.unlockedMetamagicLevels(
        _notifierState.level)) {
      if (otherLevel == sorcererLevel) continue;
      pickedAtOtherLevels.addAll(
        SorcererChoiceService.selectedMetamagicOptions(
          current,
          sorcererLevel: otherLevel,
        ),
      );
    }

    final uniqueOptions = <String>[];
    for (final optionId in optionIds) {
      final normalized = optionId.trim();
      if (!SorcererChoiceService.metamagicOptionIds.contains(normalized)) {
        continue;
      }
      if (pickedAtOtherLevels.contains(normalized)) {
        continue;
      }
      if (uniqueOptions.contains(normalized)) {
        continue;
      }
      uniqueOptions.add(normalized);
      if (uniqueOptions.length >=
          SorcererChoiceService.requiredMetamagicSelectionsForLevel(
            sorcererLevel,
          )) {
        break;
      }
    }

    for (final optionId in uniqueOptions) {
      current.add('$prefix$optionId');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setSorcererDraconicAffinity(String affinityId) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) =>
          entry.startsWith(SorcererChoiceService.draconicAffinityEntryPrefix),
    );

    final normalized = affinityId.trim();
    if (SorcererChoiceService.draconicAffinityOptions.containsKey(normalized)) {
      current.add(
          '${SorcererChoiceService.draconicAffinityEntryPrefix}$normalized');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }
}
