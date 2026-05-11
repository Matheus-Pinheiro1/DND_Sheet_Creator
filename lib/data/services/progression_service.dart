import '../../data/local/feats_data.dart';
import '../../data/local/progression_data.dart';
import '../../data/local/spells_data.dart';
import '../../data/models/character_model.dart';
import '../../data/models/feat_model.dart';

class SpellSelectionLimits {
  final int maxCantrips;
  final int maxLeveledSpells;
  final int maxSpellLevel;
  final Map<int, int> spellSlots;
  final String helperText;

  const SpellSelectionLimits({
    required this.maxCantrips,
    required this.maxLeveledSpells,
    required this.maxSpellLevel,
    this.spellSlots = const {},
    required this.helperText,
  });
}

class ProgressionService {
  const ProgressionService._();

  static List<int> getSpellSlotsListFor({
    required String className,
    required int level,
  }) {
    final slots = _spellSlotsForCaster(className.trim().toLowerCase(), level);
    final values = List<int>.filled(9, 0);
    for (final entry in slots.entries) {
      final idx = entry.key - 1;
      if (idx >= 0 && idx < values.length) {
        values[idx] = entry.value;
      }
    }
    return values;
  }

  static List<int> getAdvancementLevels(String className) {
    final normalized = className.trim().toLowerCase();
    if (normalized.startsWith('custom_class_')) {
      return kProgressionRules.defaultAdvancementLevels;
    }
    return kProgressionRules.advancementLevelsFor(normalized);
  }

  static int getAvailableAdvancementCount(String className, int level) {
    return getAdvancementLevels(className).where((l) => l <= level).length;
  }

  static int getSpentAdvancementCount(CharacterModel character) {
    return getVisibleAdvancements(character)
        .where((entry) => !entry.startsWith('origin_'))
        .length;
  }

  static int getRemainingAdvancements(CharacterModel character) {
    return getAvailableAdvancementCount(character.className, character.level) -
        getSpentAdvancementCount(character);
  }

  static String getMonkMartialArtsDie(int level) {
    return _lookupMilestone(
      kProgressionRules.classBonuses.monkMartialArtsDie,
      level,
      fallback: '1d6',
    );
  }

  static int getMonkUnarmoredMovementBonus(int level) {
    return _lookupMilestone(
      kProgressionRules.classBonuses.monkUnarmoredMovementBonus,
      level,
      fallback: 0,
    );
  }

  static int getRangerRovingSpeedBonus(int level) {
    return _lookupMilestone(
      kProgressionRules.classBonuses.rangerRovingSpeedBonus,
      level,
      fallback: 0,
    );
  }

  static int getBarbarianFastMovementBonus(int level) {
    return _lookupMilestone(
      kProgressionRules.classBonuses.barbarianFastMovementBonus,
      level,
      fallback: 0,
    );
  }

  static FeatModel? findFeat(String id) {
    for (final feat in kFeatCatalog) {
      if (feat.id == id) return feat;
    }
    return null;
  }

  static bool isMagicInitiateId(String id) {
    return id == 'magic-initiate' || id.startsWith('magic-initiate-');
  }

  static String magicInitiateListFromId(String id) {
    if (id.endsWith('-cleric')) return 'cleric';
    if (id.endsWith('-druid')) return 'druid';
    return 'wizard';
  }

  static List<String> getVisibleAdvancements(CharacterModel character) {
    return character.levelAdvancements.where((entry) {
      if (entry.startsWith('origin_feat_name:')) return false;
      if (entry.startsWith('origin_feat_ability:')) return false;
      if (entry.startsWith('origin_cantrip:')) return false;
      if (entry.startsWith('origin_spell:')) return false;
      if (entry.startsWith('origin_choice:')) return false;
      if (entry.startsWith('class_choice:')) return false;
      if (entry.startsWith('species_choice:')) return false;
      return true;
    }).toList();
  }

  static SpellSelectionLimits getSpellLimits(CharacterModelLike character) {
    return getSpellLimitsFor(
      className: character.className,
      level: character.level,
      spellcastingModifier: character.spellcastingModifier,
    );
  }

