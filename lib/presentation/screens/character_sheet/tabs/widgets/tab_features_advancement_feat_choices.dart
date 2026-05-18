part of '../tab_features.dart';

extension _AdvancementPickerFeatChoices on _AdvancementPickerSheetState {
  List<Widget> _buildFeatChoiceWidgets() {
    final featId = _selectedFeat?.id ?? '';
    if (featId.isEmpty || ProgressionService.isMagicInitiateId(featId)) {
      return const [];
    }

    if (featId == 'skilled') {
      final options = [
        ..._AdvancementPickerSheetState._skillLabels.entries
            .map((entry) => ('skill:${entry.key}', entry.value)),
        ..._AdvancementPickerSheetState._artisanTools.map(
          (tool) => ('tool:$tool', tool),
        ),
        ..._AdvancementPickerSheetState._musicalInstruments.map(
          (tool) => ('tool:$tool', tool),
        ),
      ];
      return [
        const SizedBox(height: 12),
        _MultiChoiceSection(
          title: 'Choose 3 skills or tools',
          subtitle: '${_skilledChoices.length} / 3 selected',
          options: options,
          selectedValues: _skilledChoices,
          maxSelections: 3,
          onChanged: (values) => _updateState(() => _skilledChoices = values),
        ),
      ];
    }

    if (featId == 'crafter') {
      final options = _AdvancementPickerSheetState._artisanTools
          .map((tool) => ('tool:$tool', tool))
          .toList();
      return [
        const SizedBox(height: 12),
        _MultiChoiceSection(
          title: "Choose 3 artisan's tools",
          subtitle: '${_crafterTools.length} / 3 selected',
          options: options,
          selectedValues: _crafterTools,
          maxSelections: 3,
          onChanged: (values) => _updateState(() => _crafterTools = values),
        ),
      ];
    }

    if (featId == 'musician') {
      final options = _AdvancementPickerSheetState._musicalInstruments
          .map((tool) => ('tool:$tool', tool))
          .toList();
      return [
        const SizedBox(height: 12),
        _MultiChoiceSection(
          title: 'Choose 3 musical instruments',
          subtitle: '${_musicianInstruments.length} / 3 selected',
          options: options,
          selectedValues: _musicianInstruments,
          maxSelections: 3,
          onChanged: (values) =>
              _updateState(() => _musicianInstruments = values),
        ),
      ];
    }

    if (featId == 'skill-expert') {
      final skills = _AdvancementPickerSheetState._skillLabels.entries
          .map((entry) => (entry.key, entry.value))
          .toList();
      return [
        const SizedBox(height: 12),
        _SingleChoiceSection(
          title: 'Choose 1 skill proficiency',
          options: skills,
          selectedValue: _skillExpertSkill,
          onChanged: (value) => _updateState(() {
            _skillExpertSkill = value;
            if (_skillExpertExpertise.isEmpty) {
              _skillExpertExpertise = value;
            }
          }),
        ),
        const SizedBox(height: 12),
        _SingleChoiceSection(
          title: 'Choose 1 expertise skill',
          options: skills,
          selectedValue: _skillExpertExpertise,
          onChanged: (value) =>
              _updateState(() => _skillExpertExpertise = value),
        ),
      ];
    }

    return const [];
  }

  Widget _buildMagicInitiateChooser(List<SpellDto> spells) {
    final cantrips = spells.where((spell) => spell.level == 0).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final levelOne = spells.where((spell) => spell.level == 1).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final visibleCantrips = cantrips
        .where((spell) =>
            _magicInitiateSearch.isEmpty ||
            spell.name
                .toLowerCase()
                .contains(_magicInitiateSearch.toLowerCase()))
        .toList();
    final visibleLevelOne = levelOne
        .where((spell) =>
            _magicInitiateSearch.isEmpty ||
            spell.name
                .toLowerCase()
                .contains(_magicInitiateSearch.toLowerCase()))
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                selected: _magicInitiateAbility == ability,
                selectedColor: AppTheme.crimson,
                onSelected: (_) =>
                    _updateState(() => _magicInitiateAbility = ability),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search Magic Initiate spells...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
            onChanged: (value) =>
                _updateState(() => _magicInitiateSearch = value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Cantrips'),
                selected: _magicInitiateSelectedLevel == 0,
                selectedColor: AppTheme.crimson,
                onSelected: (_) =>
                    _updateState(() => _magicInitiateSelectedLevel = 0),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Level 1'),
                selected: _magicInitiateSelectedLevel == 1,
                selectedColor: AppTheme.crimson,
                onSelected: (_) =>
                    _updateState(() => _magicInitiateSelectedLevel = 1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _magicInitiateSelectedLevel == 0
                ? 'Cantrips: ${_magicInitiateCantrips.length} / 2'
                : 'Level 1 spell: ${_magicInitiateSpell.isEmpty ? 0 : 1} / 1',
            style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ...(_magicInitiateSelectedLevel == 0
                  ? visibleCantrips
                  : visibleLevelOne)
              .map(
            (spell) => InkWell(
              onTap: () {
                _updateState(() {
                  if (_magicInitiateSelectedLevel == 0) {
                    final next = List<String>.from(_magicInitiateCantrips);
                    if (next.contains(spell.index)) {
                      next.remove(spell.index);
                    } else if (next.length < 2) {
                      next.add(spell.index);
                    }
                    _magicInitiateCantrips = next;
                  } else {
                    _magicInitiateSpell = spell.index;
                  }
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (_magicInitiateSelectedLevel == 0
                          ? _magicInitiateCantrips.contains(spell.index)
                          : _magicInitiateSpell == spell.index)
                      ? AppTheme.crimson.withValues(alpha: 0.22)
                      : AppTheme.charcoal,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spell.name,
                      style: AppTextStyles.cinzel(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${spell.school} • ${spell.castingTime} • ${spell.range}',
                      style: AppTextStyles.lato(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
