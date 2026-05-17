class OnlineCharacter {
  final String name;
  final String characterClass;
  final int level;
  final int passivePerception;
  final int passiveInvestigation;
  final int passiveInsight;

  const OnlineCharacter({
    required this.name,
    required this.characterClass,
    required this.level,
    this.passivePerception = 10,
    this.passiveInvestigation = 10,
    this.passiveInsight = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'characterClass': characterClass,
      'level': level,
      'passivePerception': passivePerception,
      'passiveInvestigation': passiveInvestigation,
      'passiveInsight': passiveInsight,
    };
  }

  factory OnlineCharacter.fromJson(Map<String, dynamic> json) {
    return OnlineCharacter(
      name: json['name'] as String,
      characterClass: json['characterClass'] as String,
      level: json['level'] as int,
      passivePerception: json['passivePerception'] as int? ?? 10,
      passiveInvestigation: json['passiveInvestigation'] as int? ?? 10,
      passiveInsight: json['passiveInsight'] as int? ?? 10,
    );
  }
}

class OnlinePlayer {
  final String id;
  final String name;
  final bool isMaster;
  final OnlineCharacter character;
  final List<String> encounters;
  final List<String> conditions;

  const OnlinePlayer({
    required this.id,
    required this.name,
    required this.isMaster,
    required this.character,
    this.encounters = const [],
    this.conditions = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isMaster': isMaster,
      'character': character.toJson(),
      'encounters': encounters,
      'conditions': conditions,
    };
  }

  factory OnlinePlayer.fromJson(Map<String, dynamic> json) {
    return OnlinePlayer(
      id: json['id'] as String,
      name: json['name'] as String,
      isMaster: json['isMaster'] as bool,
      character:
          OnlineCharacter.fromJson(json['character'] as Map<String, dynamic>),
      encounters: (json['encounters'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      conditions: (json['conditions'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList() ?? const [],
    );
  }

  OnlinePlayer copyWith({
    String? id,
    String? name,
    bool? isMaster,
    OnlineCharacter? character,
    List<String>? encounters,
    List<String>? conditions,
  }) {
    return OnlinePlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      isMaster: isMaster ?? this.isMaster,
      character: character ?? this.character,
      encounters: encounters ?? this.encounters,
      conditions: conditions ?? this.conditions,
    );
  }
}

class OnlineRoom {
  final String id;
  final String code;
  final String name;
  final OnlinePlayer master;
  final List<OnlinePlayer> players;
  final DateTime createdAt;

  const OnlineRoom({
    required this.id,
    required this.code,
    required this.name,
    required this.master,
    this.players = const [],
    required this.createdAt,
  });

  OnlineRoom copyWith({
    String? id,
    String? code,
    String? name,
    OnlinePlayer? master,
    List<OnlinePlayer>? players,
    DateTime? createdAt,
  }) {
    return OnlineRoom(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      master: master ?? this.master,
      players: players ?? this.players,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'master': master.toJson(),
      'players': players.map((player) => player.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OnlineRoom.fromJson(Map<String, dynamic> json) {
    return OnlineRoom(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      master: OnlinePlayer.fromJson(json['master'] as Map<String, dynamic>),
      players: (json['players'] as List<dynamic>)
          .map((item) => OnlinePlayer.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
