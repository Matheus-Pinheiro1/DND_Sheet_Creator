part of '../step_spells.dart';

class FighterEldritchKnightSpellPicker extends ConsumerWidget {
  final CreationState state;
  final List<SpellDto> spells;

  const FighterEldritchKnightSpellPicker({
    super.key,
    required this.state,
    required this.spells,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCantrips =
        FighterChoiceService.selectedEldritchKnightCantrips(
      state.levelAdvancements,
    );
    final selectedSpells = FighterChoiceService.selectedEldritchKnightSpells(
      state.levelAdvancements,
    );
    final cantripLimit =
        FighterChoiceService.eldritchKnightCantripCount(state.level);
    final spellLimit =
        FighterChoiceService.eldritchKnightPreparedSpellCount(state.level);
    final maxSpellLevel =
        FighterChoiceService.eldritchKnightMaxSpellLevel(state.level);
    final slotSummary = _slotSummary(
      FighterChoiceService.eldritchKnightSpellSlots(state.level),
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
    };

    final cantripOptions = FighterChoiceService.filterEldritchKnightCantrips(
      spells: spells,
      knownSpellIds: knownSpellIds.difference(selectedCantrips.toSet()),
    );
    final spellOptions =
        FighterChoiceService.filterEldritchKnightPreparedSpells(
      spells: spells,
      maxSpellLevel: maxSpellLevel,
      knownSpellIds: knownSpellIds.difference(selectedSpells.toSet()),
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
            'Eldritch Knight Spellcasting',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose Wizard cantrips and prepared Wizard spells for your Fighter level. Intelligence is your spellcasting ability.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Slots: $slotSummary',
            style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          _FighterEldritchKnightSpellGroup(
            title: 'Wizard cantrips ${selectedCantrips.length} / $cantripLimit',
            selected: selectedCantrips,
            options: cantripOptions,
            maxSelections: cantripLimit,
            onChanged: (choices) => ref
                .read(creationProvider.notifier)
                .setFighterEldritchKnightCantrips(choices),
          ),
          const SizedBox(height: 12),
          _FighterEldritchKnightSpellGroup(
            title:
                'Prepared spells ${selectedSpells.length} / $spellLimit (level $maxSpellLevel or lower)',
            selected: selectedSpells,
            options: spellOptions,
            maxSelections: spellLimit,
            onChanged: (choices) => ref
                .read(creationProvider.notifier)
                .setFighterEldritchKnightSpells(choices),
          ),
        ],
      ),
    );
  }

  String _slotSummary(Map<int, int> slots) {
    if (slots.isEmpty) return 'none';
    final levels = slots.keys.toList()..sort();
    return levels.map((level) => 'L$level ${slots[level]}').join(' / ');
  }
}

class _FighterEldritchKnightSpellGroup extends StatelessWidget {
  final String title;
  final List<String> selected;
  final List<SpellDto> options;
  final int maxSelections;
  final ValueChanged<List<String>> onChanged;

  const _FighterEldritchKnightSpellGroup({
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
