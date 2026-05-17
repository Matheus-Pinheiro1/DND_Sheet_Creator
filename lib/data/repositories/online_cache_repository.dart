import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/hive_constants.dart';
import '../models/online_room_model.dart';

class OnlineCacheRepository {
  static const _lastRoomKey = 'last_online_room';

  Box<String> get _box => Hive.box<String>(HiveConstants.onlineRoomCacheBox);

  OnlineRoom? loadLastRoom() {
    final stored = _box.get(_lastRoomKey);
    if (stored == null) return null;

    try {
      return OnlineRoom.fromJson(json.decode(stored) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLastRoom(OnlineRoom room) async {
    await _box.put(_lastRoomKey, json.encode(room.toJson()));
  }

  Future<void> clearLastRoom() async {
    await _box.delete(_lastRoomKey);
  }
}
