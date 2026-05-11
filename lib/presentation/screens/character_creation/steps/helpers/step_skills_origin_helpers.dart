part of '../step_skills.dart';

extension _StepSkillsOriginHelpers on StepSkills {
  Widget _originFeatChoiceCard(CreationState state, WidgetRef ref) {
    final featId = state.backgroundFeatId;
    if (!_originFeatNeedsChoices(featId)) return const SizedBox.shrink();

    final selected = state.originFeatChoices;
    final notifier = ref.read(creationProvider.notifier);

    if (featId == 'skilled') {
      final options = [
        ...StepSkills._skillLabels.entries.map((entry) => _ChoiceOption(
              value: 'skill:${entry.key}',
              label: entry.value,
            )),
        ...StepSkills._artisanTools.map((tool) => _ChoiceOption(
              value: 'tool:$tool',
              label: tool,
            )),
        ...StepSkills._musicalInstruments.map((tool) => _ChoiceOption(
              value: 'tool:$tool',
              label: tool,
            )),
      ];
      return _OriginChoiceCard(
        title: 'Skilled',
        subtitle: 'Choose 3 skills or tools granted by your Origin Feat.',
        selectedText: '${selected.length} / 3 selected',
        options: options,
        selectedValues: selected,
        maxSelections: 3,
        onChanged: notifier.setOriginFeatChoices,
      );
    }

    if (featId == 'crafter') {
      final options = StepSkills._artisanTools
          .map((tool) => _ChoiceOption(value: 'tool:$tool', label: tool))
          .toList();

      return _OriginChoiceCard(
        title: 'Crafter',
        subtitle: "Choose 3 Artisan's Tools granted by your Origin Feat.",
        selectedText: '${selected.length} / 3 selected',
        options: options,
        selectedValues: selected,
        maxSelections: 3,
        onChanged: notifier.setOriginFeatChoices,
      );
    }

    final options = StepSkills._musicalInstruments
        .map((tool) => _ChoiceOption(value: 'tool:$tool', label: tool))
        .toList();

    return _OriginChoiceCard(
      title: 'Musician',
      subtitle: 'Choose 3 Musical Instruments granted by your Origin Feat.',
      selectedText: '${selected.length} / 3 selected',
      options: options,
      selectedValues: selected,
      maxSelections: 3,
      onChanged: notifier.setOriginFeatChoices,
    );
  }

  bool _originFeatNeedsChoices(String featId) {
    return featId == 'skilled' || featId == 'crafter' || featId == 'musician';
  }

  bool _isHumanSpecies(CreationState state) {
    final raceValue = state.race;
    if (!raceValue.contains('::')) return raceValue == 'human';
    return raceValue.split('::').first == 'human';
  }

  List<Widget> _humanSpeciesChoiceCards(CreationState state, WidgetRef ref) {
    if (!_isHumanSpecies(state)) return const [];

    final notifier = ref.read(creationProvider.notifier);
    final cards = <Widget>[];

    final usedSkills = {
      ...state.backgroundSkillProfs,
      ...state.proficientSkills,
      ..._originSkillChoices(state),
      ...state.speciesOriginFeatChoices
          .where((choice) => choice.startsWith('skill:'))
          .map((choice) => choice.replaceFirst('skill:', '')),
      ..._classChoiceSkills(state),
    };

    final skillOptions = StepSkills._skillLabels.entries
        .where((entry) =>
            !usedSkills.contains(entry.key) ||
            state.speciesSkillChoice == entry.key)
        .map((entry) => _ChoiceOption(value: entry.key, label: entry.value))
        .toList();

    cards.add(
      _ClassChoicePanel(
        title: 'Human — Skillful',
        subtitle: 'Choose one skill proficiency granted by your Human species.',
        selectedText: state.speciesSkillChoice.isEmpty
            ? '0 / 1 skill selected'
            : '1 / 1 skill selected',
        options: skillOptions,
        selectedValues: state.speciesSkillChoice.isEmpty
            ? const []
            : [state.speciesSkillChoice],
        maxSelections: 1,
        onChanged: (values) => notifier.setSpeciesSkillChoice(
          values.isEmpty ? '' : values.first,
        ),
      ),
    );

    cards.add(const SizedBox(height: 12));

    final featOptions = kFeatCatalog
        .where((feat) => feat.tags.contains('Origin Feat'))
        .map((feat) => _ChoiceOption(value: feat.id, label: feat.name))
        .toList();

    cards.add(
      _ClassChoicePanel(
        title: 'Human — Versatile',
        subtitle: 'Choose one Origin Feat granted by your Human species.',
        selectedText: state.speciesOriginFeatId.isEmpty
            ? '0 / 1 feat selected'
            : '1 / 1 feat selected',
        options: featOptions,
        selectedValues: state.speciesOriginFeatId.isEmpty
            ? const []
            : [state.speciesOriginFeatId],
        maxSelections: 1,
        onChanged: (values) => notifier.setSpeciesOriginFeatId(
          values.isEmpty ? '' : values.first,
        ),
      ),
    );

    if (_originFeatNeedsChoices(state.speciesOriginFeatId)) {
      cards.add(const SizedBox(height: 12));
      cards.add(_speciesOriginFeatChoiceCard(state, ref));
    }

    cards.add(const SizedBox(height: 12));
    return cards;
  }

