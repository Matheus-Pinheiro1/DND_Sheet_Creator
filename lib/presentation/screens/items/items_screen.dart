import 'dart:async';

import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/data/models/item_filters.dart';
import 'package:dnd_character_sheet/data/models/item_model.dart';
import 'package:dnd_character_sheet/providers/item_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/app_navigation_drawer.dart';
import '../shared/widgets/loading_dragon.dart';

part 'items_result_widgets.dart';
part 'items_filter_widgets.dart';
part 'items_feedback_views.dart';

class ItemsScreen extends ConsumerStatefulWidget {
  const ItemsScreen({super.key});

  @override
  ConsumerState<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends ConsumerState<ItemsScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  bool _showFilters = false;
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
      final filters = ref.read(itemFiltersProvider);
      ref.read(itemFiltersProvider.notifier).state =
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
    ref.read(itemFiltersProvider.notifier).state = const ItemFilters();
  }

  void _toggleType(String type) {
    final filters = ref.read(itemFiltersProvider);
    final types = Set<String>.from(filters.types);
    if (types.contains(type)) {
      types.remove(type);
    } else {
      types.add(type);
    }
    ref.read(itemFiltersProvider.notifier).state = filters.withTypes(types);
  }

  void _toggleRarity(String rarity) {
    final filters = ref.read(itemFiltersProvider);
    final rarities = Set<String>.from(filters.rarities);
    if (rarities.contains(rarity)) {
      rarities.remove(rarity);
    } else {
      rarities.add(rarity);
    }
    ref.read(itemFiltersProvider.notifier).state =
        filters.withRarities(rarities);
  }

  void _toggleAttunement() {
    final filters = ref.read(itemFiltersProvider);
    ref.read(itemFiltersProvider.notifier).state = filters.withAttunement(
      filters.attunementOnly == true ? null : true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(itemFiltersProvider);
    final itemsAsync = ref.watch(filteredItemsProvider);
    final activeCount = filters.activeFilterCount;

    return Scaffold(
      drawer: AppNavigationDrawer(
        selectedRoute: '/items',
        onNavigate: (route) {
          if (context.mounted) context.go(route);
        },
      ),
      appBar: AppBar(
        title: const Text('Item Compendium'),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books_outlined),
            tooltip: 'Rules References',
            onPressed: () => context.go('/references'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Search items...',
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
          SizeTransition(
            sizeFactor: _filterFade,
            axisAlignment: -1,
            child: FadeTransition(
              opacity: _filterFade,
              child: _FilterPanel(
                filters: filters,
                onTypeToggle: _toggleType,
                onRarityToggle: _toggleRarity,
                onAttunementToggle: _toggleAttunement,
                onClear: _clearAll,
              ),
            ),
          ),
          if (itemsAsync.hasValue)
            _ResultCountStrip(
              count: itemsAsync.valueOrNull?.length ?? 0,
              hasFilters: filters.hasActiveFilters,
            ),
          Expanded(
            child: itemsAsync.when(
              loading: () =>
                  const LoadingDragon(label: 'Loading item compendium…'),
              error: (e, _) => _ErrorView(error: e.toString()),
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyView(
                    hasFilters: filters.hasActiveFilters,
                    onClear: _clearAll,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      _ItemCard(item: items[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
