part of 'character_creation_provider.dart';

extension CreationStateModelBuilder on CreationState {
  CharacterModel toCharacterModel() {
    final classAdvancements = _classAdvancementEntries(levelAdvancements);
    final adjusted = _applyClassBonuses(
      _applyLevelAdvancementBonuses(
        _applyBackgroundBonuses(),
        classAdvancements,
      ),
    );
    final conMod = DiceCalculator.getModifier(adjusted.constitution);
    final baseMaxHP = DiceCalculator.calculateMaxHP(level, hitDie, conMod);
    final maxHP = baseMaxHP + _bonusHpFromFeats(classAdvancements);
    final isRogueArcaneTrickster = RogueChoiceService.isArcaneTrickster(
      className: className,
      subclass: subclass,
      level: level,
    );
    final isFighterEldritchKnight = FighterChoiceService.isEldritchKnight(
      className: className,
      subclass: subclass,
      level: level,
    );
    final slots = isRogueArcaneTrickster
        ? RogueChoiceService.arcaneTricksterSpellSlotsListFor(level)
        : isFighterEldritchKnight
            ? FighterChoiceService.eldritchKnightSpellSlotsListFor(level)
            : spellcastingAbility.isNotEmpty &&
                    className != 'rogue' &&
                    className != 'fighter'
                ? ProgressionService.getSpellSlotsListFor(
                    className: className,
                    level: level,
                  )
                : List.filled(9, 0);
    final effectiveSpellcastingAbility =
        isRogueArcaneTrickster || isFighterEldritchKnight
            ? 'int'
            : className == 'rogue' || className == 'fighter'
                ? ''
                : spellcastingAbility;

    final currentHP = (preservedCurrentHP ?? maxHP).clamp(0, maxHP).toInt();
    final startingEquipment = StartingEquipmentService.buildSelection(
      className: className,
      classEquipmentChoiceId: classEquipmentChoiceId,
      backgroundOptions: _backgroundEquipmentOptions(),
      backgroundEquipmentChoiceId: backgroundEquipmentChoiceId,
    );
    final id = editingId ?? const Uuid().v4();
    final isHumanSpecies = _isHumanSpecies;
    final originSkillChoices = _choiceValues(originFeatChoices, 'skill:');
    final originToolChoices = _choiceValues(originFeatChoices, 'tool:');
    final speciesSkillChoices = isHumanSpecies
        ? <String>[
            if (speciesSkillChoice.isNotEmpty) speciesSkillChoice,
            ..._choiceValues(speciesOriginFeatChoices, 'skill:'),
          ]
        : const <String>[];
    final speciesFixedSkills = _baseRaceId(race) == 'disembodied'
        ? const ['arcana']
        : const <String>[];
    final speciesToolChoices = isHumanSpecies
        ? _choiceValues(speciesOriginFeatChoices, 'tool:')
        : const <String>[];
    final classSkillChoices = _skillChoicesFromAdvancements(classAdvancements);
    final classToolChoices = _toolChoicesFromAdvancements(classAdvancements);
    final artificerSkillChoices = className == 'artificer'
        ? ArtificerChoiceService.selectedSkillProficiencies(levelAdvancements)
        : const <String>[];
    final artificerArtisanTool = className == 'artificer'
        ? ArtificerChoiceService.selectedArtisanTool(levelAdvancements)
        : null;
    final artificerBaseSpells = className == 'artificer'
        ? ArtificerChoiceService.baseGrantedSpellIds(level)
        : const <String>[];
    final expertiseChoices =
        _expertiseChoicesFromAdvancements(classAdvancements);
    final rogueExpertiseChoices = className == 'rogue'
        ? RogueChoiceService.allSelectedExpertiseSkills(
            levelAdvancements,
            upToCharacterLevel: level,
          ).map(RogueChoiceService.expertiseLabel).toList()
        : const <String>[];
    final rangerExpertiseChoices = className == 'ranger'
        ? RangerChoiceService.allSelectedExpertiseSkills(
            levelAdvancements,
            upToCharacterLevel: level,
          ).map(RangerChoiceService.expertiseLabel).toList()
        : const <String>[];
    final bardExpertiseChoices = className == 'bard'
        ? BardChoiceService.allSelectedExpertiseSkills(
            levelAdvancements,
            upToCharacterLevel: level,
          ).map(BardChoiceService.expertiseLabel).toList()
        : const <String>[];
    final bardLoreBonusSkills = BardChoiceService.needsLoreBonusSkills(
      className: className,
      subclass: subclass,
      level: level,
    )
        ? BardChoiceService.selectedLoreBonusSkills(levelAdvancements)
        : const <String>[];
    final bardLoreDiscoverySpells =
        BardChoiceService.needsLoreMagicalDiscoveries(
      className: className,
      subclass: subclass,
      level: level,
    )
            ? BardChoiceService.selectedLoreDiscoverySpells(levelAdvancements)
            : const <String>[];
    final bardMoonSkill = BardChoiceService.isMoon(
      className: className,
      subclass: subclass,
      level: level,
    )
        ? BardChoiceService.selectedMoonSkill(levelAdvancements)
        : null;
    final bardMoonCantrip = BardChoiceService.isMoon(
      className: className,
      subclass: subclass,
      level: level,
    )
        ? BardChoiceService.selectedMoonCantrip(levelAdvancements)
        : null;
    final druidPrimalOrder = className == 'druid' && level >= 1
        ? DruidChoiceService.selectedPrimalOrder(levelAdvancements)
        : null;
    final druidElementalFury = className == 'druid' && level >= 7
        ? DruidChoiceService.selectedElementalFury(levelAdvancements)
        : null;
    final druidMagicianCantrip = className == 'druid' &&
            level >= 1 &&
            druidPrimalOrder == DruidChoiceService.magicianOrder
        ? DruidChoiceService.selectedMagicianCantrip(levelAdvancements)
        : null;
    final druidLandType = DruidChoiceService.isLand(
      className: className,
      subclass: subclass,
      level: level,
    )
        ? DruidChoiceService.selectedLandType(levelAdvancements)
        : null;
    final druidLandSpells = DruidChoiceService.landSpellIds(
      className: className,
      subclass: subclass,
      level: level,
      entries: levelAdvancements,
    );
    final druidLandResistance = DruidChoiceService.landResistance(
      level: level,
      entries: levelAdvancements,
    );
    final druidProficiencies = className == 'druid'
        ? DruidChoiceService.proficiencyLabels(
            primalOrder: druidPrimalOrder,
            elementalFury: druidElementalFury,
          )
        : const <String>[];
    final druidLanguages =
        className == 'druid' ? const ['Druidic'] : const <String>[];
    final bardMoonLanguages = BardChoiceService.isMoon(
      className: className,
      subclass: subclass,
      level: level,
    )
        ? const ['Druidic']
        : const <String>[];
    final sorcererMetamagicOptions = className == 'sorcerer'
        ? SorcererChoiceService.allSelectedMetamagicOptions(
            levelAdvancements,
            upToCharacterLevel: level,
          )
        : const <String>[];
    final warlockInvocations = className == 'warlock'
        ? WarlockChoiceService.selectedInvocations(levelAdvancements)
        : const <String>[];
    final warlockBaseSpells = className == 'warlock'
        ? WarlockChoiceService.baseGrantedSpellIds(
            level: level,
            entries: levelAdvancements,
          )
        : const <String>[];
    final warlockPactTomeSpells = className == 'warlock'
        ? WarlockChoiceService.pactTomeSpellIds(levelAdvancements)
        : const <String>[];
    final warlockMysticArcanumSpells = className == 'warlock'
        ? WarlockChoiceService.selectedMysticArcanumSpells(levelAdvancements)
        : const <String>[];
    final rangerLanguages = className == 'ranger'
        ? RangerChoiceService.selectedLanguages(levelAdvancements)
        : const <String>[];
    final rangerFightingStyle = className == 'ranger'
        ? RangerChoiceService.selectedFightingStyle(levelAdvancements)
        : null;
    final rangerWeaponMasteries = className == 'ranger'
        ? RangerChoiceService.selectedWeaponMasteries(levelAdvancements)
        : const <String>[];
    final rangerDruidicCantrips = className == 'ranger' &&
            rangerFightingStyle == 'Druidic Warrior'
        ? RangerChoiceService.selectedDruidicWarriorCantrips(levelAdvancements)
        : const <String>[];
    final barbarianWeaponMasteries = className == 'barbarian'
        ? BarbarianChoiceService.selectedWeaponMasteries(
            levelAdvancements,
            characterLevel: level,
          )
        : const <String>[];
    final barbarianPrimalKnowledgeSkill = className == 'barbarian' && level >= 3
        ? BarbarianChoiceService.selectedPrimalKnowledgeSkill(levelAdvancements)
        : null;
    final fighterWeaponMasteries = className == 'fighter'
        ? FighterChoiceService.selectedWeaponMasteries(
            levelAdvancements,
            characterLevel: level,
          )
        : const <String>[];
    final fighterEldritchKnightSpells =
        FighterChoiceService.eldritchKnightSpellIds(
      className: className,
      subclass: subclass,
      level: level,
      entries: levelAdvancements,
    );
    final fighterPsiWarriorSpells =
        FighterChoiceService.psiWarriorGrantedSpellIds(
      className: className,
      subclass: subclass,
      level: level,
    );
    final fighterBattleMasterManeuvers = FighterChoiceService.isBattleMaster(
      className: className,
      subclass: subclass,
      level: level,
    )
        ? FighterChoiceService.selectedBattleMasterManeuvers(
            levelAdvancements,
            characterLevel: level,
          )
        : const <String>[];
    final fighterBattleMasterStudentSkill = FighterChoiceService.isBattleMaster(
      className: className,
      subclass: subclass,
      level: level,
    )
        ? FighterChoiceService.selectedBattleMasterStudentSkill(
            levelAdvancements,
          )
        : null;
    final fighterBattleMasterStudentTool = FighterChoiceService.isBattleMaster(
      className: className,
      subclass: subclass,
      level: level,
    )
        ? FighterChoiceService.selectedBattleMasterStudentTool(
            levelAdvancements,
          )
        : null;
    final paladinFightingStyle = className == 'paladin'
        ? PaladinChoiceService.selectedFightingStyle(levelAdvancements)
        : null;
    final paladinWeaponMasteries = className == 'paladin'
        ? PaladinChoiceService.selectedWeaponMasteries(levelAdvancements)
        : const <String>[];
    final paladinBlessedCantrips =
        className == 'paladin' && paladinFightingStyle == 'Blessed Warrior'
            ? PaladinChoiceService.selectedBlessedWarriorCantrips(
                levelAdvancements,
              )
            : const <String>[];
    final scholarSkill =
        WizardChoiceService.selectedScholarSkill(levelAdvancements);
    final scholarExpertise = scholarSkill == null
        ? null
        : WizardChoiceService.scholarExpertiseLabel(scholarSkill);
    final wizardSavantSpells =
        WizardChoiceService.selectedSavantSpells(levelAdvancements);
    final illusionistCantrip =
        className == 'wizard' && subclass == 'wizard-illusionist' && level >= 3
            ? WizardChoiceService.illusionistGrantedCantrip(levelAdvancements)
            : null;
    final clericKnowledgeSkills = ClericChoiceService.needsKnowledgeChoices(
      className: className,
      subclass: subclass,
      level: level,
    )
        ? ClericChoiceService.selectedKnowledgeSkills(levelAdvancements)
        : const <String>[];
    final clericKnowledgeTool = ClericChoiceService.needsKnowledgeChoices(
      className: className,
      subclass: subclass,
      level: level,
    )
        ? ClericChoiceService.selectedKnowledgeTool(levelAdvancements)
        : null;
    final rogueArcaneTricksterSpells =
        RogueChoiceService.arcaneTricksterSpellIds(
      className: className,
      subclass: subclass,
      level: level,
      entries: levelAdvancements,
    );
    final rogueScionAllegiance = RogueChoiceService.needsScionDreadAllegiance(
      className: className,
      subclass: subclass,
      level: level,
    )
        ? RogueChoiceService.selectedScionDreadAllegiance(
            levelAdvancements,
          )
        : null;
    final rogueScionCantrip = rogueScionAllegiance == null
        ? null
        : RogueChoiceService.scionDreadAllegianceCantrip(levelAdvancements);
    final rogueSubclassProficiencies = <String>[
      if (className == 'rogue' &&
          subclass == RogueChoiceService.assassinSubclass &&
          level >= 3) ...const [
        'Disguise Kit',
        "Poisoner's Kit",
      ],
      if (rogueScionAllegiance != null)
        RogueChoiceService.scionDreadAllegianceProficiencyLabel(
          rogueScionAllegiance,
        ),
    ];
    final monkSubclassSkills = MonkChoiceService.subclassSkillProficiencies(
      className: className,
      subclass: subclass,
      level: level,
    );
    final monkSubclassProficiencies =
        MonkChoiceService.subclassProficiencyLabels(
      className: className,
      subclass: subclass,
      level: level,
    );

    final allSkillProfs = {
      ...proficientSkills,
      ...backgroundSkillProfs,
      ...originSkillChoices,
      ...speciesFixedSkills,
      ...speciesSkillChoices,
      ...classSkillChoices,
      ...artificerSkillChoices,
      ...bardLoreBonusSkills,
      if (bardMoonSkill != null) bardMoonSkill,
      if (barbarianPrimalKnowledgeSkill != null) barbarianPrimalKnowledgeSkill,
      ...clericKnowledgeSkills,
      if (fighterBattleMasterStudentSkill != null)
        fighterBattleMasterStudentSkill,
      ...monkSubclassSkills,
    }.toList();

    final mergedSpells = {
      ...selectedSpells,
      ...originFeatCantrips,
      if (originFeatSpell.isNotEmpty) originFeatSpell,
      if (isHumanSpecies) ...speciesOriginFeatCantrips,
      if (isHumanSpecies && speciesOriginFeatSpell.isNotEmpty)
        speciesOriginFeatSpell,
      ..._spellChoicesFromAdvancements(classAdvancements),
      ...wizardSavantSpells,
      ...artificerBaseSpells,
      if (className == 'ranger' && level >= 1) 'hunters-mark',
      ...rangerDruidicCantrips,
      ...BardChoiceService.baseGrantedSpellIds(
        className == 'bard' ? level : 0,
      ),
      ...bardLoreDiscoverySpells,
      if (bardMoonCantrip != null && bardMoonCantrip.isNotEmpty)
        bardMoonCantrip,
      ...DruidChoiceService.baseGrantedSpellIds(
        className == 'druid' ? level : 0,
      ),
      ...druidLandSpells,
      ...warlockBaseSpells,
      ...warlockPactTomeSpells,
      ...warlockMysticArcanumSpells,
      ...rogueArcaneTricksterSpells,
      ...fighterEldritchKnightSpells,
      ...fighterPsiWarriorSpells,
      if (rogueScionCantrip != null && rogueScionCantrip.isNotEmpty)
        rogueScionCantrip,
      if (druidMagicianCantrip != null && druidMagicianCantrip.isNotEmpty)
        druidMagicianCantrip,
      ...PaladinChoiceService.baseGrantedSpellIds(
        className == 'paladin' ? level : 0,
      ),
      ...paladinBlessedCantrips,
      if (illusionistCantrip != null && illusionistCantrip.isNotEmpty)
        illusionistCantrip,
      if (speciesGrantedCantrip.isNotEmpty) speciesGrantedCantrip,
      if (clericThaumaturgeCantrip.isNotEmpty) clericThaumaturgeCantrip,
      ...MonkChoiceService.subclassSpellIds(
        className: className,
        subclass: subclass,
        level: level,
      ),
      ...buildGrantedSpellEntries(
        className: className,
        subclass: subclass,
        raceValue: race,
        level: level,
      ).map((entry) => entry.spellIndex),
    }.toList();

    final mergedProficiencies = {
      ...proficiencies,
      ...backgroundToolProficiencies,
      ...originToolChoices,
      ...speciesToolChoices,
      ...classToolChoices,
      if (artificerArtisanTool != null) artificerArtisanTool,
      ...expertiseChoices,
      ...rogueExpertiseChoices,
      ...rangerExpertiseChoices,
      ...bardExpertiseChoices,
      if (bardLoreBonusSkills.isNotEmpty)
        BardChoiceService.loreBonusSkillsLabel(bardLoreBonusSkills),
      if (bardMoonSkill != null)
        BardChoiceService.moonSkillLabel(bardMoonSkill),
      if (bardMoonCantrip != null)
        BardChoiceService.moonCantripLabel(bardMoonCantrip),
      if (BardChoiceService.isValor(
        className: className,
        subclass: subclass,
        level: level,
      ))
        ...BardChoiceService.valorProficiencyLabels(),
      ...druidProficiencies,
      if (druidLandType != null)
        DruidChoiceService.landChoiceLabel(druidLandType),
      if (druidLandResistance != null)
        'Nature\'s Ward: $druidLandResistance resistance',
      if (sorcererMetamagicOptions.isNotEmpty)
        SorcererChoiceService.metamagicChoiceLabel(sorcererMetamagicOptions),
      if (warlockInvocations.isNotEmpty)
        WarlockChoiceService.invocationChoiceLabel(warlockInvocations),
      if (rangerFightingStyle != null)
        RangerChoiceService.fightingStyleLabel(rangerFightingStyle),
      if (rangerWeaponMasteries.isNotEmpty)
        RangerChoiceService.weaponMasteryLabel(rangerWeaponMasteries),
      if (barbarianWeaponMasteries.isNotEmpty)
        BarbarianChoiceService.weaponMasteryLabel(barbarianWeaponMasteries),
      if (barbarianPrimalKnowledgeSkill != null)
        BarbarianChoiceService.primalKnowledgeSkillLabel(
          barbarianPrimalKnowledgeSkill,
        ),
      if (fighterWeaponMasteries.isNotEmpty)
        FighterChoiceService.weaponMasteryLabel(fighterWeaponMasteries),
      if (fighterBattleMasterManeuvers.isNotEmpty)
        FighterChoiceService.battleMasterManeuverChoiceLabel(
          fighterBattleMasterManeuvers,
        ),
      if (fighterBattleMasterStudentTool != null)
        fighterBattleMasterStudentTool,
      if (paladinFightingStyle != null)
        PaladinChoiceService.fightingStyleLabel(paladinFightingStyle),
      if (paladinWeaponMasteries.isNotEmpty)
        PaladinChoiceService.weaponMasteryLabel(paladinWeaponMasteries),
      ...rogueSubclassProficiencies,
      ...monkSubclassProficiencies,
      ...ClericChoiceService.knowledgeExpertiseLabels(levelAdvancements),
      if (clericKnowledgeTool != null) clericKnowledgeTool,
      if (scholarExpertise != null) scholarExpertise,
      if (clericDivineOrder == 'protector') ...const [
        'Martial weapons',
        'Heavy armor'
      ],
    }.toList();

    final originAdvancements = _buildOriginAdvancements();
    final choiceAdvancements = _buildChoiceAdvancements();
    final allAdvancements = [
      ...classAdvancements,
      ...originAdvancements,
      ...choiceAdvancements,
    ];

    final effectiveEquipment = originalCharacter == null
        ? startingEquipment.items
        : List<String>.from(originalCharacter?.equipment ?? const <String>[]);
    final armorClass = _calculateArmorClass(adjusted, effectiveEquipment);
    final effectiveSpeed = _calculateSpeed();
    final initiative = DiceCalculator.getModifier(adjusted.dexterity);

    final combatPreview = CharacterModel(
      id: editingId ?? 'preview',
      name: name,
      className: className,
      classDisplayName: classDisplayName,
      level: level,
      strength: adjusted.strength,
      dexterity: adjusted.dexterity,
      constitution: adjusted.constitution,
      intelligence: adjusted.intelligence,
      wisdom: adjusted.wisdom,
      charisma: adjusted.charisma,
      proficiencies: mergedProficiencies,
      equipment: effectiveEquipment,
      exhaustionLevel: originalCharacter?.exhaustionLevel ?? 0,
    );
    final classSyncedAttacks = _syncClassAttacks(
      existingAttacks: originalCharacter?.attacks ?? const <AttackModel>[],
      previewCharacter: combatPreview,
    );
    final syncedAttacks = EquipmentMechanicsService.mergeEquipmentAttacks(
      existingAttacks: classSyncedAttacks,
      equipmentAttacks: EquipmentMechanicsService.weaponAttacksFromEquipment(
        equipment: effectiveEquipment,
        character: combatPreview,
      ),
    );

    final base = originalCharacter;
    if (base != null) {
      return base.copyWith(
        id: id,
        name: name,
        race: race,
        raceName: raceName,
        className: className,
        classDisplayName: classDisplayName,
        subclass: subclass,
        subclassName: subclassName,
        background: background,
        backgroundName: backgroundName,
        alignment: alignment,
        level: level,
        strength: adjusted.strength,
        dexterity: adjusted.dexterity,
        constitution: adjusted.constitution,
        intelligence: adjusted.intelligence,
        wisdom: adjusted.wisdom,
        charisma: adjusted.charisma,
        maxHP: maxHP,
        currentHP: currentHP,
        armorClass: armorClass,
        speed: effectiveSpeed,
        hitDie: hitDie,
        initiative: initiative,
        proficientSkills: allSkillProfs,
        backgroundSkillProfs: List<String>.from(backgroundSkillProfs),
        savingThrowProfs: List<String>.from(savingThrowProfs),
        selectedSpells: mergedSpells,
        spellSlotsMax: slots,
        spellSlotsUsed: _normalizedSlotUsage(base.spellSlotsUsed, slots),
        spellcastingAbility: effectiveSpellcastingAbility,
        languages: {
          ...languages,
          ...rangerLanguages,
          ...druidLanguages,
          ...bardMoonLanguages
        }.toList(),
        proficiencies: mergedProficiencies,
        attacks: syncedAttacks,
        levelAdvancements: allAdvancements,
        personalityTraits: personalityTraits,
        ideals: ideals,
        bonds: bonds,
        flaws: flaws,
        backstory: backstory,
      );
    }

    return CharacterModel(
      id: id,
      name: name,
      race: race,
      raceName: raceName,
      className: className,
      classDisplayName: classDisplayName,
      subclass: subclass,
      subclassName: subclassName,
      background: background,
      backgroundName: backgroundName,
      alignment: alignment,
      level: level,
      strength: adjusted.strength,
      dexterity: adjusted.dexterity,
      constitution: adjusted.constitution,
      intelligence: adjusted.intelligence,
      wisdom: adjusted.wisdom,
      charisma: adjusted.charisma,
      maxHP: maxHP,
      currentHP: currentHP,
      armorClass: armorClass,
      speed: effectiveSpeed,
      hitDie: hitDie,
      initiative: initiative,
      proficientSkills: allSkillProfs,
      backgroundSkillProfs: List<String>.from(backgroundSkillProfs),
      savingThrowProfs: List<String>.from(savingThrowProfs),
      selectedSpells: mergedSpells,
      spellSlotsMax: slots,
      spellSlotsUsed: List.filled(9, 0),
      spellcastingAbility: effectiveSpellcastingAbility,
      languages: {
        ...languages,
        ...rangerLanguages,
        ...druidLanguages,
        ...bardMoonLanguages
      }.toList(),
      proficiencies: mergedProficiencies,
      attacks: syncedAttacks,
      equipment: startingEquipment.items,
      gold: startingEquipment.gold,
      levelAdvancements: allAdvancements,
      personalityTraits: personalityTraits,
      ideals: ideals,
      bonds: bonds,
      flaws: flaws,
      backstory: backstory,
    );
  }
}
