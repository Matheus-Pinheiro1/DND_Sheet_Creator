import '../../core/utils/dice_calculator.dart';
import '../local/weapons_data.dart';
import '../remote/spell_dto.dart';

class RangerChoiceService {
  RangerChoiceService._();

  static const expertiseEntryPrefix = 'class_choice:ranger_expertise:';
  static const languageEntryPrefix = 'class_choice:ranger_language:';
  static const fightingStyleEntryPrefix = 'class_choice:ranger_fighting_style:';
  static const weaponMasteryEntryPrefix = 'class_choice:ranger_weapon_mastery:';
  static const druidicWarriorCantripPrefix =
      'class_choice:ranger_druidic_warrior_cantrip:';
  static const feyGlamourSkillEntryPrefix =
      'class_choice:ranger_fey_glamour_skill:';

  static const beastMasterSubclass = 'ranger-beast-master';
  static const feyWandererSubclass = 'ranger-fey-wanderer';
  static const gloomStalkerSubclass = 'ranger-gloom-stalker';
  static const hunterSubclass = 'ranger-hunter';
  static const winterWalkerSubclass = 'ranger-winter-walker';

  static const weaponMasterySelectionCount = 2;
  static const deftExplorerLanguageCount = 2;
  static const druidicWarriorCantripCount = 2;

  static const Map<int, int> _expertiseSelectionCounts = {
    2: 1,
    9: 2,
  };

  static const List<String> languageOptions = [
    'Common',
    'Common Sign Language',
    'Dwarvish',
    'Elvish',
    'Giant',
    'Gnomish',
    'Goblin',
    'Halfling',
    'Orc',
    'Abyssal',
    'Celestial',
    'Deep Speech',
    'Draconic',
    'Infernal',
    'Primordial',
    'Sylvan',
    'Undercommon',
  ];

  static const List<String> fightingStyleOptions = [
    'Archery',
    'Blind Fighting',
    'Defense',
    'Dueling',
    'Great Weapon Fighting',
    'Interception',
    'Protection',
    'Thrown Weapon Fighting',
    'Two-Weapon Fighting',
    'Unarmed Fighting',
    'Druidic Warrior',
  ];

  static const List<String> feyGlamourSkillOptions = [
    'deception',
    'performance',
    'persuasion',
  ];

  static List<DndWeapon> get weaponMasteryOptions {
    return kDndWeapons.toList();
  }

  static bool isRanger({required String className}) {
    return className.trim().toLowerCase() == 'ranger';
  }

  static bool isRangerChoiceEntry(String entry) {
    return entry.startsWith(expertiseEntryPrefix) ||
        entry.startsWith(languageEntryPrefix) ||
        entry.startsWith(fightingStyleEntryPrefix) ||
        entry.startsWith(weaponMasteryEntryPrefix) ||
        entry.startsWith(druidicWarriorCantripPrefix) ||
        isRangerSubclassChoiceEntry(entry);
  }

  static bool isRangerSubclassChoiceEntry(String entry) {
    return entry.startsWith(feyGlamourSkillEntryPrefix);
  }

