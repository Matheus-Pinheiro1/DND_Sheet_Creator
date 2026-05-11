part of 'character_creation_provider.dart';

extension CreationStateAdvancementBuilder on CreationState {
  int _bonusHpFromFeats(List<String> entries) {
    final hasTough = backgroundFeatId == 'tough' ||
        (_isHumanSpecies && speciesOriginFeatId == 'tough') ||
        entries.any((entry) {
          final payload = _advancementPayload(entry);
          return payload.length >= 2 &&
              payload.first == 'feat' &&
              payload[1] == 'tough';
        });

    return hasTough ? level * 2 : 0;
  }

  List<String> _classAdvancementEntries(List<String> entries) {
    return entries
        .where((entry) =>
            !entry.startsWith('origin_') &&
            !entry.startsWith('class_choice:') &&
            !entry.startsWith('species_choice:'))
        .toList();
  }

  List<String> _choiceValues(List<String> choices, String prefix) {
    return choices
        .where((choice) => choice.startsWith(prefix))
        .map((choice) => choice.replaceFirst(prefix, ''))
        .where((choice) => choice.trim().isNotEmpty)
        .toList();
  }

  List<String> _skillChoicesFromAdvancements(List<String> entries) {
    return _extraChoicesFromAdvancements(entries)
        .where((choice) => choice.startsWith('skill:'))
        .map((choice) => choice.replaceFirst('skill:', ''))
        .where((choice) => choice.trim().isNotEmpty)
        .toList();
  }

  List<String> _toolChoicesFromAdvancements(List<String> entries) {
    return _extraChoicesFromAdvancements(entries)
        .where((choice) => choice.startsWith('tool:'))
        .map((choice) => choice.replaceFirst('tool:', ''))
        .where((choice) => choice.trim().isNotEmpty)
        .toList();
  }

  List<String> _expertiseChoicesFromAdvancements(List<String> entries) {
    return _extraChoicesFromAdvancements(entries)
        .where((choice) => choice.startsWith('expertise:'))
        .map((choice) {
      final skill = choice.replaceFirst('expertise:', '');
      final label = _skillLabel(skill);
      return 'Expertise: $label';
    }).toList();
  }

  List<String> _spellChoicesFromAdvancements(List<String> entries) {
    final spells = <String>[];
    for (final entry in entries) {
      final payload = _advancementPayload(entry);
      if (payload.length < 5 || payload.first != 'feat') continue;
      if (!ProgressionService.isMagicInitiateId(payload[1])) continue;

      for (final cantrip in _splitChoices(payload[3])) {
        if (cantrip.isNotEmpty) spells.add(cantrip);
      }
      if (payload[4].isNotEmpty) spells.add(payload[4]);
    }
    return spells;
  }

  List<dynamic> _backgroundEquipmentOptions() {
    return backgroundEquipmentOptions;
  }

  List<String> _extraChoicesFromAdvancements(List<String> entries) {
    final choices = <String>[];
    for (final entry in entries) {
      final payload = _advancementPayload(entry);
      if (payload.length < 4 || payload.first != 'feat') continue;
      if (ProgressionService.isMagicInitiateId(payload[1])) continue;
      choices.addAll(payload.sublist(3).join(':').split('|'));
    }
    return choices.where((choice) => choice.trim().isNotEmpty).toList();
  }

  List<String> _advancementPayload(String entry) {
    if (entry.startsWith('level:')) {
      final parts = entry.split(':');
      if (parts.length < 4) return const [];
      return parts.skip(2).toList();
    }

    if (entry.startsWith('asi:') || entry.startsWith('feat:')) {
      return entry.split(':');
    }

    return const [];
  }

  List<String> _splitChoices(String value) {
    return value
        .split(',')
        .map((choice) => choice.trim())
        .where((choice) => choice.isNotEmpty)
        .toList();
  }

