import '../../core/utils/dice_calculator.dart';
import '../remote/spell_dto.dart';

class DruidChoiceService {
  DruidChoiceService._();

  static const primalOrderEntryPrefix = 'class_choice:druid_primal_order:';
  static const magicianCantripEntryPrefix =
      'class_choice:druid_magician_cantrip:';
  static const elementalFuryEntryPrefix = 'class_choice:druid_elemental_fury:';
  static const landTypeEntryPrefix = 'class_choice:druid_land_type:';

  static const magicianOrder = 'magician';
  static const wardenOrder = 'warden';
  static const potentSpellcasting = 'potent_spellcasting';
  static const primalStrike = 'primal_strike';
  static const landSubclass = 'druid-land';
  static const moonSubclass = 'druid-moon';
  static const seaSubclass = 'druid-sea';
  static const starsSubclass = 'druid-stars';

  static const primalOrderOptions = {
    magicianOrder: 'Magician',
    wardenOrder: 'Warden',
  };

  static const elementalFuryOptions = {
    potentSpellcasting: 'Potent Spellcasting',
    primalStrike: 'Primal Strike',
  };

  static const landTypeOptions = {
    'arid': 'Arid',
    'polar': 'Polar',
    'temperate': 'Temperate',
    'tropical': 'Tropical',
  };

  static const _landSpellIdsByType = {
    'arid': {
      3: ['blur', 'burning-hands', 'fire-bolt'],
      5: ['fireball'],
      7: ['blight'],
      9: ['wall-of-stone'],
    },
    'polar': {
      3: ['fog-cloud', 'hold-person', 'ray-of-frost'],
      5: ['sleet-storm'],
      7: ['ice-storm'],
      9: ['cone-of-cold'],
    },
    'temperate': {
      3: ['misty-step', 'shocking-grasp', 'sleep'],
      5: ['lightning-bolt'],
      7: ['freedom-of-movement'],
      9: ['tree-stride'],
    },
    'tropical': {
      3: ['acid-splash', 'ray-of-sickness', 'web'],
      5: ['stinking-cloud'],
      7: ['polymorph'],
      9: ['insect-plague'],
    },
  };

  static const _landResistanceByType = {
    'arid': 'Fire',
    'polar': 'Cold',
    'temperate': 'Lightning',
    'tropical': 'Poison',
  };

  static bool isDruid({required String className}) {
    return className.trim().toLowerCase() == 'druid';
  }

  static bool isDruidChoiceEntry(String entry) {
    return entry.startsWith(primalOrderEntryPrefix) ||
        entry.startsWith(magicianCantripEntryPrefix) ||
        entry.startsWith(elementalFuryEntryPrefix) ||
        isDruidSubclassChoiceEntry(entry);
  }

  static bool isDruidSubclassChoiceEntry(String entry) {
    return entry.startsWith(landTypeEntryPrefix);
  }

  static bool needsPrimalOrder({
    required String className,
    required int level,
  }) {
    return isDruid(className: className) && level >= 1;
  }

  static bool needsMagicianCantrip({
    required String className,
    required int level,
    required Iterable<String> entries,
  }) {
    return needsPrimalOrder(className: className, level: level) &&
        selectedPrimalOrder(entries) == magicianOrder;
  }

  static bool needsElementalFury({
    required String className,
    required int level,
  }) {
    return isDruid(className: className) && level >= 7;
  }

