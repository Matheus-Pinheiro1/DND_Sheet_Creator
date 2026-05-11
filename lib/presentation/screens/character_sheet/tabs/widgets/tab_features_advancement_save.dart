part of '../tab_features.dart';

extension _AdvancementPickerSave on _AdvancementPickerSheetState {
  void _save() {
    CharacterModel updated = widget.character;
    String encoded;

    if (_isFeat) {
      final feat = _selectedFeat;
      if (feat == null) return;
      if (ProgressionService.isMagicInitiateId(feat.id)) {
        if (_magicInitiateCantrips.length != 2 || _magicInitiateSpell.isEmpty) {
          return;
        }
        encoded =
            'feat:${feat.id}:$_magicInitiateAbility:${_magicInitiateCantrips.join(',')}:$_magicInitiateSpell';
        updated = _applyFeat(
          updated,
          feat,
          null,
          magicInitiateSpells: [
            ..._magicInitiateCantrips,
            _magicInitiateSpell,
          ],
        );
      } else {
        final extraChoices = <String>[];
        if (feat.id == 'skilled') {
          if (_skilledChoices.length != 3) return;
          extraChoices.addAll(_skilledChoices);
        } else if (feat.id == 'crafter') {
          if (_crafterTools.length != 3) return;
          extraChoices.addAll(_crafterTools);
        } else if (feat.id == 'musician') {
          if (_musicianInstruments.length != 3) return;
          extraChoices.addAll(_musicianInstruments);
        } else if (feat.id == 'skill-expert') {
          if (_skillExpertSkill.isEmpty || _skillExpertExpertise.isEmpty) {
            return;
          }
          extraChoices.add('skill:$_skillExpertSkill');
          extraChoices.add('expertise:$_skillExpertExpertise');
        }

        final needsAbilityChoice = _featAbilityOptions(feat).isNotEmpty;
        final selectedAbility =
            needsAbilityChoice ? _selectedFeatAbility : null;
        if (needsAbilityChoice) {
          if (selectedAbility == null || selectedAbility.isEmpty) {
            return;
          }
          if (!_canApplyFeatAbility(selectedAbility)) {
            return;
          }
        }

        final abilityPart = selectedAbility ?? '-';
        encoded = extraChoices.isEmpty
            ? 'feat:${feat.id}:$abilityPart'
            : 'feat:${feat.id}:$abilityPart:${extraChoices.join('|')}';
        updated = _applyFeat(
          updated,
          feat,
          selectedAbility,
          extraChoices: extraChoices,
        );
      }
    } else {
      if (_asiMode == 'single') {
        encoded = 'asi:$_singleAbility+2';
        updated = _adjustAbility(updated, _singleAbility, 2);
      } else {
        if (_firstAbility == _secondAbility) return;
        encoded = 'asi:$_firstAbility+1,$_secondAbility+1';
        updated = _adjustAbility(updated, _firstAbility, 1);
        updated = _adjustAbility(updated, _secondAbility, 1);
      }
    }

    updated = updated.copyWith(
      levelAdvancements: [...updated.levelAdvancements, encoded],
    );

    Navigator.of(context).pop(_AdvancementResult(updated));
  }

