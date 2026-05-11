part of '../step_spells.dart';

extension _StepSpellsClassPickerHelpers on _StepSpellsState {
  Widget _buildClassSpellPicker(
    BuildContext context,
    CreationState state,
    List<SpellDto> allSpells,
    SpellSelectionLimits rules,
  ) {
    final selectedSpellDtos = allSpells
        .where((spell) => state.selectedSpells.contains(spell.index))
        .toList();
    final selectedCantrips =
        selectedSpellDtos.where((spell) => spell.level == 0).length;
    final selectedLeveled =
        selectedSpellDtos.where((spell) => spell.level > 0).length;
    final selectionSummary = rules.maxCantrips > 0
        ? 'Cantrips $selectedCantrips / ${rules.maxCantrips} • Prepared $selectedLeveled / ${rules.maxLeveledSpells}'
        : 'Prepared $selectedLeveled / ${rules.maxLeveledSpells}';

    final subclassGranted = kSubclassGrantedSpells2024[state.subclass];
    final speciesGranted = kSpeciesGrantedSpells2024[state.race];
    final hasBardMagicalSecrets = BardChoiceService.hasMagicalSecrets(
      className: state.className,
      level: state.level,
    );
    final hasWordsOfCreation = BardChoiceService.hasWordsOfCreation(
      className: state.className,
      level: state.level,
    );
    final artificerTinkerMagicSpells =
        state.className == 'artificer' && state.level >= 1
            ? const {
                1: ['Mending'],
              }
            : null;
    final druidMagicianCantrip = state.className == 'druid'
        ? DruidChoiceService.selectedMagicianCantrip(state.levelAdvancements)
        : null;
    final druidLandSpells = DruidChoiceService.landSpellIds(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
      entries: state.levelAdvancements,
    ).toSet();
    final druidLandSpellPreview = DruidChoiceService.landSpellLabelsByLevel(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
      entries: state.levelAdvancements,
    );
    final druidLandType = DruidChoiceService.selectedLandType(
      state.levelAdvancements,
    );
    final effectiveSubclassGranted = subclassGranted ??
        (druidLandSpellPreview.isEmpty ? null : druidLandSpellPreview);
    final effectiveSubclassName = subclassGranted != null ||
            druidLandType == null
        ? state.subclassName
        : '${state.subclassName} (${DruidChoiceService.landTypeLabel(druidLandType)})';
    final spellNameToIndex = buildSpellNameIndexMap(allSpells);
    final grantedSpellIds = buildGrantedSpellEntries(
      className: state.className,
      subclass: state.subclass,
      raceValue: state.race,
      level: state.level,
      spellNameToIndex: spellNameToIndex,
    ).map((entry) => entry.spellIndex);
    final blockedClassSpellIds = <String>{
      if (state.className == 'druid')
        ...DruidChoiceService.baseGrantedSpellIds(state.level),
      if (state.className == 'artificer')
        ...ArtificerChoiceService.baseGrantedSpellIds(state.level),
      if (druidMagicianCantrip != null) druidMagicianCantrip,
      ...druidLandSpells,
      ...grantedSpellIds,
      ...BardChoiceService.selectedLoreDiscoverySpells(
        state.levelAdvancements,
      ),
      if (BardChoiceService.selectedMoonCantrip(state.levelAdvancements) !=
          null)
        BardChoiceService.selectedMoonCantrip(state.levelAdvancements)!,
      if (state.className == 'warlock')
        ...WarlockChoiceService.baseGrantedSpellIds(
          level: state.level,
          entries: state.levelAdvancements,
        ),
      if (state.className == 'warlock')
        ...WarlockChoiceService.pactTomeSpellIds(state.levelAdvancements),
      if (state.className == 'warlock')
        ...WarlockChoiceService.selectedMysticArcanumSpells(
          state.levelAdvancements,
        ),
    };

    final availableLevels = <int>[
      if (rules.maxCantrips > 0 || selectedCantrips > 0) 0,
      for (int level = 1; level <= rules.maxSpellLevel; level++) level,
    ];
    if (availableLevels.isEmpty) {
      availableLevels.add(0);
    }
    if (!availableLevels.contains(_selectedLevel)) {
      _selectedLevel = availableLevels.first;
    }

    final filtered = allSpells.where((spell) {
      if (blockedClassSpellIds.contains(spell.index) &&
          !state.selectedSpells.contains(spell.index)) {
        return false;
      }
      final matchesLevel = spell.level == _selectedLevel;
      final matchesSearch = _searchQuery.isEmpty ||
          spell.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final withinAllowedLevel =
          spell.level == 0 || spell.level <= rules.maxSpellLevel;
      return matchesLevel && matchesSearch && withinAllowedLevel;
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      color: AppTheme.gold, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectionSummary,
                      style: AppTextStyles.cinzel(
                        color: AppTheme.gold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                rules.helperText,
                style: AppTextStyles.lato(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
              if (rules.spellSlots.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Spell Slots',
                  style: AppTextStyles.cinzel(
                    color: AppTheme.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: rules.spellSlots.entries
                      .map(
                        (entry) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.charcoal,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            '${_ordinalLabel(entry.key)} ${entry.value}',
                            style: AppTextStyles.lato(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        if (effectiveSubclassGranted != null || speciesGranted != null) ...[
          const SizedBox(height: 12),
          _GrantedSpellsPreview(
            title: 'Always Prepared / Granted Spells',
            subclassName: effectiveSubclassName,
            subclassMap: effectiveSubclassGranted,
            speciesName: state.raceName,
            speciesMap: speciesGranted,
          ),
        ],
        if (artificerTinkerMagicSpells != null) ...[
          const SizedBox(height: 12),
          _GrantedSpellsPreview(
            title: 'Tinker\'s Magic',
            subclassName: 'Artificer',
            subclassMap: artificerTinkerMagicSpells,
            speciesName: '',
            speciesMap: null,
          ),
        ],
        if (hasBardMagicalSecrets) ...[
          const SizedBox(height: 12),
          _BardMagicalSecretsCard(
            hasWordsOfCreation: hasWordsOfCreation,
          ),
        ],
        if (_shouldShowWizardChoices(state)) ...[
          const SizedBox(height: 12),
          _buildWizardSubclassChoices(state, allSpells),
        ],
        if (state.className == 'warlock' &&
            WarlockChoiceService.mysticArcanumSpellLevels(state.level)
                .isNotEmpty) ...[
          const SizedBox(height: 12),
          WarlockMysticArcanumSection(
            state: state,
            spells: allSpells,
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search spells by name...',
            prefixIcon: Icon(Icons.search),
            isDense: true,
          ),
          onChanged: (v) => _updateUi(() => _searchQuery = v),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: availableLevels.map((lvl) {
              final isSelected = _selectedLevel == lvl;
              final count =
                  selectedSpellDtos.where((spell) => spell.level == lvl).length;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ChoiceChip(
                      label: Text(
                        lvl == 0 ? 'Cantrips' : 'Level $lvl',
                        style: AppTextStyles.lato(fontSize: 12),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.crimson,
                      onSelected: (_) => _updateUi(() => _selectedLevel = lvl),
                    ),
                    if (count > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.gold,
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                _searchQuery.isNotEmpty
                    ? 'No spells found for "$_searchQuery"'
                    : 'No spells available at this level yet',
                style: AppTextStyles.lato(
                  color: Colors.white38,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...filtered.map(
            (spell) => _SpellSelectionTile(
              spell: spell,
              maxSpellLevel: rules.maxSpellLevel,
              currentCantrips: selectedCantrips,
              currentLeveled: selectedLeveled,
              maxCantrips: rules.maxCantrips,
              maxLeveled: rules.maxLeveledSpells,
            ),
          ),
      ],
    );
  }
}
