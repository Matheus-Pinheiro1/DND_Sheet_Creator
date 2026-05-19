import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/class_feature_model.dart';
import '../data/models/monster_filters.dart';
import '../data/remote/race_dto.dart';
import '../data/remote/class_dto.dart';
import '../data/remote/spell_dto.dart';
import '../data/remote/background_dto.dart';
import '../data/remote/monster_dto.dart';
import '../data/repositories/dnd_api_repository.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Accept': 'application/json'},
  ));
});

final dndApiRepositoryProvider = Provider<DndApiRepository>((ref) {
  return DndApiRepository(ref.watch(dioProvider));
});

final racesProvider = FutureProvider<List<RaceDto>>((ref) {
  return ref.watch(dndApiRepositoryProvider).getRaces();
});

final classesProvider = FutureProvider<List<ClassDto>>((ref) {
  return ref.watch(dndApiRepositoryProvider).getClasses();
});

final uaClassesProvider = FutureProvider<List<ClassDto>>((ref) {
  return ref.watch(dndApiRepositoryProvider).getUaClasses();
});

final subclassesProvider =
    FutureProvider.family<List<Map<String, String>>, String>((ref, classIdx) {
  return ref.watch(dndApiRepositoryProvider).getSubclassesForClass(classIdx);
});

final backgroundsProvider = FutureProvider<List<BackgroundDto>>((ref) {
  return ref.watch(dndApiRepositoryProvider).getBackgrounds();
});

final classSpellsProvider =
    FutureProvider.family<List<SpellDto>, String>((ref, classIdx) {
  ref.keepAlive();
  return ref.watch(dndApiRepositoryProvider).getSpellsForClass(classIdx);
});

final refreshSpellCacheProvider =
    Provider.family<Future<void> Function(), String>((ref, classIdx) {
  return () async {
    final repo = ref.read(dndApiRepositoryProvider);
    await repo.clearSpellCache(classIdx);
    ref.invalidate(classSpellsProvider(classIdx));
  };
});

final allSpellsProvider = FutureProvider<List<SpellDto>>((ref) {
  ref.keepAlive();
  return ref.watch(dndApiRepositoryProvider).getAllSpells();
});

final spellsByIndicesProvider =
    FutureProvider.family<List<SpellDto>, List<String>>((ref, indices) {
  ref.keepAlive();
  return ref.watch(dndApiRepositoryProvider).getSpellsByIndices(indices);
});

final skillsProvider = FutureProvider<List<Map<String, String>>>((ref) {
  return ref.watch(dndApiRepositoryProvider).getSkills();
});

final classFeatureProgressionProvider = FutureProvider.family
    .autoDispose<List<ClassLevelFeatures>, ({String className, int level})>((
  ref,
  args,
) {
  return ref
      .watch(dndApiRepositoryProvider)
      .getClassFeatureProgression(args.className, args.level);
});

final subclassFeatureProgressionProvider = FutureProvider.family
    .autoDispose<List<ClassLevelFeatures>, ({String subclass, int level})>((
  ref,
  args,
) {
  if (args.subclass.isEmpty) return Future.value(const []);
  return ref
      .watch(dndApiRepositoryProvider)
      .getSubclassFeatureProgression(args.subclass, args.level);
});

// Monster providers

/// Loads the full monster index (no query) once and keeps it alive.
/// This is the source of truth for the filtered monsters screen.
final allMonstersProvider = FutureProvider<List<MonsterSummaryDto>>((ref) {
  ref.keepAlive();
  return ref.watch(dndApiRepositoryProvider).getMonsters();
});

/// Active filter state. Reset to MonsterFilters() to clear.
final monsterFiltersProvider =
    StateProvider<MonsterFilters>((ref) => const MonsterFilters());

/// Derived provider: [allMonstersProvider] with [monsterFiltersProvider] applied.
/// Consumers should watch this instead of [allMonstersProvider] directly.
final filteredMonstersProvider =
    Provider<AsyncValue<List<MonsterSummaryDto>>>((ref) {
  final allAsync = ref.watch(allMonstersProvider);
  final filters = ref.watch(monsterFiltersProvider);
  return allAsync.whenData(filters.apply);
});

/// Legacy provider kept for compatibility. Prefer [filteredMonstersProvider].
final monstersProvider =
    FutureProvider.family<List<MonsterSummaryDto>, String>((ref, query) {
  ref.keepAlive();
  return ref.watch(dndApiRepositoryProvider).getMonsters(query: query);
});

final monsterDetailProvider = FutureProvider.autoDispose
    .family<MonsterDetailDto, String>((ref, monsterIndex) {
  final cacheLink = ref.keepAlive();
  Timer? cacheTimer;

  ref.onCancel(() {
    cacheTimer = Timer(const Duration(minutes: 5), cacheLink.close);
  });
  ref.onResume(() {
    cacheTimer?.cancel();
    cacheTimer = null;
  });
  ref.onDispose(() {
    cacheTimer?.cancel();
  });

  return ref.watch(dndApiRepositoryProvider).getMonsterDetail(monsterIndex);
});
