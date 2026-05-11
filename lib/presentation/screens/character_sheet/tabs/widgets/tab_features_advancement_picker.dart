part of '../tab_features.dart';

class _AdvancementResult {
  final CharacterModel character;
  const _AdvancementResult(this.character);
}

class _AdvancementPickerSheet extends ConsumerStatefulWidget {
  final CharacterModel character;
  const _AdvancementPickerSheet({required this.character});

  @override
  ConsumerState<_AdvancementPickerSheet> createState() =>
      _AdvancementPickerSheetState();
}

class _AdvancementPickerSheetState
    extends ConsumerState<_AdvancementPickerSheet> {
  bool _isFeat = true;
  FeatModel? _selectedFeat;
  String? _selectedFeatAbility;
  String _asiMode = 'single';
  String _singleAbility = 'str';
  String _firstAbility = 'str';
  String _secondAbility = 'dex';
  String _search = '';
  String _magicInitiateAbility = 'int';
  List<String> _magicInitiateCantrips = const [];
  String _magicInitiateSpell = '';
  int _magicInitiateSelectedLevel = 0;
  String _magicInitiateSearch = '';
  List<String> _skilledChoices = const [];
  List<String> _crafterTools = const [];
  List<String> _musicianInstruments = const [];
  String _skillExpertSkill = '';
  String _skillExpertExpertise = '';

  static const _abilities = ['str', 'dex', 'con', 'int', 'wis', 'cha'];
  static const _skillLabels = {
    'acrobatics': 'Acrobatics',
    'animal-handling': 'Animal Handling',
    'arcana': 'Arcana',
    'athletics': 'Athletics',
    'deception': 'Deception',
    'history': 'History',
    'insight': 'Insight',
    'intimidation': 'Intimidation',
    'investigation': 'Investigation',
    'medicine': 'Medicine',
    'nature': 'Nature',
    'perception': 'Perception',
    'performance': 'Performance',
    'persuasion': 'Persuasion',
    'religion': 'Religion',
    'sleight-of-hand': 'Sleight of Hand',
    'stealth': 'Stealth',
    'survival': 'Survival',
  };
  static const _artisanTools = [
    "Alchemist's Supplies",
    "Brewer's Supplies",
    "Calligrapher's Supplies",
    "Carpenter's Tools",
    "Cartographer's Tools",
    "Cobbler's Tools",
    "Cook's Utensils",
    "Glassblower's Tools",
    "Jeweler's Tools",
    "Leatherworker's Tools",
    "Mason's Tools",
    "Painter's Supplies",
    "Potter's Tools",
    "Smith's Tools",
    "Tinker's Tools",
    "Weaver's Tools",
    "Woodcarver's Tools",
  ];
  static const _musicalInstruments = [
    'Bagpipes',
    'Drum',
    'Dulcimer',
    'Flute',
    'Horn',
    'Lute',
    'Lyre',
    'Pan Flute',
    'Shawm',
    'Viol',
  ];

  List<String> _featAbilityOptions(FeatModel feat) {
    return feat.optionalAbilityBonuses
        .map((ability) => ability.trim().toLowerCase())
        .where((ability) => _abilities.contains(ability))
        .toSet()
        .toList()
      ..sort();
  }

  int _abilityScore(CharacterModel character, String ability) {
    switch (ability) {
      case 'str':
        return character.strength;
      case 'dex':
        return character.dexterity;
      case 'con':
        return character.constitution;
      case 'int':
        return character.intelligence;
      case 'wis':
        return character.wisdom;
      case 'cha':
        return character.charisma;
      default:
        return 0;
    }
  }

  bool _canApplyFeatAbility(String ability) {
    final advancementLevel =
        LevelAdvancementService.nextAvailableLevel(widget.character);
    if (advancementLevel == null) {
      return false;
    }

    return LevelAdvancementService.canIncreaseAbility(
      currentScore: _abilityScore(widget.character, ability),
      increase: 1,
      advancementLevel: advancementLevel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final advancementLevel =
        LevelAdvancementService.nextAvailableLevel(widget.character);
    final visibleFeats = (advancementLevel == null
        ? <FeatModel>[]
        : kFeatCatalog.where((feat) {
            final matchesSearch = _search.isEmpty ||
                feat.name.toLowerCase().contains(_search.toLowerCase());

            if (!matchesSearch) return false;

            return LevelAdvancementService.canChooseFeatForAdvancement(
              feat,
              advancementLevel: advancementLevel,
              levelAdvancements: widget.character.levelAdvancements,
            );
          }).toList())
      ..sort((a, b) => a.name.compareTo(b.name));
    final magicInitiateId = _selectedFeat?.id ?? '';
    final isMagicInitiate =
        ProgressionService.isMagicInitiateId(magicInitiateId);
    final magicList = isMagicInitiate
        ? ProgressionService.magicInitiateListFromId(magicInitiateId)
        : '';
    final magicSpellsAsync =
        isMagicInitiate ? ref.watch(classSpellsProvider(magicList)) : null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Choose Advancement',
              style: AppTextStyles.cinzel(
                color: AppTheme.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Feat')),
                ButtonSegment(value: false, label: Text('Ability Scores')),
              ],
              selected: {_isFeat},
              onSelectionChanged: (set) => setState(() => _isFeat = set.first),
            ),
            const SizedBox(height: 16),
            if (_isFeat) ...[
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search feat...',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: visibleFeats.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) {
                    final feat = visibleFeats[i];
                    final selected = _selectedFeat?.id == feat.id;
                    return InkWell(
                      onTap: () => setState(() {
                        _selectedFeat = feat;
                        final abilityOptions = _featAbilityOptions(feat)
                            .where(_canApplyFeatAbility)
                            .toList();
                        _selectedFeatAbility = abilityOptions.length == 1
                            ? abilityOptions.first
                            : null;
                        _skilledChoices = const [];
                        _crafterTools = const [];
                        _musicianInstruments = const [];
                        _skillExpertSkill = '';
                        _skillExpertExpertise = '';
                        if (ProgressionService.isMagicInitiateId(feat.id)) {
                          _magicInitiateAbility = 'int';
                          _magicInitiateCantrips = const [];
                          _magicInitiateSpell = '';
                          _magicInitiateSelectedLevel = 0;
                          _magicInitiateSearch = '';
                        }
                      }),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.crimson : AppTheme.ashGray,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? AppTheme.gold : Colors.white10,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feat.name,
                              style: AppTextStyles.cinzel(
                                color: selected ? AppTheme.gold : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              feat.minimumLevel >= 19
                                  ? 'Level 19+'
                                  : feat.minimumLevel >= 4
                                      ? 'Level 4+'
                                      : 'Origin feat',
                              style: AppTextStyles.lato(
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (feat.prerequisite.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Prerequisite: ${feat.prerequisite}',
                                style: AppTextStyles.lato(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              feat.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.lato(
                                color: Colors.white60,
                                fontSize: 12,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_selectedFeat != null &&
                  _featAbilityOptions(_selectedFeat!).isNotEmpty &&
                  !isMagicInitiate) ...[
                const SizedBox(height: 12),
                Text(
                  'Feat ability bonus',
                  style: AppTextStyles.cinzel(
                    color: AppTheme.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose the ability this feat increases.',
                  style: AppTextStyles.lato(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _featAbilityOptions(_selectedFeat!).map((ability) {
                    final enabled = _canApplyFeatAbility(ability);
                    return ChoiceChip(
                      label: Text(ability.toUpperCase()),
                      selected: _selectedFeatAbility == ability,
                      selectedColor: AppTheme.crimson,
                      onSelected: enabled
                          ? (_) => setState(() {
                                _selectedFeatAbility = ability;
                              })
                          : null,
                      labelStyle: AppTextStyles.lato(
                        color: enabled ? Colors.white : Colors.white38,
                      ),
                    );
                  }).toList(),
                ),
                if (!_featAbilityOptions(_selectedFeat!)
                    .any(_canApplyFeatAbility)) ...[
                  const SizedBox(height: 8),
                  Text(
                    'All allowed abilities are already at the cap for this level.',
                    style: AppTextStyles.lato(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
              if (isMagicInitiate && magicSpellsAsync != null) ...[
                const SizedBox(height: 12),
                magicSpellsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: LoadingDragon(
                        label: 'Loading Magic Initiate spells...'),
                  ),
                  error: (_, __) => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.ashGray,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade700),
                    ),
                    child: Text(
                      'Failed to load the Magic Initiate spell list.',
                      style: AppTextStyles.lato(color: Colors.white70),
                    ),
                  ),
                  data: _buildMagicInitiateChooser,
                ),
              ],
              ..._buildFeatChoiceWidgets(),
            ] else ...[
              Text(
                'Choose how to apply the ASI.',
                style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 12),
              ChoiceChip(
                label: const Text('+2 to one ability'),
                selected: _asiMode == 'single',
                selectedColor: AppTheme.crimson,
                onSelected: (_) => setState(() => _asiMode = 'single'),
              ),
              const SizedBox(height: 8),
              ChoiceChip(
                label: const Text('+1 to two abilities'),
                selected: _asiMode == 'double',
                selectedColor: AppTheme.crimson,
                onSelected: (_) => setState(() => _asiMode = 'double'),
              ),
              const SizedBox(height: 12),
              if (_asiMode == 'single')
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _abilities
                      .map(
                        (ability) => ChoiceChip(
                          label: Text(ability.toUpperCase()),
                          selected: _singleAbility == ability,
                          selectedColor: AppTheme.crimson,
                          onSelected: (_) =>
                              setState(() => _singleAbility = ability),
                        ),
                      )
                      .toList(),
                )
              else ...[
                Text('First ability',
                    style: AppTextStyles.lato(
                        color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: _abilities
                      .map(
                        (ability) => ChoiceChip(
                          label: Text(ability.toUpperCase()),
                          selected: _firstAbility == ability,
                          selectedColor: AppTheme.crimson,
                          onSelected: (_) =>
                              setState(() => _firstAbility = ability),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Text('Second ability',
                    style: AppTextStyles.lato(
                        color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: _abilities
                      .map(
                        (ability) => ChoiceChip(
                          label: Text(ability.toUpperCase()),
                          selected: _secondAbility == ability,
                          selectedColor: AppTheme.crimson,
                          onSelected: (_) =>
                              setState(() => _secondAbility = ability),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: Text(
                  'Apply Choice',
                  style: AppTextStyles.cinzel(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateState(VoidCallback update) => setState(update);
}
