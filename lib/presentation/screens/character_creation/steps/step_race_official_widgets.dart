part of 'step_race.dart';

class _OfficialRaceCard extends StatelessWidget {
  final RaceDto race;
  final bool isSelected;
  final List<String> selectedOptionIds;
  final String selectedExtraLanguage;
  final ValueChanged<String> onSelectExtraLanguage;
  final VoidCallback onTap;
  final void Function(SpeciesOptionGroupDto group, SpeciesOptionDto option)
      onSelectOption;

  const _OfficialRaceCard({
    required this.race,
    required this.isSelected,
    required this.selectedOptionIds,
    required this.selectedExtraLanguage,
    required this.onSelectExtraLanguage,
    required this.onTap,
    required this.onSelectOption,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? AppTheme.crimson.withValues(alpha: 0.25) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppTheme.gold : Colors.white10,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(
                    race.name,
                    style: AppTextStyles.cinzel(
                      color: isSelected ? AppTheme.gold : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ContextInfoButton(
                  title: race.name,
                  body: race.description,
                  size: 18,
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.gold,
                    size: 20,
                  ),
              ]),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _Badge(
                    '${race.speed} ft',
                    helpText:
                        '${race.name} walking speed is ${race.speed} feet.',
                  ),
                  _Badge(
                    race.size,
                    helpText: '${race.name} is a ${race.size} creature.',
                  ),
                  if (race.languages.isNotEmpty)
                    _Badge(
                      race.languages.join(', '),
                      helpText:
                          'You begin play able to speak, read, and write: ${race.languages.join(', ')}.',
                    ),
                ],
              ),
              if (race.traits.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: race.traits
                      .map(
                        (trait) => _Badge(
                          trait.name,
                          helpText: race.traitDetails[trait.index] ??
                              race.description,
                          compact: true,
                        ),
                      )
                      .toList(),
                ),
              ],
              if (race.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  race.description,
                  style: AppTextStyles.lato(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
              if (isSelected && race.optionGroups.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...race.optionGroups.map(
                  (group) {
                    final selectedOptionForGroup =
                        _selectedOptionForGroup(group);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  group.label,
                                  style: AppTextStyles.cinzel(
                                    color: AppTheme.gold,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (group.helpText.trim().isNotEmpty)
                                ContextInfoButton(
                                  title: group.label,
                                  body: group.helpText,
                                  size: 16,
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: group.options.map((option) {
                              final selected = selectedOptionIds.length >= 2 &&
                                  selectedOptionIds[0] == group.id &&
                                  selectedOptionIds[1] == option.id;
                              return ChoiceChip(
                                label: Text(option.name),
                                selected: selected,
                                selectedColor: AppTheme.crimson,
                                labelStyle: AppTextStyles.lato(
                                  color:
                                      selected ? AppTheme.gold : Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                                onSelected: (_) =>
                                    onSelectOption(group, option),
                                avatar: option.details.trim().isEmpty
                                    ? null
                                    : InkWell(
                                        onTap: () => showContextInfoDialog(
                                          context,
                                          title: option.name,
                                          body: option.details,
                                        ),
                                        child: const Icon(
                                          Icons.info_outline,
                                          color: AppTheme.gold,
                                          size: 16,
                                        ),
                                      ),
                              );
                            }).toList(),
                          ),
                          if (selectedOptionForGroup != null &&
                              selectedOptionForGroup.details
                                  .trim()
                                  .isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedOptionForGroup.name,
                                    style: AppTextStyles.cinzel(
                                      color: AppTheme.gold,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (selectedOptionForGroup.summary
                                      .trim()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      selectedOptionForGroup.summary,
                                      style: AppTextStyles.lato(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(
                                    selectedOptionForGroup.details,
                                    style: AppTextStyles.lato(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
              if (isSelected && _hasExtraLanguageChoice) ...[
                const SizedBox(height: 12),
                _SpeciesExtraLanguageChooser(
                  raceName: race.name,
                  selectedLanguage: selectedExtraLanguage,
                  onChanged: onSelectExtraLanguage,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  SpeciesOptionDto? _selectedOptionForGroup(SpeciesOptionGroupDto group) {
    if (selectedOptionIds.length < 2 || selectedOptionIds[0] != group.id) {
      return null;
    }
    for (final option in group.options) {
      if (option.id == selectedOptionIds[1]) return option;
    }
    return null;
  }

  bool get _hasExtraLanguageChoice {
    return race.languages.any((language) {
      final normalized = language.trim().toLowerCase();
      return normalized.contains('extra language') ||
          normalized.contains('language of your choice');
    });
  }
}

class _SpeciesExtraLanguageChooser extends StatelessWidget {
  final String raceName;
  final String selectedLanguage;
  final ValueChanged<String> onChanged;

  const _SpeciesExtraLanguageChooser({
    required this.raceName,
    required this.selectedLanguage,
    required this.onChanged,
  });

  static const _languageOptions = [
    'Common Sign Language',
    'Draconic',
    'Dwarvish',
    'Elvish',
    'Giant',
    'Gnomish',
    'Goblin',
    'Halfling',
    'Orc',
    'Abyssal',
    'Celestial',
    'Deep Speech',
    'Infernal',
    'Primordial',
    'Sylvan',
    'Undercommon',
  ];

  @override
  Widget build(BuildContext context) {
    final complete = selectedLanguage.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: complete
              ? Colors.greenAccent.withValues(alpha: 0.35)
              : AppTheme.gold.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$raceName Language',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            complete
                ? 'Selected: $selectedLanguage'
                : 'Choose the extra language granted by $raceName.',
            style: AppTextStyles.lato(
              color: complete ? Colors.greenAccent : Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _languageOptions.map((language) {
              final selected = selectedLanguage == language;
              return ChoiceChip(
                label: Text(language),
                selected: selected,
                selectedColor: AppTheme.crimson,
                labelStyle: AppTextStyles.lato(
                  color: selected ? AppTheme.gold : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                onSelected: (_) => onChanged(language),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
