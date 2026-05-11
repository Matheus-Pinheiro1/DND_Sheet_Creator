class ClericChoiceService {
  ClericChoiceService._();

  static const knowledgeSkillPrefix = 'class_choice:cleric_knowledge_skill:';
  static const knowledgeToolPrefix = 'class_choice:cleric_knowledge_tool:';
  static const knowledgeSkillCount = 2;

  static const List<String> knowledgeSkillOptions = [
    'arcana',
    'history',
    'nature',
    'religion',
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

  static const Map<String, String> _skillLabels = {
    'arcana': 'Arcana',
    'history': 'History',
    'nature': 'Nature',
    'religion': 'Religion',
  };

  static bool needsKnowledgeChoices({
    required String className,
    required String subclass,
    required int level,
  }) {
    return className.trim().toLowerCase() == 'cleric' &&
        subclass.trim().toLowerCase() == 'cleric-knowledge' &&
        level >= 3;
  }

  static bool isClericChoiceEntry(String entry) {
    return entry.startsWith(knowledgeSkillPrefix) ||
        entry.startsWith(knowledgeToolPrefix);
  }

  static List<String> selectedKnowledgeSkills(Iterable<String> entries) {
    final values = <String>[];
    for (final entry in entries) {
      if (!entry.startsWith(knowledgeSkillPrefix)) continue;
      final value = entry.replaceFirst(knowledgeSkillPrefix, '').trim();
      if (value.isEmpty || values.contains(value)) continue;
      values.add(value);
    }
    return values;
  }

  static String? selectedKnowledgeTool(Iterable<String> entries) {
    for (final entry in entries.toList().reversed) {
      if (!entry.startsWith(knowledgeToolPrefix)) continue;
      final value = entry.replaceFirst(knowledgeToolPrefix, '').trim();
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  static List<String> knowledgeExpertiseLabels(Iterable<String> entries) {
    return selectedKnowledgeSkills(entries)
        .map((skill) => 'Expertise: ${skillLabel(skill)}')
        .toList();
  }

  static Iterable<String> preservedEntriesForLevel(
    Iterable<String> entries, {
    required int characterLevel,
  }) {
    if (characterLevel < 3) return const <String>[];

    final preserved = <String>[];
    final skills = <String>[];

    for (final entry in entries) {
      if (!entry.startsWith(knowledgeSkillPrefix)) continue;
      final value = entry.replaceFirst(knowledgeSkillPrefix, '').trim();
      if (!knowledgeSkillOptions.contains(value) || skills.contains(value)) {
        continue;
      }
      skills.add(value);
      preserved.add('$knowledgeSkillPrefix$value');
      if (skills.length >= knowledgeSkillCount) break;
    }

    final tool = selectedKnowledgeTool(entries);
    if (tool != null && artisanToolOptions.contains(tool)) {
      preserved.add('$knowledgeToolPrefix$tool');
    }

    return preserved;
  }

  static String skillLabel(String skillIndex) {
    return _skillLabels[skillIndex] ?? skillIndex;
  }
}
