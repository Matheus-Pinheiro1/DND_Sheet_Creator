import '../remote/spell_dto.dart';

class WizardSavantMilestone {
  final int wizardLevel;
  final int maxSpellLevel;
  final int selections;

  const WizardSavantMilestone({
    required this.wizardLevel,
    required this.maxSpellLevel,
    required this.selections,
  });
}

class WizardChoiceService {
  WizardChoiceService._();

  static const scholarEntryPrefix = 'class_choice:wizard_scholar:';
  static const savantEntryPrefix = 'class_choice:wizard_savant:';
  static const illusionistCantripPrefix =
      'class_choice:illusionist_bonus_cantrip:';

  static const List<String> scholarSkillOptions = [
    'arcana',
    'history',
    'investigation',
    'medicine',
    'nature',
    'religion',
  ];

  static const List<WizardSavantMilestone> _allSavantMilestones = [
    WizardSavantMilestone(wizardLevel: 3, maxSpellLevel: 2, selections: 2),
    WizardSavantMilestone(wizardLevel: 5, maxSpellLevel: 3, selections: 1),
    WizardSavantMilestone(wizardLevel: 7, maxSpellLevel: 4, selections: 1),
    WizardSavantMilestone(wizardLevel: 9, maxSpellLevel: 5, selections: 1),
    WizardSavantMilestone(wizardLevel: 11, maxSpellLevel: 6, selections: 1),
    WizardSavantMilestone(wizardLevel: 13, maxSpellLevel: 7, selections: 1),
    WizardSavantMilestone(wizardLevel: 15, maxSpellLevel: 8, selections: 1),
    WizardSavantMilestone(wizardLevel: 17, maxSpellLevel: 9, selections: 1),
  ];

  static bool needsScholar({required String className, required int level}) {
    return className.trim().toLowerCase() == 'wizard' && level >= 2;
  }

  static bool needsSavant({
    required String className,
    required String subclass,
    required int level,
  }) {
    return className.trim().toLowerCase() == 'wizard' &&
        level >= 3 &&
        savantSchoolForSubclass(subclass) != null;
  }

  static String? savantSchoolForSubclass(String subclass) {
    switch (subclass.trim().toLowerCase()) {
      case 'wizard-abjurer':
        return 'abjuration';
      case 'wizard-diviner':
        return 'divination';
      case 'wizard-evoker':
        return 'evocation';
      case 'wizard-illusionist':
        return 'illusion';
      default:
        return null;
    }
  }

  static String savantFeatureNameForSubclass(String subclass) {
    switch (subclass.trim().toLowerCase()) {
      case 'wizard-abjurer':
        return 'Abjuration Savant';
      case 'wizard-diviner':
        return 'Divination Savant';
      case 'wizard-evoker':
        return 'Evocation Savant';
      case 'wizard-illusionist':
        return 'Illusion Savant';
      default:
        return 'Savant';
    }
  }

  static String schoolLabel(String school) {
    if (school.isEmpty) return '';
    return school[0].toUpperCase() + school.substring(1).toLowerCase();
  }

  static List<WizardSavantMilestone> savantMilestonesForLevel(int wizardLevel) {
    return _allSavantMilestones
        .where((milestone) => wizardLevel >= milestone.wizardLevel)
        .toList();
  }

  static int totalRequiredSavantSelections(int wizardLevel) {
    return savantMilestonesForLevel(wizardLevel)
        .fold<int>(0, (total, milestone) => total + milestone.selections);
  }

  static String? selectedScholarSkill(Iterable<String> entries) {
    for (final entry in entries.toList().reversed) {
      if (entry.startsWith(scholarEntryPrefix)) {
        final value = entry.replaceFirst(scholarEntryPrefix, '').trim();
        if (value.isNotEmpty) return value;
      }
    }
    return null;
  }

  static List<String> selectedSavantSpells(
    Iterable<String> entries, {
    int? wizardLevel,
  }) {
    final spells = <String>[];
    for (final entry in entries) {
      if (!entry.startsWith(savantEntryPrefix)) continue;
      final parts = entry.split(':');
      if (parts.length < 4) continue;
      final entryLevel = int.tryParse(parts[2]);
      if (wizardLevel != null && entryLevel != wizardLevel) continue;
      final spellIndex = parts[3].trim();
      if (spellIndex.isNotEmpty) {
        spells.add(spellIndex);
      }
    }
    return spells;
  }

  static String? selectedIllusionistBonusCantrip(Iterable<String> entries) {
    for (final entry in entries.toList().reversed) {
      if (entry.startsWith(illusionistCantripPrefix)) {
        final value = entry.replaceFirst(illusionistCantripPrefix, '').trim();
        if (value.isNotEmpty) return value;
      }
    }
    return null;
  }

  static String scholarExpertiseLabel(String skillIndex) {
    return 'Expertise: ${skillLabel(skillIndex)}';
  }

  static String skillLabel(String skillIndex) {
    return skillIndex
        .split('-')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  static String illusionistGrantedCantrip(Iterable<String> entries) {
    return selectedIllusionistBonusCantrip(entries) ?? 'minor-illusion';
  }

  static bool needsIllusionistBonusCantrip({
    required String subclass,
    required int level,
    required Iterable<String> knownSpellIds,
  }) {
    return subclass.trim().toLowerCase() == 'wizard-illusionist' &&
        level >= 3 &&
        knownSpellIds.contains('minor-illusion');
  }

  static List<SpellDto> filterSavantSpellOptions({
    required List<SpellDto> spells,
    required String school,
    required int maxSpellLevel,
  }) {
    final loweredSchool = school.trim().toLowerCase();
    final filtered = spells.where((spell) {
      return spell.level > 0 &&
          spell.level <= maxSpellLevel &&
          spell.school.trim().toLowerCase() == loweredSchool;
    }).toList()
      ..sort((a, b) {
        if (a.level != b.level) {
          return a.level.compareTo(b.level);
        }
        return a.name.compareTo(b.name);
      });
    return filtered;
  }

  static List<SpellDto> filterIllusionistBonusCantrips({
    required List<SpellDto> spells,
    required Set<String> knownSpellIds,
  }) {
    final filtered = spells.where((spell) {
      return spell.level == 0 &&
          spell.index != 'minor-illusion' &&
          !knownSpellIds.contains(spell.index);
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }
}
