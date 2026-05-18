import 'package:uuid/uuid.dart';

const kDndConditions = [
  'Blinded',
  'Charmed',
  'Deafened',
  'Frightened',
  'Grappled',
  'Incapacitated',
  'Invisible',
  'Paralyzed',
  'Petrified',
  'Poisoned',
  'Prone',
  'Restrained',
  'Stunned',
  'Unconscious',
];

class EncounterParticipant {
  final String id;
  final String monsterIndex;
  final String name;
  final String originalName;
  final String type;
  final String crLabel;
  final bool isPlayer;
  final int colorTag;

  final int maxHp;
  final int currentHp;
  final int temporaryHp;
  final int armorClass;
  final int initiative;

  final List<String> conditions;
  final int legendaryActionsMax;
  final int legendaryActionsUsed;
  final int legendaryResistancesMax;
  final int legendaryResistancesUsed;
  final bool reactionUsed;
  final bool concentrating;
  final int exhaustionLevel;
  final String notes;

  const EncounterParticipant({
    required this.id,
    required this.monsterIndex,
    required this.name,
    this.originalName = '',
    required this.type,
    required this.crLabel,
    required this.isPlayer,
    this.colorTag = 0,
    required this.maxHp,
    required this.currentHp,
    this.temporaryHp = 0,
    required this.armorClass,
    required this.initiative,
    this.conditions = const [],
    this.legendaryActionsMax = 0,
    this.legendaryActionsUsed = 0,
    this.legendaryResistancesMax = 0,
    this.legendaryResistancesUsed = 0,
    this.reactionUsed = false,
    this.concentrating = false,
    this.exhaustionLevel = 0,
    this.notes = '',
  });

  bool get isDefeated => currentHp <= 0;
  String get visibleOriginalName {
    if (isPlayer) return '';
    final original = originalName.trim();
    if (original.isEmpty || original == name.trim()) return '';
    return original;
  }

  int get legendaryActionsRemaining =>
      (legendaryActionsMax - legendaryActionsUsed)
          .clamp(0, legendaryActionsMax);
  int get legendaryResistancesRemaining =>
      (legendaryResistancesMax - legendaryResistancesUsed)
          .clamp(0, legendaryResistancesMax);
  double get hpPercent => maxHp > 0 ? (currentHp / maxHp).clamp(0.0, 1.0) : 0.0;

  factory EncounterParticipant.fromMonster({
    required String monsterIndex,
    required String name,
    required String type,
    required String crLabel,
    required int hp,
    required int ac,
    required int legendaryActionsCount,
    required int legendaryResistancesCount,
    String? customName,
  }) {
    return EncounterParticipant(
      id: const Uuid().v4(),
      monsterIndex: monsterIndex,
      name: customName ?? name,
      originalName: name,
      type: type,
      crLabel: crLabel,
      isPlayer: false,
      maxHp: hp,
      currentHp: hp,
      armorClass: ac,
      initiative: 0,
      legendaryActionsMax: legendaryActionsCount,
      legendaryResistancesMax: legendaryResistancesCount,
    );
  }
  factory EncounterParticipant.player({
    required String name,
    required int maxHp,
    required int ac,
  }) {
    return EncounterParticipant(
      id: const Uuid().v4(),
      monsterIndex: '',
      name: name,
      originalName: '',
      type: 'Player Character',
      crLabel: '-',
      isPlayer: true,
      maxHp: maxHp,
      currentHp: maxHp,
      armorClass: ac,
      initiative: 0,
    );
  }

