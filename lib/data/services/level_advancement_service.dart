import '../../data/models/character_model.dart';
import '../../data/models/feat_model.dart';
import 'progression_service.dart';

class LevelAdvancementService {
  const LevelAdvancementService._();

  static const int normalAbilityCap = 20;
  static const int epicAbilityCap = 30;

  static bool _hasFeatTag(FeatModel feat, String tag) {
    final expected = tag.trim().toLowerCase();

    return feat.tags.any((current) {
      return current.trim().toLowerCase() == expected;
    });
  }

  static bool isOriginFeat(FeatModel feat) {
    return _hasFeatTag(feat, 'Origin Feat');
  }

  static bool isGeneralFeat(FeatModel feat) {
    return _hasFeatTag(feat, 'General Feat');
  }

  static bool isEpicBoon(FeatModel feat) {
    return _hasFeatTag(feat, 'Epic Boon');
  }

  static bool canChooseOriginFeat(FeatModel feat) {
    return isOriginFeat(feat);
  }

  static bool canChooseLevelFeat(FeatModel feat, int advancementLevel) {
    if (isOriginFeat(feat)) return false;

    if (advancementLevel >= 19) {
      return isEpicBoon(feat) && feat.minimumLevel <= advancementLevel;
    }

    if (advancementLevel >= 4) {
      return isGeneralFeat(feat) && feat.minimumLevel <= advancementLevel;
    }

    return false;
  }

  static bool canChooseFeatForAdvancement(
    FeatModel feat, {
    required int advancementLevel,
    required Iterable<String> levelAdvancements,
    String? currentEntry,
  }) {
    if (!canChooseLevelFeat(feat, advancementLevel)) return false;

    return !hasChosenLevelFeat(
      levelAdvancements,
      feat,
      currentEntry: currentEntry,
    );
  }

  static bool hasChosenLevelFeat(
    Iterable<String> levelAdvancements,
    FeatModel feat, {
    String? currentEntry,
  }) {
    final featId = _normalizeFeatId(feat.id);

    for (final entry in levelAdvancements) {
      if (currentEntry != null && entry == currentEntry) continue;
      if (!isClassLevelEntry(entry)) continue;

      final chosenFeatId = featIdFromEntry(entry);
      if (chosenFeatId == featId) return true;
    }

    return false;
  }

  static String? featIdFromEntry(String entry) {
    final payload = _payload(entry);
    if (payload.length < 2 || payload.first != 'feat') return null;
    return _normalizeFeatId(payload[1]);
  }

  static String _normalizeFeatId(String value) {
    return value.trim().toLowerCase();
  }

  static bool isHiddenOriginDetail(String value) {
    return value.startsWith('origin_feat_name:') ||
        value.startsWith('origin_feat_ability:') ||
        value.startsWith('origin_cantrip:') ||
        value.startsWith('origin_spell:');
  }

  static bool isOriginEntry(String value) {
    return value.startsWith('origin_');
  }

  static bool isVisibleOriginEntry(String value) {
    return isOriginEntry(value) && !isHiddenOriginDetail(value);
  }

  static bool isClassLevelEntry(String value) {
    if (isOriginEntry(value) || isHiddenOriginDetail(value)) return false;
    return value.startsWith('level:') ||
        value.startsWith('asi:') ||
        value.startsWith('feat:');
  }

  static List<String> visibleOriginEntries(CharacterModel character) {
    return character.levelAdvancements
        .where(isVisibleOriginEntry)
        .toList(growable: false);
  }

  static List<String> classLevelEntries(CharacterModel character) {
    return character.levelAdvancements
        .where(isClassLevelEntry)
        .toList(growable: false);
  }

  static int availableCount(String className, int level) {
    return ProgressionService.getAvailableAdvancementCount(className, level);
  }

  static int spentCount(CharacterModel character) {
    return classLevelEntries(character).length;
  }

  static int remainingCount(CharacterModel character) {
    final remaining = availableCount(character.className, character.level) -
        spentCount(character);
    return remaining < 0 ? 0 : remaining;
  }

