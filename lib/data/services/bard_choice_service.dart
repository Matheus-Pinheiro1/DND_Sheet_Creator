import '../remote/spell_dto.dart';

class BardChoiceService {
  BardChoiceService._();

  static const expertiseEntryPrefix = 'class_choice:bard_expertise:';
  static const loreBonusSkillEntryPrefix = 'class_choice:bard_lore_skill:';
  static const loreDiscoverySpellEntryPrefix = 'class_choice:bard_lore_spell:';
  static const moonCantripEntryPrefix = 'class_choice:bard_moon_cantrip:';
  static const moonSkillEntryPrefix = 'class_choice:bard_moon_skill:';

  static const danceSubclass = 'bard-dance';
  static const glamourSubclass = 'bard-glamour';
  static const loreSubclass = 'bard-lore';
  static const moonSubclass = 'bard-moon';
  static const valorSubclass = 'bard-valor';
  static const loreBonusSkillCount = 3;
  static const loreDiscoverySpellCount = 2;

  static const Map<int, int> _expertiseSelectionCounts = {
    2: 2,
    9: 2,
  };

  static const loreSkillOptions = [
    'acrobatics',
    'animal-handling',
    'arcana',
    'athletics',
    'deception',
    'history',
    'insight',
    'intimidation',
    'investigation',
    'medicine',
    'nature',
    'perception',
    'performance',
    'persuasion',
    'religion',
    'sleight-of-hand',
    'stealth',
    'survival',
  ];

  static const moonSkillOptions = [
    'animal-handling',
    'insight',
    'medicine',
    'nature',
    'perception',
    'survival',
  ];

  static const _magicalSecretsClassIndices = {
    'bard',
    'cleric',
    'druid',
    'wizard',
  };
  static const _loreDiscoveryClassIndices = {
    'cleric',
    'druid',
    'wizard',
  };

  static bool isBard({required String className}) {
    return className.trim().toLowerCase() == 'bard';
  }

  static bool isBardChoiceEntry(String entry) {
    return entry.startsWith(expertiseEntryPrefix) ||
        isBardSubclassChoiceEntry(entry);
  }

  static bool isBardSubclassChoiceEntry(String entry) {
    return entry.startsWith(loreBonusSkillEntryPrefix) ||
        entry.startsWith(loreDiscoverySpellEntryPrefix) ||
        entry.startsWith(moonCantripEntryPrefix) ||
        entry.startsWith(moonSkillEntryPrefix);
  }

