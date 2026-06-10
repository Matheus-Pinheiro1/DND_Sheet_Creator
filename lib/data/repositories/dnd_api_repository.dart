import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_flutter/hive_flutter.dart';

import '../models/item_model.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/hive_constants.dart';
import '../local/subclasses_2024_data_expanded.dart';
import '../local/granted_spells_2024.dart';
import '../models/class_feature_model.dart';
import '../remote/background_dto.dart';
import '../remote/class_dto.dart';
import '../remote/monster_dto.dart';
import '../remote/race_dto.dart';
import '../remote/spell_dto.dart';
import '../services/class_features_service.dart';

class DndApiRepository {
  final Dio _dio;
  static const _base = '${AppStrings.baseApiUrl}/v1';
  static const _baseNoVersion = AppStrings.baseApiUrl;
  static const _baseV2 = '${AppStrings.baseApiUrl}/v2';
  static const _itemsCacheKey = 'items_index_open5e_2024_vom_v1';
  static const _itemPageLimit = 1000;
  static const _itemSourceFilter = 'document__key__in=srd-2024,vom';
  static const _itemFields =
      'fields=key,name,desc,category,weapon,armor,weight,cost,document';
  static const _magicItemFields =
      'fields=key,name,desc,category,rarity,weapon,armor,weight,cost,'
      'requires_attunement,document';
  static const _documentFields =
      'document__fields=name,key,display_name,publisher';

  DndApiRepository(this._dio);

  Box<String> get _cacheBox => Hive.box<String>(HiveConstants.spellCacheBox);
  final ClassFeaturesService _fallbackFeatureService =
      const ClassFeaturesService();
  Future<List<SpellDto>>? _localSpellAdditionsFuture;

  static const Set<String> _core2024Classes = {
    'barbarian',
    'bard',
    'cleric',
    'druid',
    'fighter',
    'monk',
    'paladin',
    'ranger',
    'rogue',
    'sorcerer',
    'warlock',
    'wizard',
  };
  static const Set<String> _localOnlyUaClasses = {'artificer', 'psion'};
  static const Set<String> _hiddenUaClasses = {'psion'};

  Future<List<RaceDto>> getRaces() async {
    final local = await _loadLocalList('assets/data/2024/races.json');
    return local.map(RaceDto.fromJson).toList();
  }

  Future<List<ClassDto>> getClasses() async {
    final local = await _loadLocalList('assets/data/2024/classes.json');
    return local.map(ClassDto.fromJson).toList();
  }

  Future<List<ClassDto>> getUaClasses() async {
    return (await _loadLocalList('assets/data/2024/ua_classes.json'))
        .map(ClassDto.fromJson)
        .where((cls) => !_hiddenUaClasses.contains(cls.index))
        .toList();
  }

  /// Retorna subclasses do catálogo local 2024.
  /// Se a classe não tem subclasses registradas localmente, retorna lista vazia
  /// (sem fallback para API, que retornaria índices da 5e velha).
  Future<List<Map<String, String>>> getSubclassesForClass(
      String classIndex) async {
    final normalized = classIndex.trim().toLowerCase();
    return List<Map<String, String>>.from(
      kLocal2024SubclassOptions[normalized] ?? const <Map<String, String>>[],
    );
  }

