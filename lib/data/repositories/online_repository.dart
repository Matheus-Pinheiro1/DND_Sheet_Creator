import 'package:uuid/uuid.dart';
import '../models/online_room_model.dart';

class OnlineRepository {
  final _uuid = const Uuid();
  final Map<String, OnlineRoom> _rooms = {};
  final Map<String, String> _roomCodeIndex = {};

  OnlineRepository({OnlineRoom? initialRoom}) {
    if (initialRoom != null) {
      _rooms[initialRoom.id] = initialRoom;
      _roomCodeIndex[initialRoom.code] = initialRoom.id;
    }
  }

  OnlineRoom createRoom({required String masterName}) {
    final roomId = _uuid.v4();
    final roomCode = _buildRoomCode();
    final master = OnlinePlayer(
      id: _uuid.v4(),
      name: masterName,
      isMaster: true,
      character: const OnlineCharacter(
        name: 'Mestre',
        characterClass: 'Narrador',
        level: 1,
        passivePerception: 12,
        passiveInvestigation: 10,
        passiveInsight: 11,
      ),
    );
    final room = OnlineRoom(
      id: roomId,
      code: roomCode,
      name: 'Sala $roomCode',
      master: master,
      players: [],
      createdAt: DateTime.now(),
    );

    _rooms[roomId] = room;
    _roomCodeIndex[roomCode] = roomId;
    return room;
  }

  OnlineRoom? getRoomById(String roomId) {
    return _rooms[roomId];
  }

  OnlineRoom? getRoomByCode(String code) {
    final roomId = _roomCodeIndex[code.toUpperCase().trim()];
    if (roomId == null) return null;
    return _rooms[roomId];
  }

  void loadInitialRoom(OnlineRoom room) {
    _rooms[room.id] = room;
    _roomCodeIndex[room.code] = room.id;
  }

  OnlineRoom? joinRoom(String code,
      {required String playerName,
      OnlineCharacter? character,
      List<String>? conditions}) {
    final room = getRoomByCode(code);
    if (room == null) return null;

    final player = OnlinePlayer(
      id: _uuid.v4(),
      name: playerName,
      isMaster: false,
      character: character ?? OnlineCharacter(
        name: 'Player $playerName',
        characterClass: 'Aventureiro',
        level: 1,
        passivePerception: 10,
        passiveInvestigation: 10,
        passiveInsight: 10,
      ),
      conditions: conditions ?? const [],
    );

    final updatedRoom = room.copyWith(
      players: [...room.players, player],
    );

    _rooms[room.id] = updatedRoom;
    return updatedRoom;
  }

  String _buildRoomCode() {
    const allowed = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final buffer = StringBuffer();
    for (var i = 0; i < 6; i++) {
      final index = _uuid.v4().hashCode.abs() % allowed.length;
      buffer.write(allowed[index]);
    }
    final code = buffer.toString();
    if (_roomCodeIndex.containsKey(code)) {
      return _buildRoomCode();
    }
    return code;
  }
}
