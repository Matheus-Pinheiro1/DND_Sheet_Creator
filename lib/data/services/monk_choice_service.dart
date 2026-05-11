import '../../core/utils/dice_calculator.dart';
import '../local/weapons_data.dart';
import 'progression_service.dart';

class MonkChoiceService {
  MonkChoiceService._();

  static const bodyAndMindAbilityBonus = 4;
  static const bodyAndMindAbilityMaximum = 25;
  static const mercySubclass = 'monk-mercy';
  static const shadowSubclass = 'monk-shadow';
  static const elementsSubclass = 'monk-elements';
  static const openHandSubclass = 'monk-open-hand';

  static const mercySkillProficiencies = ['insight', 'medicine'];
  static const mercyToolProficiency = 'Herbalism Kit';
  static const elementalDamageTypes = [
    'Acid',
    'Cold',
    'Fire',
    'Lightning',
    'Thunder',
  ];

  static bool isMonk({required String className}) {
    return className.trim().toLowerCase() == 'monk';
  }

  static String martialArtsDie(int level) {
    return ProgressionService.getMonkMartialArtsDie(level);
  }

  static bool isMercy({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isMonk(className: className) &&
        subclass.trim().toLowerCase() == mercySubclass &&
        level >= 3;
  }

  static bool isShadow({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isMonk(className: className) &&
        subclass.trim().toLowerCase() == shadowSubclass &&
        level >= 3;
  }

  static bool isElements({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isMonk(className: className) &&
        subclass.trim().toLowerCase() == elementsSubclass &&
        level >= 3;
  }

  static bool isOpenHand({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isMonk(className: className) &&
        subclass.trim().toLowerCase() == openHandSubclass &&
        level >= 3;
  }

  static List<String> subclassSkillProficiencies({
    required String className,
    required String subclass,
    required int level,
  }) {
    if (isMercy(className: className, subclass: subclass, level: level)) {
      return mercySkillProficiencies;
    }
    return const [];
  }

  static List<String> subclassProficiencyLabels({
    required String className,
    required String subclass,
    required int level,
  }) {
    if (isMercy(className: className, subclass: subclass, level: level)) {
      return const [
        'Warrior of Mercy: Insight',
        'Warrior of Mercy: Medicine',
        mercyToolProficiency,
      ];
    }
    if (isShadow(className: className, subclass: subclass, level: level)) {
      return const ['Shadow Arts: Darkvision +60 ft'];
    }
    return const [];
  }

  static List<String> subclassSpellIds({
    required String className,
    required String subclass,
    required int level,
  }) {
    if (isShadow(className: className, subclass: subclass, level: level)) {
      return const ['darkness', 'minor-illusion'];
    }
    if (isElements(className: className, subclass: subclass, level: level)) {
      return const ['elementalism'];
    }
    return const [];
  }

  static int unarmoredMovementBonus(int level) {
    return ProgressionService.getMonkUnarmoredMovementBonus(level);
  }

  static int focusPoints(int level) {
    return level >= 2 ? level : 0;
  }

  static int slowFallReduction(int level) {
    return level >= 4 ? level * 5 : 0;
  }

  static int stunningStrikeSaveDc({
    required int level,
    required int wisdom,
  }) {
    return 8 +
        DiceCalculator.getProficiencyBonus(level) +
        DiceCalculator.getModifier(wisdom);
  }

  static String uncannyMetabolismHealingFormula(int level) {
    return '${martialArtsDie(level)} + $level';
  }

  static String deflectAttacksReductionFormula({
    required int level,
    required int dexterity,
  }) {
    return _formula(
      '1d10',
      [DiceCalculator.getModifier(dexterity), level],
    );
  }

  static String deflectRedirectDamageFormula({
    required int level,
    required int dexterity,
  }) {
    return _formula(
      _multiplySingleDie(martialArtsDie(level), 2),
      [DiceCalculator.getModifier(dexterity)],
    );
  }

  static String heightenedFocusTemporaryHpFormula(int level) {
    return _multiplySingleDie(martialArtsDie(level), 2);
  }

  static String martialArtsPlusWisdomFormula({
    required int level,
    required int wisdom,
  }) {
    return _formula(
        martialArtsDie(level), [DiceCalculator.getModifier(wisdom)]);
  }

  static int wisdomUses(int wisdom) {
    final modifier = DiceCalculator.getModifier(wisdom);
    return modifier < 1 ? 1 : modifier;
  }

  static String ultimateMercyHealingFormula(int wisdom) {
    return _formula('4d10', [DiceCalculator.getModifier(wisdom)]);
  }

  static String elementalBurstDamageFormula(int level) {
    return _multiplySingleDie(martialArtsDie(level), 3);
  }

  static int monkSaveDc({
    required int level,
    required int wisdom,
  }) {
    return stunningStrikeSaveDc(level: level, wisdom: wisdom);
  }

  static String elementalDamageTypeSummary() {
    return elementalDamageTypes.join(', ');
  }

  static bool isMonkWeapon(DndWeapon weapon) {
    if (_isRangedWeapon(weapon)) {
      return false;
    }

    if (weapon.category == WeaponCategory.simple) {
      return true;
    }

    return weapon.category == WeaponCategory.martial &&
        weapon.properties.toLowerCase().contains('light');
  }

  static bool _isRangedWeapon(DndWeapon weapon) {
    final properties = weapon.properties.toLowerCase();
    if (properties.contains('ammunition')) {
      return true;
    }

    return weapon.name.toLowerCase() == 'dart';
  }

  static String _multiplySingleDie(String dice, int count) {
    final match = RegExp(r'^1d(\d+)$').firstMatch(dice.trim().toLowerCase());
    if (match == null) {
      return dice;
    }
    return '${count}d${match.group(1)}';
  }

  static String _formula(String base, List<int> terms) {
    final buffer = StringBuffer(base);
    for (final term in terms) {
      if (term > 0) {
        buffer.write(' + $term');
      } else if (term < 0) {
        buffer.write(' - ${term.abs()}');
      }
    }
    return buffer.toString();
  }
}