  String _skillLabel(String index) {
    const labels = {
      'acrobatics': 'Acrobatics',
      'animal-handling': 'Animal Handling',
      'arcana': 'Arcana',
      'athletics': 'Athletics',
      'deception': 'Deception',
      'history': 'History',
      'insight': 'Insight',
      'intimidation': 'Intimidation',
      'investigation': 'Investigation',
      'medicine': 'Medicine',
      'nature': 'Nature',
      'perception': 'Perception',
      'performance': 'Performance',
      'persuasion': 'Persuasion',
      'religion': 'Religion',
      'sleight-of-hand': 'Sleight of Hand',
      'stealth': 'Stealth',
      'survival': 'Survival',
    };
    return labels[index] ?? index;
  }

  List<String> _buildOriginAdvancements() {
    final entries = <String>[];

    if (backgroundFeatId.isNotEmpty) {
      entries.add('origin_feat:$backgroundFeatId');
    }

    if (backgroundBonusChoices.isNotEmpty) {
      final counts = <String, int>{};
      for (final ability in backgroundBonusChoices) {
        counts.update(ability, (value) => value + 1, ifAbsent: () => 1);
      }
      final parts =
          counts.entries.map((entry) => '${entry.key}+${entry.value}').toList();
      entries.add('origin_asi:${parts.join(',')}');
    }

    if (originFeatSpellAbility.isNotEmpty) {
      entries.add('origin_feat_ability:$originFeatSpellAbility');
    }
    for (final cantrip in originFeatCantrips) {
      entries.add('origin_cantrip:$cantrip');
    }
    if (originFeatSpell.isNotEmpty) {
      entries.add('origin_spell:$originFeatSpell');
    }
    for (final choice in originFeatChoices) {
      entries.add('origin_choice:$choice');
    }

    return entries;
  }

  bool get _isHumanSpecies => _baseRaceId(race) == 'human';

  String _baseRaceId(String raceValue) {
    if (!raceValue.contains('::')) return raceValue;
    return raceValue.split('::').first;
  }