  static bool isBeastMaster({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isRanger(className: className) &&
        subclass.trim().toLowerCase() == beastMasterSubclass &&
        level >= 3;
  }

  static bool isFeyWanderer({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isRanger(className: className) &&
        subclass.trim().toLowerCase() == feyWandererSubclass &&
        level >= 3;
  }

  static bool isGloomStalker({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isRanger(className: className) &&
        subclass.trim().toLowerCase() == gloomStalkerSubclass &&
        level >= 3;
  }

  static bool isHunter({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isRanger(className: className) &&
        subclass.trim().toLowerCase() == hunterSubclass &&
        level >= 3;
  }

  static bool isWinterWalker({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isRanger(className: className) &&
        subclass.trim().toLowerCase() == winterWalkerSubclass &&
        level >= 3;
  }

  static bool needsFeyGlamourSkill({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isFeyWanderer(
      className: className,
      subclass: subclass,
      level: level,
    );
  }

  static bool needsWeaponMastery({
    required String className,
    required int level,
  }) {
    return isRanger(className: className) && level >= 1;
  }

  static bool needsFightingStyle({
    required String className,
    required int level,
  }) {
    return isRanger(className: className) && level >= 2;
  }

  static bool needsDeftExplorer({
    required String className,
    required int level,
  }) {
    return isRanger(className: className) && level >= 2;
  }

  static bool needsDruidicWarriorCantrips({
    required String className,
    required int level,
    required Iterable<String> entries,
  }) {
    return needsFightingStyle(className: className, level: level) &&
        selectedFightingStyle(entries) == 'Druidic Warrior';
  }

  static List<int> unlockedExpertiseLevels(int characterLevel) {
    return _expertiseSelectionCounts.keys
        .where((level) => characterLevel >= level)
        .toList()
      ..sort();
  }

  static int requiredExpertiseSelectionsForLevel(int rangerLevel) {
    return _expertiseSelectionCounts[rangerLevel] ?? 0;
  }

  static List<String> selectedExpertiseSkills(
    Iterable<String> entries, {
    required int rangerLevel,
  }) {
    final prefix = '$expertiseEntryPrefix$rangerLevel:';

    return entries
        .where((entry) => entry.startsWith(prefix))
        .map((entry) => entry.substring(prefix.length).trim())
        .where((skill) => skill.isNotEmpty)
        .toList();
  }

  static List<String> allSelectedExpertiseSkills(
    Iterable<String> entries, {
    required int upToCharacterLevel,
  }) {
    final selected = <String>[];

    for (final rangerLevel in unlockedExpertiseLevels(upToCharacterLevel)) {
      selected.addAll(
        selectedExpertiseSkills(entries, rangerLevel: rangerLevel),
      );
    }

    return selected;
  }

  static List<String> selectedLanguages(Iterable<String> entries) {
    final languages = <String>[];
    for (final entry in entries) {
      if (!entry.startsWith(languageEntryPrefix)) continue;
      final value = entry.replaceFirst(languageEntryPrefix, '').trim();
      if (value.isEmpty || languages.contains(value)) continue;
      languages.add(value);
    }
    return languages;
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
      final canonical = _canonicalWeaponName(value);
      if (canonical == null || weapons.contains(canonical)) continue;
      weapons.add(canonical);
    }
    return weapons;
  }

  static bool isWeaponMasteryWeaponName(String weaponName) {
    return _canonicalWeaponName(weaponName) != null;
  }

  static List<String> selectedDruidicWarriorCantrips(Iterable<String> entries) {
    final cantrips = <String>[];
    for (final entry in entries) {
      if (!entry.startsWith(druidicWarriorCantripPrefix)) continue;
      final value = entry.replaceFirst(druidicWarriorCantripPrefix, '').trim();
      if (value.isEmpty || cantrips.contains(value)) continue;
      cantrips.add(value);
    }
    return cantrips;
  }

  static String? selectedFeyGlamourSkill(Iterable<String> entries) {
    for (final entry in entries.toList().reversed) {
      if (!entry.startsWith(feyGlamourSkillEntryPrefix)) continue;
      final value = entry.replaceFirst(feyGlamourSkillEntryPrefix, '').trim();
      if (feyGlamourSkillOptions.contains(value)) return value;
    }
    return null;
  }

  static Iterable<String> preservedEntriesForLevel(
    Iterable<String> entries, {
    required int characterLevel,
    String subclass = '',
  }) {
    final allowedExpertiseLevels =
        unlockedExpertiseLevels(characterLevel).toSet();
    final hasFightingStyle = characterLevel >= 2;
    final normalizedSubclass = subclass.trim().toLowerCase();
    var weaponMasteries = 0;
    final seenWeapons = <String>{};
    var keptFeyGlamourSkill = false;

    return entries.where((entry) {
      if (!isRangerChoiceEntry(entry)) return false;

      if (entry.startsWith(feyGlamourSkillEntryPrefix)) {
        final skill = entry.replaceFirst(feyGlamourSkillEntryPrefix, '').trim();
        if (characterLevel < 3 ||
            normalizedSubclass != feyWandererSubclass ||
            keptFeyGlamourSkill ||
            !feyGlamourSkillOptions.contains(skill)) {
          return false;
        }
        keptFeyGlamourSkill = true;
        return true;
      }

      if (entry.startsWith(expertiseEntryPrefix)) {
        final parts = entry.split(':');
        if (parts.length < 4) return false;
        final rangerLevel = int.tryParse(parts[2]);
        return rangerLevel != null &&
            allowedExpertiseLevels.contains(rangerLevel);
      }

      if (entry.startsWith(languageEntryPrefix)) {
        return characterLevel >= 2;
      }

      if (entry.startsWith(fightingStyleEntryPrefix)) {
        return hasFightingStyle;
      }

      if (entry.startsWith(druidicWarriorCantripPrefix)) {
        return hasFightingStyle;
      }

      if (entry.startsWith(weaponMasteryEntryPrefix)) {
        if (characterLevel < 1 ||
            weaponMasteries >= weaponMasterySelectionCount) {
          return false;
        }
        final weapon = entry.replaceFirst(weaponMasteryEntryPrefix, '').trim();
        final canonical = _canonicalWeaponName(weapon);
        if (canonical == null || seenWeapons.contains(canonical)) return false;
        seenWeapons.add(canonical);
        weaponMasteries++;
        return true;
      }

      return false;
    });
  }

  static String expertiseLabel(String skillIndex) {
    return 'Expertise: ${skillLabel(skillIndex)}';
  }

  static String fightingStyleLabel(String style) {
    return 'Fighting Style: $style';
  }

  static String weaponMasteryLabel(List<String> weapons) {
    return 'Weapon Mastery: ${weapons.join(', ')}';
  }

  static String feyGlamourSkillLabel(String skillIndex) {
    return 'Otherworldly Glamour: ${skillLabel(skillIndex)}';
  }

  static int spellSaveDc({required int level, required int wisdom}) {
    return 8 +
        DiceCalculator.getProficiencyBonus(level) +
        DiceCalculator.getModifier(wisdom);
  }

  static int wisdomMinimumOne(int wisdom) {
    return DiceCalculator.getModifier(wisdom).clamp(1, 99).toInt();
  }

  static int otherworldlyGlamourSkillBonus({
    required String className,
    required String subclass,
    required int level,
    required int wisdom,
    required String ability,
  }) {
    if (!isFeyWanderer(
      className: className,
      subclass: subclass,
      level: level,
    )) {
      return 0;
    }
    return ability == 'cha' ? wisdomMinimumOne(wisdom) : 0;
  }

  static String dreadfulStrikesDie(int level) {
    return level >= 11 ? '1d6' : '1d4';
  }

  static String dreadAmbusherDamageDie(int level) {
    return level >= 11 ? '2d8' : '2d6';
  }

  static int gloomStalkerInitiativeBonus({
    required String className,
    required String subclass,
    required int level,
    required int wisdom,
  }) {
    if (!isGloomStalker(
      className: className,
      subclass: subclass,
      level: level,
    )) {
      return 0;
    }
    return DiceCalculator.getModifier(wisdom);
  }

  static int huntersRimeTemporaryHp(int level) {
    return level >= 3 ? level : 0;
  }

  static String? _canonicalWeaponName(String weaponName) {
    final wanted = weaponName.trim().toLowerCase();
    for (final weapon in weaponMasteryOptions) {
      if (weapon.name.toLowerCase() == wanted) return weapon.name;
    }
    return null;
  }

  static String skillLabel(String skillIndex) {
    return skillIndex
        .split('-')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  static List<SpellDto> filterDruidicWarriorCantrips({
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
