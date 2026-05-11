part of '../step_skills.dart';

extension _StepSkillsBardRogueRangerHelpers on StepSkills {
  List<Widget> _bardMoonPrimalLoreSkillCards(
    CreationState state,
    WidgetRef ref,
  ) {
    if (!BardChoiceService.isMoon(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return const [];
    }

    final baseSkills = {
      ...state.backgroundSkillProfs,
      ...state.proficientSkills,
      ..._originSkillChoices(state),
      ..._speciesSkillChoices(state),
    };
    final selected = BardChoiceService.selectedMoonSkill(
      state.levelAdvancements,
    );
    final options = BardChoiceService.moonSkillOptions
        .where((skill) => !baseSkills.contains(skill) || selected == skill)
        .map(
          (skill) => _ChoiceOption(
            value: skill,
            label: StepSkills._skillLabels[skill] ??
                BardChoiceService.skillLabel(skill),
          ),
        )
        .toList();

    return [
      _ClassChoicePanel(
        title: 'Primal Lore',
        subtitle: 'Choose 1 skill granted by College of the Moon.',
        selectedText: options.isEmpty
            ? 'No eligible skill left'
            : selected == null
                ? '0 / 1 selected'
                : '1 / 1 selected',
        options: options,
        selectedValues: selected == null ? const [] : [selected],
        maxSelections: options.isEmpty ? 0 : 1,
        onChanged: (values) {
          ref
              .read(creationProvider.notifier)
              .setBardMoonSkill(values.isEmpty ? '' : values.first);
        },
      ),
      const SizedBox(height: 12),
    ];
  }

  List<Widget> _bardLoreBonusSkillChoiceCards(
    CreationState state,
    WidgetRef ref,
  ) {
    if (!BardChoiceService.needsLoreBonusSkills(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return const [];
    }

    final baseSkills = {
      ...state.backgroundSkillProfs,
      ...state.proficientSkills,
      ..._originSkillChoices(state),
      ..._speciesSkillChoices(state),
    };
    final selected =
        BardChoiceService.selectedLoreBonusSkills(state.levelAdvancements);
    final options = BardChoiceService.loreSkillOptions
        .where(
          (skill) => !baseSkills.contains(skill) || selected.contains(skill),
        )
        .map(
          (skill) => _ChoiceOption(
            value: skill,
            label: StepSkills._skillLabels[skill] ??
                BardChoiceService.skillLabel(skill),
          ),
        )
        .toList();
    final required = options.length < BardChoiceService.loreBonusSkillCount
        ? options.length
        : BardChoiceService.loreBonusSkillCount;

    return [
      _ClassChoicePanel(
        title: 'Bonus Proficiencies',
        subtitle: 'Choose 3 skills granted by College of Lore.',
        selectedText: '${selected.length} / $required selected',
        options: options,
        selectedValues: selected,
        maxSelections: required,
        onChanged: (values) {
          ref.read(creationProvider.notifier).setBardLoreBonusSkills(values);
        },
      ),
      const SizedBox(height: 12),
    ];
  }

  List<Widget> _bardExpertiseChoiceCards(CreationState state, WidgetRef ref) {
    if (state.className != 'bard') {
      return const [];
    }

    final unlockedLevels = BardChoiceService.unlockedExpertiseLevels(
      state.level,
    );
    if (unlockedLevels.isEmpty) {
      return const [];
    }

    final proficientSkills = _allCurrentProficientSkills(state);
    final cards = <Widget>[];

    for (final bardLevel in unlockedLevels) {
      final selected = BardChoiceService.selectedExpertiseSkills(
        state.levelAdvancements,
        bardLevel: bardLevel,
      );
      final otherSelections = unlockedLevels
          .where((level) => level != bardLevel)
          .expand(
            (level) => BardChoiceService.selectedExpertiseSkills(
              state.levelAdvancements,
              bardLevel: level,
            ),
          )
          .toSet();

      final options = proficientSkills
          .where(
            (skill) =>
                !otherSelections.contains(skill) || selected.contains(skill),
          )
          .map(
            (skill) => _ChoiceOption(
              value: skill,
              label: StepSkills._skillLabels[skill] ??
                  BardChoiceService.skillLabel(skill),
            ),
          )
          .toList();

      if (cards.isNotEmpty) {
        cards.add(const SizedBox(height: 12));
      }

      cards.add(
        _RangerExpertiseCard(
          title: bardLevel == 2 ? 'Expertise' : 'Expertise (Level $bardLevel)',
          subtitle: bardLevel == 2
              ? 'Choose 2 of your skill proficiencies. These skills gain Expertise.'
              : 'Choose 2 more skill proficiencies. These skills gain Expertise.',
          options: options,
          selectedValues: selected,
          maxSelections:
              BardChoiceService.requiredExpertiseSelectionsForLevel(bardLevel),
          onChanged: (values) {
            ref.read(creationProvider.notifier).setBardExpertiseChoices(
                  bardLevel: bardLevel,
                  skillIndices: values,
                );
          },
        ),
      );
    }

    if (cards.isNotEmpty) {
      cards.add(const SizedBox(height: 12));
    }

    return cards;
  }

  List<Widget> _rogueExpertiseChoiceCards(CreationState state, WidgetRef ref) {
    if (state.className != 'rogue') {
      return const [];
    }

    final unlockedLevels = RogueChoiceService.unlockedExpertiseLevels(
      state.level,
    );
    if (unlockedLevels.isEmpty) {
      return const [];
    }

    final proficientSkills = {
      ...state.backgroundSkillProfs,
      ...state.proficientSkills,
      ..._originSkillChoices(state),
      ..._speciesSkillChoices(state),
    }.toList()
      ..sort((left, right) {
        return (StepSkills._skillLabels[left] ?? left)
            .compareTo(StepSkills._skillLabels[right] ?? right);
      });

    final cards = <Widget>[];
    for (final rogueLevel in unlockedLevels) {
      final selected = RogueChoiceService.selectedExpertiseSkills(
        state.levelAdvancements,
        rogueLevel: rogueLevel,
      );
      final otherSelections = unlockedLevels
          .where((level) => level != rogueLevel)
          .expand(
            (level) => RogueChoiceService.selectedExpertiseSkills(
              state.levelAdvancements,
              rogueLevel: level,
            ),
          )
          .toSet();

      final options = proficientSkills
          .where(
            (skill) =>
                !otherSelections.contains(skill) || selected.contains(skill),
          )
          .map(
            (skill) => _ChoiceOption(
              value: skill,
              label: StepSkills._skillLabels[skill] ??
                  RogueChoiceService.skillLabel(skill),
            ),
          )
          .toList();

      if (cards.isNotEmpty) {
        cards.add(const SizedBox(height: 12));
      }

      cards.add(
        _RogueExpertiseCard(
          rogueLevel: rogueLevel,
          options: options,
          selectedValues: selected,
          maxSelections:
              RogueChoiceService.requiredSelectionsForLevel(rogueLevel),
          onChanged: (values) {
            ref.read(creationProvider.notifier).setRogueExpertiseChoices(
                  rogueLevel: rogueLevel,
                  skillIndices: values,
                );
          },
        ),
      );
    }

    if (cards.isNotEmpty) {
      cards.add(const SizedBox(height: 12));
    }

    return cards;
  }

  List<Widget> _rangerChoiceCards(CreationState state, WidgetRef ref) {
    if (state.className != 'ranger') {
      return const [];
    }

    final cards = <Widget>[];
    final proficientSkills = _allCurrentProficientSkills(state);
    final unlockedLevels = RangerChoiceService.unlockedExpertiseLevels(
      state.level,
    );

    for (final rangerLevel in unlockedLevels) {
      final selected = RangerChoiceService.selectedExpertiseSkills(
        state.levelAdvancements,
        rangerLevel: rangerLevel,
      );
      final otherSelections = unlockedLevels
          .where((level) => level != rangerLevel)
          .expand(
            (level) => RangerChoiceService.selectedExpertiseSkills(
              state.levelAdvancements,
              rangerLevel: level,
            ),
          )
          .toSet();

      final options = proficientSkills
          .where(
            (skill) =>
                !otherSelections.contains(skill) || selected.contains(skill),
          )
          .map(
            (skill) => _ChoiceOption(
              value: skill,
              label: StepSkills._skillLabels[skill] ??
                  RangerChoiceService.skillLabel(skill),
            ),
          )
          .toList();

      if (cards.isNotEmpty) {
        cards.add(const SizedBox(height: 12));
      }

      cards.add(
        _RangerExpertiseCard(
          title: rangerLevel == 2
              ? 'Deft Explorer'
              : 'Expertise (Level $rangerLevel)',
          subtitle: rangerLevel == 2
              ? 'Choose 1 skill proficiency. That skill gains Expertise from Deft Explorer.'
              : 'Choose 2 more skill proficiencies. Those skills gain Expertise.',
          options: options,
          selectedValues: selected,
          maxSelections:
              RangerChoiceService.requiredExpertiseSelectionsForLevel(
                  rangerLevel),
          onChanged: (values) {
            ref.read(creationProvider.notifier).setRangerExpertiseChoices(
                  rangerLevel: rangerLevel,
                  skillIndices: values,
                );
          },
        ),
      );
    }

    if (state.level >= 2) {
      if (cards.isNotEmpty) {
        cards.add(const SizedBox(height: 12));
      }
      final selectedLanguages = RangerChoiceService.selectedLanguages(
        state.levelAdvancements,
      );
      cards.add(
        _RangerLanguageCard(
          selectedValues: selectedLanguages,
          onChanged: (values) =>
              ref.read(creationProvider.notifier).setRangerLanguages(values),
        ),
      );
    }

    if (cards.isNotEmpty) {
      cards.add(const SizedBox(height: 12));
    }

    return cards;
  }

  List<Widget> _barbarianChoiceCards(CreationState state, WidgetRef ref) {
    if (!BarbarianChoiceService.needsPrimalKnowledge(
      className: state.className,
      level: state.level,
    )) {
      return const [];
    }

    final selected = BarbarianChoiceService.selectedPrimalKnowledgeSkill(
      state.levelAdvancements,
    );
    final alreadyProficient = {
      ...state.backgroundSkillProfs,
      ...state.proficientSkills,
      ..._originSkillChoices(state),
      ..._speciesSkillChoices(state),
    };
    final options = BarbarianChoiceService.skillOptions
        .where(
            (skill) => !alreadyProficient.contains(skill) || selected == skill)
        .map(
          (skill) => _ChoiceOption(
            value: skill,
            label: StepSkills._skillLabels[skill] ??
                BarbarianChoiceService.skillLabel(skill),
          ),
        )
        .toList();

    return [
      _BarbarianPrimalKnowledgeCard(
        options: options,
        selectedValue: selected,
        isSelectionValid: options.isEmpty ||
            (selected != null && !alreadyProficient.contains(selected)),
        onChanged: (skill) => ref
            .read(creationProvider.notifier)
            .setBarbarianPrimalKnowledgeSkill(skill),
      ),
      const SizedBox(height: 12),
    ];
  }
}