  List<String> _buildChoiceAdvancements() {
    final entries = <String>[];

    if (_isHumanSpecies) {
      if (speciesSkillChoice.isNotEmpty) {
        entries.add('species_choice:skillful:$speciesSkillChoice');
      }
      if (speciesOriginFeatId.isNotEmpty) {
        entries.add('species_choice:versatile_feat:$speciesOriginFeatId');
      }
      if (speciesOriginFeatSpellAbility.isNotEmpty) {
        entries.add(
          'species_choice:versatile_feat_ability:$speciesOriginFeatSpellAbility',
        );
      }
      for (final cantrip in speciesOriginFeatCantrips) {
        entries.add('species_choice:versatile_cantrip:$cantrip');
      }
      if (speciesOriginFeatSpell.isNotEmpty) {
        entries.add('species_choice:versatile_spell:$speciesOriginFeatSpell');
      }
      for (final choice in speciesOriginFeatChoices) {
        entries.add('species_choice:versatile_choice:$choice');
      }
    }

    if (speciesSpellAbility.isNotEmpty) {
      entries.add('species_choice:spell_ability:$speciesSpellAbility');
    }
    if (speciesGrantedCantrip.isNotEmpty) {
      entries.add('species_choice:granted_cantrip:$speciesGrantedCantrip');
    }
    if (clericDivineOrder.isNotEmpty) {
      entries.add('class_choice:divine_order:$clericDivineOrder');
    }
    if (clericThaumaturgeCantrip.isNotEmpty) {
      entries.add(
        'class_choice:divine_order_cantrip:$clericThaumaturgeCantrip',
      );
    }
    if (classEquipmentChoiceId.isNotEmpty) {
      entries.add(
        '${StartingEquipmentService.classEquipmentEntryPrefix}$classEquipmentChoiceId',
      );
    }
    if (backgroundEquipmentChoiceId.isNotEmpty) {
      entries.add(
        '${StartingEquipmentService.backgroundEquipmentEntryPrefix}$backgroundEquipmentChoiceId',
      );
    }

    final preservedClassChoices = levelAdvancements.where((entry) {
      if (!entry.startsWith('class_choice:')) return false;
      if (entry.startsWith('class_choice:divine_order:')) return false;
      if (entry.startsWith('class_choice:divine_order_cantrip:')) return false;
      if (StartingEquipmentService.isStartingEquipmentEntry(entry)) {
        return false;
      }
      if (RogueChoiceService.isRogueChoiceEntry(entry)) {
        return false;
      }
      if (ClericChoiceService.isClericChoiceEntry(entry)) {
        return false;
      }
      if (BardChoiceService.isBardChoiceEntry(entry)) {
        return false;
      }
      if (DruidChoiceService.isDruidChoiceEntry(entry)) {
        return false;
      }
      if (RangerChoiceService.isRangerChoiceEntry(entry)) {
        return false;
      }
      if (SorcererChoiceService.isSorcererChoiceEntry(entry)) {
        return false;
      }
      if (WarlockChoiceService.isWarlockChoiceEntry(entry)) {
        return false;
      }
      if (BarbarianChoiceService.isBarbarianChoiceEntry(entry)) {
        return false;
      }
      if (FighterChoiceService.isFighterChoiceEntry(entry)) {
        return false;
      }
      if (PaladinChoiceService.isPaladinChoiceEntry(entry)) {
        return false;
      }
      return true;
    });
    entries.addAll(preservedClassChoices);

    if (className == 'rogue') {
      entries.addAll(
        RogueChoiceService.preservedEntriesForLevel(
          levelAdvancements,
          characterLevel: level,
        ),
      );
    }
    if (className == 'cleric') {
      entries.addAll(
        ClericChoiceService.preservedEntriesForLevel(
          levelAdvancements,
          characterLevel: level,
        ),
      );
    }
    if (className == 'bard') {
      entries.addAll(
        BardChoiceService.preservedEntriesForLevel(
          levelAdvancements,
          characterLevel: level,
          subclass: subclass,
        ),
      );
    }
    if (className == 'ranger') {
      entries.addAll(
        RangerChoiceService.preservedEntriesForLevel(
          levelAdvancements,
          characterLevel: level,
        ),
      );
    }
    if (className == 'druid') {
      entries.addAll(
        DruidChoiceService.preservedEntriesForLevel(
          levelAdvancements,
          characterLevel: level,
          subclass: subclass,
        ),
      );
    }
    if (className == 'sorcerer') {
      entries.addAll(
        SorcererChoiceService.preservedEntriesForLevel(
          levelAdvancements,
          characterLevel: level,
        ),
      );
    }
    if (className == 'warlock') {
      entries.addAll(
        WarlockChoiceService.preservedEntriesForLevel(
          levelAdvancements,
          characterLevel: level,
        ),
      );
    }
    if (className == 'barbarian') {
      entries.addAll(
        BarbarianChoiceService.preservedEntriesForLevel(
          levelAdvancements,
          characterLevel: level,
        ),
      );
    }
    if (className == 'fighter') {
      entries.addAll(
        FighterChoiceService.preservedEntriesForLevel(
          levelAdvancements,
          characterLevel: level,
        ),
      );
    }
    if (className == 'paladin') {
      entries.addAll(
        PaladinChoiceService.preservedEntriesForLevel(
          levelAdvancements,
          characterLevel: level,
        ),
      );
    }

    return entries;
  }

  List<int> _normalizedSlotUsage(List<int> used, List<int> max) {
    final values = List<int>.filled(9, 0);
    for (var i = 0; i < values.length; i++) {
      final previous = i < used.length ? used[i] : 0;
      final limit = i < max.length ? max[i] : 0;
      values[i] = previous.clamp(0, limit).toInt();
    }
    return values;
  }
}
