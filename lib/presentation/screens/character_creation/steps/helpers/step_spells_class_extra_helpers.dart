part of '../step_spells.dart';

extension _StepSpellsClassExtraHelpers on _StepSpellsState {
  Widget _buildRangerDruidicWarriorPicker(
    BuildContext context,
    CreationState state,
    List<SpellDto> spells,
  ) {
    final selected = RangerChoiceService.selectedDruidicWarriorCantrips(
      state.levelAdvancements,
    );
    final knownSpellIds = <String>{
      ...state.selectedSpells,
      ...state.originFeatCantrips,
      if (state.originFeatSpell.isNotEmpty) state.originFeatSpell,
      ...state.speciesOriginFeatCantrips,
      if (state.speciesOriginFeatSpell.isNotEmpty) state.speciesOriginFeatSpell,
      if (state.speciesGrantedCantrip.isNotEmpty) state.speciesGrantedCantrip,
      if (state.clericThaumaturgeCantrip.isNotEmpty)
        state.clericThaumaturgeCantrip,
      ...WizardChoiceService.selectedSavantSpells(state.levelAdvancements),
    }..removeAll(selected);
    final options = RangerChoiceService.filterDruidicWarriorCantrips(
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
            'Druidic Warrior',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose 2 Druid cantrips. They count as Ranger spells for you and use Wisdom as the spellcasting ability.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cantrips: ${selected.length} / ${RangerChoiceService.druidicWarriorCantripCount}',
            style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (options.isEmpty)
            Text(
              'No Druid cantrips were available to choose here.',
              style: AppTextStyles.lato(
                color: Colors.orangeAccent,
                fontSize: 12,
                height: 1.4,
              ),
            )
          else
            ...options.map(
              (spell) => _OriginFeatSpellTile(
                spell: spell,
                isSelected: selected.contains(spell.index),
                onTap: () {
                  final next = List<String>.from(selected);
                  if (next.contains(spell.index)) {
                    next.remove(spell.index);
                  } else {
                    if (next.length >=
                        RangerChoiceService.druidicWarriorCantripCount) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Choose only 2 Druidic Warrior cantrips.',
                          ),
                        ),
                      );
                      return;
                    }
                    next.add(spell.index);
                  }
                  ref
                      .read(creationProvider.notifier)
                      .setRangerDruidicWarriorCantrips(next);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBardLoreMagicalDiscoveriesPicker(
    BuildContext context,
    CreationState state,
    List<SpellDto> spells,
    SpellSelectionLimits classRules,
  ) {
    final selected = BardChoiceService.selectedLoreDiscoverySpells(
      state.levelAdvancements,
    );
    final spellNameToIndex = buildSpellNameIndexMap(spells);
    final knownSpellIds = <String>{
      ...state.selectedSpells,
      ...state.originFeatCantrips,
      if (state.originFeatSpell.isNotEmpty) state.originFeatSpell,
      ...state.speciesOriginFeatCantrips,
      if (state.speciesOriginFeatSpell.isNotEmpty) state.speciesOriginFeatSpell,
      if (state.speciesGrantedCantrip.isNotEmpty) state.speciesGrantedCantrip,
      if (state.clericThaumaturgeCantrip.isNotEmpty)
        state.clericThaumaturgeCantrip,
      ...WizardChoiceService.selectedSavantSpells(state.levelAdvancements),
      ...RangerChoiceService.selectedDruidicWarriorCantrips(
        state.levelAdvancements,
      ),
      ...PaladinChoiceService.selectedBlessedWarriorCantrips(
        state.levelAdvancements,
      ),
      ...DruidChoiceService.baseGrantedSpellIds(
        state.className == 'druid' ? state.level : 0,
      ),
      ...buildGrantedSpellEntries(
        className: state.className,
        subclass: state.subclass,
        raceValue: state.race,
        level: state.level,
        spellNameToIndex: spellNameToIndex,
      ).map((entry) => entry.spellIndex),
    }..removeAll(selected);
    final options = BardChoiceService.filterLoreDiscoverySpellOptions(
      spells: spells,
      maxSpellLevel: classRules.maxSpellLevel,
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
            'Magical Discoveries',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose 2 Cleric, Druid, or Wizard spells. They count as Bard spells and do not count against prepared Bard spells.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Spells: ${selected.length} / ${BardChoiceService.loreDiscoverySpellCount}',
            style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (options.isEmpty)
            Text(
              'No eligible spells were available to choose here.',
              style: AppTextStyles.lato(
                color: Colors.orangeAccent,
                fontSize: 12,
                height: 1.4,
              ),
            )
          else
            ...options.map(
              (spell) => _OriginFeatSpellTile(
                spell: spell,
                isSelected: selected.contains(spell.index),
                onTap: () {
                  final next = List<String>.from(selected);
                  if (next.contains(spell.index)) {
                    next.remove(spell.index);
                  } else {
                    if (next.length >=
                        BardChoiceService.loreDiscoverySpellCount) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Choose only 2 Magical Discoveries spells.',
                          ),
                        ),
                      );
                      return;
                    }
                    next.add(spell.index);
                  }
                  ref
                      .read(creationProvider.notifier)
                      .setBardLoreDiscoverySpells(next);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBardMoonCantripPicker(
    BuildContext context,
    CreationState state,
    List<SpellDto> spells,
  ) {
    final selected = BardChoiceService.selectedMoonCantrip(
      state.levelAdvancements,
    );
    final selectedSet = {
      if (selected != null) selected,
    };
    final knownSpellIds = <String>{
      ...state.selectedSpells,
      ...state.originFeatCantrips,
      if (state.originFeatSpell.isNotEmpty) state.originFeatSpell,
      ...state.speciesOriginFeatCantrips,
      if (state.speciesOriginFeatSpell.isNotEmpty) state.speciesOriginFeatSpell,
      if (state.speciesGrantedCantrip.isNotEmpty) state.speciesGrantedCantrip,
      if (state.clericThaumaturgeCantrip.isNotEmpty)
        state.clericThaumaturgeCantrip,
      ...WizardChoiceService.selectedSavantSpells(state.levelAdvancements),
      ...BardChoiceService.selectedLoreDiscoverySpells(
        state.levelAdvancements,
      ),
      ...RangerChoiceService.selectedDruidicWarriorCantrips(
        state.levelAdvancements,
      ),
      ...PaladinChoiceService.selectedBlessedWarriorCantrips(
        state.levelAdvancements,
      ),
    }..removeAll(selectedSet);
    final options = BardChoiceService.filterMoonCantripOptions(
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
            'Primal Lore',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose 1 Druid cantrip. It counts as a Bard spell and does not count against your Bard cantrips known.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selected == null ? 'Cantrips: 0 / 1' : 'Cantrips: 1 / 1',
            style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (options.isEmpty)
            Text(
              'No Druid cantrips were available to choose here.',
              style: AppTextStyles.lato(
                color: Colors.orangeAccent,
                fontSize: 12,
                height: 1.4,
              ),
            )
          else
            ...options.map(
              (spell) => _OriginFeatSpellTile(
                spell: spell,
                isSelected: selected == spell.index,
                onTap: () => ref
                    .read(creationProvider.notifier)
                    .setBardMoonCantrip(spell.index),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaladinBlessedWarriorPicker(
    BuildContext context,
    CreationState state,
    List<SpellDto> spells,
  ) {
    final selected = PaladinChoiceService.selectedBlessedWarriorCantrips(
      state.levelAdvancements,
    );
    final knownSpellIds = <String>{
      ...state.selectedSpells,
      ...state.originFeatCantrips,
      if (state.originFeatSpell.isNotEmpty) state.originFeatSpell,
      ...state.speciesOriginFeatCantrips,
      if (state.speciesOriginFeatSpell.isNotEmpty) state.speciesOriginFeatSpell,
      if (state.speciesGrantedCantrip.isNotEmpty) state.speciesGrantedCantrip,
      if (state.clericThaumaturgeCantrip.isNotEmpty)
        state.clericThaumaturgeCantrip,
      ...WizardChoiceService.selectedSavantSpells(state.levelAdvancements),
      ...RangerChoiceService.selectedDruidicWarriorCantrips(
        state.levelAdvancements,
      ),
    }..removeAll(selected);
    final options = PaladinChoiceService.filterBlessedWarriorCantrips(
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
            'Blessed Warrior',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose 2 Cleric cantrips. They count as Paladin spells for you and use Charisma as the spellcasting ability.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cantrips: ${selected.length} / ${PaladinChoiceService.blessedWarriorCantripCount}',
            style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (options.isEmpty)
            Text(
              'No Cleric cantrips were available to choose here.',
              style: AppTextStyles.lato(
                color: Colors.orangeAccent,
                fontSize: 12,
                height: 1.4,
              ),
            )
          else
            ...options.map(
              (spell) => _OriginFeatSpellTile(
                spell: spell,
                isSelected: selected.contains(spell.index),
                onTap: () {
                  final next = List<String>.from(selected);
                  if (next.contains(spell.index)) {
                    next.remove(spell.index);
                  } else {
                    if (next.length >=
                        PaladinChoiceService.blessedWarriorCantripCount) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Choose only 2 Blessed Warrior cantrips.',
                          ),
                        ),
                      );
                      return;
                    }
                    next.add(spell.index);
                  }
                  ref
                      .read(creationProvider.notifier)
                      .setPaladinBlessedWarriorCantrips(next);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDruidMagicianCantripPicker(
    BuildContext context,
    CreationState state,
    List<SpellDto> spells,
  ) {
    final selected = DruidChoiceService.selectedMagicianCantrip(
      state.levelAdvancements,
    );
    final selectedSet = {
      if (selected != null) selected,
    };
    final knownSpellIds = <String>{
      ...state.selectedSpells,
      ...state.originFeatCantrips,
      if (state.originFeatSpell.isNotEmpty) state.originFeatSpell,
      ...state.speciesOriginFeatCantrips,
      if (state.speciesOriginFeatSpell.isNotEmpty) state.speciesOriginFeatSpell,
      if (state.speciesGrantedCantrip.isNotEmpty) state.speciesGrantedCantrip,
      if (state.clericThaumaturgeCantrip.isNotEmpty)
        state.clericThaumaturgeCantrip,
      ...WizardChoiceService.selectedSavantSpells(state.levelAdvancements),
      ...RangerChoiceService.selectedDruidicWarriorCantrips(
        state.levelAdvancements,
      ),
      ...PaladinChoiceService.selectedBlessedWarriorCantrips(
        state.levelAdvancements,
      ),
    }..removeAll(selectedSet);
    final options = DruidChoiceService.filterMagicianCantrips(
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
            'Primal Order: Magician',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose 1 extra Druid cantrip. This does not count against your normal Druid cantrips.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selected == null ? 'Cantrip: 0 / 1' : 'Cantrip: 1 / 1',
            style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (options.isEmpty)
            Text(
              'No Druid cantrips were available to choose here.',
              style: AppTextStyles.lato(
                color: Colors.orangeAccent,
                fontSize: 12,
                height: 1.4,
              ),
            )
          else
            ...options.map(
              (spell) => _OriginFeatSpellTile(
                spell: spell,
                isSelected: selected == spell.index,
                onTap: () {
                  final next = selected == spell.index ? '' : spell.index;
                  ref
                      .read(creationProvider.notifier)
                      .setDruidMagicianCantrip(next);
                },
              ),
            ),
        ],
      ),
    );
  }
}
