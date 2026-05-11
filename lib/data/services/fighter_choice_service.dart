import '../local/choice_lists_data.dart';
import '../local/weapons_data.dart';
import '../remote/spell_dto.dart';

class BattleMasterManeuverOption {
  final String id;
  final String label;
  final String summary;

  const BattleMasterManeuverOption({
    required this.id,
    required this.label,
    required this.summary,
  });
}

class FighterChoiceService {
  FighterChoiceService._();

  static const _legacyFightingStyleEntryPrefix =
      'class_choice:fighter_fighting_style:';
  static const weaponMasteryEntryPrefix =
      'class_choice:fighter_weapon_mastery:';
  static const eldritchKnightCantripEntryPrefix =
      'class_choice:fighter_eldritch_knight_cantrip:';
  static const eldritchKnightSpellEntryPrefix =
      'class_choice:fighter_eldritch_knight_spell:';
  static const battleMasterManeuverEntryPrefix =
      'class_choice:fighter_battle_master_maneuver:';
  static const battleMasterStudentSkillEntryPrefix =
      'class_choice:fighter_battle_master_student_skill:';
  static const battleMasterStudentToolEntryPrefix =
      'class_choice:fighter_battle_master_student_tool:';
  static const _genericBattleMasterSummary =
      'Add a Superiority Die to an attack roll.';

  static const eldritchKnightSubclass = 'fighter-eldritch-knight';
  static const battleMasterSubclass = 'fighter-battle-master';
  static const psiWarriorSubclass = 'fighter-psi-warrior';

  static const Map<int, int> _eldritchKnightPreparedSpells = {
    3: 3,
    4: 4,
    5: 4,
    6: 4,
    7: 5,
    8: 6,
    9: 6,
    10: 7,
    11: 8,
    12: 8,
    13: 9,
    14: 10,
    15: 10,
    16: 11,
    17: 11,
    18: 11,
    19: 12,
    20: 13,
  };

  static const Map<int, Map<int, int>> _eldritchKnightSpellSlots = {
    3: {1: 2},
    4: {1: 3},
    5: {1: 3},
    6: {1: 3},
    7: {1: 4, 2: 2},
    8: {1: 4, 2: 2},
    9: {1: 4, 2: 2},
    10: {1: 4, 2: 3},
    11: {1: 4, 2: 3},
    12: {1: 4, 2: 3},
    13: {1: 4, 2: 3, 3: 2},
    14: {1: 4, 2: 3, 3: 2},
    15: {1: 4, 2: 3, 3: 2},
    16: {1: 4, 2: 3, 3: 3},
    17: {1: 4, 2: 3, 3: 3},
    18: {1: 4, 2: 3, 3: 3},
    19: {1: 4, 2: 3, 3: 3, 4: 1},
    20: {1: 4, 2: 3, 3: 3, 4: 1},
  };

  static const List<String> studentOfWarSkillOptions = [
    'acrobatics',
    'animal-handling',
    'athletics',
    'history',
    'insight',
    'intimidation',
    'perception',
    'persuasion',
    'survival',
  ];

  static const List<String> artisanToolOptions = [
    "Alchemist's Supplies",
    "Brewer's Supplies",
    "Calligrapher's Supplies",
    "Carpenter's Tools",
    "Cartographer's Tools",
    "Cobbler's Tools",
    "Cook's Utensils",
    "Glassblower's Tools",
    "Jeweler's Tools",
    "Leatherworker's Tools",
    "Mason's Tools",
    "Painter's Supplies",
    "Potter's Tools",
    "Smith's Tools",
    "Tinker's Tools",
    "Weaver's Tools",
    "Woodcarver's Tools",
  ];

  static List<BattleMasterManeuverOption> get maneuverOptions {
    try {
      final loaded = ChoiceListsData.battleMasterManeuvers;
      if (loaded.isNotEmpty) {
        return loaded.map((entry) {
          final fallback = _fallbackManeuverById(entry.id);
          return BattleMasterManeuverOption(
            id: entry.id,
            label: entry.name,
            summary: _maneuverSummary(
              entry.summary,
              fallback: fallback?.summary ?? '',
            ),
          );
        }).toList(growable: false);
      }
    } catch (_) {
      // Keep static fallback usable before LocalDataLoader finishes.
    }

    return _fallbackManeuverOptions;
  }

