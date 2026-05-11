import 'package:hive_flutter/hive_flutter.dart';
import '../models/character_model.dart';
import '../../core/constants/hive_constants.dart';

class CharacterRepository {
  Box<CharacterModel> get _box =>
      Hive.box<CharacterModel>(HiveConstants.characterBox);

  List<CharacterModel> getAllCharacters() {
    return _box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  CharacterModel? getCharacter(String id) {
    try {
      return _box.values.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCharacter(CharacterModel character) async {
    await _box.put(character.id, character);
  }

  Future<void> updateCharacter(CharacterModel character) async {
    await _box.put(character.id, character);
  }

  Future<void> deleteCharacter(String id) async {
    await _box.delete(id);
  }

  Stream<BoxEvent> watchCharacters() => _box.watch();
}
