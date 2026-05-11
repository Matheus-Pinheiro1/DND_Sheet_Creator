part of 'character_creation_provider.dart';

extension CreationNotifierCharacterLoaders on CreationNotifier {
  int _baseSpeedForLoadedCharacter(CharacterModel character) {
    final className = character.className.trim().toLowerCase();
    var speedBonus = 0;
    if (MonkChoiceService.isMonk(className: className)) {
      speedBonus = MonkChoiceService.unarmoredMovementBonus(character.level);
    } else if (className == 'ranger') {
      speedBonus = ProgressionService.getRangerRovingSpeedBonus(
        character.level,
      );
    } else if (className == 'barbarian') {
      speedBonus = ProgressionService.getBarbarianFastMovementBonus(
        character.level,
      );
    }

    if (speedBonus == 0) {
      return character.speed;
    }

    final baseSpeed = character.speed - speedBonus;
    return baseSpeed < 0 ? 0 : baseSpeed;
  }

  void loadFromCharacter(CharacterModel c) {
    final parsed = _parseOriginChoices(c.levelAdvancements);
    final originSpellIds = <String>{
      ...parsed.originCantrips,
      if (parsed.originSpell.isNotEmpty) parsed.originSpell,
      ...parsed.speciesOriginFeatCantrips,
      if (parsed.speciesOriginFeatSpell.isNotEmpty)
        parsed.speciesOriginFeatSpell,
    };
    final originSkillChoiceIds = <String>{
      ...parsed.originFeatChoices
          .where((choice) => choice.startsWith('skill:'))
          .map((choice) => choice.replaceFirst('skill:', '')),
      if (parsed.speciesSkillChoice.isNotEmpty) parsed.speciesSkillChoice,
      ...parsed.speciesOriginFeatChoices
          .where((choice) => choice.startsWith('skill:'))
          .map((choice) => choice.replaceFirst('skill:', '')),
    };
    final specialChoiceSpellIds = <String>{
      if (parsed.speciesGrantedCantrip.isNotEmpty) parsed.speciesGrantedCantrip,
      if (parsed.clericThaumaturgeCantrip.isNotEmpty)
        parsed.clericThaumaturgeCantrip,
      ...WizardChoiceService.selectedSavantSpells(c.levelAdvancements),
      ...BardChoiceService.selectedLoreDiscoverySpells(c.levelAdvancements),
      if (BardChoiceService.selectedMoonCantrip(c.levelAdvancements) != null)
        BardChoiceService.selectedMoonCantrip(c.levelAdvancements)!,
    };
    if (c.className == 'wizard' &&
        c.subclass == 'wizard-illusionist' &&
        c.level >= 3) {
      specialChoiceSpellIds.add(
        WizardChoiceService.illusionistGrantedCantrip(c.levelAdvancements),
      );
    }
    final grantedSpellIds = buildGrantedSpellEntries(
      className: c.className,
      subclass: c.subclass,
      raceValue: c.race,
      level: c.level,
    ).map((entry) => entry.spellIndex).toSet();
    final savedArtificerBaseSpells = c.className == 'artificer'
        ? ArtificerChoiceService.baseGrantedSpellIds(c.level).toSet()
        : <String>{};
    final savedArtificerSkills = c.className == 'artificer'
        ? ArtificerChoiceService.selectedSkillProficiencies(
            c.levelAdvancements,
          )
        : const <String>[];
    final savedArtificerTool = c.className == 'artificer'
        ? ArtificerChoiceService.selectedArtisanTool(c.levelAdvancements)
        : null;
    final savedArtificerProficiencyLabels = <String>{
      if (savedArtificerTool != null) savedArtificerTool,
    };
    final savedRangerLanguages = c.className == 'ranger'
        ? RangerChoiceService.selectedLanguages(c.levelAdvancements).toSet()
        : <String>{};
    final savedRangerBaseSpells =
        c.className == 'ranger' ? const {'hunters-mark'} : <String>{};
    final savedRangerCantrips = c.className == 'ranger' &&
            RangerChoiceService.selectedFightingStyle(c.levelAdvancements) ==
                'Druidic Warrior'
        ? RangerChoiceService.selectedDruidicWarriorCantrips(
            c.levelAdvancements,
          ).toSet()
        : <String>{};
    final savedRangerFightingStyle = c.className == 'ranger'
        ? RangerChoiceService.selectedFightingStyle(c.levelAdvancements)
        : null;
    final savedRangerWeaponMasteries = c.className == 'ranger'
        ? RangerChoiceService.selectedWeaponMasteries(c.levelAdvancements)
        : const <String>[];
    final savedRangerProficiencyLabels = <String>{
      if (c.className == 'ranger')
        ...RangerChoiceService.allSelectedExpertiseSkills(
          c.levelAdvancements,
          upToCharacterLevel: c.level,
        ).map(RangerChoiceService.expertiseLabel),
      if (savedRangerFightingStyle != null)
        RangerChoiceService.fightingStyleLabel(savedRangerFightingStyle),
      if (savedRangerWeaponMasteries.isNotEmpty)
        RangerChoiceService.weaponMasteryLabel(savedRangerWeaponMasteries),
    };
    final savedBarbarianWeaponMasteries = c.className == 'barbarian'
        ? BarbarianChoiceService.selectedWeaponMasteries(
            c.levelAdvancements,
            characterLevel: c.level,
          )
        : const <String>[];
    final savedBarbarianPrimalKnowledgeSkill = c.className == 'barbarian'
        ? BarbarianChoiceService.selectedPrimalKnowledgeSkill(
            c.levelAdvancements,
          )
        : null;
    final savedBarbarianProficiencyLabels = <String>{
      if (savedBarbarianWeaponMasteries.isNotEmpty)
        BarbarianChoiceService.weaponMasteryLabel(
          savedBarbarianWeaponMasteries,
        ),
      if (savedBarbarianPrimalKnowledgeSkill != null)
        BarbarianChoiceService.primalKnowledgeSkillLabel(
          savedBarbarianPrimalKnowledgeSkill,
        ),
    };
    final savedFighterWeaponMasteries = c.className == 'fighter'
        ? FighterChoiceService.selectedWeaponMasteries(
            c.levelAdvancements,
            characterLevel: c.level,
          )
        : const <String>[];
    final savedFighterEldritchKnightSpells =
        FighterChoiceService.eldritchKnightSpellIds(
      className: c.className,
      subclass: c.subclass,
      level: c.level,
      entries: c.levelAdvancements,
    ).toSet();
    final savedFighterPsiWarriorSpells =
        FighterChoiceService.psiWarriorGrantedSpellIds(
      className: c.className,
      subclass: c.subclass,
      level: c.level,
    ).toSet();
    final savedFighterBattleMasterManeuvers =
        FighterChoiceService.isBattleMaster(
      className: c.className,
      subclass: c.subclass,
      level: c.level,
    )
            ? FighterChoiceService.selectedBattleMasterManeuvers(
                c.levelAdvancements,
                characterLevel: c.level,
              )
            : const <String>[];
    final savedFighterBattleMasterStudentSkill =
        FighterChoiceService.isBattleMaster(
      className: c.className,
      subclass: c.subclass,
      level: c.level,
    )
            ? FighterChoiceService.selectedBattleMasterStudentSkill(
                c.levelAdvancements,
              )
            : null;
    final savedFighterBattleMasterStudentTool =
        FighterChoiceService.isBattleMaster(
      className: c.className,
      subclass: c.subclass,
      level: c.level,
    )
            ? FighterChoiceService.selectedBattleMasterStudentTool(
                c.levelAdvancements,
              )
            : null;
    final savedFighterProficiencyLabels = <String>{
      if (savedFighterWeaponMasteries.isNotEmpty)
        FighterChoiceService.weaponMasteryLabel(savedFighterWeaponMasteries),
      if (savedFighterBattleMasterManeuvers.isNotEmpty)
        FighterChoiceService.battleMasterManeuverChoiceLabel(
          savedFighterBattleMasterManeuvers,
        ),
      if (savedFighterBattleMasterStudentTool != null)
        savedFighterBattleMasterStudentTool,
    };
    final savedPaladinBaseSpells = c.className == 'paladin'
        ? PaladinChoiceService.baseGrantedSpellIds(c.level).toSet()
        : <String>{};
    final savedPaladinFightingStyle = c.className == 'paladin'
        ? PaladinChoiceService.selectedFightingStyle(c.levelAdvancements)
        : null;
    final savedPaladinWeaponMasteries = c.className == 'paladin'
        ? PaladinChoiceService.selectedWeaponMasteries(c.levelAdvancements)
        : const <String>[];
    final savedPaladinCantrips = c.className == 'paladin' &&
            savedPaladinFightingStyle == 'Blessed Warrior'
        ? PaladinChoiceService.selectedBlessedWarriorCantrips(
            c.levelAdvancements,
          ).toSet()
        : <String>{};
    final savedPaladinProficiencyLabels = <String>{
      if (savedPaladinFightingStyle != null)
        PaladinChoiceService.fightingStyleLabel(savedPaladinFightingStyle),
      if (savedPaladinWeaponMasteries.isNotEmpty)
        PaladinChoiceService.weaponMasteryLabel(savedPaladinWeaponMasteries),
    };
    final savedBardBaseSpells = c.className == 'bard'
        ? BardChoiceService.baseGrantedSpellIds(c.level).toSet()
        : <String>{};
    final savedBardMoonSkill = BardChoiceService.isMoon(
      className: c.className,
      subclass: c.subclass,
      level: c.level,
    )
        ? BardChoiceService.selectedMoonSkill(c.levelAdvancements)
        : null;
    final savedBardMoonCantrip = BardChoiceService.isMoon(
      className: c.className,
      subclass: c.subclass,
      level: c.level,
    )
        ? BardChoiceService.selectedMoonCantrip(c.levelAdvancements)
        : null;
    final savedBardMoonLanguages = BardChoiceService.isMoon(
      className: c.className,
      subclass: c.subclass,
      level: c.level,
    )
        ? const {'Druidic'}
        : <String>{};
    final savedBardProficiencyLabels = <String>{
      if (c.className == 'bard')
        ...BardChoiceService.allSelectedExpertiseSkills(
          c.levelAdvancements,
          upToCharacterLevel: c.level,
        ).map(BardChoiceService.expertiseLabel),
      if (BardChoiceService.selectedLoreBonusSkills(c.levelAdvancements)
          .isNotEmpty)
        BardChoiceService.loreBonusSkillsLabel(
          BardChoiceService.selectedLoreBonusSkills(c.levelAdvancements),
        ),
      if (savedBardMoonSkill != null)
        BardChoiceService.moonSkillLabel(savedBardMoonSkill),
      if (savedBardMoonCantrip != null)
        BardChoiceService.moonCantripLabel(savedBardMoonCantrip),
      if (BardChoiceService.isValor(
        className: c.className,
        subclass: c.subclass,
        level: c.level,
      ))
        ...BardChoiceService.valorProficiencyLabels(),
    };
    final savedBardLoreSkills =
        BardChoiceService.selectedLoreBonusSkills(c.levelAdvancements);
    final savedBardLoreSpells =
        BardChoiceService.selectedLoreDiscoverySpells(c.levelAdvancements)
            .toSet();
    final savedDruidBaseSpells = c.className == 'druid'
        ? DruidChoiceService.baseGrantedSpellIds(c.level).toSet()
        : <String>{};
    final savedDruidPrimalOrder = c.className == 'druid' && c.level >= 1
        ? DruidChoiceService.selectedPrimalOrder(c.levelAdvancements)
        : null;
    final savedDruidElementalFury = c.className == 'druid' && c.level >= 7
        ? DruidChoiceService.selectedElementalFury(c.levelAdvancements)
        : null;
    final savedDruidMagicianCantrip = c.className == 'druid' && c.level >= 1
        ? DruidChoiceService.selectedMagicianCantrip(c.levelAdvancements)
        : null;
    final savedDruidCantrips = c.className == 'druid' &&
            savedDruidPrimalOrder == DruidChoiceService.magicianOrder
        ? {
            if (savedDruidMagicianCantrip != null) savedDruidMagicianCantrip,
          }
        : <String>{};
    final savedDruidLandType = DruidChoiceService.isLand(
      className: c.className,
      subclass: c.subclass,
      level: c.level,
    )
        ? DruidChoiceService.selectedLandType(c.levelAdvancements)
        : null;
    final savedDruidLandSpells = DruidChoiceService.landSpellIds(
      className: c.className,
      subclass: c.subclass,
      level: c.level,
      entries: c.levelAdvancements,
    ).toSet();
    final savedDruidLandResistance = DruidChoiceService.landResistance(
      level: c.level,
      entries: c.levelAdvancements,
    );
    final savedDruidLanguages =
        c.className == 'druid' ? const {'Druidic'} : <String>{};
    final savedDruidProficiencyLabels = <String>{
      if (c.className == 'druid')
        ...DruidChoiceService.proficiencyLabels(
          primalOrder: savedDruidPrimalOrder,
          elementalFury: savedDruidElementalFury,
        ),
      if (savedDruidLandType != null)
        DruidChoiceService.landChoiceLabel(savedDruidLandType),
      if (savedDruidLandResistance != null)
        'Nature\'s Ward: $savedDruidLandResistance resistance',
    };
    final savedMonkSubclassSkills =
        MonkChoiceService.subclassSkillProficiencies(
      className: c.className,
      subclass: c.subclass,
      level: c.level,
    );
    final savedMonkSubclassSpells = MonkChoiceService.subclassSpellIds(
      className: c.className,
      subclass: c.subclass,
      level: c.level,
    ).toSet();
    final savedMonkProficiencyLabels =
        MonkChoiceService.subclassProficiencyLabels(
      className: c.className,
      subclass: c.subclass,
      level: c.level,
    );
    final savedSorcererMetamagicOptions = c.className == 'sorcerer'
        ? SorcererChoiceService.allSelectedMetamagicOptions(
            c.levelAdvancements,
            upToCharacterLevel: c.level,
          )
        : const <String>[];
    final savedSorcererProficiencyLabels = <String>{
      if (savedSorcererMetamagicOptions.isNotEmpty)
        SorcererChoiceService.metamagicChoiceLabel(
          savedSorcererMetamagicOptions,
        ),
    };
    final savedWarlockInvocations = c.className == 'warlock'
        ? WarlockChoiceService.selectedInvocations(c.levelAdvancements)
        : const <String>[];
    final savedWarlockBaseSpells = c.className == 'warlock'
        ? WarlockChoiceService.baseGrantedSpellIds(
            level: c.level,
            entries: c.levelAdvancements,
          ).toSet()
        : <String>{};
    final savedWarlockPactTomeSpells = c.className == 'warlock'
        ? WarlockChoiceService.pactTomeSpellIds(c.levelAdvancements).toSet()
        : <String>{};
    final savedWarlockMysticArcanumSpells = c.className == 'warlock'
        ? WarlockChoiceService.selectedMysticArcanumSpells(c.levelAdvancements)
            .toSet()
        : <String>{};
    final savedWarlockProficiencyLabels = <String>{
      if (savedWarlockInvocations.isNotEmpty)
        WarlockChoiceService.invocationChoiceLabel(savedWarlockInvocations),
    };
    final savedClericKnowledgeSkills =
        ClericChoiceService.needsKnowledgeChoices(
      className: c.className,
      subclass: c.subclass,
      level: c.level,
    )
            ? ClericChoiceService.selectedKnowledgeSkills(c.levelAdvancements)
            : const <String>[];
    final savedClericKnowledgeTool = ClericChoiceService.needsKnowledgeChoices(
      className: c.className,
      subclass: c.subclass,
      level: c.level,
    )
        ? ClericChoiceService.selectedKnowledgeTool(c.levelAdvancements)
        : null;
    final savedClericProficiencyLabels = <String>{
      ...ClericChoiceService.knowledgeExpertiseLabels(c.levelAdvancements),
      if (savedClericKnowledgeTool != null) savedClericKnowledgeTool,
    };
    final savedRogueArcaneTricksterSpells =
        RogueChoiceService.arcaneTricksterSpellIds(
      className: c.className,
      subclass: c.subclass,
      level: c.level,
      entries: c.levelAdvancements,
    ).toSet();
    final savedRogueScionAllegiance =
        RogueChoiceService.needsScionDreadAllegiance(
      className: c.className,
      subclass: c.subclass,
      level: c.level,
    )
            ? RogueChoiceService.selectedScionDreadAllegiance(
                c.levelAdvancements,
              )
            : null;
    final savedRogueScionCantrip = savedRogueScionAllegiance == null
        ? null
        : RogueChoiceService.scionDreadAllegianceCantrip(
            c.levelAdvancements,
          );
    final savedRogueProficiencyLabels = <String>{
      if (c.className == 'rogue')
        ...RogueChoiceService.allSelectedExpertiseSkills(
          c.levelAdvancements,
          upToCharacterLevel: c.level,
        ).map(RogueChoiceService.expertiseLabel),
      if (c.className == 'rogue' &&
          c.subclass == RogueChoiceService.assassinSubclass &&
          c.level >= 3) ...const [
        'Disguise Kit',
        "Poisoner's Kit",
      ],
      if (savedRogueScionAllegiance != null)
        RogueChoiceService.scionDreadAllegianceProficiencyLabel(
          savedRogueScionAllegiance,
        ),
    };
    final savedClassProficiencyLabels = {
      ...savedArtificerProficiencyLabels,
      ...savedRangerProficiencyLabels,
      ...savedBarbarianProficiencyLabels,
      ...savedFighterProficiencyLabels,
      ...savedPaladinProficiencyLabels,
      ...savedBardProficiencyLabels,
      ...savedDruidProficiencyLabels,
      ...savedMonkProficiencyLabels,
      ...savedSorcererProficiencyLabels,
      ...savedWarlockProficiencyLabels,
      ...savedClericProficiencyLabels,
      ...savedRogueProficiencyLabels,
    };

    final baseAbilities = _removeSavedAbilityBonuses(
      strength: c.strength,
      dexterity: c.dexterity,
      constitution: c.constitution,
      intelligence: c.intelligence,
      wisdom: c.wisdom,
      charisma: c.charisma,
      backgroundBonusChoices: parsed.backgroundBonusChoices,
      levelAdvancements: c.levelAdvancements,
      className: c.className,
      level: c.level,
    );

    _notifierState = CreationState(
      editingId: c.id,
      originalCharacter: c,
      preservedCurrentHP: c.currentHP,
      name: c.name,
      alignment: c.alignment,
      level: c.level,
      race: c.race,
      raceName: c.raceName,
      speed: _baseSpeedForLoadedCharacter(c),
      languages: c.languages
          .where((language) =>
              !savedRangerLanguages.contains(language) &&
              !savedBardMoonLanguages.contains(language) &&
              !savedDruidLanguages.contains(language))
          .toList(),
      className: c.className,
      classDisplayName: c.classDisplayName,
      subclass: c.subclass,
      subclassName: c.subclassName,
      hitDie: c.hitDie,
      spellcastingAbility: c.className == 'rogue' &&
                  c.subclass != RogueChoiceService.arcaneTricksterSubclass ||
              c.className == 'fighter' &&
                  c.subclass != FighterChoiceService.eldritchKnightSubclass
          ? ''
          : c.spellcastingAbility,
      savingThrowProfs: List<String>.from(c.savingThrowProfs),
      proficiencies: c.proficiencies
          .where((prof) => !savedClassProficiencyLabels.contains(prof))
          .toList(),
      background: c.background,
      backgroundName: c.backgroundName,
      classEquipmentChoiceId: StartingEquipmentService.selectedClassEquipmentId(
          c.levelAdvancements),
      backgroundEquipmentChoiceId:
          StartingEquipmentService.selectedBackgroundEquipmentId(
        c.levelAdvancements,
      ),
      backgroundAbilityOptions:
          List<String>.from(parsed.backgroundBonusChoices),
      backgroundFeatId: parsed.backgroundFeatId,
      backgroundFeatName: parsed.backgroundFeatName,
      backgroundBonusMode:
          parsed.backgroundBonusChoices.length == 3 ? 'plus1all' : 'plus2plus1',
      backgroundBonusChoices: List<String>.from(parsed.backgroundBonusChoices),
      backgroundSkillProfs: List<String>.from(c.backgroundSkillProfs),
      proficientSkills: c.proficientSkills
          .where((s) =>
              !c.backgroundSkillProfs.contains(s) &&
              !originSkillChoiceIds.contains(s) &&
              s != savedBarbarianPrimalKnowledgeSkill &&
              !savedBardLoreSkills.contains(s) &&
              s != savedBardMoonSkill &&
              !savedClericKnowledgeSkills.contains(s) &&
              s != savedFighterBattleMasterStudentSkill &&
              !savedArtificerSkills.contains(s) &&
              !savedMonkSubclassSkills.contains(s))
          .toList(),
      strength: baseAbilities.strength,
      dexterity: baseAbilities.dexterity,
      constitution: baseAbilities.constitution,
      intelligence: baseAbilities.intelligence,
      wisdom: baseAbilities.wisdom,
      charisma: baseAbilities.charisma,
      selectedSpells: c.selectedSpells
          .where((spell) =>
              !originSpellIds.contains(spell) &&
              !grantedSpellIds.contains(spell) &&
              !specialChoiceSpellIds.contains(spell) &&
              !savedRangerBaseSpells.contains(spell) &&
              !savedRangerCantrips.contains(spell) &&
              !savedBardBaseSpells.contains(spell) &&
              !savedBardLoreSpells.contains(spell) &&
              spell != savedBardMoonCantrip &&
              !savedDruidBaseSpells.contains(spell) &&
              !savedDruidCantrips.contains(spell) &&
              !savedDruidLandSpells.contains(spell) &&
              !savedMonkSubclassSpells.contains(spell) &&
              !savedWarlockBaseSpells.contains(spell) &&
              !savedWarlockPactTomeSpells.contains(spell) &&
              !savedWarlockMysticArcanumSpells.contains(spell) &&
              !savedRogueArcaneTricksterSpells.contains(spell) &&
              !savedFighterEldritchKnightSpells.contains(spell) &&
              !savedFighterPsiWarriorSpells.contains(spell) &&
              !savedArtificerBaseSpells.contains(spell) &&
              spell != savedRogueScionCantrip &&
              !savedPaladinBaseSpells.contains(spell) &&
              !savedPaladinCantrips.contains(spell))
          .toList(),
      originFeatSpellAbility: parsed.originFeatSpellAbility,
      originFeatCantrips: List<String>.from(parsed.originCantrips),
      originFeatSpell: parsed.originSpell,
      originFeatChoices: List<String>.from(parsed.originFeatChoices),
      speciesSkillChoice: parsed.speciesSkillChoice,
      speciesOriginFeatId: parsed.speciesOriginFeatId,
      speciesOriginFeatSpellAbility: parsed.speciesOriginFeatSpellAbility,
      speciesOriginFeatCantrips:
          List<String>.from(parsed.speciesOriginFeatCantrips),
      speciesOriginFeatSpell: parsed.speciesOriginFeatSpell,
      speciesOriginFeatChoices:
          List<String>.from(parsed.speciesOriginFeatChoices),
      speciesSpellAbility: parsed.speciesSpellAbility,
      speciesGrantedCantrip: parsed.speciesGrantedCantrip,
      clericDivineOrder: parsed.clericDivineOrder,
      clericThaumaturgeCantrip: parsed.clericThaumaturgeCantrip,
      personalityTraits: c.personalityTraits,
      ideals: c.ideals,
      bonds: c.bonds,
      flaws: c.flaws,
      backstory: c.backstory,
      levelAdvancements: List<String>.from(c.levelAdvancements),
    );
  }

