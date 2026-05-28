import 'package:uuid/uuid.dart';

import 'encounter_participant.dart';

class EncounterModel {
  final String id;
  final String name;
  final List<EncounterParticipant> participants;
  final int currentTurnIndex;
  final int currentRound;
  final int colorTag;

  const EncounterModel({
    this.id = '',
    this.name = 'Encounter',
    this.participants = const [],
    this.currentTurnIndex = -1,
    this.currentRound = 1,
    this.colorTag = 0,
  });

  bool get isEmpty => participants.isEmpty;
  bool get isStarted => turnParticipants.isNotEmpty && currentTurnIndex >= 0;

  List<EncounterParticipant> get sortedParticipants {
    final list = [
      for (var i = 0; i < participants.length; i++)
        _IndexedParticipant(participants[i], i),
    ];
    list.sort((a, b) {
      final defeatedCmp = a.participant.isDefeated == b.participant.isDefeated
          ? 0
          : a.participant.isDefeated
              ? 1
              : -1;
      if (defeatedCmp != 0) return defeatedCmp;

      if (a.participant.isDefeated && b.participant.isDefeated) {
        return a.index.compareTo(b.index);
      }

      final cmp = b.participant.initiative.compareTo(a.participant.initiative);
      if (cmp != 0) return cmp;
      final acCmp =
          b.participant.armorClass.compareTo(a.participant.armorClass);
      if (acCmp != 0) return acCmp;
      return a.index.compareTo(b.index);
    });
    return list.map((entry) => entry.participant).toList(growable: false);
  }

  List<EncounterParticipant> get turnParticipants => sortedParticipants
      .where((participant) => !participant.isDefeated)
      .toList(growable: false);

  EncounterParticipant? get currentParticipant {
    final turnOrder = turnParticipants;
    if (turnOrder.isEmpty || currentTurnIndex < 0) return null;
    final idx = currentTurnIndex.clamp(0, turnOrder.length - 1);
    return turnOrder[idx];
  }

  EncounterModel copyWith({
    String? id,
    String? name,
    List<EncounterParticipant>? participants,
    int? currentTurnIndex,
    int? currentRound,
    int? colorTag,
  }) {
    return EncounterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      participants: participants ?? this.participants,
      currentTurnIndex: currentTurnIndex ?? this.currentTurnIndex,
      currentRound: currentRound ?? this.currentRound,
      colorTag: colorTag ?? this.colorTag,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'participants': participants.map((p) => p.toJson()).toList(),
        'currentTurnIndex': currentTurnIndex,
        'currentRound': currentRound,
        'colorTag': colorTag,
      };

  factory EncounterModel.fromJson(Map<String, dynamic> json) => EncounterModel(
        id: _string(json['id']),
        name: _string(json['name'], fallback: 'Encounter'),
        participants: _participants(json['participants']),
        currentTurnIndex: _int(json['currentTurnIndex'], fallback: -1),
        currentRound: _int(json['currentRound'], fallback: 1),
        colorTag: _int(json['colorTag']),
      );

  static EncounterModel get empty => const EncounterModel();

  factory EncounterModel.newEncounter({required String name}) {
    return EncounterModel(
      id: const Uuid().v4(),
      name: name,
    );
  }

  static List<EncounterParticipant> _participants(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (entry) => EncounterParticipant.fromJson(
            Map<String, dynamic>.from(entry),
          ),
        )
        .toList();
  }

  static int _int(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }
}

class _IndexedParticipant {
  final EncounterParticipant participant;
  final int index;

  const _IndexedParticipant(this.participant, this.index);
}
