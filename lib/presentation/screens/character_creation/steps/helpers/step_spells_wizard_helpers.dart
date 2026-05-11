part of '../step_spells.dart';

extension _StepSpellsWizardHelpers on _StepSpellsState {
  bool _shouldShowWizardChoices(CreationState state) {
    if (state.className != 'wizard' ||
        state.level < 3 ||
        state.subclass.isEmpty) {
      return false;
    }

    final school = WizardChoiceService.savantSchoolForSubclass(state.subclass);
    if (school != null) {
      return true;
    }

    final knownSpellIds = <String>{
      ...state.selectedSpells,
      ...state.originFeatCantrips,
      if (state.originFeatSpell.isNotEmpty) state.originFeatSpell,
      if (state.speciesGrantedCantrip.isNotEmpty) state.speciesGrantedCantrip,
      if (state.clericThaumaturgeCantrip.isNotEmpty)
        state.clericThaumaturgeCantrip,
      ...WizardChoiceService.selectedSavantSpells(state.levelAdvancements),
    };
    return WizardChoiceService.needsIllusionistBonusCantrip(
      subclass: state.subclass,
      level: state.level,
      knownSpellIds: knownSpellIds,
    );
  }

  Widget _buildWizardSubclassChoices(
      CreationState state, List<SpellDto> spells) {
    if (!_shouldShowWizardChoices(state)) {
      return const SizedBox.shrink();
    }

    final sections = <Widget>[];
    final school = WizardChoiceService.savantSchoolForSubclass(state.subclass);
    if (school != null) {
      sections.add(_buildWizardSavantSection(state, spells, school));
    }

    final knownSpellIds = <String>{
      ...state.selectedSpells,
      ...state.originFeatCantrips,
      if (state.originFeatSpell.isNotEmpty) state.originFeatSpell,
      if (state.speciesGrantedCantrip.isNotEmpty) state.speciesGrantedCantrip,
      if (state.clericThaumaturgeCantrip.isNotEmpty)
        state.clericThaumaturgeCantrip,
      ...WizardChoiceService.selectedSavantSpells(state.levelAdvancements),
    };
    if (WizardChoiceService.needsIllusionistBonusCantrip(
      subclass: state.subclass,
      level: state.level,
      knownSpellIds: knownSpellIds,
    )) {
      if (sections.isNotEmpty) {
        sections.add(const SizedBox(height: 16));
      }
      sections.add(
          _buildIllusionistBonusCantripSection(state, spells, knownSpellIds));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }

  Widget _buildWizardSavantSection(
    CreationState state,
    List<SpellDto> spells,
    String school,
  ) {
    final allSelected = WizardChoiceService.selectedSavantSpells(
      state.levelAdvancements,
    ).toSet();
    final schoolLabel = WizardChoiceService.schoolLabel(school);
    final featureName = WizardChoiceService.savantFeatureNameForSubclass(
      state.subclass,
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
            featureName,
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose the free $schoolLabel spells added to your spellbook by your Wizard subclass. These spells are recorded separately from your normal prepared-spell choices.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          ...WizardChoiceService.savantMilestonesForLevel(state.level).map(
            (milestone) {
              final selectedForLevel = WizardChoiceService.selectedSavantSpells(
                state.levelAdvancements,
                wizardLevel: milestone.wizardLevel,
              );
              final options = WizardChoiceService.filterSavantSpellOptions(
                spells: spells,
                school: school,
                maxSpellLevel: milestone.maxSpellLevel,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.charcoal,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone.wizardLevel == 3
                            ? 'Wizard level 3 — choose ${milestone.selections}'
                            : 'Wizard level ${milestone.wizardLevel} — choose ${milestone.selections}',
                        style: AppTextStyles.cinzel(
                          color: AppTheme.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Selected ${selectedForLevel.length} / ${milestone.selections} • $schoolLabel spells of level ${milestone.maxSpellLevel} or lower',
                        style: AppTextStyles.lato(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...options.map((spell) {
                        final alreadyChosenElsewhere =
                            allSelected.contains(spell.index) &&
                                !selectedForLevel.contains(spell.index);
                        return _OriginFeatSpellTile(
                          spell: spell,
                          isSelected: selectedForLevel.contains(spell.index),
                          onTap: () {
                            if (alreadyChosenElsewhere) return;
                            if (!selectedForLevel.contains(spell.index) &&
                                selectedForLevel.length >=
                                    milestone.selections) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'You already selected the maximum number of $featureName spells for Wizard level ${milestone.wizardLevel}.',
                                  ),
                                ),
                              );
                              return;
                            }
                            ref
                                .read(creationProvider.notifier)
                                .toggleWizardSavantSpell(
                                  wizardLevel: milestone.wizardLevel,
                                  spellIndex: spell.index,
                                  maxSelections: milestone.selections,
                                );
                          },
                          subtitleOverride: alreadyChosenElsewhere
                              ? 'Already chosen for another Savant unlock.'
                              : null,
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIllusionistBonusCantripSection(
    CreationState state,
    List<SpellDto> spells,
    Set<String> knownSpellIds,
  ) {
    final selected = WizardChoiceService.selectedIllusionistBonusCantrip(
      state.levelAdvancements,
    );
    final options = WizardChoiceService.filterIllusionistBonusCantrips(
      spells: spells,
      knownSpellIds: knownSpellIds,
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
            'Improved Illusions',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You already know Minor Illusion, so choose a different Wizard cantrip to gain from this feature.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          if (options.isEmpty)
            Text(
              'No other Wizard cantrips were available to choose here.',
              style: AppTextStyles.lato(
                color: Colors.orangeAccent,
                fontSize: 12,
              ),
            )
          else
            ...options.map(
              (spell) => _OriginFeatSpellTile(
                spell: spell,
                isSelected: selected == spell.index,
                onTap: () => ref
                    .read(creationProvider.notifier)
                    .setIllusionistBonusCantrip(spell.index),
              ),
            ),
        ],
      ),
    );
  }
}