  void loadForLevelUp(CharacterModel c) {
    loadFromCharacter(c);

    final nextLevel = c.level >= 20 ? 20 : c.level + 1;
    _notifierState = _notifierState.copyWith(
      level: nextLevel,
      currentStep: 2,
    );
  }

  _AdjustedAbilities _removeSavedAbilityBonuses({
    required int strength,
    required int dexterity,
    required int constitution,
    required int intelligence,
    required int wisdom,
    required int charisma,
    required List<String> backgroundBonusChoices,
    required List<String> levelAdvancements,
    required String className,
    required int level,
  }) {
    var str = strength;
    var dex = dexterity;
    var con = constitution;
    var intScore = intelligence;
    var wis = wisdom;
    var cha = charisma;

    final counts = <String, int>{};
    for (final ability in backgroundBonusChoices) {
      counts.update(ability, (value) => value + 1, ifAbsent: () => 1);
    }

    void subtract(String ability, int amount) {
      switch (ability) {
        case 'str':
          str -= amount;
          break;
        case 'dex':
          dex -= amount;
          break;
        case 'con':
          con -= amount;
          break;
        case 'int':
          intScore -= amount;
          break;
        case 'wis':
          wis -= amount;
          break;
        case 'cha':
          cha -= amount;
          break;
      }
    }

    for (final entry in counts.entries) {
      subtract(entry.key, entry.value);
    }

    for (final entry in _classAdvancementEntries(levelAdvancements)) {
      final payload = _advancementPayload(entry);
      if (payload.isEmpty) continue;

      if (payload.first == 'asi' && payload.length >= 2) {
        for (final bonus in _splitChoices(payload[1])) {
          final parts = bonus.split('+');
          if (parts.length != 2) continue;
          subtract(parts[0], int.tryParse(parts[1]) ?? 0);
        }
      }

      if (payload.first == 'feat' && payload.length >= 3) {
        final featId = payload[1];
        final ability = payload[2];
        if (!ProgressionService.isMagicInitiateId(featId) &&
            ability.isNotEmpty &&
            ability != '-') {
          subtract(ability, 1);
        }
      }
    }

    if (MonkChoiceService.isMonk(className: className) && level >= 20) {
      subtract('dex', MonkChoiceService.bodyAndMindAbilityBonus);
      subtract('wis', MonkChoiceService.bodyAndMindAbilityBonus);
    }

    if (className == 'barbarian' && level >= 20) {
      subtract('str', 4);
      subtract('con', 4);
    }

    return _AdjustedAbilities(
      strength: str,
      dexterity: dex,
      constitution: con,
      intelligence: intScore,
      wisdom: wis,
      charisma: cha,
    );
  }