  static List<int> availableLevels(String className, int level) {
    return ProgressionService.getAdvancementLevels(className)
        .where((item) => item <= level)
        .toList(growable: false);
  }

  static int? nextAvailableLevel(CharacterModel character) {
    final levels = availableLevels(character.className, character.level);
    final used = usedClassLevels(character);
    for (final level in levels) {
      if (!used.contains(level)) return level;
    }
    return null;
  }

  static Set<int> usedClassLevels(CharacterModel character) {
    final levels = availableLevels(character.className, character.level);
    final used = <int>{};
    var legacyIndex = 0;

    for (final entry in classLevelEntries(character)) {
      final parsed = levelFromEntry(entry);
      if (parsed != null) {
        used.add(parsed);
        continue;
      }

      while (
          legacyIndex < levels.length && used.contains(levels[legacyIndex])) {
        legacyIndex++;
      }
      if (legacyIndex < levels.length) {
        used.add(levels[legacyIndex]);
        legacyIndex++;
      }
    }

    return used;
  }

  static int? levelFromEntry(String value) {
    if (!value.startsWith('level:')) return null;
    final parts = value.split(':');
    if (parts.length < 4) return null;
    return int.tryParse(parts[1]);
  }

  static String kindFromEntry(String value) {
    final payload = _payload(value);
    if (payload.isEmpty) return 'unknown';
    return payload.first;
  }

  static String encodeAsi({
    required int level,
    required String rawBonuses,
  }) {
    return 'level:$level:asi:$rawBonuses';
  }

  static String encodeFeat({
    required int level,
    required String featId,
    String? ability,
    String? magicInitiateAbility,
    List<String> magicInitiateCantrips = const [],
    String? magicInitiateSpell,
  }) {
    if (ProgressionService.isMagicInitiateId(featId)) {
      final abilityValue = magicInitiateAbility ?? ability ?? '';
      final cantrips = magicInitiateCantrips.join(',');
      final spell = magicInitiateSpell ?? '';
      return 'level:$level:feat:$featId:$abilityValue:$cantrips:$spell';
    }
    if (ability == null || ability.isEmpty) {
      return 'level:$level:feat:$featId';
    }
    return 'level:$level:feat:$featId:$ability';
  }

  static String formatEntry(String value) {
    if (value.startsWith('origin_asi:')) {
      final raw = value.replaceFirst('origin_asi:', '');
      return 'Origin / Background ASI — ${_formatBonuses(raw)}';
    }

    if (value.startsWith('origin_feat:')) {
      final featId = value.replaceFirst('origin_feat:', '');
      final feat = ProgressionService.findFeat(featId);
      return 'Origin Feat — ${feat?.name ?? _humanize(featId)}';
    }

    final payload = _payload(value);
    if (payload.isEmpty) return value;

    final level = levelFromEntry(value);
    final prefix = level == null ? 'Level Advancement' : 'Level $level';

    if (payload.first == 'asi' && payload.length >= 2) {
      return '$prefix ASI — ${_formatBonuses(payload[1])}';
    }

    if (payload.first == 'feat' && payload.length >= 2) {
      final featId = payload[1];
      final feat = ProgressionService.findFeat(featId);
      if (ProgressionService.isMagicInitiateId(featId)) {
        return '$prefix Feat — ${feat?.name ?? _humanize(featId)}';
      }
      final ability = payload.length >= 3 && payload[2].isNotEmpty
          ? ' (+1 ${payload[2].toUpperCase()})'
          : '';
      return '$prefix Feat — ${feat?.name ?? _humanize(featId)}$ability';
    }

    return value;
  }

