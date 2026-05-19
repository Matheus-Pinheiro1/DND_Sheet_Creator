import '../../core/utils/dice_calculator.dart';
import '../local/choice_lists_data.dart';

class SorcererChoiceService {
  SorcererChoiceService._();

  static const metamagicEntryPrefix = 'class_choice:sorcerer_metamagic:';
  static const draconicAffinityEntryPrefix =
      'class_choice:sorcerer_draconic_affinity:';

  static const aberrantSubclass = 'sorcerer-aberrant-sorcery';
  static const clockworkSubclass = 'sorcerer-clockwork-sorcery';
  static const draconicSubclass = 'sorcerer-draconic-sorcery';
  static const spellfireSubclass = 'sorcerer-spellfire-sorcery';
  static const wildMagicSubclass = 'sorcerer-wild-magic-sorcery';

  static const Map<int, int> _metamagicSelectionCounts = {
    2: 2,
    10: 2,
    17: 2,
  };

  static const Map<String, String> draconicAffinityOptions = {
    'acid': 'Acid',
    'cold': 'Cold',
    'fire': 'Fire',
    'lightning': 'Lightning',
    'poison': 'Poison',
  };

  static Map<String, _MetamagicOption> get _metamagicOptions {
    try {
      final loaded = ChoiceListsData.metamagicOptions;
      if (loaded.isNotEmpty) {
        return {
          for (final entry in loaded)
            entry.id: _MetamagicOption(
              label: entry.name,
              costLabel: _sorceryCostLabel(
                entry.costLabel,
                fallback: _fallbackMetamagicOptions[entry.id]?.costLabel ?? '',
              ),
              summary: _metamagicSummaryText(
                entry.id,
                entry.summary,
                fallback: _fallbackMetamagicOptions[entry.id]?.summary ?? '',
              ),
            ),
        };
      }
    } catch (_) {}

    return _fallbackMetamagicOptions;
  }

  static const Map<String, _MetamagicOption> _fallbackMetamagicOptions = {
    'careful_spell': _MetamagicOption(
      label: 'Careful Spell',
      costLabel: '1 Sorcery Point',
      summary:
          'Protect selected creatures from the harsher effects of your saving throw spell.',
    ),
    'distant_spell': _MetamagicOption(
      label: 'Distant Spell',
      costLabel: '1 Sorcery Point',
      summary: 'Increase a spell range, or turn Touch range into 30 feet.',
    ),
    'empowered_spell': _MetamagicOption(
      label: 'Empowered Spell',
      costLabel: '1 Sorcery Point',
      summary:
          'Reroll a limited number of spell damage dice and use the new rolls.',
    ),
    'extended_spell': _MetamagicOption(
      label: 'Extended Spell',
      costLabel: '1 Sorcery Point',
      summary: 'Extend an eligible spell duration and improve Concentration.',
    ),
    'heightened_spell': _MetamagicOption(
      label: 'Heightened Spell',
      costLabel: '2 Sorcery Points',
      summary: 'Make a target less likely to resist your spell saves.',
    ),
    'quickened_spell': _MetamagicOption(
      label: 'Quickened Spell',
      costLabel: '2 Sorcery Points',
      summary: 'Cast an eligible spell as a Bonus Action instead of an action.',
    ),
    'seeking_spell': _MetamagicOption(
      label: 'Seeking Spell',
      costLabel: '1 Sorcery Point',
      summary: 'Reroll a missed spell attack roll and use the new roll.',
    ),
    'subtle_spell': _MetamagicOption(
      label: 'Subtle Spell',
      costLabel: '1 Sorcery Point',
      summary: 'Cast with reduced visible casting components.',
    ),
    'transmuted_spell': _MetamagicOption(
      label: 'Transmuted Spell',
      costLabel: '1 Sorcery Point',
      summary: 'Change an eligible spell damage type.',
    ),
    'twinned_spell': _MetamagicOption(
      label: 'Twinned Spell',
      costLabel: '1 Sorcery Point',
      summary: 'Add a second target to an eligible single-target spell.',
    ),
  };

  static bool isSorcerer({required String className}) {
    return className.trim().toLowerCase() == 'sorcerer';
  }

