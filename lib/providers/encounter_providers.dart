import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/encounter_model.dart';
import '../data/models/encounter_participant.dart';
import '../data/repositories/encounter_repository.dart';

final encounterRepositoryProvider = Provider<EncounterRepository>(
  (_) => EncounterRepository(),
);

final encounterProvider =
    StateNotifierProvider<EncounterNotifier, EncounterModel>(
  (ref) => EncounterNotifier(ref.read(encounterRepositoryProvider)),
);

class EncounterNotifier extends StateNotifier<EncounterModel> {
  final EncounterRepository _repo;
  late List<EncounterModel> _encounters;
  late String _activeEncounterId;
  final Map<int, Map<String, _RoundResourceState>> _roundResourceSnapshots = {};
  final _saveErrorController = StreamController<Object>.broadcast();
  Timer? _saveDebounce;
  static const _saveDebounceDuration = Duration(milliseconds: 600);

  EncounterNotifier(this._repo) : super(_repo.loadAll().activeEncounter) {
    final loaded = _repo.loadAll();
    _encounters = loaded.encounters;
    _activeEncounterId = loaded.activeEncounterId;
    state = loaded.activeEncounter;
  }

  List<EncounterModel> get encounters => List.unmodifiable(_encounters);
  String get activeEncounterId => _activeEncounterId;
  bool get hasMultipleEncounters => _encounters.length > 1;
  Stream<Object> get saveErrors => _saveErrorController.stream;
  List<SavedPlayerCharacter> get savedPlayerCharacters {
    final playersByName = <String, SavedPlayerCharacter>{};

    for (final encounter in _encounters) {
      for (final participant in encounter.participants) {
        if (!participant.isPlayer) continue;
        final name = participant.name.trim();
        if (name.isEmpty) continue;

        playersByName[name.toLowerCase()] = SavedPlayerCharacter(
          name: name,
          initiative: participant.initiative,
        );
      }
    }

    return List.unmodifiable(playersByName.values);
  }

  void createEncounter({String? name}) {
    final encounter = EncounterModel.newEncounter(name: _encounterName(name));
    _encounters = [..._encounters, encounter];
    _activeEncounterId = encounter.id;
    _persistActive();
  }

  void selectEncounter(String id) {
    if (!_encounters.any((encounter) => encounter.id == id)) return;
    _activeEncounterId = id;
    _persistActive();
  }

  void renameEncounter(String id, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _encounters = _encounters
        .map(
          (encounter) => encounter.id == id
              ? encounter.copyWith(name: trimmed)
              : encounter,
        )
        .toList();
    _persistActive();
  }

  void setEncounterColor(String id, int colorTag) {
    _encounters = _encounters
        .map(
          (encounter) => encounter.id == id
              ? encounter.copyWith(colorTag: colorTag)
              : encounter,
        )
        .toList();
    _persistActive();
  }

  void deleteEncounter(String id) {
    if (_encounters.length <= 1) {
      final replacement = EncounterModel.newEncounter(name: 'Encounter 1');
      _encounters = [replacement];
      _activeEncounterId = replacement.id;
      _persistActive();
      return;
    }

    final removedIndex =
        _encounters.indexWhere((encounter) => encounter.id == id);
    if (removedIndex < 0) return;
    _encounters = _encounters.where((encounter) => encounter.id != id).toList();

    if (_activeEncounterId == id) {
      final nextIndex = removedIndex.clamp(0, _encounters.length - 1).toInt();
      _activeEncounterId = _encounters[nextIndex].id;
    }

    _persistActive();
  }

  void addParticipant(EncounterParticipant participant) {
    final currentParticipantId = state.currentParticipant?.id;
    final baseName = participant.originalName.trim().isNotEmpty
        ? participant.originalName.trim()
        : participant.name.trim();
    final normalizedBaseName = baseName.isEmpty ? 'Participant' : baseName;
    final existingNames = state.participants
        .map((p) => p.name.trim())
        .where((name) => name.isNotEmpty)
        .toSet();
    final name =
        _nextAvailableParticipantName(normalizedBaseName, existingNames);

    _updatePreservingParticipant(
      state.copyWith(
        participants: [
          ...state.participants,
          participant.copyWith(
            name: name,
            originalName: participant.isPlayer ? '' : normalizedBaseName,
          ),
        ],
      ),
      currentParticipantId,
    );
  }

  void addPlayerCharacter(EncounterParticipant player) {
    addParticipant(player);
  }