  Future<List<BackgroundDto>> getBackgrounds() async {
    const cacheKey = 'backgrounds_full_v2';
    final local = (await _loadLocalList('assets/data/2024/backgrounds.json'))
        .map(BackgroundDto.fromJson)
        .toList();
    if (local.isNotEmpty) {
      await _cacheBox.put(
          cacheKey, jsonEncode(local.map((e) => e.toJson()).toList()));
      return local;
    }
    try {
      final res = await _dio.get('$_base/backgrounds');
      final list = res.data['results'] as List<dynamic>;
      final backgrounds = await Future.wait(
          list.map((b) => _getBackground(b['index'] as String)));
      await _cacheBox.put(
          cacheKey, jsonEncode(backgrounds.map((e) => e.toJson()).toList()));
      return backgrounds;
    } catch (_) {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        return (jsonDecode(cached) as List<dynamic>)
            .map((e) =>
                BackgroundDto.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return local;
    }
  }

  Future<BackgroundDto> _getBackground(String index) async {
    final res = await _dio.get('$_base/backgrounds/$index');
    return BackgroundDto.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<List<SpellDto>> getSpellsForClass(String classIndex) async {
    final normalized = classIndex.trim().toLowerCase();
    try {
      return (await _getLocalSpellAdditions())
          .where((s) => s.classIndices.contains(normalized))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (_) {
      final cached = _cacheBox.get('spells_${classIndex}_v5');
      if (cached != null) {
        return _decodeSpellList(cached)
          ..sort((a, b) => a.name.compareTo(b.name));
      }
      return const [];
    }
  }

  Future<List<SpellDto>> getAllSpells() async {
    try {
      return [...await _getLocalSpellAdditions()]
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (_) {
      final cached = _cacheBox.get('spells_all_detailed_v5');
      if (cached != null) {
        return _decodeSpellList(cached)
          ..sort((a, b) => a.name.compareTo(b.name));
      }
      return const [];
    }
  }

  Future<List<SpellDto>> getSpellsByIndices(List<String> indices) async {
    if (indices.isEmpty) return const [];
    final wanted = indices.toSet();
    final all = await getAllSpells();
    return all.where((s) => wanted.contains(s.index)).toList()
      ..sort((a, b) => a.level == b.level
          ? a.name.compareTo(b.name)
          : a.level.compareTo(b.level));
  }

  Future<void> clearSpellCache(String classIndex) async {
    await _cacheBox.delete('spells_${classIndex}_v5');
    await _cacheBox.delete('spells_all_detailed_v5');
  }

  static const _monsterCacheKey = 'monsters_index_v4';

  static const _docPriority = {
    'wotc-srd': 0,
    'a5e': 1,
    'menagerie': 2,
    'tob': 3,
    'tob2': 4,
    'tob3': 5,
    'cc': 6,
  };

  Future<List<ItemModel>> getItems() async {
    final cached = _cacheBox.get(_itemsCacheKey);
    if (cached != null) {
      return (jsonDecode(cached) as List<dynamic>)
          .map((e) => ItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    final results = await Future.wait([
      _fetchAllOpen5ePages(
        '$_baseV2/items/?limit=$_itemPageLimit&$_itemSourceFilter&$_itemFields'
        '&$_documentFields',
      ),
      _fetchAllOpen5ePages(
        '$_baseV2/magicitems/?limit=$_itemPageLimit&$_itemSourceFilter'
        '&$_magicItemFields'
        '&$_documentFields',
      ),
    ]);

    final normalItems = results[0];
    final magicItems = results[1];

    final byId = <String, ItemModel>{};

    for (final raw in normalItems) {
      if (!_isAllowedItemDocument(raw)) continue;
      final item = ItemModel.fromOpen5e(raw);
      if (item.id.isNotEmpty) byId[item.id] = item;
    }

    for (final raw in magicItems) {
      if (!_isAllowedItemDocument(raw)) continue;
      final item = ItemModel.fromOpen5e(raw);
      if (item.id.isNotEmpty) byId[item.id] = item;
    }

    final items = byId.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    await _cacheBox.put(
      _itemsCacheKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );

    return items;
  }

  Future<void> clearItemsCache() async {
    await _cacheBox.delete(_itemsCacheKey);
  }

  bool _isAllowedItemDocument(Map<String, dynamic> raw) {
    final document = raw['document'];
    if (document is Map) {
      final key = document['key']?.toString();
      return key == 'srd-2024' || key == 'vom';
    }
    final key = document?.toString();
    return key == 'srd-2024' || key == 'vom';
  }

  Future<List<Map<String, dynamic>>> _fetchAllOpen5ePages(
      String firstUrl) async {
    final result = <Map<String, dynamic>>[];
    String? nextUrl = firstUrl;

    while (nextUrl != null) {
      final res = await _dio.get<Map<String, dynamic>>(nextUrl);
      final data = res.data ?? const <String, dynamic>{};
      final list = data['results'] as List<dynamic>? ?? const [];

      result.addAll(
        list.map((e) => Map<String, dynamic>.from(e as Map)),
      );

      nextUrl = data['next'] as String?;
    }

    return result;
  }

  Future<List<MonsterSummaryDto>> getMonsters({String query = ''}) async {
    final q = query.trim().toLowerCase();

    final cached = _cacheBox.get(_monsterCacheKey);
    if (cached != null) {
      final all = (jsonDecode(cached) as List<dynamic>)
          .map((e) =>
              MonsterSummaryDto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return q.isEmpty
          ? all
          : all.where((m) => m.name.toLowerCase().contains(q)).toList();
    }

    try {
      final all = await _fetchAllOpen5eMonsters();
      await _cacheBox.put(
          _monsterCacheKey,
          jsonEncode(all
              .map((m) => {
                    'index': m.index,
                    'name': m.name,
                    'challenge_rating': m.challengeRating,
                    'cr_label': m.crLabel,
                    'type': m.type,
                    'size': m.size,
                  })
              .toList()));
      return q.isEmpty
          ? all
          : all.where((m) => m.name.toLowerCase().contains(q)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MonsterSummaryDto>> _fetchAllOpen5eMonsters() async {
    final best = <String, ({int priority, MonsterSummaryDto monster})>{};

    String? nextUrl = '$_base/monsters/?limit=100';

    while (nextUrl != null) {
      final res = await _dio.get<Map<String, dynamic>>(nextUrl);
      final data = res.data!;

      for (final raw in (data['results'] as List<dynamic>? ?? [])) {
        final map = Map<String, dynamic>.from(raw as Map);
        final monster = MonsterSummaryDto.fromJson(map);
        final docSlug = (map['document__slug'] ?? '').toString();
        final priority = _docPriority[docSlug] ?? 99;
        final key = monster.name.toLowerCase();

        final existing = best[key];
        if (existing == null || priority < existing.priority) {
          best[key] = (priority: priority, monster: monster);
        }
      }

      nextUrl = data['next'] as String?;
    }

    return best.values.map((e) => e.monster).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> clearMonsterCache() async {
    await _cacheBox.delete(_monsterCacheKey);
  }

  Future<MonsterDetailDto> getMonsterDetail(String monsterIndex) async {
    final cacheKey = 'monster_detail_$monsterIndex';

    try {
      final res = await _dio.get('$_base/monsters/$monsterIndex/');
      final dto =
          MonsterDetailDto.fromJson(Map<String, dynamic>.from(res.data as Map));
      await _cacheBox.put(cacheKey, jsonEncode(dto.toJson()));
      return dto;
    } catch (_) {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        return MonsterDetailDto.fromJson(
            Map<String, dynamic>.from(jsonDecode(cached) as Map));
      }
      rethrow;
    }
  }

  /// Retorna a lista local de skills do D&D 2024 (sem chamada de API).
  /// Todos os índices são idênticos entre 5e e 2024; não há necessidade
  /// de buscar isso remotamente.
  Future<List<Map<String, String>>> getSkills() async {
    return const [
      {'index': 'acrobatics', 'name': 'Acrobatics'},
      {'index': 'animal-handling', 'name': 'Animal Handling'},
      {'index': 'arcana', 'name': 'Arcana'},
      {'index': 'athletics', 'name': 'Athletics'},
      {'index': 'deception', 'name': 'Deception'},
      {'index': 'history', 'name': 'History'},
      {'index': 'insight', 'name': 'Insight'},
      {'index': 'intimidation', 'name': 'Intimidation'},
      {'index': 'investigation', 'name': 'Investigation'},
      {'index': 'medicine', 'name': 'Medicine'},
      {'index': 'nature', 'name': 'Nature'},
      {'index': 'perception', 'name': 'Perception'},
      {'index': 'performance', 'name': 'Performance'},
      {'index': 'persuasion', 'name': 'Persuasion'},
      {'index': 'religion', 'name': 'Religion'},
      {'index': 'sleight-of-hand', 'name': 'Sleight of Hand'},
      {'index': 'stealth', 'name': 'Stealth'},
      {'index': 'survival', 'name': 'Survival'},
    ];
  }

  Future<List<ClassLevelFeatures>> getClassFeatureProgression(
      String classIndex, int maxLevel) async {
    final normalized = classIndex.trim().toLowerCase();
    if (_core2024Classes.contains(normalized)) {
      return _fallbackFeatureService.getFeatureProgressionUpToLevel(
          normalized, maxLevel);
    }
    try {
      final levelsRes =
          await _dio.get('$_baseNoVersion/api/classes/$classIndex/levels');
      final list = levelsRes.data as List<dynamic>;
      final result = <ClassLevelFeatures>[];
      for (final raw in list) {
        final level = _extractLevel(raw);
        if (level <= 0 || level > maxLevel) continue;
        final features = await _mapFeatureRefs(
            raw['features'] as List<dynamic>? ?? const [], level);
        if (features.isNotEmpty) {
          result.add(ClassLevelFeatures(level: level, features: features));
        }
      }
      result.sort((a, b) => a.level.compareTo(b.level));
      return result;
    } catch (_) {
      return _fallbackFeatureService.getFeatureProgressionUpToLevel(
          classIndex, maxLevel);
    }
  }

  Future<List<ClassLevelFeatures>> getSubclassFeatureProgression(
      String subclassIndex, int maxLevel) async {
    final local = _getLocalSubclassProgression(subclassIndex, maxLevel);
    if (local.isNotEmpty) return local;
    try {
      final levelsRes = await _dio
          .get('$_baseNoVersion/api/subclasses/$subclassIndex/levels');
      final list = levelsRes.data as List<dynamic>;
      final result = <ClassLevelFeatures>[];
      for (final raw in list) {
        final level = _extractLevel(raw);
        if (level <= 0 || level > maxLevel) continue;
        final features = await _mapFeatureRefs(
            raw['features'] as List<dynamic>? ?? const [], level,
            source: 'subclass');
        if (features.isNotEmpty) {
          result.add(ClassLevelFeatures(level: level, features: features));
        }
      }
      result.sort((a, b) => a.level.compareTo(b.level));
      return result;
    } catch (_) {
      return const [];
    }
  }

  Future<List<ClassFeatureModel>> _mapFeatureRefs(List<dynamic> refs, int level,
      {String source = 'class'}) async {
    final result = <ClassFeatureModel>[];
    for (final ref in refs) {
      final item = ref as Map<String, dynamic>;
      final index = (item['index'] ?? '').toString();
      final name = (item['name'] ?? '').toString();
      result.add(await _getFeatureDetail(index, name, level, source: source));
    }
    return result;
  }

  Future<ClassFeatureModel> _getFeatureDetail(
      String index, String fallbackName, int level,
      {String source = 'class'}) async {
    try {
      final res = await _dio.get('$_baseNoVersion/api/features/$index');
      final data = res.data as Map<String, dynamic>;
      final name = (data['name'] ?? fallbackName).toString();
      final desc = (data['desc'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .join('\n\n')
          .trim();
      return _fallbackFeatureService.buildFeature(
          name: name,
          level: level,
          description: desc.isNotEmpty ? desc : null,
          source: source);
    } catch (_) {
      return _fallbackFeatureService.buildFeature(
          name: fallbackName, level: level, source: source);
    }
  }

  int _extractLevel(dynamic raw) {
    if (raw is! Map<String, dynamic>) return 0;
    final value = raw['level'] ?? raw['class_level'] ?? raw['subclass_level'];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  List<ClassLevelFeatures> _getLocalSubclassProgression(
      String subclassIndex, int maxLevel) {
    final normalized = subclassIndex.trim().toLowerCase();
    final raw = kLocal2024SubclassFeatures[normalized];
    if (raw == null || raw.isEmpty) return const [];
    final grantedMap = kSubclassGrantedSpells2024[normalized];
    final levels = raw.keys.map(int.parse).toList()..sort();
    return levels
        .where((l) => l <= maxLevel)
        .map(
          (level) => ClassLevelFeatures(
            level: level,
            features:
                (raw['$level'] ?? const <Map<String, String>>[]).map((item) {
              final name = item['name'] ?? 'Subclass Feature';
              return _fallbackFeatureService.buildFeature(
                name: name,
                level: level,
                source: 'subclass',
                description: _resolveLocalSubclassDescription(
                  normalizedSubclass: normalized,
                  featureName: name,
                  baseDescription: item['description'] ?? '',
                  grantedMap: grantedMap,
                ),
              );
            }).toList(),
          ),
        )
        .where((e) => e.features.isNotEmpty)
        .toList();
  }

  String _resolveLocalSubclassDescription({
    required String normalizedSubclass,
    required String featureName,
    required String baseDescription,
    required Map<int, List<String>>? grantedMap,
  }) {
    final lowerName = featureName.toLowerCase();
    if (grantedMap != null &&
        (lowerName.endsWith('spells') || lowerName.contains('domain spells'))) {
      final levels = grantedMap.keys.toList()..sort();
      final parts = <String>[
        'These spells are always prepared for you and do not count against the number of spells you can prepare.',
      ];
      for (final unlock in levels) {
        final spells = grantedMap[unlock] ?? const <String>[];
        if (spells.isEmpty) continue;
        parts.add('Level $unlock: ${spells.join(', ')}.');
      }
      return parts.join('\n\n');
    }
    return baseDescription;
  }

  Future<List<Map<String, dynamic>>> _loadLocalList(String path) async {
    final raw = await rootBundle.loadString(path);
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<SpellDto>> _getLocalSpellAdditions() =>
      _localSpellAdditionsFuture ??= _loadLocalSpellAdditions();

  Future<List<SpellDto>> _loadLocalSpellAdditions() async {
    try {
      return (await _loadLocalList('assets/data/2024/spells.json'))
          .map(SpellDto.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  List<SpellDto> _decodeSpellList(String cached) =>
      (jsonDecode(cached) as List<dynamic>)
          .map((e) => SpellDto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
}
