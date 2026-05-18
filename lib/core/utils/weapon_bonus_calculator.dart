import 'package:dnd_character_sheet/data/local/weapons_data.dart';
import 'package:dnd_character_sheet/data/models/character_model.dart';
import 'package:dnd_character_sheet/data/services/monk_choice_service.dart';
import 'dice_calculator.dart';

class WeaponBonusCalculator {
  const WeaponBonusCalculator._();

  static String calculateWeaponBonus(
    DndWeapon weapon,
    CharacterModel character,
  ) {
    final bonus = calculateAttackBonus(weapon, character);
    return bonus >= 0 ? '+$bonus' : '$bonus';
  }

  static int calculateAttackBonus(
    DndWeapon weapon,
    CharacterModel character,
  ) {
    final profBonus = DiceCalculator.getProficiencyBonus(character.level);
    final abilityMod = DiceCalculator.getModifier(
      _relevantAbilityScore(weapon, character),
    );
    final isProficient = _isProficientWithWeapon(weapon, character);
    final exhaustionPenalty = character.exhaustionLevel;
    return abilityMod +
        (isProficient ? profBonus : 0) +
        _fightingStyleAttackBonus(weapon, character) -
        exhaustionPenalty;
  }

  static String calculateWeaponDamageDice(
    DndWeapon weapon,
    CharacterModel character,
  ) {
    var damageDice = weapon.damageDice;

    if (MonkChoiceService.isMonk(className: character.className) &&
        isMonkWeapon(weapon)) {
      final monkDie = MonkChoiceService.martialArtsDie(character.level);
      damageDice = _singleDieSize(monkDie) > _singleDieSize(weapon.damageDice)
          ? monkDie
          : weapon.damageDice;
    }

    if (_hasPaladinRadiantStrikes(weapon, character)) {
      return '$damageDice + 1d8';
    }

    return damageDice;
  }

  static String calculateWeaponDamageType(
    DndWeapon weapon,
    CharacterModel character,
  ) {
    if (_hasPaladinRadiantStrikes(weapon, character) &&
        !weapon.damageType.toLowerCase().contains('radiant')) {
      return '${weapon.damageType} + Radiant';
    }
    return weapon.damageType;
  }

  static bool isMonkWeapon(DndWeapon weapon) {
    if (_isRangedWeapon(weapon)) {
      return false;
    }

    return MonkChoiceService.isMonkWeapon(weapon);
  }

  static int _relevantAbilityScore(
    DndWeapon weapon,
    CharacterModel character,
  ) {
    if (MonkChoiceService.isMonk(className: character.className) &&
        isMonkWeapon(weapon)) {
      return character.dexterity >= character.strength
          ? character.dexterity
          : character.strength;
    }

    if (_hasPactOfTheBlade(character) && _isMeleeWeapon(weapon)) {
      final normalScore =
          weapon.isFinesse && character.dexterity > character.strength
              ? character.dexterity
              : character.strength;
      return character.charisma > normalScore
          ? character.charisma
          : normalScore;
    }

    final isRanged = _isRangedWeapon(weapon);
    if (isRanged || weapon.isFinesse) {
      return character.dexterity >= character.strength
          ? character.dexterity
          : (weapon.isFinesse ? character.strength : character.dexterity);
    }
    return character.strength;
  }

  static bool isRangedWeapon(DndWeapon weapon) {
    return _isRangedWeapon(weapon);
  }

  static bool _isRangedWeapon(DndWeapon weapon) {
    final properties = weapon.properties.toLowerCase();
    if (properties.contains('ammunition')) {
      return true;
    }

    return weapon.name.toLowerCase() == 'dart';
  }

  static bool _isMeleeWeapon(DndWeapon weapon) {
    return !_isRangedWeapon(weapon);
  }

  static bool _hasPaladinRadiantStrikes(
    DndWeapon weapon,
    CharacterModel character,
  ) {
    return character.className.trim().toLowerCase() == 'paladin' &&
        character.level >= 11 &&
        !_isRangedWeapon(weapon);
  }

  static int _fightingStyleAttackBonus(
    DndWeapon weapon,
    CharacterModel character,
  ) {
    final profs = character.proficiencies.map((e) => e.toLowerCase()).toList();
    final hasArchery = profs.contains('fighting style: archery');
    return hasArchery && _isRangedWeapon(weapon) ? 2 : 0;
  }

  static bool _isProficientWithWeapon(
    DndWeapon weapon,
    CharacterModel character,
  ) {
    if (MonkChoiceService.isMonk(className: character.className) &&
        isMonkWeapon(weapon)) {
      return true;
    }

    if (_hasPactOfTheBlade(character) && _isMeleeWeapon(weapon)) {
      return true;
    }

    final profs = character.proficiencies.map((e) => e.toLowerCase()).toList();
    final name = weapon.name.toLowerCase();
    if (profs.any((p) => p.contains(name))) return true;
    if (weapon.category == WeaponCategory.simple &&
        profs.any((p) => p.contains('simple weapons'))) {
      return true;
    }
    if (weapon.category == WeaponCategory.martial &&
        profs.any((p) => p.contains('martial weapons'))) {
      return true;
    }
    return false;
  }

  static bool _hasPactOfTheBlade(CharacterModel character) {
    if (character.className.trim().toLowerCase() != 'warlock') {
      return false;
    }
    return character.proficiencies.any(
      (prof) => prof.toLowerCase().contains('pact of the blade'),
    );
  }

  static int _singleDieSize(String dice) {
    final match = RegExp(r'^1d(\d+)$').firstMatch(dice.trim().toLowerCase());
    if (match == null) {
      return 0;
    }
    return int.tryParse(match.group(1) ?? '0') ?? 0;
  }
}
