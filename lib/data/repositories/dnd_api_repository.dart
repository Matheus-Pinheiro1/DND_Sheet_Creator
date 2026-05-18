import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_flutter/hive_flutter.dart';

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
  static const _base = '${AppStrings.baseApiUrl}/api/2014';
  static const _baseNoVersion = AppStrings.baseApiUrl;

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
  static const Set<String> _localOnlyUaClasses = {
    'artificer',
    'psion',
  };
  static const Set<String> _hiddenUaClasses = {
    'psion',
  };

  Future<List<RaceDto>> getRaces() async {
    final local = await _loadLocalList('assets/data/2024/races.json');
    return local.map(RaceDto.fromJson).toList();
  }

  Future<List<ClassDto>> getClasses() async {
    final local = await _loadLocalList('assets/data/2024/classes.json');
    return local.map(ClassDto.fromJson).toList();
  }

  Future<List<ClassDto>> getUaClasses() async {
    final local = (await _loadLocalList('assets/data/2024/ua_classes.json'))
        .map(ClassDto.fromJson)
        .where((cls) => !_hiddenUaClasses.contains(cls.index))
        .toList();
    return local;
  }

  Future<List<Map<String, String>>> getSubclassesForClass(
      String classIndex) async {
    final normalized = classIndex.trim().toLowerCase();
    final local = List<Map<String, String>>.from(
      kLocal2024SubclassOptions[normalized] ?? const <Map<String, String>>[],
    );

    if (local.isNotEmpty) {
      return local;
    }

    if (_localOnlyUaClasses.contains(normalized)) {
      return const [];
    }

    try {
      final res = await _dio.get('$_base/classes/$classIndex/subclasses');
      return (res.data['results'] as List<dynamic>)
          .map(
            (e) => {
              'index': (e['index'] ?? '').toString(),
              'name': (e['name'] ?? '').toString(),
            },
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<BackgroundDto>> getBackgrounds() async {
    const cacheKey = 'backgrounds_full_v2';
    final local = (await _loadLocalList('assets/data/2024/backgrounds.json'))
        .map(BackgroundDto.fromJson)
        .toList();
    if (local.isNotEmpty) {
      await _cacheBox.put(
        cacheKey,
        jsonEncode(local.map((e) => e.toJson()).toList()),
      );
      return local;
    }

    try {
      final res = await _dio.get('$_base/backgrounds');
      final list = res.data['results'] as List<dynamic>;
      final backgrounds = await Future.wait(
        list.map((b) => _getBackground(b['index'] as String)),
      );
      await _cacheBox.put(
        cacheKey,
        jsonEncode(backgrounds.map((e) => e.toJson()).toList()),
      );
      return backgrounds;
    } catch (_) {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        return (jsonDecode(cached) as List<dynamic>)
            .map(
              (e) =>
                  BackgroundDto.fromJson(Map<String, dynamic>.from(e as Map)),
            )
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
      final localAdditions = await _getLocalSpellAdditions();
      final localForClass = localAdditions
          .where((spell) => spell.classIndices.contains(normalized))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return localForClass;
    } catch (_) {
      final cached = _cacheBox.get('spells_${classIndex}_v5');
      if (cached != null) {
        return _decodeSpellList(cached)
          ..sort((a, b) => a.name.compareTo(b.name));
      }
      return const <SpellDto>[];
    }
  }

  Future<List<SpellDto>> getAllSpells() async {
    try {
      final localAdditions = await _getLocalSpellAdditions();
      return [...localAdditions]..sort((a, b) => a.name.compareTo(b.name));
    } catch (_) {
      final cached = _cacheBox.get('spells_all_detailed_v5');
      if (cached != null) {
        return _decodeSpellList(cached)
          ..sort((a, b) => a.name.compareTo(b.name));
      }
      return const <SpellDto>[];
    }
  }

  Future<List<SpellDto>> getSpellsByIndices(List<String> indices) async {
    if (indices.isEmpty) return const [];
    final wanted = indices.toSet();
    final all = await getAllSpells();
    final byIndex = {for (final spell in all) spell.index: spell};

    return byIndex.values
        .where((spell) => wanted.contains(spell.index))
        .toList()
      ..sort((a, b) => a.level == b.level
          ? a.name.compareTo(b.name)
          : a.level.compareTo(b.level));
  }

  Future<void> clearSpellCache(String classIndex) async {
    await _cacheBox.delete('spells_${classIndex}_v5');
    await _cacheBox.delete('spells_all_detailed_v5');
  }

  Future<List<MonsterSummaryDto>> getMonsters({String query = ''}) async {
    const cacheKey = 'monsters_index';
    try {
      final res = await _dio.get(
        '$_base/monsters',
        queryParameters: query.trim().isEmpty ? null : {'name': query.trim()},
      );
      final list = (res.data['results'] as List<dynamic>)
          .map(
            (e) => MonsterSummaryDto.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
      if (query.trim().isEmpty) {
        await _cacheBox.put(
          cacheKey,
          jsonEncode(
            list
                .map((e) => {'index': e.index, 'name': e.name, 'url': e.url})
                .toList(),
          ),
        );
      }
      return list;
    } catch (_) {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        final list = (jsonDecode(cached) as List<dynamic>)
            .map(
              (e) => MonsterSummaryDto.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
        if (query.trim().isEmpty) return list;
        return list
            .where((m) => m.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      rethrow;
    }
  }

  Future<MonsterDetailDto> getMonsterDetail(String monsterIndex) async {
    final cacheKey = 'monster_detail_$monsterIndex';
    try {
      final res = await _dio.get('$_base/monsters/$monsterIndex');
      final dto =
          MonsterDetailDto.fromJson(Map<String, dynamic>.from(res.data as Map));
      await _cacheBox.put(cacheKey, jsonEncode(dto.toJson()));
      return dto;
    } catch (_) {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        return MonsterDetailDto.fromJson(
          Map<String, dynamic>.from(jsonDecode(cached) as Map),
        );
      }
      rethrow;
    }
  }

  Future<List<Map<String, String>>> getSkills() async {
    final res = await _dio.get('$_base/skills');
    return (res.data['results'] as List<dynamic>)
        .map(
          (e) => {
            'index': (e['index'] ?? '').toString(),
            'name': (e['name'] ?? '').toString(),
          },
        )
        .toList();
  }

  Future<List<ClassLevelFeatures>> getClassFeatureProgression(
    String classIndex,
    int maxLevel,
  ) async {
    final normalized = classIndex.trim().toLowerCase();
    if (_core2024Classes.contains(normalized)) {
      return _fallbackFeatureService.getFeatureProgressionUpToLevel(
        normalized,
        maxLevel,
      );
    }

    try {
      final levelsRes =
          await _dio.get('$_baseNoVersion/api/classes/$classIndex/levels');
      final list = (levelsRes.data as List<dynamic>);
      final result = <ClassLevelFeatures>[];
      for (final raw in list) {
        final level = _extractLevel(raw);
        if (level <= 0 || level > maxLevel) continue;
        final features = await _mapFeatureRefs(
          raw['features'] as List<dynamic>? ?? const [],
          level,
        );
        if (features.isNotEmpty) {
          result.add(ClassLevelFeatures(level: level, features: features));
        }
      }
      result.sort((a, b) => a.level.compareTo(b.level));
      return result;
    } catch (_) {
      return _fallbackFeatureService.getFeatureProgressionUpToLevel(
        classIndex,
        maxLevel,
      );
    }
  }

  Future<List<ClassLevelFeatures>> getSubclassFeatureProgression(
    String subclassIndex,
    int maxLevel,
  ) async {
    final local = _getLocalSubclassProgression(subclassIndex, maxLevel);
    if (local.isNotEmpty) return local;

    try {
      final levelsRes = await _dio
          .get('$_baseNoVersion/api/subclasses/$subclassIndex/levels');
      final list = (levelsRes.data as List<dynamic>);
      final result = <ClassLevelFeatures>[];
      for (final raw in list) {
        final level = _extractLevel(raw);
        if (level <= 0 || level > maxLevel) continue;
        final features = await _mapFeatureRefs(
          raw['features'] as List<dynamic>? ?? const [],
          level,
          source: 'subclass',
        );
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

  Future<List<ClassFeatureModel>> _mapFeatureRefs(
    List<dynamic> refs,
    int level, {
    String source = 'class',
  }) async {
    final result = <ClassFeatureModel>[];
    for (final ref in refs) {
      final item = ref as Map<String, dynamic>;
      final index = (item['index'] ?? '').toString();
      final name = (item['name'] ?? '').toString();
      final detail =
          await _getFeatureDetail(index, name, level, source: source);
      result.add(detail);
    }
    return result;
  }

  Future<ClassFeatureModel> _getFeatureDetail(
    String index,
    String fallbackName,
    int level, {
    String source = 'class',
  }) async {
    try {
      final res = await _dio.get('$_baseNoVersion/api/features/$index');
      final data = res.data as Map<String, dynamic>;
      final name = (data['name'] ?? fallbackName).toString();
      final descList = (data['desc'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList();
      final description = descList.join('\n\n').trim();
      return _fallbackFeatureService.buildFeature(
        name: name,
        level: level,
        description: description.isNotEmpty ? description : null,
        source: source,
      );
    } catch (_) {
      return _fallbackFeatureService.buildFeature(
        name: fallbackName,
        level: level,
        source: source,
      );
    }
  }

  int _extractLevel(dynamic raw) {
    if (raw is! Map<String, dynamic>) return 0;
    final value = raw['level'] ?? raw['class_level'] ?? raw['subclass_level'];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  List<ClassLevelFeatures> _getLocalSubclassProgression(
    String subclassIndex,
    int maxLevel,
  ) {
    final normalizedSubclass = subclassIndex.trim().toLowerCase();
    final raw = kLocal2024SubclassFeatures[normalizedSubclass];
    if (raw == null || raw.isEmpty) return const [];

    final grantedMap = kSubclassGrantedSpells2024[normalizedSubclass];
    final levels = raw.keys.map(int.parse).toList()..sort();
    return levels
        .where((level) => level <= maxLevel)
        .map(
          (level) => ClassLevelFeatures(
            level: level,
            features:
                (raw['$level'] ?? const <Map<String, String>>[]).map((item) {
              final name = item['name'] ?? 'Subclass Feature';
              final description = _resolveLocalSubclassDescription(
                normalizedSubclass: normalizedSubclass,
                featureName: name,
                baseDescription: item['description'] ?? '',
                grantedMap: grantedMap,
              );
              return _fallbackFeatureService.buildFeature(
                name: name,
                level: level,
                description: description,
                source: 'subclass',
              );
            }).toList(),
          ),
        )
        .where((entry) => entry.features.isNotEmpty)
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

  Future<List<SpellDto>> _getLocalSpellAdditions() {
    return _localSpellAdditionsFuture ??= _loadLocalSpellAdditions();
  }

  Future<List<SpellDto>> _loadLocalSpellAdditions() async {
    try {
      final raw = await _loadLocalList('assets/data/2024/spells.json');
      return raw.map(SpellDto.fromJson).toList();
    } catch (_) {
      return const [];
    }
  }

  List<SpellDto> _decodeSpellList(String cached) {
    final list = jsonDecode(cached) as List<dynamic>;
    return list
        .map((e) => SpellDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
