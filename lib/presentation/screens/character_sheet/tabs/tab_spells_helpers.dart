part of 'tab_spells.dart';

extension _TabSpellsHelpers on TabSpells {
  String _selectedBaseRaceId(String raceValue) {
    if (!raceValue.contains('::')) return raceValue;
    return raceValue.split('::').first;
  }

  List<int> _normalizeSpellSlots(List<int> slots) {
    final normalized = List<int>.filled(9, 0);
    for (var i = 0; i < slots.length && i < normalized.length; i++) {
      normalized[i] = slots[i];
    }
    return normalized;
  }

  String _getEffectiveSpellAbility() {
    if (RogueChoiceService.isArcaneTrickster(
      className: character.className,
      subclass: character.subclass,
      level: character.level,
    )) {
      return 'int';
    }
    if (FighterChoiceService.isEldritchKnight(
      className: character.className,
      subclass: character.subclass,
      level: character.level,
    )) {
      return 'int';
    }
    if (FighterChoiceService.isPsiWarrior(
          className: character.className,
          subclass: character.subclass,
          level: character.level,
        ) &&
        character.level >= 18) {
      return 'int';
    }
    if (BarbarianChoiceService.isWildHeart(
      className: character.className,
      subclass: character.subclass,
      level: character.level,
    )) {
      return 'wis';
    }
    if (RogueChoiceService.needsScionDreadAllegiance(
          className: character.className,
          subclass: character.subclass,
          level: character.level,
        ) &&
        RogueChoiceService.selectedScionDreadAllegiance(
              character.levelAdvancements,
            ) !=
            null) {
      return 'int';
    }

    if (character.spellcastingAbility.isNotEmpty) {
      return character.spellcastingAbility.toLowerCase();
    }

    for (final entry in character.levelAdvancements.reversed) {
      if (entry.startsWith('origin_feat_ability:')) {
        return entry.replaceFirst('origin_feat_ability:', '').toLowerCase();
      }
      if (entry.startsWith('species_choice:versatile_feat_ability:')) {
        return entry
            .replaceFirst('species_choice:versatile_feat_ability:', '')
            .toLowerCase();
      }
      if (entry.startsWith('species_choice:spell_ability:')) {
        return entry
            .replaceFirst('species_choice:spell_ability:', '')
            .toLowerCase();
      }
      if (entry.startsWith('feat:magic-initiate-')) {
        final parts = entry.split(':');
        if (parts.length > 2 && parts[2].isNotEmpty) {
          return parts[2].toLowerCase();
        }
      }
    }

    return '';
  }

  int _getAbilityScore(String ability) {
    switch (ability) {
      case 'int':
        return character.intelligence;
      case 'wis':
        return character.wisdom;
      case 'cha':
        return character.charisma;
      default:
        return 10;
    }
  }
}
