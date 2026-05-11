part of '../tab_features.dart';

extension _TabFeaturesRogueClericFighterDecorators on _TabFeaturesDecorator {
  List<ClassLevelFeatures> _decorateRogueSubclassFeatures(
    List<ClassLevelFeatures> entries,
  ) {
    if (character.className != 'rogue' || character.subclass.isEmpty) {
      return entries;
    }

    ClassFeatureModel withExtraDescription(
      ClassFeatureModel feature,
      List<String> extra,
    ) {
      return ClassFeatureModel(
        id: feature.id,
        name: feature.name,
        description: [feature.description, ...extra].join('\n\n'),
        availableAtLevel: feature.availableAtLevel,
        tags: feature.tags,
        actionType: feature.actionType,
        usage: feature.usage,
        resourceCost: feature.resourceCost,
        recharge: feature.recharge,
        mechanicalEffect: feature.mechanicalEffect,
        summary: feature.summary,
        showInCombat: feature.showInCombat,
        source: feature.source,
      );
    }

    final arcaneCantrips = RogueChoiceService.selectedArcaneTricksterCantrips(
      character.levelAdvancements,
    );
    final arcaneSpells = RogueChoiceService.selectedArcaneTricksterSpells(
      character.levelAdvancements,
    );
    final scionAllegiance = RogueChoiceService.selectedScionDreadAllegiance(
      character.levelAdvancements,
    );

    return entries.map((entry) {
      final features = entry.features.map((feature) {
        if (character.subclass == RogueChoiceService.arcaneTricksterSubclass &&
            feature.name == 'Spellcasting') {
          return withExtraDescription(
            feature,
            [
              'Mage Hand is added automatically.',
              if (arcaneCantrips.isNotEmpty)
                'Chosen cantrips: ${arcaneCantrips.map(RogueChoiceService.spellLabel).join(', ')}.',
              if (arcaneSpells.isNotEmpty)
                'Prepared spells: ${arcaneSpells.map(RogueChoiceService.spellLabel).join(', ')}.',
              'Current slots: ${_slotSummary(RogueChoiceService.arcaneTricksterSpellSlots(character.level))}.',
            ],
          );
        }

        if (character.subclass == RogueChoiceService.soulknifeSubclass &&
            feature.name == 'Psionic Power') {
          return withExtraDescription(
            feature,
            [
              'Current Psionic Energy Dice: ${RogueChoiceService.soulknifePsionicEnergyDice(character.level)}.',
            ],
          );
        }

        if (character.subclass == RogueChoiceService.soulknifeSubclass &&
            feature.name == 'Psychic Blades') {
          return withExtraDescription(
            feature,
            [
              'Psychic Blade and Psychic Blade (Bonus Action) are added automatically to the Attacks list.',
            ],
          );
        }

        if (character.subclass == RogueChoiceService.scionSubclass &&
            feature.name == 'Dread Allegiance' &&
            scionAllegiance != null) {
          return withExtraDescription(
            feature,
            [
              'Chosen allegiance: ${RogueChoiceService.scionDreadAllegianceSummary(scionAllegiance)}',
            ],
          );
        }

        return feature;
      }).toList();

      return ClassLevelFeatures(level: entry.level, features: features);
    }).toList();
  }

  List<ClassLevelFeatures> _decorateClericSubclassFeatures(
    List<ClassLevelFeatures> entries,
  ) {
    if (character.className != 'cleric' ||
        character.subclass != 'cleric-knowledge') {
      return entries;
    }

    final knowledgeSkills = ClericChoiceService.selectedKnowledgeSkills(
      character.levelAdvancements,
    );
    final knowledgeTool = ClericChoiceService.selectedKnowledgeTool(
      character.levelAdvancements,
    );
    if (knowledgeSkills.isEmpty && knowledgeTool == null) {
      return entries;
    }

    ClassFeatureModel withExtraDescription(
      ClassFeatureModel feature,
      List<String> extra,
    ) {
      return ClassFeatureModel(
        id: feature.id,
        name: feature.name,
        description: [feature.description, ...extra].join('\n\n'),
        availableAtLevel: feature.availableAtLevel,
        tags: feature.tags,
        actionType: feature.actionType,
        usage: feature.usage,
        resourceCost: feature.resourceCost,
        recharge: feature.recharge,
        mechanicalEffect: feature.mechanicalEffect,
        summary: feature.summary,
        showInCombat: feature.showInCombat,
        source: feature.source,
      );
    }

    return entries.map((entry) {
      final features = entry.features.map((feature) {
        if (feature.name == 'Blessings of Knowledge') {
          return withExtraDescription(
            feature,
            [
              if (knowledgeSkills.isNotEmpty)
                'Chosen skills: ${knowledgeSkills.map(ClericChoiceService.skillLabel).join(', ')}.',
              if (knowledgeTool != null) 'Chosen tool: $knowledgeTool.',
              'The chosen skills are proficient and gain Expertise.',
            ],
          );
        }
        return feature;
      }).toList();

      return ClassLevelFeatures(level: entry.level, features: features);
    }).toList();
  }