  void addParticipantToEncounter(
      String encounterId, EncounterParticipant participant) {
    if (encounterId == _activeEncounterId) {
      addParticipant(participant);
      return;
    }

    final targetIndex = _encounters.indexWhere((e) => e.id == encounterId);
    if (targetIndex < 0) return;

    final targetEncounter = _encounters[targetIndex];

    final baseName = participant.originalName.trim().isNotEmpty
        ? participant.originalName.trim()
        : participant.name.trim();
    final normalizedBaseName = baseName.isEmpty ? 'Participant' : baseName;

    final existingNames = targetEncounter.participants
        .map((p) => p.name.trim())
        .where((name) => name.isNotEmpty)
        .toSet();
    final name =
        _nextAvailableParticipantName(normalizedBaseName, existingNames);

    final newParticipant = participant.copyWith(
      name: name,
      originalName: participant.isPlayer ? '' : normalizedBaseName,
    );

    final updatedEncounter = targetEncounter.copyWith(
      participants: [...targetEncounter.participants, newParticipant],
    );

    _encounters = _encounters
        .map((e) => e.id == encounterId ? updatedEncounter : e)
        .toList();
    _saveAll();
  }

  void removeParticipant(String id) {
    final currentParticipantId = state.currentParticipant?.id;
    final newParticipants =
        state.participants.where((p) => p.id != id).toList();

    _updatePreservingParticipant(
      state.copyWith(participants: newParticipants),
      currentParticipantId == id ? null : currentParticipantId,
    );
  }

  void updateParticipant(EncounterParticipant updated) {
    final currentParticipantId = state.currentParticipant?.id;
    _updatePreservingParticipant(
      state.copyWith(
        participants: state.participants
            .map((p) => p.id == updated.id ? updated : p)
            .toList(),
      ),
      currentParticipantId,
    );
  }

  void applyDamage(String id, int amount) {
    if (amount <= 0) return;
    _mutate(id, (p) {
      final absorbedByTemporaryHp = amount.clamp(0, p.temporaryHp).toInt();
      final remainingDamage = amount - absorbedByTemporaryHp;
      final newTemporaryHp = p.temporaryHp - absorbedByTemporaryHp;
      final newHp = (p.currentHp - remainingDamage).clamp(0, p.maxHp).toInt();
      return p.copyWith(
        currentHp: newHp,
        temporaryHp: newTemporaryHp,
      );
    });
  }

  void applyHealing(String id, int amount) {
    if (amount <= 0) return;
    _mutate(id, (p) {
      final newHp = (p.currentHp + amount).clamp(0, p.maxHp);
      return p.copyWith(currentHp: newHp);
    });
  }

  void setHp(String id, int hp) {
    _mutate(
      id,
      (p) => p.copyWith(currentHp: hp > p.maxHp ? p.maxHp : hp),
    );
  }

  void setMaxHp(String id, int maxHp) {
    if (maxHp <= 0) return;
    _mutate(
        id,
        (p) => p.copyWith(
              maxHp: maxHp,
              currentHp: p.currentHp.clamp(0, maxHp),
            ));
  }

  void setTemporaryHp(String id, int temporaryHp) {
    _mutate(
      id,
      (p) => p.copyWith(temporaryHp: temporaryHp.clamp(0, 999).toInt()),
    );
  }

  void setInitiative(String id, int initiative) {
    _mutate(id, (p) => p.copyWith(initiative: initiative));
  }

  void setAc(String id, int ac) {
    if (ac <= 0) return;
    _mutate(id, (p) => p.copyWith(armorClass: ac));
  }

  void setParticipantName(String id, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _mutate(id, (p) {
      final originalName =
          _shouldPreserveGeneratedName(p) ? p.name.trim() : p.originalName;
      return p.copyWith(name: trimmed, originalName: originalName);
    });
  }

  void setColorTag(String id, int colorTag) {
    _mutate(id, (p) => p.copyWith(colorTag: colorTag));
  }

  void toggleCondition(String id, String condition) {
    _mutate(id, (p) {
      final conds = List<String>.from(p.conditions);
      if (conds.contains(condition)) {
        conds.remove(condition);
      } else {
        conds.add(condition);
      }
      return p.copyWith(conditions: conds);
    });
  }

  void clearConditions(String id) {
    _mutate(id, (p) => p.copyWith(conditions: []));
  }

  void setExhaustionLevel(String id, int level) {
    _mutate(
      id,
      (p) => p.copyWith(exhaustionLevel: level.clamp(0, 6).toInt()),
    );
  }

  void incrementExhaustion(String id) {
    _mutate(
      id,
      (p) => p.copyWith(
        exhaustionLevel: (p.exhaustionLevel + 1).clamp(0, 6).toInt(),
      ),
    );
  }