  CharacterModel _applyFeat(
    CharacterModel c,
    FeatModel feat,
    String? ability, {
    List<String> magicInitiateSpells = const [],
    List<String> extraChoices = const [],
  }) {
    var updated = c;
    final advancementLevel =
        LevelAdvancementService.nextAvailableLevel(widget.character);
    if (ability != null &&
        ability.isNotEmpty &&
        ability != '-' &&
        advancementLevel != null) {
      final increase = LevelAdvancementService.cappedIncrease(
        currentScore: _abilityScore(updated, ability),
        requestedIncrease: 1,
        advancementLevel: advancementLevel,
      );
      if (increase > 0) {
        updated = _adjustAbility(updated, ability, increase);
      }
    }
    if (feat.id == 'tough') {
      updated = updated.copyWith(
        maxHP: updated.maxHP + (2 * updated.level),
        currentHP: updated.currentHP + (2 * updated.level),
      );
    }
    if (feat.id == 'resilient' &&
        ability != null &&
        ability.isNotEmpty &&
        ability != '-' &&
        !updated.savingThrowProfs.contains(ability)) {
      updated = updated.copyWith(
        savingThrowProfs: [...updated.savingThrowProfs, ability],
      );
    }
    if (feat.id == 'skilled' && extraChoices.isNotEmpty) {
      final skills = <String>[];
      final profs = List<String>.from(updated.proficiencies);
      for (final choice in extraChoices) {
        if (choice.startsWith('skill:')) {
          skills.add(choice.replaceFirst('skill:', ''));
        } else if (choice.startsWith('tool:')) {
          final tool = choice.replaceFirst('tool:', '');
          if (!profs.contains(tool)) profs.add(tool);
        }
      }
      updated = updated.copyWith(
        proficientSkills: {...updated.proficientSkills, ...skills}.toList(),
        proficiencies: profs,
      );
    }
    if (feat.id == 'crafter' && extraChoices.isNotEmpty) {
      final profs = List<String>.from(updated.proficiencies);
      for (final choice in extraChoices) {
        if (choice.startsWith('tool:')) {
          final tool = choice.replaceFirst('tool:', '');
          if (!profs.contains(tool)) profs.add(tool);
        }
      }
      updated = updated.copyWith(proficiencies: profs);
    }
    if (feat.id == 'musician' && extraChoices.isNotEmpty) {
      final profs = List<String>.from(updated.proficiencies);
      for (final choice in extraChoices) {
        if (choice.startsWith('tool:')) {
          final tool = choice.replaceFirst('tool:', '');
          if (!profs.contains(tool)) profs.add(tool);
        }
      }
      updated = updated.copyWith(proficiencies: profs);
    }
    if (feat.id == 'skill-expert' && extraChoices.isNotEmpty) {
      final skills = List<String>.from(updated.proficientSkills);
      final profs = List<String>.from(updated.proficiencies);
      for (final choice in extraChoices) {
        if (choice.startsWith('skill:')) {
          final skill = choice.replaceFirst('skill:', '');
          if (!skills.contains(skill)) skills.add(skill);
        } else if (choice.startsWith('expertise:')) {
          final skill = choice.replaceFirst('expertise:', '');
          final label =
              _AdvancementPickerSheetState._skillLabels[skill] ?? skill;
          final entry = 'Expertise: $label';
          if (!profs.contains(entry)) profs.add(entry);
        }
      }
      updated = updated.copyWith(
        proficientSkills: skills,
        proficiencies: profs,
      );
    }
    if (feat.id == 'martial-weapon-training' &&
        !updated.proficiencies.contains('Martial Weapons')) {
      updated = updated.copyWith(
        proficiencies: [...updated.proficiencies, 'Martial Weapons'],
      );
    }
    if (ProgressionService.isMagicInitiateId(feat.id) &&
        magicInitiateSpells.isNotEmpty) {
      updated = updated.copyWith(
        selectedSpells: {
          ...updated.selectedSpells,
          ...magicInitiateSpells,
        }.toList(),
      );
    }
    return updated;
  }

  CharacterModel _adjustAbility(CharacterModel c, String ability, int amount) {
    switch (ability) {
      case 'str':
        return c.copyWith(strength: c.strength + amount);
      case 'dex':
        return c.copyWith(
          dexterity: c.dexterity + amount,
          initiative: DiceCalculator.getModifier(c.dexterity + amount),
          armorClass: c.armorClass +
              amount ~/ 2 -
              DiceCalculator.getModifier(c.dexterity),
        );
      case 'con':
        return c.copyWith(
          constitution: c.constitution + amount,
          maxHP: c.maxHP +
              (DiceCalculator.getModifier(c.constitution + amount) -
                      DiceCalculator.getModifier(c.constitution)) *
                  c.level,
          currentHP: c.currentHP +
              (DiceCalculator.getModifier(c.constitution + amount) -
                      DiceCalculator.getModifier(c.constitution)) *
                  c.level,
        );
      case 'int':
        return c.copyWith(intelligence: c.intelligence + amount);
      case 'wis':
        return c.copyWith(wisdom: c.wisdom + amount);
      case 'cha':
        return c.copyWith(charisma: c.charisma + amount);
      default:
        return c;
    }
  }
}