  List<ClassLevelFeatures> _decorateFighterSubclassFeatures(
    List<ClassLevelFeatures> entries,
  ) {
    if (character.className != 'fighter' || character.subclass.isEmpty) {
      return entries;
    }

    ClassFeatureModel withExtraDescription(
      ClassFeatureModel feature,
      List<String> extra,
    ) {
      return ClassFeatureModel(
        id: feature.id,
        name: feature.name,
        description: [feature.description, ...extra].join('\n\n'),
        availableAtLevel: feature.availableAtLevel,
        tags: feature.tags,
        actionType: feature.actionType,
        usage: feature.usage,
        resourceCost: feature.resourceCost,
        recharge: feature.recharge,
        mechanicalEffect: feature.mechanicalEffect,
        summary: feature.summary,
        showInCombat: feature.showInCombat,
        source: feature.source,
      );
    }

    final eldritchCantrips =
        FighterChoiceService.selectedEldritchKnightCantrips(
      character.levelAdvancements,
    );
    final eldritchSpells = FighterChoiceService.selectedEldritchKnightSpells(
      character.levelAdvancements,
    );
    final maneuvers = FighterChoiceService.selectedBattleMasterManeuvers(
      character.levelAdvancements,
      characterLevel: character.level,
    );
    final studentSkill = FighterChoiceService.selectedBattleMasterStudentSkill(
      character.levelAdvancements,
    );
    final studentTool = FighterChoiceService.selectedBattleMasterStudentTool(
      character.levelAdvancements,
    );

    return entries.map((entry) {
      final features = entry.features.map((feature) {
        if (character.subclass == FighterChoiceService.eldritchKnightSubclass &&
            feature.name == 'Spellcasting') {
          return withExtraDescription(
            feature,
            [
              if (eldritchCantrips.isNotEmpty)
                'Chosen cantrips: ${eldritchCantrips.map(FighterChoiceService.spellLabel).join(', ')}.',
              if (eldritchSpells.isNotEmpty)
                'Prepared spells: ${eldritchSpells.map(FighterChoiceService.spellLabel).join(', ')}.',
              'Current slots: ${_slotSummary(FighterChoiceService.eldritchKnightSpellSlots(character.level))}.',
            ],
          );
        }

        if (character.subclass == FighterChoiceService.battleMasterSubclass &&
            feature.name == 'Combat Superiority') {
          return withExtraDescription(
            feature,
            [
              'Current Superiority Dice: ${FighterChoiceService.battleMasterSuperiorityDice(character.level)}.',
              if (maneuvers.isNotEmpty)
                'Chosen maneuvers: ${maneuvers.map(FighterChoiceService.battleMasterManeuverLabel).join(', ')}.',
            ],
          );
        }

        if (character.subclass == FighterChoiceService.battleMasterSubclass &&
            feature.name == 'Student of War') {
          return withExtraDescription(
            feature,
            [
              if (studentSkill != null)
                'Chosen skill: ${FighterChoiceService.skillLabel(studentSkill)}.',
              if (studentTool != null) 'Chosen tool: $studentTool.',
            ],
          );
        }

        if (character.subclass == FighterChoiceService.psiWarriorSubclass &&
            feature.name == 'Psionic Power') {
          return withExtraDescription(
            feature,
            [
              'Current Psionic Energy Dice: ${FighterChoiceService.psiWarriorPsionicEnergyDice(character.level)}.',
            ],
          );
        }

        if (character.subclass == FighterChoiceService.psiWarriorSubclass &&
            feature.name == 'Telekinetic Master' &&
            character.level >= 18) {
          return withExtraDescription(
            feature,
            [
              'Telekinesis is added automatically and uses Intelligence.',
            ],
          );
        }

        return feature;
      }).toList();

      return ClassLevelFeatures(level: entry.level, features: features);
    }).toList();
  }
}
