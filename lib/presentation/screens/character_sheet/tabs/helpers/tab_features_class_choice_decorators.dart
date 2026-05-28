part of '../tab_features.dart';

extension _TabFeaturesClassChoiceDecorators on _TabFeaturesDecorator {
  List<ClassLevelFeatures> _decorateClassChoiceFeatures(
    List<ClassLevelFeatures> entries,
  ) {
    final divineOrder = _selectedChoiceValue('class_choice:divine_order:');
    final divineOrderCantrip =
        _selectedChoiceValue('class_choice:divine_order_cantrip:');
    final scholarSkill = WizardChoiceService.selectedScholarSkill(
      character.levelAdvancements,
    );
    final clericKnowledgeSkills = character.className == 'cleric'
        ? ClericChoiceService.selectedKnowledgeSkills(
            character.levelAdvancements,
          )
        : const <String>[];
    final clericKnowledgeTool = character.className == 'cleric'
        ? ClericChoiceService.selectedKnowledgeTool(character.levelAdvancements)
        : null;

    final rogueExpertiseByLevel = <int, List<String>>{};
    if (character.className == 'rogue') {
      for (final rogueLevel
          in RogueChoiceService.unlockedExpertiseLevels(character.level)) {
        rogueExpertiseByLevel[rogueLevel] =
            RogueChoiceService.selectedExpertiseSkills(
          character.levelAdvancements,
          rogueLevel: rogueLevel,
        );
      }
    }

    final bardExpertiseByLevel = <int, List<String>>{};
    if (character.className == 'bard') {
      for (final bardLevel
          in BardChoiceService.unlockedExpertiseLevels(character.level)) {
        bardExpertiseByLevel[bardLevel] =
            BardChoiceService.selectedExpertiseSkills(
          character.levelAdvancements,
          bardLevel: bardLevel,
        );
      }
    }

    final rangerExpertiseByLevel = <int, List<String>>{};
    final rangerLanguages = character.className == 'ranger'
        ? RangerChoiceService.selectedLanguages(character.levelAdvancements)
        : const <String>[];
    final rangerFightingStyle = character.className == 'ranger'
        ? RangerChoiceService.selectedFightingStyle(character.levelAdvancements)
        : null;
    final rangerWeaponMasteries = character.className == 'ranger'
        ? RangerChoiceService.selectedWeaponMasteries(
            character.levelAdvancements)
        : const <String>[];
    final rangerDruidicCantrips = character.className == 'ranger' &&
            rangerFightingStyle == 'Druidic Warrior'
        ? RangerChoiceService.selectedDruidicWarriorCantrips(
            character.levelAdvancements,
          )
        : const <String>[];
    final barbarianWeaponMasteries = character.className == 'barbarian'
        ? BarbarianChoiceService.selectedWeaponMasteries(
            character.levelAdvancements,
            characterLevel: character.level,
          )
        : const <String>[];
    final barbarianPrimalKnowledgeSkill = character.className == 'barbarian'
        ? BarbarianChoiceService.selectedPrimalKnowledgeSkill(
            character.levelAdvancements,
          )
        : null;
    final fighterWeaponMasteries = character.className == 'fighter'
        ? FighterChoiceService.selectedWeaponMasteries(
            character.levelAdvancements,
            characterLevel: character.level,
          )
        : const <String>[];
    final paladinFightingStyle = character.className == 'paladin'
        ? PaladinChoiceService.selectedFightingStyle(
            character.levelAdvancements,
          )
        : null;
    final paladinWeaponMasteries = character.className == 'paladin'
        ? PaladinChoiceService.selectedWeaponMasteries(
            character.levelAdvancements,
          )
        : const <String>[];
    final paladinBlessedCantrips = character.className == 'paladin' &&
            paladinFightingStyle == 'Blessed Warrior'
        ? PaladinChoiceService.selectedBlessedWarriorCantrips(
            character.levelAdvancements,
          )
        : const <String>[];
    final druidPrimalOrder = character.className == 'druid' &&
            character.level >= 1
        ? DruidChoiceService.selectedPrimalOrder(character.levelAdvancements)
        : null;
    final druidElementalFury = character.className == 'druid' &&
            character.level >= 7
        ? DruidChoiceService.selectedElementalFury(character.levelAdvancements)
        : null;
    final druidMagicianCantrip =
        character.className == 'druid' && character.level >= 1
            ? DruidChoiceService.selectedMagicianCantrip(
                character.levelAdvancements,
              )
            : null;
    final sorcererMetamagicByLevel = <int, List<String>>{};
    if (character.className == 'sorcerer') {
      for (final sorcererLevel
          in SorcererChoiceService.unlockedMetamagicLevels(character.level)) {
        sorcererMetamagicByLevel[sorcererLevel] =
            SorcererChoiceService.selectedMetamagicOptions(
          character.levelAdvancements,
          sorcererLevel: sorcererLevel,
        );
      }
    }
    final warlockInvocations = character.className == 'warlock'
        ? WarlockChoiceService.selectedInvocations(character.levelAdvancements)
        : const <String>[];
    final warlockPactTomeCantrips = character.className == 'warlock'
        ? WarlockChoiceService.selectedPactTomeCantrips(
            character.levelAdvancements,
          )
        : const <String>[];
    final warlockPactTomeRituals = character.className == 'warlock'
        ? WarlockChoiceService.selectedPactTomeRituals(
            character.levelAdvancements,
          )
        : const <String>[];
    final warlockArcanumByLevel = <int, String?>{};
    if (character.className == 'warlock') {
      for (final spellLevel
          in WarlockChoiceService.mysticArcanumSpellLevels(character.level)) {
        warlockArcanumByLevel[spellLevel] =
            WarlockChoiceService.selectedMysticArcanumSpell(
          character.levelAdvancements,
          spellLevel: spellLevel,
        );
      }
    }

    if (character.className == 'ranger') {
      for (final rangerLevel
          in RangerChoiceService.unlockedExpertiseLevels(character.level)) {
        rangerExpertiseByLevel[rangerLevel] =
            RangerChoiceService.selectedExpertiseSkills(
          character.levelAdvancements,
          rangerLevel: rangerLevel,
        );
      }
    }

    final hasRogueChoices = rogueExpertiseByLevel.values.any(
      (skills) => skills.isNotEmpty,
    );
    final hasBardChoices = character.className == 'bard' ||
        bardExpertiseByLevel.values.any((skills) => skills.isNotEmpty);
    final hasRangerChoices = rangerLanguages.isNotEmpty ||
        rangerFightingStyle != null ||
        rangerWeaponMasteries.isNotEmpty ||
        rangerDruidicCantrips.isNotEmpty ||
        rangerExpertiseByLevel.values.any((skills) => skills.isNotEmpty);
    final hasBarbarianChoices = barbarianWeaponMasteries.isNotEmpty ||
        barbarianPrimalKnowledgeSkill != null;
    final hasFighterChoices = fighterWeaponMasteries.isNotEmpty;
    final hasPaladinChoices = paladinFightingStyle != null ||
        paladinWeaponMasteries.isNotEmpty ||
        paladinBlessedCantrips.isNotEmpty;
    final hasDruidChoices = druidPrimalOrder != null ||
        druidElementalFury != null ||
        druidMagicianCantrip != null;
    final hasSorcererChoices = character.className == 'sorcerer' ||
        sorcererMetamagicByLevel.values.any((options) => options.isNotEmpty);
    final hasWarlockChoices = character.className == 'warlock' ||
        warlockInvocations.isNotEmpty ||
        warlockPactTomeCantrips.isNotEmpty ||
        warlockPactTomeRituals.isNotEmpty ||
        warlockArcanumByLevel.values.any((spell) => spell != null);
    final hasMonkFeatures = MonkChoiceService.isMonk(
      className: character.className,
    );
    final hasClericKnowledgeChoices =
        clericKnowledgeSkills.isNotEmpty || clericKnowledgeTool != null;

    if (divineOrder.isEmpty &&
        scholarSkill == null &&
        !hasClericKnowledgeChoices &&
        !hasRogueChoices &&
        !hasBardChoices &&
        !hasRangerChoices &&
        !hasBarbarianChoices &&
        !hasFighterChoices &&
        !hasPaladinChoices &&
        !hasDruidChoices &&
        !hasSorcererChoices &&
        !hasWarlockChoices &&
        !hasMonkFeatures) {
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

    return entries.map((entry) {
      final features = entry.features.map<ClassFeatureModel>((feature) {
        if (feature.name == 'Divine Order') {
          final pieces = <String>[];
          if (divineOrder.isNotEmpty) {
            pieces.add(
              'Chosen order: ${divineOrder[0].toUpperCase()}${divineOrder.substring(1)}.',
            );
            if (divineOrder == 'thaumaturge' && divineOrderCantrip.isNotEmpty) {
              pieces.add(
                'Chosen Cleric cantrip: ${divineOrderCantrip.replaceAll('-', ' ')}.',
              );
            }
          }
          if (pieces.isNotEmpty) {
            return withExtraDescription(feature, pieces);
          }
        }

        if (feature.name == 'Scholar' && scholarSkill != null) {
          return withExtraDescription(
            feature,
            [
              'Chosen skill: ${WizardChoiceService.skillLabel(scholarSkill)}.',
              'This choice grants Expertise in that skill.',
            ],
          );
        }

        if (feature.name == 'Blessings of Knowledge' &&
            hasClericKnowledgeChoices) {
          return withExtraDescription(
            feature,
            [
              if (clericKnowledgeSkills.isNotEmpty)
                'Chosen skills: ${clericKnowledgeSkills.map(ClericChoiceService.skillLabel).join(', ')}.',
              if (clericKnowledgeTool != null)
                'Chosen tool: $clericKnowledgeTool.',
              'The chosen skills are proficient and gain Expertise.',
            ],
          );
        }

        if (MonkChoiceService.isMonk(className: character.className)) {
          if (feature.name == 'Martial Arts') {
            return withExtraDescription(
              feature,
              [
                'Current Martial Arts die: ${MonkChoiceService.martialArtsDie(character.level)}.',
                'Unarmed Strike is synced automatically in the Combat tab.',
              ],
            );
          }

          if (feature.name == "Monk's Focus") {
            return withExtraDescription(
              feature,
              [
                'Current Focus Points: ${MonkChoiceService.focusPoints(character.level)}.',
                'Monk save DC: ${MonkChoiceService.stunningStrikeSaveDc(level: character.level, wisdom: character.wisdom)}.',
              ],
            );
          }

          if (feature.name == 'Unarmored Movement') {
            return withExtraDescription(
              feature,
              [
                'Current speed bonus: +${MonkChoiceService.unarmoredMovementBonus(character.level)} ft.',
              ],
            );
          }

          if (feature.name == 'Uncanny Metabolism') {
            return withExtraDescription(
              feature,
              [
                'Current healing: ${MonkChoiceService.uncannyMetabolismHealingFormula(character.level)} HP.',
              ],
            );
          }

          if (feature.name == 'Deflect Attacks' ||
              feature.name == 'Deflect Energy') {
            return withExtraDescription(
              feature,
              [
                'Current damage reduction: ${MonkChoiceService.deflectAttacksReductionFormula(level: character.level, dexterity: character.dexterity)}.',
                'Redirect damage after reducing to 0: ${MonkChoiceService.deflectRedirectDamageFormula(level: character.level, dexterity: character.dexterity)}.',
              ],
            );
          }

          if (feature.name == 'Slow Fall') {
            return withExtraDescription(
              feature,
              [
                'Current fall damage reduction: ${MonkChoiceService.slowFallReduction(character.level)}.',
              ],
            );
          }

          if (feature.name == 'Stunning Strike') {
            return withExtraDescription(
              feature,
              [
                'Current save DC: ${MonkChoiceService.stunningStrikeSaveDc(level: character.level, wisdom: character.wisdom)}.',
              ],
            );
          }

          if (feature.name == 'Heightened Focus') {
            return withExtraDescription(
              feature,
              [
                'Patient Defense temporary HP: ${MonkChoiceService.heightenedFocusTemporaryHpFormula(character.level)}.',
              ],
            );
          }

          if (feature.name == 'Perfect Focus') {
            return withExtraDescription(
              feature,
              [
                'When initiative is rolled, recover to 4 Focus Points if you have 3 or fewer and do not use Uncanny Metabolism.',
              ],
            );
          }

          if (feature.name == 'Body and Mind') {
            return withExtraDescription(
              feature,
              [
                'Dexterity and Wisdom are increased by ${MonkChoiceService.bodyAndMindAbilityBonus}, up to ${MonkChoiceService.bodyAndMindAbilityMaximum}; the sheet applies this automatically.',
              ],
            );
          }
        }

        if (character.className == 'bard') {
          if (feature.name == 'Bardic Inspiration') {
            final charismaMod = DiceCalculator.getModifier(character.charisma);
            final uses = charismaMod < 1 ? 1 : charismaMod;
            return withExtraDescription(
              feature,
              [
                'Current die: ${BardChoiceService.bardicInspirationDie(character.level)}.',
                'Current uses: $uses per rest based on Charisma.',
              ],
            );
          }

          if (feature.name == 'Expertise') {
            final selected =
                bardExpertiseByLevel[entry.level] ?? const <String>[];
            if (selected.isNotEmpty) {
              return withExtraDescription(
                feature,
                [
                  'Chosen skills: ${selected.map(BardChoiceService.skillLabel).join(', ')}.',
                  'These skills gain Expertise.',
                ],
              );
            }
          }

          if (feature.name == 'Magical Secrets') {
            return withExtraDescription(
              feature,
              [
                'The Bard level 1+ spell picker includes Bard, Cleric, Druid, and Wizard spells at this level.',
              ],
            );
          }

          if (feature.name == 'Words of Creation') {
            return withExtraDescription(
              feature,
              [
                'Power Word Heal and Power Word Kill are added to the spell list automatically.',
              ],
            );
          }
        }

        if (character.className == 'ranger') {
          if (feature.name == 'Weapon Mastery' &&
              rangerWeaponMasteries.isNotEmpty) {
            return withExtraDescription(
              feature,
              [
                'Chosen weapons: ${rangerWeaponMasteries.join(', ')}.',
              ],
            );
          }

          if (feature.name == 'Fighting Style' && rangerFightingStyle != null) {
            final pieces = <String>[
              'Chosen style: $rangerFightingStyle.',
            ];
            if (rangerFightingStyle == 'Druidic Warrior' &&
                rangerDruidicCantrips.isNotEmpty) {
              pieces.add(
                'Chosen Druid cantrips: ${rangerDruidicCantrips.map((spell) => spell.replaceAll('-', ' ')).join(', ')}.',
              );
            }
            return withExtraDescription(feature, pieces);
          }

          if (feature.name == 'Deft Explorer') {
            final selected =
                rangerExpertiseByLevel[entry.level] ?? const <String>[];
            final pieces = <String>[];
            if (selected.isNotEmpty) {
              pieces.add(
                'Chosen Expertise skill: ${selected.map(RangerChoiceService.skillLabel).join(', ')}.',
              );
            }
            if (rangerLanguages.isNotEmpty) {
              pieces.add('Chosen languages: ${rangerLanguages.join(', ')}.');
            }
            if (pieces.isNotEmpty) {
              return withExtraDescription(feature, pieces);
            }
          }

          if (feature.name == 'Expertise') {
            final selected =
                rangerExpertiseByLevel[entry.level] ?? const <String>[];
            if (selected.isNotEmpty) {
              return withExtraDescription(
                feature,
                [
                  'Chosen skills: ${selected.map(RangerChoiceService.skillLabel).join(', ')}.',
                  'These skills gain Expertise.',
                ],
              );
            }
          }
        }

        if (character.className == 'barbarian') {
          if (feature.name == 'Weapon Mastery' &&
              barbarianWeaponMasteries.isNotEmpty) {
            return withExtraDescription(
              feature,
              [
                'Chosen weapons: ${barbarianWeaponMasteries.join(', ')}.',
              ],
            );
          }

          if (feature.name == 'Primal Knowledge' &&
              barbarianPrimalKnowledgeSkill != null) {
            return withExtraDescription(
              feature,
              [
                'Chosen skill: ${BarbarianChoiceService.skillLabel(barbarianPrimalKnowledgeSkill)}.',
                'This skill is added to your proficient skills.',
              ],
            );
          }
        }

        if (character.className == 'fighter') {
          if (feature.name == 'Weapon Mastery' &&
              fighterWeaponMasteries.isNotEmpty) {
            return withExtraDescription(
              feature,
              [
                'Chosen weapons: ${fighterWeaponMasteries.join(', ')}.',
              ],
            );
          }
        }

        if (character.className == 'paladin') {
          if (feature.name == 'Weapon Mastery' &&
              paladinWeaponMasteries.isNotEmpty) {
            return withExtraDescription(
              feature,
              [
                'Chosen weapons: ${paladinWeaponMasteries.join(', ')}.',
              ],
            );
          }

          if (feature.name == 'Fighting Style' &&
              paladinFightingStyle != null) {
            final pieces = <String>[
              'Chosen style: $paladinFightingStyle.',
            ];
            if (paladinFightingStyle == 'Blessed Warrior' &&
                paladinBlessedCantrips.isNotEmpty) {
              pieces.add(
                'Chosen Cleric cantrips: ${paladinBlessedCantrips.map((spell) => spell.replaceAll('-', ' ')).join(', ')}.',
              );
            }
            return withExtraDescription(feature, pieces);
          }
        }

        if (character.className == 'druid') {
          if (feature.name == 'Primal Order' && druidPrimalOrder != null) {
            final pieces = <String>[
              'Chosen order: ${DruidChoiceService.primalOrderLabel(druidPrimalOrder)}.',
            ];
            if (druidPrimalOrder == DruidChoiceService.magicianOrder) {
              final bonus = DruidChoiceService.magicianSkillBonus(
                className: character.className,
                level: character.level,
                entries: character.levelAdvancements,
                wisdom: character.wisdom,
                skillIndex: 'arcana',
              );
              pieces.add(
                'Chosen extra cantrip: ${druidMagicianCantrip?.replaceAll('-', ' ') ?? 'not selected'}.',
              );
              pieces.add('Arcana and Nature checks gain +$bonus.');
            }
            if (druidPrimalOrder == DruidChoiceService.wardenOrder) {
              pieces.add(
                'Martial weapon and Medium armor proficiency are added automatically.',
              );
            }
            return withExtraDescription(feature, pieces);
          }

          if (feature.name == 'Wild Shape') {
            return withExtraDescription(
              feature,
              [
                'Current uses: ${DruidChoiceService.wildShapeUses(character.level)}.',
                'Current duration: ${DruidChoiceService.wildShapeDuration(character.level)}.',
              ],
            );
          }

          if (feature.name == 'Elemental Fury' && druidElementalFury != null) {
            final pieces = <String>[
              'Chosen option: ${DruidChoiceService.elementalFuryLabel(druidElementalFury)}.',
            ];
            if (druidElementalFury == DruidChoiceService.primalStrike) {
              pieces.add(
                'Current extra damage: ${DruidChoiceService.elementalFuryDamageDie(character.level)}.',
              );
            }
            return withExtraDescription(feature, pieces);
          }

          if (feature.name == 'Improved Elemental Fury' &&
              druidElementalFury != null) {
            return withExtraDescription(
              feature,
              [
                'This improves your ${DruidChoiceService.elementalFuryLabel(druidElementalFury)} choice.',
              ],
            );
          }
        }

        if (character.className == 'sorcerer') {
          if (feature.name == 'Innate Sorcery') {
            return withExtraDescription(
              feature,
              [
                'Current uses: ${SorcererChoiceService.innateSorceryUses(character.level)} per Long Rest.',
                'While active, your Sorcerer spell save DC increases by 1 and your Sorcerer spell attacks have Advantage.',
              ],
            );
          }

          if (feature.name == 'Font of Magic') {
            return withExtraDescription(
              feature,
              [
                'Current Sorcery Point maximum: ${SorcererChoiceService.sorceryPointMaximum(character.level)}.',
                'You can convert spell slots into Sorcery Points, or spend Sorcery Points to create temporary spell slots.',
              ],
            );
          }

          if (feature.name == 'Metamagic') {
            final selected =
                sorcererMetamagicByLevel[entry.level] ?? const <String>[];
            if (selected.isNotEmpty) {
              return withExtraDescription(
                feature,
                [
                  'Chosen options: ${selected.map(SorcererChoiceService.metamagicLabel).join(', ')}.',
                  ...selected.map(
                    (optionId) =>
                        '${SorcererChoiceService.metamagicLabel(optionId)} (${SorcererChoiceService.metamagicCostLabel(optionId)}): ${SorcererChoiceService.metamagicSummary(optionId)}',
                  ),
                ],
              );
            }
          }

          if (feature.name == 'Sorcerous Restoration') {
            return withExtraDescription(
              feature,
              [
                'Current recovery cap: ${SorcererChoiceService.sorcerousRestorationPoints(character.level)} Sorcery Points.',
              ],
            );
          }

          if (feature.name == 'Sorcery Incarnate') {
            return withExtraDescription(
              feature,
              [
                'If your Innate Sorcery uses are spent, you can spend 2 Sorcery Points to activate it.',
                'While Innate Sorcery is active, you can apply up to two Metamagic options to each spell you cast.',
              ],
            );
          }

          if (feature.name == 'Arcane Apotheosis') {
            return withExtraDescription(
              feature,
              [
                'While Innate Sorcery is active, one Metamagic option each turn costs no Sorcery Points.',
              ],
            );
          }
        }

        if (character.className == 'warlock') {
          if (feature.name == 'Eldritch Invocations' &&
              warlockInvocations.isNotEmpty) {
            final pieces = <String>[
              'Chosen invocations: ${warlockInvocations.map(WarlockChoiceService.invocationLabel).join(', ')}.',
              ...warlockInvocations.map(
                (invocationId) =>
                    '${WarlockChoiceService.invocationLabel(invocationId)}: ${WarlockChoiceService.invocationSummary(invocationId)}',
              ),
            ];
            if (warlockPactTomeCantrips.isNotEmpty ||
                warlockPactTomeRituals.isNotEmpty) {
              pieces.add(
                'Pact Tome cantrips: ${warlockPactTomeCantrips.map((spell) => spell.replaceAll('-', ' ')).join(', ')}.',
              );
              pieces.add(
                'Pact Tome rituals: ${warlockPactTomeRituals.map((spell) => spell.replaceAll('-', ' ')).join(', ')}.',
              );
            }
            return withExtraDescription(
              feature,
              pieces,
            );
          }

          if (feature.name == 'Pact Magic') {
            final slots = ProgressionService.getSpellLimitsFor(
              className: character.className,
              level: character.level,
              spellcastingModifier:
                  DiceCalculator.getModifier(character.charisma),
            ).spellSlots;
            final slotText = slots.entries
                .map((entry) => '${entry.value} level ${entry.key}')
                .join(', ');
            return withExtraDescription(
              feature,
              [
                'Current Pact Magic slots: ${slotText.isEmpty ? 'none' : slotText}.',
                'Pact Magic slots refresh on Short or Long Rest.',
              ],
            );
          }

          if (feature.name == 'Magical Cunning') {
            return withExtraDescription(
              feature,
              [
                'Current recovery: half your maximum Pact Magic slots, rounded up.',
                if (character.level >= 20)
                  'At Warlock level 20, Eldritch Master makes this recover all expended Pact Magic slots.',
              ],
            );
          }

          if (feature.name == 'Contact Patron') {
            return withExtraDescription(
              feature,
              [
                'Contact Other Plane is added automatically and can be cast through this feature once per Long Rest.',
              ],
            );
          }

          if (feature.name.startsWith('Mystic Arcanum')) {
            final match = RegExp(r'level (\d+) spell').firstMatch(feature.name);
            final spellLevel = int.tryParse(match?.group(1) ?? '');
            final selected =
                spellLevel == null ? null : warlockArcanumByLevel[spellLevel];
            if (selected != null) {
              return withExtraDescription(
                feature,
                [
                  'Chosen spell: ${selected.replaceAll('-', ' ')}.',
                  'This arcanum can be cast once per Long Rest without expending a Pact Magic slot.',
                ],
              );
            }
          }

          if (feature.name == 'Eldritch Master') {
            return withExtraDescription(
              feature,
              [
                'Magical Cunning now restores all expended Pact Magic spell slots.',
              ],
            );
          }
        }

        if (character.className == 'rogue' && feature.name == 'Expertise') {
          final selected =
              rogueExpertiseByLevel[entry.level] ?? const <String>[];
          if (selected.isNotEmpty) {
            return withExtraDescription(
              feature,
              [
                'Chosen skills: ${selected.map(RogueChoiceService.skillLabel).join(', ')}.',
                'These skills gain Expertise.',
              ],
            );
          }
        }

        return feature;
      }).toList();
      return ClassLevelFeatures(level: entry.level, features: features);
    }).toList();
  }
}
