part of '../tab_features.dart';

extension _TabFeaturesDruidMonkDecorators on _TabFeaturesDecorator {
  List<ClassLevelFeatures> _decorateDruidSubclassFeatures(
    List<ClassLevelFeatures> entries,
  ) {
    if (character.className != 'druid' || character.subclass.isEmpty) {
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

    final landType = DruidChoiceService.selectedLandType(
      character.levelAdvancements,
    );
    final landSpells = DruidChoiceService.landSpellIds(
      className: character.className,
      subclass: character.subclass,
      level: character.level,
      entries: character.levelAdvancements,
    );
    final landResistance = DruidChoiceService.landResistance(
      level: character.level,
      entries: character.levelAdvancements,
    );
    final wisdomModifierText = DiceCalculator.formatModifier(character.wisdom);

    return entries.map<ClassLevelFeatures>((entry) {
      final features = entry.features.map<ClassFeatureModel>((feature) {
        if (character.subclass == DruidChoiceService.landSubclass &&
            feature.name == 'Circle of the Land Spells') {
          return withExtraDescription(
            feature,
            [
              if (landType != null)
                'Chosen land: ${DruidChoiceService.landTypeLabel(landType)}.',
              if (landSpells.isNotEmpty)
                'Prepared spells: ${landSpells.map(DruidChoiceService.spellLabel).join(', ')}.',
              'These spells are added to the Spells tab without counting against prepared Druid spells.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.landSubclass &&
            feature.name == "Land's Aid") {
          return withExtraDescription(
            feature,
            [
              'Current damage and healing: ${DruidChoiceService.landAidDice(character.level)}.',
              'Cost: 1 Wild Shape use.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.landSubclass &&
            feature.name == 'Natural Recovery') {
          return withExtraDescription(
            feature,
            [
              'Current Short Rest recovery limit: ${DruidChoiceService.naturalRecoverySlotLevels(character.level)} spell slot levels.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.landSubclass &&
            feature.name == "Nature's Ward" &&
            landResistance != null) {
          return withExtraDescription(
            feature,
            [
              'Current land resistance: $landResistance.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.landSubclass &&
            feature.name == "Nature's Sanctuary" &&
            landResistance != null) {
          return withExtraDescription(
            feature,
            [
              'Allies in the sanctuary gain your current $landResistance resistance.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.moonSubclass &&
            feature.name == 'Circle Forms') {
          return withExtraDescription(
            feature,
            [
              'Current max Wild Shape CR: ${DruidChoiceService.moonWildShapeMaxChallengeRating(character.level)}.',
              'Wild Shape AC floor: ${DruidChoiceService.moonWildShapeArmorClass(character.wisdom)}.',
              'Temporary HP on Wild Shape: ${DruidChoiceService.moonWildShapeTemporaryHitPoints(character.level)}.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.moonSubclass &&
            feature.name == 'Circle of the Moon Spells') {
          return withExtraDescription(
            feature,
            [
              'These spells are added to the Spells tab without counting against prepared Druid spells.',
              'They can be cast while you are in Wild Shape.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.moonSubclass &&
            feature.name == 'Improved Circle Forms') {
          return withExtraDescription(
            feature,
            [
              'Current Wisdom modifier added to Wild Shape Constitution saves: $wisdomModifierText.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.moonSubclass &&
            feature.name == 'Moonlight Step') {
          return withExtraDescription(
            feature,
            [
              'Current uses per Long Rest: ${DruidChoiceService.moonlightStepUses(character.wisdom)}.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.moonSubclass &&
            feature.name == 'Lunar Form') {
          return withExtraDescription(
            feature,
            [
              'Wild Shape attacks can deal an extra 2d10 Radiant damage once per turn.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.seaSubclass &&
            feature.name == 'Wrath of the Sea') {
          return withExtraDescription(
            feature,
            [
              'Current damage: ${DruidChoiceService.seaWrathDamageDice(character.wisdom)} Cold.',
              'Cost: 1 Wild Shape use.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.seaSubclass &&
            feature.name == 'Circle Spells') {
          return withExtraDescription(
            feature,
            [
              'These spells are added to the Spells tab without counting against prepared Druid spells.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.seaSubclass &&
            feature.name == 'Aquatic Affinity') {
          return withExtraDescription(
            feature,
            [
              'Current Swim Speed: ${character.speed} ft.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.seaSubclass &&
            feature.name == 'Stormborn') {
          return withExtraDescription(
            feature,
            [
              'Current Fly Speed while Wrath of the Sea is active: ${character.speed} ft.',
              'Current conditional resistances: ${DruidChoiceService.seaStormbornResistances()}.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.seaSubclass &&
            feature.name == 'Oceanic Gift') {
          return withExtraDescription(
            feature,
            [
              'Manifesting Wrath of the Sea around both targets costs 2 Wild Shape uses.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.starsSubclass &&
            feature.name == 'Star Map') {
          return withExtraDescription(
            feature,
            [
              'Guidance and Guiding Bolt are added to the Spells tab without counting against prepared Druid spells.',
              'Current free Guiding Bolt uses per Long Rest: ${DruidChoiceService.starsGuidingBoltUses(character.wisdom)}.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.starsSubclass &&
            feature.name == 'Starry Form') {
          return withExtraDescription(
            feature,
            [
              'Current Archer and Chalice die: ${DruidChoiceService.starryFormDie(character.level)}.',
              'The die adds your Wisdom modifier ($wisdomModifierText) where the feature says so.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.starsSubclass &&
            feature.name == 'Cosmic Omen') {
          return withExtraDescription(
            feature,
            [
              'Current uses per Long Rest: ${DruidChoiceService.cosmicOmenUses(character.wisdom)}.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.starsSubclass &&
            feature.name == 'Twinkling Constellations') {
          return withExtraDescription(
            feature,
            [
              'Archer and Chalice now use ${DruidChoiceService.starryFormDie(character.level)}.',
              'Dragon grants a 20 ft Fly Speed and hover while active.',
            ],
          );
        }

        if (character.subclass == DruidChoiceService.starsSubclass &&
            feature.name == 'Full of Stars') {
          return withExtraDescription(
            feature,
            [
              'While Starry Form is active, you resist Bludgeoning, Piercing, and Slashing damage.',
            ],
          );
        }

        return feature;
      }).toList();

      return ClassLevelFeatures(level: entry.level, features: features);
    }).toList();
  }

  List<ClassLevelFeatures> _decorateMonkSubclassFeatures(
    List<ClassLevelFeatures> entries,
  ) {
    if (character.className != 'monk' || character.subclass.isEmpty) {
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

    final martialArtsDie = MonkChoiceService.martialArtsDie(character.level);
    final monkSaveDc = MonkChoiceService.monkSaveDc(
      level: character.level,
      wisdom: character.wisdom,
    );
    final wisdomUses = MonkChoiceService.wisdomUses(character.wisdom);
    final martialArtsPlusWisdom =
        MonkChoiceService.martialArtsPlusWisdomFormula(
      level: character.level,
      wisdom: character.wisdom,
    );

    return entries.map<ClassLevelFeatures>((entry) {
      final features = entry.features.map<ClassFeatureModel>((feature) {
        if (character.subclass == MonkChoiceService.mercySubclass &&
            feature.name == 'Implements of Mercy') {
          return withExtraDescription(
            feature,
            [
              'Insight, Medicine, and Herbalism Kit proficiency are added automatically.',
            ],
          );
        }

        if (character.subclass == MonkChoiceService.mercySubclass &&
            feature.name == 'Hand of Harm') {
          return withExtraDescription(
            feature,
            [
              'Current extra damage: $martialArtsPlusWisdom Necrotic.',
              'Cost: 1 Focus Point.',
            ],
          );
        }

        if (character.subclass == MonkChoiceService.mercySubclass &&
            feature.name == 'Hand of Healing') {
          return withExtraDescription(
            feature,
            [
              'Current healing: $martialArtsPlusWisdom HP.',
              'Cost: 1 Focus Point, or replaces one Flurry of Blows strike without extra Focus cost.',
            ],
          );
        }

        if (character.subclass == MonkChoiceService.mercySubclass &&
            feature.name == "Physician's Touch") {
          return withExtraDescription(
            feature,
            [
              'Hand of Harm can also Poison; Hand of Healing can also end listed conditions.',
            ],
          );
        }

        if (character.subclass == MonkChoiceService.mercySubclass &&
            feature.name == 'Flurry of Healing and Harm') {
          return withExtraDescription(
            feature,
            [
              'Current free benefit uses per Long Rest: $wisdomUses.',
            ],
          );
        }

        if (character.subclass == MonkChoiceService.mercySubclass &&
            feature.name == 'Hand of Ultimate Mercy') {
          return withExtraDescription(
            feature,
            [
              'Current revival healing: ${MonkChoiceService.ultimateMercyHealingFormula(character.wisdom)} HP.',
              'Cost: 5 Focus Points.',
            ],
          );
        }

        if (character.subclass == MonkChoiceService.shadowSubclass &&
            feature.name == 'Shadow Arts') {
          return withExtraDescription(
            feature,
            [
              'Darkness and Minor Illusion are added to the Spells tab.',
              'Darkness costs 1 Focus Point through this feature.',
              'Darkvision +60 ft is added to proficiencies.',
            ],
          );
        }

        if (character.subclass == MonkChoiceService.shadowSubclass &&
            feature.name == 'Improved Shadow Step') {
          return withExtraDescription(
            feature,
            [
              'Removing the Dim Light/Darkness requirement costs 1 Focus Point.',
            ],
          );
        }

        if (character.subclass == MonkChoiceService.shadowSubclass &&
            feature.name == 'Cloak of Shadows') {
          return withExtraDescription(
            feature,
            [
              'Cost: 3 Focus Points. While active, Flurry of Blows costs 0 Focus Points.',
            ],
          );
        }

        if (character.subclass == MonkChoiceService.elementsSubclass &&
            feature.name == 'Elemental Attunement') {
          return withExtraDescription(
            feature,
            [
              'Current Unarmed Strike damage die: $martialArtsDie.',
              'Elemental save DC: $monkSaveDc.',
              'Available damage types: ${MonkChoiceService.elementalDamageTypeSummary()}.',
            ],
          );
        }

        if (character.subclass == MonkChoiceService.elementsSubclass &&
            feature.name == 'Manipulate Elements') {
          return withExtraDescription(
            feature,
            [
              'Elementalism is added to the Spells tab and uses Wisdom.',
            ],
          );
        }

        if (character.subclass == MonkChoiceService.elementsSubclass &&
            feature.name == 'Elemental Burst') {
          return withExtraDescription(
            feature,
            [
              'Current damage: ${MonkChoiceService.elementalBurstDamageFormula(character.level)}.',
              'Save DC: $monkSaveDc. Cost: 2 Focus Points.',
            ],
          );
        }

        if (character.subclass == MonkChoiceService.elementsSubclass &&
            feature.name == 'Stride of the Elements') {
          return withExtraDescription(
            feature,
            [
              'Current Fly and Swim Speed while attuned: ${character.speed} ft.',
            ],
          );
        }

        if (character.subclass == MonkChoiceService.elementsSubclass &&
            feature.name == 'Elemental Epitome') {
          return withExtraDescription(
            feature,
            [
              'Resistance can be changed each turn among ${MonkChoiceService.elementalDamageTypeSummary()}.',
              'Destructive Stride and Empowered Strikes use $martialArtsDie.',
            ],
          );
        }

        if (character.subclass == MonkChoiceService.openHandSubclass &&
            feature.name == 'Open Hand Technique') {
          return withExtraDescription(
            feature,
            [
              'Current save DC for Push and Topple: $monkSaveDc.',
            ],
          );
        }

        if (character.subclass == MonkChoiceService.openHandSubclass &&
            feature.name == 'Wholeness of Body') {
          return withExtraDescription(
            feature,
            [
              'Current healing: $martialArtsPlusWisdom HP.',
              'Current uses per Long Rest: $wisdomUses.',
            ],
          );
        }

        if (character.subclass == MonkChoiceService.openHandSubclass &&
            feature.name == 'Quivering Palm') {
          return withExtraDescription(
            feature,
            [
              'Save DC: $monkSaveDc. Cost: 4 Focus Points. Damage: 10d12 Force, half on success.',
            ],
          );
        }

        return feature;
      }).toList();

      return ClassLevelFeatures(level: entry.level, features: features);
    }).toList();
  }
}