  void decrementExhaustion(String id) {
    _mutate(
      id,
      (p) => p.copyWith(
        exhaustionLevel: (p.exhaustionLevel - 1).clamp(0, 6).toInt(),
      ),
    );
  }

  void useLegendaryAction(String id) {
    _mutate(id, (p) {
      if (p.legendaryActionsRemaining <= 0) return p;
      return p.copyWith(legendaryActionsUsed: p.legendaryActionsUsed + 1);
    });
  }

  void resetLegendaryActions(String id) {
    _mutate(id, (p) => p.copyWith(legendaryActionsUsed: 0));
  }

  void setLegendaryActionsMax(String id, int max) {
    if (max < 0) return;
    _mutate(id, (p) {
      final used = max == p.legendaryActionsMax
          ? p.legendaryActionsUsed.clamp(0, max).toInt()
          : 0;
      return p.copyWith(
        legendaryActionsMax: max,
        legendaryActionsUsed: used,
      );
    });
  }

  void useLegendaryResistance(String id) {
    _mutate(id, (p) {
      if (p.legendaryResistancesRemaining <= 0) return p;
      return p.copyWith(
          legendaryResistancesUsed: p.legendaryResistancesUsed + 1);
    });
  }

  void resetLegendaryResistances(String id) {
    _mutate(id, (p) => p.copyWith(legendaryResistancesUsed: 0));
  }

  void setLegendaryResistancesMax(String id, int max) {
    if (max < 0) return;
    _mutate(id, (p) {
      final used = max == p.legendaryResistancesMax
          ? p.legendaryResistancesUsed.clamp(0, max).toInt()
          : 0;
      return p.copyWith(
        legendaryResistancesMax: max,
        legendaryResistancesUsed: used,
      );
    });
  }

  void useReaction(String id) {
    _mutate(id, (p) => p.copyWith(reactionUsed: true));
  }

  void resetReaction(String id) {
    _mutate(id, (p) => p.copyWith(reactionUsed: false));
  }

  void toggleConcentration(String id) {
    _mutate(id, (p) => p.copyWith(concentrating: !p.concentrating));
  }

  void setNotes(String id, String notes) {
    _mutate(id, (p) => p.copyWith(notes: notes));
  }

  void nextTurn() {
    final turnOrder = state.turnParticipants;
    if (turnOrder.isEmpty) {
      if (state.currentTurnIndex >= 0) {
        _update(state.copyWith(currentTurnIndex: -1));
      }
      return;
    }

    final count = turnOrder.length;
    var nextIdx = state.currentTurnIndex + 1;
    var nextRound = state.currentRound;

    if (nextIdx >= count) {
      nextIdx = 0;
      nextRound++;
      _roundResourceSnapshots.clear();
      _roundResourceSnapshots[nextRound] = {
        for (final participant in state.participants)
          participant.id: _RoundResourceState(
            legendaryActionsUsed: participant.legendaryActionsUsed,
            reactionUsed: participant.reactionUsed,
          ),
      };
      final updated = state.participants
          .map((p) => p.copyWith(
                reactionUsed: false,
                legendaryActionsUsed: 0,
              ))
          .toList();
      _update(state.copyWith(
        participants: updated,
        currentTurnIndex: nextIdx,
        currentRound: nextRound,
      ));
      return;
    }

    _update(state.copyWith(
      currentTurnIndex: nextIdx,
      currentRound: nextRound,
    ));
  }

  void previousTurn() {
    if (state.isEmpty) return;
    final count = state.turnParticipants.length;
    if (count == 0) {
      if (state.currentTurnIndex >= 0) {
        _update(state.copyWith(currentTurnIndex: -1));
      }
      return;
    }

    var prevIdx = state.currentTurnIndex - 1;
    var prevRound = state.currentRound;
    var crossedRoundBoundary = false;

    if (prevIdx < 0) {
      if (prevRound <= 1) return;
      prevIdx = count - 1;
      prevRound--;
      crossedRoundBoundary = true;
    }

    final snapshot = crossedRoundBoundary
        ? _roundResourceSnapshots.remove(state.currentRound)
        : null;
    final participants = snapshot == null
        ? state.participants
        : state.participants.map((participant) {
            final saved = snapshot[participant.id];
            if (saved == null) return participant;
            return participant.copyWith(
              legendaryActionsUsed: saved.legendaryActionsUsed,
              reactionUsed: saved.reactionUsed,
            );
          }).toList();

    _update(state.copyWith(
      participants: participants,
      currentTurnIndex: prevIdx,
      currentRound: prevRound,
    ));
  }

  void jumpToParticipant(String id) {
    final turnOrder = state.turnParticipants;
    final idx = turnOrder.indexWhere((p) => p.id == id);
    if (idx < 0) return;
    _update(state.copyWith(currentTurnIndex: idx));
  }