  static SpellSelectionLimits getSpellLimitsFor({
    required String className,
    required int level,
    required int spellcastingModifier,
  }) {
    final normalized = className.trim().toLowerCase();

    if (!_isSpellcaster(normalized)) {
      return const SpellSelectionLimits(
        maxCantrips: 0,
        maxLeveledSpells: 0,
        maxSpellLevel: 0,
        helperText: 'This class does not normally use spell selection.',
      );
    }

    if (normalized == 'wizard') {
      final cantrips = _cantripsFor(normalized, level);
      final prepared = _preparedSpellsFor(normalized, level);
      final spellSlots = _spellSlotsForCaster(normalized, level);
      return SpellSelectionLimits(
        maxCantrips: cantrips,
        maxLeveledSpells: prepared,
        maxSpellLevel: _highestSpellLevel(spellSlots),
        spellSlots: spellSlots,
        helperText:
            'Prepared spells: $prepared. Choose Wizard spells of levels for which you have spell slots.',
      );
    }

    if (normalized == 'cleric') {
      final cantrips = _cantripsFor(normalized, level);
      final prepared = _preparedSpellsFor(normalized, level);
      final spellSlots = _spellSlotsForCaster(normalized, level);
      return SpellSelectionLimits(
        maxCantrips: cantrips,
        maxLeveledSpells: prepared,
        maxSpellLevel: _highestSpellLevel(spellSlots),
        spellSlots: spellSlots,
        helperText:
            'Prepared spells: $prepared. Choose Cleric spells of levels for which you have spell slots.',
      );
    }

    if (normalized == 'druid') {
      final cantrips = _cantripsFor(normalized, level);
      final prepared = _preparedSpellsFor(normalized, level);
      final spellSlots = _spellSlotsForCaster(normalized, level);
      return SpellSelectionLimits(
        maxCantrips: cantrips,
        maxLeveledSpells: prepared,
        maxSpellLevel: _highestSpellLevel(spellSlots),
        spellSlots: spellSlots,
        helperText:
            'Prepared spells: $prepared. Choose Druid spells of levels for which you have spell slots.',
      );
    }

    if (normalized == 'bard') {
      final cantrips = _cantripsFor(normalized, level);
      final prepared = _preparedSpellsFor(normalized, level);
      final spellSlots = _spellSlotsForCaster(normalized, level);
      final sourceText = level >= 10
          ? 'Choose Bard cantrips and level 1+ Bard, Cleric, Druid, or Wizard spells for which you have spell slots.'
          : 'Choose Bard spells of levels for which you have spell slots.';
      return SpellSelectionLimits(
        maxCantrips: cantrips,
        maxLeveledSpells: prepared,
        maxSpellLevel: _highestSpellLevel(spellSlots),
        spellSlots: spellSlots,
        helperText: 'Prepared spells: $prepared. $sourceText',
      );
    }

    if (normalized == 'sorcerer') {
      final cantrips = _cantripsFor(normalized, level);
      final prepared = _preparedSpellsFor(normalized, level);
      final spellSlots = _spellSlotsForCaster(normalized, level);
      return SpellSelectionLimits(
        maxCantrips: cantrips,
        maxLeveledSpells: prepared,
        maxSpellLevel: _highestSpellLevel(spellSlots),
        spellSlots: spellSlots,
        helperText:
            'Prepared spells: $prepared. Choose Sorcerer spells of levels for which you have spell slots.',
      );
    }

    if (normalized == 'warlock') {
      final cantrips = _cantripsFor(normalized, level);
      final prepared = _preparedSpellsFor(normalized, level);
      final spellSlots = _spellSlotsForCaster(normalized, level);
      return SpellSelectionLimits(
        maxCantrips: cantrips,
        maxLeveledSpells: prepared,
        maxSpellLevel: _highestSpellLevel(spellSlots),
        spellSlots: spellSlots,
        helperText:
            'Prepared spells: $prepared. Choose Warlock spells of levels for which you have spell slots.',
      );
    }

    if (normalized == 'ranger') {
      final prepared = _preparedSpellsFor(normalized, level);
      final spellSlots = _spellSlotsForCaster(normalized, level);
      return SpellSelectionLimits(
        maxCantrips: 0,
        maxLeveledSpells: prepared,
        maxSpellLevel: _highestSpellLevel(spellSlots),
        spellSlots: spellSlots,
        helperText:
            'Prepared spells: $prepared. Choose Ranger spells of levels for which you have spell slots.',
      );
    }

    if (normalized == 'paladin') {
      final prepared = _preparedSpellsFor(normalized, level);
      final spellSlots = _spellSlotsForCaster(normalized, level);
      return SpellSelectionLimits(
        maxCantrips: 0,
        maxLeveledSpells: prepared,
        maxSpellLevel: _highestSpellLevel(spellSlots),
        spellSlots: spellSlots,
        helperText:
            'Prepared spells: $prepared. Choose Paladin spells of levels for which you have spell slots.',
      );
    }

    if (normalized == 'artificer') {
      final cantrips = _cantripsFor(normalized, level);
      final prepared = _preparedSpellsFor(normalized, level);
      final spellSlots = _spellSlotsForCaster(normalized, level);
      return SpellSelectionLimits(
        maxCantrips: cantrips,
        maxLeveledSpells: prepared,
        maxSpellLevel: _highestSpellLevel(spellSlots),
        spellSlots: spellSlots,
        helperText:
            'Prepared spells: $prepared. Choose Artificer spells of levels for which you have spell slots.',
      );
    }

    return const SpellSelectionLimits(
      maxCantrips: 0,
      maxLeveledSpells: 0,
      maxSpellLevel: 0,
      helperText: 'No local spell selection rules were found for this class.',
    );
  }