  List<String> _classAdvancementEntries(List<String> entries) {
    return entries
        .where((entry) =>
            !entry.startsWith('origin_') &&
            !entry.startsWith('class_choice:') &&
            !entry.startsWith('species_choice:'))
        .toList();
  }

  List<String> _advancementPayload(String entry) {
    if (entry.startsWith('level:')) {
      final parts = entry.split(':');
      if (parts.length < 4) return const [];
      return parts.skip(2).toList();
    }

    if (entry.startsWith('asi:') || entry.startsWith('feat:')) {
      return entry.split(':');
    }

    return const [];
  }

  List<String> _splitChoices(String value) {
    return value
        .split(',')
        .map((choice) => choice.trim())
        .where((choice) => choice.isNotEmpty)
        .toList();
  }

  _ParsedOriginChoices _parseOriginChoices(List<String> entries) {
    String backgroundFeatId = '';
    String backgroundFeatName = '';
    String originFeatSpellAbility = '';
    final originCantrips = <String>[];
    String originSpell = '';
    final originFeatChoices = <String>[];
    final backgroundBonusChoices = <String>[];
    String speciesSkillChoice = '';
    String speciesOriginFeatId = '';
    String speciesOriginFeatSpellAbility = '';
    final speciesOriginFeatCantrips = <String>[];
    String speciesOriginFeatSpell = '';
    final speciesOriginFeatChoices = <String>[];
    String speciesSpellAbility = '';
    String speciesGrantedCantrip = '';
    String clericDivineOrder = '';
    String clericThaumaturgeCantrip = '';

    for (final entry in entries) {
      if (entry.startsWith('origin_feat:')) {
        backgroundFeatId = entry.replaceFirst('origin_feat:', '');
      } else if (entry.startsWith('origin_feat_name:')) {
        backgroundFeatName = entry.replaceFirst('origin_feat_name:', '');
      } else if (entry.startsWith('origin_feat_ability:')) {
        originFeatSpellAbility = entry.replaceFirst('origin_feat_ability:', '');
      } else if (entry.startsWith('origin_cantrip:')) {
        originCantrips.add(entry.replaceFirst('origin_cantrip:', ''));
      } else if (entry.startsWith('origin_spell:')) {
        originSpell = entry.replaceFirst('origin_spell:', '');
      } else if (entry.startsWith('origin_choice:')) {
        originFeatChoices.add(entry.replaceFirst('origin_choice:', ''));
      } else if (entry.startsWith('origin_asi:')) {
        final raw = entry.replaceFirst('origin_asi:', '');
        final parts = raw.split(',');
        for (final part in parts) {
          final split = part.split('+');
          if (split.length != 2) continue;
          final ability = split[0];
          final count = int.tryParse(split[1]) ?? 0;
          for (var i = 0; i < count; i++) {
            backgroundBonusChoices.add(ability);
          }
        }
      } else if (entry.startsWith('species_choice:skillful:')) {
        speciesSkillChoice = entry.replaceFirst('species_choice:skillful:', '');
      } else if (entry.startsWith('species_choice:versatile_feat:')) {
        speciesOriginFeatId =
            entry.replaceFirst('species_choice:versatile_feat:', '');
      } else if (entry.startsWith('species_choice:versatile_feat_ability:')) {
        speciesOriginFeatSpellAbility = entry.replaceFirst(
          'species_choice:versatile_feat_ability:',
          '',
        );
      } else if (entry.startsWith('species_choice:versatile_cantrip:')) {
        speciesOriginFeatCantrips.add(
          entry.replaceFirst('species_choice:versatile_cantrip:', ''),
        );
      } else if (entry.startsWith('species_choice:versatile_spell:')) {
        speciesOriginFeatSpell =
            entry.replaceFirst('species_choice:versatile_spell:', '');
      } else if (entry.startsWith('species_choice:versatile_choice:')) {
        speciesOriginFeatChoices.add(
          entry.replaceFirst('species_choice:versatile_choice:', ''),
        );
      } else if (entry.startsWith('species_choice:spell_ability:')) {
        speciesSpellAbility =
            entry.replaceFirst('species_choice:spell_ability:', '');
      } else if (entry.startsWith('species_choice:granted_cantrip:')) {
        speciesGrantedCantrip =
            entry.replaceFirst('species_choice:granted_cantrip:', '');
      } else if (entry.startsWith('class_choice:divine_order:')) {
        clericDivineOrder =
            entry.replaceFirst('class_choice:divine_order:', '');
      } else if (entry.startsWith('class_choice:divine_order_cantrip:')) {
        clericThaumaturgeCantrip = entry.replaceFirst(
          'class_choice:divine_order_cantrip:',
          '',
        );
      }
    }

    return _ParsedOriginChoices(
      backgroundFeatId: backgroundFeatId,
      backgroundFeatName: backgroundFeatName,
      originFeatSpellAbility: originFeatSpellAbility,
      originCantrips: originCantrips,
      originSpell: originSpell,
      originFeatChoices: originFeatChoices,
      backgroundBonusChoices: backgroundBonusChoices,
      speciesSkillChoice: speciesSkillChoice,
      speciesOriginFeatId: speciesOriginFeatId,
      speciesOriginFeatSpellAbility: speciesOriginFeatSpellAbility,
      speciesOriginFeatCantrips: speciesOriginFeatCantrips,
      speciesOriginFeatSpell: speciesOriginFeatSpell,
      speciesOriginFeatChoices: speciesOriginFeatChoices,
      speciesSpellAbility: speciesSpellAbility,
      speciesGrantedCantrip: speciesGrantedCantrip,
      clericDivineOrder: clericDivineOrder,
      clericThaumaturgeCantrip: clericThaumaturgeCantrip,
    );
  }
}
