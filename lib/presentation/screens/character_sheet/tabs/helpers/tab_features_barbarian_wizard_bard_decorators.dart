part of '../tab_features.dart';

extension _TabFeaturesBarbarianWizardBardDecorators on _TabFeaturesDecorator {
  List<ClassLevelFeatures> _decorateBarbarianSubclassFeatures(
    List<ClassLevelFeatures> entries,
  ) {
    if (character.className != 'barbarian' || character.subclass.isEmpty) {
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

    final rageDamageBonus =
        BarbarianChoiceService.rageDamageBonus(character.level);
    final proficiencyBonus =
        DiceCalculator.getProficiencyBonus(character.level);
    final strengthModifier = DiceCalculator.getModifier(character.strength);
    final barbarianSaveDc = 8 + strengthModifier + proficiencyBonus;

    return entries.map((entry) {
      final features = entry.features.map((feature) {
        if (character.subclass == BarbarianChoiceService.berserkerSubclass) {
          if (feature.name == 'Frenzy') {
            return withExtraDescription(
              feature,
              [
                'Current extra damage: ${BarbarianChoiceService.berserkerFrenzyDamage(character.level)}.',
                'This uses your current Rage Damage bonus: +$rageDamageBonus.',
              ],
            );
          }
          if (feature.name == 'Intimidating Presence') {
            return withExtraDescription(
              feature,
              ['Current save DC: $barbarianSaveDc.'],
            );
          }
        }

        if (character.subclass == BarbarianChoiceService.wildHeartSubclass) {
          if (feature.name == 'Animal Speaker') {
            return withExtraDescription(
              feature,
              [
                'Beast Sense and Speak with Animals are added automatically as ritual-only spells and use Wisdom.',
              ],
            );
          }
          if (feature.name == 'Rage of the Wilds') {
            return withExtraDescription(
              feature,
              [
                'This is not a permanent character-creation choice. Pick Bear, Eagle, or Wolf each time you activate Rage.',
              ],
            );
          }
          if (feature.name == 'Aspect of the Wilds') {
            return withExtraDescription(
              feature,
              [
                'Choose Owl, Panther, or Salmon after each Long Rest; this can change during play, so it is shown as a feature option instead of locked at creation.',
              ],
            );
          }
          if (feature.name == 'Nature Speaker') {
            return withExtraDescription(
              feature,
              [
                'Commune with Nature is added automatically as a ritual-only spell and uses Wisdom.',
              ],
            );
          }
          if (feature.name == 'Power of the Wilds') {
            return withExtraDescription(
              feature,
              [
                'This is not a permanent character-creation choice. Pick Falcon, Lion, or Ram each time you activate Rage.',
              ],
            );
          }
        }

        if (character.subclass == BarbarianChoiceService.worldTreeSubclass) {
          if (feature.name == 'Vitality of the Tree') {
            return withExtraDescription(
              feature,
              [
                'Vitality Surge current Temporary HP: ${character.level}.',
                'Life-Giving Force current dice: ${BarbarianChoiceService.worldTreeLifeGivingForceDice(character.level)}.',
              ],
            );
          }
          if (feature.name == 'Branches of the Tree') {
            return withExtraDescription(
              feature,
              ['Current save DC: $barbarianSaveDc.'],
            );
          }
          if (feature.name == 'Battering Roots') {
            return withExtraDescription(
              feature,
              [
                'Applies to melee weapons with the Heavy or Versatile property; those attacks can add Push or Topple alongside another mastery.',
              ],
            );
          }
        }

        if (character.subclass == BarbarianChoiceService.zealotSubclass) {
          if (feature.name == 'Divine Fury') {
            return withExtraDescription(
              feature,
              [
                'Current extra damage: ${BarbarianChoiceService.zealotDivineFuryDamage(character.level)} Necrotic or Radiant.',
              ],
            );
          }
          if (feature.name == 'Warrior of the Gods') {
            return withExtraDescription(
              feature,
              [
                'Current healing pool: ${BarbarianChoiceService.zealotWarriorOfTheGodsDice(character.level)}d12 per Long Rest.',
              ],
            );
          }
          if (feature.name == 'Fanatical Focus') {
            return withExtraDescription(
              feature,
              [
                'Current reroll bonus: +$rageDamageBonus.',
              ],
            );
          }
          if (feature.name == 'Rage of the Gods') {
            return withExtraDescription(
              feature,
              [
                'Revivification currently sets the target to ${character.level} HP.',
              ],
            );
          }
        }

        return feature;
      }).toList();

      return ClassLevelFeatures(level: entry.level, features: features);
    }).toList();
  }

  List<ClassLevelFeatures> _decorateWizardSubclassFeatures(
    List<ClassLevelFeatures> entries,
  ) {
    if (character.className != 'wizard' || character.subclass.isEmpty) {
      return entries;
    }

    final savantFeatureName =
        WizardChoiceService.savantFeatureNameForSubclass(character.subclass);
    final illusionistCantrip =
        WizardChoiceService.selectedIllusionistBonusCantrip(
              character.levelAdvancements,
            ) ??
            (character.subclass == 'wizard-illusionist' && character.level >= 3
                ? 'minor-illusion'
                : null);

    return entries.map((entry) {
      final features = entry.features.map((feature) {
        if (feature.name == savantFeatureName) {
          final selectedSpells = WizardChoiceService.selectedSavantSpells(
            character.levelAdvancements,
            wizardLevel: entry.level,
          );
          if (selectedSpells.isEmpty) {
            return feature;
          }

          final pieces = <String>[feature.description];
          pieces.add(
            'Chosen spells: ${selectedSpells.map((spell) => spell.replaceAll('-', ' ')).join(', ')}.',
          );
          return ClassFeatureModel(
            id: feature.id,
            name: feature.name,
            description: pieces.join('\n\n'),
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

        if (feature.name == 'Improved Illusions' &&
            illusionistCantrip != null) {
          final pieces = <String>[feature.description];
          pieces.add(
            'Granted cantrip: ${illusionistCantrip.replaceAll('-', ' ')}.',
          );
          return ClassFeatureModel(
            id: feature.id,
            name: feature.name,
            description: pieces.join('\n\n'),
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

        return feature;
      }).toList();

      return ClassLevelFeatures(level: entry.level, features: features);
    }).toList();
  }

  List<ClassLevelFeatures> _decorateBardSubclassFeatures(
    List<ClassLevelFeatures> entries,
  ) {
    if (character.className != 'bard' || character.subclass.isEmpty) {
      return entries;
    }

    ClassFeatureModel withExtraDescription(
      ClassFeatureModel feature,
      List<String> additions,
    ) {
      return ClassFeatureModel(
        id: feature.id,
        name: feature.name,
        description: [feature.description, ...additions].join('\n\n'),
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

    final inspirationDie = BardChoiceService.bardicInspirationDie(
      character.level,
    );
    final dexModifier = DiceCalculator.getModifier(character.dexterity);
    final chaModifier = DiceCalculator.getModifier(character.charisma);
    final danceArmorClass = 10 + dexModifier + chaModifier;
    final loreSkills = BardChoiceService.selectedLoreBonusSkills(
      character.levelAdvancements,
    );
    final loreSpells = BardChoiceService.selectedLoreDiscoverySpells(
      character.levelAdvancements,
    );
    final moonSkill = BardChoiceService.selectedMoonSkill(
      character.levelAdvancements,
    );
    final moonCantrip = BardChoiceService.selectedMoonCantrip(
      character.levelAdvancements,
    );

    return entries.map((entry) {
      final features = entry.features.map((feature) {
        if (character.subclass == BardChoiceService.danceSubclass &&
            feature.name == 'Dazzling Footwork') {
          return withExtraDescription(
            feature,
            [
              'Current unarmored AC: 10 + DEX + CHA = $danceArmorClass.',
              'Dance unarmed strike is synced in Combat as $inspirationDie + DEX.',
            ],
          );
        }

        if (character.subclass == BardChoiceService.danceSubclass &&
            feature.name == 'Tandem Footwork') {
          return withExtraDescription(
            feature,
            ['Current Bardic Inspiration die: $inspirationDie.'],
          );
        }

        if (character.subclass == BardChoiceService.glamourSubclass &&
            feature.name == 'Mantle of Inspiration') {
          return withExtraDescription(
            feature,
            [
              'Current Bardic Inspiration die: $inspirationDie. Temporary HP equals 2 x the die roll.',
            ],
          );
        }

        if (character.subclass == BardChoiceService.glamourSubclass &&
            feature.name == 'Beguiling Magic') {
          return withExtraDescription(
            feature,
            [
              'Charm Person and Mirror Image are added automatically without counting against chosen Bard spells.',
            ],
          );
        }

        if (character.subclass == BardChoiceService.glamourSubclass &&
            feature.name == 'Mantle of Majesty') {
          return withExtraDescription(
            feature,
            [
              'Command is added automatically without counting against chosen Bard spells.',
            ],
          );
        }

        if (character.subclass == BardChoiceService.loreSubclass &&
            feature.name == 'Bonus Proficiencies') {
          if (loreSkills.isEmpty) return feature;
          return withExtraDescription(
            feature,
            [
              'Chosen skills: ${loreSkills.map(BardChoiceService.skillLabel).join(', ')}.',
            ],
          );
        }

        if (character.subclass == BardChoiceService.loreSubclass &&
            feature.name == 'Cutting Words') {
          return withExtraDescription(
            feature,
            ['Current Bardic Inspiration die: $inspirationDie.'],
          );
        }

        if (character.subclass == BardChoiceService.loreSubclass &&
            feature.name == 'Magical Discoveries') {
          if (loreSpells.isEmpty) return feature;
          return withExtraDescription(
            feature,
            [
              'Chosen spells: ${loreSpells.map(BardChoiceService.spellLabel).join(', ')}.',
              'These spells are added to the Spells tab without counting against prepared Bard spells.',
            ],
          );
        }

        if (character.subclass == BardChoiceService.loreSubclass &&
            feature.name == 'Peerless Skill') {
          return withExtraDescription(
            feature,
            ['Current Bardic Inspiration die: $inspirationDie.'],
          );
        }

        if (character.subclass == BardChoiceService.moonSubclass &&
            feature.name == "Moon's Inspiration") {
          return withExtraDescription(
            feature,
            ['Current Bardic Inspiration die: $inspirationDie.'],
          );
        }

        if (character.subclass == BardChoiceService.moonSubclass &&
            feature.name == 'Primal Lore') {
          return withExtraDescription(
            feature,
            [
              'Druidic is added automatically.',
              if (moonSkill != null)
                'Chosen skill: ${BardChoiceService.skillLabel(moonSkill)}.',
              if (moonCantrip != null)
                'Chosen cantrip: ${BardChoiceService.spellLabel(moonCantrip)}.',
              if (moonCantrip != null)
                'This cantrip is added to the Spells tab without counting against chosen Bard cantrips.',
            ],
          );
        }

        if (character.subclass == BardChoiceService.moonSubclass &&
            feature.name == 'Blessing of Moonlight') {
          return withExtraDescription(
            feature,
            [
              'Moonbeam is added automatically without counting against chosen Bard spells.',
            ],
          );
        }

        if (character.subclass == BardChoiceService.moonSubclass &&
            feature.name == "Eventide's Splendor") {
          return withExtraDescription(
            feature,
            ['Current Bardic Inspiration die: $inspirationDie.'],
          );
        }

        if (character.subclass == BardChoiceService.valorSubclass &&
            feature.name == 'Combat Inspiration') {
          return withExtraDescription(
            feature,
            ['Current Bardic Inspiration die: $inspirationDie.'],
          );
        }

        if (character.subclass == BardChoiceService.valorSubclass &&
            feature.name == 'Martial Training') {
          return withExtraDescription(
            feature,
            [
              'Applied proficiencies: ${BardChoiceService.valorProficiencyLabels().join(', ')}.',
            ],
          );
        }

        return feature;
      }).toList();

      return ClassLevelFeatures(level: entry.level, features: features);
    }).toList();
  }
}