  Widget _speciesOriginFeatChoiceCard(CreationState state, WidgetRef ref) {
    final featId = state.speciesOriginFeatId;
    if (!_originFeatNeedsChoices(featId)) return const SizedBox.shrink();

    final selected = state.speciesOriginFeatChoices;
    final notifier = ref.read(creationProvider.notifier);

    if (featId == 'skilled') {
      final options = [
        ...StepSkills._skillLabels.entries.map((entry) => _ChoiceOption(
              value: 'skill:${entry.key}',
              label: entry.value,
            )),
        ...StepSkills._artisanTools.map((tool) => _ChoiceOption(
              value: 'tool:$tool',
              label: tool,
            )),
        ...StepSkills._musicalInstruments.map((tool) => _ChoiceOption(
              value: 'tool:$tool',
              label: tool,
            )),
      ];
      return _OriginChoiceCard(
        title: 'Human — Skilled',
        subtitle: 'Choose 3 skills or tools granted by your Human Origin Feat.',
        selectedText: '${selected.length} / 3 selected',
        options: options,
        selectedValues: selected,
        maxSelections: 3,
        onChanged: notifier.setSpeciesOriginFeatChoices,
      );
    }

    if (featId == 'crafter') {
      final options = StepSkills._artisanTools
          .map((tool) => _ChoiceOption(value: 'tool:$tool', label: tool))
          .toList();

      return _OriginChoiceCard(
        title: 'Human — Crafter',
        subtitle: "Choose 3 Artisan's Tools granted by your Human Origin Feat.",
        selectedText: '${selected.length} / 3 selected',
        options: options,
        selectedValues: selected,
        maxSelections: 3,
        onChanged: notifier.setSpeciesOriginFeatChoices,
      );
    }

    final options = StepSkills._musicalInstruments
        .map((tool) => _ChoiceOption(value: 'tool:$tool', label: tool))
        .toList();

    return _OriginChoiceCard(
      title: 'Human — Musician',
      subtitle:
          'Choose 3 Musical Instruments granted by your Human Origin Feat.',
      selectedText: '${selected.length} / 3 selected',
      options: options,
      selectedValues: selected,
      maxSelections: 3,
      onChanged: notifier.setSpeciesOriginFeatChoices,
    );
  }

  List<String> _originSkillChoices(CreationState state) {
    return state.originFeatChoices
        .where((choice) => choice.startsWith('skill:'))
        .map((choice) => choice.replaceFirst('skill:', ''))
        .toList();
  }

  List<String> _speciesSkillChoices(CreationState state) {
    return [
      if (state.speciesSkillChoice.isNotEmpty) state.speciesSkillChoice,
      ...state.speciesOriginFeatChoices
          .where((choice) => choice.startsWith('skill:'))
          .map((choice) => choice.replaceFirst('skill:', '')),
    ];
  }

  List<String> _classChoiceSkills(CreationState state) {
    final barbarianPrimalSkill = BarbarianChoiceService.needsPrimalKnowledge(
      className: state.className,
      level: state.level,
    )
        ? BarbarianChoiceService.selectedPrimalKnowledgeSkill(
            state.levelAdvancements,
          )
        : null;
    final clericKnowledgeSkills = ClericChoiceService.needsKnowledgeChoices(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )
        ? ClericChoiceService.selectedKnowledgeSkills(state.levelAdvancements)
        : const <String>[];
    final battleMasterStudentSkill = FighterChoiceService.isBattleMaster(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )
        ? FighterChoiceService.selectedBattleMasterStudentSkill(
            state.levelAdvancements,
          )
        : null;
    final paladinGenieSkill = PaladinChoiceService.isNobleGenies(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )
        ? PaladinChoiceService.selectedGenieSplendorSkill(
            state.levelAdvancements,
          )
        : null;
    final rangerFeyGlamourSkill = RangerChoiceService.needsFeyGlamourSkill(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )
        ? RangerChoiceService.selectedFeyGlamourSkill(state.levelAdvancements)
        : null;
    final bardLoreBonusSkills = BardChoiceService.needsLoreBonusSkills(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )
        ? BardChoiceService.selectedLoreBonusSkills(state.levelAdvancements)
        : const <String>[];
    final bardMoonSkill = BardChoiceService.isMoon(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )
        ? BardChoiceService.selectedMoonSkill(state.levelAdvancements)
        : null;
    final monkSubclassSkills = MonkChoiceService.subclassSkillProficiencies(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    );
    final artificerSkills = ArtificerChoiceService.needsBaseChoices(
      className: state.className,
      level: state.level,
    )
        ? ArtificerChoiceService.selectedSkillProficiencies(
            state.levelAdvancements,
          )
        : const <String>[];

    return [
      ...artificerSkills,
      ...bardLoreBonusSkills,
      if (bardMoonSkill != null) bardMoonSkill,
      if (barbarianPrimalSkill != null) barbarianPrimalSkill,
      ...clericKnowledgeSkills,
      if (battleMasterStudentSkill != null) battleMasterStudentSkill,
      if (paladinGenieSkill != null) paladinGenieSkill,
      if (rangerFeyGlamourSkill != null) rangerFeyGlamourSkill,
      ...monkSubclassSkills,
    ];
  }

  List<String> _allCurrentProficientSkills(CreationState state) {
    final skills = {
      ...state.backgroundSkillProfs,
      ...state.proficientSkills,
      ..._originSkillChoices(state),
      ..._speciesSkillChoices(state),
      ..._classChoiceSkills(state),
    }.toList();

    skills.sort((left, right) {
      return (StepSkills._skillLabels[left] ?? left)
          .compareTo(StepSkills._skillLabels[right] ?? right);
    });
    return skills;
  }
}
