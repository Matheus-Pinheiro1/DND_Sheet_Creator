part of '../step_skills.dart';

extension _StepSkillsChoiceHelpers on StepSkills {
  List<Widget> _clericKnowledgeChoiceCards(CreationState state, WidgetRef ref) {
    if (!ClericChoiceService.needsKnowledgeChoices(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return const [];
    }

    final selectedSkills = ClericChoiceService.selectedKnowledgeSkills(
      state.levelAdvancements,
    );
    final selectedTool = ClericChoiceService.selectedKnowledgeTool(
      state.levelAdvancements,
    );
    final notifier = ref.read(creationProvider.notifier);

    return [
      _ClassChoicePanel(
        title: 'Blessings of Knowledge',
        subtitle:
            'Choose two Knowledge Domain skills. They become proficient and gain Expertise.',
        selectedText:
            '${selectedSkills.length} / ${ClericChoiceService.knowledgeSkillCount} skills selected',
        options: ClericChoiceService.knowledgeSkillOptions
            .map(
              (skill) => _ChoiceOption(
                value: skill,
                label: ClericChoiceService.skillLabel(skill),
              ),
            )
            .toList(),
        selectedValues: selectedSkills,
        maxSelections: ClericChoiceService.knowledgeSkillCount,
        onChanged: notifier.setClericKnowledgeSkills,
      ),
      const SizedBox(height: 12),
      _ClassChoicePanel(
        title: 'Knowledge Artisan Tool',
        subtitle: 'Choose one Artisan Tool proficiency from your domain.',
        selectedText: selectedTool == null
            ? '0 / 1 tool selected'
            : '1 / 1 tool selected',
        options: ClericChoiceService.artisanToolOptions
            .map((tool) => _ChoiceOption(value: tool, label: tool))
            .toList(),
        selectedValues: selectedTool == null ? const [] : [selectedTool],
        maxSelections: 1,
        onChanged: (values) => values.isEmpty
            ? notifier.setClericKnowledgeTool('')
            : notifier.setClericKnowledgeTool(values.first),
      ),
      const SizedBox(height: 12),
    ];
  }

  List<Widget> _fighterBattleMasterStudentChoiceCards(
    CreationState state,
    WidgetRef ref,
  ) {
    if (!FighterChoiceService.isBattleMaster(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return const [];
    }

    final selectedSkill = FighterChoiceService.selectedBattleMasterStudentSkill(
      state.levelAdvancements,
    );
    final selectedTool = FighterChoiceService.selectedBattleMasterStudentTool(
      state.levelAdvancements,
    );
    final notifier = ref.read(creationProvider.notifier);

    return [
      _ClassChoicePanel(
        title: 'Student of War Skill',
        subtitle: 'Choose one Fighter skill proficiency from Battle Master.',
        selectedText: selectedSkill == null
            ? '0 / 1 skill selected'
            : '1 / 1 skill selected',
        options: FighterChoiceService.studentOfWarSkillOptions
            .map(
              (skill) => _ChoiceOption(
                value: skill,
                label: StepSkills._skillLabels[skill] ??
                    FighterChoiceService.skillLabel(skill),
              ),
            )
            .toList(),
        selectedValues: selectedSkill == null ? const [] : [selectedSkill],
        maxSelections: 1,
        onChanged: (values) => values.isEmpty
            ? notifier.setFighterBattleMasterStudentSkill('')
            : notifier.setFighterBattleMasterStudentSkill(values.first),
      ),
      const SizedBox(height: 12),
      _ClassChoicePanel(
        title: 'Student of War Tool',
        subtitle: 'Choose one Artisan Tool proficiency from Battle Master.',
        selectedText: selectedTool == null
            ? '0 / 1 tool selected'
            : '1 / 1 tool selected',
        options: FighterChoiceService.artisanToolOptions
            .map((tool) => _ChoiceOption(value: tool, label: tool))
            .toList(),
        selectedValues: selectedTool == null ? const [] : [selectedTool],
        maxSelections: 1,
        onChanged: (values) => values.isEmpty
            ? notifier.setFighterBattleMasterStudentTool('')
            : notifier.setFighterBattleMasterStudentTool(values.first),
      ),
      const SizedBox(height: 12),
    ];
  }

  List<Widget> _paladinGenieSplendorChoiceCards(
    CreationState state,
    WidgetRef ref,
  ) {
    if (!PaladinChoiceService.isNobleGenies(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return const [];
    }

    final selected = PaladinChoiceService.selectedGenieSplendorSkill(
      state.levelAdvancements,
    );
    final options = PaladinChoiceService.genieSplendorSkillOptions
        .map(
          (skill) => _ChoiceOption(
            value: skill,
            label: StepSkills._skillLabels[skill] ??
                PaladinChoiceService.skillLabel(skill),
          ),
        )
        .toList();

    return [
      _ClassChoicePanel(
        title: "Genie's Splendor",
        subtitle:
            "Choose one skill proficiency granted by Oath of the Noble Genies.",
        selectedText:
            selected == null ? "0 / 1 skill selected" : "1 / 1 skill selected",
        options: options,
        selectedValues: selected == null ? const [] : [selected],
        maxSelections: 1,
        onChanged: (values) => values.isEmpty
            ? ref
                .read(creationProvider.notifier)
                .setPaladinGenieSplendorSkill("")
            : ref
                .read(creationProvider.notifier)
                .setPaladinGenieSplendorSkill(values.first),
      ),
      const SizedBox(height: 12),
    ];
  }

  List<Widget> _rangerFeyGlamourChoiceCards(
    CreationState state,
    WidgetRef ref,
  ) {
    if (!RangerChoiceService.needsFeyGlamourSkill(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    )) {
      return const [];
    }

    final selected = RangerChoiceService.selectedFeyGlamourSkill(
      state.levelAdvancements,
    );
    final options = RangerChoiceService.feyGlamourSkillOptions
        .map(
          (skill) => _ChoiceOption(
            value: skill,
            label: StepSkills._skillLabels[skill] ??
                RangerChoiceService.skillLabel(skill),
          ),
        )
        .toList();

    return [
      _ClassChoicePanel(
        title: 'Otherworldly Glamour',
        subtitle: 'Choose one skill proficiency granted by Fey Wanderer.',
        selectedText:
            selected == null ? '0 / 1 skill selected' : '1 / 1 skill selected',
        options: options,
        selectedValues: selected == null ? const [] : [selected],
        maxSelections: 1,
        onChanged: (values) => values.isEmpty
            ? ref.read(creationProvider.notifier).setRangerFeyGlamourSkill('')
            : ref
                .read(creationProvider.notifier)
                .setRangerFeyGlamourSkill(values.first),
      ),
      const SizedBox(height: 12),
    ];
  }

  Widget _wizardScholarChoiceCard(CreationState state, WidgetRef ref) {
    if (!WizardChoiceService.needsScholar(
      className: state.className,
      level: state.level,
    )) {
      return const SizedBox.shrink();
    }

    final currentSkillProficiencies =
        _allCurrentProficientSkills(state).toSet();
    final options = WizardChoiceService.scholarSkillOptions
        .where(currentSkillProficiencies.contains)
        .toList();
    final selected = WizardChoiceService.selectedScholarSkill(
      state.levelAdvancements,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scholar',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose one proficient skill from Arcana, History, Investigation, Medicine, Nature, or Religion. You gain Expertise in the chosen skill.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          if (options.isEmpty)
            Text(
              'Choose one of the eligible Wizard skills above first. Scholar can only use a skill in which you already have proficiency.',
              style: AppTextStyles.lato(
                color: Colors.orangeAccent,
                fontSize: 12,
                height: 1.4,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((skill) {
                return ChoiceChip(
                  label: Text(StepSkills._skillLabels[skill] ??
                      WizardChoiceService.skillLabel(skill)),
                  selected: selected == skill,
                  selectedColor: AppTheme.crimson,
                  onSelected: (_) => ref
                      .read(creationProvider.notifier)
                      .setWizardScholarSkill(skill),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
