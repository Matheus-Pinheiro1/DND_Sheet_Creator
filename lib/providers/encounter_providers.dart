// lib/providers/encounter_providers.dart

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

  EncounterNotifier(this._repo) : super(_repo.loadAll().activeEncounter) {
    final loaded = _repo.loadAll();
    _encounters = loaded.encounters;
    _activeEncounterId = loaded.activeEncounterId;
    state = loaded.activeEncounter;
  }

  // ── Participants ─────────────────────────────────────────────────────────

  List<EncounterModel> get encounters => List.unmodifiable(_encounters);
  String get activeEncounterId => _activeEncounterId;
  bool get hasMultipleEncounters => _encounters.length > 1;

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
    // Auto-number duplicates: "Goblin", "Goblin #2", "Goblin #3"
    final baseName = participant.originalName.trim().isNotEmpty
        ? participant.originalName.trim()
        : participant.name.trim();
    final sameBase = state.participants
        .where(
          (p) =>
              p.name == baseName ||
              p.name.startsWith('$baseName #') ||
              p.originalName == baseName ||
              p.originalName.startsWith('$baseName #'),
        )
        .length;
    final name = sameBase == 0 ? baseName : '$baseName #${sameBase + 1}';

    _updatePreservingParticipant(
      state.copyWith(
        participants: [
          ...state.participants,
          participant.copyWith(
            name: name,
            originalName: participant.isPlayer ? '' : name,
          ),
        ],
      ),
      currentParticipantId,
    );
  }

  void addPlayerCharacter(EncounterParticipant player) {
    addParticipant(player);
  }

  void removeParticipant(String id) {
    final currentParticipantId = state.currentParticipant?.id;
    final newParticipants =
        state.participants.where((p) => p.id != id).toList();

    var newIdx = state.currentTurnIndex;
    if (newParticipants.isEmpty) {
      newIdx = 0;
    } else if (currentParticipantId != null && currentParticipantId != id) {
      final sorted =
          state.copyWith(participants: newParticipants).sortedParticipants;
      final preservedIdx = sorted
          .indexWhere((participant) => participant.id == currentParticipantId);
      newIdx = preservedIdx < 0 ? 0 : preservedIdx;
    } else {
      newIdx = newIdx.clamp(0, newParticipants.length - 1).toInt();
    }

    _update(state.copyWith(
      participants: newParticipants,
      currentTurnIndex: newIdx,
    ));
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

  // ── HP ───────────────────────────────────────────────────────────────────

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
    _mutate(id, (p) => p.copyWith(currentHp: hp.clamp(0, p.maxHp)));
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

  // ── Initiative ───────────────────────────────────────────────────────────

  void setInitiative(String id, int initiative) {
    _mutate(id, (p) => p.copyWith(initiative: initiative));
  }

  void setAc(String id, int ac) {
    _mutate(id, (p) => p.copyWith(armorClass: ac));
  }

  void setParticipantName(String id, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _mutate(id, (p) => p.copyWith(name: trimmed));
  }

  void setColorTag(String id, int colorTag) {
    _mutate(id, (p) => p.copyWith(colorTag: colorTag));
  }

  // ── Conditions ───────────────────────────────────────────────────────────

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

  // ── Combat resources ─────────────────────────────────────────────────────

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
    _mutate(id,
        (p) => p.copyWith(legendaryActionsMax: max, legendaryActionsUsed: 0));
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
    _mutate(
        id,
        (p) => p.copyWith(
            legendaryResistancesMax: max, legendaryResistancesUsed: 0));
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

  // ── Turn management ──────────────────────────────────────────────────────

  void nextTurn() {
    final sorted = state.sortedParticipants;
    if (sorted.isEmpty) return;

    final count = sorted.length;
    var nextIdx = state.currentTurnIndex + 1;
    var nextRound = state.currentRound;

    // New round: reset reactions + legendary actions for all participants
    if (nextIdx >= count) {
      nextIdx = 0;
      nextRound++;
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
    final count = state.sortedParticipants.length;
    var prevIdx = state.currentTurnIndex - 1;
    var prevRound = state.currentRound;

    if (prevIdx < 0) {
      if (prevRound <= 1) return; // Can't go before round 1
      prevIdx = count - 1;
      prevRound--;
    }

    _update(state.copyWith(
      currentTurnIndex: prevIdx,
      currentRound: prevRound,
    ));
  }

  void jumpToParticipant(String id) {
    final sorted = state.sortedParticipants;
    final idx = sorted.indexWhere((p) => p.id == id);
    if (idx < 0) return;
    _update(state.copyWith(currentTurnIndex: idx));
  }

  // ── Encounter lifecycle ───────────────────────────────────────────────────

  void resetEncounter() {
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

  // ── Helpers ───────────────────────────────────────────────────────────────

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
      _update(newState);
      return;
    }

    final sorted = newState.sortedParticipants;
    final index = sorted.indexWhere((p) => p.id == participantId);
    _update(newState.copyWith(
      currentTurnIndex: index < 0 ? newState.currentTurnIndex : index,
    ));
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

  void _saveAll() {
    _repo
        .saveAll(_encounters, _activeEncounterId)
        .catchError((Object error, StackTrace stackTrace) {
      debugPrint('Failed to save encounter: $error');
    });
  }
}