  static bool isLore({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isBard(className: className) &&
        subclass.trim().toLowerCase() == loreSubclass &&
        level >= 3;
  }

  static bool needsLoreBonusSkills({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isLore(className: className, subclass: subclass, level: level);
  }

  static bool needsLoreMagicalDiscoveries({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isLore(className: className, subclass: subclass, level: level) &&
        level >= 6;
  }

  static bool isDance({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isBard(className: className) &&
        subclass.trim().toLowerCase() == danceSubclass &&
        level >= 3;
  }

  static bool isMoon({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isBard(className: className) &&
        subclass.trim().toLowerCase() == moonSubclass &&
        level >= 3;
  }

  static bool isValor({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isBard(className: className) &&
        subclass.trim().toLowerCase() == valorSubclass &&
        level >= 3;
  }

  static bool hasJackOfAllTrades({
    required String className,
    required int level,
  }) {
    return isBard(className: className) && level >= 2;
  }

  static bool hasMagicalSecrets({
    required String className,
    required int level,
  }) {
    return isBard(className: className) && level >= 10;
  }

  static bool hasWordsOfCreation({
    required String className,
    required int level,
  }) {
    return isBard(className: className) && level >= 20;
  }

  static String bardicInspirationDie(int level) {
    if (level >= 15) return 'd12';
    if (level >= 10) return 'd10';
    if (level >= 5) return 'd8';
    return 'd6';
  }

  static List<int> unlockedExpertiseLevels(int characterLevel) {
    return _expertiseSelectionCounts.keys
        .where((level) => characterLevel >= level)
        .toList()
      ..sort();
  }

  static int requiredExpertiseSelectionsForLevel(int bardLevel) {
    return _expertiseSelectionCounts[bardLevel] ?? 0;
  }

  static List<String> selectedExpertiseSkills(
    Iterable<String> entries, {
    required int bardLevel,
  }) {
    final prefix = '$expertiseEntryPrefix$bardLevel:';

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

    for (final bardLevel in unlockedExpertiseLevels(upToCharacterLevel)) {
      selected.addAll(
        selectedExpertiseSkills(entries, bardLevel: bardLevel),
      );
    }

    return selected;
  }

  static List<String> selectedLoreBonusSkills(Iterable<String> entries) {
    return _selectedByPrefix(entries, loreBonusSkillEntryPrefix)
        .where(loreSkillOptions.contains)
        .take(loreBonusSkillCount)
        .toList();
  }

  static List<String> selectedLoreDiscoverySpells(Iterable<String> entries) {
    return _selectedByPrefix(entries, loreDiscoverySpellEntryPrefix)
        .take(loreDiscoverySpellCount)
        .toList();
  }

  static String? selectedMoonCantrip(Iterable<String> entries) {
    final selected = _selectedByPrefix(entries, moonCantripEntryPrefix);
    return selected.isEmpty ? null : selected.first;
  }

  static String? selectedMoonSkill(Iterable<String> entries) {
    for (final skill in _selectedByPrefix(entries, moonSkillEntryPrefix)) {
      if (moonSkillOptions.contains(skill)) return skill;
    }
    return null;
  }

  static Iterable<String> preservedEntriesForLevel(
    Iterable<String> entries, {
    required int characterLevel,
    String subclass = '',
  }) {
    final allowedLevels = unlockedExpertiseLevels(characterLevel).toSet();
    final selectedByLevel = <int, Set<String>>{};
    final preserved = <String>[];

    for (final entry in entries) {
      if (!entry.startsWith(expertiseEntryPrefix)) {
        continue;
      }

      final parts = entry.split(':');
      if (parts.length < 4) {
        continue;
      }

      final bardLevel = int.tryParse(parts[2]);
      if (bardLevel == null) {
        continue;
      }

      if (!allowedLevels.contains(bardLevel)) {
        continue;
      }

      final skill = entry.replaceFirst('$expertiseEntryPrefix$bardLevel:', '');
      if (skill.trim().isEmpty) {
        continue;
      }

      final selectedForLevel = selectedByLevel.putIfAbsent(
        bardLevel,
        () => <String>{},
      );
      if (selectedForLevel.length >=
          requiredExpertiseSelectionsForLevel(bardLevel)) {
        continue;
      }
      if (selectedForLevel.add(skill)) {
        preserved.add(entry);
      }
    }

    if (subclass.trim().toLowerCase() == loreSubclass && characterLevel >= 3) {
      for (final skill in selectedLoreBonusSkills(entries)) {
        preserved.add('$loreBonusSkillEntryPrefix$skill');
      }
    }

    if (subclass.trim().toLowerCase() == loreSubclass && characterLevel >= 6) {
      for (final spell in selectedLoreDiscoverySpells(entries)) {
        preserved.add('$loreDiscoverySpellEntryPrefix$spell');
      }
    }

    if (subclass.trim().toLowerCase() == moonSubclass && characterLevel >= 3) {
      final cantrip = selectedMoonCantrip(entries);
      if (cantrip != null) {
        preserved.add('$moonCantripEntryPrefix$cantrip');
      }
      final skill = selectedMoonSkill(entries);
      if (skill != null) {
        preserved.add('$moonSkillEntryPrefix$skill');
      }
    }

    return preserved;
  }

  static List<SpellDto> filterMagicalSecretsSpellOptions({
    required List<SpellDto> spells,
  }) {
    final byIndex = <String, SpellDto>{};

    for (final spell in spells) {
      if (spell.level == 0) {
        if (spell.classIndices.contains('bard')) {
          byIndex[spell.index] = spell;
        }
        continue;
      }

      final matchesAllowedList = spell.classIndices.any(
        _magicalSecretsClassIndices.contains,
      );
      if (matchesAllowedList) {
        byIndex[spell.index] = spell;
      }
    }

    return byIndex.values.toList()
      ..sort((left, right) {
        if (left.level != right.level) {
          return left.level.compareTo(right.level);
        }
        return left.name.compareTo(right.name);
      });
  }

  static List<SpellDto> filterLoreDiscoverySpellOptions({
    required List<SpellDto> spells,
    required int maxSpellLevel,
    required Set<String> knownSpellIds,
  }) {
    final byIndex = <String, SpellDto>{};

    for (final spell in spells) {
      if (knownSpellIds.contains(spell.index)) continue;
      if (spell.level > maxSpellLevel) continue;
      if (spell.classIndices.any(_loreDiscoveryClassIndices.contains)) {
        byIndex[spell.index] = spell;
      }
    }

    return byIndex.values.toList()
      ..sort((left, right) {
        if (left.level != right.level) {
          return left.level.compareTo(right.level);
        }
        return left.name.compareTo(right.name);
      });
  }

  static List<SpellDto> filterMoonCantripOptions({
    required List<SpellDto> spells,
    required Set<String> knownSpellIds,
  }) {
    return spells
        .where((spell) =>
            spell.level == 0 &&
            spell.classIndices.contains('druid') &&
            !knownSpellIds.contains(spell.index))
        .toList()
      ..sort((left, right) => left.name.compareTo(right.name));
  }

  static List<String> baseGrantedSpellIds(int level) {
    if (level < 20) return const [];
    return const ['power-word-heal', 'power-word-kill'];
  }

  static String expertiseLabel(String skillIndex) {
    return 'Expertise: ${skillLabel(skillIndex)}';
  }

  static String loreBonusSkillsLabel(List<String> skillIndices) {
    return 'Bonus Proficiencies: ${skillIndices.map(skillLabel).join(', ')}';
  }

  static String moonSkillLabel(String skillIndex) {
    return 'Primal Lore: ${skillLabel(skillIndex)}';
  }

  static String moonCantripLabel(String spellIndex) {
    return 'Primal Lore Cantrip: ${spellLabel(spellIndex)}';
  }

  static List<String> valorProficiencyLabels() {
    return const ['Martial weapons', 'Medium armor', 'Shields'];
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