  static bool isLand({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isDruid(className: className) &&
        subclass.trim().toLowerCase() == landSubclass &&
        level >= 3;
  }

  static bool isMoon({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isDruid(className: className) &&
        subclass.trim().toLowerCase() == moonSubclass &&
        level >= 3;
  }

  static bool isSea({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isDruid(className: className) &&
        subclass.trim().toLowerCase() == seaSubclass &&
        level >= 3;
  }

  static bool isStars({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isDruid(className: className) &&
        subclass.trim().toLowerCase() == starsSubclass &&
        level >= 3;
  }

  static String? selectedPrimalOrder(Iterable<String> entries) {
    return _firstEntryValue(entries, primalOrderEntryPrefix);
  }

  static String? selectedMagicianCantrip(Iterable<String> entries) {
    return _firstEntryValue(entries, magicianCantripEntryPrefix);
  }

  static String? selectedElementalFury(Iterable<String> entries) {
    return _firstEntryValue(entries, elementalFuryEntryPrefix);
  }

  static String? selectedLandType(Iterable<String> entries) {
    final selected = _firstEntryValue(entries, landTypeEntryPrefix);
    if (selected == null || !landTypeOptions.containsKey(selected)) {
      return null;
    }
    return selected;
  }

  static Iterable<String> preservedEntriesForLevel(
    Iterable<String> entries, {
    required int characterLevel,
    String subclass = '',
  }) {
    var keptPrimalOrder = false;
    var keptMagicianCantrip = false;
    var keptElementalFury = false;
    var keptLandType = false;
    final order = selectedPrimalOrder(entries);
    final normalizedSubclass = subclass.trim().toLowerCase();

    return entries.where((entry) {
      if (entry.startsWith(primalOrderEntryPrefix)) {
        final value = entry.replaceFirst(primalOrderEntryPrefix, '').trim();
        if (characterLevel < 1 ||
            keptPrimalOrder ||
            !primalOrderOptions.containsKey(value)) {
          return false;
        }
        keptPrimalOrder = true;
        return true;
      }

      if (entry.startsWith(magicianCantripEntryPrefix)) {
        final value = entry.replaceFirst(magicianCantripEntryPrefix, '').trim();
        if (characterLevel < 1 ||
            order != magicianOrder ||
            keptMagicianCantrip ||
            value.isEmpty) {
          return false;
        }
        keptMagicianCantrip = true;
        return true;
      }

      if (entry.startsWith(elementalFuryEntryPrefix)) {
        final value = entry.replaceFirst(elementalFuryEntryPrefix, '').trim();
        if (characterLevel < 7 ||
            keptElementalFury ||
            !elementalFuryOptions.containsKey(value)) {
          return false;
        }
        keptElementalFury = true;
        return true;
      }

      if (entry.startsWith(landTypeEntryPrefix)) {
        final value = entry.replaceFirst(landTypeEntryPrefix, '').trim();
        if (characterLevel < 3 ||
            normalizedSubclass != landSubclass ||
            keptLandType ||
            !landTypeOptions.containsKey(value)) {
          return false;
        }
        keptLandType = true;
        return true;
      }

      return false;
    });
  }

  static List<String> landSpellIds({
    required String className,
    required String subclass,
    required int level,
    required Iterable<String> entries,
  }) {
    if (!isLand(className: className, subclass: subclass, level: level)) {
      return const [];
    }

    final landType = selectedLandType(entries);
    final spellMap = _landSpellIdsByType[landType];
    if (spellMap == null) return const [];

    final spellIds = <String>[];
    final unlockLevels = spellMap.keys.toList()..sort();
    for (final unlockLevel in unlockLevels) {
      if (unlockLevel <= level) {
        spellIds.addAll(spellMap[unlockLevel] ?? const []);
      }
    }
    return spellIds;
  }

  static Map<int, List<String>> landSpellLabelsByLevel({
    required String className,
    required String subclass,
    required int level,
    required Iterable<String> entries,
  }) {
    if (!isLand(className: className, subclass: subclass, level: level)) {
      return const {};
    }

    final landType = selectedLandType(entries);
    final spellMap = _landSpellIdsByType[landType];
    if (spellMap == null) return const {};

    final result = <int, List<String>>{};
    final unlockLevels = spellMap.keys.toList()..sort();
    for (final unlockLevel in unlockLevels) {
      if (unlockLevel <= level) {
        result[unlockLevel] =
            (spellMap[unlockLevel] ?? const []).map(spellLabel).toList();
      }
    }
    return result;
  }

  static String? landResistance({
    required int level,
    required Iterable<String> entries,
  }) {
    if (level < 10) return null;
    final landType = selectedLandType(entries);
    return _landResistanceByType[landType];
  }

  static String landAidDice(int level) {
    if (level >= 14) return '4d6';
    if (level >= 10) return '3d6';
    return '2d6';
  }

  static int naturalRecoverySlotLevels(int level) {
    return (level + 1) ~/ 2;
  }

  static int moonWildShapeMaxChallengeRating(int level) {
    if (level < 3) return 0;
    return level ~/ 3;
  }

  static int moonWildShapeArmorClass(int wisdom) {
    return 13 + DiceCalculator.getModifier(wisdom);
  }

  static int moonWildShapeTemporaryHitPoints(int level) {
    return level * 3;
  }

  static int moonlightStepUses(int wisdom) {
    return _minimumOneAbilityModifier(wisdom);
  }

  static String seaWrathDamageDice(int wisdom) {
    return '${_minimumOneAbilityModifier(wisdom)}d6';
  }

  static String seaStormbornResistances() {
    return 'Cold, Lightning, and Thunder';
  }

  static int starsGuidingBoltUses(int wisdom) {
    return _minimumOneAbilityModifier(wisdom);
  }

  static String starryFormDie(int level) {
    return level >= 10 ? '2d8' : '1d8';
  }

  static int cosmicOmenUses(int wisdom) {
    return _minimumOneAbilityModifier(wisdom);
  }

  static String landTypeLabel(String value) {
    return landTypeOptions[value] ?? value;
  }

  static String landChoiceLabel(String value) {
    return 'Circle of the Land: ${landTypeLabel(value)}';
  }

  static String spellLabel(String spellIndex) {
    return spellIndex
        .split('-')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  static List<SpellDto> filterMagicianCantrips({
    required List<SpellDto> spells,
    required Set<String> knownSpellIds,
  }) {
    return spells.where((spell) {
      return spell.level == 0 && !knownSpellIds.contains(spell.index);
    }).toList()
      ..sort((left, right) => left.name.compareTo(right.name));
  }

  static List<String> baseGrantedSpellIds(int level) {
    if (level < 1) return const [];
    return [
      'speak-with-animals',
      if (level >= 2) 'find-familiar',
    ];
  }

  static List<String> proficiencyLabels({
    required String? primalOrder,
    required String? elementalFury,
  }) {
    final labels = <String>[];

    if (primalOrder != null) {
      labels.add('Primal Order: ${primalOrderLabel(primalOrder)}');
      if (primalOrder == magicianOrder) {
        labels.add('Nature Magician: Arcana/Nature +Wisdom');
      }
      if (primalOrder == wardenOrder) {
        labels.addAll(const ['Martial Weapons', 'Medium Armor']);
      }
    }

    if (elementalFury != null) {
      labels.add('Elemental Fury: ${elementalFuryLabel(elementalFury)}');
    }

    return labels;
  }

  static int magicianSkillBonus({
    required String className,
    required int level,
    required Iterable<String> entries,
    required int wisdom,
    required String skillIndex,
  }) {
    if (!needsMagicianCantrip(
      className: className,
      level: level,
      entries: entries,
    )) {
      return 0;
    }
    if (skillIndex != 'arcana' && skillIndex != 'nature') {
      return 0;
    }
    final wisdomMod = DiceCalculator.getModifier(wisdom);
    return wisdomMod < 1 ? 1 : wisdomMod;
  }

  static int wildShapeUses(int level) {
    if (level < 2) return 0;
    if (level >= 17) return 4;
    if (level >= 6) return 3;
    return 2;
  }

  static String wildShapeDuration(int level) {
    if (level < 2) return '-';
    final hours = level ~/ 2;
    return '$hours hour${hours == 1 ? '' : 's'}';
  }

  static String elementalFuryDamageDie(int level) {
    return level >= 15 ? '2d8' : '1d8';
  }

  static String primalOrderLabel(String value) {
    return primalOrderOptions[value] ?? value;
  }

  static String elementalFuryLabel(String value) {
    return elementalFuryOptions[value] ?? value;
  }

  static String? _firstEntryValue(
    Iterable<String> entries,
    String prefix,
  ) {
    for (final entry in entries) {
      if (!entry.startsWith(prefix)) continue;
      final value = entry.replaceFirst(prefix, '').trim();
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  static int _minimumOneAbilityModifier(int abilityScore) {
    final modifier = DiceCalculator.getModifier(abilityScore);
    return modifier < 1 ? 1 : modifier;
  }
}
