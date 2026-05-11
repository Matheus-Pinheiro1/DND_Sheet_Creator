import '../remote/spell_dto.dart';

class RogueChoiceService {
  RogueChoiceService._();

  static const expertiseEntryPrefix = 'class_choice:rogue_expertise:';
  static const arcaneTricksterCantripEntryPrefix =
      'class_choice:rogue_arcane_trickster_cantrip:';
  static const arcaneTricksterSpellEntryPrefix =
      'class_choice:rogue_arcane_trickster_spell:';
  static const scionDreadAllegianceEntryPrefix =
      'class_choice:rogue_scion_dread_allegiance:';

  static const arcaneTricksterSubclass = 'rogue-arcane-trickster';
  static const assassinSubclass = 'rogue-assassin';
  static const soulknifeSubclass = 'rogue-soulknife';
  static const scionSubclass = 'rogue-scion-of-the-three';

  static const mageHandSpellId = 'mage-hand';

  static const Map<int, int> _expertiseSelectionCounts = {
    1: 2,
    6: 2,
  };

  static const Map<int, int> _arcaneTricksterPreparedSpells = {
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

  static const Map<int, Map<int, int>> _arcaneTricksterSpellSlots = {
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

  static const Map<String, _ScionDreadAllegiance> _scionAllegiances = {
    'bane': _ScionDreadAllegiance(
      label: 'Bane',
      resistance: 'Psychic',
      cantrip: 'minor-illusion',
    ),
    'bhaal': _ScionDreadAllegiance(
      label: 'Bhaal',
      resistance: 'Poison',
      cantrip: 'blade-ward',
    ),
    'myrkul': _ScionDreadAllegiance(
      label: 'Myrkul',
      resistance: 'Necrotic',
      cantrip: 'chill-touch',
    ),
  };

  static bool isRogueChoiceEntry(String entry) {
    return entry.startsWith(expertiseEntryPrefix) ||
        isRogueSubclassChoiceEntry(entry);
  }

  static bool isRogueSubclassChoiceEntry(String entry) {
    return entry.startsWith(arcaneTricksterCantripEntryPrefix) ||
        entry.startsWith(arcaneTricksterSpellEntryPrefix) ||
        entry.startsWith(scionDreadAllegianceEntryPrefix);
  }

  static bool isArcaneTrickster({
    required String className,
    required String subclass,
    required int level,
  }) {
    return className.trim().toLowerCase() == 'rogue' &&
        subclass.trim().toLowerCase() == arcaneTricksterSubclass &&
        level >= 3;
  }

  static bool isSoulknife({
    required String className,
    required String subclass,
    required int level,
  }) {
    return className.trim().toLowerCase() == 'rogue' &&
        subclass.trim().toLowerCase() == soulknifeSubclass &&
        level >= 3;
  }

  static bool needsScionDreadAllegiance({
    required String className,
    required String subclass,
    required int level,
  }) {
    return className.trim().toLowerCase() == 'rogue' &&
        subclass.trim().toLowerCase() == scionSubclass &&
        level >= 3;
  }

  static List<int> unlockedExpertiseLevels(int characterLevel) {
    return _expertiseSelectionCounts.keys
        .where((level) => characterLevel >= level)
        .toList()
      ..sort();
  }

  static int requiredSelectionsForLevel(int rogueLevel) {
    return _expertiseSelectionCounts[rogueLevel] ?? 0;
  }

  static List<String> selectedExpertiseSkills(
    Iterable<String> entries, {
    required int rogueLevel,
  }) {
    final prefix = '$expertiseEntryPrefix$rogueLevel:';

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

    for (final rogueLevel in unlockedExpertiseLevels(upToCharacterLevel)) {
      selected.addAll(
        selectedExpertiseSkills(entries, rogueLevel: rogueLevel),
      );
    }

    return selected;
  }

  static int arcaneTricksterCantripCount(int rogueLevel) {
    if (rogueLevel >= 10) return 3;
    if (rogueLevel >= 3) return 2;
    return 0;
  }

  static int arcaneTricksterPreparedSpellCount(int rogueLevel) {
    return _arcaneTricksterPreparedSpells[rogueLevel] ?? 0;
  }

  static Map<int, int> arcaneTricksterSpellSlots(int rogueLevel) {
    return _arcaneTricksterSpellSlots[rogueLevel] ?? const {};
  }

  static List<int> arcaneTricksterSpellSlotsListFor(int rogueLevel) {
    final slots = arcaneTricksterSpellSlots(rogueLevel);
    final values = List<int>.filled(9, 0);
    for (final entry in slots.entries) {
      final index = entry.key - 1;
      if (index >= 0 && index < values.length) {
        values[index] = entry.value;
      }
    }
    return values;
  }

  static int arcaneTricksterMaxSpellLevel(int rogueLevel) {
    final slots = arcaneTricksterSpellSlots(rogueLevel);
    if (slots.isEmpty) return 0;
    final levels = slots.keys.toList()..sort();
    return levels.last;
  }

  static List<String> selectedArcaneTricksterCantrips(
    Iterable<String> entries,
  ) {
    return _selectedByPrefix(entries, arcaneTricksterCantripEntryPrefix);
  }

  static List<String> selectedArcaneTricksterSpells(
    Iterable<String> entries,
  ) {
    return _selectedByPrefix(entries, arcaneTricksterSpellEntryPrefix);
  }

  static List<String> arcaneTricksterSpellIds({
    required String className,
    required String subclass,
    required int level,
    required Iterable<String> entries,
  }) {
    if (!isArcaneTrickster(
      className: className,
      subclass: subclass,
      level: level,
    )) {
      return const <String>[];
    }

    return <String>{
      mageHandSpellId,
      ...selectedArcaneTricksterCantrips(entries),
      ...selectedArcaneTricksterSpells(entries),
    }.toList();
  }

  static List<SpellDto> filterArcaneTricksterCantrips({
    required List<SpellDto> spells,
    required Set<String> knownSpellIds,
  }) {
    final options = spells
        .where((spell) =>
            spell.level == 0 &&
            spell.index != mageHandSpellId &&
            !knownSpellIds.contains(spell.index))
        .toList();
    options.sort((a, b) => a.name.compareTo(b.name));
    return options;
  }

  static List<SpellDto> filterArcaneTricksterPreparedSpells({
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

  static bool isScionAllegianceId(String id) {
    return _scionAllegiances.containsKey(id.trim().toLowerCase());
  }

  static List<String> get scionAllegianceIds {
    return _scionAllegiances.keys.toList(growable: false);
  }

  static String? selectedScionDreadAllegiance(Iterable<String> entries) {
    for (final entry in entries) {
      if (!entry.startsWith(scionDreadAllegianceEntryPrefix)) continue;
      final value = entry
          .replaceFirst(scionDreadAllegianceEntryPrefix, '')
          .trim()
          .toLowerCase();
      if (_scionAllegiances.containsKey(value)) return value;
    }
    return null;
  }

  static String? scionDreadAllegianceCantrip(Iterable<String> entries) {
    final selected = selectedScionDreadAllegiance(entries);
    if (selected == null) return null;
    return _scionAllegiances[selected]?.cantrip;
  }

  static String scionDreadAllegianceLabel(String id) {
    return _scionAllegiances[id.trim().toLowerCase()]?.label ?? id;
  }

  static String scionDreadAllegianceSummary(String id) {
    final option = _scionAllegiances[id.trim().toLowerCase()];
    if (option == null) return id;
    return '${option.label}: ${option.resistance} Resistance, ${spellLabel(option.cantrip)}.';
  }

  static String scionDreadAllegianceProficiencyLabel(String id) {
    final option = _scionAllegiances[id.trim().toLowerCase()];
    if (option == null) return 'Dread Allegiance: $id';
    return 'Dread Allegiance: ${option.label} (${option.resistance} Resistance)';
  }

  static String soulknifePsionicEnergyDice(int rogueLevel) {
    if (rogueLevel >= 17) return '1d12 / 12 dice';
    if (rogueLevel >= 13) return '1d10 / 10 dice';
    if (rogueLevel >= 11) return '1d10 / 8 dice';
    if (rogueLevel >= 9) return '1d8 / 8 dice';
    if (rogueLevel >= 5) return '1d8 / 6 dice';
    return '1d6 / 4 dice';
  }

  static Iterable<String> preservedEntriesForLevel(
    Iterable<String> entries, {
    required int characterLevel,
  }) {
    final preserved = <String>[];
    final allowedExpertiseLevels =
        unlockedExpertiseLevels(characterLevel).toSet();

    for (final entry in entries) {
      if (!entry.startsWith(expertiseEntryPrefix)) continue;

      final parts = entry.split(':');
      if (parts.length < 4) continue;

      final rogueLevel = int.tryParse(parts[2]);
      if (rogueLevel == null || !allowedExpertiseLevels.contains(rogueLevel)) {
        continue;
      }

      preserved.add(entry);
    }

    final cantripLimit = arcaneTricksterCantripCount(characterLevel);
    var cantrips = 0;
    for (final entry in entries) {
      if (!entry.startsWith(arcaneTricksterCantripEntryPrefix)) continue;
      if (cantrips >= cantripLimit) break;
      final value = entry.replaceFirst(arcaneTricksterCantripEntryPrefix, '');
      if (value.trim().isEmpty) continue;
      preserved.add(entry);
      cantrips++;
    }

    final spellLimit = arcaneTricksterPreparedSpellCount(characterLevel);
    var spells = 0;
    for (final entry in entries) {
      if (!entry.startsWith(arcaneTricksterSpellEntryPrefix)) continue;
      if (spells >= spellLimit) break;
      final value = entry.replaceFirst(arcaneTricksterSpellEntryPrefix, '');
      if (value.trim().isEmpty) continue;
      preserved.add(entry);
      spells++;
    }

    if (characterLevel >= 3) {
      for (final entry in entries) {
        if (!entry.startsWith(scionDreadAllegianceEntryPrefix)) continue;
        final value = entry
            .replaceFirst(scionDreadAllegianceEntryPrefix, '')
            .trim()
            .toLowerCase();
        if (!isScionAllegianceId(value)) continue;
        preserved.add('$scionDreadAllegianceEntryPrefix$value');
        break;
      }
    }

    return preserved;
  }

  static String expertiseLabel(String skillIndex) {
    return 'Expertise: ${skillLabel(skillIndex)}';
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

class _ScionDreadAllegiance {
  final String label;
  final String resistance;
  final String cantrip;

  const _ScionDreadAllegiance({
    required this.label,
    required this.resistance,
    required this.cantrip,
  });
}
