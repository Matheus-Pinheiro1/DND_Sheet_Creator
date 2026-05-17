import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/online_room_model.dart';
import '../data/repositories/online_cache_repository.dart';
import '../data/repositories/online_repository.dart';

final onlineCacheRepositoryProvider = Provider<OnlineCacheRepository>((_) {
  return OnlineCacheRepository();
});

final onlineRepositoryProvider = Provider<OnlineRepository>((ref) {
  final cache = ref.read(onlineCacheRepositoryProvider);
  return OnlineRepository(initialRoom: cache.loadLastRoom());
});

final onlineRoomProvider =
    StateNotifierProvider<OnlineRoomNotifier, OnlineRoom?>((ref) {
  return OnlineRoomNotifier(
    ref.read(onlineRepositoryProvider),
    ref.read(onlineCacheRepositoryProvider),
  );
});

class OnlineRoomNotifier extends StateNotifier<OnlineRoom?> {
  final OnlineRepository _repository;
  final OnlineCacheRepository _cacheRepository;

  OnlineRoomNotifier(this._repository, this._cacheRepository)
      : super(_cacheRepository.loadLastRoom()) {
    final initialRoom = _cacheRepository.loadLastRoom();
    if (initialRoom != null) {
      _repository.loadInitialRoom(initialRoom);
    }
  }

  OnlineRoom createRoom({required String masterName}) {
    final room = _repository.createRoom(masterName: masterName);
    state = room;
    _cacheRepository.saveLastRoom(room);
    return room;
  }

  OnlineRoom? joinRoom(String code,
      {required String playerName,
      OnlineCharacter? character,
      List<String>? conditions}) {
    final joined = _repository.joinRoom(
      code,
      playerName: playerName,
      character: character,
      conditions: conditions,
    );
    if (joined != null) {
      state = joined;
      _cacheRepository.saveLastRoom(joined);
    }
    return joined;
  }

  OnlineRoom? loadRoomById(String roomId) {
    final room = _repository.getRoomById(roomId);
    if (room != null) {
      state = room;
      _cacheRepository.saveLastRoom(room);
    }
    return room;
  }

  Future<void> clearLastRoom() async {
    state = null;
    await _cacheRepository.clearLastRoom();
  }
}
