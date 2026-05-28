import 'dart:convert';

import 'package:dnd_character_sheet/data/models/item_filters.dart';
import 'package:dnd_character_sheet/data/models/item_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final itemsIndexProvider = FutureProvider<List<ItemModel>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/items_index.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
      .toList();
});

final itemsDescProvider = FutureProvider<Map<String, String>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/items_desc.json');
  final map = jsonDecode(raw) as Map<String, dynamic>;
  return map.map((k, v) => MapEntry(k, v as String));
});

final itemDescriptionProvider =
    FutureProvider.family<String, int>((ref, id) async {
  final descs = await ref.watch(itemsDescProvider.future);
  return descs[id.toString()] ?? '';
});

final itemFiltersProvider = StateProvider<ItemFilters>(
  (_) => const ItemFilters(),
);

final filteredItemsProvider = Provider<AsyncValue<List<ItemModel>>>((ref) {
  final allAsync = ref.watch(itemsIndexProvider);
  final filters = ref.watch(itemFiltersProvider);

  return allAsync.whenData((all) {
    return all.where((item) {
      if (!item.matchesQuery(filters.name)) return false;
      if (filters.types.isNotEmpty && !filters.types.contains(item.itemType)) {
        return false;
      }
      if (filters.rarities.isNotEmpty &&
          !filters.rarities.contains(item.rarity)) {
        return false;
      }
      if (filters.attunementOnly == true && !item.requiresAttunement) {
        return false;
      }
      return true;
    }).toList();
  });
});
