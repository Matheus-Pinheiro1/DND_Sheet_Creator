import 'package:dnd_character_sheet/data/models/item_filters.dart';
import 'package:dnd_character_sheet/data/models/item_model.dart';
import 'package:dnd_character_sheet/providers/dnd_api_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final itemsIndexProvider = FutureProvider<List<ItemModel>>((ref) {
  ref.keepAlive();
  return ref.watch(dndApiRepositoryProvider).getItems();
});

final itemDescriptionProvider =
    FutureProvider.family<String, String>((ref, id) async {
  final items = await ref.watch(itemsIndexProvider.future);

  for (final item in items) {
    if (item.id == id) return item.description;
  }

  return '';
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