  static const List<BattleMasterManeuverOption> _fallbackManeuverOptions = [
    BattleMasterManeuverOption(
      id: 'ambush',
      label: 'Ambush',
      summary: 'Add a Superiority Die to Stealth or Initiative.',
    ),
    BattleMasterManeuverOption(
      id: 'bait_and_switch',
      label: 'Bait and Switch',
      summary: 'Swap places with a willing creature and boost AC.',
    ),
    BattleMasterManeuverOption(
      id: 'commanders_strike',
      label: "Commander's Strike",
      summary: 'Direct a willing creature to attack using its Reaction.',
    ),
    BattleMasterManeuverOption(
      id: 'commanding_presence',
      label: 'Commanding Presence',
      summary:
          'Add a Superiority Die to Intimidation, Performance, or Persuasion.',
    ),
    BattleMasterManeuverOption(
      id: 'disarming_attack',
      label: 'Disarming Attack',
      summary: 'Add damage and try to make the target drop an object.',
    ),
    BattleMasterManeuverOption(
      id: 'distracting_strike',
      label: 'Distracting Strike',
      summary: "Add damage and give the next ally's attack Advantage.",
    ),
    BattleMasterManeuverOption(
      id: 'evasive_footwork',
      label: 'Evasive Footwork',
      summary: 'Disengage as a Bonus Action and add the die to your AC.',
    ),
    BattleMasterManeuverOption(
      id: 'feinting_attack',
      label: 'Feinting Attack',
      summary:
          'Gain Advantage against a nearby target and add damage on a hit.',
    ),
    BattleMasterManeuverOption(
      id: 'goading_attack',
      label: 'Goading Attack',
      summary: 'Add damage and pressure the target to attack you.',
    ),
    BattleMasterManeuverOption(
      id: 'lunging_attack',
      label: 'Lunging Attack',
      summary:
          'Dash as a Bonus Action and add damage after a straight-line melee hit.',
    ),
    BattleMasterManeuverOption(
      id: 'maneuvering_attack',
      label: 'Maneuvering Attack',
      summary: 'Add damage and let an ally move safely.',
    ),
    BattleMasterManeuverOption(
      id: 'menacing_attack',
      label: 'Menacing Attack',
      summary: 'Add damage and try to Frighten the target.',
    ),
    BattleMasterManeuverOption(
      id: 'parry',
      label: 'Parry',
      summary: 'Use a Reaction to reduce melee attack damage.',
    ),
    BattleMasterManeuverOption(
      id: 'precision_attack',
      label: 'Precision Attack',
      summary: 'Add a Superiority Die to a missed attack roll.',
    ),
    BattleMasterManeuverOption(
      id: 'pushing_attack',
      label: 'Pushing Attack',
      summary: 'Add damage and try to push the target.',
    ),
    BattleMasterManeuverOption(
      id: 'rally',
      label: 'Rally',
      summary: 'Grant Temporary Hit Points to an ally.',
    ),
    BattleMasterManeuverOption(
      id: 'riposte',
      label: 'Riposte',
      summary: 'Make a Reaction attack after a creature misses you.',
    ),
    BattleMasterManeuverOption(
      id: 'sweeping_attack',
      label: 'Sweeping Attack',
      summary: 'Damage a second nearby creature after a hit.',
    ),
    BattleMasterManeuverOption(
      id: 'tactical_assessment',
      label: 'Tactical Assessment',
      summary: 'Add a Superiority Die to History, Investigation, or Insight.',
    ),
    BattleMasterManeuverOption(
      id: 'trip_attack',
      label: 'Trip Attack',
      summary: 'Add damage and try to knock the target Prone.',
    ),
  ];

  static List<DndWeapon> get weaponMasteryOptions {
    return kDndWeapons.toList();
  }

  static bool isFighter({required String className}) {
    return className.trim().toLowerCase() == 'fighter';
  }

  static bool isFighterChoiceEntry(String entry) {
    return entry.startsWith(_legacyFightingStyleEntryPrefix) ||
        entry.startsWith(weaponMasteryEntryPrefix) ||
        isFighterSubclassChoiceEntry(entry);
  }

