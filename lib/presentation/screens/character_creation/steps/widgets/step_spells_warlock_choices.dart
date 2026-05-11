part of '../step_spells.dart';

class WarlockPactTomePicker extends ConsumerWidget {
  final CreationState state;
  final List<SpellDto> spells;

  const WarlockPactTomePicker({
    super.key,
    required this.state,
    required this.spells,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCantrips = WarlockChoiceService.selectedPactTomeCantrips(
      state.levelAdvancements,
    );
    final selectedRituals = WarlockChoiceService.selectedPactTomeRituals(
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
      ...PaladinChoiceService.selectedBlessedWarriorCantrips(
        state.levelAdvancements,
      ),
      ...WarlockChoiceService.baseGrantedSpellIds(
        level: state.level,
        entries: state.levelAdvancements,
      ),
      ...WarlockChoiceService.selectedMysticArcanumSpells(
        state.levelAdvancements,
      ),
    };
    final cantripOptions = WarlockChoiceService.filterPactTomeCantrips(
      spells: spells,
      knownSpellIds: knownSpellIds.difference(selectedCantrips.toSet()),
    );
    final ritualOptions = WarlockChoiceService.filterPactTomeRituals(
      spells: spells,
      knownSpellIds: knownSpellIds.difference(selectedRituals.toSet()),
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
            'Pact of the Tome',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose 3 extra cantrips and 2 level 1 ritual spells for your Book of Shadows. These are recorded separately from normal Warlock prepared spells.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          _WarlockTomeSpellGroup(
            title:
                'Cantrips ${selectedCantrips.length} / ${WarlockChoiceService.pactTomeCantripCount}',
            selected: selectedCantrips,
            options: cantripOptions,
            maxSelections: WarlockChoiceService.pactTomeCantripCount,
            onChanged: (choices) => ref
                .read(creationProvider.notifier)
                .setWarlockPactTomeCantrips(choices),
          ),
          const SizedBox(height: 12),
          _WarlockTomeSpellGroup(
            title:
                'Level 1 Rituals ${selectedRituals.length} / ${WarlockChoiceService.pactTomeRitualCount}',
            selected: selectedRituals,
            options: ritualOptions,
            maxSelections: WarlockChoiceService.pactTomeRitualCount,
            onChanged: (choices) => ref
                .read(creationProvider.notifier)
                .setWarlockPactTomeRituals(choices),
          ),
        ],
      ),
    );
  }
}

class _WarlockTomeSpellGroup extends StatelessWidget {
  final String title;
  final List<String> selected;
  final List<SpellDto> options;
  final int maxSelections;
  final ValueChanged<List<String>> onChanged;

  const _WarlockTomeSpellGroup({
    required this.title,
    required this.selected,
    required this.options,
    required this.maxSelections,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            title,
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (options.isEmpty)
            Text(
              'No eligible spells available.',
              style: AppTextStyles.lato(color: Colors.white38, fontSize: 12),
            )
          else
            ...options.map((spell) {
              final isSelected = selected.contains(spell.index);
              return _OriginFeatSpellTile(
                spell: spell,
                isSelected: isSelected,
                onTap: () {
                  final next = List<String>.from(selected);
                  if (isSelected) {
                    next.remove(spell.index);
                  } else {
                    if (next.length >= maxSelections) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Choose up to $maxSelections.')),
                      );
                      return;
                    }
                    next.add(spell.index);
                  }
                  onChanged(next);
                },
              );
            }),
        ],
      ),
    );
  }
}

class WarlockMysticArcanumSection extends ConsumerWidget {
  final CreationState state;
  final List<SpellDto> spells;

  const WarlockMysticArcanumSection({
    super.key,
    required this.state,
    required this.spells,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arcanumLevels =
        WarlockChoiceService.mysticArcanumSpellLevels(state.level);

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
            'Mystic Arcanum',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose one Warlock spell for each Mystic Arcanum level. Each arcanum is cast once per Long Rest without using Pact Magic slots.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          ...arcanumLevels.map((spellLevel) {
            final selected = WarlockChoiceService.selectedMysticArcanumSpell(
              state.levelAdvancements,
              spellLevel: spellLevel,
            );
            final options = WarlockChoiceService.filterMysticArcanumOptions(
              spells: spells,
              spellLevel: spellLevel,
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
                      'Level $spellLevel spell',
                      style: AppTextStyles.cinzel(
                        color: AppTheme.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...options.map((spell) {
                      return _OriginFeatSpellTile(
                        spell: spell,
                        isSelected: selected == spell.index,
                        onTap: () => ref
                            .read(creationProvider.notifier)
                            .setWarlockMysticArcanum(
                              spellLevel: spellLevel,
                              spellIndex: spell.index,
                            ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
