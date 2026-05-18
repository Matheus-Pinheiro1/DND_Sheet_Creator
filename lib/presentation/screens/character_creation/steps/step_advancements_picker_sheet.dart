part of 'step_advancements.dart';

class _AdvancementPickerSheet extends ConsumerStatefulWidget {
  final int advLevel;
  final String? currentEntry;
  final CreationState state;

  const _AdvancementPickerSheet({
    required this.advLevel,
    required this.state,
    this.currentEntry,
  });

  @override
  ConsumerState<_AdvancementPickerSheet> createState() =>
      _AdvancementPickerSheetState();
}

class _AdvancementPickerSheetState
    extends ConsumerState<_AdvancementPickerSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, int> _deltas = {
    'str': 0,
    'dex': 0,
    'con': 0,
    'int': 0,
    'wis': 0,
    'cha': 0,
  };
  int get _asiTotal => _deltas.values.fold(0, (a, b) => a + b);

  String _search = '';
  String? _selectedFeatId;
  String? _selectedFeatAbility;

  int get _cap =>
      LevelAdvancementService.abilityCapForAdvancementLevel(widget.advLevel);

  bool get _canSave {
    if (_tabController.index == 0) return _asiTotal == 2;

    final feat = _selectedFeat;
    if (feat == null) return false;
    if (ProgressionService.isMagicInitiateId(feat.id)) {
      return true;
    }

    final abilityOptions = _featAbilityOptions(feat);
    if (abilityOptions.isEmpty) {
      return true;
    }

    final selectedAbility = _selectedFeatAbility;
    if (selectedAbility == null || selectedAbility.isEmpty) {
      return false;
    }

    return _canApplyFeatAbility(selectedAbility);
  }

  FeatModel? get _selectedFeat {
    final featId = _selectedFeatId;
    if (featId == null || featId.isEmpty) {
      return null;
    }
    return ProgressionService.findFeat(featId);
  }

  List<String> _featAbilityOptions(FeatModel feat) {
    return feat.optionalAbilityBonuses
        .map((ability) => ability.trim().toLowerCase())
        .where((ability) => _deltas.containsKey(ability))
        .toSet()
        .toList()
      ..sort();
  }

  int _abilityScoreBeforeCurrentEntry(String ability) {
    final character = widget.state.toCharacterModel();
    var score = switch (ability) {
      'str' => character.strength,
      'dex' => character.dexterity,
      'con' => character.constitution,
      'int' => character.intelligence,
      'wis' => character.wisdom,
      'cha' => character.charisma,
      _ => 0,
    };

    final entry = widget.currentEntry;
    if (entry == null || entry.isEmpty) {
      return score;
    }

    final payload = _extractPayload(entry);
    if (payload.isEmpty) {
      return score;
    }

    if (payload[0] == 'asi' && payload.length >= 2) {
      for (final part in payload[1].split(',')) {
        final split = part.split('+');
        if (split.length != 2 || split[0] != ability) {
          continue;
        }
        score -= int.tryParse(split[1]) ?? 0;
      }
      return score;
    }

    if (payload[0] == 'feat' && payload.length >= 3 && payload[2] == ability) {
      score -= 1;
    }

    return score;
  }

  bool _canApplyFeatAbility(String ability) {
    return LevelAdvancementService.canIncreaseAbility(
      currentScore: _abilityScoreBeforeCurrentEntry(ability),
      increase: 1,
      advancementLevel: widget.advLevel,
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _initFromEntry();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initFromEntry() {
    final entry = widget.currentEntry;
    if (entry == null) return;

    final payload = _extractPayload(entry);
    if (payload.isEmpty) return;

    if (payload[0] == 'asi' && payload.length >= 2) {
      for (final part in payload[1].split(',')) {
        final kv = part.split('+');
        if (kv.length == 2) {
          final ability = kv[0];
          final delta = int.tryParse(kv[1]) ?? 0;
          if (_deltas.containsKey(ability)) _deltas[ability] = delta;
        }
      }
    } else if (payload[0] == 'feat' && payload.length >= 2) {
      _selectedFeatId = payload[1];
      _selectedFeatAbility =
          payload.length >= 3 && payload[2].isNotEmpty ? payload[2] : null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _tabController.index = 1;
      });
    }
  }

  List<String> _extractPayload(String value) {
    if (!value.startsWith('level:')) return const [];
    final parts = value.split(':');
    if (parts.length < 4) return const [];
    return parts.skip(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Level ${widget.advLevel} Advancement',
                    style: AppTextStyles.cinzel(
                      color: AppTheme.gold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.currentEntry != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    tooltip: 'Clear selection',
                    onPressed: _clearAndClose,
                  ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Ability Score +2'),
              Tab(text: 'Feat'),
            ],
            labelColor: AppTheme.gold,
            unselectedLabelColor: Colors.white38,
            indicatorColor: AppTheme.crimson,
            labelStyle: AppTextStyles.cinzel(fontSize: 12),
          ),
          const Divider(height: 1, color: Colors.white12),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAsiTab(ctrl),
                _buildFeatTab(ctrl),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: ElevatedButton(
              onPressed: _canSave ? _save : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: AppTheme.crimson,
                disabledBackgroundColor: Colors.white10,
              ),
              child: Text(
                'Confirm Selection',
                style: AppTextStyles.cinzel(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsiTab(ScrollController ctrl) {
    final state = widget.state;
    final scores = {
      'str': state.strength,
      'dex': state.dexterity,
      'con': state.constitution,
      'int': state.intelligence,
      'wis': state.wisdom,
      'cha': state.charisma,
    };
    const labels = {
      'str': 'Strength',
      'dex': 'Dexterity',
      'con': 'Constitution',
      'int': 'Intelligence',
      'wis': 'Wisdom',
      'cha': 'Charisma',
    };
    final remaining = 2 - _asiTotal;

    return ListView(
      controller: ctrl,
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            remaining > 0
                ? 'Distribute $remaining more point${remaining > 1 ? 's' : ''}.'
                : 'All 2 points assigned. Hit Confirm to save.',
            style: AppTextStyles.lato(
              color: remaining == 0 ? Colors.greenAccent : Colors.white54,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 14),
        ...scores.entries.map((entry) {
          final ability = entry.key;
          final base = entry.value;
          final delta = _deltas[ability] ?? 0;
          final current = base + delta;
          final atCap = current >= _cap;
          final canAdd = remaining > 0 && !atCap;
          final canRemove = delta > 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: delta > 0
                  ? AppTheme.crimson.withValues(alpha: 0.12)
                  : AppTheme.charcoal,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: delta > 0
                    ? AppTheme.gold.withValues(alpha: 0.5)
                    : Colors.white10,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labels[ability] ?? ability.toUpperCase(),
                        style: AppTextStyles.cinzel(
                          color: delta > 0 ? AppTheme.gold : Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        delta > 0
                            ? '$base ->’ $current  (+$delta)'
                            : '$current${atCap ? '  (cap)' : ''}',
                        style: AppTextStyles.lato(
                          color: delta > 0
                              ? Colors.greenAccent
                              : atCap
                                  ? Colors.white30
                                  : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: canRemove ? Colors.white70 : Colors.white12,
                  onPressed: canRemove
                      ? () => setState(() => _deltas[ability] = delta - 1)
                      : null,
                ),
                Text(
                  '+$delta',
                  style: AppTextStyles.cinzel(
                    color: delta > 0 ? AppTheme.gold : Colors.white24,
                    fontSize: 14,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: canAdd ? Colors.white70 : Colors.white12,
                  onPressed: canAdd
                      ? () => setState(() => _deltas[ability] = delta + 1)
                      : null,
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        if (widget.advLevel >= 19)
          Text(
            'Epic boon level - ability cap raised to 30.',
            style: AppTextStyles.lato(color: Colors.white38, fontSize: 11),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildFeatTab(ScrollController ctrl) {
    final feats = kFeatCatalog.where((feat) {
      final matchesSearch = _search.isEmpty ||
          feat.name.toLowerCase().contains(_search.toLowerCase());

      if (!matchesSearch) return false;

      return LevelAdvancementService.canChooseFeatForAdvancement(
        feat,
        advancementLevel: widget.advLevel,
        levelAdvancements: widget.state.levelAdvancements,
        currentEntry: widget.currentEntry,
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search feats...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: feats.isEmpty
              ? Center(
                  child: Text(
                    'No feats match "$_search"',
                    style:
                        AppTextStyles.lato(color: Colors.white38, fontSize: 13),
                  ),
                )
              : ListView.builder(
                  controller: ctrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: feats.length,
                  itemBuilder: (_, i) {
                    final feat = feats[i];
                    final isSelected = _selectedFeatId == feat.id;
                    final isMagicInit =
                        ProgressionService.isMagicInitiateId(feat.id);
                    return _FeatTile(
                      feat: feat,
                      isSelected: isSelected,
                      isMagicInitiate: isMagicInit,
                      selectedAbility: isSelected ? _selectedFeatAbility : null,
                      availableAbilities: _featAbilityOptions(feat),
                      isAbilityAvailable: _canApplyFeatAbility,
                      onTap: () => setState(() {
                        _selectedFeatId = feat.id;
                        final abilityOptions = _featAbilityOptions(feat)
                            .where(_canApplyFeatAbility)
                            .toList();
                        _selectedFeatAbility = abilityOptions.length == 1
                            ? abilityOptions.first
                            : null;
                      }),
                      onAbilitySelected: (ability) =>
                          setState(() => _selectedFeatAbility = ability),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _save() {
    final notifier = ref.read(creationProvider.notifier);
    String entry;

    if (_tabController.index == 0) {
      final parts = _deltas.entries
          .where((e) => e.value > 0)
          .map((e) => '${e.key}+${e.value}')
          .join(',');
      entry = LevelAdvancementService.encodeAsi(
        level: widget.advLevel,
        rawBonuses: parts,
      );
    } else {
      final feat = _selectedFeat;
      if (feat == null) {
        return;
      }

      final ability =
          _featAbilityOptions(feat).isEmpty ? null : _selectedFeatAbility;

      if (ability != null && !_canApplyFeatAbility(ability)) {
        return;
      }

      entry = LevelAdvancementService.encodeFeat(
        level: widget.advLevel,
        featId: feat.id,
        ability: ability,
      );
    }

    notifier.setLevelAdvancement(entry);
    if (mounted) Navigator.of(context).pop();
  }

  void _clearAndClose() {
    ref.read(creationProvider.notifier).clearLevelAdvancement(widget.advLevel);
    if (mounted) Navigator.of(context).pop();
  }
}
