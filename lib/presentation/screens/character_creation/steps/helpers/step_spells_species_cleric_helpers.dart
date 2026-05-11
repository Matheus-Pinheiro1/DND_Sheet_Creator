part of '../step_spells.dart';

extension _StepSpellsSpeciesClericHelpers on _StepSpellsState {
  bool _needsSpeciesSpellAbility(String raceValue) {
    return raceValue.startsWith('elf::') ||
        raceValue.startsWith('tiefling::') ||
        raceValue.startsWith('gnome::');
  }

  Widget _buildSpeciesSpellAbilityChooser(CreationState state) {
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
            'Species Spellcasting Ability',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose the spellcasting ability used by your species spells.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: ['int', 'wis', 'cha'].map((ability) {
              return ChoiceChip(
                label: Text(ability.toUpperCase()),
                selected: state.speciesSpellAbility == ability,
                selectedColor: AppTheme.crimson,
                onSelected: (_) => ref
                    .read(creationProvider.notifier)
                    .setSpeciesSpellAbility(ability),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHighElfCantripPicker(
      CreationState state, List<SpellDto> spells) {
    final cantrips = spells.where((spell) => spell.level == 0).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return _buildSingleGrantedCantripPicker(
      title: 'High Elf Lineage',
      subtitle: 'Choose 1 Wizard cantrip granted by your lineage.',
      selectedSpellIndex: state.speciesGrantedCantrip,
      spells: cantrips,
      onChanged: (spellIndex) => ref
          .read(creationProvider.notifier)
          .setSpeciesGrantedCantrip(spellIndex),
    );
  }

  Widget _buildDivineOrderChooser(CreationState state, List<SpellDto> spells) {
    final cantrips = spells.where((spell) => spell.level == 0).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

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
            'Divine Order',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose Protector or Thaumaturge for your Cleric. Protector adds Martial weapons and Heavy armor. Thaumaturge grants 1 extra Cleric cantrip.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Protector'),
                selected: state.clericDivineOrder == 'protector',
                selectedColor: AppTheme.crimson,
                onSelected: (_) => ref
                    .read(creationProvider.notifier)
                    .setClericDivineOrder('protector'),
              ),
              ChoiceChip(
                label: const Text('Thaumaturge'),
                selected: state.clericDivineOrder == 'thaumaturge',
                selectedColor: AppTheme.crimson,
                onSelected: (_) => ref
                    .read(creationProvider.notifier)
                    .setClericDivineOrder('thaumaturge'),
              ),
            ],
          ),
          if (state.clericDivineOrder == 'thaumaturge') ...[
            const SizedBox(height: 12),
            _buildSingleGrantedCantripPicker(
              title: 'Thaumaturge Cantrip',
              subtitle:
                  'Choose the extra Cleric cantrip granted by Thaumaturge.',
              selectedSpellIndex: state.clericThaumaturgeCantrip,
              spells: cantrips,
              onChanged: (spellIndex) => ref
                  .read(creationProvider.notifier)
                  .setClericThaumaturgeCantrip(spellIndex),
              dense: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSingleGrantedCantripPicker({
    required String title,
    required String subtitle,
    required String selectedSpellIndex,
    required List<SpellDto> spells,
    required ValueChanged<String> onChanged,
    bool dense = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(dense ? 0 : 14),
      decoration: dense
          ? null
          : BoxDecoration(
              color: AppTheme.ashGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.32)),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          ...spells.map(
            (spell) => _OriginFeatSpellTile(
              spell: spell,
              isSelected: selectedSpellIndex == spell.index,
              onTap: () => onChanged(spell.index),
            ),
          ),
        ],
      ),
    );
  }
}
