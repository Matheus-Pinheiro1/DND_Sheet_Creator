// lib/presentation/screens/monsters/monsters_screen.dart

import 'dart:async';

import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/core/utils/monster_combat_helpers.dart';
import 'package:dnd_character_sheet/data/local/monster_metadata.dart';
import 'package:dnd_character_sheet/data/models/encounter_participant.dart';
import 'package:dnd_character_sheet/data/models/monster_filters.dart';
import 'package:dnd_character_sheet/providers/dnd_api_providers.dart';
import 'package:dnd_character_sheet/providers/encounter_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/loading_dragon.dart';

part 'monster_quantity_sheet.dart';
part 'monsters_feedback_views.dart';
part 'monsters_filter_widgets.dart';
part 'monsters_result_widgets.dart';

class MonstersScreen extends ConsumerStatefulWidget {
  const MonstersScreen({super.key});

  @override
  ConsumerState<MonstersScreen> createState() => _MonstersScreenState();
}

class _MonstersScreenState extends ConsumerState<MonstersScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  bool _showFilters = false;
  final Set<String> _addingMonsterIndexes = {};
  late final AnimationController _filterAnim;
  late final Animation<double> _filterFade;

  @override
  void initState() {
    super.initState();
    _filterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _filterFade = CurvedAnimation(parent: _filterAnim, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _filterAnim.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final filters = ref.read(monsterFiltersProvider);
      ref.read(monsterFiltersProvider.notifier).state =
          filters.withName(value.trim());
    });
  }

  void _toggleFilters() {
    setState(() => _showFilters = !_showFilters);
    if (_showFilters) {
      _filterAnim.forward();
    } else {
      _filterAnim.reverse();
    }
  }

  void _clearAll() {
    _searchCtrl.clear();
    ref.read(monsterFiltersProvider.notifier).state = const MonsterFilters();
  }

  void _toggleCrPreset(CrRange preset) {
    final filters = ref.read(monsterFiltersProvider);
    if (filters.isCrPresetSelected(preset)) {
      ref.read(monsterFiltersProvider.notifier).state =
          filters.withCrRange(null, null);
    } else {
      ref.read(monsterFiltersProvider.notifier).state =
          filters.withCrRange(preset.min, preset.max);
    }
  }

  void _toggleType(String type) {
    final filters = ref.read(monsterFiltersProvider);
    final types = Set<String>.from(filters.types);
    if (types.contains(type)) {
      types.remove(type);
    } else {
      types.add(type);
    }
    ref.read(monsterFiltersProvider.notifier).state = filters.withTypes(types);
  }

  void _toggleSize(String size) {
    final filters = ref.read(monsterFiltersProvider);
    final sizes = Set<String>.from(filters.sizes);
    if (sizes.contains(size)) {
      sizes.remove(size);
    } else {
      sizes.add(size);
    }
    ref.read(monsterFiltersProvider.notifier).state = filters.withSizes(sizes);
  }

  Future<void> _addToEncounter(
    BuildContext context,
    String monsterIndex,
    String name,
    MonsterMeta? meta,
    int quantity,
  ) async {
    if (_addingMonsterIndexes.contains(monsterIndex)) return;
    final count = quantity.clamp(1, 50).toInt();
    setState(() => _addingMonsterIndexes.add(monsterIndex));

    try {
      final detail = await ref.read(monsterDetailProvider(monsterIndex).future);
      if (!mounted || !context.mounted) return;

      final legendaryActionsCount = MonsterCombatHelpers.legendaryActionsMax(
        detail.legendaryActions,
      );
      final legendaryResistancesCount =
          MonsterCombatHelpers.legendaryResistancesMax(
        detail.specialAbilities,
      );

      final displayName = detail.name.isNotEmpty ? detail.name : name;
      final notifier = ref.read(encounterProvider.notifier);
      for (var i = 0; i < count; i++) {
        notifier.addParticipant(
          EncounterParticipant.fromMonster(
            monsterIndex: monsterIndex,
            name: displayName,
            type: detail.type.isNotEmpty ? detail.type : meta?.type ?? '',
            crLabel: detail.challengeRatingLabel,
            hp: detail.hitPoints,
            ac: detail.armorClass,
            legendaryActionsCount: legendaryActionsCount,
            legendaryResistancesCount: legendaryResistancesCount,
          ),
        );
      }

      final activeEncounter = ref.read(encounterProvider);
      final encounterSuffix = notifier.hasMultipleEncounters
          ? ' to ${activeEncounter.name}'
          : ' to encounter';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count == 1
                ? '$displayName added$encounterSuffix'
                : '$displayName x$count added$encounterSuffix',
          ),
          backgroundColor: AppTheme.ashGray,
          action: SnackBarAction(
            label: 'View',
            textColor: AppTheme.gold,
            onPressed: () => context.push('/encounter'),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load $name details. Try again.'),
          backgroundColor: AppTheme.ashGray,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _addingMonsterIndexes.remove(monsterIndex));
      }
    }
  }

  Future<void> _chooseMonsterQuantityAndAdd(
    BuildContext context,
    String monsterIndex,
    String name,
    MonsterMeta? meta,
  ) async {
    if (_addingMonsterIndexes.contains(monsterIndex)) return;

    final quantity = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MonsterQuantitySheet(name: name, meta: meta),
    );

    if (!mounted || !context.mounted || quantity == null) return;
    await _addToEncounter(context, monsterIndex, name, meta, quantity);
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(monsterFiltersProvider);
    final monstersAsync = ref.watch(filteredMonstersProvider);
    final activeCount = filters.activeFilterCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monster Compendium'),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books_outlined),
            tooltip: 'Rules References',
            onPressed: () => context.push('/references'),
          ),
        ],
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, _) {
          final count = ref.watch(encounterProvider).participants.length;
          return FloatingActionButton.extended(
            onPressed: () => context.push('/encounter'),
            backgroundColor: AppTheme.crimson,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shield_outlined),
                if (count > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppTheme.gold,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: AppTheme.darkBrown,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: Text(
              count > 0 ? 'Encounter ($count)' : 'Encounter',
              style: AppTextStyles.cinzel(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
      body: Column(
        children: [
          // â”€â”€ Search bar + filter toggle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Search monster name...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 8),
                _FilterToggleButton(
                  isOpen: _showFilters,
                  activeCount: activeCount,
                  onTap: _toggleFilters,
                ),
              ],
            ),
          ),

          // â”€â”€ Animated filter panel â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          SizeTransition(
            sizeFactor: _filterFade,
            axisAlignment: -1,
            child: FadeTransition(
              opacity: _filterFade,
              child: _FilterPanel(
                filters: filters,
                onCrToggle: _toggleCrPreset,
                onTypeToggle: _toggleType,
                onSizeToggle: _toggleSize,
                onClear: _clearAll,
              ),
            ),
          ),

          // â”€â”€ Result count strip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (monstersAsync.hasValue)
            _ResultCountStrip(
              count: monstersAsync.valueOrNull?.length ?? 0,
              hasFilters: filters.hasActiveFilters,
            ),

          // â”€â”€ Monster list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Expanded(
            child: monstersAsync.when(
              loading: () =>
                  const LoadingDragon(label: 'Summoning monsters...'),
              error: (error, _) => _ErrorView(error: error.toString()),
              data: (monsters) {
                if (monsters.isEmpty) {
                  return _EmptyView(
                    hasFilters: filters.hasActiveFilters,
                    onClear: _clearAll,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  itemCount: monsters.length,
                  itemBuilder: (context, index) {
                    final m = monsters[index];
                    final meta = kMonsterMetadata[m.index];
                    return _MonsterCard(
                      name: m.name,
                      index: m.index,
                      meta: meta,
                      onTap: () => context.push('/monsters/${m.index}'),
                      isAdding: _addingMonsterIndexes.contains(m.index),
                      onAddToEncounter: () => _chooseMonsterQuantityAndAdd(
                        context,
                        m.index,
                        m.name,
                        meta,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