  static String detailName(String value) {
    if (value.startsWith('origin_asi:')) return 'Origin / Background ASI';
    if (value.startsWith('origin_feat:')) {
      final featId = value.replaceFirst('origin_feat:', '');
      return ProgressionService.findFeat(featId)?.name ?? _humanize(featId);
    }

    final payload = _payload(value);
    final level = levelFromEntry(value);
    final prefix = level == null ? '' : 'Level $level — ';
    if (payload.isEmpty) return value;

    if (payload.first == 'asi') return '${prefix}Ability Score Improvement';
    if (payload.first == 'feat' && payload.length >= 2) {
      final feat = ProgressionService.findFeat(payload[1]);
      return '$prefix${feat?.name ?? _humanize(payload[1])}';
    }
    return value;
  }

  static String detailDescription(String value) {
    if (value.startsWith('origin_asi:')) {
      final raw = value.replaceFirst('origin_asi:', '');
      return 'Background ability increases applied to this character: ${_formatBonuses(raw)}. These increases remain part of the character and do not spend level 4, 8, 12, 16, or 19 ASI / feat choices.';
    }

    if (value.startsWith('origin_feat:')) {
      final featId = value.replaceFirst('origin_feat:', '');
      final feat = ProgressionService.findFeat(featId);
      if (feat == null) return 'Origin feat: ${_humanize(featId)}.';
      return '${feat.description}\n\nThis is an Origin Feat. It remains active and does not spend level ASI / feat choices.';
    }

    final payload = _payload(value);
    if (payload.isEmpty) return value;

    if (payload.first == 'asi' && payload.length >= 2) {
      return 'Ability Score Improvement applied: ${_formatBonuses(payload[1])}. The ability scores on the sheet already include this increase.';
    }

    if (payload.first == 'feat' && payload.length >= 2) {
      final featId = payload[1];
      final feat = ProgressionService.findFeat(featId);
      final lines = <String>[];
      if (feat != null && feat.description.trim().isNotEmpty) {
        lines.add(feat.description.trim());
      } else {
        lines.add('Feat selected: ${_humanize(featId)}.');
      }

      if (ProgressionService.isMagicInitiateId(featId)) {
        final ability = payload.length > 2 ? payload[2].toUpperCase() : '';
        final cantrips = payload.length > 3 && payload[3].isNotEmpty
            ? payload[3].split(',').map(_humanize).join(', ')
            : '';
        final spell = payload.length > 4 ? _humanize(payload[4]) : '';
        final extras = <String>[];
        if (ability.isNotEmpty) extras.add('Spellcasting ability: $ability');
        if (cantrips.isNotEmpty) extras.add('Cantrips: $cantrips');
        if (spell.isNotEmpty) extras.add('Level 1 spell: $spell');
        if (extras.isNotEmpty) lines.add(extras.join('\n'));
      } else if (payload.length > 2 && payload[2].isNotEmpty) {
        lines.add('Applied ability increase: +1 ${payload[2].toUpperCase()}.');
      }

      return lines.join('\n\n');
    }

    return value;
  }

  static int abilityCapForAdvancementLevel(int level) {
    return level >= 19 ? epicAbilityCap : normalAbilityCap;
  }

  static bool canIncreaseAbility({
    required int currentScore,
    required int increase,
    required int advancementLevel,
  }) {
    final cap = abilityCapForAdvancementLevel(advancementLevel);
    return currentScore < cap && currentScore + increase <= cap;
  }

  static int cappedIncrease({
    required int currentScore,
    required int requestedIncrease,
    required int advancementLevel,
  }) {
    final cap = abilityCapForAdvancementLevel(advancementLevel);
    final room = cap - currentScore;
    if (room <= 0) return 0;
    if (requestedIncrease > room) return room;
    return requestedIncrease;
  }

  static List<String> _payload(String value) {
    if (value.startsWith('level:')) {
      final parts = value.split(':');
      if (parts.length < 4) return const [];
      return parts.skip(2).toList(growable: false);
    }
    if (value.startsWith('asi:') || value.startsWith('feat:')) {
      return value.split(':');
    }
    return const [];
  }

  static String _formatBonuses(String raw) {
    return raw
        .split(',')
        .where((item) => item.trim().isNotEmpty)
        .map((item) => item.trim().toUpperCase())
        .join(' and ');
  }

  static String _humanize(String value) {
    return value
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}
