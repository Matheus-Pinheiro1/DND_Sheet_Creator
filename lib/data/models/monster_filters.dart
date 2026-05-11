import '../local/monster_metadata.dart';
import '../remote/monster_dto.dart';

class CrRange {
  final String label;
  final double min;
  final double? max;

  const CrRange({required this.label, required this.min, this.max});

  static const List<CrRange> presets = [
    CrRange(label: 'CR 0', min: 0, max: 0),
    CrRange(label: '1/8 – ½', min: 0.125, max: 0.5),
    CrRange(label: 'CR 1–4', min: 1, max: 4),
    CrRange(label: 'CR 5–10', min: 5, max: 10),
    CrRange(label: 'CR 11–16', min: 11, max: 16),
    CrRange(label: 'CR 17+', min: 17, max: null),
  ];
}

class MonsterFilters {
  final String nameQuery;
  final double? crMin;
  final double? crMax;
  final Set<String> types;
  final Set<String> sizes;

  const MonsterFilters({
    this.nameQuery = '',
    this.crMin,
    this.crMax,
    this.types = const {},
    this.sizes = const {},
  });

  bool get hasActiveFilters =>
      nameQuery.isNotEmpty ||
      crMin != null ||
      crMax != null ||
      types.isNotEmpty ||
      sizes.isNotEmpty;

  int get activeFilterCount {
    var n = 0;
    if (nameQuery.isNotEmpty) n++;
    if (crMin != null || crMax != null) n++;
    if (types.isNotEmpty) n++;
    if (sizes.isNotEmpty) n++;
    return n;
  }

  bool isCrPresetSelected(CrRange preset) =>
      crMin == preset.min && crMax == preset.max;

  MonsterFilters withName(String name) => MonsterFilters(
        nameQuery: name,
        crMin: crMin,
        crMax: crMax,
        types: types,
        sizes: sizes,
      );

  MonsterFilters withCrRange(double? min, double? max) => MonsterFilters(
        nameQuery: nameQuery,
        crMin: min,
        crMax: max,
        types: types,
        sizes: sizes,
      );

  MonsterFilters withTypes(Set<String> newTypes) => MonsterFilters(
        nameQuery: nameQuery,
        crMin: crMin,
        crMax: crMax,
        types: newTypes,
        sizes: sizes,
      );

  MonsterFilters withSizes(Set<String> newSizes) => MonsterFilters(
        nameQuery: nameQuery,
        crMin: crMin,
        crMax: crMax,
        types: types,
        sizes: newSizes,
      );

  MonsterFilters clear() => const MonsterFilters();

  List<MonsterSummaryDto> apply(List<MonsterSummaryDto> all) {
    if (!hasActiveFilters) return all;

    return all.where(_matches).toList();
  }

  bool _matches(MonsterSummaryDto m) {
    if (nameQuery.isNotEmpty &&
        !m.name.toLowerCase().contains(nameQuery.toLowerCase())) {
      return false;
    }

    if (crMin == null && crMax == null && types.isEmpty && sizes.isEmpty) {
      return true;
    }

    final meta = kMonsterMetadata[m.index];
    if (meta == null) return false;

    if (crMin != null && meta.cr < crMin!) return false;
    if (crMax != null && meta.cr > crMax!) return false;
    if (types.isNotEmpty && !types.contains(meta.type)) return false;
    if (sizes.isNotEmpty && !sizes.contains(meta.size)) return false;

    return true;
  }
}
