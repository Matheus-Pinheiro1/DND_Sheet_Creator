class ItemFilters {
  final String name;
  final Set<String> types;
  final Set<String> rarities;
  final bool? attunementOnly;

  const ItemFilters({
    this.name = '',
    this.types = const {},
    this.rarities = const {},
    this.attunementOnly,
  });

  bool get hasActiveFilters =>
      name.isNotEmpty ||
      types.isNotEmpty ||
      rarities.isNotEmpty ||
      attunementOnly != null;

  int get activeFilterCount {
    int c = 0;
    if (name.isNotEmpty) c++;
    if (types.isNotEmpty) c++;
    if (rarities.isNotEmpty) c++;
    if (attunementOnly != null) c++;
    return c;
  }

  ItemFilters withName(String v) => ItemFilters(
      name: v,
      types: types,
      rarities: rarities,
      attunementOnly: attunementOnly);

  ItemFilters withTypes(Set<String> v) => ItemFilters(
      name: name, types: v, rarities: rarities, attunementOnly: attunementOnly);

  ItemFilters withRarities(Set<String> v) => ItemFilters(
      name: name, types: types, rarities: v, attunementOnly: attunementOnly);

  ItemFilters withAttunement(bool? v) => ItemFilters(
      name: name, types: types, rarities: rarities, attunementOnly: v);

  bool isTypeSelected(String t) => types.contains(t);
  bool isRaritySelected(String r) => rarities.contains(r);
}
