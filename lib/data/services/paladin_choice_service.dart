import '../remote/spell_dto.dart';

class PaladinChoiceService {
  PaladinChoiceService._();

  static const fightingStyleEntryPrefix =
      'class_choice:paladin_fighting_style:';
  static const weaponMasteryEntryPrefix =
      'class_choice:paladin_weapon_mastery:';
  static const blessedWarriorCantripPrefix =
      'class_choice:paladin_blessed_warrior_cantrip:';
  static const genieSplendorSkillEntryPrefix =
      'class_choice:paladin_genie_splendor_skill:';

  static const nobleGeniesSubclass = 'paladin-noble-genies';

  static const weaponMasterySelectionCount = 2;
  static const blessedWarriorCantripCount = 2;

  static const List<String> genieSplendorSkillOptions = [
    'acrobatics',
    'intimidation',
    'performance',
    'persuasion',
  ];

  static const Map<String, String> _skillLabels = {
    'acrobatics': 'Acrobatics',
    'intimidation': 'Intimidation',
    'performance': 'Performance',
    'persuasion': 'Persuasion',
  };

  static const List<String> fightingStyleOptions = [
    'Blessed Warrior',
    'Blind Fighting',
    'Defense',
    'Dueling',
    'Great Weapon Fighting',
    'Interception',
    'Protection',
    'Thrown Weapon Fighting',
    'Two-Weapon Fighting',
    'Unarmed Fighting',
  ];

  static bool isPaladin({required String className}) {
    return className.trim().toLowerCase() == 'paladin';
  }

  static bool isPaladinChoiceEntry(String entry) {
    return entry.startsWith(fightingStyleEntryPrefix) ||
        entry.startsWith(weaponMasteryEntryPrefix) ||
        entry.startsWith(blessedWarriorCantripPrefix) ||
        isPaladinSubclassChoiceEntry(entry);
  }

  static bool isPaladinSubclassChoiceEntry(String entry) {
    return entry.startsWith(genieSplendorSkillEntryPrefix);
  }

  static bool needsWeaponMastery({
    required String className,
    required int level,
  }) {
    return isPaladin(className: className) && level >= 1;
  }

  static bool needsFightingStyle({
    required String className,
    required int level,
  }) {
    return isPaladin(className: className) && level >= 2;
  }

  static bool needsBlessedWarriorCantrips({
    required String className,
    required int level,
    required Iterable<String> entries,
  }) {
    return needsFightingStyle(className: className, level: level) &&
        selectedFightingStyle(entries) == 'Blessed Warrior';
  }

  static bool isNobleGenies({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isPaladin(className: className) &&
        subclass.trim().toLowerCase() == nobleGeniesSubclass &&
        level >= 3;
  }

  static String? selectedFightingStyle(Iterable<String> entries) {
    for (final entry in entries.toList().reversed) {
      if (!entry.startsWith(fightingStyleEntryPrefix)) continue;
      final value = entry.replaceFirst(fightingStyleEntryPrefix, '').trim();
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  static List<String> selectedWeaponMasteries(Iterable<String> entries) {
    final weapons = <String>[];
    for (final entry in entries) {
      if (!entry.startsWith(weaponMasteryEntryPrefix)) continue;
      final value = entry.replaceFirst(weaponMasteryEntryPrefix, '').trim();
      if (value.isEmpty || weapons.contains(value)) continue;
      weapons.add(value);
    }
    return weapons;
  }

  static List<String> selectedBlessedWarriorCantrips(
    Iterable<String> entries,
  ) {
    final cantrips = <String>[];
    for (final entry in entries) {
      if (!entry.startsWith(blessedWarriorCantripPrefix)) continue;
      final value = entry.replaceFirst(blessedWarriorCantripPrefix, '').trim();
      if (value.isEmpty || cantrips.contains(value)) continue;
      cantrips.add(value);
    }
    return cantrips;
  }

  static String? selectedGenieSplendorSkill(Iterable<String> entries) {
    for (final entry in entries.toList().reversed) {
      if (!entry.startsWith(genieSplendorSkillEntryPrefix)) continue;
      final value =
          entry.replaceFirst(genieSplendorSkillEntryPrefix, '').trim();
      if (genieSplendorSkillOptions.contains(value)) return value;
    }
    return null;
  }

  static Iterable<String> preservedEntriesForLevel(
    Iterable<String> entries, {
    required int characterLevel,
  }) {
    return entries.where((entry) {
      if (!isPaladinChoiceEntry(entry)) return false;

      if (entry.startsWith(weaponMasteryEntryPrefix)) {
        return characterLevel >= 1;
      }

      if (entry.startsWith(fightingStyleEntryPrefix)) {
        return characterLevel >= 2;
      }

      if (entry.startsWith(blessedWarriorCantripPrefix)) {
        return characterLevel >= 2 &&
            selectedFightingStyle(entries) == 'Blessed Warrior';
      }

      if (entry.startsWith(genieSplendorSkillEntryPrefix)) {
        final skill =
            entry.replaceFirst(genieSplendorSkillEntryPrefix, '').trim();
        return characterLevel >= 3 && genieSplendorSkillOptions.contains(skill);
      }

      return false;
    });
  }

  static List<String> baseGrantedSpellIds(int level) {
    return [
      if (level >= 2) 'divine-smite',
      if (level >= 5) 'find-steed',
    ];
  }

  static String fightingStyleLabel(String style) {
    return 'Fighting Style: $style';
  }

  static String weaponMasteryLabel(List<String> weapons) {
    return 'Weapon Mastery: ${weapons.join(', ')}';
  }

  static String skillLabel(String skillIndex) {
    return _skillLabels[skillIndex] ?? skillIndex;
  }

  static String genieSplendorSkillLabel(String skillIndex) {
    return 'Genie\'s Splendor: ${skillLabel(skillIndex)}';
  }

  static List<SpellDto> filterBlessedWarriorCantrips({
    required List<SpellDto> spells,
    required Set<String> knownSpellIds,
  }) {
    final filtered = spells.where((spell) {
      return spell.level == 0 && !knownSpellIds.contains(spell.index);
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }
}
