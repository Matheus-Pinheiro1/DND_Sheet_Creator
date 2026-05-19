import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/hive_constants.dart';
import '../models/encounter_model.dart';

class EncounterRepositoryState {
  final List<EncounterModel> encounters;
  final String activeEncounterId;

  const EncounterRepositoryState({
    required this.encounters,
    required this.activeEncounterId,
  });

  EncounterModel get activeEncounter {
    for (final encounter in encounters) {
      if (encounter.id == activeEncounterId) return encounter;
    }
    return encounters.isEmpty
        ? EncounterModel.newEncounter(name: 'Encounter 1')
        : encounters.first;
  }
}

class EncounterRepository {
  static const _legacyActiveKey = 'active';
  static const _collectionKey = 'encounters_v2';
  static const _uuid = Uuid();

  Box<String> get _box => Hive.box<String>(HiveConstants.encounterBox);

  EncounterModel load() {
    return loadAll().activeEncounter;
  }

  EncounterRepositoryState loadAll() {
    final collection = _loadCollection();
    if (collection != null) return collection;

    final legacy = _loadLegacyEncounter();
    final encounter = legacy.isEmpty
        ? EncounterModel.newEncounter(name: 'Encounter 1')
        : _withIdentity(legacy, fallbackName: 'Encounter 1');
    return EncounterRepositoryState(
      encounters: [encounter],
      activeEncounterId: encounter.id,
    );
  }

  Future<void> save(EncounterModel encounter) async {
    await saveAll(
        [_withIdentity(encounter, fallbackName: 'Encounter 1')], encounter.id);
  }

  Future<void> saveAll(
    List<EncounterModel> encounters,
    String activeEncounterId,
  ) async {
    final normalized = _normalize(encounters);
    final activeId = normalized.any((e) => e.id == activeEncounterId)
        ? activeEncounterId
        : normalized.first.id;
    await _box.put(
      _collectionKey,
      jsonEncode({
        'activeEncounterId': activeId,
        'encounters': normalized.map((e) => e.toJson()).toList(),
      }),
    );
  }

  Future<void> clear() async {
    await _box.delete(_legacyActiveKey);
    await _box.delete(_collectionKey);
  }

  EncounterRepositoryState? _loadCollection() {
    final raw = _box.get(_collectionKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final list = json['encounters'];
      if (list is! List) return null;

      final encounters = _normalize(
        list
            .whereType<Map>()
            .map(
              (entry) => EncounterModel.fromJson(
                Map<String, dynamic>.from(entry),
              ),
            )
            .toList(),
      );
      final activeId = json['activeEncounterId']?.toString() ?? '';
      return EncounterRepositoryState(
        encounters: encounters,
        activeEncounterId: encounters.any((e) => e.id == activeId)
            ? activeId
            : encounters.first.id,
      );
    } catch (_) {
      return null;
    }
  }

  EncounterModel _loadLegacyEncounter() {
    final raw = _box.get(_legacyActiveKey);
    if (raw == null || raw.isEmpty) return EncounterModel.empty;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return EncounterModel.fromJson(json);
    } catch (_) {
      return EncounterModel.empty;
    }
  }

  List<EncounterModel> _normalize(List<EncounterModel> encounters) {
    if (encounters.isEmpty) {
      return [EncounterModel.newEncounter(name: 'Encounter 1')];
    }

    return [
      for (var i = 0; i < encounters.length; i++)
        _withIdentity(encounters[i], fallbackName: 'Encounter ${i + 1}'),
    ];
  }

  EncounterModel _withIdentity(
    EncounterModel encounter, {
    required String fallbackName,
  }) {
    final id = encounter.id.trim().isEmpty ? _uuid.v4() : encounter.id;
    final name = encounter.name.trim().isEmpty ? fallbackName : encounter.name;
    return encounter.copyWith(id: id, name: name);
  }
}