  static bool isFighterSubclassChoiceEntry(String entry) {
    return entry.startsWith(eldritchKnightCantripEntryPrefix) ||
        entry.startsWith(eldritchKnightSpellEntryPrefix) ||
        entry.startsWith(battleMasterManeuverEntryPrefix) ||
        entry.startsWith(battleMasterStudentSkillEntryPrefix) ||
        entry.startsWith(battleMasterStudentToolEntryPrefix);
  }

  static bool isEldritchKnight({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isFighter(className: className) &&
        subclass.trim().toLowerCase() == eldritchKnightSubclass &&
        level >= 3;
  }

  static bool isBattleMaster({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isFighter(className: className) &&
        subclass.trim().toLowerCase() == battleMasterSubclass &&
        level >= 3;
  }

  static bool isPsiWarrior({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isFighter(className: className) &&
        subclass.trim().toLowerCase() == psiWarriorSubclass &&
        level >= 3;
  }

  static bool needsWeaponMastery({
    required String className,
    required int level,
  }) {
    return isFighter(className: className) && level >= 1;
  }

  static int weaponMasterySelectionCountForLevel(int level) {
    if (level >= 16) return 6;
    if (level >= 10) return 5;
    if (level >= 4) return 4;
    return 3;
  }

  static int eldritchKnightCantripCount(int fighterLevel) {
    if (fighterLevel >= 10) return 3;
    if (fighterLevel >= 3) return 2;
    return 0;
  }

  static int eldritchKnightPreparedSpellCount(int fighterLevel) {
    return _eldritchKnightPreparedSpells[fighterLevel] ?? 0;
  }

  static Map<int, int> eldritchKnightSpellSlots(int fighterLevel) {
    return _eldritchKnightSpellSlots[fighterLevel] ?? const {};
  }

  static List<int> eldritchKnightSpellSlotsListFor(int fighterLevel) {
    final slots = eldritchKnightSpellSlots(fighterLevel);
    final values = List<int>.filled(9, 0);
    for (final entry in slots.entries) {
      final index = entry.key - 1;
      if (index >= 0 && index < values.length) {
        values[index] = entry.value;
      }
    }
    return values;
  }

  static int eldritchKnightMaxSpellLevel(int fighterLevel) {
    final slots = eldritchKnightSpellSlots(fighterLevel);
    if (slots.isEmpty) return 0;
    final levels = slots.keys.toList()..sort();
    return levels.last;
  }

  static int battleMasterManeuverCountForLevel(int fighterLevel) {
    if (fighterLevel >= 15) return 9;
    if (fighterLevel >= 10) return 7;
    if (fighterLevel >= 7) return 5;
    if (fighterLevel >= 3) return 3;
    return 0;
  }

  static List<String> selectedEldritchKnightCantrips(
    Iterable<String> entries,
  ) {
    return _selectedByPrefix(entries, eldritchKnightCantripEntryPrefix);
  }

  static List<String> selectedEldritchKnightSpells(
    Iterable<String> entries,
  ) {
    return _selectedByPrefix(entries, eldritchKnightSpellEntryPrefix);
  }

  static List<String> eldritchKnightSpellIds({
    required String className,
    required String subclass,
    required int level,
    required Iterable<String> entries,
  }) {
    if (!isEldritchKnight(
      className: className,
      subclass: subclass,
      level: level,
    )) {
      return const <String>[];
    }

    return <String>{
      ...selectedEldritchKnightCantrips(entries),
      ...selectedEldritchKnightSpells(entries),
    }.toList();
  }

  static List<SpellDto> filterEldritchKnightCantrips({
    required List<SpellDto> spells,
    required Set<String> knownSpellIds,
  }) {
    final options = spells
        .where(
            (spell) => spell.level == 0 && !knownSpellIds.contains(spell.index))
        .toList();
    options.sort((a, b) => a.name.compareTo(b.name));
    return options;
  }

  static List<SpellDto> filterEldritchKnightPreparedSpells({
    required List<SpellDto> spells,
    required int maxSpellLevel,
    required Set<String> knownSpellIds,
  }) {
    final options = spells
        .where((spell) =>
            spell.level > 0 &&
            spell.level <= maxSpellLevel &&
            !knownSpellIds.contains(spell.index))
        .toList();
    options.sort((a, b) => a.level == b.level
        ? a.name.compareTo(b.name)
        : a.level.compareTo(b.level));
    return options;
  }

  static List<String> selectedBattleMasterManeuvers(
    Iterable<String> entries, {
    int? characterLevel,
  }) {
    final maxSelections = characterLevel == null
        ? null
        : battleMasterManeuverCountForLevel(characterLevel);
    final maneuvers = <String>[];
    for (final entry in entries) {
      if (!entry.startsWith(battleMasterManeuverEntryPrefix)) continue;
      final value =
          entry.replaceFirst(battleMasterManeuverEntryPrefix, '').trim();
      if (!isBattleMasterManeuverId(value) || maneuvers.contains(value)) {
        continue;
      }
      maneuvers.add(value);
      if (maxSelections != null && maneuvers.length >= maxSelections) {
        break;
      }
    }
    return maneuvers;
  }

  static bool isBattleMasterManeuverId(String id) {
    return maneuverOptions.any((option) => option.id == id.trim());
  }

  static String battleMasterManeuverLabel(String id) {
    return maneuverOptions
        .firstWhere(
          (option) => option.id == id,
          orElse: () => BattleMasterManeuverOption(
            id: id,
            label: id,
            summary: id,
          ),
        )
        .label;
  }

  static String battleMasterManeuverSummary(String id) {
    return maneuverOptions
        .firstWhere(
          (option) => option.id == id,
          orElse: () => BattleMasterManeuverOption(
            id: id,
            label: id,
            summary: id,
          ),
        )
        .summary;
  }

  static String? selectedBattleMasterStudentSkill(Iterable<String> entries) {
    for (final entry in entries.toList().reversed) {
      if (!entry.startsWith(battleMasterStudentSkillEntryPrefix)) continue;
      final value =
          entry.replaceFirst(battleMasterStudentSkillEntryPrefix, '').trim();
      if (studentOfWarSkillOptions.contains(value)) return value;
    }
    return null;
  }

  static String? selectedBattleMasterStudentTool(Iterable<String> entries) {
    for (final entry in entries.toList().reversed) {
      if (!entry.startsWith(battleMasterStudentToolEntryPrefix)) continue;
      final value =
          entry.replaceFirst(battleMasterStudentToolEntryPrefix, '').trim();
      if (artisanToolOptions.contains(value)) return value;
    }
    return null;
  }

  static String battleMasterManeuverChoiceLabel(List<String> maneuvers) {
    return 'Battle Master Maneuvers: ${maneuvers.map(battleMasterManeuverLabel).join(', ')}';
  }

  static String battleMasterSuperiorityDice(int fighterLevel) {
    final die = fighterLevel >= 18
        ? 'd12'
        : fighterLevel >= 10
            ? 'd10'
            : 'd8';
    final dice = fighterLevel >= 15
        ? 6
        : fighterLevel >= 7
            ? 5
            : 4;
    return '$dice $die dice';
  }

  static String psiWarriorPsionicEnergyDice(int fighterLevel) {
    if (fighterLevel >= 17) return '1d12 / 12 dice';
    if (fighterLevel >= 13) return '1d10 / 10 dice';
    if (fighterLevel >= 11) return '1d10 / 8 dice';
    if (fighterLevel >= 9) return '1d8 / 8 dice';
    if (fighterLevel >= 5) return '1d8 / 6 dice';
    return '1d6 / 4 dice';
  }

  static List<String> psiWarriorGrantedSpellIds({
    required String className,
    required String subclass,
    required int level,
  }) {
    if (isPsiWarrior(className: className, subclass: subclass, level: level) &&
        level >= 18) {
      return const ['telekinesis'];
    }
    return const <String>[];
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

  static bool isWeaponMasteryWeaponName(String weaponName) {
    return _canonicalWeaponName(weaponName) != null;
  }

  static Iterable<String> preservedEntriesForLevel(
    Iterable<String> entries, {
    required int characterLevel,
  }) {
    final preserved = <String>[];
    final maxWeaponMasteries =
        weaponMasterySelectionCountForLevel(characterLevel);
    var weaponMasteries = 0;
    final seenWeapons = <String>{};

    for (final entry in entries) {
      if (!entry.startsWith(weaponMasteryEntryPrefix)) continue;
      if (characterLevel < 1 || weaponMasteries >= maxWeaponMasteries) {
        continue;
      }
      final weapon = entry.replaceFirst(weaponMasteryEntryPrefix, '').trim();
      final canonical = _canonicalWeaponName(weapon);
      if (canonical == null || seenWeapons.contains(canonical)) continue;
      seenWeapons.add(canonical);
      preserved.add('$weaponMasteryEntryPrefix$canonical');
      weaponMasteries++;
    }

    final cantripLimit = eldritchKnightCantripCount(characterLevel);
    var cantrips = 0;
    for (final entry in entries) {
      if (!entry.startsWith(eldritchKnightCantripEntryPrefix)) continue;
      if (cantrips >= cantripLimit) break;
      final value = entry.replaceFirst(eldritchKnightCantripEntryPrefix, '');
      if (value.trim().isEmpty) continue;
      preserved.add(entry);
      cantrips++;
    }

    final spellLimit = eldritchKnightPreparedSpellCount(characterLevel);
    var spells = 0;
    for (final entry in entries) {
      if (!entry.startsWith(eldritchKnightSpellEntryPrefix)) continue;
      if (spells >= spellLimit) break;
      final value = entry.replaceFirst(eldritchKnightSpellEntryPrefix, '');
      if (value.trim().isEmpty) continue;
      preserved.add(entry);
      spells++;
    }

    final maneuverLimit = battleMasterManeuverCountForLevel(characterLevel);
    final seenManeuvers = <String>{};
    for (final entry in entries) {
      if (!entry.startsWith(battleMasterManeuverEntryPrefix)) continue;
      if (seenManeuvers.length >= maneuverLimit) break;
      final value =
          entry.replaceFirst(battleMasterManeuverEntryPrefix, '').trim();
      if (!isBattleMasterManeuverId(value) || seenManeuvers.contains(value)) {
        continue;
      }
      seenManeuvers.add(value);
      preserved.add('$battleMasterManeuverEntryPrefix$value');
    }

    if (characterLevel >= 3) {
      final skill = selectedBattleMasterStudentSkill(entries);
      if (skill != null) {
        preserved.add('$battleMasterStudentSkillEntryPrefix$skill');
      }
      final tool = selectedBattleMasterStudentTool(entries);
      if (tool != null) {
        preserved.add('$battleMasterStudentToolEntryPrefix$tool');
      }
    }

    return preserved;
  }

  static String weaponMasteryLabel(List<String> weapons) {
    return 'Weapon Mastery: ${weapons.join(', ')}';
  }

  static String skillLabel(String skillIndex) {
    return skillIndex
        .split('-')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  static String spellLabel(String spellIndex) {
    return spellIndex
        .split('-')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  static BattleMasterManeuverOption? _fallbackManeuverById(String id) {
    final normalized = id.trim();
    for (final option in _fallbackManeuverOptions) {
      if (option.id == normalized) return option;
    }
    return null;
  }

  static String _maneuverSummary(String summary, {required String fallback}) {
    final trimmed = summary.trim();
    if (trimmed.isEmpty || trimmed == _genericBattleMasterSummary) {
      return fallback.isEmpty ? trimmed : fallback;
    }
    return trimmed;
  }

  static String? _canonicalWeaponName(String weaponName) {
    final wanted = weaponName.trim().toLowerCase();
    for (final weapon in weaponMasteryOptions) {
      if (weapon.name.toLowerCase() == wanted) return weapon.name;
    }
    return null;
  }

  static List<String> _selectedByPrefix(
    Iterable<String> entries,
    String prefix,
  ) {
    final selected = <String>[];
    for (final entry in entries) {
      if (!entry.startsWith(prefix)) continue;
      final value = entry.replaceFirst(prefix, '').trim();
      if (value.isEmpty || selected.contains(value)) continue;
      selected.add(value);
    }
    return selected;
  }
}
