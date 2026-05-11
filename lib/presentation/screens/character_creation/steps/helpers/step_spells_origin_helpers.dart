part of '../step_spells.dart';

extension _StepSpellsOriginHelpers on _StepSpellsState {
  Widget _buildOriginFeatSpellPicker(
    BuildContext context,
    CreationState state,
    List<SpellDto> spells,
  ) {
    final cantrips = spells.where((spell) => spell.level == 0).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final levelOne = spells.where((spell) => spell.level == 1).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final visibleCantrips = cantrips
        .where((spell) =>
            _originSearchQuery.isEmpty ||
            spell.name.toLowerCase().contains(_originSearchQuery.toLowerCase()))
        .toList();
    final visibleLevelOne = levelOne
        .where((spell) =>
            _originSearchQuery.isEmpty ||
            spell.name.toLowerCase().contains(_originSearchQuery.toLowerCase()))
        .toList();

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
            state.backgroundFeatName.isEmpty
                ? 'Origin Feat Spell Choices'
                : state.backgroundFeatName,
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose 2 cantrips and 1 level 1 spell. The chosen level 1 spell is always prepared and can be cast once without a slot per Long Rest.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Spellcasting ability',
            style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: ['int', 'wis', 'cha'].map((ability) {
              return ChoiceChip(
                label: Text(ability.toUpperCase()),
                selected: state.originFeatSpellAbility == ability,
                selectedColor: AppTheme.crimson,
                onSelected: (_) => ref
                    .read(creationProvider.notifier)
                    .setOriginFeatSpellAbility(ability),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search origin feat spells...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
            onChanged: (value) => _updateUi(() => _originSearchQuery = value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Cantrips'),
                selected: _originSelectedLevel == 0,
                selectedColor: AppTheme.crimson,
                onSelected: (_) => _updateUi(() => _originSelectedLevel = 0),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Level 1'),
                selected: _originSelectedLevel == 1,
                selectedColor: AppTheme.crimson,
                onSelected: (_) => _updateUi(() => _originSelectedLevel = 1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _originSelectedLevel == 0
                ? 'Cantrips: ${state.originFeatCantrips.length} / 2'
                : 'Level 1 spell: ${state.originFeatSpell.isEmpty ? 0 : 1} / 1',
            style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ...(_originSelectedLevel == 0 ? visibleCantrips : visibleLevelOne)
              .map(
            (spell) => _OriginFeatSpellTile(
              spell: spell,
              isSelected: _originSelectedLevel == 0
                  ? state.originFeatCantrips.contains(spell.index)
                  : state.originFeatSpell == spell.index,
              onTap: () {
                if (_originSelectedLevel == 0) {
                  ref
                      .read(creationProvider.notifier)
                      .toggleOriginFeatCantrip(spell.index);
                } else {
                  ref
                      .read(creationProvider.notifier)
                      .setOriginFeatSpell(spell.index);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesOriginFeatSpellPicker(
    BuildContext context,
    CreationState state,
    List<SpellDto> spells,
  ) {
    final cantrips = spells.where((spell) => spell.level == 0).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final levelOne = spells.where((spell) => spell.level == 1).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final visibleCantrips = cantrips
        .where((spell) =>
            _speciesOriginSearchQuery.isEmpty ||
            spell.name
                .toLowerCase()
                .contains(_speciesOriginSearchQuery.toLowerCase()))
        .toList();
    final visibleLevelOne = levelOne
        .where((spell) =>
            _speciesOriginSearchQuery.isEmpty ||
            spell.name
                .toLowerCase()
                .contains(_speciesOriginSearchQuery.toLowerCase()))
        .toList();

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
            "Human — Versatile (${ProgressionService.findFeat(state.speciesOriginFeatId)?.name ?? 'Magic Initiate'})",
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose 2 cantrips and 1 level 1 spell for the Origin Feat granted by your Human species.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Spellcasting ability',
            style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: ['int', 'wis', 'cha'].map((ability) {
              return ChoiceChip(
                label: Text(ability.toUpperCase()),
                selected: state.speciesOriginFeatSpellAbility == ability,
                selectedColor: AppTheme.crimson,
                onSelected: (_) => ref
                    .read(creationProvider.notifier)
                    .setSpeciesOriginFeatSpellAbility(ability),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search human feat spells...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
            onChanged: (value) =>
                _updateUi(() => _speciesOriginSearchQuery = value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Cantrips'),
                selected: _speciesOriginSelectedLevel == 0,
                selectedColor: AppTheme.crimson,
                onSelected: (_) =>
                    _updateUi(() => _speciesOriginSelectedLevel = 0),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Level 1'),
                selected: _speciesOriginSelectedLevel == 1,
                selectedColor: AppTheme.crimson,
                onSelected: (_) =>
                    _updateUi(() => _speciesOriginSelectedLevel = 1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _speciesOriginSelectedLevel == 0
                ? 'Cantrips: ${state.speciesOriginFeatCantrips.length} / 2'
                : 'Level 1 spell: ${state.speciesOriginFeatSpell.isEmpty ? 0 : 1} / 1',
            style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ...(_speciesOriginSelectedLevel == 0
                  ? visibleCantrips
                  : visibleLevelOne)
              .map(
            (spell) => _OriginFeatSpellTile(
              spell: spell,
              isSelected: _speciesOriginSelectedLevel == 0
                  ? state.speciesOriginFeatCantrips.contains(spell.index)
                  : state.speciesOriginFeatSpell == spell.index,
              onTap: () {
                if (_speciesOriginSelectedLevel == 0) {
                  ref
                      .read(creationProvider.notifier)
                      .toggleSpeciesOriginFeatCantrip(spell.index);
                } else {
                  ref
                      .read(creationProvider.notifier)
                      .setSpeciesOriginFeatSpell(spell.index);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