  static bool canSelectSpell({
    required CharacterModelLike character,
    required int spellLevel,
    required int currentCantrips,
    required int currentLeveled,
  }) {
    final limits = getSpellLimits(character);
    if (spellLevel > limits.maxSpellLevel && spellLevel != 0) {
      return false;
    }
    if (spellLevel == 0) return currentCantrips < limits.maxCantrips;
    return currentLeveled < limits.maxLeveledSpells;
  }

  static bool hasCompletedSpellSelectionFor({
    required String className,
    required int level,
    required Iterable<String> selectedSpellIds,
    required int spellcastingModifier,
  }) {
    final limits = getSpellLimitsFor(
      className: className,
      level: level,
      spellcastingModifier: spellcastingModifier,
    );
    if (limits.maxCantrips == 0 && limits.maxLeveledSpells == 0) {
      return true;
    }

    var cantrips = 0;
    var leveled = 0;
    final selected = selectedSpellIds
        .map((spell) => spell.trim().toLowerCase())
        .where((spell) => spell.isNotEmpty)
        .toSet();

    for (final spell in selected) {
      final spellLevel = SpellCatalogData.levelFor(spell);
      if (spellLevel == null) return false;
      if (spellLevel == 0) {
        cantrips += 1;
      } else {
        if (spellLevel > limits.maxSpellLevel) return false;
        leveled += 1;
      }
    }

    return cantrips == limits.maxCantrips && leveled == limits.maxLeveledSpells;
  }

  static bool _isSpellcaster(String className) {
    return kProgressionRules.preparedProgressionByClass.containsKey(className);
  }

  static T _lookupMilestone<T>(
    Map<int, T> table,
    int level, {
    required T fallback,
  }) {
    final keys = table.keys.toList()..sort();
    var value = fallback;
    for (final key in keys) {
      if (level >= key) {
        value = table[key] ?? value;
      }
    }
    return value;
  }

  static int _cantripsFor(String className, int level) {
    final progression = kProgressionRules.cantripsFor(className);
    if (progression == null) return 0;
    return _lookupMilestone(
      progression.levels,
      level,
      fallback: progression.fallback,
    );
  }

  static int _preparedSpellsFor(String className, int level) {
    return kProgressionRules.preparedSpellsFor(className)[level] ?? 0;
  }

  static Map<int, int> _spellSlotsForCaster(String className, int level) {
    if (level <= 0) return const {};
    return kProgressionRules.spellSlotsFor(className)[level] ?? const {};
  }

  static int _highestSpellLevel(Map<int, int> spellSlots) {
    if (spellSlots.isEmpty) return 0;
    final keys = spellSlots.keys.toList()..sort();
    return keys.last;
  }
}

abstract class CharacterModelLike {
  String get className;
  int get level;
  int get spellcastingModifier;
}
