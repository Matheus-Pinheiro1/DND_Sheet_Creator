import '../local/weapons_data.dart';

class BarbarianChoiceService {
  BarbarianChoiceService._();

  static const weaponMasteryEntryPrefix =
      'class_choice:barbarian_weapon_mastery:';
  static const primalKnowledgeSkillEntryPrefix =
      'class_choice:barbarian_primal_knowledge_skill:';

  static const berserkerSubclass = 'barbarian-berserker';
  static const wildHeartSubclass = 'barbarian-wild-heart';
  static const worldTreeSubclass = 'barbarian-world-tree';
  static const zealotSubclass = 'barbarian-zealot';

  static const weaponMasterySelectionCount = 2;

  static const List<String> skillOptions = [
    'animal-handling',
    'athletics',
    'intimidation',
    'nature',
    'perception',
    'survival',
  ];

  static List<DndWeapon> get weaponMasteryOptions {
    return kDndWeapons.where(isWeaponMasteryOption).toList();
  }

  static bool isBarbarian({required String className}) {
    return className.trim().toLowerCase() == 'barbarian';
  }

  static bool isBerserker({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isBarbarian(className: className) &&
        subclass.trim().toLowerCase() == berserkerSubclass &&
        level >= 3;
  }

  static bool isWildHeart({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isBarbarian(className: className) &&
        subclass.trim().toLowerCase() == wildHeartSubclass &&
        level >= 3;
  }

  static bool isWorldTree({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isBarbarian(className: className) &&
        subclass.trim().toLowerCase() == worldTreeSubclass &&
        level >= 3;
  }

  static bool isZealot({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isBarbarian(className: className) &&
        subclass.trim().toLowerCase() == zealotSubclass &&
        level >= 3;
  }

  static bool isBarbarianChoiceEntry(String entry) {
    return entry.startsWith(weaponMasteryEntryPrefix) ||
        entry.startsWith(primalKnowledgeSkillEntryPrefix);
  }

  static bool isWeaponMasteryOption(DndWeapon weapon) {
    final name = weapon.name.trim().toLowerCase();
    final properties = weapon.properties.toLowerCase();

    return !properties.contains('ammunition') &&
        name != 'dart' &&
        name != 'net';
  }

  static bool isWeaponMasteryWeaponName(String weaponName) {
    return _canonicalWeaponName(weaponName) != null;
  }

  static String? _canonicalWeaponName(String weaponName) {
    final wanted = weaponName.trim().toLowerCase();
    for (final weapon in weaponMasteryOptions) {
      if (weapon.name.toLowerCase() == wanted) return weapon.name;
    }
    return null;
  }

  static bool needsWeaponMastery({
    required String className,
    required int level,
  }) {
    return isBarbarian(className: className) && level >= 1;
  }

  static bool needsPrimalKnowledge({
    required String className,
    required int level,
  }) {
    return isBarbarian(className: className) && level >= 3;
  }

  static int weaponMasterySelectionCountForLevel(int level) {
    if (level >= 10) return 4;
    if (level >= 4) return 3;
    return weaponMasterySelectionCount;
  }

  static int rageDamageBonus(int barbarianLevel) {
    if (barbarianLevel >= 16) return 4;
    if (barbarianLevel >= 9) return 3;
    return 2;
  }

  static String berserkerFrenzyDamage(int barbarianLevel) {
    return '${rageDamageBonus(barbarianLevel)}d6';
  }

  static String worldTreeLifeGivingForceDice(int barbarianLevel) {
    return '${rageDamageBonus(barbarianLevel)}d6';
  }

  static String zealotDivineFuryDamage(int barbarianLevel) {
    return '1d6 + ${barbarianLevel ~/ 2}';
  }

  static int zealotWarriorOfTheGodsDice(int barbarianLevel) {
    if (barbarianLevel >= 17) return 7;
    if (barbarianLevel >= 12) return 6;
    if (barbarianLevel >= 6) return 5;
    return 4;
  }

  static List<String> wildHeartGrantedSpellIds({
    required String className,
    required String subclass,
    required int level,
  }) {
    if (!isWildHeart(
      className: className,
      subclass: subclass,
      level: level,
    )) {
      return const <String>[];
    }
    return [
      'beast-sense',
      'speak-with-animals',
      if (level >= 10) 'commune-with-nature',
    ];
  }

  static List<String> selectedWeaponMasteries(
    Iterable<String> entries, {
    int? characterLevel,
  }) {
    final maxSelections = characterLevel == null
        ? null
        : weaponMasterySelectionCountForLevel(characterLevel);
    final weapons = <String>[];
    for (final entry in entries) {
      if (!entry.startsWith(weaponMasteryEntryPrefix)) continue;
      final value = entry.replaceFirst(weaponMasteryEntryPrefix, '').trim();
      final canonical = _canonicalWeaponName(value);
      if (canonical == null || weapons.contains(canonical)) continue;
      weapons.add(canonical);
      if (maxSelections != null && weapons.length >= maxSelections) {
        break;
      }
    }
    return weapons;
  }

  static String? selectedPrimalKnowledgeSkill(Iterable<String> entries) {
    for (final entry in entries.toList().reversed) {
      if (!entry.startsWith(primalKnowledgeSkillEntryPrefix)) continue;
      final value =
          entry.replaceFirst(primalKnowledgeSkillEntryPrefix, '').trim();
      if (value.isNotEmpty && skillOptions.contains(value)) return value;
    }
    return null;
  }

  static Iterable<String> preservedEntriesForLevel(
    Iterable<String> entries, {
    required int characterLevel,
  }) {
    final maxWeaponMasteries =
        weaponMasterySelectionCountForLevel(characterLevel);
    var weaponMasteries = 0;
    final seenWeapons = <String>{};

    return entries.where((entry) {
      if (!isBarbarianChoiceEntry(entry)) return false;

      if (entry.startsWith(weaponMasteryEntryPrefix)) {
        if (characterLevel < 1 || weaponMasteries >= maxWeaponMasteries) {
          return false;
        }
        final weapon = entry.replaceFirst(weaponMasteryEntryPrefix, '').trim();
        final canonical = _canonicalWeaponName(weapon);
        if (canonical == null || seenWeapons.contains(canonical)) return false;
        seenWeapons.add(canonical);
        weaponMasteries++;
        return true;
      }

      if (entry.startsWith(primalKnowledgeSkillEntryPrefix)) {
        final skill =
            entry.replaceFirst(primalKnowledgeSkillEntryPrefix, '').trim();
        return characterLevel >= 3 && skillOptions.contains(skill);
      }

      return false;
    });
  }

  static String weaponMasteryLabel(List<String> weapons) {
    return 'Weapon Mastery: ${weapons.join(', ')}';
  }

  static String primalKnowledgeSkillLabel(String skillIndex) {
    return 'Primal Knowledge: ${skillLabel(skillIndex)}';
  }

  static String skillLabel(String skillIndex) {
    return skillIndex
        .split('-')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}