  void resetEncounter() {
    _roundResourceSnapshots.clear();
    _update(
      state.copyWith(
        participants: const [],
        currentTurnIndex: 0,
        currentRound: 1,
      ),
    );
  }

  void resetAllHp() {
    _update(state.copyWith(
      participants: state.participants
          .map((p) => p.copyWith(currentHp: p.maxHp, temporaryHp: 0))
          .toList(),
    ));
  }

  void _mutate(
      String id, EncounterParticipant Function(EncounterParticipant) fn) {
    final currentParticipantId = state.currentParticipant?.id;
    _updatePreservingParticipant(
      state.copyWith(
        participants:
            state.participants.map((p) => p.id == id ? fn(p) : p).toList(),
      ),
      currentParticipantId,
    );
  }

  void _updatePreservingParticipant(
    EncounterModel newState,
    String? participantId,
  ) {
    if (participantId == null || newState.participants.isEmpty) {
      _update(newState.copyWith(
        currentTurnIndex: _normalizedTurnIndex(newState),
      ));
      return;
    }

    final turnOrder = newState.turnParticipants;
    final index = turnOrder.indexWhere((p) => p.id == participantId);
    _update(newState.copyWith(
      currentTurnIndex: index < 0 ? _normalizedTurnIndex(newState) : index,
    ));
  }

  int _normalizedTurnIndex(EncounterModel encounter) {
    final turnOrder = encounter.turnParticipants;
    if (turnOrder.isEmpty) return -1;
    if (encounter.currentTurnIndex < 0) return -1;
    return encounter.currentTurnIndex.clamp(0, turnOrder.length - 1).toInt();
  }

  void _update(EncounterModel newState) {
    final updated = newState.id.trim().isEmpty
        ? newState.copyWith(id: _activeEncounterId)
        : newState;
    _activeEncounterId = updated.id;
    _encounters = _encounters
        .map((encounter) => encounter.id == updated.id ? updated : encounter)
        .toList();
    if (!_encounters.any((encounter) => encounter.id == updated.id)) {
      _encounters = [..._encounters, updated];
    }
    state = updated;
    _saveAll();
  }

  void _persistActive() {
    state = _activeEncounter().copyWith();
    _saveAll();
  }

  EncounterModel _activeEncounter() {
    for (final encounter in _encounters) {
      if (encounter.id == _activeEncounterId) return encounter;
    }
    return _encounters.isEmpty
        ? EncounterModel.newEncounter(name: 'Encounter 1')
        : _encounters.first;
  }

  String _encounterName(String? requested) {
    final trimmed = requested?.trim() ?? '';
    if (trimmed.isNotEmpty) return trimmed;

    var index = _encounters.length + 1;
    while (
        _encounters.any((encounter) => encounter.name == 'Encounter $index')) {
      index++;
    }
    return 'Encounter $index';
  }

  String _nextAvailableParticipantName(
    String baseName,
    Set<String> existingNames,
  ) {
    if (!existingNames.contains(baseName)) return baseName;

    var suffix = 2;
    while (existingNames.contains('$baseName #$suffix')) {
      suffix++;
    }
    return '$baseName #$suffix';
  }

  bool _shouldPreserveGeneratedName(EncounterParticipant participant) {
    if (participant.isPlayer) return false;
    final current = participant.name.trim();
    final original = participant.originalName.trim();
    if (current.isEmpty || original.isEmpty || current == original) {
      return false;
    }
    if (!current.startsWith(original)) return false;

    final suffix = current.substring(original.length).trim();
    if (!suffix.startsWith('#')) return false;
    return int.tryParse(suffix.substring(1).trim()) != null;
  }

  void _saveAll() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(_saveDebounceDuration, () {
      _repo
          .saveAll(_encounters, _activeEncounterId)
          .catchError((Object error, StackTrace stackTrace) {
        debugPrint('Failed to save encounter: $error');
        if (!_saveErrorController.isClosed) {
          _saveErrorController.add(error);
        }
      });
    });
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _repo.saveAll(_encounters, _activeEncounterId).ignore();
    _saveErrorController.close();
    super.dispose();
  }
}

class SavedPlayerCharacter {
  final String name;
  final int initiative;

  const SavedPlayerCharacter({
    required this.name,
    required this.initiative,
  });

  String get normalizedName => name.trim().toLowerCase();
}

class _RoundResourceState {
  final int legendaryActionsUsed;
  final bool reactionUsed;

  const _RoundResourceState({
    required this.legendaryActionsUsed,
    required this.reactionUsed,
  });
}
