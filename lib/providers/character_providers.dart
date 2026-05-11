import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/character_model.dart';
import '../data/repositories/character_repository.dart';
import '../core/constants/hive_constants.dart';

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepository();
});

final charactersProvider =
    StateNotifierProvider<CharactersNotifier, List<CharacterModel>>((ref) {
  final repo = ref.watch(characterRepositoryProvider);
  return CharactersNotifier(repo);
});

class CharactersNotifier extends StateNotifier<List<CharacterModel>> {
  final CharacterRepository _repo;

  StreamSubscription<BoxEvent>? _subscription;

  CharactersNotifier(this._repo) : super([]) {
    _loadCharacters();

    _subscription = Hive.box<CharacterModel>(HiveConstants.characterBox)
        .watch()
        .listen((_) => _loadCharacters());
  }

  void _loadCharacters() {
    state = List.unmodifiable(_repo.getAllCharacters());
  }

  Future<void> addCharacter(CharacterModel character) async {
    await _repo.saveCharacter(character);
    _loadCharacters();
  }

  Future<void> updateCharacter(CharacterModel character) async {
    await _repo.updateCharacter(character);
    _loadCharacters();
  }

  Future<void> deleteCharacter(String id) async {
    await _repo.deleteCharacter(id);
    _loadCharacters();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final characterByIdProvider =
    Provider.family<CharacterModel?, String>((ref, id) {
  final characters = ref.watch(charactersProvider);
  try {
    return characters.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});