  static bool isSorcererChoiceEntry(String entry) {
    return entry.startsWith(metamagicEntryPrefix) ||
        isSorcererSubclassChoiceEntry(entry);
  }

  static bool isSorcererSubclassChoiceEntry(String entry) {
    return entry.startsWith(draconicAffinityEntryPrefix);
  }

  static bool isAberrant({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isSorcerer(className: className) &&
        subclass.trim().toLowerCase() == aberrantSubclass &&
        level >= 3;
  }

  static bool isClockwork({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isSorcerer(className: className) &&
        subclass.trim().toLowerCase() == clockworkSubclass &&
        level >= 3;
  }

  static bool isDraconic({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isSorcerer(className: className) &&
        subclass.trim().toLowerCase() == draconicSubclass &&
        level >= 3;
  }

  static bool isSpellfire({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isSorcerer(className: className) &&
        subclass.trim().toLowerCase() == spellfireSubclass &&
        level >= 3;
  }

  static bool isWildMagic({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isSorcerer(className: className) &&
        subclass.trim().toLowerCase() == wildMagicSubclass &&
        level >= 3;
  }

  static bool needsDraconicAffinity({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isDraconic(
          className: className,
          subclass: subclass,
          level: level,
        ) &&
        level >= 6;
  }

  static List<String> get metamagicOptionIds {
    return _metamagicOptions.keys.toList(growable: false);
  }

  static List<int> unlockedMetamagicLevels(int characterLevel) {
    return _metamagicSelectionCounts.keys
        .where((level) => characterLevel >= level)
        .toList()
      ..sort();
  }

  static int requiredMetamagicSelectionsForLevel(int sorcererLevel) {
    return _metamagicSelectionCounts[sorcererLevel] ?? 0;
  }

  static List<String> selectedMetamagicOptions(
    Iterable<String> entries, {
    required int sorcererLevel,
  }) {
    final prefix = '$metamagicEntryPrefix$sorcererLevel:';
    final selected = <String>[];

    for (final entry in entries) {
      if (!entry.startsWith(prefix)) continue;
      final optionId = entry.substring(prefix.length).trim();
      if (!_metamagicOptions.containsKey(optionId)) continue;
      if (selected.contains(optionId)) continue;
      selected.add(optionId);
    }

    return selected;
  }

  static List<String> allSelectedMetamagicOptions(
    Iterable<String> entries, {
    required int upToCharacterLevel,
  }) {
    final selected = <String>[];

    for (final sorcererLevel in unlockedMetamagicLevels(upToCharacterLevel)) {
      for (final option in selectedMetamagicOptions(
        entries,
        sorcererLevel: sorcererLevel,
      )) {
        if (!selected.contains(option)) {
          selected.add(option);
        }
      }
    }

    return selected;
  }

  static String? selectedDraconicAffinity(Iterable<String> entries) {
    for (final entry in entries.toList().reversed) {
      if (!entry.startsWith(draconicAffinityEntryPrefix)) continue;
      final value = entry.replaceFirst(draconicAffinityEntryPrefix, '').trim();
      if (draconicAffinityOptions.containsKey(value)) return value;
    }
    return null;
  }

  static Iterable<String> preservedEntriesForLevel(
    Iterable<String> entries, {
    required int characterLevel,
    String subclass = '',
  }) {
    final allowedLevels = unlockedMetamagicLevels(characterLevel).toSet();
    final selectedByLevel = <int, Set<String>>{};
    final selectedOptions = <String>{};
    final normalizedSubclass = subclass.trim().toLowerCase();
    var keptDraconicAffinity = false;

    return entries.where((entry) {
      if (entry.startsWith(draconicAffinityEntryPrefix)) {
        final value =
            entry.replaceFirst(draconicAffinityEntryPrefix, '').trim();
        if (characterLevel < 6 ||
            normalizedSubclass != draconicSubclass ||
            keptDraconicAffinity ||
            !draconicAffinityOptions.containsKey(value)) {
          return false;
        }
        keptDraconicAffinity = true;
        return true;
      }

      if (!entry.startsWith(metamagicEntryPrefix)) return false;

      final parts = entry.split(':');
      if (parts.length < 4) return false;

      final sorcererLevel = int.tryParse(parts[2]);
      if (sorcererLevel == null || !allowedLevels.contains(sorcererLevel)) {
        return false;
      }

      final optionId = entry
          .replaceFirst(
            '$metamagicEntryPrefix$sorcererLevel:',
            '',
          )
          .trim();
      if (!_metamagicOptions.containsKey(optionId)) return false;
      if (selectedOptions.contains(optionId)) return false;

      final selectedForLevel = selectedByLevel.putIfAbsent(
        sorcererLevel,
        () => <String>{},
      );
      if (selectedForLevel.length >=
          requiredMetamagicSelectionsForLevel(sorcererLevel)) {
        return false;
      }

      selectedOptions.add(optionId);
      return selectedForLevel.add(optionId);
    });
  }

  static int innateSorceryUses(int level) {
    return level >= 1 ? 2 : 0;
  }

  static int sorceryPointMaximum(int level) {
    return level >= 2 ? level : 0;
  }

  static int sorcerousRestorationPoints(int level) {
    return level >= 5 ? level ~/ 2 : 0;
  }

  static int draconicResilienceHpBonus({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isDraconic(
      className: className,
      subclass: subclass,
      level: level,
    )
        ? level
        : 0;
  }

  static int draconicResilienceArmorClass({
    required int dexterity,
    required int charisma,
  }) {
    return 10 +
        DiceCalculator.getModifier(dexterity) +
        DiceCalculator.getModifier(charisma);
  }

  static int spellSaveDc({required int level, required int charisma}) {
    return 8 +
        DiceCalculator.getProficiencyBonus(level) +
        DiceCalculator.getModifier(charisma);
  }

  static int charismaMinimumOne(int charisma) {
    return DiceCalculator.getModifier(charisma).clamp(1, 99).toInt();
  }

  static String elementalAffinityDamageBonus(int charisma) {
    return _signed(DiceCalculator.getModifier(charisma));
  }

  static String spellfireBurstTemporaryHpFormula({
    required int level,
    required int charisma,
  }) {
    final charismaPart = _signed(DiceCalculator.getModifier(charisma));
    if (level >= 14) return '1d4 $charismaPart + $level';
    return '1d4 $charismaPart';
  }

  static String spellfireBurstDamageDie(int level) {
    return level >= 14 ? '1d8' : '1d4';
  }

  static String metamagicLabel(String optionId) {
    return _metamagicOptions[optionId]?.label ?? optionId;
  }

  static String metamagicCostLabel(String optionId) {
    return _metamagicOptions[optionId]?.costLabel ?? 'Sorcery Points';
  }

  static String metamagicSummary(String optionId) {
    return _metamagicOptions[optionId]?.summary ?? '';
  }

  static String metamagicChoiceLabel(List<String> optionIds) {
    return 'Metamagic: ${optionIds.map(metamagicLabel).join(', ')}';
  }

  static String draconicAffinityLabel(String affinityId) {
    return draconicAffinityOptions[affinityId] ?? affinityId;
  }

  static String draconicAffinityChoiceLabel(String affinityId) {
    return 'Elemental Affinity: ${draconicAffinityLabel(affinityId)}';
  }

  static String _signed(int value) {
    if (value == 0) return '+ 0';
    return value > 0 ? '+ $value' : '- ${value.abs()}';
  }

  static String _sorceryCostLabel(String costLabel,
      {required String fallback}) {
    final label = costLabel.trim().isEmpty ? fallback : costLabel.trim();
    return label.replaceAll('1 Sorcery Points', '1 Sorcery Point');
  }

  static String _metamagicSummaryText(
    String id,
    String summary, {
    required String fallback,
  }) {
    final trimmed = summary.trim();
    final quickenedSummary =
        _fallbackMetamagicOptions['quickened_spell']?.summary ?? '';

    if (trimmed.isEmpty ||
        id == 'extended_spell' && trimmed == quickenedSummary) {
      return fallback;
    }
    return trimmed;
  }
}

class _MetamagicOption {
  final String label;
  final String costLabel;
  final String summary;

  const _MetamagicOption({
    required this.label,
    required this.costLabel,
    required this.summary,
  });
}
