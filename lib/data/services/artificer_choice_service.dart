class ArtificerChoiceService {
  ArtificerChoiceService._();

  static const skillEntryPrefix = 'class_choice:artificer_skill:';
  static const artisanToolEntryPrefix = 'class_choice:artificer_artisan_tool:';

  static const int skillSelectionCount = 2;
  static const String tinkerMagicCantrip = 'mending';

  static const List<String> skillOptions = [
    'arcana',
    'history',
    'investigation',
    'medicine',
    'nature',
    'perception',
    'sleight-of-hand',
  ];

  static const List<String> baseToolProficiencies = [
    "Thieves' Tools",
    "Tinker's Tools",
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

  static List<String> get selectableArtisanToolOptions {
    return artisanToolOptions
        .where((tool) => !baseToolProficiencies.contains(tool))
        .toList(growable: false);
  }

  static bool isArtificer({required String className}) {
    return className.trim().toLowerCase() == 'artificer';
  }

  static bool needsBaseChoices({
    required String className,
    required int level,
  }) {
    return isArtificer(className: className) && level >= 1;
  }

  static bool isArtificerChoiceEntry(String entry) {
    return entry.startsWith(skillEntryPrefix) ||
        entry.startsWith(artisanToolEntryPrefix);
  }

  static List<String> selectedSkillProficiencies(List<String> entries) {
    final result = <String>[];
    for (final entry in entries) {
      if (!entry.startsWith(skillEntryPrefix)) continue;
      final skill = entry.replaceFirst(skillEntryPrefix, '').trim();
      if (skillOptions.contains(skill) && !result.contains(skill)) {
        result.add(skill);
      }
    }
    return result;
  }

  static String? selectedArtisanTool(List<String> entries) {
    for (final entry in entries) {
      if (!entry.startsWith(artisanToolEntryPrefix)) continue;
      final tool = entry.replaceFirst(artisanToolEntryPrefix, '').trim();
      if (selectableArtisanToolOptions.contains(tool)) return tool;
    }
    return null;
  }

  static List<String> baseGrantedSpellIds(int level) {
    return level >= 1 ? const [tinkerMagicCantrip] : const <String>[];
  }

  static String skillLabel(String skill) {
    return switch (skill) {
      'arcana' => 'Arcana',
      'history' => 'History',
      'investigation' => 'Investigation',
      'medicine' => 'Medicine',
      'nature' => 'Nature',
      'perception' => 'Perception',
      'sleight-of-hand' => 'Sleight of Hand',
      _ => skill,
    };
  }
}
