part of '../tab_features.dart';

extension _TabFeaturesPaladinSorcererWarlockRangerDecorators
    on _TabFeaturesDecorator {
  List<ClassLevelFeatures> _decoratePaladinSubclassFeatures(
    List<ClassLevelFeatures> entries,
  ) {
    if (character.className != 'paladin' || character.subclass.isEmpty) {
      return entries;
    }

    final genieSkill = PaladinChoiceService.isNobleGenies(
      className: character.className,
      subclass: character.subclass,
      level: character.level,
    )
        ? PaladinChoiceService.selectedGenieSplendorSkill(
            character.levelAdvancements,
          )
        : null;

    if (genieSkill == null) return entries;

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
        if (feature.name == "Genie's Splendor") {
          return withExtraDescription(
            feature,
            [
              'Chosen skill: ${PaladinChoiceService.skillLabel(genieSkill)}.',
              'Armor Class is updated from this feature: 10 + Dexterity modifier + Charisma modifier.',
            ],
          );
        }
        return feature;
      }).toList();

      return ClassLevelFeatures(level: entry.level, features: features);
    }).toList();
  }

  List<ClassLevelFeatures> _decorateSorcererSubclassFeatures(
    List<ClassLevelFeatures> entries,
  ) {
    if (character.className != 'sorcerer' || character.subclass.isEmpty) {
      return entries;
    }

    final affinity = SorcererChoiceService.selectedDraconicAffinity(
      character.levelAdvancements,
    );
    final spellSaveDc = SorcererChoiceService.spellSaveDc(
      level: character.level,
      charisma: character.charisma,
    );
    final charismaUses = SorcererChoiceService.charismaMinimumOne(
      character.charisma,
    );

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
        if (const {
          'Psionic Spells',
          'Clockwork Spells',
          'Draconic Spells',
          'Spellfire Spells',
        }.contains(feature.name)) {
          return withExtraDescription(
            feature,
            [
              'Granted spells from this feature are added automatically and do not need to be selected in the Spells step.',
            ],
          );
        }

        if (feature.name == 'Telepathic Speech') {
          return withExtraDescription(
            feature,
            [
              'Current range: ${charismaUses == 1 ? '1 mile' : '$charismaUses miles'}.',
              'Current duration: ${character.level} minutes.',
            ],
          );
        }

        if (feature.name == 'Warping Implosion') {
          return withExtraDescription(
            feature,
            [
              'Current save DC: $spellSaveDc.',
              'Restoring the use costs 5 Sorcery Points.',
            ],
          );
        }

        if (feature.name == 'Restore Balance') {
          return withExtraDescription(
            feature,
            [
              'Current uses: $charismaUses per Long Rest.',
            ],
          );
        }

        if (feature.name == 'Bastion of Law') {
          return withExtraDescription(
            feature,
            [
              'Current ward pool: 1 to 5 d8s, one die per Sorcery Point spent.',
            ],
          );
        }

        if (feature.name == 'Draconic Resilience') {
          return withExtraDescription(
            feature,
            [
              'Current Hit Point maximum bonus: +${SorcererChoiceService.draconicResilienceHpBonus(className: character.className, subclass: character.subclass, level: character.level)}.',
              'Armor Class is updated from this feature: ${SorcererChoiceService.draconicResilienceArmorClass(dexterity: character.dexterity, charisma: character.charisma)}.',
            ],
          );
        }

        if (feature.name == 'Elemental Affinity') {
          final extra = affinity == null
              ? [
                  'Choose the damage type in the Class step to record its resistance and damage bonus.',
                ]
              : [
                  'Chosen damage type: ${SorcererChoiceService.draconicAffinityLabel(affinity)}.',
                  'You have ${SorcererChoiceService.draconicAffinityLabel(affinity)} resistance.',
                  'Matching spells add ${SorcererChoiceService.elementalAffinityDamageBonus(character.charisma)} to one damage roll.',
                ];
          return withExtraDescription(feature, extra);
        }

        if (feature.name == 'Dragon Wings') {
          return withExtraDescription(
            feature,
            [
              'Current Fly Speed while active: 60 ft.',
              'Restoring the use costs 3 Sorcery Points.',
            ],
          );
        }

        if (feature.name == 'Dragon Companion') {
          return withExtraDescription(
            feature,
            [
              'Summon Dragon is added automatically and can be cast once without a spell slot.',
            ],
          );
        }

        if (feature.name == 'Spellfire Burst') {
          return withExtraDescription(
            feature,
            [
              'Bolstering Flames temporary HP: ${SorcererChoiceService.spellfireBurstTemporaryHpFormula(level: character.level, charisma: character.charisma)}.',
              'Radiant Fire damage: ${SorcererChoiceService.spellfireBurstDamageDie(character.level)} Fire or Radiant.',
            ],
          );
        }

        if (feature.name == 'Absorb Spells') {
          return withExtraDescription(
            feature,
            [
              'Counterspell is added automatically.',
              'A failed save against your Counterspell restores 1d4 Sorcery Points.',
            ],
          );
        }

        if (feature.name == 'Honed Spellfire') {
          return withExtraDescription(
            feature,
            [
              'Bolstering Flames temporary HP is now ${SorcererChoiceService.spellfireBurstTemporaryHpFormula(level: character.level, charisma: character.charisma)}.',
              'Radiant Fire damage is now ${SorcererChoiceService.spellfireBurstDamageDie(character.level)}.',
            ],
          );
        }

        if (feature.name == 'Crown of Spellfire') {
          return withExtraDescription(
            feature,
            [
              'Burning Life Force can expend up to $charismaUses Hit Point Dice per trigger.',
              'Flight from this feature grants a 60 ft Fly Speed and hover.',
            ],
          );
        }

        if (feature.name == 'Bend Luck') {
          return withExtraDescription(
            feature,
            [
              'Current cost: 1 Sorcery Point for a 1d4 bonus or penalty.',
            ],
          );
        }

        return feature;
      }).toList();

      return ClassLevelFeatures(level: entry.level, features: features);
    }).toList();
  }

  List<ClassLevelFeatures> _decorateWarlockSubclassFeatures(
    List<ClassLevelFeatures> entries,
  ) {
    if (character.className != 'warlock' || character.subclass.isEmpty) {
      return entries;
    }

    final charismaUses = WarlockChoiceService.charismaMinimumOne(
      character.charisma,
    );
    final spellSaveDc = WarlockChoiceService.spellSaveDc(
      level: character.level,
      charisma: character.charisma,
    );

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
        if (const {
          'Archfey Spells',
          'Celestial Spells',
          'Fiend Spells',
          'Great Old One Spells',
        }.contains(feature.name)) {
          return withExtraDescription(
            feature,
            [
              'Granted spells from this feature are added automatically and do not need to be selected in the Spells step.',
            ],
          );
        }

        if (feature.name == 'Steps of the Fey') {
          return withExtraDescription(
            feature,
            [
              'Current free Misty Step uses: $charismaUses per Long Rest.',
              'Current save DC for Taunting Step: $spellSaveDc.',
            ],
          );
        }

        if (feature.name == 'Misty Escape') {
          return withExtraDescription(
            feature,
            [
              'Current save DC for Dreadful Step: $spellSaveDc.',
              'Dreadful Step damage: 2d10 Psychic.',
            ],
          );
        }

        if (feature.name == 'Beguiling Defenses') {
          return withExtraDescription(
            feature,
            [
              'Current save DC for the retaliation effect: $spellSaveDc.',
              'The reaction use can be restored by expending a Pact Magic spell slot.',
            ],
          );
        }

        if (feature.name == 'Healing Light') {
          return withExtraDescription(
            feature,
            [
              'Current healing pool: ${WarlockChoiceService.healingLightPoolDice(character.level)}d6.',
              'Maximum dice per Bonus Action: ${WarlockChoiceService.healingLightMaxDice(character.charisma)}d6.',
            ],
          );
        }

        if (feature.name == 'Radiant Soul') {
          return withExtraDescription(
            feature,
            [
              'You have Radiant resistance.',
              'Radiant or Fire spells add ${WarlockChoiceService.charismaModifierLabel(character.charisma)} to one damage roll once per turn.',
            ],
          );
        }

        if (feature.name == 'Celestial Resilience') {
          return withExtraDescription(
            feature,
            [
              'Temporary HP for you: ${WarlockChoiceService.celestialResilienceSelfTempHp(level: character.level, charisma: character.charisma)}.',
              'Temporary HP for each chosen ally: ${WarlockChoiceService.celestialResilienceAllyTempHp(level: character.level, charisma: character.charisma)}.',
            ],
          );
        }

        if (feature.name == 'Searing Vengeance') {
          return withExtraDescription(
            feature,
            [
              'Healing amount for the saved creature: ${character.maxHP ~/ 2} HP.',
              'Radiant burst damage: 2d8 ${WarlockChoiceService.charismaModifierLabel(character.charisma)}.',
            ],
          );
        }

        if (feature.name == "Dark One's Blessing") {
          return withExtraDescription(
            feature,
            [
              'Current Temporary HP gained: ${WarlockChoiceService.darkOnesBlessingTempHp(level: character.level, charisma: character.charisma)}.',
            ],
          );
        }

        if (feature.name == "Dark One's Own Luck") {
          return withExtraDescription(
            feature,
            [
              'Current uses: $charismaUses per Long Rest.',
              'Current bonus die: 1d10.',
            ],
          );
        }

        if (feature.name == 'Fiendish Resilience') {
          return withExtraDescription(
            feature,
            [
              'The resistance type is chosen after each Short or Long Rest, so it is not stored as a permanent sheet choice.',
            ],
          );
        }

        if (feature.name == 'Hurl Through Hell') {
          return withExtraDescription(
            feature,
            [
              'Current save DC: $spellSaveDc.',
              'Damage on failed save: 8d10 Psychic unless the target is a Fiend.',
            ],
          );
        }

        if (feature.name == 'Awakened Mind') {
          return withExtraDescription(
            feature,
            [
              'Current range: ${WarlockChoiceService.awakenedMindMiles(character.charisma)} ${WarlockChoiceService.awakenedMindMiles(character.charisma) == 1 ? 'mile' : 'miles'}.',
              'Current duration: ${character.level} minutes.',
            ],
          );
        }

        if (feature.name == 'Clairvoyant Combatant') {
          return withExtraDescription(
            feature,
            [
              'Current save DC: $spellSaveDc.',
              'The use can be restored by expending a Pact Magic spell slot.',
            ],
          );
        }

        if (feature.name == 'Eldritch Hex') {
          return withExtraDescription(
            feature,
            [
              'Hex is added automatically and does not need to be selected in the Spells step.',
            ],
          );
        }

        if (feature.name == 'Create Thrall') {
          return withExtraDescription(
            feature,
            [
              'Summon Aberration can be modified to require no Concentration for that casting.',
              'Current Aberration Temporary HP: ${WarlockChoiceService.createThrallTempHp(level: character.level, charisma: character.charisma)}.',
            ],
          );
        }

        return feature;
      }).toList();

      return ClassLevelFeatures(level: entry.level, features: features);
    }).toList();
  }

  List<ClassLevelFeatures> _decorateRangerSubclassFeatures(
    List<ClassLevelFeatures> entries,
  ) {
    if (character.className != 'ranger' || character.subclass.isEmpty) {
      return entries;
    }

    final spellSaveDc = RangerChoiceService.spellSaveDc(
      level: character.level,
      wisdom: character.wisdom,
    );
    final wisdomUses = RangerChoiceService.wisdomMinimumOne(
      character.wisdom,
    );
    final feySkill = RangerChoiceService.selectedFeyGlamourSkill(
      character.levelAdvancements,
    );

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
        if (const {
          'Fey Wanderer Spells',
          'Gloom Stalker Spells',
          'Winter Walker Spells',
        }.contains(feature.name)) {
          return withExtraDescription(
            feature,
            [
              'Granted spells from this feature are added automatically and do not need to be selected in the Spells step.',
            ],
          );
        }

        if (feature.name == 'Primal Companion') {
          return withExtraDescription(
            feature,
            [
              'The companion acts on your turn. Its stat block choice can change when you finish a Long Rest, so it is not stored as a permanent sheet choice.',
            ],
          );
        }

        if (feature.name == 'Bestial Fury') {
          return withExtraDescription(
            feature,
            [
              "The beast's extra Force damage matches your Hunter's Mark bonus damage.",
            ],
          );
        }

        if (feature.name == 'Dreadful Strikes') {
          return withExtraDescription(
            feature,
            [
              'Current extra damage: ${RangerChoiceService.dreadfulStrikesDie(character.level)} Psychic once per turn.',
            ],
          );
        }

        if (feature.name == 'Otherworldly Glamour') {
          final extra = <String>[
            'Current Charisma check bonus: +$wisdomUses.',
            'This bonus is applied automatically to Charisma skills on the main tab.',
          ];
          if (feySkill != null) {
            extra.insert(
              0,
              'Chosen skill: ${RangerChoiceService.skillLabel(feySkill)}.',
            );
          }
          return withExtraDescription(feature, extra);
        }

        if (feature.name == 'Beguiling Twist') {
          return withExtraDescription(
            feature,
            [
              'Current save DC: $spellSaveDc.',
            ],
          );
        }

        if (feature.name == 'Fey Reinforcements') {
          return withExtraDescription(
            feature,
            [
              'Summon Fey is added automatically and can be cast once without a spell slot.',
            ],
          );
        }

        if (feature.name == 'Misty Wanderer') {
          return withExtraDescription(
            feature,
            [
              'Current free Misty Step uses: $wisdomUses per Long Rest.',
            ],
          );
        }

        if (feature.name == 'Dread Ambusher') {
          return withExtraDescription(
            feature,
            [
              'Current Dreadful Strike damage: ${RangerChoiceService.dreadAmbusherDamageDie(character.level)} Psychic.',
              'Current uses: $wisdomUses per Long Rest.',
              'Initiative includes your Wisdom modifier on the Combat tab.',
            ],
          );
        }

        if (feature.name == 'Stalker\'s Flurry') {
          return withExtraDescription(
            feature,
            [
              'Current Mass Fear save DC: $spellSaveDc.',
            ],
          );
        }

        if (feature.name == 'Hunter\'s Prey' ||
            feature.name == 'Defensive Tactics') {
          return withExtraDescription(
            feature,
            [
              'This option can change when you finish a Short or Long Rest, so it is not stored as a permanent sheet choice.',
            ],
          );
        }

        if (feature.name == 'Frigid Explorer') {
          return withExtraDescription(
            feature,
            [
              'Cold resistance is tracked in Other Proficiencies.',
              'Polar Strikes damage: ${RangerChoiceService.dreadfulStrikesDie(character.level)} Cold once per turn.',
            ],
          );
        }

        if (feature.name == 'Hunter\'s Rime') {
          return withExtraDescription(
            feature,
            [
              'Temporary HP when you cast Hunter\'s Mark: 1d10 + ${RangerChoiceService.huntersRimeTemporaryHp(character.level)}.',
            ],
          );
        }

        if (feature.name == 'Fortifying Soul') {
          return withExtraDescription(
            feature,
            [
              'Current targets: $wisdomUses.',
              'Healing per target: 1d10 + ${character.level}.',
            ],
          );
        }

        if (feature.name == 'Chilling Retribution') {
          return withExtraDescription(
            feature,
            [
              'Current save DC: $spellSaveDc.',
              'Current uses: $wisdomUses per Long Rest.',
            ],
          );
        }

        if (feature.name == 'Fronzen Haunt' || feature.name == 'Frozen Haunt') {
          return withExtraDescription(
            feature,
            [
              'The form can be restored by expending a level 4+ spell slot.',
              'Frozen Soul damage: 2d4 Cold in a 15-foot Emanation.',
            ],
          );
        }

        return feature;
      }).toList();

      return ClassLevelFeatures(level: entry.level, features: features);
    }).toList();
  }
}