  EncounterParticipant copyWith({
    int? currentHp,
    int? temporaryHp,
    int? maxHp,
    int? armorClass,
    int? initiative,
    List<String>? conditions,
    int? legendaryActionsUsed,
    int? legendaryActionsMax,
    int? legendaryResistancesUsed,
    int? legendaryResistancesMax,
    bool? reactionUsed,
    bool? concentrating,
    int? exhaustionLevel,
    String? notes,
    String? name,
    String? originalName,
    int? colorTag,
  }) {
    return EncounterParticipant(
      id: id,
      monsterIndex: monsterIndex,
      name: name ?? this.name,
      originalName: originalName ?? this.originalName,
      type: type,
      crLabel: crLabel,
      isPlayer: isPlayer,
      colorTag: colorTag ?? this.colorTag,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      temporaryHp: temporaryHp ?? this.temporaryHp,
      armorClass: armorClass ?? this.armorClass,
      initiative: initiative ?? this.initiative,
      conditions: conditions ?? this.conditions,
      legendaryActionsMax: legendaryActionsMax ?? this.legendaryActionsMax,
      legendaryActionsUsed: legendaryActionsUsed ?? this.legendaryActionsUsed,
      legendaryResistancesMax:
          legendaryResistancesMax ?? this.legendaryResistancesMax,
      legendaryResistancesUsed:
          legendaryResistancesUsed ?? this.legendaryResistancesUsed,
      reactionUsed: reactionUsed ?? this.reactionUsed,
      concentrating: concentrating ?? this.concentrating,
      exhaustionLevel: exhaustionLevel ?? this.exhaustionLevel,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'monsterIndex': monsterIndex,
        'name': name,
        'originalName': originalName,
        'type': type,
        'crLabel': crLabel,
        'isPlayer': isPlayer,
        'colorTag': colorTag,
        'maxHp': maxHp,
        'currentHp': currentHp,
        'temporaryHp': temporaryHp,
        'armorClass': armorClass,
        'initiative': initiative,
        'conditions': conditions,
        'legendaryActionsMax': legendaryActionsMax,
        'legendaryActionsUsed': legendaryActionsUsed,
        'legendaryResistancesMax': legendaryResistancesMax,
        'legendaryResistancesUsed': legendaryResistancesUsed,
        'reactionUsed': reactionUsed,
        'concentrating': concentrating,
        'exhaustionLevel': exhaustionLevel,
        'notes': notes,
      };

  factory EncounterParticipant.fromJson(Map<String, dynamic> json) {
    final id = _string(json['id']);
    final name = _string(json['name']);
    final monsterIndex = _string(json['monsterIndex']);
    final originalName = _string(json['originalName']);
    final maxHp = _int(json['maxHp'], fallback: 1);
    final conditions = List<String>.from(_stringList(json['conditions']));
    final legacyExhaustion = conditions.contains('Exhaustion');
    final exhaustionLevel = _int(
      json['exhaustionLevel'],
      fallback: legacyExhaustion ? 1 : 0,
    ).clamp(0, 6).toInt();
    conditions.remove('Exhaustion');

    return EncounterParticipant(
      id: id.isEmpty ? const Uuid().v4() : id,
      monsterIndex: monsterIndex,
      name: name.isEmpty ? 'Unnamed' : name,
      originalName: originalName.isEmpty && monsterIndex.isNotEmpty
          ? (name.isEmpty ? 'Unnamed' : name)
          : originalName,
      type: _string(json['type']),
      crLabel:
          _string(json['crLabel']).isEmpty ? '-' : _string(json['crLabel']),
      isPlayer: _bool(json['isPlayer']),
      colorTag: _int(json['colorTag']),
      maxHp: maxHp,
      currentHp: _int(json['currentHp'], fallback: maxHp),
      temporaryHp: _int(json['temporaryHp'] ?? json['tempHp']),
      armorClass: _int(json['armorClass'], fallback: 10),
      initiative: _int(json['initiative']),
      conditions: conditions,
      legendaryActionsMax: _int(json['legendaryActionsMax']),
      legendaryActionsUsed: _int(json['legendaryActionsUsed']),
      legendaryResistancesMax: _int(json['legendaryResistancesMax']),
      legendaryResistancesUsed: _int(json['legendaryResistancesUsed']),
      reactionUsed: _bool(json['reactionUsed']),
      concentrating: _bool(json['concentrating']),
      exhaustionLevel: exhaustionLevel,
      notes: _string(json['notes']),
    );
  }

  static String _string(dynamic value) => value?.toString() ?? '';

  static int _int(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool _bool(dynamic value) {
    if (value is bool) return value;
    return value?.toString().toLowerCase() == 'true';
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((entry) => entry.toString()).toList();
  }
}
